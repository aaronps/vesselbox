#!/bin/sh
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

cp /etc/hostname /data/etc/hostname
cp /etc/resolv.conf /data/etc/resolv.conf 

mount --make-shared /data
mount -t tmpfs tmpfs /data/tmp
mount -t tmpfs tmpfs /data/run
mkdir /data/run/lock
mount -t tmpfs tmpfs /data/run/lock
mount --bind /proc /data/proc
mount --bind /sys /data/sys
mount -o remount,rw /sys/fs/cgroup
mount --bind /sys/fs/cgroup /data/sys/fs/cgroup
mount --rbind /dev /data/dev

exec chroot /data /usr/bin/setpriv \
    --reuid=0 \
    --init-groups \
    --securebits=+noroot \
    --inh-caps=+chown,+dac_override,+fowner,+fsetid,+kill,+setgid,+setuid,+setpcap,+net_bind_service,+net_raw,+audit_write \
    --ambient-caps=+chown,+dac_override,+fowner,+fsetid,+kill,+setgid,+setuid,+setpcap,+net_bind_service,+net_raw,+audit_write \
    -- \
    /usr/lib/systemd/systemd
