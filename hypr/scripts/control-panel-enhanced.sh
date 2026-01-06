#!/usr/bin/env bash

# -----------------------------------------------------
# Control Panel (Rofi Menu)
# -----------------------------------------------------

SCRIPTS_DIR="$HOME/.config/hypr/scripts"
ROFI_THEME="$HOME/.config/hypr/rofi/launcher.rasi"

# -----------------------------------------------------
# FAST STATUS CHECKS
# -----------------------------------------------------

# Wi-Fi
if command -v nmcli &> /dev/null; then
    wifi_active=$(nmcli -t -f TYPE,STATE connection show --active | grep "802-11-wireless:activated")
    if [ -n "$wifi_active" ]; then
        wifi_id=$(nmcli -t -f NAME connection show --active | head -n1)
        wifi_entry="󰖩  Wi-Fi: ${wifi_id:-Connected}"
    else
        wifi_entry="󰖪  Wi-Fi: Disconnected"
    fi
else
    wifi_entry="󰖩  Wi-Fi"
fi

# Bluetooth
if command -v bluetoothctl &> /dev/null; then
    if timeout 0.2s bluetoothctl show | grep -q "Powered: yes"; then
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
# LAUNCH ROFI
# -----------------------------------------------------
choice=$(echo -e "$options" | rofi -dmenu \
    -i \
    -p "Control Panel" \
    -theme "$ROFI_THEME")

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