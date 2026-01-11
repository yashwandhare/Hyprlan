#!/usr/bin/env bash
LOCK_FILE="$HOME/.cache/battery-notify.lock"
exec 9>"$LOCK_FILE"
flock -n 9 || exit 0

LAST_NOTIFY_FILE="$HOME/.cache/battery-last-notify"
FULL_NOTIFIED=false

BAT_PATH=$(find /sys/class/power_supply -maxdepth 1 -name "BAT*" | head -n1)
[ -z "$BAT_PATH" ] && exit 1

while sleep 30; do
    CAP=$(cat "$BAT_PATH/capacity" 2>/dev/null)
    STATUS=$(cat "$BAT_PATH/status" 2>/dev/null)
    
    if [ "$STATUS" = "Not charging" ] && [ "$CAP" -ge 80 ] && [ "$FULL_NOTIFIED" = false ]; then
        notify-send "Battery" "Charge limit reached ($CAP%)" -u low -i battery-full-charged
        FULL_NOTIFIED=true
    elif [ "$STATUS" = "Discharging" ]; then
        FULL_NOTIFIED=false
        
        NOW=$(date +%s)
        LAST_NOTIFY=$(cat "$LAST_NOTIFY_FILE" 2>/dev/null || echo 0)
        DIFF=$((NOW - LAST_NOTIFY))
        
        if [ "$CAP" -le 10 ] && [ "$DIFF" -gt 120 ]; then
            notify-send "⚠️ Battery Critical" "Only $CAP% remaining!\nPlug in charger immediately." \
                -u critical -i battery-level-10-symbolic -h string:x-dunst-stack-tag:battery-critical
            echo "$NOW" > "$LAST_NOTIFY_FILE"
        elif [ "$CAP" -le 20 ] && [ "$DIFF" -gt 600 ]; then
            notify-send "Battery Low" "$CAP% remaining" \
                -u critical -i battery-level-20-symbolic -h string:x-dunst-stack-tag:battery-warning
            echo "$NOW" > "$LAST_NOTIFY_FILE"
        fi
    else
        [ -f "$LAST_NOTIFY_FILE" ] && rm "$LAST_NOTIFY_FILE"
    fi
done