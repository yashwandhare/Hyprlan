#!/usr/bin/env bash
VOL_RAW=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null) || exit 1
VOL=$(echo "$VOL_RAW" | awk '{print int($2 * 100)}')
MUTED=$(echo "$VOL_RAW" | grep -q MUTED && echo "yes" || echo "no")

[ "$MUTED" = "yes" ] && {
    ICON="audio-volume-muted"
    TEXT="Muted"
} || {
    TEXT="${VOL}%"
    [ "$VOL" -lt 30 ] && ICON="audio-volume-low"
    [ "$VOL" -ge 30 ] && [ "$VOL" -lt 70 ] && ICON="audio-volume-medium"
    [ "$VOL" -ge 70 ] && ICON="audio-volume-high"
}

notify-send -t 1000 -u low -i "$ICON" -h string:x-dunst-stack-tag:volume -h int:value:"$VOL" "Volume" "$TEXT"