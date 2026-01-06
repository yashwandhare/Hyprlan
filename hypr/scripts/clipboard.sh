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

# Launch Rofi
# -p "Clipboard" sets the prompt text
# -theme sets the config file
cliphist list | rofi -dmenu \
    -p "Clipboard" \
    -theme "$ROFI_THEME" \
    | cliphist decode | wl-copy