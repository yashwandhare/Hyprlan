#!/usr/bin/env bash

STATE_FILE="$HOME/.cache/caffeine-state"

if [ -f "$STATE_FILE" ]; then
    # Caffeine is on, turn it off
    rm "$STATE_FILE"
    pkill -SIGUSR1 hypridle 2>/dev/null
    systemctl --user start hypridle.service 2>/dev/null
    notify-send "Caffeine" "Caffeine Disabled" -u normal
else
    # Caffeine is off, turn it on
    touch "$STATE_FILE"
    pkill -SIGUSR2 hypridle 2>/dev/null
    systemctl --user stop hypridle.service 2>/dev/null
    notify-send "Caffeine" "Caffeine Enabled" -u normal
fi

# Refresh waybar
pkill -RTMIN+8 waybar 2>/dev/null
