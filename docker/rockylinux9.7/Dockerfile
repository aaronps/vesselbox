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

FROM $REGISTRY/rockylinux/rockylinux:9.7

ARG TARGETARCH TARGETVARIANT CACHE_ID=rockylinux9.7

ARG ROCKY_MIRROR TZ=UTC LANG=C.UTF8
# export ROCKY_MIRROR=https://mirror.nju.edu.cn/rocky

RUN test -n "$ROCKY_MIRROR" \
 && sed -e "s|^mirrorlist=|#mirrorlist=|g" \
        -e "s|^#baseurl=http://dl.rockylinux.org/\$contentdir|baseurl=$ROCKY_MIRROR|g" \
        -i \
        /etc/yum.repos.d/rocky*.repo

ENV TZ=$TZ \
    LANG=$LANG

# when installing packages, also install documentation, like real server
RUN sed -i 's/tsflags=nodocs/#tsflags=nodocs/' /etc/dnf/dnf.conf

RUN --mount=type=cache,target=/var/cache/dnf,sharing=locked,id=dnf-cache-${CACHE_ID}-${TARGETARCH}${TARGETVARIANT} \
    dnf -y --setopt=keepcache=1 update

RUN --mount=type=cache,target=/var/cache/dnf,sharing=locked,id=dnf-cache-${CACHE_ID}-${TARGETARCH}${TARGETVARIANT} \
    dnf -y --setopt=keepcache=1 install systemd

RUN systemctl set-default multi-user.target \
 && systemctl mask `systemctl list-unit-files '*mount' | awk '/mount/{print $1}'`

RUN --mount=type=cache,target=/var/cache/dnf,sharing=locked,id=dnf-cache-${CACHE_ID}-${TARGETARCH}${TARGETVARIANT} \
    dnf -y --setopt=keepcache=1 install openssh
