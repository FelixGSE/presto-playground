FROM openjdk:11

ARG PRESTO_VERSION=333
ARG BUILD_TIME="-"
ARG REVISION="-"

ENV DEBIAN_FRONTEND=noninteractive \
    PRESTO_HOME=/opt/presto \
    PRESTO_RUNTIME_HOME=/var/presto

ENV PATH=${PATH}:${PRESTO_HOME}/bin \
    PRESTO_DATA_DIR=$PRESTO_RUNTIME_HOME/data \ 
    PRESTO_ETC_DIR=$PRESTO_RUNTIME_HOME/etc

LABEL org.opencontainers.image.created=$BUILD_TIME \
      org.opencontainers.image.url="https://github.com/FelixGSE/presto-playground" \
      org.opencontainers.image.source="https://github.com/FelixGSE/presto-playground" \
      org.opencontainers.image.version="MAJOR.MINOR.PATCH" \
      org.opencontainers.image.revision="$REVISION" \
      org.opencontainers.image.vendor="-" \
      org.opencontainers.image.title="Presto" \
      org.opencontainers.image.description="Minimal docker image to run presto" \
      org.opencontainers.image.documentation="https://github.com/FelixGSE/presto-playground/README.md" \
      org.opencontainers.image.authors="FelixGSE" \
      org.opencontainers.image.licenses="Apache-2.0" \
      org.opencontainers.image.ref.name="-"

RUN wget https://repo1.maven.org/maven2/io/prestosql/presto-server/$PRESTO_VERSION/presto-server-$PRESTO_VERSION.tar.gz \
&&  tar -xzf presto-server-$PRESTO_VERSION.tar.gz \
&&  mv presto-server-$PRESTO_VERSION $PRESTO_HOME \
&&  mkdir -p $PRESTO_RUNTIME_HOME \
             $PRESTO_HOME/etc \
             $PRESTO_DATA_DIR \
             $PRESTO_ETC_DIR \
&&  rm presto-server-$PRESTO_VERSION.tar.gz 

COPY /base_config $PRESTO_ETC_DIR

RUN adduser --system \
            --group \
            --no-create-home \
            --home $PRESTO_RUNTIME_HOME \
            --shell /usr/sbin/nologin \
            --disabled-password \
            presto \
&&  chown -R presto:presto $PRESTO_RUNTIME_HOME

USER presto

WORKDIR $PRESTO_RUNTIME_HOME

COPY entrypoint.sh entrypoint.sh

ENTRYPOINT ["./entrypoint.sh"]
