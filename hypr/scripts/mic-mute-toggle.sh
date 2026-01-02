#!/usr/bin/env bash

wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle 2>/dev/null || exit 1

MUTE_STATUS=$(wpctl get-volume @DEFAULT_AUDIO_SOURCE@ 2>/dev/null)
MUTE=$(echo "$MUTE_STATUS" | grep -q "MUTED" && echo "Muted" || echo "Unmuted")

notify-send "Microphone" "󰍬 $MUTE"
