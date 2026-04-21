FROM eclipse-temurin:11-jre-jammy

RUN apt-get update && apt-get install -y \
    wget unzip curl openssl inotify-tools \
    && rm -rf /var/lib/apt/lists/*

ENV OPENAS2_VERSION=2.11.1
ENV OPENAS2_HOME=/opt/openas2

RUN mkdir -p $OPENAS2_HOME && \
    wget -q "https://github.com/OpenAS2/OpenAs2App/releases/download/v2.11.1/OpenAS2Server-2.11.1.zip" \
    -O /tmp/openas2.zip && \
    unzip -q /tmp/openas2.zip -d $OPENAS2_HOME && \
    rm /tmp/openas2.zip && \
    chmod +x $OPENAS2_HOME/bin/start-openas2.sh

RUN mkdir -p $OPENAS2_HOME/data/inbox \
    $OPENAS2_HOME/data/outbox \
    $OPENAS2_HOME/data/sent \
    $OPENAS2_HOME/data/failed \
    $OPENAS2_HOME/certs

COPY config/ $OPENAS2_HOME/config/
COPY scripts/ $OPENAS2_HOME/scripts/
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
RUN chmod +x $OPENAS2_HOME/scripts/*.sh

EXPOSE 4080 4443

WORKDIR $OPENAS2_HOME
ENTRYPOINT ["/entrypoint.sh"]
