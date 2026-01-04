#!/usr/bin/env bash

STATE_FILE="$HOME/.cache/caffeine-state"
FOCUS_FILE="$HOME/.cache/focus-mode-state"

# Only show caffeine icon if caffeine is enabled AND focus mode is NOT active
if [ -f "$STATE_FILE" ] && [ ! -f "$FOCUS_FILE" ]; then
    echo '{"text": "", "tooltip": "Caffeine Enabled", "class": "enabled"}'
else
    echo ''
fi
