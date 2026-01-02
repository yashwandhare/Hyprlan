#!/bin/bash

DEVICE="/sys/class/leds/asus::kbd_backlight/brightness"
LAST_VALUE=$(cat "$DEVICE" 2>/dev/null)

while true; do
    CURRENT=$(cat "$DEVICE" 2>/dev/null)
    if [[ "$CURRENT" != "$LAST_VALUE" && -n "$CURRENT" && -n "$LAST_VALUE" ]]; then
        MAX_BRIGHT=$(cat /sys/class/leds/asus::kbd_backlight/max_brightness)
        PERCENT=$((CURRENT * 100 / MAX_BRIGHT))
        notify-send "Keyboard Backlight" "Level: ${PERCENT}%"
    fi
    LAST_VALUE="$CURRENT"
    sleep 0.2
done
