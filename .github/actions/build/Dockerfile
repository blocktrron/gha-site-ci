ARG CONTAINER=ghcr.io/freifunk-gluon/gluon-build
ARG VERSION=master
FROM $CONTAINER:$VERSION

COPY --chmod=0755 entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]