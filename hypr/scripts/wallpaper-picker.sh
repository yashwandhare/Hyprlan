#!/usr/bin/env bash

# -----------------------------------------------------
# CONFIGURATION
# -----------------------------------------------------
WALLDIR="${WALLPAPER_DIR:-$HOME/Downloads/walls}"
CACHE_DIR="$HOME/.cache/wallpicker"
CACHE_LIST="$CACHE_DIR/list.txt"
STATE="$HOME/.cache/current_wallpaper"
ROFI_THEME="$HOME/.config/hyprland/hypr/rofi/wallpaper.rasi"

# Thumbnail Settings (High quality for 5x2 grid)
THUMBNAIL_WIDTH=400
THUMBNAIL_HEIGHT=250

# SWWW Transition - "Cinematic Fade"
TRANSITION_TYPE="fade"
TRANSITION_DURATION="2.5"
TRANSITION_FPS="60"
TRANSITION_BEZIER=".43,1.19,1,.4"

# -----------------------------------------------------
# CHECKS
# -----------------------------------------------------
if [ ! -d "$WALLDIR" ]; then
    notify-send "Wallpaper Picker" "Directory $WALLDIR not found!" -u critical
    exit 1
fi

mkdir -p "$CACHE_DIR"

if ! pgrep -x swww-daemon >/dev/null; then
    swww-daemon & disown
    sleep 0.5
fi

# -----------------------------------------------------
# CACHE GENERATION
# -----------------------------------------------------
if [ ! -f "$CACHE_LIST" ] || [ "$(find "$WALLDIR" -mmin -1 2>/dev/null)" ]; then
    find "$WALLDIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) \
        -printf "%T@ %p\n" 2>/dev/null | sort -rn | cut -d' ' -f2- > "$CACHE_LIST"
fi

# Parallel Thumbnail Generation
(
    while read -r img; do
        thumb="$CACHE_DIR/$(basename "$img")"
        if [ ! -f "$thumb" ]; then
            echo "$img|$thumb"
        fi
    done < "$CACHE_LIST" | xargs -P 4 -I {} sh -c '
        img="${1%%|*}"
        thumb="${1##*|}"
        magick "$img" -resize 400x250^ -gravity center -extent 400x250 "$thumb" 2>/dev/null
    ' _ {}
) & disown

# -----------------------------------------------------
# ROFI MENU
# -----------------------------------------------------
selected="$(
    while read -r img; do
        thumb="$CACHE_DIR/$(basename "$img")"
        [ -f "$thumb" ] || thumb="$img"
        printf "%s\0icon\x1f%s\n" "$(basename "$img")" "$thumb"
    done < "$CACHE_LIST" | rofi -dmenu -no-custom -matching fuzzy -theme "$ROFI_THEME" -p "Select Wallpaper"
)"

# -----------------------------------------------------
# APPLY WALLPAPER
# -----------------------------------------------------
if [ -n "$selected" ]; then
    wall="$WALLDIR/$selected"
    
    if [ -f "$wall" ]; then
        swww img "$wall" \
            --transition-type "$TRANSITION_TYPE" \
            --transition-duration "$TRANSITION_DURATION" \
            --transition-fps "$TRANSITION_FPS" \
            --transition-bezier "$TRANSITION_BEZIER"
            
        ln -sf "$wall" "$STATE"
        notify-send "Wallpaper" "Applied: $(basename "$selected")" -i "$wall"
    fi
fi