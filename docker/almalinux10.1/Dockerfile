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

FROM $REGISTRY/library/almalinux:10.1

ARG TARGETARCH TARGETVARIANT CACHE_ID=almalinux10.1

ARG TZ=UTC LANG=C.UTF8

ENV TZ=$TZ \
    LANG=$LANG

RUN --mount=type=cache,target=/var/cache/dnf,sharing=locked,id=dnf-cache-${CACHE_ID}-${TARGETARCH}${TARGETVARIANT} \
    dnf -y --setopt=keepcache=1 update

RUN --mount=type=cache,target=/var/cache/dnf,sharing=locked,id=dnf-cache-${CACHE_ID}-${TARGETARCH}${TARGETVARIANT} \
    dnf -y --setopt=keepcache=1 install openssh-server openssh-clients

RUN systemctl set-default multi-user.target \
 && systemctl mask `systemctl list-unit-files '*mount' | awk '/mount/{print $1}'`