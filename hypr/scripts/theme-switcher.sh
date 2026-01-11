#!/usr/bin/env bash
THEME_DIR="$HOME/.config/hyprland/themes"
LINK_DIR="$HOME/.config/hyprland/hypr/theme"
VISUALS_CONF="$LINK_DIR/visuals.conf"
ROFI_THEME="$HOME/.config/hyprland/hypr/rofi/theme-switcher.rasi"
APPLY_DUNST="$HOME/.config/hyprland/hypr/scripts/apply-dunst-theme.sh"

[ ! -d "$THEME_DIR" ] && notify-send "Error" "Theme directory not found" -u critical && exit 1

# Always use solid mode
ln -sf "$LINK_DIR/mode_solid.css" "$LINK_DIR/waybar-mode.css"
ln -sf "$LINK_DIR/rofi-mode-solid.rasi" "$LINK_DIR/rofi-mode.rasi"

[ ! -L "$LINK_DIR/colors.conf" ] && {
    DEFAULT_THEME=$(ls -1 "$THEME_DIR" | head -n1)
    [ -n "$DEFAULT_THEME" ] && [ -f "$THEME_DIR/$DEFAULT_THEME/hyprland.conf" ] && {
        ln -sf "$THEME_DIR/$DEFAULT_THEME/hyprland.conf" "$LINK_DIR/colors.conf"
        [ -f "$THEME_DIR/$DEFAULT_THEME/waybar.css" ] && ln -sf "$THEME_DIR/$DEFAULT_THEME/waybar.css" "$LINK_DIR/waybar-colors.css"
        [ -f "$THEME_DIR/$DEFAULT_THEME/rofi.rasi" ] && ln -sf "$THEME_DIR/$DEFAULT_THEME/rofi.rasi" "$LINK_DIR/rofi-colors.rasi"
    }
}

# Get current theme name
CURRENT_COLORS_PATH=$(readlink -f "$LINK_DIR/colors.conf" 2>/dev/null || echo "")
CURRENT_THEME=""
if [[ "$CURRENT_COLORS_PATH" == *"/themes/"* ]]; then
    CURRENT_THEME=$(basename "$(dirname "$CURRENT_COLORS_PATH")")
fi

# Build theme list and mark current with a small circle
THEMES=$(ls -1 "$THEME_DIR" 2>/dev/null)
DISPLAY_LIST=""
while IFS= read -r theme; do
    if [ "$theme" == "$CURRENT_THEME" ]; then
        DISPLAY_LIST+="● $theme\n"
    else
        DISPLAY_LIST+="$theme\n"
    fi
done <<< "$THEMES"

CHOICE=$(echo -e "$DISPLAY_LIST" | rofi -dmenu -i -p "Appearance" -theme "$ROFI_THEME" 2>/dev/null)

# Strip marker if present
CHOICE="${CHOICE/#● /}"

[ -z "$CHOICE" ] && exit 0

if [ -d "$THEME_DIR/$CHOICE" ]; then
    [ ! -f "$THEME_DIR/$CHOICE/hyprland.conf" ] && notify-send "Error" "Theme config missing" -u critical && exit 1
    
    ln -sf "$THEME_DIR/$CHOICE/hyprland.conf" "$LINK_DIR/colors.conf"
    [ -f "$THEME_DIR/$CHOICE/waybar.css" ] && ln -sf "$THEME_DIR/$CHOICE/waybar.css" "$LINK_DIR/waybar-colors.css"
    [ -f "$THEME_DIR/$CHOICE/rofi.rasi" ] && ln -sf "$THEME_DIR/$CHOICE/rofi.rasi" "$LINK_DIR/rofi-colors.rasi"
    
    # Apply dunst theme
    if [ -f "$APPLY_DUNST" ] && [ -f "$THEME_DIR/$CHOICE/dunst.conf" ]; then
        "$APPLY_DUNST" "$CHOICE"
    fi
    
    # Set solid mode
    sed -i 's/active_opacity = .*/active_opacity = 1.0/' "$VISUALS_CONF"
    sed -i 's/inactive_opacity = .*/inactive_opacity = 1.0/' "$VISUALS_CONF"
    sed -i '/blur {/,/}/ s/enabled = true/enabled = false/' "$VISUALS_CONF"
    
    hyprctl reload
    sleep 0.2
    pkill -9 waybar 2>/dev/null
    sleep 0.2
    waybar > /dev/null 2>&1 &
    pkill dunst 2>/dev/null
    sleep 0.2
    dunst & disown
    
    notify-send "Appearance" "Theme: $CHOICE" -t 1500
    exit 0
fi
