# Copyright 2026 Aaron Perez Sanchez <aaronperezsanchez@hotmail.com>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

ARG REGISTRY="docker.io"

FROM $REGISTRY/library/alpine:3.23.3

ARG TARGETARCH TARGETVARIANT CACHE_ID=alpine3.23

ARG ALPINE_MIRROR=""

RUN test -n "$ALPINE_MIRROR" && sed -i "s#https\?://dl-cdn.alpinelinux.org/alpine#${ALPINE_MIRROR}#g" /etc/apk/repositories

RUN --mount=type=cache,target=/var/cache/apk,sharing=locked,id=apt-lists-${CACHE_ID}-${TARGETARCH}${TARGETVARIANT} \
    apk update

RUN --mount=type=cache,target=/var/cache/apk,sharing=locked,id=apt-lists-${CACHE_ID}-${TARGETARCH}${TARGETVARIANT} \
    apk add bash crane

COPY --chmod=500 \
    scripts/entrypoint.sh \
    scripts/init-volume.sh \
    /usr/local/sbin/

ENTRYPOINT [ "entrypoint.sh" ]


