#!/usr/bin/env bash
ACTION="$1"

DEVICE=$(find /sys/class/leds -name "*::kbd_backlight" -o -name "*kbd_backlight*" | head -n1)
[ -z "$DEVICE" ] && exit 0

get_percent() {
    local cur=$(brightnessctl --device='*::kbd_backlight' get)
    local max=$(brightnessctl --device='*::kbd_backlight' max)
    echo $((cur * 100 / max))
}

if [ -n "$ACTION" ]; then
    CURRENT=$(get_percent)
    case "$ACTION" in
        up) brightnessctl --device='*::kbd_backlight' set +33% ;;
        down) brightnessctl --device='*::kbd_backlight' set 33%- ;;
        cycle)
            if [ "$CURRENT" -ge 95 ]; then
                brightnessctl --device='*::kbd_backlight' set 0
            elif [ "$CURRENT" -ge 45 ]; then
                brightnessctl --device='*::kbd_backlight' set 100%
            else
                brightnessctl --device='*::kbd_backlight' set 50%
            fi
            ;;
    esac
fi

NEW_PERCENT=$(get_percent)
notify-send "Keyboard" "${NEW_PERCENT}%" -t 800 -u low -i keyboard-brightness-symbolic \
    -h string:x-dunst-stack-tag:kbd_backlight -h int:value:"$NEW_PERCENT"