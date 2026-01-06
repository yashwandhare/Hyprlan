#!/usr/bin/env bash

# -----------------------------------------------------
# Cleanup Script: Run on Lock/Logout
# -----------------------------------------------------

CACHE_DIR="$HOME/.cache"
FILES=(
    "$CACHE_DIR/caffeine-state"
    "$CACHE_DIR/caffeine-auto-state"
    "$CACHE_DIR/focus-mode-state"
)

# 1. Remove all state flags
for file in "${FILES[@]}"; do
    if [ -f "$file" ]; then
        rm -f "$file"
    fi
done

# 2. Force Idle Daemon ON
# (Ensure screen can turn off physically after locking)
systemctl --user start hypridle.service 2>/dev/null

# 3. Refresh Waybar (Reset indicators)
pkill -RTMIN+8 waybar 2>/dev/null # Caffeine
pkill -RTMIN+9 waybar 2>/dev/null # Focus Mode