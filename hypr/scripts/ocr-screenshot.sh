#!/usr/bin/env bash

# OCR from screenshot - requires tesseract and grim/slurp

# Check dependencies
if ! command -v tesseract &>/dev/null; then
    notify-send "OCR Error" "tesseract not installed" -u critical
    exit 1
fi

if ! command -v grim &>/dev/null || ! command -v slurp &>/dev/null; then
    notify-send "OCR Error" "grim/slurp not installed" -u critical
    exit 1
fi

# Create temp directory
TEMP_DIR="/tmp/hypr-ocr"
mkdir -p "$TEMP_DIR"
IMG_FILE="$TEMP_DIR/screenshot.png"
TXT_FILE="$TEMP_DIR/text.txt"

# Take screenshot of selected area
grim -g "$(slurp)" "$IMG_FILE" 2>/dev/null || {
    notify-send "OCR" "Screenshot cancelled" -t 1000
    exit 0
}

# Run OCR
tesseract "$IMG_FILE" "${TXT_FILE%.txt}" 2>/dev/null

if [ -f "$TXT_FILE" ] && [ -s "$TXT_FILE" ]; then
    # Copy to clipboard
    wl-copy < "$TXT_FILE"
    
    # Get first line for notification preview
    PREVIEW=$(head -n1 "$TXT_FILE" | cut -c1-50)
    [ ${#PREVIEW} -eq 50 ] && PREVIEW="${PREVIEW}..."
    
    notify-send "OCR Success" "Text copied to clipboard\n${PREVIEW}" -t 3000
else
    notify-send "OCR Failed" "No text detected" -u normal -t 2000
fi

# Cleanup
rm -f "$IMG_FILE" "$TXT_FILE"
