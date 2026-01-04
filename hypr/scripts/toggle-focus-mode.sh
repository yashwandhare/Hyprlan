#!/usr/bin/env bash

# Focus Mode: Enable DND + Caffeine together

DND_FILE="$HOME/.cache/dnd-state"
CAFFEINE_FILE="$HOME/.cache/caffeine-state"
FOCUS_FILE="$HOME/.cache/focus-mode-state"

if [ -f "$FOCUS_FILE" ]; then
    # Focus mode is active, disable it
    rm -f "$FOCUS_FILE"
    
    # Disable DND
    if [ -f "$DND_FILE" ]; then
        rm -f "$DND_FILE"
        dunstctl set-paused false
    fi
    
    # Disable Caffeine (only if we enabled it)
    if [ -f "$CAFFEINE_FILE" ]; then
        rm -f "$CAFFEINE_FILE"
        pkill -SIGUSR1 hypridle 2>/dev/null
        systemctl --user start hypridle.service 2>/dev/null
        pkill -RTMIN+8 waybar 2>/dev/null
    fi
    
    notify-send "Focus Mode" "Disabled" -t 1500
    
    # Refresh waybar
    pkill -RTMIN+9 waybar 2>/dev/null
else
    # Focus mode is inactive, enable it
    touch "$FOCUS_FILE"
    
    # Enable DND
    if [ ! -f "$DND_FILE" ]; then
        touch "$DND_FILE"
        notify-send "Focus Mode" "Enabled - Do Not Disturb + Caffeine active" -t 2000
        sleep 0.3
        dunstctl set-paused true
    fi
    
    # Enable Caffeine
    if [ ! -f "$CAFFEINE_FILE" ]; then
        touch "$CAFFEINE_FILE"
        pkill -SIGUSR2 hypridle 2>/dev/null
        systemctl --user stop hypridle.service 2>/dev/null
        pkill -RTMIN+8 waybar 2>/dev/null
    fi
    
    # Refresh waybar
    pkill -RTMIN+9 waybar 2>/dev/null
fi
