#!/bin/bash

# Toggle microphone mute
wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle

# Get current mute status
MUTE=$(wpctl get-volume @DEFAULT_AUDIO_SOURCE@ | grep -q MUTED && echo "Muted" || echo "Unmuted")

notify-send "Microphone" "󰍬 $MUTE"
