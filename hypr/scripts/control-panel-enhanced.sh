#!/usr/bin/env bash

# -----------------------------------------------------
# Control Panel (Wofi Menu)
# -----------------------------------------------------

SCRIPTS_DIR="$HOME/.config/hyprland/hypr/scripts"

# -----------------------------------------------------
# FAST STATUS CHECKS (Instant Cache Query)
# -----------------------------------------------------

# Wi-Fi: Query active connection name directly (No hardware scan)
if command -v nmcli &> /dev/null; then
    wifi_active=$(nmcli -t -f TYPE,STATE connection show --active | grep "802-11-wireless:activated")
    if [ -n "$wifi_active" ]; then
        # Get name only if active
        wifi_id=$(nmcli -t -f NAME connection show --active | head -n1)
        wifi_entry="󰖩  Wi-Fi: ${wifi_id:-Connected}"
    else
        wifi_entry="󰖪  Wi-Fi: Disconnected"
    fi
else
    wifi_entry="󰖩  Wi-Fi"
fi

# Bluetooth: fast timeout check
if command -v bluetoothctl &> /dev/null; then
    # Timeout after 0.2s to prevent lag
    if timeout 0.2s bluetoothctl show | grep -q "Powered: yes"; then
        # Check for connected devices (fast grep)
        bt_dev=$(timeout 0.2s bluetoothctl info | grep "Name" | cut -d ' ' -f 2-)
        if [ -n "$bt_dev" ]; then
            bt_entry="󰂯  Bluetooth: $bt_dev"
        else
            bt_entry="󰂯  Bluetooth: On"
        fi
    else
        bt_entry="󰂲  Bluetooth: Off"
    fi
else
    bt_entry="󰂯  Bluetooth"
fi

# -----------------------------------------------------
# MENU OPTIONS
# -----------------------------------------------------
options="$wifi_entry
$bt_entry
󰂛  Do Not Disturb
  Caffeine
󰽥  Focus Mode
󰀵  Software Store
󰄜  KDE Connect
󰒍  LocalSend
󰆍  Config"

# -----------------------------------------------------
# LAUNCH WOFI
# -----------------------------------------------------
choice=$(echo "$options" | wofi --dmenu \
    --prompt " " \
    --width=400 \
    --height=450 \
    --location=center \
    --hide-scroll \
    --no-actions \
    --cache-file /dev/null \
    --matching=fuzzy)

# -----------------------------------------------------
# HANDLE SELECTION
# -----------------------------------------------------
case "$choice" in
  *"Wi-Fi"*)
    nm-connection-editor & ;;
  *"Bluetooth"*)
    blueman-manager & ;;
  *"Do Not Disturb"*)
    "$SCRIPTS_DIR/toggle-dnd.sh" ;;
  *"Caffeine"*)
    "$SCRIPTS_DIR/toggle-caffeine.sh" ;;
  *"Focus Mode"*)
    "$SCRIPTS_DIR/toggle-focus-mode.sh" ;;
  *"Software Store"*)
    flatpak run org.gnome.Software 2>/dev/null || gnome-software 2>/dev/null || discover 2>/dev/null ;;
  *"KDE Connect"*)
    kdeconnect-app & ;;
  *"LocalSend"*)
    flatpak run org.localsend.localsend_app 2>/dev/null || localsend_app 2>/dev/null ;;
  *"Config"*)
    cd ~/.config/hyprland && code . & ;;
esac