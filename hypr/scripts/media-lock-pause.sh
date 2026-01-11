#!/usr/bin/env bash
command -v socat >/dev/null 2>&1 || exit 0
command -v playerctl >/dev/null 2>&1 || exit 0

[ -z "$HYPRLAND_INSTANCE_SIGNATURE" ] && exit 0

socat -u UNIX-CONNECT:/tmp/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock - 2>/dev/null | while read -r line; do
    [[ "$line" == "lockscreenevent>>"* ]] && playerctl -a pause 2>/dev/null
done