FROM mydumper/mydumper:v0.14.5-2

ENV TEMPDIR="/tmp" \
    SKIP_OUTDIR="false" \
    EXTRA_MYDUMPER_ARGS="--no-locks" \
    EXTRA_MYLOADER_ARGS=""

ADD clone-db.sh /usr/local/bin/

ENTRYPOINT /usr/local/bin/clone-db.sh

VOLUME /backup
