#!/usr/bin/env bash

LOCK="$HOME/.cache/battery-notify.lock"
LAST_NOTIFY="$HOME/.cache/battery-last-notify"

exec 9>"$LOCK" || exit 0
flock -n 9 || exit 0

while sleep 30; do
    # Find first battery device more efficiently
    BAT=$(find /sys/class/power_supply -maxdepth 1 -name "BAT*" -type d 2>/dev/null | head -n1 | xargs -r basename)
    [ -z "$BAT" ] && continue
    [ -f "/sys/class/power_supply/$BAT/capacity" ] || continue
    [ -f "/sys/class/power_supply/$BAT/status" ] || continue
    
    CAP=$(cat "/sys/class/power_supply/$BAT/capacity")
    STAT=$(cat "/sys/class/power_supply/$BAT/status")

    # Charge limit notification
    if [ "$CAP" -ge 80 ] && [ "$STAT" = "Not charging" ]; then
        notify-send \
            -h string:x-dunst-stack-tag:battery \
            -u normal \
            "Battery" "Charge limit reached (${CAP}%)"
        sleep 600
        continue
    fi
    
    # Critical battery notifications (bypass DND)
    if [ "$STAT" = "Discharging" ]; then
        CURRENT_TIME=$(date +%s)
        LAST_TIME=$(cat "$LAST_NOTIFY" 2>/dev/null || echo 0)
        TIME_DIFF=$((CURRENT_TIME - LAST_TIME))
        
        # Critical: 10% (every 2 min)
        if [ "$CAP" -le 10 ] && [ "$TIME_DIFF" -gt 120 ]; then
            notify-send \
                -u critical \
                -h string:x-dunst-stack-tag:battery-critical \
                -h int:transient:0 \
                "⚠️ Battery Critical" \
                "Only ${CAP}% remaining!\nPlug in charger immediately."
            echo "$CURRENT_TIME" > "$LAST_NOTIFY"
        # Warning: 20% (once)
        elif [ "$CAP" -le 20 ] && [ "$TIME_DIFF" -gt 600 ]; then
            notify-send \
                -u critical \
                -h string:x-dunst-stack-tag:battery-warning \
                "Battery Low" \
                "${CAP}% remaining\nConsider plugging in charger."
            echo "$CURRENT_TIME" > "$LAST_NOTIFY"
        fi
    else
        # Reset notification timer when charging
        rm -f "$LAST_NOTIFY"
    fi
done
