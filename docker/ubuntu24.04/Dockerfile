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

FROM $REGISTRY/library/ubuntu:24.04

ARG TARGETARCH TARGETVARIANT CACHE_ID=ubuntu24.04

ARG UBUNTU_MIRROR TZ=UTC LANG=C.UTF8

RUN test -n "$UBUNTU_MIRROR" && sed -Ei "s,(archive|security|ports)\.ubuntu\.com,${UBUNTU_MIRROR},g" /etc/apt/sources.list.d/ubuntu.sources

ENV TZ=$TZ \
    LANG=$LANG

# As this instance is intended to be a complete system, and we use build cache for apt, remove the docker optimizations
RUN rm /etc/apt/apt.conf.d/docker-*

RUN --mount=type=cache,target=/var/lib/apt/lists,sharing=locked,id=apt-lists-${CACHE_ID}-${TARGETARCH}${TARGETVARIANT} \
    --mount=type=cache,target=/var/cache/apt,sharing=locked,id=apt-cache-${CACHE_ID}-${TARGETARCH}${TARGETVARIANT} \
    apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get -y upgrade \
 && echo y | unminimize

RUN --mount=type=cache,target=/var/lib/apt/lists,sharing=locked,id=apt-lists-${CACHE_ID}-${TARGETARCH}${TARGETVARIANT} \
    --mount=type=cache,target=/var/cache/apt,sharing=locked,id=apt-cache-${CACHE_ID}-${TARGETARCH}${TARGETVARIANT} \
    apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y systemd systemd-sysv dbus openssh-server less  \
 && rm -f /etc/ssh/ssh_host_*

# as ubuntu 24.04 doesn't have sshd-keygen.service unit, we take this from debian 13, modified to run when needed.
COPY <<EOF /etc/systemd/system/sshd-keygen.service
[Unit]
Description=Generate sshd host keys on first boot
ConditionPathIsReadWrite=/etc/ssh
ConditionPathIsSymbolicLink=!/etc/ssh
ConditionPathExists=!/etc/ssh/ssh_host_rsa_key
Before=ssh.service sshd.service sshd@.service

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=ssh-keygen -A

[Install]
WantedBy=ssh.service sshd.service sshd@.service ssh.socket
EOF

RUN systemctl set-default multi-user.target \
 && systemctl mask systemd-resolved.service $(systemctl list-unit-files | awk '/\.mount|.automount|systemd-tmpfiles-setup/{print $1}') \
 && systemctl enable sshd-keygen
