#!/usr/bin/env bash

# -----------------------------------------------------
# Clipboard Manager (Rofi)
# -----------------------------------------------------

ROFI_THEME="$HOME/.config/hypr/rofi/launcher.rasi"

# Check dependencies
if ! command -v cliphist &>/dev/null; then
    notify-send "Error" "cliphist not installed"
    exit 1
fi

if ! command -v rofi &>/dev/null; then
    notify-send "Error" "rofi not installed"
    exit 1
fi

# Build menu with a Clear option
HISTORY=$(cliphist list)
MENU="🗑️  Clear All\n────────────────\n$HISTORY"

# Show Rofi menu
SELECTED=$(echo -e "$MENU" | rofi -dmenu \
    -p "Clipboard" \
    -theme "$ROFI_THEME")

# Handle selection
case "$SELECTED" in
    "")
        exit 0
        ;;
    "🗑️  Clear All")
        cliphist wipe
        notify-send "Clipboard" "History cleared" -u low
        ;;
    *)
        echo "$SELECTED" | cliphist decode | wl-copy
        ;;
esac