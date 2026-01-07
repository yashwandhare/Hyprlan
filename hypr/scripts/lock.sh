#!/usr/bin/env bash

# -----------------------------------------------------
# Lock Screen - Screenshot with Blur
# -----------------------------------------------------
# Captures current screen and locks with blur effect

SCREENSHOT_PATH="/tmp/lock_screenshot.png"

# Remove old screenshot if it exists
rm -f "$SCREENSHOT_PATH"

# Create screenshot and wait for it to complete
grim "$SCREENSHOT_PATH" 2>/dev/null

# Ensure screenshot exists, use black fallback if not
if [ ! -f "$SCREENSHOT_PATH" ]; then
    # Create a solid grey image as fallback
    convert -size 1920x1080 xc:"#191414" "$SCREENSHOT_PATH" 2>/dev/null
fi

# Launch hyprlock with the screenshot ready
hyprlock