#!/usr/bin/env bash

STATE_FILE="/tmp/mic_indicator_state"

# 1. Get running source outputs (Apps using Mic)
# We exclude 'monitor' sources to avoid false positives
APPS=$(pactl list source-outputs 2>/dev/null | grep -E 'application.name|application.process.binary' | cut -d '"' -f2 | sort -u | paste -sd "," -)

# 2. Check if Mic is actually RUNNING (Hardware level)
IS_RUNNING=$(pactl list sources short | grep "RUNNING" | grep -v "monitor")

if [ -n "$IS_RUNNING" ] && [ -n "$APPS" ]; then
    # NOTIFY if state changed from inactive to active
    LAST_STATE=$(cat "$STATE_FILE" 2>/dev/null)
    if [ "$LAST_STATE" != "active" ]; then
        notify-send -u low -t 2000 "Microphone" "󰍬 Active: $APPS"
        echo "active" > "$STATE_FILE"
    fi
    
    # JSON Output for Waybar
    echo "{\"text\": \"󰍬\", \"tooltip\": \"Microphone Active\nUsing: $APPS\", \"class\": \"recording\"}"
else
    # Reset state
    echo "inactive" > "$STATE_FILE"
    echo ""
fi