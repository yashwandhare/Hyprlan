#!/usr/bin/env bash

# -----------------------------------------------------
# Toggle Do Not Disturb
# -----------------------------------------------------

CACHE_DIR="$HOME/.cache"
DND_FILE="$CACHE_DIR/dnd-state"
FOCUS_FILE="$CACHE_DIR/focus-mode-state"

if [ -f "$DND_FILE" ]; then
    # -------------------------------------------------
    # DISABLE DND
    # -------------------------------------------------
    rm -f "$DND_FILE"
    
    # If Focus Mode was on, this breaks it, so clear that state too
    if [ -f "$FOCUS_FILE" ]; then
        rm -f "$FOCUS_FILE"
        pkill -RTMIN+9 waybar 2>/dev/null # Update Focus indicator
    fi

    dunstctl set-paused false
    notify-send "Do Not Disturb" "Disabled" -u low -i notification-symbolic
else
    # -------------------------------------------------
    # ENABLE DND
    # -------------------------------------------------
    touch "$DND_FILE"
    
    # Notify BEFORE pausing (so you see the confirmation)
    notify-send "Do Not Disturb" "Enabled" -u low -i notification-disabled-symbolic
    sleep 0.2
    dunstctl set-paused true
fi