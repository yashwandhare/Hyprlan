#!/usr/bin/env bash

FOCUS_FILE="$HOME/.cache/focus-mode-state"

if [ -f "$FOCUS_FILE" ]; then
    echo '{"text": "󰽥", "tooltip": "Focus Mode: Active", "class": "active"}'
else
    echo '{"text": "", "tooltip": "", "class": ""}'
fi