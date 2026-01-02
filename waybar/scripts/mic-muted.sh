#!/bin/bash

# Check if microphone is muted using wpctl
MUTE_STATUS=$(wpctl get-volume @DEFAULT_AUDIO_SOURCE@ 2>/dev/null)

if echo "$MUTE_STATUS" | grep -q "MUTED"; then
    echo "󰍬 MUTE"
else
    echo ""
fi
