#!/usr/bin/env bash

WALLDIR="${WALLPAPER_DIR:-$HOME/Downloads/walls}"
CACHE_DIR="$HOME/.cache/wallpicker"
CACHE_LIST="$CACHE_DIR/list.txt"
STATE="$HOME/.cache/current_wallpaper"
ROFI_THEME="$HOME/.config/hypr/rofi/wallpaper.rasi"

THUMBNAIL_WIDTH=480
THUMBNAIL_HEIGHT=270
TRANSITION_TYPE="fade"
TRANSITION_DURATION="0.8"

mkdir -p "$CACHE_DIR"

command -v rofi >/dev/null || exit 1
command -v swww >/dev/null || exit 1
command -v magick >/dev/null || exit 1

pgrep -x swww-daemon >/dev/null || swww-daemon & disown

if [ ! -f "$CACHE_LIST" ] || [ "$(find "$CACHE_LIST" -mmin +0.5 2>/dev/null)" ]; then
    find "$WALLDIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) \
        -printf "%T@ %p\n" 2>/dev/null | sort -rn | cut -d' ' -f2- > "$CACHE_LIST"
fi

(
    grep -v '^$' "$CACHE_LIST" | while read -r img; do
        thumb="$CACHE_DIR/$(basename "$img")"
        [ -f "$thumb" ] && continue
        echo "$img|$thumb"
    done | xargs -P 4 -I {} sh -c '
        img="${1%%|*}"
        thumb="${1##*|}"
        magick "$img" -resize "'${THUMBNAIL_WIDTH}'x'${THUMBNAIL_HEIGHT}'^" \
            -gravity center -extent "'${THUMBNAIL_WIDTH}'x'${THUMBNAIL_HEIGHT}'" \
            -quality 85 "$thumb" 2>/dev/null
    ' _ {}
) & disown

selected="$(
while read -r img; do
    thumb="$CACHE_DIR/$(basename "$img")"
    [ -f "$thumb" ] || continue
    printf "%s\0icon\x1f%s\n" "$(basename "$img")" "$thumb"
done < "$CACHE_LIST" | rofi -dmenu -no-custom -matching fuzzy -theme "$ROFI_THEME" -p "Wallpaper"
)"

[ -z "$selected" ] && exit 0

wall="$WALLDIR/$selected"
[ -f "$wall" ] || exit 0

(
swww img "$wall" \
    --transition-type "$TRANSITION_TYPE" \
    --transition-duration "$TRANSITION_DURATION" \
    --transition-fps 60
ln -sfn "$wall" "$STATE"
) & disown
