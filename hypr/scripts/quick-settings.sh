#!/usr/bin/env bash

if ! command -v wofi >/dev/null 2>&1; then
    notify-send -u critical "Quick Settings" "wofi is not installed"
    exit 1
fi

choice=$(printf "Wi-Fi\nBluetooth\nAudio\nBrightness\nPower\n" | wofi --dmenu --prompt "Quick Settings")

case "$choice" in
  "Wi-Fi")
    nm-connection-editor &
    ;;
  "Bluetooth")
    blueman-manager &
    ;;
  "Audio")
    pavucontrol &
    ;;
  "Brightness")
    kitty -e brightnessctl &
    ;;
  "Power")
    wlogout &
    ;;
esac
