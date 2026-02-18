#!/bin/sh

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
