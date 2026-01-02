#!/usr/bin/env bash

# Check for active microphone access using wpctl (consistent with other scripts)
if wpctl status 2>/dev/null | grep -q "capturing" || \
   pactl list sources 2>/dev/null | grep -q "State: RUNNING"; then
    echo "󰍬 MIC"
else
    echo ""
fi
