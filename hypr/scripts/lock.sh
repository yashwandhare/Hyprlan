#!/usr/bin/env bash
SCREENSHOT_PATH="/tmp/lock_screenshot.png"
rm -f "$SCREENSHOT_PATH"
grim "$SCREENSHOT_PATH" 2>/dev/null || {
    if command -v magick >/dev/null 2>&1; then
        magick -size 1920x1080 xc:"#191414" "$SCREENSHOT_PATH"
    elif command -v convert >/dev/null 2>&1; then
        convert -size 1920x1080 xc:"#191414" "$SCREENSHOT_PATH"
    fi
}
hyprlock