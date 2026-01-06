#!/usr/bin/env bash

DND_FILE="$HOME/.cache/dnd-state"
COUNT=$(dunstctl count waiting 2>/dev/null || echo 0)

if [ -f "$DND_FILE" ]; then
    echo "{\"text\": \"󰂛\", \"tooltip\": \"Do Not Disturb: On\", \"class\": \"dnd\"}"
else
    if [ "$COUNT" -gt 0 ]; then
        echo "{\"text\": \"󰂚 $COUNT\", \"tooltip\": \"$COUNT Notifications waiting\", \"class\": \"active\"}"
    else
        echo "{\"text\": \"󰂚\", \"tooltip\": \"Notifications\", \"class\": \"normal\"}"
    fi
fi