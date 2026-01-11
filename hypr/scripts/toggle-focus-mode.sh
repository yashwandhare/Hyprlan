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
    
    if [ ! -f "$CAFFEINE_FILE" ]; then
        touch "$CAFFEINE_FILE"
        systemctl --user stop hypridle.service 2>/dev/null
        "$SCRIPTS_DIR/caffeine-inhibit-daemon.sh" & disown
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
    
    if [ -f "$CAFFEINE_FILE" ]; then
        [ -f "$PID_FILE" ] && kill "$(cat "$PID_FILE")" 2>/dev/null && rm -f "$PID_FILE"
        rm -f "$CAFFEINE_FILE"
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