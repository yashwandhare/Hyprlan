#!/usr/bin/env bash

# Define empty JSON
EMPTY='{"text": "", "tooltip": "", "class": ""}'

if ! command -v kdeconnect-cli &>/dev/null; then
    echo "$EMPTY"
    exit 0
fi

# Get list of devices (IDs only)
DEVICES=$(kdeconnect-cli -a --id-only 2>/dev/null)

if [ -z "$DEVICES" ]; then
    echo "$EMPTY"
else
    # Count devices
    COUNT=$(echo "$DEVICES" | wc -l)
    
    # Get Name of first device and sanitize output (remove newlines)
    FIRST_ID=$(echo "$DEVICES" | head -n1)
    NAME=$(kdeconnect-cli --name --device "$FIRST_ID" 2>/dev/null | tr -d '\n')
    
    if [ -z "$NAME" ]; then
        NAME="Unknown Device"
    fi
    
    if [ "$COUNT" -gt 1 ]; then
        TOOLTIP="$COUNT Devices Connected\nPrimary: $NAME"
    else
        TOOLTIP="Connected: $NAME"
    fi
    
    # Output JSON with Phone Icon
    printf '{"text": "", "tooltip": "%s", "class": "connected"}\n' "$TOOLTIP"
fi