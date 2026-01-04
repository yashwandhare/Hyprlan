#!/usr/bin/env bash

# Disable caffeine when locking, logging out, or shutting down

STATE_FILE="$HOME/.cache/caffeine-state"
AUTO_STATE_FILE="$HOME/.cache/caffeine-auto-state"

if [ -f "$STATE_FILE" ]; then
    rm "$STATE_FILE"
fi

if [ -f "$AUTO_STATE_FILE" ]; then
    rm "$AUTO_STATE_FILE"
fi

pkill -SIGUSR1 hypridle 2>/dev/null
systemctl --user start hypridle.service 2>/dev/null
pkill -RTMIN+8 waybar 2>/dev/null
