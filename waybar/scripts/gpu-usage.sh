#!/usr/bin/env bash

THRESHOLD=5

# Exit silently if NVIDIA tools are not available
command -v nvidia-smi &>/dev/null || exit 0

UTIL=$(nvidia-smi \
  --query-gpu=utilization.gpu \
  --format=csv,noheader,nounits 2>/dev/null)

UTIL=${UTIL:-0}

if (( UTIL > THRESHOLD )); then
    echo "󰢮 ${UTIL}%"
else
    echo ""
fi
