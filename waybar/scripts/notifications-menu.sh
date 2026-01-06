#!/usr/bin/env bash

# -----------------------------------------------------
# Notification History (Rofi)
# -----------------------------------------------------

LOG_FILE="$HOME/.cache/notification_log.txt"
ROFI_THEME="$HOME/.config/hypr/rofi/launcher.rasi"
touch "$LOG_FILE"

# 1. Build Menu
# Note: Rofi handles newlines differently, so we list actions first
if [ -s "$LOG_FILE" ]; then
    HISTORY=$(tac "$LOG_FILE" | head -n 30)
    # Using printf to separate actions from history cleanly
    MENU="🗑️  Clear All\n📋  Copy Last\n────────────────\n$HISTORY"
else
    MENU="🗑️  Clear All\n📋  Copy Last\n────────────────\nNo notifications"
fi

# 2. Show Rofi
SELECTED=$(echo -e "$MENU" | rofi -dmenu \
    -p "Notifications" \
    -theme "$ROFI_THEME" \
    -markup-rows)

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
        if [ -n "$SELECTED" ] && [[ "$SELECTED" != *"────────────────"* ]] && [[ "$SELECTED" != "No notifications" ]]; then
            echo "$SELECTED" | wl-copy
            notify-send "Notifications" "Copied to clipboard" -u low
        fi
        ;;
esac