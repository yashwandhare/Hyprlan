#!/usr/bin/env bash

# Check if kdeconnect-cli is available
command -v kdeconnect-cli &>/dev/null || exit 0

# Check if any KDE Connect device is connected
if kdeconnect-cli -a --id-only 2>/dev/null | grep -q .; then
    echo ""
else
    echo ""
fi
