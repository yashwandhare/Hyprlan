#!/usr/bin/env bash
LOCK_FILE="$HOME/.cache/battery-notify.lock"
exec 9>"$LOCK_FILE"
flock -n 9 || exit 0


# State file to track if 'Battery Full' notification was sent
BAT_FULL_STATE_FILE="$HOME/.cache/battery-full-notified"
LAST_NOTIFY_FILE="$HOME/.cache/battery-last-notify"

BAT_PATH=$(find /sys/class/power_supply -maxdepth 1 -name "BAT*" | head -n1)
[ -z "$BAT_PATH" ] && exit 1

CAP=$(cat "$BAT_PATH/capacity" 2>/dev/null)
STATUS=$(cat "$BAT_PATH/status" 2>/dev/null)

if [ "$STATUS" = "Not charging" ] && [ "$CAP" -ge 80 ]; then
    # Only send notification if not already sent in this charge cycle
    if [ ! -f "$BAT_FULL_STATE_FILE" ]; then
        notify-send "Battery" "Charge limit reached ($CAP%)" -u low -i battery-full-charged
        touch "$BAT_FULL_STATE_FILE"
    fi
elif [ "$STATUS" = "Discharging" ]; then
    # Reset full notification state if battery drops below 90%
    if [ "$CAP" -lt 90 ]; then
        [ -f "$BAT_FULL_STATE_FILE" ] && rm "$BAT_FULL_STATE_FILE"
    fi

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
    # Also reset full notification state if battery drops below 90% in other states
    if [ "$CAP" -lt 90 ]; then
        [ -f "$BAT_FULL_STATE_FILE" ] && rm "$BAT_FULL_STATE_FILE"
    fi
fi

# State file logic: BAT_FULL_STATE_FILE is created when 'Battery Full' notification is sent, and removed when battery drops below 90%.