#!/usr/bin/env bash

# -----------------------------------------------------
# Microphone Toggle & OSD
# -----------------------------------------------------

# Toggle Mute
wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle 2>/dev/null || exit 1

# Get New Status
STATUS=$(wpctl get-volume @DEFAULT_AUDIO_SOURCE@ 2>/dev/null)

if echo "$STATUS" | grep -q "MUTED"; then
    notify-send "Microphone" "Muted" \
        -u low \
        -i microphone-sensitivity-muted \
        -h string:x-dunst-stack-tag:mic
else
    notify-send "Microphone" "Active" \
        -u low \
        -i microphone-sensitivity-high \
        -h string:x-dunst-stack-tag:mic
fi

# Refresh Waybar
pkill -RTMIN+8 waybar 2>/dev/null