#!/usr/bin/env bash
CACHE_DIR="$HOME/.cache"
DND_FILE="$CACHE_DIR/dnd-state"
CAFFEINE_FILE="$CACHE_DIR/caffeine-state"
FOCUS_FILE="$CACHE_DIR/focus-mode-state"
PID_FILE="$CACHE_DIR/caffeine-inhibit.pid"

SCRIPTS_DIR="$HOME/.config/hyprland/hypr/scripts"

enable_focus() {
    touch "$FOCUS_FILE"

    if [ ! -f "$DND_FILE" ]; then
        touch "$DND_FILE"
        dunstctl set-paused true
    fi

    if ! systemctl --user is-active --quiet caffeine-inhibit.service; then
        systemctl --user start caffeine-inhibit.service
        systemctl --user stop hypridle.service 2>/dev/null
        pkill -RTMIN+8 waybar 2>/dev/null
    fi

    notify-send "Focus Mode" "Enabled (DND + Caffeine)" -u low -i dialog-information
    pkill -RTMIN+9 waybar 2>/dev/null
}

disable_focus() {
    rm -f "$FOCUS_FILE"

    if [ -f "$DND_FILE" ]; then
        rm -f "$DND_FILE"
        dunstctl set-paused false
    fi

    if systemctl --user is-active --quiet caffeine-inhibit.service; then
        systemctl --user stop caffeine-inhibit.service
        systemctl --user start hypridle.service 2>/dev/null
        pkill -RTMIN+8 waybar 2>/dev/null
    fi

    notify-send "Focus Mode" "Disabled" -u low -i dialog-information
    pkill -RTMIN+9 waybar 2>/dev/null
}

if [ -f "$FOCUS_FILE" ]; then
    disable_focus
else
    enable_focus
fi