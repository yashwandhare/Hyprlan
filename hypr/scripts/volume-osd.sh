#!/usr/bin/env bash

# -----------------------------------------------------
# Volume OSD with Dynamic Icons
# -----------------------------------------------------

# Get Volume & Mute Status
VOL_RAW=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null) || exit 1
VOL=$(echo "$VOL_RAW" | awk '{print int($2 * 100)}')
MUTED=$(echo "$VOL_RAW" | grep -q MUTED && echo "yes" || echo "no")

# Determine Icon
if [ "$MUTED" = "yes" ]; then
    ICON="audio-volume-muted"
    TEXT="Muted"
else
    TEXT="${VOL}%"
    if [ "$VOL" -lt 30 ]; then
        ICON="audio-volume-low"
    elif [ "$VOL" -lt 70 ]; then
        ICON="audio-volume-medium"
    else
        ICON="audio-volume-high"
    fi
fi

# Send Notification
notify-send \
  -t 1000 \
  -u low \
  -i "$ICON" \
  -h string:x-dunst-stack-tag:volume \
  -h int:value:"$VOL" \
  "Volume" "$TEXT"