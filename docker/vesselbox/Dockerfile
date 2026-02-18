ARG REGISTRY="docker.io"

FROM $REGISTRY/library/alpine:3.23.3

ARG ALPINE_MIRROR=""

RUN test -n "$ALPINE_MIRROR" && sed -i "s#https\?://dl-cdn.alpinelinux.org/alpine#${ALPINE_MIRROR}#g" /etc/apk/repositories

COPY --chmod=700 init-volume.sh /bin/init-volume.sh
COPY --chmod=700 entrypoint.sh /entrypoint.sh

ENTRYPOINT [ "/entrypoint.sh" ]

# RUN --mount=type=cache,target=/var/cache/apk,sharing=private \
#     apk update

# RUN --mount=type=cache,target=/var/cache/apk,sharing=private \
#     apk add libcap-utils
