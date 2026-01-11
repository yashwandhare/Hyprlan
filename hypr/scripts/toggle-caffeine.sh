#!/usr/bin/env bash

# -----------------------------------------------------
# Toggle Caffeine Mode (Manual)
# Blocks: Lock, Sleep, Suspend, Lid-Close, Power Key
# Unless manually triggered (then caffeine auto-disables)
# -----------------------------------------------------

CACHE_DIR="$HOME/.cache"
STATE_FILE="$CACHE_DIR/caffeine-state"
PID_FILE="$CACHE_DIR/caffeine-inhibit.pid"
SCRIPTS_DIR="$HOME/.config/hyprland/hypr/scripts"

if [ -f "$STATE_FILE" ]; then
    # -------------------------------------------------
    # TURN OFF
    # -------------------------------------------------
    
    # Kill inhibit daemon if it's running
    if [ -f "$PID_FILE" ]; then
        INHIBIT_PID=$(cat "$PID_FILE")
        kill "$INHIBIT_PID" 2>/dev/null
        rm -f "$PID_FILE"
    fi
    
    rm -f "$STATE_FILE"
    
    # Restart idle daemon (allows normal lock/sleep/suspend)
    systemctl --user start hypridle.service 2>/dev/null
    
    # Icon: Sleep/Suspend symbol
    notify-send "Caffeine" "Disabled" -u low -i system-suspend
else
    # -------------------------------------------------
    # TURN ON
    # -------------------------------------------------
    touch "$STATE_FILE"
    
    # Stop idle daemon (prevents idle lock/DPMS)
    systemctl --user stop hypridle.service 2>/dev/null
    
    # Start inhibit daemon in background
    # Blocks sleep, suspend, lid-close, power-key
    "$SCRIPTS_DIR/caffeine-inhibit-daemon.sh" &
    disown
    
    # Icon: Display brightness/Video symbol (Always On)
    notify-send "Caffeine" "Enabled (Blocks Sleep/Lock/Suspend)" -u low -i video-display
fi

# Refresh Waybar Indicator
pkill -RTMIN+8 waybar 2>/dev/null