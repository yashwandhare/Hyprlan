#!/usr/bin/env bash

# Check dependencies
if ! command -v cliphist &>/dev/null; then
    notify-send "Error" "cliphist not installed"
    exit 1
fi

cliphist list | wofi --show dmenu --prompt "Clipboard" --width=600 --height=400 | cliphist decode | wl-copy