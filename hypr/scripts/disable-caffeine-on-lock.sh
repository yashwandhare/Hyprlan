#!/usr/bin/env bash

# -----------------------------------------------------
# Cleanup Script: Run on Lock/Logout
# Disables caffeine and inhibits if running
# Called by hypridle before sleep or when lock is triggered
# Also called from hyprland when lid-close or manual lock
# -----------------------------------------------------

CACHE_DIR="$HOME/.cache"
FILES=(
    "$CACHE_DIR/caffeine-state"
    "$CACHE_DIR/caffeine-auto-state"
    "$CACHE_DIR/focus-mode-state"
)
PID_FILE="$CACHE_DIR/caffeine-inhibit.pid"

# 1. Kill inhibit daemon if running
if [ -f "$PID_FILE" ]; then
    INHIBIT_PID=$(cat "$PID_FILE")
    kill "$INHIBIT_PID" 2>/dev/null
    rm -f "$PID_FILE"
fi

# 2. Remove all state flags
for file in "${FILES[@]}"; do
    if [ -f "$file" ]; then
        rm -f "$file"
    fi
done

# 3. Force Idle Daemon ON
# (Ensure screen can turn off physically after locking)
systemctl --user start hypridle.service 2>/dev/null

# 4. Refresh Waybar (Reset indicators)
pkill -RTMIN+8 waybar 2>/dev/null # Caffeine
pkill -RTMIN+9 waybar 2>/dev/null # Focus Mode