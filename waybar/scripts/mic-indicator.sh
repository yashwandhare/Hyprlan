#!/bin/bash

# Check for active microphone access
if pactl list sources | grep -q "State: RUNNING" 2>/dev/null; then
    echo "󰍬 MIC"
else
    echo ""
fi
