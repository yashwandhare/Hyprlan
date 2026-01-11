#!/usr/bin/env bash
STATE_FILE="$HOME/.cache/caffeine-state"
AUTO_STATE_FILE="$HOME/.cache/caffeine-auto-state"
FOCUS_FILE="$HOME/.cache/focus-mode-state"
PID_FILE="$HOME/.cache/caffeine-inhibit.pid"
SCRIPTS_DIR="$HOME/.config/hyprland/hypr/scripts"
CHECK_INTERVAL=5

LOCK_FILE="$HOME/.cache/auto-caffeine.lock"
exec 9>"$LOCK_FILE"
flock -n 9 || exit 0

enable_caffeine() {
    [ ! -f "$STATE_FILE" ] && [ ! -f "$FOCUS_FILE" ] && {
        touch "$STATE_FILE" "$AUTO_STATE_FILE"
        systemctl --user stop hypridle.service 2>/dev/null
        "$SCRIPTS_DIR/caffeine-inhibit-daemon.sh" & disown
        notify-send "Caffeine" "Auto-enabled (Media/Fullscreen)" -u low -t 2000
        pkill -RTMIN+8 waybar 2>/dev/null
    }
}

disable_caffeine() {
    [ -f "$AUTO_STATE_FILE" ] && [ -f "$STATE_FILE" ] && [ ! -f "$FOCUS_FILE" ] && {
        [ -f "$PID_FILE" ] && kill "$(cat "$PID_FILE")" 2>/dev/null && rm -f "$PID_FILE"
        rm -f "$STATE_FILE" "$AUTO_STATE_FILE"
        systemctl --user start hypridle.service 2>/dev/null
        notify-send "Caffeine" "Auto-disabled" -u low -t 2000
        pkill -RTMIN+8 waybar 2>/dev/null
    }
}

check_status() {
    playerctl status 2>/dev/null | grep -q "Playing" && return 0
    hyprctl activewindow -j 2>/dev/null | grep -q '"fullscreen": [12]' && return 0
    return 1
}

while true; do
    check_status && enable_caffeine || disable_caffeine
    sleep "$CHECK_INTERVAL"
done