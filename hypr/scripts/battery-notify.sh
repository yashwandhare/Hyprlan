#!/usr/bin/env bash

LOCK="$HOME/.cache/battery-notify.lock"

exec 9>"$LOCK" || exit 0
flock -n 9 || exit 0

while sleep 60; do
    # Find first battery device more efficiently
    BAT=$(find /sys/class/power_supply -maxdepth 1 -name "BAT*" -type d 2>/dev/null | head -n1 | xargs -r basename)
    [ -z "$BAT" ] && continue
    [ -f "/sys/class/power_supply/$BAT/capacity" ] || continue
    [ -f "/sys/class/power_supply/$BAT/status" ] || continue
    
    CAP=$(cat "/sys/class/power_supply/$BAT/capacity")
    STAT=$(cat "/sys/class/power_supply/$BAT/status")

    if [ "$CAP" -ge 80 ] && [ "$STAT" = "Not charging" ]; then
        notify-send \
            -h string:x-dunst-stack-tag:battery \
            -u normal \
            "Battery" "Charge limit reached (${CAP}%)"
        sleep 600
    fi
done
