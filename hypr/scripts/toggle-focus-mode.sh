#!/usr/bin/env bash

# -----------------------------------------------------
# Focus Mode: DND + Caffeine (Deep Work)
# When enabled, also blocks sleep/suspend via systemd-inhibit
# When disabled, kills inhibit daemon
# -----------------------------------------------------

CACHE_DIR="$HOME/.cache"
DND_FILE="$CACHE_DIR/dnd-state"
CAFFEINE_FILE="$CACHE_DIR/caffeine-state"
FOCUS_FILE="$CACHE_DIR/focus-mode-state"
PID_FILE="$CACHE_DIR/caffeine-inhibit.pid"

SCRIPTS_DIR="$HOME/.config/hyprland/hypr/scripts"

enable_focus() {
    touch "$FOCUS_FILE"
    
    # 1. Enable DND
    if [ ! -f "$DND_FILE" ]; then
        touch "$DND_FILE"
        dunstctl set-paused true
    fi
    
    # 2. Enable Caffeine
    if [ ! -f "$CAFFEINE_FILE" ]; then
        touch "$CAFFEINE_FILE"
        systemctl --user stop hypridle.service 2>/dev/null
        
        # Start inhibit daemon (blocks sleep/suspend/lid)
        "$SCRIPTS_DIR/caffeine-inhibit-daemon.sh" &
        disown
        
        pkill -RTMIN+8 waybar 2>/dev/null
    fi
    
    # 3. Notify
    notify-send "Focus Mode" "Enabled (DND + Caffeine)" -u low -i dialog-information
    pkill -RTMIN+9 waybar 2>/dev/null
}

disable_focus() {
    rm -f "$FOCUS_FILE"
    
    # 1. Disable DND
    if [ -f "$DND_FILE" ]; then
        rm -f "$DND_FILE"
        dunstctl set-paused false
    fi
    
    # 2. Disable Caffeine
    if [ -f "$CAFFEINE_FILE" ]; then
        # Kill inhibit daemon if it's running
        if [ -f "$PID_FILE" ]; then
            INHIBIT_PID=$(cat "$PID_FILE")
            kill "$INHIBIT_PID" 2>/dev/null
            rm -f "$PID_FILE"
        fi
        
        rm -f "$CAFFEINE_FILE"
        systemctl --user start hypridle.service 2>/dev/null
        pkill -RTMIN+8 waybar 2>/dev/null
    fi
    
    # 3. Notify
    notify-send "Focus Mode" "Disabled" -u low -i dialog-information
    pkill -RTMIN+9 waybar 2>/dev/null
}

if [ -f "$FOCUS_FILE" ]; then
    disable_focus
else
    enable_focus
fi