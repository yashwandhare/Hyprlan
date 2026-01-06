#!/usr/bin/env bash

# -----------------------------------------------------
# USB Monitor Daemon
# -----------------------------------------------------

# Check requirements
if ! command -v udisksctl &>/dev/null; then
    exit 0
fi

# Monitor udev events for USB subsystem
udevadm monitor --udev --subsystem-match=block | while read -r line; do
    if echo "$line" | grep -q "add.*usb"; then
        # Wait for filesystem to register
        sleep 1
        
        # Extract device name (e.g. sdb1)
        DEVNAME=$(echo "$line" | grep -oP 'sd[a-z][0-9]+' | head -1)
        
        if [ -n "$DEVNAME" ]; then
            DEVICE="/dev/$DEVNAME"
            
            # Get Label or Model
            LABEL=$(lsblk -no LABEL "$DEVICE" 2>/dev/null)
            if [ -z "$LABEL" ]; then
                LABEL=$(lsblk -no MODEL "$DEVICE" 2>/dev/null)
            fi
            
            # Get Size
            SIZE=$(lsblk -no SIZE "$DEVICE" 2>/dev/null)
            
            notify-send "USB Connected" "${LABEL:-USB Device} ($SIZE)" \
                -i drive-removable-media \
                -u normal \
                -h string:x-dunst-stack-tag:usb
        fi
    fi
done