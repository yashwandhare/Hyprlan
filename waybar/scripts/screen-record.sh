#!/usr/bin/env bash

# Check for screen recording processes
if pgrep -f "gpu-screen-recorder|obs|ffmpeg|wf-recorder|screenkey" > /dev/null 2>&1; then
    echo "󰻃 REC"
else
    echo ""
fi
