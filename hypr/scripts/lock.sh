#!/usr/bin/env bash

# -----------------------------------------------------
# Lock Screen Wrapper (Fixed)
# -----------------------------------------------------

# 1. Clear old temp file to prevent stale locks
rm -f /tmp/current_wallpaper.png

# 2. Robustly find the current wallpaper
#    (Greps for any standard image file path starting with /)
current_wall=$(swww query | grep -oE '/[^"]+\.(png|jpg|jpeg|webp)' | head -n 1)

echo "Detected Wallpaper: $current_wall" # Debug output

# 3. Copy with fallback
if [ -f "$current_wall" ]; then
    cp "$current_wall" /tmp/current_wallpaper.png
else
    echo "Wallpaper not found or invalid path. Using fallback."
    # CHANGE THIS to a real file on your system
    cp ~/Pictures/Wallpapers/default.png /tmp/current_wallpaper.png 
fi

# 4. Launch Hyprlock
hyprlock