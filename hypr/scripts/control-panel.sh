#!/usr/bin/env bash

choice=$(printf "󰖩  Wi-Fi\n󰂯  Bluetooth\n󰂛  Do Not Disturb\n󰀵  Software Store\n󰄜  KDE Connect\n󰒍  LocalSend\n󰆍  Config" | \
    wofi --dmenu --prompt "" --width=300 --height=280 --location=center --hide-scroll --no-actions)

case "$choice" in
  "󰖩  Wi-Fi")
    nm-connection-editor &
    ;;
  "󰂯  Bluetooth")
    blueman-manager &
    ;;
  "󰂛  Do Not Disturb")
    ~/.config/hyprland/hypr/scripts/toggle-dnd.sh
    ;;
  "󰀵  Software Store")
    flatpak run org.gnome.Software 2>/dev/null || \
    gnome-software 2>/dev/null || \
    discover 2>/dev/null || \
    notify-send "Software Store" "Software store not found"
    ;;
  "󰄜  KDE Connect")
    kdeconnect-app &
    ;;
  "󰒍  LocalSend")
    flatpak run org.localsend.localsend_app 2>/dev/null || \
    localsend_app 2>/dev/null || \
    notify-send "LocalSend" "LocalSend not found"
    ;;
  "󰆍  Config")
    cd ~/.config/hyprland && code . &
    ;;
esac

