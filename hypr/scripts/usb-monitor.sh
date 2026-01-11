#!/usr/bin/env bash
command -v udevadm >/dev/null 2>&1 || exit 0

udevadm monitor --udev --subsystem-match=block | while read -r line; do
    echo "$line" | grep -q "add.*usb" || continue
    sleep 0.5
    DEVNAME=$(echo "$line" | grep -oP 'sd[a-z][0-9]+' | head -1)
    [ -z "$DEVNAME" ] && continue
    
    DEVICE="/dev/$DEVNAME"
    LABEL=$(lsblk -no LABEL "$DEVICE" 2>/dev/null)
    [ -z "$LABEL" ] && LABEL=$(lsblk -no MODEL "$DEVICE" 2>/dev/null)
    SIZE=$(lsblk -no SIZE "$DEVICE" 2>/dev/null)
    notify-send "USB Connected" "${LABEL:-USB Device} ($SIZE)" -i drive-removable-media -u normal -h string:x-dunst-stack-tag:usb
done