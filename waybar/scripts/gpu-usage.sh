#!/usr/bin/env bash

THRESHOLD=5

# Exit silently if NVIDIA tools are not available
command -v nvidia-smi &>/dev/null || exit 0

UTIL=$(nvidia-smi \
  --query-gpu=utilization.gpu \
  --format=csv,noheader,nounits 2>/dev/null)

# Validate UTIL is numeric
if ! [[ "$UTIL" =~ ^[0-9]+$ ]]; then
    UTIL=0
fi

if (( UTIL > THRESHOLD )); then
    echo "󰢮 ${UTIL}%"
else
    echo ""
fi
