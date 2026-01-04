#!/usr/bin/env bash

# Monitor USB device connections and show notifications

# Check if udisksctl is available
if ! command -v udisksctl &>/dev/null; then
    exit 0
fi

# Monitor udev events
udevadm monitor --udev --subsystem-match=block 2>/dev/null | while read -r line; do
    if echo "$line" | grep -q "add.*usb"; then
        sleep 1  # Wait for device to settle
        
        # Get device info
        DEVICE=$(echo "$line" | grep -oP '/dev/sd[a-z][0-9]*' | head -1)
        
        if [ -n "$DEVICE" ]; then
            # Get label/name
            LABEL=$(lsblk -no LABEL "$DEVICE" 2>/dev/null)
            [ -z "$LABEL" ] && LABEL=$(lsblk -no MODEL "$DEVICE" 2>/dev/null | xargs)
            [ -z "$LABEL" ] && LABEL="USB Device"
            
            SIZE=$(lsblk -no SIZE "$DEVICE" 2>/dev/null)
            
            notify-send \
                -u normal \
                -t 4000 \
                -h string:x-dunst-stack-tag:usb \
                "USB Device Connected" \
                "${LABEL}\nSize: ${SIZE}\nDevice: ${DEVICE}"
        fi
    fi
done
