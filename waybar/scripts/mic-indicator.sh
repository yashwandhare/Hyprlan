#!/usr/bin/env bash

STATE_FILE="/tmp/mic_indicator_state"

# Check if any real (non-monitor) mic source is RUNNING
running_sources=$(pactl list sources short 2>/dev/null | \
    awk '$2 !~ /\.monitor$/ && $7 == "RUNNING"')

if [ -z "$running_sources" ]; then
    echo "inactive" > "$STATE_FILE" 2>/dev/null
    echo ""
    exit 0
fi

# Get apps using the mic
apps=$(pactl list source-outputs 2>/dev/null | awk '
BEGIN { app=""; binary=""; source="" }
/^Source Output #/ { app=""; binary=""; source="" }
/^\tSource:/ { source=$2 }
/^\tapplication.name = "/ { 
    match($0, /"([^"]+)"/, arr)
    app=arr[1]
}
/^\tapplication.process.binary = "/ {
    match($0, /"([^"]+)"/, arr)
    binary=arr[1]
}
/^$/ {
    if (source !~ /\.monitor$/) {
        if (binary != "") print binary
        else if (app != "") print app
    }
    app=""; binary=""; source=""
}
' | sort -u | paste -sd, - | sed 's/,/, /g')

# Notify once per activation
if [ "$(cat "$STATE_FILE" 2>/dev/null)" != "active" ]; then
    if [ -n "$apps" ]; then
        notify-send -u low -t 2000 "Microphone" "󰍬 In use by: $apps"
    else
        notify-send -u low -t 2000 "Microphone" "󰍬 Microphone is active"
    fi
    echo "active" > "$STATE_FILE"
fi

# Waybar output
if [ -n "$apps" ]; then
    echo "{\"text\":\"󰍬 MIC\",\"tooltip\":\"Using: $apps\"}"
else
    echo "{\"text\":\"󰍬 MIC\",\"tooltip\":\"Microphone Active\"}"
fi
