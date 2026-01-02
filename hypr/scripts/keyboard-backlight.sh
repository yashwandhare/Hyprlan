#!/bin/bash

DEVICE="/sys/class/leds/asus::kbd_backlight"

if [[ ! -d "$DEVICE" ]]; then
    exit 1
fi

MAX_BRIGHT=$(cat "$DEVICE/max_brightness")
CURRENT=$(cat "$DEVICE/brightness")

# Calculate percentage
PERCENT=$((CURRENT * 100 / MAX_BRIGHT))

notify-send "Keyboard Backlight" "Level: ${PERCENT}%"
