#!/usr/bin/env bash
WALLDIR="${WALLPAPER_DIR:-$HOME/Downloads/walls}"
CACHE_DIR="$HOME/.cache/wallpicker"
CACHE_LIST="$CACHE_DIR/list.txt"
STATE="$HOME/.cache/current_wallpaper"
ROFI_THEME="$HOME/.config/hyprland/hypr/rofi/wallpaper.rasi"
THUMBNAIL_WIDTH=200
THUMBNAIL_HEIGHT=125
TRANSITION_TYPE="fade"
TRANSITION_DURATION="0.9"
TRANSITION_FPS="90"
TRANSITION_BEZIER="0.4,0.0,0.2,1.0"
MAX_ITEMS="${WALLPICKER_MAX:-0}"

# Build cache list and generate thumbnails for missing ones
scan_and_update_cache() {
    tmp="$CACHE_LIST.tmp"
    find "$WALLDIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) \
        -printf "%T@ %p\n" 2>/dev/null | sort -rn | cut -d' ' -f2- > "$tmp" && mv "$tmp" "$CACHE_LIST"
    (
        while read -r img; do
            [ -z "$img" ] && continue
            thumb="$CACHE_DIR/$(basename "$img")"
            [ ! -f "$thumb" ] && echo "$img|$thumb"
        done < "$CACHE_LIST" | xargs -P 8 -I {} sh -c '
            img="${1%%|*}"
            thumb="${1##*|}"
            magick "$img" -thumbnail ${THUMBNAIL_WIDTH}x${THUMBNAIL_HEIGHT}^ -gravity center -extent ${THUMBNAIL_WIDTH}x${THUMBNAIL_HEIGHT} -strip -quality 85 "$thumb" 2>/dev/null
        ' _ {}
    ) & disown
}

[ ! -d "$WALLDIR" ] && notify-send "Wallpaper Picker" "Directory $WALLDIR not found!" -u critical && exit 1
mkdir -p "$CACHE_DIR"

# Ensure swww daemon is running
if ! pgrep -x swww-daemon >/dev/null 2>&1; then
    swww-daemon --no-cache &
    sleep 0.2
fi

# Wait until swww reports at least one output (quick polling)
for i in {1..10}; do
    swww query >/dev/null 2>&1 && break
    sleep 0.1
done

if [ ! -f "$CACHE_LIST" ]; then
    scan_and_update_cache
fi

# Build menu list (optionally limit if MAX_ITEMS > 0)
if [ "$MAX_ITEMS" -gt 0 ]; then
    MENU_LIST=$(head -n "$MAX_ITEMS" "$CACHE_LIST" 2>/dev/null)
else
    MENU_LIST=$(cat "$CACHE_LIST" 2>/dev/null)
fi

(
    echo "$MENU_LIST" | while read -r img; do
        [ -z "$img" ] && continue
        thumb="$CACHE_DIR/$(basename "$img")"
        [ ! -f "$thumb" ] && echo "$img|$thumb"
    done | xargs -P 8 -I {} sh -c '
        img="${1%%|*}"
        thumb="${1##*|}"
        magick "$img" -thumbnail ${THUMBNAIL_WIDTH}x${THUMBNAIL_HEIGHT}^ -gravity center -extent ${THUMBNAIL_WIDTH}x${THUMBNAIL_HEIGHT} -strip -quality 85 "$thumb" 2>/dev/null
    ' _ {}
) & disown

selected="$(
    echo "$MENU_LIST" | while read -r img; do
        [ -z "$img" ] && continue
        thumb="$CACHE_DIR/$(basename "$img")"
        [ -f "$thumb" ] && printf "%s\0icon\x1f%s\n" "$(basename "$img")" "$thumb" || printf "%s\n" "$(basename "$img")"
    done | rofi -dmenu -no-custom -matching fuzzy -theme "$ROFI_THEME" -p "Select Wallpaper"
)"

[ -n "$selected" ] && wall="$WALLDIR/$selected" && [ -f "$wall" ] && {
    outputs=$(swww query 2>/dev/null | awk '/Output/ { out=$2; sub(/:$/, "", out); print out }')
    if [ -n "$outputs" ]; then
        apply_ok=1
        for out in $outputs; do
            swww img "$wall" --outputs "$out" --transition-type "$TRANSITION_TYPE" --transition-duration "$TRANSITION_DURATION" \
                --transition-fps "$TRANSITION_FPS" --transition-bezier "$TRANSITION_BEZIER" 2>/dev/null || apply_ok=0
        done
    else
        if swww img "$wall" --transition-type "$TRANSITION_TYPE" --transition-duration "$TRANSITION_DURATION" \
            --transition-fps "$TRANSITION_FPS" --transition-bezier "$TRANSITION_BEZIER" 2>/dev/null; then
            apply_ok=1
        else
            apply_ok=0
        fi
    fi

    if [ "$apply_ok" -eq 1 ]; then
        ln -sf "$wall" "$STATE"
        "$HOME/.config/hyprland/hypr/scripts/update-lockscreen-wallpaper.sh" "$wall"
        notify-send "Wallpaper" "Applied: $(basename "$selected")" -i "$wall"
        
        # Auto-refresh cache in background for next picker open
        (
            scan_and_update_cache
        ) & disown
    else
        notify-send "Wallpaper" "Failed to apply wallpaper" -u critical
    fi
}