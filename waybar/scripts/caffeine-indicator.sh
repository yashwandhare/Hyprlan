#!/usr/bin/env bash

STATE_FILE="$HOME/.cache/caffeine-state"

if [ -f "$STATE_FILE" ]; then
    echo '{"text": "", "tooltip": "Caffeine Enabled", "class": "enabled"}'
else
    echo ''
fi
