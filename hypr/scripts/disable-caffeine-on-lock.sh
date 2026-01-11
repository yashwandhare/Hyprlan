#!/usr/bin/env bash
CACHE_DIR="$HOME/.cache"
FILES=(
    "$CACHE_DIR/caffeine-state"
    "$CACHE_DIR/caffeine-auto-state"
    "$CACHE_DIR/focus-mode-state"
)
PID_FILE="$CACHE_DIR/caffeine-inhibit.pid"

[ -f "$PID_FILE" ] && kill "$(cat "$PID_FILE")" 2>/dev/null && rm -f "$PID_FILE"
for file in "${FILES[@]}"; do
    [ -f "$file" ] && rm -f "$file"
done
systemctl --user start hypridle.service 2>/dev/null
pkill -RTMIN+8 waybar 2>/dev/null
pkill -RTMIN+9 waybar 2>/dev/null