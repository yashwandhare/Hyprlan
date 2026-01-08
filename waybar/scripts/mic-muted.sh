#!/usr/bin/env bash

# Check if default source is muted
if wpctl get-volume @DEFAULT_AUDIO_SOURCE@ | grep -q "MUTED"; then
    echo "{\"text\": \"󰍭\", \"tooltip\": \"Microphone Muted\", \"class\": \"muted\"}"
else
    echo ""
fi