#!/usr/bin/env bash

# -----------------------------------------------------
# Toggle Caffeine Mode (Manual)
# -----------------------------------------------------

CACHE_DIR="$HOME/.cache"
STATE_FILE="$CACHE_DIR/caffeine-state"

if [ -f "$STATE_FILE" ]; then
    # -------------------------------------------------
    # TURN OFF
    # -------------------------------------------------
    rm -f "$STATE_FILE"
    
    # Restart idle daemon
    systemctl --user start hypridle.service 2>/dev/null
    
    # Icon: Sleep/Suspend symbol (Standard)
    notify-send "Caffeine" "Disabled" -u low -i system-suspend
else
    # -------------------------------------------------
    # TURN ON
    # -------------------------------------------------
    touch "$STATE_FILE"
    
    # Stop idle daemon
    systemctl --user stop hypridle.service 2>/dev/null
    
    # Icon: Display brightness/Video symbol (Standard for 'Always On')
    notify-send "Caffeine" "Enabled" -u low -i video-display
fi

# Refresh Waybar Indicator
pkill -RTMIN+8 waybar 2>/dev/null