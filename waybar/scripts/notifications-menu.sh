#!/usr/bin/env bash

LOG_FILE="$HOME/.cache/notification_log.txt"

# Create log file if it doesn't exist
touch "$LOG_FILE"

# Get notification history from log
if [ -s "$LOG_FILE" ]; then
    # Add action buttons at top
    menu_items=$(echo -e "🗑️  Clear All\n📋  Copy Last\n────────────────")
    
    # Read notifications from log (most recent first) - show last 30
    notif_list=$(tac "$LOG_FILE" | head -30)
    
    if [ -n "$notif_list" ]; then
        menu_items=$(echo -e "${menu_items}\n${notif_list}")
    else
        menu_items=$(echo -e "${menu_items}\nNo notifications")
    fi
else
    menu_items="🗑️  Clear All\n📋  Copy Last\n────────────────\nNo notifications"
fi

# Show menu with better formatting
choice=$(echo -e "$menu_items" | wofi \
    --dmenu \
    --prompt "Notifications" \
    --width=500 \
    --height=450 \
    --location=center \
    --hide-scroll \
    --no-actions \
    --cache-file /dev/null)

# Handle actions
if echo "$choice" | grep -q "^🗑️"; then
    > "$LOG_FILE"
    dunstctl close-all 2>/dev/null
    notify-send "Notifications" "All notifications cleared" -t 1000 -u low
elif echo "$choice" | grep -q "^📋"; then
    # Copy last notification to clipboard
    LAST_NOTIF=$(head -n1 "$LOG_FILE" 2>/dev/null)
    if [ -n "$LAST_NOTIF" ]; then
        echo "$LAST_NOTIF" | wl-copy
        notify-send "Notifications" "Last notification copied" -t 1000 -u low
    fi
elif [ -n "$choice" ]; then
    # Copy selected notification to clipboard
    echo "$choice" | wl-copy
    notify-send "Notifications" "Copied to clipboard" -t 1000 -u low
fi
