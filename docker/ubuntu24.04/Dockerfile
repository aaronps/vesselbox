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

ARG UBUNTU_MIRROR TZ=UTC LANG=C.UTF8

RUN test -n "$UBUNTU_MIRROR" && sed -Ei "s,(archive|security|ports)\.ubuntu\.com,${UBUNTU_MIRROR},g" /etc/apt/sources.list.d/ubuntu.sources

ENV TZ=$TZ \
    LANG=$LANG

RUN --mount=type=cache,target=/var/lib/apt,sharing=private \
    --mount=type=cache,target=/var/cache/apt,sharing=private \
    apt -y update \
 && apt -y upgrade \
 && echo y | unminimize

RUN --mount=type=cache,target=/var/lib/apt,sharing=private \
    --mount=type=cache,target=/var/cache/apt,sharing=private \
    DEBIAN_FRONTEND=noninteractive apt install -y --no-install-recommends systemd dbus 

RUN systemctl set-default multi-user.target \
 && systemctl mask `systemctl list-unit-files '*mount' | awk '/mount/{print $1}'`
