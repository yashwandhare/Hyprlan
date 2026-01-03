#!/usr/bin/env bash

# Dunst notification logger - captures all notifications to a log file
# This script should be called by dunst on every notification

LOG_FILE="$HOME/.cache/notification_log.txt"
MAX_ENTRIES=100

# Get notification details from dunst environment variables
APPNAME="${1:-Unknown}"
SUMMARY="${2:-}"
BODY="${3:-}"
ICON="${4:-}"

# Skip logging for system control notifications
if [ "$SUMMARY" = "All notifications cleared" ] || \
   [ "$SUMMARY" = "Do Not Disturb" ] || \
   [ "$APPNAME" = "Notifications" ]; then
    exit 0
fi

# Create timestamp
TIMESTAMP=$(date "+%H:%M")

# Format the log entry
if [ -n "$BODY" ]; then
    LOG_ENTRY="[$TIMESTAMP] $APPNAME: $SUMMARY - $BODY"
else
    LOG_ENTRY="[$TIMESTAMP] $APPNAME: $SUMMARY"
fi

# Truncate to reasonable length
LOG_ENTRY=$(echo "$LOG_ENTRY" | cut -c1-150)

# Append to log file
echo "$LOG_ENTRY" >> "$LOG_FILE"

# Keep only last MAX_ENTRIES lines
tail -n "$MAX_ENTRIES" "$LOG_FILE" > "$LOG_FILE.tmp"
mv "$LOG_FILE.tmp" "$LOG_FILE"
