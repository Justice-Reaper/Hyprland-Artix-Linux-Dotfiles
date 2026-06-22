#!/bin/sh
if grep -qE "^\S+ / overlay " /proc/mounts; then
    exit 0
fi
exec /bin/mount -o remount,ro,rshared /
