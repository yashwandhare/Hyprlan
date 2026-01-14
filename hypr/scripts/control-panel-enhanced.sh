#!/usr/bin/env bash
# Unified Control Center v8.3
# Fixes: Hotspot/Scan button logic, Icons, Stability.

set -u

# --- Configuration ---
ROFI_THEME="${ROFI_THEME:-$HOME/.config/hyprland/hypr/rofi/launcher.rasi}"
SCRIPTS_DIR="$HOME/.config/hyprland/hypr/scripts"

# Theme Overrides
THEME_MAIN="window { width: 600px; height: 600px; } listview { lines: 14; }"
THEME_VITALS="window { width: 800px; height: 600px; } listview { lines: 16; fixed-height: false; }"

# --- Icons ---
I_WIFI="󰖩"
I_BT="󰂯"
I_VITAL="󰓅"
I_THEME="󰉼"
I_BACK="󰌍"
I_REFRESH="⟳"
I_LOCK=""
I_UNLOCK=""
I_CHECK="󰄬"
I_WARN=""
I_EXIT="󰗼"
I_ETH="󰈀"
I_HOTSPOT="󰐹"
I_EDIT="󰒓"

# Bluetooth Icons
I_BT_POWER=""
I_BT_SCAN="󰑓"
I_BT_CONN="󰂱"
I_BT_DISC="󰂲"
I_BT_TRUST="󰂨"
I_BT_UNTRUST="󰂩"
I_BT_PAIR="󰆴"
I_BT_AUDIO="󰂰"
I_BT_INPUT="󰰏"
I_BT_PHONE="󰏲"
I_BT_COMP="󰇅"
I_BT_DEF="󰂯"

# Vitals Icons
I_CPU=""
I_GPU="󰢮"
I_RAM="󰍛"
I_DISK="󰋊"
I_BATT="󰁹"
I_NET="󰖩"
I_UP=""
I_DOWN=""
I_TAB_ACT="▣"
I_TAB_INA="▢"
I_USER=""
I_SYS=""

# --- HELPER: Rofi Wrapper ---
run_rofi() {
    local theme_str="${2:-$THEME_MAIN}"
    rofi -dmenu -i -theme-str "$theme_str" -theme "$ROFI_THEME" -p "$1" "${@:3}"
}

notify() {
    notify-send -u low -t 2000 -h string:x-canonical-private-synchronous:control-center "Control Center" "$1"
}

# ==============================================================================
# MODULE: APPEARANCE
# ==============================================================================
menu_themes() {
    local ctx="$1"
    local theme_dir="$HOME/.config/hyprland/themes"
    local link_dir="$HOME/.config/hyprland/hypr/theme"
    local visuals_conf="$link_dir/visuals.conf"
    local apply_dunst="$HOME/.config/hyprland/hypr/scripts/apply-dunst-theme.sh"

    [[ ! -d "$theme_dir" ]] && notify "Error: Theme directory missing" && return

    local current_path=$(readlink -f "$link_dir/colors.conf" 2>/dev/null || echo "")
    local current_theme=""
    [[ "$current_path" == *"/themes/"* ]] && current_theme=$(basename "$(dirname "$current_path")")

    local theme_list=""
    for d in "$theme_dir"/*; do
        if [[ -d "$d" ]]; then
            local name=$(basename "$d")
            [[ "$name" == "$current_theme" ]] && theme_list+="● $name\n" || theme_list+="$name\n"
        fi
    done

    local options=""
    [[ "$ctx" == "menu" ]] && options="$I_BACK Back\n"
    options+="$theme_list"

    local sel=$(echo -e "$options" | run_rofi "Appearance")
    local choice=$(echo "$sel" | sed 's/^● //')

    case "$choice" in
        "") exit 0 ;;
        *"Back") main_menu ;;
        *)
            if [[ -d "$theme_dir/$choice" ]]; then
                ln -sf "$theme_dir/$choice/hyprland.conf" "$link_dir/colors.conf"
                [[ -f "$theme_dir/$choice/waybar.css" ]] && ln -sf "$theme_dir/$choice/waybar.css" "$link_dir/waybar-colors.css"
                [[ -f "$theme_dir/$choice/rofi.rasi" ]] && ln -sf "$theme_dir/$choice/rofi.rasi" "$link_dir/rofi-colors.rasi"
                ln -sf "$link_dir/mode_solid.css" "$link_dir/waybar-mode.css"
                ln -sf "$link_dir/rofi-mode-solid.rasi" "$link_dir/rofi-mode.rasi"
                [[ -f "$apply_dunst" && -f "$theme_dir/$choice/dunst.conf" ]] && "$apply_dunst" "$choice"
                sed -i 's/active_opacity = .*/active_opacity = 1.0/' "$visuals_conf"
                sed -i 's/inactive_opacity = .*/inactive_opacity = 1.0/' "$visuals_conf"
                sed -i '/blur {/,/}/ s/enabled = true/enabled = false/' "$visuals_conf"

                notify "Applying Theme: $choice..."
                hyprctl reload
                sleep 0.2
                pkill -9 waybar; waybar > /dev/null 2>&1 &
                pkill dunst; dunst & disown
                exit 0
            else
                exec "$0" "themes" "$ctx"
            fi
            ;;
    esac
}

# ==============================================================================
# MODULE: VITALS
# ==============================================================================
vitals_get_bar() {
    local percent=${1%.*}; local width=14; local filled=$(( (percent * width) / 100 )); local empty=$(( width - filled )); local bar=""
    for ((i=0; i<filled; i++)); do bar+="█"; done
    for ((i=0; i<empty; i++)); do bar+="░"; done
    echo "$bar"
}

vitals_get_cpu_temp() {
    local temp="N/A"
    command -v sensors &>/dev/null && temp=$(sensors 2>/dev/null | awk '/Package id 0/{print $4;exit}/Tctl/{print $2;exit}' | tr -d '+' | sed 's/\..*//')
    if [[ "$temp" == "N/A" || -z "$temp" ]]; then
        for zone in /sys/class/thermal/thermal_zone*; do
            local t=$(cat "$zone/temp" 2>/dev/null || echo 0)
            if [[ $t -gt 20000 && $t -lt 110000 ]]; then temp="$((t / 1000))°C"; break; fi
        done
    fi
    echo "${temp:-N/A}"
}

vitals_get_battery() {
    local bat_path=""; for b in /sys/class/power_supply/BAT*; do [[ -d "$b" ]] && bat_path="$b" && break; done
    [[ -z "$bat_path" ]] && printf "  %s  Battery       Not Found\n" "$I_BATT" && return
    
    local cap=$(cat "$bat_path/capacity"); local status=$(cat "$bat_path/status"); local usage=""
    [[ -f "$bat_path/power_now" ]] && { local p=$(cat "$bat_path/power_now"); [[ $p -gt 0 ]] && usage="$(awk -v p="$p" 'BEGIN {printf "%.1fW", p/1000000}')"; }
    local icon="$I_BATT"; [[ $cap -lt 20 ]] && icon="$I_WARN"
    
    [[ -n "$usage" ]] && printf "  %s  Battery       %-16s %3d%% (%s, %s Draw)\n" "$icon" "$(vitals_get_bar $cap)" "$cap" "$status" "$usage" || printf "  %s  Battery       %-16s %3d%% (%s)\n" "$icon" "$(vitals_get_bar $cap)" "$cap" "$status"
}

vitals_get_system() {
    local net_iface=$(ip route | awk '/default/ {print $5; exit}')
    
    local rx1=$(cat /sys/class/net/$net_iface/statistics/rx_bytes 2>/dev/null || echo 0)
    local tx1=$(cat /sys/class/net/$net_iface/statistics/tx_bytes 2>/dev/null || echo 0)
    local ci1=$(awk '/^cpu / {print $5}' /proc/stat)
    local ct1=$(awk '/^cpu / {print $2+$3+$4+$5+$6+$7+$8}' /proc/stat)
    
    sleep 0.1
    
    local rx2=$(cat /sys/class/net/$net_iface/statistics/rx_bytes 2>/dev/null || echo 0)
    local tx2=$(cat /sys/class/net/$net_iface/statistics/tx_bytes 2>/dev/null || echo 0)
    local ci2=$(awk '/^cpu / {print $5}' /proc/stat)
    local ct2=$(awk '/^cpu / {print $2+$3+$4+$5+$6+$7+$8}' /proc/stat)
    
    local cu=0; [[ $((ct2 - ct1)) -gt 0 ]] && cu=$((100 * ((ct2 - ct1) - (ci2 - ci1)) / (ct2 - ct1)))
    
    local rx_bytes=$(( (rx2 - rx1) * 10 ))
    local tx_bytes=$(( (tx2 - tx1) * 10 ))
    local rx_mb=$(awk "BEGIN{printf \"%.2f\", $rx_bytes/1024/1024}")
    local tx_mb=$(awk "BEGIN{printf \"%.2f\", $tx_bytes/1024/1024}")

    local mem=$(cat /proc/meminfo); local mt=$(echo "$mem" | awk '/^MemTotal:/{print $2}'); local mu=$((mt - $(echo "$mem" | awk '/^MemAvailable:/{print $2}')))
    local mp=$((mu * 100 / mt)); local mgb=$(awk "BEGIN{printf \"%.1f\", $mu/1024/1024}")
    local st=$(echo "$mem" | awk '/^SwapTotal:/{print $2}'); local su=$((st - $(echo "$mem" | awk '/^SwapFree:/{print $2}'))); local sgb=$(awk "BEGIN{printf \"%.1f\", $su/1024/1024}")
    
    local disk=$(df -h / | tail -1); local du=$(echo "$disk" | awk '{print $5}' | tr -d '%'); local da=$(echo "$disk" | awk '{print $4}')
    
    local gpu_line="  $I_GPU  GPU Nvidia    Not Found"
    if command -v nvidia-smi &>/dev/null; then
        local gd=$(nvidia-smi --query-gpu=utilization.gpu,temperature.gpu,memory.used,memory.total --format=csv,noheader,nounits 2>/dev/null)
        [[ -n "$gd" ]] && gpu_line=$(printf "  %s  GPU Nvidia    %-16s %3d%% (%d°C, %dMB/%dMB)" "$I_GPU" "$(vitals_get_bar $(echo "$gd" | cut -d, -f1))" $(echo "$gd" | cut -d, -f1) $(echo "$gd" | cut -d, -f2) $(echo "$gd" | cut -d, -f3) $(echo "$gd" | cut -d, -f4))
    fi

    printf "  %s  CPU           %-16s %3d%% (%s)\n" "$I_CPU" "$(vitals_get_bar $cu)" "$cu" "$(vitals_get_cpu_temp)"
    echo "$gpu_line"
    printf "  %s  Memory        %-16s %3d%% (%.1fG Used, Swap: %.1fG)\n" "$I_RAM" "$(vitals_get_bar $mp)" "$mp" "$mgb" "$sgb"
    printf "  %s  Storage (/)   %-16s %3d%% (%s Free)\n" "$I_DISK" "$(vitals_get_bar $du)" "$du" "$da"
    printf "  %s  Network       %s %s MB/s  %s %s MB/s\n" "$I_NET" "$I_DOWN" "$rx_mb" "$I_UP" "$tx_mb"
    vitals_get_battery
}

vitals_get_processes() {
    local cores=$(nproc)
    printf "   %-8s %-10s %-8s %-10s %s\n" "TYPE" "PID" "CPU%" "RAM(MB)" "COMMAND"
    echo "   --------------------------------------------------------"
    ps -eo user,pid,%cpu,rss,comm --sort=-%cpu | head -n 16 | tail -n +2 | \
    awk -v me="$USER" -v cores="$cores" -v i_user="$I_USER" -v i_sys="$I_SYS" '
    {
        user=$1; pid=$2; raw=$3; ram=$4; cmd=$5
        if (length(cmd) > 15) cmd = substr(cmd, 1, 14) "…"
        norm = raw / cores; icon = (user == me) ? i_user : i_sys; type = (user == me) ? "USER" : "SYS "
        printf "   %s %s   %-10s %-8.1f %-10s %s\n", icon, type, pid, norm, sprintf("%.0f", ram/1024), cmd
    }'
}

module_vitals() {
    local view="${1:-vitals}"
    local ctx="${2:-}"

    while true; do
        local back_opt=""
        [[ "$ctx" == "menu" ]] && back_opt="$I_BACK Back\n"

        if [[ "$view" == "vitals" ]]; then
            HEADER="${back_opt}$I_TAB_ACT System Vitals (Select to Refresh)\n$I_TAB_INA Process Manager\n___________________________________________________"
            CONTENT=$(vitals_get_system)
        else
            HEADER="${back_opt}$I_TAB_INA System Vitals\n$I_TAB_ACT Process Manager\n___________________________________________________"
            CONTENT=$(vitals_get_processes)
        fi

        SELECTION=$(echo -e "$HEADER\n$CONTENT" | run_rofi "Monitor" "$THEME_VITALS" -mesg "Last Update: $(date +%T)")

        case "$SELECTION" in
            "") exit 0 ;; 
            *"Back"*) exec "$0" "menu"; exit 0 ;; 
            *"System Vitals"*) view="vitals" ;;
            *"Process Manager"*) view="processes" ;;
            *"$I_USER"*|*"$I_SYS"*)
                PID=$(echo "$SELECTION" | awk '{print $3}')
                NAME=$(echo "$SELECTION" | awk '{print $6}')
                [[ -z "$PID" ]] && continue
                CONF=$(echo -e "No\nYes" | run_rofi "Kill $NAME ($PID)?" "window {width: 300px; height: 150px;}")
                [[ "$CONF" == "Yes" ]] && kill -9 "$PID" 2>/dev/null
                view="processes"
                ;;
            *) continue ;;
        esac
    done
}

# ==============================================================================
# MODULE: BLUETOOTH
# ==============================================================================
bt_get_icon() {
    local type=$(bluetoothctl info "$1" | grep "Icon:" | cut -d: -f2 | xargs)
    case "$type" in *"audio"*|*"headset"*) echo "$I_BT_AUDIO";; *"input"*|*"mouse"*) echo "$I_BT_INPUT";; *"phone"*) echo "$I_BT_PHONE";; *"computer"*) echo "$I_BT_COMP";; *) echo "$I_BT_DEF";; esac
}

module_bluetooth() {
    local ctx="$1"
    local power="off"; bluetoothctl show | grep "Powered: yes" >/dev/null && power="on"
    
    local options=""
    [[ "$ctx" == "menu" ]] && options="$I_BACK Back\n"

    if [[ "$power" == "off" ]]; then
        options+="$I_BT_POWER Turn On Bluetooth"
        local sel=$(echo -e "$options" | run_rofi "Bluetooth")
        case "$sel" in
            "") exit 0 ;;
            *"Back") exec "$0" ;;
            *"Turn On"*) bluetoothctl power on; sleep 0.5; exec "$0" "bt" "$ctx" ;;
        esac
        return
    fi

    local scan_state="no"
    if pgrep -f "bluetoothctl scan on" >/dev/null 2>&1; then
        scan_state="yes"
    fi
    
    options+="$I_BT_POWER Turn Off Bluetooth\n"
    if [[ "$scan_state" == "yes" ]]; then options+="$I_BT_SCAN Stop Scanning"; else options+="$I_BT_SCAN Scan for Devices"; fi
    options+="\n$I_EDIT Open Settings (Blueman)\n------------------------------------------------"

    local devices=""
    while read -r line; do
        local mac=$(echo "$line" | cut -d ' ' -f 2); local name=$(echo "$line" | cut -d ' ' -f 3-); local info=$(bluetoothctl info "$mac")
        local is_conn=$(echo "$info" | grep "Connected: yes"); local icon=$(bt_get_icon "$mac")
        [[ -n "$is_conn" ]] && devices+="<b>$icon  $name (Connected)</b> <span size='x-small'>$mac</span>\n" || devices+="$icon  $name <span size='x-small'>$mac</span>\n"
    done < <(bluetoothctl devices)

    local sel=$(echo -e "$options\n$devices" | run_rofi "Bluetooth" "$THEME_MAIN" -markup-rows)

    case "$sel" in
        "") exit 0 ;;
        *"Back") exec "$0" ;;
        *"Turn Off"*) bluetoothctl power off; sleep 0.5; exec "$0" "bt" "$ctx" ;;
        *"Scan"*) notify "Scanning..."; nohup bluetoothctl scan on >/dev/null 2>&1 & sleep 1; exec "$0" "bt" "$ctx" ;;
        *"Stop Scanning"*) pkill -f "bluetoothctl scan on"; bluetoothctl scan off >/dev/null 2>&1; notify "Scanning Stopped"; sleep 0.5; exec "$0" "bt" "$ctx" ;;
        *"Open Settings"*) blueman-manager & ;;
        *"---"*) exec "$0" "bt" "$ctx" ;;
        *)
            local mac=$(echo "$sel" | grep -oE '([0-9A-Fa-f]{2}:){5}[0-9A-Fa-f]{2}')
            local name=$(echo "$sel" | sed -E 's/<[^>]*>//g' | sed -E "s/$mac//" | sed "s/^. //" | xargs)
            [[ -n "$mac" ]] && bt_device_menu "$mac" "$name" "$ctx"
            ;;
    esac
}

bt_device_menu() {
    local mac=$1; local name=$2; local ctx=$3
    local info=$(bluetoothctl info "$mac"); local conn=$(echo "$info" | grep "Connected: yes"); local pair=$(echo "$info" | grep "Paired: yes"); local trust=$(echo "$info" | grep "Trusted: yes")
    
    local opts="$I_BACK Back"
    [[ -n "$conn" ]] && opts+="\n$I_BT_DISC Disconnect" || opts+="\n$I_BT_CONN Connect"
    [[ -n "$pair" ]] && opts+="\n$I_BT_PAIR Remove (Unpair)" || opts+="\n$I_BT_CONN Pair"
    [[ -n "$trust" ]] && opts+="\n$I_BT_UNTRUST Untrust" || opts+="\n$I_BT_TRUST Trust"
    
    local sel=$(echo -e "$opts" | run_rofi "$name")
    case "$sel" in
        "") exit 0 ;;
        *"Back") exec "$0" "bt" "$ctx" ;;
        *"Connect") notify "Connecting..."; bluetoothctl connect "$mac";;
        *"Disconnect") bluetoothctl disconnect "$mac";;
        *"Pair") notify "Pairing..."; bluetoothctl pair "$mac";;
        *"Remove") bluetoothctl remove "$mac"; exec "$0" "bt" "$ctx" ;;
        *"Trust") bluetoothctl trust "$mac";;
        *"Untrust") bluetoothctl untrust "$mac";;
    esac
    exec "$0" "bt" "$ctx"
}

# ==============================================================================
# MODULE: WI-FI
# ==============================================================================
HS_SSID_FILE="${XDG_CACHE_HOME:-$HOME/.cache}/rofi-wifi-hotspot-ssid"
HS_PASS_FILE="${XDG_CACHE_HOME:-$HOME/.cache}/rofi-wifi-hotspot-pass"

wifi_get_iface() { nmcli -t -f DEVICE,TYPE device | grep ":wifi$" | head -n1 | cut -d: -f1; }

wifi_hotspot_menu() {
    local ctx=$1
    [[ -f "$HS_SSID_FILE" ]] && HS_SSID=$(cat "$HS_SSID_FILE") || HS_SSID="MyHotspot"
    [[ -f "$HS_PASS_FILE" ]] && HS_PASS=$(cat "$HS_PASS_FILE") || HS_PASS="password123"

    # Detect hotspot state by checking if the Wi-Fi interface is in AP mode (reliable method)
    local iface
    iface=$(wifi_get_iface)
    local status="OFF"

    # Check if this interface is actively running in AP mode
    if nmcli -t -f IN-USE,MODE device wifi list ifname "$iface" 2>/dev/null | grep -q '^\*:ap$'; then
        status="ON"
    fi


    local opts="$I_BACK Back\n$I_HOTSPOT Toggle Hotspot [$status]\n$I_EDIT Change Name ($HS_SSID)\n$I_EDIT Change Password ($HS_PASS)"
    local sel=$(echo -e "$opts" | run_rofi "Hotspot Settings")

    case "$sel" in
        "") exit 0 ;;
        *"Back") exec "$0" "wifi" "$ctx" ;;
        *"Toggle"*)
            if [[ "$status" == "ON" ]]; then
                nmcli connection down id "$HS_SSID"; notify "Hotspot Stopped"
            else
                # Only create the hotspot connection if it does not exist
                if ! nmcli -t -f NAME connection show | grep -qx "$HS_SSID"; then
                    nmcli con add type wifi ifname "$iface" con-name "$HS_SSID" autoconnect no ssid "$HS_SSID" >/dev/null 2>&1
                    nmcli con modify "$HS_SSID" 802-11-wireless.mode ap 802-11-wireless.band bg ipv4.method shared >/dev/null 2>&1
                    nmcli con modify "$HS_SSID" wifi-sec.key-mgmt wpa-psk wifi-sec.psk "$HS_PASS" >/dev/null 2>&1
                    nmcli connection modify "$HS_SSID" connection.autoconnect yes >/dev/null 2>&1
                fi
                if nmcli connection up id "$HS_SSID"; then notify "Hotspot Started"; else notify "Failed"; fi
            fi
            exec "$0" "wifi" "$ctx" "hotspot"
            ;;
        *"Change Name"*) 
            local val=$(echo "" | run_rofi "New Name" "$THEME_MAIN" -lines 0)
            [[ -n "$val" ]] && echo "$val" > "$HS_SSID_FILE"
            exec "$0" "wifi" "$ctx" "hotspot"
            ;;
        *"Change Password"*)
            local val=$(echo "" | run_rofi "New Password" "$THEME_MAIN" -lines 0)
            [[ -n "$val" ]] && echo "$val" > "$HS_PASS_FILE"
            exec "$0" "wifi" "$ctx" "hotspot"
            ;;
    esac
}

wifi_edit_deep() {
    local profile="$1"; local ctx="$2"
    local iface=$(wifi_get_iface)
    
    local auto=$(nmcli -g connection.autoconnect connection show "$profile" 2>/dev/null || echo "unknown")
    local ip=$(nmcli -g ipv4.method connection show "$profile" 2>/dev/null || echo "unknown")
    
    local opts="$I_BACK Back\n$I_EDIT Toggle Autoconnect [$auto]\n$I_EDIT Set IP Method [$ip]\n$I_EDIT Update Password"
    
    local sel=$(echo -e "$opts" | run_rofi "Edit $profile")
    case "$sel" in
        "") exit 0 ;;
        *"Back") wifi_edit_menu "$profile" "$ctx" ;;
        *"Autoconnect"*) 
            [[ "$auto" == "yes" ]] && nmcli connection modify "$profile" connection.autoconnect no || nmcli connection modify "$profile" connection.autoconnect yes
            wifi_edit_deep "$profile" "$ctx" ;;
        *"IP Method"*)
            local m=$(echo -e "auto\nmanual" | run_rofi "Select IP Method" "$THEME_MAIN" -lines 2)
            [[ -n "$m" ]] && nmcli connection modify "$profile" ipv4.method "$m"
            wifi_edit_deep "$profile" "$ctx" ;;
        *"Password"*)
            local p=$(echo "" | run_rofi "New Password" "$THEME_MAIN" -password -lines 0)
            [[ -n "$p" ]] && nmcli connection modify "$profile" wifi-sec.psk "$p"
            wifi_edit_deep "$profile" "$ctx" ;;
    esac
}

wifi_edit_menu() {
    local profile="$1"; local ctx="$2"
    if [[ "$profile" == "Active" ]]; then
        local iface=$(wifi_get_iface)
        profile=$(nmcli -t -f NAME,DEVICE connection show --active | grep ":$iface" | head -n1 | cut -d: -f1)
        [[ -z "$profile" ]] && { notify "No active connection"; exec "$0" "wifi" "$ctx"; }
    fi

    local iface=$(wifi_get_iface)
    local active_profile=$(nmcli -t -f NAME,DEVICE connection show --active | grep ":$iface" | head -n1 | cut -d: -f1)
    
    local opts="$I_BACK Back\n"
    [[ "$profile" != "$active_profile" ]] && opts+="$I_CHECK Connect (Direct)\n"
    opts+="$I_EXIT Disconnect\n$I_EDIT Edit Settings\n$I_WARN Forget Network"
    
    local sel=$(echo -e "$opts" | run_rofi "$profile Options")
    case "$sel" in
        "") exit 0 ;;
        *"Back") exec "$0" "wifi" "$ctx" ;;
        *"Connect") nmcli connection up id "$profile"; notify "Connected"; exec "$0" "wifi" "$ctx" ;;
        *"Disconnect") nmcli device disconnect "$(wifi_get_iface)"; notify "Disconnected"; exec "$0" "wifi" "$ctx" ;;
        *"Forget") nmcli connection delete id "$profile"; notify "Forgot $profile"; exec "$0" "wifi" "$ctx" ;;
        *"Edit Settings") wifi_edit_deep "$profile" "$ctx" ;;
    esac
}

wifi_connect_menu() {
    local ssid="$1"; local secure="$2"; local ctx="$3"
    
    local opts="$I_BACK Back\n$I_CHECK Connect\n$I_WARN Forget Network"
    local sel=$(echo -e "$opts" | run_rofi "$ssid Actions")
    
    case "$sel" in
        "") exit 0 ;;
        *"Back") exec "$0" "wifi" "$ctx" ;;
        *"Forget") nmcli connection delete id "$ssid"; notify "Forgot $ssid"; exec "$0" "wifi" "$ctx" ;;
        *"Connect")
            if nmcli -t -f NAME connection show | grep -q "^$ssid$"; then
                notify "Connecting saved: $ssid"; nmcli connection up id "$ssid"
            elif [[ "$secure" == "true" ]]; then
                local pass=$(echo "" | run_rofi "Password for $ssid" "$THEME_MAIN" -password -lines 0)
                if [[ -n "$pass" ]]; then
                    notify "Connecting $ssid..."; nmcli device wifi connect "$ssid" password "$pass"
                else
                    wifi_connect_menu "$ssid" "$secure" "$ctx"; return
                fi
            else
                notify "Connecting Open: $ssid"; nmcli device wifi connect "$ssid"
            fi
            sleep 2; exec "$0" "wifi" "$ctx" ;;
    esac
}

module_wifi() {
    local ctx="$1"
    local submode="${2:-}"
    
    if [[ "$submode" == "hotspot" ]]; then
        wifi_hotspot_menu "$ctx"
        return
    fi

    local header=""
    [[ "$ctx" == "menu" ]] && header="$I_BACK  Back\n"
    header+="$I_HOTSPOT  Hotspot Settings\n$I_REFRESH  Scan Networks\n----------------------"
    
    local wired=$(nmcli -t -f DEVICE,TYPE,STATE,CONNECTION device | awk -F: -v i="$I_ETH" -v c="$I_CHECK" '$2=="ethernet" && $3=="connected"{print c"  "i"  Wired: "$4" (Connected)"}')
    
    local wifilist=$(nmcli -t -f ACTIVE,SSID,SIGNAL,BARS,SECURITY,RATE device wifi list --rescan no 2>/dev/null | sort -t: -k3 -nr | awk -F: -v lock="$I_LOCK" -v check="$I_CHECK" '{if ($2=="") next; if (seen[$2]++) next; icon = ($3 > 75) ? "󰤨" : ($3 > 50) ? "󰤢" : ($3 > 25) ? "󰤟" : "󰤯"; sec = ($5!="" && $5!="--") ? lock : "  "; if ($1=="yes") print check"  "icon"  "$2"  ("$3"%)  ["$6"]"; else print "   "icon" "sec" "$2"  ("$3"%)"}')
    
    if [[ -z "$wifilist" ]]; then
       nmcli device wifi rescan
       wifilist=$(nmcli -t -f ACTIVE,SSID,SIGNAL,BARS,SECURITY,RATE device wifi list --rescan no 2>/dev/null | sort -t: -k3 -nr | awk -F: -v lock="$I_LOCK" -v check="$I_CHECK" '{if ($2=="") next; if (seen[$2]++) next; icon = ($3 > 75) ? "󰤨" : ($3 > 50) ? "󰤢" : ($3 > 25) ? "󰤟" : "󰤯"; sec = ($5!="" && $5!="--") ? lock : "  "; if ($1=="yes") print check"  "icon"  "$2"  ("$3"%)  ["$6"]"; else print "   "icon" "sec" "$2"  ("$3"%)"}')
    fi

    local content="$header"
    [[ -n "$wired" ]] && content+="\n$wired"
    [[ -n "$wifilist" ]] && content+="\n$wifilist"
    [[ $(nmcli radio wifi) == "disabled" ]] && content+="\n$I_WARN Enable Wi-Fi"

    local sel=$(echo -e "$content" | run_rofi "Wi-Fi Networks")
    
    case "$sel" in
        "") exit 0 ;;
        *"Back") exec "$0" ;;
        
        # FIX: Explicit full string match
        *"Hotspot Settings"*) wifi_hotspot_menu "$ctx" ;;
        *"Scan Networks"*) 
            notify "Scanning for new networks..."
            nmcli device wifi rescan
            exec "$0" "wifi" "$ctx" 
            ;;
            
        *"Enable Wi-Fi") nmcli radio wifi on; exec "$0" "wifi" "$ctx" ;;
        *"$I_CHECK"*) wifi_edit_menu "Active" "$ctx" ;;
        *)
            local raw=$(echo "$sel" | sed "s/^   .[^ ]* . //; s/  (.*)$//")
            local sec="false"; [[ "$sel" == *"$I_LOCK"* ]] && sec="true"
            
            # FIX: Fallthrough Guard - Do NOT allow Hotspot/Scan text to pass as SSID
            if [[ "$raw" == *"Scan Networks"* || "$raw" == *"Hotspot Settings"* || -z "$raw" ]]; then
                exec "$0" "wifi" "$ctx"
            else
                wifi_connect_menu "$raw" "$sec" "$ctx"
            fi
            ;;
    esac
}

# ==============================================================================
# MAIN MENU
# ==============================================================================
main_menu() {
    local w_status="Disconnected"; command -v nmcli &>/dev/null && { w=$(nmcli -t -f NAME connection show --active | head -n1); [[ -n "$w" ]] && w_status="$w"; }
    local b_status="Off"; command -v bluetoothctl &>/dev/null && bluetoothctl show | grep -q "Powered: yes" && b_status="On"

    local opts=""
    opts+="$I_WIFI  Wi-Fi: $w_status\n"
    opts+="$I_BT  Bluetooth: $b_status\n"
    opts+="$I_VITAL  System Vitals\n"
    opts+="$I_THEME  Appearance\n"
    opts+="----------------------\n"
    opts+="󰂛  Do Not Disturb\n"
    opts+="󰅶  Caffeine\n"
    opts+="󰽥  Focus Mode\n"
    opts+="󰄜  LocalSend\n"
    opts+="󰀵  Software Store\n"
    opts+="󰄜  KDE Connect\n"
    opts+="󰆍  Hyprland Config"

    local choice=$(echo -e "$opts" | run_rofi "Control Center")

    case "$choice" in
        "") exit 0 ;;
        *"Wi-Fi"*)         exec "$0" "wifi" "menu" ;;
        *"Bluetooth"*)     exec "$0" "bt" "menu" ;;
        *"System Vitals"*) exec "$0" "vitals" "vitals" "menu" ;;
        *"Appearance"*)    exec "$0" "themes" "menu" ;;
        
        *"Do Not Disturb"*) "$SCRIPTS_DIR/toggle-dnd.sh" ;;
        *"Caffeine"*)       "$SCRIPTS_DIR/toggle-caffeine.sh" ;;
        *"Focus Mode"*)     "$SCRIPTS_DIR/toggle-focus-mode.sh" ;;
        *"LocalSend"*)      flatpak run org.localsend.localsend_app 2>/dev/null || localsend_app 2>/dev/null & ;;
        *"Software Store"*) flatpak run org.gnome.Software 2>/dev/null || gnome-software & ;;
        *"KDE Connect"*)    kdeconnect-app & ;;
        *"Hyprland Config"*) code ~/.config/hyprland & ;;
    esac
}

# --- ARGUMENT ROUTER ---
MODE="${1:-main}"
ARG2="${2:-}"
ARG3="${3:-}"

case "$MODE" in
    "wifi") module_wifi "$ARG2" "$ARG3" ;;
    "bt") module_bluetooth "$ARG2" ;;
    "vitals") module_vitals "$ARG2" "$ARG3" ;;
    "themes") menu_themes "$ARG2" ;;
    *) main_menu ;;
esac