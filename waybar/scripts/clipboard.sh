#!/usr/bin/env bash

# Check if required commands are available
command -v cliphist &>/dev/null || exit 1
command -v wofi &>/dev/null || exit 1
command -v wl-copy &>/dev/null || exit 1

cliphist list | wofi --show dmenu | cliphist decode | wl-copy
