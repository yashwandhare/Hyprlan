#!/usr/bin/env bash

# Check if default source is muted
if wpctl get-volume @DEFAULT_AUDIO_SOURCE@ | grep -q "MUTED"; then
    echo "󰍬 MUTE"
else
    echo ""
fi