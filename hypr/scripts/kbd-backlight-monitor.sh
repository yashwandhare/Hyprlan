#!/usr/bin/env bash

# Auto-detect keyboard backlight device
DEVICE_DIR=""
for dev in /sys/class/leds/*::kbd_backlight /sys/class/leds/*kbd_backlight*; do
    if [[ -d "$dev" ]] && [[ -f "$dev/brightness" ]]; then
        DEVICE_DIR="$dev"
        break
    fi
done

# Fallback to common ASUS path if not found
if [[ -z "$DEVICE_DIR" ]]; then
    DEVICE_DIR="/sys/class/leds/asus::kbd_backlight"
fi

BRIGHTNESS_FILE="$DEVICE_DIR/brightness"
MAX_BRIGHTNESS_FILE="$DEVICE_DIR/max_brightness"

# Exit if device not found
if [[ ! -f "$BRIGHTNESS_FILE" ]] || [[ ! -f "$MAX_BRIGHTNESS_FILE" ]]; then
    exit 0
fi

LAST_VALUE=$(cat "$BRIGHTNESS_FILE" 2>/dev/null || echo "")

while true; do
    CURRENT=$(cat "$BRIGHTNESS_FILE" 2>/dev/null || echo "")
    if [[ -n "$CURRENT" ]] && [[ -n "$LAST_VALUE" ]] && [[ "$CURRENT" != "$LAST_VALUE" ]]; then
        MAX_BRIGHT=$(cat "$MAX_BRIGHTNESS_FILE" 2>/dev/null || echo "0")
        if [[ -n "$MAX_BRIGHT" ]] && [[ "$MAX_BRIGHT" -gt 0 ]]; then
        PERCENT=$((CURRENT * 100 / MAX_BRIGHT))
        notify-send "Keyboard Backlight" "Level: ${PERCENT}%"
        fi
    fi
    LAST_VALUE="$CURRENT"
    sleep 0.2
done
