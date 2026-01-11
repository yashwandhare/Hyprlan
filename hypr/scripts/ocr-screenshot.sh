#!/usr/bin/env bash
for cmd in tesseract grim slurp wl-copy; do
    command -v "$cmd" >/dev/null 2>&1 || { notify-send "OCR Error" "$cmd not installed" -u critical; exit 1; }
done

IMG_FILE=$(mktemp /tmp/ocr-XXXXX.png)
TXT_FILE=$(mktemp /tmp/ocr-XXXXX)

grim -g "$(slurp)" "$IMG_FILE" || { rm -f "$IMG_FILE" "$TXT_FILE"; exit 0; }

tesseract "$IMG_FILE" "$TXT_FILE" &>/dev/null

if [ -s "${TXT_FILE}.txt" ]; then
    tr -s ' \n' ' ' < "${TXT_FILE}.txt" | wl-copy
    PREVIEW=$(head -c 60 "${TXT_FILE}.txt")
    notify-send "OCR Copied" "\"${PREVIEW}...\"" -i scanner-symbolic -t 3000
else
    notify-send "OCR Failed" "No text detected." -u low -i dialog-warning
fi

rm -f "$IMG_FILE" "$TXT_FILE" "${TXT_FILE}.txt"