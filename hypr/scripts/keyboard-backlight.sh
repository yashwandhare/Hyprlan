#!/usr/bin/env bash

# Auto-detect keyboard backlight device
DEVICE=""
for dev in /sys/class/leds/*::kbd_backlight /sys/class/leds/*kbd_backlight*; do
    if [[ -d "$dev" ]]; then
        DEVICE="$dev"
        break
    fi
done

# Fallback to common ASUS path if not found
if [[ -z "$DEVICE" ]]; then
DEVICE="/sys/class/leds/asus::kbd_backlight"
fi

if [[ ! -d "$DEVICE" ]] || [[ ! -f "$DEVICE/brightness" ]] || [[ ! -f "$DEVICE/max_brightness" ]]; then
    exit 1
fi

MAX_BRIGHT=$(cat "$DEVICE/max_brightness" 2>/dev/null)
CURRENT=$(cat "$DEVICE/brightness" 2>/dev/null)

# Validate values
if [[ -z "$MAX_BRIGHT" ]] || [[ -z "$CURRENT" ]] || [[ "$MAX_BRIGHT" -eq 0 ]]; then
    exit 1
fi

# Calculate percentage
PERCENT=$((CURRENT * 100 / MAX_BRIGHT))

notify-send "Keyboard Backlight" "Level: ${PERCENT}%"
