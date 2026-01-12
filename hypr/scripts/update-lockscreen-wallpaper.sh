#!/usr/bin/env bash

# Update hyprlock.conf with current wallpaper
# If argument provided, use that; otherwise read from current_wallpaper symlink

WALLPAPER="${1:-$(readlink -f ~/.cache/current_wallpaper 2>/dev/null)}"

if [ -z "$WALLPAPER" ] || [ ! -f "$WALLPAPER" ]; then
    # Fallback: try to find any wallpaper
    WALLPAPER=$(find ~/Downloads/walls -type f \( -iname "*.jpg" -o -iname "*.png" -o -iname "*.webp" \) 2>/dev/null | head -n1)
    [ -z "$WALLPAPER" ] && exit 0
fi

# Escape path for sed
ESCAPED_PATH=$(printf '%s\n' "$WALLPAPER" | sed -e 's/[\/&]/\\&/g')

# Update hyprlock.conf
sed -i "s|^    path = .*|    path = $ESCAPED_PATH|" ~/.config/hyprland/hypr/hyprlock.conf
