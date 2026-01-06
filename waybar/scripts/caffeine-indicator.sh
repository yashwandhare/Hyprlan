#!/usr/bin/env bash

STATE_FILE="$HOME/.cache/caffeine-state"
FOCUS_FILE="$HOME/.cache/focus-mode-state"

# Only show if enabled AND Focus Mode is NOT active
if [ -f "$STATE_FILE" ] && [ ! -f "$FOCUS_FILE" ]; then
    echo '{"text": "", "tooltip": "Caffeine: Enabled", "class": "active"}'
else
    echo '{"text": "", "tooltip": "", "class": ""}'
fi