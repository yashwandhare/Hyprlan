#!/usr/bin/env bash

VOL_RAW=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null) || exit 1
VOL=$(echo "$VOL_RAW" | awk '{print int($2 * 100)}')
[[ "$VOL" =~ ^[0-9]+$ ]] || VOL=0
MUTED=$(echo "$VOL_RAW" | grep -q MUTED && echo yes || echo no)

if [ "$MUTED" = "yes" ]; then
    notify-send \
      -t 1000 \
      -u normal \
      -h string:x-dunst-stack-tag:volume \
      -h int:value:0 \
      "Volume" "Muted"
else
    notify-send \
      -t 1000 \
      -u normal \
      -h string:x-dunst-stack-tag:volume \
      -h int:value:"$VOL" \
      "Volume" "${VOL}%"
fi
