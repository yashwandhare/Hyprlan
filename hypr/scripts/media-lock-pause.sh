#!/usr/bin/env bash

# Auto-pause media when screen locks

# Listen to lock events
socat -u UNIX-CONNECT:/tmp/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock - | while read -r line; do
    if echo "$line" | grep -q "^lockscreenevent>>"; then
        # Pause all media players
        playerctl -a pause 2>/dev/null
    fi
done
