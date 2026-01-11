#!/usr/bin/env bash
CACHE_DIR="$HOME/.cache"
STATE_FILE="$CACHE_DIR/caffeine-state"
PID_FILE="$CACHE_DIR/caffeine-inhibit.pid"
SCRIPTS_DIR="$HOME/.config/hyprland/hypr/scripts"

[ -f "$STATE_FILE" ] && {
    [ -f "$PID_FILE" ] && kill "$(cat "$PID_FILE")" 2>/dev/null && rm -f "$PID_FILE"
    rm -f "$STATE_FILE"
    systemctl --user start hypridle.service 2>/dev/null
    notify-send "Caffeine" "Disabled" -u low -i system-suspend
} || {
    touch "$STATE_FILE"
    systemctl --user stop hypridle.service 2>/dev/null
    "$SCRIPTS_DIR/caffeine-inhibit-daemon.sh" & disown
    notify-send "Caffeine" "Enabled (Blocks Sleep/Lock/Suspend)" -u low -i video-display
}

pkill -RTMIN+8 waybar 2>/dev/null