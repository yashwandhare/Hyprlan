#!/usr/bin/env bash

# -----------------------------------------------------
# Auto-pause media when screen locks
# -----------------------------------------------------

# Check if socat is installed
if ! command -v socat &> /dev/null; then
    notify-send "Error" "socat not found. Media pause will not work." -u critical
    exit 1
fi

# Listen to Hyprland socket for lock events
handle_event() {
    local event="$1"
    if [[ "$event" == "lockscreenevent>>"* ]]; then
        playerctl -a pause
    fi
}

socat -u UNIX-CONNECT:/tmp/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock - | while read -r line; do
    handle_event "$line"
done