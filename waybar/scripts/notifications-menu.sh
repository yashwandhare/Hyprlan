#!/usr/bin/env bash

LOG_FILE="$HOME/.cache/notification_log.txt"

# Create log file if it doesn't exist
touch "$LOG_FILE"

# Get notification history from log
if [ -s "$LOG_FILE" ]; then
    # Add Clear All option at top
    menu_items=$(echo -e "🗑️  Clear All\n────────────────")
    
    # Read notifications from log (most recent first)
    notif_list=$(tac "$LOG_FILE" | head -20)
    
    if [ -n "$notif_list" ]; then
        menu_items=$(echo -e "${menu_items}\n${notif_list}")
    else
        menu_items=$(echo -e "${menu_items}\nNo notifications")
    fi
else
    menu_items="🗑️  Clear All\n────────────────\nNo notifications"
fi

# Show menu
choice=$(echo -e "$menu_items" | wofi --dmenu --prompt "" --width=450 --height=400 --location=center --hide-scroll --no-actions)

# Check if Clear All was selected (match any line starting with the emoji)
if echo "$choice" | grep -q "^🗑️"; then
    > "$LOG_FILE"  # Clear the log file
    dunstctl close-all 2>/dev/null
    notify-send "Notifications" "All notifications cleared" -t 1000
fi
