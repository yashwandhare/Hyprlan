#!/usr/bin/env bash

DND_FILE="$HOME/.cache/dnd-state"

if [ -f "$DND_FILE" ]; then
    # DND is active, disable it
    rm -f "$DND_FILE"
    dunstctl set-paused false
    notify-send "Do Not Disturb" "Disabled" -t 1000
else
    # DND is inactive, enable it
    touch "$DND_FILE"
    # Show notification BEFORE pausing dunst
    notify-send "Do Not Disturb" "Enabled" -t 1000
    sleep 0.2
    dunstctl set-paused true
fi

