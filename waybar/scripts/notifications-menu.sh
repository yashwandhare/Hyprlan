#!/usr/bin/env bash

LOG_FILE="$HOME/.cache/notification_log.txt"
touch "$LOG_FILE"

# 1. Build Menu
OPTIONS="🗑️  Clear All\n📋  Copy Last"
if [ -s "$LOG_FILE" ]; then
    # Show last 20 notifications
    HISTORY=$(tac "$LOG_FILE" | head -n 20)
    MENU="$OPTIONS\n────────────────\n$HISTORY"
else
    MENU="$OPTIONS\n────────────────\nNo notifications"
fi

# 2. Show Wofi
SELECTED=$(echo -e "$MENU" | wofi --dmenu --prompt "Notifications" --width=500 --height=400 --cache-file /dev/null)

# 3. Handle Actions
case "$SELECTED" in
    "🗑️  Clear All")
        > "$LOG_FILE"
        dunstctl close-all
        notify-send "Notifications" "History Cleared" -u low
        ;;
    "📋  Copy Last")
        if [ -s "$LOG_FILE" ]; then
            tail -n 1 "$LOG_FILE" | wl-copy
            notify-send "Notifications" "Copied to clipboard" -u low
        fi
        ;;
    *)
        # Copy selected line if clicked
        if [ -n "$SELECTED" ] && [ "$SELECTED" != "────────────────" ] && [ "$SELECTED" != "No notifications" ]; then
            echo "$SELECTED" | wl-copy
            notify-send "Notifications" "Copied: $SELECTED" -u low
        fi
        ;;
esac