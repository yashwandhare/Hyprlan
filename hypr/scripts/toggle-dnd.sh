#!/usr/bin/env bash
CACHE_DIR="$HOME/.cache"
DND_FILE="$CACHE_DIR/dnd-state"
FOCUS_FILE="$CACHE_DIR/focus-mode-state"

if [ -f "$DND_FILE" ]; then
    rm -f "$DND_FILE"
    [ -f "$FOCUS_FILE" ] && rm -f "$FOCUS_FILE" && pkill -RTMIN+9 waybar 2>/dev/null
    dunstctl set-paused false
    notify-send "Do Not Disturb" "Disabled" -u low -i notification-symbolic
else
    touch "$DND_FILE"
    notify-send "Do Not Disturb" "Enabled" -u low -i notification-disabled-symbolic
    sleep 0.2
    dunstctl set-paused true
fi