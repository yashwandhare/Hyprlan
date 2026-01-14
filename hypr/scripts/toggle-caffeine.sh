#!/usr/bin/env bash
if systemctl --user is-active --quiet caffeine-inhibit.service; then
    systemctl --user stop caffeine-inhibit.service
    systemctl --user start hypridle.service 2>/dev/null
    notify-send "Caffeine" "Disabled" -u low -i system-suspend
else
    systemctl --user start caffeine-inhibit.service
    systemctl --user stop hypridle.service 2>/dev/null
    notify-send "Caffeine" "Enabled (Blocks Sleep/Lock/Suspend)" -u low -i video-display
fi

pkill -RTMIN+8 waybar 2>/dev/null