#!/usr/bin/env bash

# Auto-enable caffeine when media is playing or fullscreen apps are detected
# Auto-disable when conditions are no longer met

STATE_FILE="$HOME/.cache/caffeine-state"
AUTO_STATE_FILE="$HOME/.cache/caffeine-auto-state"
CHECK_INTERVAL=5

enable_caffeine() {
    if [ ! -f "$STATE_FILE" ]; then
        touch "$STATE_FILE"
        touch "$AUTO_STATE_FILE"
        systemctl --user kill -s SIGUSR2 hypridle.service 2>/dev/null
        systemctl --user stop hypridle.service 2>/dev/null
        notify-send "Caffeine" "Auto-enabled" -u low
        pkill -RTMIN+8 waybar 2>/dev/null
    fi
}

disable_caffeine() {
    # Only disable if it was auto-enabled
    if [ -f "$AUTO_STATE_FILE" ] && [ -f "$STATE_FILE" ]; then
        rm "$STATE_FILE"
        rm "$AUTO_STATE_FILE"
        systemctl --user kill -s SIGUSR1 hypridle.service 2>/dev/null
        systemctl --user start hypridle.service 2>/dev/null
        notify-send "Caffeine" "Auto-disabled" -u low
        pkill -RTMIN+8 waybar 2>/dev/null
    fi
}

check_media() {
    # Check if any media player is playing
    playerctl status 2>/dev/null | grep -q "Playing"
}

check_fullscreen() {
    # Check if any window is fullscreen
    hyprctl clients -j 2>/dev/null | grep -q '"fullscreen":true'
}

while true; do
    if check_media || check_fullscreen; then
        enable_caffeine
    else
        disable_caffeine
    fi
    
    sleep "$CHECK_INTERVAL"
done
