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

VOLUME_DIR=/data

pre_checks() {
    test -e "$VOLUME_DIR" || { echo "Volume $VOLUME_DIR does not exists"; exit 1; }
    test -d "$VOLUME_DIR" || { echo "Volume $VOLUME_DIR is not a directory"; exit 1; }
}

prepare_volume() {
    cp /etc/hostname $VOLUME_DIR/etc/hostname
    cp /etc/resolv.conf $VOLUME_DIR/etc/resolv.conf

    mount --make-shared $VOLUME_DIR
    mount -t tmpfs tmpfs $VOLUME_DIR/tmp
    mount -t tmpfs tmpfs $VOLUME_DIR/run
    mkdir $VOLUME_DIR/run/lock
    mount -t tmpfs tmpfs $VOLUME_DIR/run/lock
    mount --bind /proc $VOLUME_DIR/proc
    mount --bind /sys $VOLUME_DIR/sys
    mount -o remount,rw /sys/fs/cgroup
    mount --bind /sys/fs/cgroup $VOLUME_DIR/sys/fs/cgroup
    mount --rbind /dev $VOLUME_DIR/dev
}

do_chroot() {
    exec chroot $VOLUME_DIR /usr/bin/setpriv \
        --reuid=0 \
        --init-groups \
        --securebits=+noroot \
        --inh-caps=+chown,+dac_override,+fowner,+fsetid,+kill,+setgid,+setuid,+setpcap,+net_bind_service,+net_raw,+audit_write \
        --ambient-caps=+chown,+dac_override,+fowner,+fsetid,+kill,+setgid,+setuid,+setpcap,+net_bind_service,+net_raw,+audit_write \
        -- \
        "$@"
}

pre_checks

prepare_volume

do_chroot /usr/lib/systemd/systemd
