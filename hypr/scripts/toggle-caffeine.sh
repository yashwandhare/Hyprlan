#!/usr/bin/env bash

STATE_FILE="$HOME/.cache/caffeine-state"

if [ -f "$STATE_FILE" ]; then
    # Caffeine is on, turn it off
    rm "$STATE_FILE"
    systemctl --user kill -s SIGUSR1 hypridle.service 2>/dev/null
    systemctl --user start hypridle.service 2>/dev/null
    notify-send "Caffeine" "Caffeine Disabled" -u normal
    
    # Verify it actually stopped
    if systemctl --user is-active --quiet hypridle.service; then
        : # Success, do nothing
    else
        notify-send "Caffeine Error" "Failed to re-enable idle" -u critical
    fi
else
    # Caffeine is off, turn it on
    touch "$STATE_FILE"
    systemctl --user kill -s SIGUSR2 hypridle.service 2>/dev/null
    systemctl --user stop hypridle.service 2>/dev/null
    notify-send "Caffeine" "Caffeine Enabled" -u normal
    
    # Verify it actually stopped
    if ! systemctl --user is-active --quiet hypridle.service; then
        : # Success, do nothing
    else
        notify-send "Caffeine Error" "Failed to disable idle" -u critical
    fi
fi

# Refresh waybar
pkill -RTMIN+8 waybar 2>/dev/null
