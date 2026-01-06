#!/usr/bin/env bash

DND_FILE="$HOME/.cache/dnd-state"

if [ -f "$DND_FILE" ]; then
    echo '{"text": "󰂛", "class": "dnd"}'
else
    echo '{"text": "󰂚", "class": "normal"}'
fi

