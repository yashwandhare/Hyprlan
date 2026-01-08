#!/usr/bin/env bash

LOG_FILE="$HOME/.cache/notification_log.txt"
MAX_LINES=100

# Prefer CLI args; fall back to dunst env vars if missing
APP="${1:-${DUNST_APP_NAME}}"
SUMMARY="${2:-${DUNST_SUMMARY}}"
BODY="${3:-${DUNST_BODY}}"

# Ensure cache dir exists
mkdir -p "$HOME/.cache"
touch "$LOG_FILE"

# Ignore volume/brightness/system popups
if [[ "$APP" == "Volume" ]] || [[ "$APP" == "Brightness" ]] || [[ "$APP" == "System" ]]; then
    exit 0
fi

TIMESTAMP=$(date +"%H:%M")
ENTRY="[$TIMESTAMP] $APP: $SUMMARY"

if [ -n "$BODY" ]; then
    ENTRY="$ENTRY - $BODY"
fi

# Append and trim log
echo "$ENTRY" >> "$LOG_FILE"
if [ $(wc -l < "$LOG_FILE") -gt $MAX_LINES ]; then
    tail -n $MAX_LINES "$LOG_FILE" > "$LOG_FILE.tmp" && mv "$LOG_FILE.tmp" "$LOG_FILE"
fi