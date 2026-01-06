#!/usr/bin/env bash

# Define empty JSON for when hidden
EMPTY='{"text": "", "tooltip": "", "class": ""}'

# 1. Check if nvidia-smi exists
if ! command -v nvidia-smi &>/dev/null; then
    echo "$EMPTY"
    exit 0
fi

# 2. Get GPU Utilization (0-100)
UTIL=$(nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits 2>/dev/null)

# 3. Check if UTIL is a valid number
if [[ ! "$UTIL" =~ ^[0-9]+$ ]]; then
    echo "$EMPTY"
    exit 0
fi

# 4. Logic: Show only if usage > 0
if [ "$UTIL" -gt 0 ]; then
    # Get Name for Tooltip (clean newlines)
    NAME=$(nvidia-smi --query-gpu=name --format=csv,noheader 2>/dev/null | tr -d '\n')
    
    # Output Valid JSON with GPU Icon (󰢮)
    printf '{"text": "󰢮 %s%%", "tooltip": "GPU: %s (%s%%)", "class": "active"}\n' "$UTIL" "$NAME" "$UTIL"
else
    echo "$EMPTY"
fi