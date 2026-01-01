#!/usr/bin/env bash

LOCK="$HOME/.cache/battery-notify.lock"

exec 9>"$LOCK" || exit 0
flock -n 9 || exit 0

while sleep 60; do
    BAT=$(ls /sys/class/power_supply | grep BAT | head -n1) || continue
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
