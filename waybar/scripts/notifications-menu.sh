#!/usr/bin/env bash
LOG_FILE="$HOME/.cache/notification_log.txt"
ROFI_THEME="$HOME/.config/hyprland/hypr/rofi/launcher.rasi"
touch "$LOG_FILE"

[ -s "$LOG_FILE" ] && HISTORY=$(tac "$LOG_FILE" | head -n 30) && \
    MENU="🗑️  Clear All\n📋  Copy Last\n────────────────\n$HISTORY" || \
    MENU="🗑️  Clear All\n📋  Copy Last\n────────────────\nNo notifications"

SELECTED=$(echo -e "$MENU" | rofi -dmenu -p "Notifications" -theme "$ROFI_THEME" -markup-rows)

case "$SELECTED" in
    "🗑️  Clear All")
        > "$LOG_FILE"
        dunstctl close-all
        notify-send "Notifications" "History Cleared" -u low
        ;;
    "📋  Copy Last")
        [ -s "$LOG_FILE" ] && tail -n 1 "$LOG_FILE" | wl-copy && notify-send "Notifications" "Copied to clipboard" -u low
        ;;
    *)
        [ -n "$SELECTED" ] && [[ "$SELECTED" != *"────────────────"* ]] && [[ "$SELECTED" != "No notifications" ]] && \
            echo "$SELECTED" | wl-copy && notify-send "Notifications" "Copied to clipboard" -u low
        ;;
esac