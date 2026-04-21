#!/bin/bash
INBOX=/opt/openas2/data/inbox
CONNECTOR_URL=${CONNECTOR_URL:-http://localhost:3000}

echo "👀 Watching: $INBOX → $CONNECTOR_URL"

inotifywait -m -e close_write "$INBOX" --format '%f' 2>/dev/null |
while read filename; do
    filepath="$INBOX/$filename"
    # Only process .edi files
    if [[ "$filename" == *.edi ]]; then
        echo "📥 Received: $filename"
        sleep 1
        HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" \
            -X POST "$CONNECTOR_URL/edi/inbound" \
            -H "Content-Type: text/plain" \
            -H "X-Filename: $filename" \
            --data-binary "@$filepath")
        echo "→ Forwarded to connector: HTTP $HTTP_CODE"
        if [ "$HTTP_CODE" = "200" ]; then
            mv "$filepath" /opt/openas2/data/sent/
        fi
    fi
done
