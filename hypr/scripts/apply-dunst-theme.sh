#!/usr/bin/env bash
# Apply dunst theme colors from theme dunst.conf

THEME_NAME="$1"
THEME_DIR="$HOME/.config/hyprland/themes/$THEME_NAME"
DUNST_CONF="$THEME_DIR/dunst.conf"
DUNSTRC="$HOME/.config/dunst/dunstrc"

[ ! -f "$DUNST_CONF" ] && echo "No dunst.conf found for theme $THEME_NAME" && exit 1
[ ! -f "$DUNSTRC" ] && echo "No dunstrc found" && exit 1

# Extract colors from dunst.conf
low_bg=$(grep -A2 "^\[urgency_low\]" "$DUNST_CONF" | grep "background" | sed 's/.*= //;s/"//g')
low_fg=$(grep -A2 "^\[urgency_low\]" "$DUNST_CONF" | grep "foreground" | sed 's/.*= //;s/"//g')
low_frame=$(grep -A2 "^\[urgency_low\]" "$DUNST_CONF" | grep "frame_color" | sed 's/.*= //;s/"//g')

normal_bg=$(grep -A3 "^\[urgency_normal\]" "$DUNST_CONF" | grep "background" | sed 's/.*= //;s/"//g')
normal_fg=$(grep -A3 "^\[urgency_normal\]" "$DUNST_CONF" | grep "foreground" | sed 's/.*= //;s/"//g')
normal_frame=$(grep -A3 "^\[urgency_normal\]" "$DUNST_CONF" | grep "frame_color" | sed 's/.*= //;s/"//g')

critical_bg=$(grep -A3 "^\[urgency_critical\]" "$DUNST_CONF" | grep "background" | sed 's/.*= //;s/"//g')
critical_fg=$(grep -A3 "^\[urgency_critical\]" "$DUNST_CONF" | grep "foreground" | sed 's/.*= //;s/"//g')
critical_frame=$(grep -A3 "^\[urgency_critical\]" "$DUNST_CONF" | grep "frame_color" | sed 's/.*= //;s/"//g')

# Update dunstrc with extracted colors
sed -i "/\[urgency_low\]/,/\[urgency_normal\]/{ s/background = .*/background = \"$low_bg\"/; s/foreground = .*/foreground = \"$low_fg\"/; s/frame_color = .*/frame_color = \"$low_frame\"/ }" "$DUNSTRC"

sed -i "/\[urgency_normal\]/,/\[urgency_critical\]/{ s/background = .*/background = \"$normal_bg\"/; s/foreground = .*/foreground = \"$normal_fg\"/; s/frame_color = .*/frame_color = \"$normal_frame\"/ }" "$DUNSTRC"

sed -i "/\[urgency_critical\]/,/\[battery\]/{ s/background = .*/background = \"$critical_bg\"/; s/foreground = .*/foreground = \"$critical_fg\"/; s/frame_color = .*/frame_color = \"$critical_frame\"/ }" "$DUNSTRC"
