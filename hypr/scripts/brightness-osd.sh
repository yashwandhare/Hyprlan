#!/usr/bin/env bash
BRIGHT=$(brightnessctl get 2>/dev/null) || exit 1
MAX=$(brightnessctl max 2>/dev/null) || exit 1
[ "$MAX" -eq 0 ] && exit 1
PERCENT=$((BRIGHT * 100 / MAX))
notify-send -t 1000 -u low -h string:x-dunst-stack-tag:brightness -h int:value:"$PERCENT" "Brightness" "${PERCENT}%"