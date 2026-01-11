#!/usr/bin/env bash
SCRIPTS_DIR="$HOME/.config/hyprland/hypr/scripts"
ROFI_THEME="$HOME/.config/hyprland/hypr/rofi/launcher.rasi"

command -v nmcli &>/dev/null && {
    wifi_active=$(nmcli -t -f TYPE,STATE connection show --active | grep "802-11-wireless:activated")
    [ -n "$wifi_active" ] && wifi_id=$(nmcli -t -f NAME connection show --active | head -n1) && \
        wifi_entry="󰖩  Wi-Fi: ${wifi_id:-Connected}" || wifi_entry="󰖪  Wi-Fi: Disconnected"
} || wifi_entry="󰖩  Wi-Fi"

command -v bluetoothctl &>/dev/null && {
    timeout 0.2s bluetoothctl show | grep -q "Powered: yes" && {
        bt_dev=$(timeout 0.2s bluetoothctl info | grep "Name" | cut -d ' ' -f 2-)
        [ -n "$bt_dev" ] && bt_entry="󰂯  Bluetooth: $bt_dev" || bt_entry="󰂯  Bluetooth: On"
    } || bt_entry="󰂲  Bluetooth: Off"
} || bt_entry="󰂯  Bluetooth"

options="$wifi_entry
$bt_entry
󰂛  Do Not Disturb
  Caffeine
󰽥  Focus Mode
󰀵  Software Store
󰄜  KDE Connect
󰒍  LocalSend
󰆍  Config"

choice=$(echo -e "$options" | rofi -dmenu -i -p "Control Panel" -theme "$ROFI_THEME")

case "$choice" in
  *"Wi-Fi"*) nm-connection-editor & ;;
  *"Bluetooth"*) blueman-manager & ;;
  *"Do Not Disturb"*) "$SCRIPTS_DIR/toggle-dnd.sh" ;;
  *"Caffeine"*) "$SCRIPTS_DIR/toggle-caffeine.sh" ;;
  *"Focus Mode"*) "$SCRIPTS_DIR/toggle-focus-mode.sh" ;;
  *"Software Store"*) flatpak run org.gnome.Software 2>/dev/null || gnome-software 2>/dev/null || discover 2>/dev/null ;;
  *"KDE Connect"*) kdeconnect-app & ;;
  *"LocalSend"*) flatpak run org.localsend.localsend_app 2>/dev/null || localsend_app 2>/dev/null ;;
  *"Config"*) cd ~/.config/hyprland && code . & ;;
esac