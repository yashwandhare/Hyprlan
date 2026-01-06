#!/usr/bin/env bash

# -----------------------------------------------------
# DND Status (JSON)
# -----------------------------------------------------

DND_FILE="$HOME/.cache/dnd-state"

if [ -f "$DND_FILE" ]; then
    # DND Active (Bell Crossed Out)
    echo '{"text": "󰂛", "tooltip": "Do Not Disturb: On", "class": "dnd"}'
else
    # DND Inactive (Bell) - Optional: return empty "" to hide when off
    echo '{"text": "󰂚", "tooltip": "Do Not Disturb: Off", "class": "active"}'
fi