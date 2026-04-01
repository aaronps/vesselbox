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

FROM $REGISTRY/library/debian:13.3

ARG TARGETARCH TARGETVARIANT CACHE_ID=debian13.3

ARG DEBIAN_MIRROR TZ=UTC LANG=C.UTF8

RUN test -n "$DEBIAN_MIRROR" && sed -Ei "s,deb\.debian\.org,${DEBIAN_MIRROR},g" /etc/apt/sources.list.d/debian.sources

ENV TZ=$TZ \
    LANG=$LANG

# As this instance is intended to be a complete system, and we use build cache for apt, remove the docker optimizations
RUN rm /etc/apt/apt.conf.d/docker-*

RUN --mount=type=cache,target=/var/lib/apt/lists,sharing=locked,id=apt-lists-${CACHE_ID}-${TARGETARCH}${TARGETVARIANT} \
    --mount=type=cache,target=/var/cache/apt,sharing=locked,id=apt-cache-${CACHE_ID}-${TARGETARCH}${TARGETVARIANT} \
    apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get -y upgrade

# we use a separated step temporarily until the package list is stabilized.
RUN --mount=type=cache,target=/var/lib/apt/lists,sharing=locked,id=apt-lists-${CACHE_ID}-${TARGETARCH}${TARGETVARIANT} \
    --mount=type=cache,target=/var/cache/apt,sharing=locked,id=apt-cache-${CACHE_ID}-${TARGETARCH}${TARGETVARIANT} \
    apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends systemd systemd-sysv dbus openssh-server \
 && rm -f /etc/ssh/ssh_host_*

# Configure the sshd-keygen service to run when needed
COPY <<EOF /etc/systemd/system/sshd-keygen.service.d/override.conf
[Unit]
ConditionFirstBoot=
ConditionPathExists=!/etc/ssh/ssh_host_rsa_key
EOF

# Remove CAP_AUDIT_WRITE from dbus, it now fails as we removed this capability.
COPY <<EOF /etc/systemd/system/dbus.service.d/override.conf
[Service]
AmbientCapabilities=
EOF

RUN systemctl set-default multi-user.target \
 && systemctl mask $(systemctl list-unit-files '*mount' | awk '/mount/{print $1}')
