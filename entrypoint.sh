#!/bin/bash
set -e

OPENAS2_HOME=/opt/openas2
CONFIG=$OPENAS2_HOME/config/config.xml
PARTNERSHIPS=$OPENAS2_HOME/config/partnerships.xml

echo "🚀 Starting BusinessOS OpenAS2 Gateway..."
echo "   Sender ID:   ${AS2_SENDER_ID:-3863629312}"
echo "   Receiver ID: ${AS2_RECEIVER_ID:-521227911TDL}"
echo "   Environment: ${NODE_ENV:-development}"

# Generate self-signed cert if not exists
if [ ! -f "$OPENAS2_HOME/certs/openas2.p12" ]; then
    echo "🔐 Generating SSL certificate..."
    openssl req -x509 -newkey rsa:2048 \
        -keyout /tmp/key.pem \
        -out /tmp/cert.pem \
        -days 3650 -nodes \
        -subj "/C=US/ST=Florida/L=Branford/O=BusinessOS/CN=${AS2_DOMAIN:-edi.runbusiness.com}"

    openssl pkcs12 -export \
        -in /tmp/cert.pem \
        -inkey /tmp/key.pem \
        -out $OPENAS2_HOME/certs/openas2.p12 \
        -name openas2 \
        -passout pass:${CERT_PASSWORD:-openas2password}

    keytool -importkeystore \
        -srckeystore $OPENAS2_HOME/certs/openas2.p12 \
        -srcstoretype PKCS12 \
        -srcstorepass ${CERT_PASSWORD:-openas2password} \
        -destkeystore $OPENAS2_HOME/certs/as2_certs.jks \
        -deststorepass ${CERT_PASSWORD:-openas2password} \
        -noprompt 2>/dev/null

    echo "✅ Certificate generated"
    echo "📋 Export this cert to share with Lennette at DLA:"
    openssl x509 -in /tmp/cert.pem -text -noout | grep -A2 "Subject:"
fi

# Inject env vars into config files
sed -i "s|{{AS2_SENDER_ID}}|${AS2_SENDER_ID:-3863629312}|g" $CONFIG $PARTNERSHIPS
sed -i "s|{{AS2_RECEIVER_ID}}|${AS2_RECEIVER_ID:-521227911TDL}|g" $CONFIG $PARTNERSHIPS
sed -i "s|{{CERT_PASSWORD}}|${CERT_PASSWORD:-openas2password}|g" $CONFIG $PARTNERSHIPS
sed -i "s|{{CONNECTOR_URL}}|${CONNECTOR_URL:-http://localhost:3000}|g" $CONFIG $PARTNERSHIPS
sed -i "s|{{GEX_AS2_URL}}|${GEX_AS2_URL:-https://gex.dla.mil/as2}|g" $CONFIG $PARTNERSHIPS

# Start inbox watcher in background
echo "👀 Starting inbox watcher..."
bash $OPENAS2_HOME/scripts/watch-inbox.sh &

echo "✅ Starting OpenAS2..."
exec $OPENAS2_HOME/bin/start-openas2.sh
