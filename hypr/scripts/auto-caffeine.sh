#!/usr/bin/env bash

# -----------------------------------------------------
# Auto-Caffeine (Media & Fullscreen Detection)
# Starts inhibit daemon when enabling, kills it when disabling
# -----------------------------------------------------

STATE_FILE="$HOME/.cache/caffeine-state"
AUTO_STATE_FILE="$HOME/.cache/caffeine-auto-state"
FOCUS_FILE="$HOME/.cache/focus-mode-state"
PID_FILE="$HOME/.cache/caffeine-inhibit.pid"
SCRIPTS_DIR="$HOME/.config/hyprland/hypr/scripts"
CHECK_INTERVAL=5

# Ensure we don't start multiple instances
for pid in $(pidof -x "auto-caffeine.sh"); do
    if [ $pid != $$ ]; then
        exit 1
    fi
done

enable_caffeine() {
    # Don't enable if Focus Mode is already handling it
    if [ ! -f "$STATE_FILE" ] && [ ! -f "$FOCUS_FILE" ]; then
        touch "$STATE_FILE"
        touch "$AUTO_STATE_FILE"
        systemctl --user stop hypridle.service 2>/dev/null
        
        # Start inhibit daemon
        "$SCRIPTS_DIR/caffeine-inhibit-daemon.sh" &
        disown
        
        notify-send "Caffeine" "Auto-enabled (Media/Fullscreen)" -u low -t 2000
        pkill -RTMIN+8 waybar 2>/dev/null
    fi
}

disable_caffeine() {
    # Only disable if WE enabled it (and Focus Mode isn't active)
    if [ -f "$AUTO_STATE_FILE" ] && [ -f "$STATE_FILE" ] && [ ! -f "$FOCUS_FILE" ]; then
        # Kill inhibit daemon if it's running
        if [ -f "$PID_FILE" ]; then
            INHIBIT_PID=$(cat "$PID_FILE")
            kill "$INHIBIT_PID" 2>/dev/null
            rm -f "$PID_FILE"
        fi
        
        rm -f "$STATE_FILE"
        rm -f "$AUTO_STATE_FILE"
        systemctl --user start hypridle.service 2>/dev/null
        notify-send "Caffeine" "Auto-disabled" -u low -t 2000
        pkill -RTMIN+8 waybar 2>/dev/null
    fi
}

check_status() {
    # 1. Check Media (Playing)
    if playerctl status 2>/dev/null | grep -q "Playing"; then
        return 0
    fi
    
    # 2. Check Fullscreen (Only active window, vastly cheaper than checking all clients)
    # Returns 0 (success) if fullscreen: 1 (active) or 2 (global)
    if hyprctl activewindow -j | grep -q '"fullscreen": [12]'; then
        return 0
    fi
    
    return 1
}

while true; do
    if check_status; then
        enable_caffeine
    else
        disable_caffeine
    fi
    sleep "$CHECK_INTERVAL"
done