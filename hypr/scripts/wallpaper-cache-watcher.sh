#!/usr/bin/env bash
set -euo pipefail

WALLDIR="${WALLPAPER_DIR:-$HOME/Downloads/walls}"
CACHE_DIR="$HOME/.cache/wallpicker"
CACHE_LIST="$CACHE_DIR/list.txt"
THUMBNAIL_WIDTH=${THUMBNAIL_WIDTH:-200}
THUMBNAIL_HEIGHT=${THUMBNAIL_HEIGHT:-125}

mkdir -p "$CACHE_DIR"

rebuild_cache() {
  tmp="$CACHE_LIST.tmp"
  find "$WALLDIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) \
    -printf "%T@ %p\n" 2>/dev/null | sort -rn | cut -d' ' -f2- > "$tmp" && mv "$tmp" "$CACHE_LIST"
}

gen_thumbs() {
  [ -f "$CACHE_LIST" ] || return 0
  awk 'NF' "$CACHE_LIST" | while read -r img; do
    thumb="$CACHE_DIR/$(basename "$img")"
    if [ ! -f "$thumb" ]; then
      echo "$img|$thumb"
    fi
  done | xargs -P 2 -I {} sh -c '
    img="${1%%|*}"; thumb="${1##*|}";
    magick "$img" -thumbnail '${THUMBNAIL_WIDTH}'x'${THUMBNAIL_HEIGHT}'^ -gravity center -extent '${THUMBNAIL_WIDTH}'x'${THUMBNAIL_HEIGHT}' -strip -quality 85 "$thumb" 2>/dev/null || true
  ' _ {}
}

initial_setup() {
  [ -f "$CACHE_LIST" ] || rebuild_cache
  gen_thumbs
}

initial_setup

if command -v inotifywait >/dev/null 2>&1; then
  while inotifywait -qq -r -e create,delete,move,close_write "$WALLDIR"; do
    rebuild_cache
    gen_thumbs
    sleep 0.5
  done
else
  while true; do
    rebuild_cache
    gen_thumbs
    sleep 600
  done
fi
