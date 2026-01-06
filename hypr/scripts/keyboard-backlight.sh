#!/usr/bin/env bash

# -----------------------------------------------------
# Keyboard Backlight Control (Cycle & OSD)
# -----------------------------------------------------

# 1. Action (up/down/cycle)
ACTION="$1"

# 2. Get Device (Auto-detect)
DEVICE=$(find /sys/class/leds -name "*::kbd_backlight" | head -n1)
if [ -z "$DEVICE" ]; then
    DEVICE=$(find /sys/class/leds -name "*kbd_backlight*" | head -n1)
fi

[ -z "$DEVICE" ] && exit 0

# Helper to get current %
get_percent() {
    local cur=$(brightnessctl --device='*::kbd_backlight' get)
    local max=$(brightnessctl --device='*::kbd_backlight' max)
    echo $((cur * 100 / max))
}

# 3. Apply Change
if [ -n "$ACTION" ]; then
    CURRENT=$(get_percent)
    
    if [ "$ACTION" == "up" ]; then
        brightnessctl --device='*::kbd_backlight' set +33%
    elif [ "$ACTION" == "down" ]; then
        brightnessctl --device='*::kbd_backlight' set 33%-
    elif [ "$ACTION" == "cycle" ]; then
        # Cycle: Off -> Med -> High -> Off
        if [ "$CURRENT" -ge 95 ]; then
            brightnessctl --device='*::kbd_backlight' set 0
        elif [ "$CURRENT" -ge 45 ]; then
            brightnessctl --device='*::kbd_backlight' set 100%
        else
            brightnessctl --device='*::kbd_backlight' set 50%
        fi
    fi
fi

# 4. Notify New State
NEW_PERCENT=$(get_percent)
notify-send "Keyboard" "${NEW_PERCENT}%" \
    -t 800 \
    -u low \
    -i keyboard-brightness-symbolic \
    -h string:x-dunst-stack-tag:kbd_backlight \
    -h int:value:"$NEW_PERCENT"