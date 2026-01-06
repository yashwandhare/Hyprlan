#!/usr/bin/env bash

# -----------------------------------------------------
# OCR Screenshot (Grim + Slurp + Tesseract)
# -----------------------------------------------------

# Dependency Check
for cmd in tesseract grim slurp wl-copy; do
    if ! command -v $cmd &>/dev/null; then
        notify-send "OCR Error" "$cmd not installed" -u critical
        exit 1
    fi
done

# Create safe temp files
IMG_FILE=$(mktemp /tmp/ocr-XXXXX.png)
TXT_FILE=$(mktemp /tmp/ocr-XXXXX)

# 1. Capture Region
if ! grim -g "$(slurp)" "$IMG_FILE"; then
    rm -f "$IMG_FILE" "$TXT_FILE"
    exit 0
fi

# 2. Run Tesseract (OCR)
# -l eng = English (add others if needed, e.g. -l eng+deu)
tesseract "$IMG_FILE" "$TXT_FILE" &>/dev/null

# 3. Process Result
if [ -s "${TXT_FILE}.txt" ]; then
    # Clean up whitespace and copy
    cat "${TXT_FILE}.txt" | tr -s ' \n' ' ' | wl-copy
    
    # Generate Preview (First 60 chars)
    PREVIEW=$(head -c 60 "${TXT_FILE}.txt")
    notify-send "OCR Copied" "\"${PREVIEW}...\"" -i scanner-symbolic -t 3000
else
    notify-send "OCR Failed" "No text detected." -u low -i dialog-warning
fi

# Cleanup
rm -f "$IMG_FILE" "$TXT_FILE" "${TXT_FILE}.txt"