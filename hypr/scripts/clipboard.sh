#!/usr/bin/env bash
ROFI_THEME="$HOME/.config/hyprland/hypr/rofi/launcher.rasi"
command -v cliphist >/dev/null 2>&1 || { notify-send "Error" "cliphist not installed"; exit 1; }
command -v rofi >/dev/null 2>&1 || { notify-send "Error" "rofi not installed"; exit 1; }

HISTORY=$(cliphist list 2>/dev/null)
MENU="🗑️  Clear All\n────────────────\n$HISTORY"
SELECTED=$(echo -e "$MENU" | rofi -dmenu -p "Clipboard" -theme "$ROFI_THEME" 2>/dev/null)

case "$SELECTED" in
    ""|"────────────────") exit 0 ;;
    "🗑️  Clear All") cliphist wipe && notify-send "Clipboard" "History cleared" -u low ;;
    *) echo "$SELECTED" | cliphist decode | wl-copy ;;
esac