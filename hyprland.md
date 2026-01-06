# Hyprland Configuration Documentation

```
╔══════════════════════════════════════════════════════════════╗
║                                                              ║
║  ██╗  ██╗██╗   ██╗██████╗ ██████╗ ██╗      █████╗ ███╗   ██╗ ║
║  ██║  ██║╚██╗ ██╔╝██╔══██╗██╔══██╗██║     ██╔══██╗████╗  ██║ ║
║  ███████║ ╚████╔╝ ██████╔╝██████╔╝██║     ███████║██╔██╗ ██║ ║
║  ██╔══██║  ╚██╔╝  ██╔═══╝ ██╔══██╗██║     ██╔══██║██║╚██╗██║ ║
║  ██║  ██║   ██║   ██║     ██║  ██║███████╗██║  ██║██║ ╚████║ ║
║  ╚═╝  ╚═╝   ╚═╝   ╚═╝     ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═══╝ ║
║                                                              ║
║                     My Hyprland Dots                         ║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝
```

A comprehensive guide to this Hyprland window manager setup with custom configurations, scripts, and aesthetic enhancements.

---

## Table of Contents

1. [Overview](#overview)
2. [File Structure](#file-structure)
3. [Core Configuration Files](#core-configuration-files)
4. [Keybindings](#keybindings)
5. [Features & Scripts](#features--scripts)
6. [Waybar Integration](#waybar-integration)
7. [Visual Aesthetics](#visual-aesthetics)
8. [Required Packages & Dependencies](#required-packages--dependencies)
9. [System Components](#system-components)

---

## Overview

This is a fully customized **Hyprland** wayland compositor setup with:

- **Window Manager**: Hyprland (Wayland-native, GPU accelerated)
- **Status Bar**: Waybar with custom modules
- **Application Launcher**: Wofi with fuzzy search
- **Lock Screen**: Hyprlock with custom styling
- **Idle Management**: Hypridle with 5/10 min auto-lock
- **Theme**: Dark theme with pastel steel blue accents (#A2B6C9)
- **Font**: JetBrains Mono Nerd Font for icons and text

---

## File Structure

```
~/.config/hyprland/
├── README.md                          # Project overview
├── hyprland.md                        # This documentation
├── hypr/
│   ├── hyprland.conf                  # Main Hyprland config
│   ├── hypridle.conf                  # Idle & sleep config
│   ├── hyprlock.conf                  # Lock screen config
│   ├── rofi/
│   │   └── wallpaper.rasi             # Rofi theme for wallpaper picker
│   └── scripts/                       # Automation & utility scripts
│       ├── auto-caffeine.sh           # Auto-enable caffeine on media/fullscreen
│       ├── battery-notify.sh          # Battery status notifications
│       ├── brightness-osd.sh          # Brightness level OSD
│       ├── control-panel-enhanced.sh  # Settings menu with Focus Mode
│       ├── control-panel.sh           # Alternate settings menu
│       ├── current-wallpaper.sh       # Wallpaper management
│       ├── disable-caffeine-on-lock.sh# Caffeine disable on lock
│       ├── kbd-backlight-monitor.sh   # Keyboard backlight monitoring
│       ├── keyboard-backlight.sh      # Keyboard backlight toggle
│       ├── media-lock-pause.sh        # Pause media on lock
│       ├── mic-mute-toggle.sh         # Microphone mute toggle
│       ├── ocr-screenshot.sh          # OCR from screenshot
│       ├── quick-settings.sh          # Quick settings toggle
│       ├── toggle-caffeine.sh         # Toggle caffeine mode
│       ├── toggle-dnd.sh              # Toggle Do Not Disturb
│       ├── toggle-focus-mode.sh       # Toggle Focus Mode (DND+Caffeine)
│       ├── usb-monitor.sh             # USB device monitoring
│       ├── volume-osd.sh              # Volume level OSD
│       └── wallpaper-picker.sh        # Interactive wallpaper selector
├── waybar/
│   ├── config.jsonc                   # Waybar modules & settings
│   ├── config.jsonc.backup            # Backup of waybar config
│   ├── style.css                      # Waybar styling
│   └── scripts/
│       ├── caffeine-indicator.sh      # Caffeine mode indicator
│       ├── clipboard.sh               # Clipboard history manager
│       ├── dnd-status.sh              # DND status indicator
│       ├── focus-mode-indicator.sh    # Focus Mode status
│       ├── gpu-usage.sh               # GPU usage display
│       ├── kdeconnect-status.sh       # KDE Connect status
│       ├── mic-indicator.sh           # Microphone activity indicator
│       ├── mic-muted.sh               # Mic mute status
│       ├── notification-logger.sh     # Notification history
│       ├── notifications-icon.sh      # Notification icon display
│       ├── notifications-menu.sh      # Notification menu
│       └── screen-record.sh           # Screen recording indicator
├── wofi/
│   ├── config                         # Wofi launcher config
│   └── style.css                      # Wofi styling
├── wlogout/
│   ├── layout.json                    # Logout menu layout
│   ├── style.css                      # Logout menu styling
│   └── icons/                         # Logout menu icons
└── rofi/
    └── wallpaper.rasi                 # Wallpaper picker theme
```

---

## Core Configuration Files

### 1. **hyprland.conf** - Main Window Manager Configuration

**Location**: `hypr/hyprland.conf`

#### Environment Variables
```properties
XDG_SESSION_TYPE=wayland         # Use Wayland protocol
XDG_CURRENT_DESKTOP=Hyprland     # Set current desktop
XCURSOR_SIZE=24                  # Cursor size
HYPRLAND_NO_QTUTILS=1            # Disable Qt utilities
QT_QPA_PLATFORMTHEME=qt6ct       # Use Qt6 theme
```

#### Monitor Setup
- **Auto-detect**: `monitor = ,preferred,auto,1`
- Resolution and refresh rate automatically detected
- Multi-monitor support with auto-arrangement

#### Input Configuration
- **Keyboard**: US layout
- **Numlock**: Enabled by default
- **Mouse Sensitivity**: -0.1 (slight reduction)
- **Touchpad**: Natural scrolling enabled
- **Cursor**: Software rendering (no hardware cursor)

#### General Layout Settings
```
Layout: Dwindle (tree-based layout)
Gaps (inner): 4px
Gaps (outer): 10px
Border size: 2px
Active border: #A2B6C9 (pastel steel blue)
Inactive border: #45475a (dark gray)
```

#### Decoration & Effects
- **Rounding**: 0px (sharp corners)
- **Blur**: Enabled (5px size, 2 passes)
- **Shadows**: Enabled (15px range, power 2)
- **Shadow Color**: rgba(0, 0, 0, 0.4) (40% opacity black)

#### Animations
| Animation | Duration | Bezier | Effect |
|-----------|----------|--------|--------|
| Windows | 1s | Smooth | Slide |
| Layers | 1s | Fast | Fade |
| Workspaces | 1s | Smooth | Slide |
| Special Workspace | 1s | Smooth | Vertical Slide |

#### Window Rules
- **Floating dialogs**: File open/save/select, system utilities
- **Picture-in-Picture**: Floated, pinned, no border, 40% size, bottom-right position
- **Calculators & Clocks**: Centered, floated, 400x500px
- **Auto-workspace assignment**:
  - Workspace 2: Slack, Discord, Vesktop
  - Workspace 3: Spotify

#### Autostart Applications
```bash
dunst                                      # Notification daemon
waybar                                     # Status bar
nm-applet, blueman-applet                 # Network/Bluetooth
swww-daemon                               # Wallpaper daemon
hyprlock                                  # Lock screen
easyeffects --gapplication-service        # Audio effects
hypridle                                  # Idle management
tlp                                       # Power management
cliphist                                  # Clipboard history
Battery notify, USB monitor, Media pause  # Custom scripts
Auto-caffeine, Keyboard backlight monitor # Custom scripts
```

---

### 2. **hypridle.conf** - Idle & Sleep Configuration

**Location**: `hypr/hypridle.conf`

Manages automatic idle state handling:

```
Listener 1: 5 minutes (300s)  → Lock screen (hyprlock)
Listener 2: 10 minutes (600s) → Turn off display (DPMS)
```

**Features**:
- Runs custom script to disable caffeine before locking
- Auto-resumes display on activity
- Respects "Caffeine Mode" state files to skip idle

---

### 3. **hyprlock.conf** - Lock Screen Configuration

**Location**: `hypr/hyprlock.conf`

Beautiful lock screen with:

#### Visual Design
- **Background**: Current wallpaper blurred (3 passes, 6px blur)
- **Brightness**: 0.65 (darkened)
- **Contrast**: 0.95
- **Vibrancy**: 0.05 (subtle effect)

#### Display Elements
1. **Clock**: 
   - Time format: HH:MM (24-hour)
   - Font: JetBrains Mono ExtraBold
   - Size: 100px
   - Position: Top center, 100px offset

2. **Date**: 
   - Format: Day, DD Month
   - Font: JetBrains Mono
   - Size: 18px
   - Position: Top center, 250px offset

3. **Password Input Field**:
   - Size: 240x42px
   - Border: 1px outline, 6px rounding
   - Placeholder: •
   - Colors:
     - Outer: rgba(255,255,255,0.25)
     - Inner: rgba(0,0,0,0.35)
     - Text: rgba(255,255,255,1)
     - Fail: rgba(255,120,120,0.6)

---

## Keybindings

All keybindings use `SUPER` (Windows/Cmd key) as the main modifier.

### Application Launchers

| Keybind | Action | Description |
|---------|--------|-------------|
| `Super + Return` | `kitty` | Open terminal |
| `Super + B` | `zen-browser` | Open web browser |
| `Super + period` | `nautilus` | Open file manager |
| `Ctrl + Space` | `wofi --show drun` | Application launcher |
| `Super + W` | wallpaper-picker.sh | Interactive wallpaper picker |
| `Super + I` | control-panel-enhanced.sh | Settings panel with Focus Mode |

### Window Management

| Keybind | Action | Description |
|---------|--------|-------------|
| `Super + Q` | Kill window | Close active window |
| `Super + V` | Toggle float & center | Float/unfloat and center window |
| `Super + P` | Pseudo tile | Toggle pseudo-tile mode |
| `Super + J` | Toggle split | Toggle split direction |
| `Super + F` | Fullscreen (0) | Fullscreen without border |
| `Super + Shift + F` | Fullscreen (1) | Fullscreen with border |
| `Super + M` | Fullscreen (1) | Alias for fullscreen |

### Focus Navigation (Arrow Keys)

| Keybind | Action |
|---------|--------|
| `Super + ←/→/↑/↓` | Move focus in direction |

### Window Resizing

| Keybind | Action |
|---------|--------|
| `Super + Shift + ←` | Resize -20px width |
| `Super + Shift + →` | Resize +20px width |
| `Super + Shift + ↑` | Resize -20px height |
| `Super + Shift + ↓` | Resize +20px height |

### Workspace Navigation (1-0)

| Keybind | Action | Description |
|---------|--------|-------------|
| `Super + [1-0]` | Switch workspace | Jump to workspace 1-10 |
| `Super + Shift + [1-0]` | Move window to workspace | Send active window to workspace |
| `Super + Ctrl + [1-0]` | Move & follow window | Move window and follow it |

### Screenshot & Screen Recording

| Keybind | Action | Description |
|---------|--------|-------------|
| `Print` | Full screenshot | Capture entire screen → clipboard & ~/Pictures/Screenshots/ |
| `Super + Shift + S` | Region screenshot | Select area → clipboard & ~/Pictures/Screenshots/ |

### Media & Brightness Controls

| Keybind | Device | Action |
|---------|--------|--------|
| `XF86AudioRaiseVolume` | Volume | Increase 5% + OSD |
| `XF86AudioLowerVolume` | Volume | Decrease 5% + OSD |
| `XF86AudioMute` | Volume | Toggle mute + OSD |
| `XF86MonBrightnessUp` | Display | Increase brightness + OSD |
| `XF86MonBrightnessDown` | Display | Decrease brightness + OSD |
| `XF86AudioMicMute` / `F9` | Microphone | Toggle mute + notification |
| `XF86KbdBrightnessUp/Down` | Keyboard | Adjust keyboard backlight |
| `XF86AudioPlay` | Media | Play/pause |
| `XF86AudioNext` | Media | Next track |
| `XF86AudioPrev` | Media | Previous track |
| `XF86PowerOff` | System | Suspend to sleep |

### Utilities & Special Functions

| Keybind | Action | Description |
|---------|--------|-------------|
| `Super + L` | hyprlock | Lock screen immediately |
| `Super + Escape` | wlogout | Open logout menu |
| `Super + Shift + Escape` | exit | Exit Hyprland |
| `Super + Shift + V` | Clipboard menu | Show clipboard history (wofi) |
| `Super + E` | rofimoji | Open emoji picker |
| `Super + C` | hyprpicker | Color picker |
| `Super + Shift + T` | ocr-screenshot.sh | OCR from selected area |

### Mouse Bindings

| Keybind | Action | Description |
|---------|--------|-------------|
| `Super + Mouse:272` (Left) | Move window | Drag to move |
| `Super + Mouse:273` (Right) | Resize window | Drag to resize |

---

## Features & Scripts

### 1. **Caffeine Mode** (Keep-Awake)

**Files**:
- `toggle-caffeine.sh` - Main toggle script
- `auto-caffeine.sh` - Auto-enable on media/fullscreen
- `caffeine-indicator.sh` - Waybar indicator
- `disable-caffeine-on-lock.sh` - Auto-disable on lock
- Cache file: `~/.cache/caffeine-state`

**Features**:
- Manually toggle via `toggle-caffeine.sh` or waybar click
- **Auto-enable** when:
  - Media player is running
  - Window is in fullscreen mode
- **Auto-disable** when conditions stop
- Integrates with hypridle service via systemd signals

**Keybind**: Waybar module or `toggle-caffeine.sh`

---

### 2. **Focus Mode** (Deep Work)

**Files**:
- `toggle-focus-mode.sh` - Main toggle
- `focus-mode-indicator.sh` - Waybar display
- Cache file: `~/.cache/focus-mode-state`

**Enables simultaneously**:
- Do Not Disturb (mutes all notifications)
- Caffeine Mode (prevents sleep)

**Status**: Displayed in waybar with 󰽥 icon

**Keybind**: 
- Waybar module click
- Quick settings menu (`Super + I`)

---

### 3. **Do Not Disturb** (DND)

**Files**:
- `toggle-dnd.sh` - Toggle script
- `dnd-status.sh` - Status indicator
- Cache file: `~/.cache/dnd-state`

**Features**:
- Pauses all notifications via dunstctl
- Shows notification before pausing
- Visual indicator in waybar

**Keybind**: Quick settings menu (`Super + I`)

---

### 4. **Battery Management**

**Files**:
- `battery-notify.sh` - Continuous monitoring

**Notifications**:
| Level | Condition | Frequency |
|-------|-----------|-----------|
| 80%+ | Not charging | Once per session |
| 20% | Discharging | Once per 10 minutes |
| 10% | Discharging | Every 2 minutes |
| ≤10% | Critical | Every 2 minutes |

**Features**:
- Ignores DND when critical
- Persistent lock file to prevent multiple instances

---

### 5. **Brightness & Volume OSD**

**Files**:
- `brightness-osd.sh` - Display OSD on brightness change
- `volume-osd.sh` - Display OSD on volume change

**Display**:
- Integrated dunst notification with progress bar
- Auto-hides after 1 second
- Shows percentage value

---

### 6. **Microphone Management**

**Files**:
- `mic-mute-toggle.sh` - Toggle mic mute
- `mic-indicator.sh` - Waybar indicator showing apps using mic
- `mic-muted.sh` - Mute status display

**Features**:
- Real-time detection of microphone activity
- Shows which app is using the mic
- Toggle via `F9` or `XF86AudioMicMute`
- Notification on state change

---

### 7. **Keyboard Backlight**

**Files**:
- `keyboard-backlight.sh` - Brightness control
- `kbd-backlight-monitor.sh` - Continuous monitoring

**Controls**:
- `XF86KbdBrightnessUp` - Increase brightness
- `XF86KbdBrightnessDown` - Decrease brightness

---

### 8. **Wallpaper Management**

**Files**:
- `wallpaper-picker.sh` - Interactive selector
- `current-wallpaper.sh` - Query current wallpaper
- `/tmp/hypr-wallpaper` - Cache directory

**Features**:
- Rofi-based interactive picker with thumbnail previews
- Parallel thumbnail generation (4 workers)
- Smooth fade transition (0.8s duration)
- Scans `~/Downloads/walls/` directory
- Caches current wallpaper to `~/.cache/current_wallpaper`

**Keybind**: `Super + W`

---

### 9. **OCR from Screenshot**

**Files**:
- `ocr-screenshot.sh`

**Dependencies**:
- `tesseract` (OCR engine)
- `grim` (Wayland screenshot)
- `slurp` (Area selection)

**Workflow**:
1. User selects area with `slurp`
2. Screenshot captured with `grim`
3. Text extracted via `tesseract`
4. Result copied to clipboard
5. First line displayed in notification

**Keybind**: `Super + Shift + T`

---

### 10. **USB Device Monitoring**

**Files**:
- `usb-monitor.sh`

Continuously monitors for USB device changes and notifies user.

---

### 11. **Media Pause on Lock**

**Files**:
- `media-lock-pause.sh`

Automatically pauses all media players when screen locks using `playerctl`.

---

### 12. **Clipboard History**

**Files**:
- `clipboard.sh` (Waybar integration)

**Features**:
- Managed by `cliphist`
- Both text and image history
- Wofi menu to browse/restore
- Right-click to wipe history

**Keybind**: `Super + Shift + V` (show menu)

---

### 13. **Screen Recording Indicator**

**Files**:
- `screen-record.sh`

Detects active recording by looking for processes:
- `gpu-screen-recorder`
- `obs`
- `ffmpeg`
- `wf-recorder`
- `screenkey`

Displays 󰻃 REC in waybar when recording.

---

---

## Waybar Integration

**Location**: `waybar/config.jsonc` and `waybar/style.css`

Waybar is the status bar displaying system information and custom indicators.

### Bar Configuration

```jsonc
layer: "top"
position: "top"
exclusive: true
height: 34px
margins: 6px (top), 8px (sides)
```

### Module Layout

#### Left Section (Workspaces & Window)
| Module | Purpose |
|--------|---------|
| `hyprland/workspaces` | Workspace switcher (I-X numbering) |
| `hyprland/window` | Active window title (max 50 chars) |

#### Center Section (Clock & Media)
| Module | Purpose |
|--------|---------|
| `custom/notifications` | Notification icon & count |
| `clock` | Date/time with calendar |
| `mpris` | Now playing (Spotify, VLC, etc.) |

#### Right Section (System & Status)
| Module | Purpose |
|--------|---------|
| `custom/screen-record` | Recording indicator |
| `custom/mic-indicator` | Microphone activity |
| `custom/mic-muted` | Mute status |
| `custom/caffeine` | Caffeine mode status |
| `custom/focus-mode` | Focus Mode status |
| `cpu` | CPU usage % |
| `temperature` | CPU temperature |
| `memory` | RAM usage |
| `pulseaudio` | Volume % |
| `network` | Network connection |
| `bluetooth` | Bluetooth status |
| `battery` | Battery % |

### Module Details

#### Clock
```jsonc
format: "{:%H:%M}"                    // 24-hour time
format-alt: "{:%A, %d %b %Y}"         // Full date
calendar: year mode with custom colors
tooltip: Interactive calendar
```

#### Media Player (MPRIS)
```jsonc
players: Spotify, VLC, MPV, Firefox
format: "{player_icon} {dynamic}"
actions:
  - Click: Play/pause
  - Scroll up: Next track
  - Scroll down: Previous track
```

#### CPU
```jsonc
interval: 2s
format: "󰍛 {usage}%"
on-click: "kitty -e btop"              // Open system monitor
```

#### Battery
```jsonc
States:
  critical: ≤15%  (red)
  warning: ≤30%   (yellow)
  full: 100%      (green)
  charging:       (gold)
  plugged:        (green)
```

#### Network
```jsonc
format: "{icon}"                       // Wifi icon
tooltip: SSID, signal strength, IP address
on-click: "nm-connection-editor"
```

#### Bluetooth
```jsonc
format: Shows connected device count
tooltip: Connected device names
on-click: "blueman-manager"
```

#### Pulseaudio
```jsonc
format: "{icon} {volume}%"
scroll-step: 5%
on-click: Toggle mute
on-click-right: "pavucontrol"
```

#### Custom Modules

**Caffeine Indicator**:
- Executes: `~/.config/hyprland/waybar/scripts/caffeine-indicator.sh`
- Output: ☕ icon (only when active AND focus mode off)
- On-click: Toggles caffeine mode

**Focus Mode Indicator**:
- Executes: `~/.config/hyprland/waybar/scripts/focus-mode-indicator.sh`
- Output: 󰽥 icon (only when active)
- On-click: Toggles focus mode

**Notifications**:
- Executes: `~/.config/hyprland/waybar/scripts/notifications-icon.sh`
- Dynamic notification count display

**Screen Recording**:
- Executes: `~/.config/hyprland/waybar/scripts/screen-record.sh`
- Shows: 󰻃 REC (when recording)

**Microphone Indicator**:
- Shows active microphone with app names
- Updates every 1 second
- Shows notification on activation

---

## Visual Aesthetics

### Color Scheme

The setup uses a **dark theme with pastel blue accents**:

| Element | Color | Hex | Usage |
|---------|-------|-----|-------|
| Primary Accent | Pastel Steel Blue | #A2B6C9 | Active elements, highlights |
| Primary BG | Off-Black | #14 1414 | Main background |
| Secondary BG | Dark Gray | #1e1e1e | Input fields, panels |
| Border/Separator | Light Gray | #45475a | Window/panel dividers |
| Text Primary | Off-White | #E3E6E8 | Main text |
| Text Muted | Medium Gray | #7F8490 | Inactive text |
| Success/Health | Soft Green | #8db8a8 | Positive indicators |
| Warning/Caution | Soft Yellow | #d9c88a | Battery warnings |
| Critical/Error | Soft Red | #d99a9a | Low battery, errors |

### Typography

**Font Stack**: `JetBrains Mono Nerd Font > JetBrains Mono > Sans-serif`

**Font Sizes**:
- Waybar: 15px (base), 16px (modules)
- Lock screen clock: 100px
- Lock screen date: 18px
- Wofi/Rofi: 15px
- Wlogout: 14px

**Font Weights**:
- Light: Clock (24h), regular text
- Bold: Window titles, active indicators
- ExtraBold: Lock screen time display

### Nerd Font Icons

Extensively uses Nerd Font icons for visual clarity:

- 󰁹 Battery
- 󰝟 Volume muted
- 󰍛 CPU
- 󰟜 Memory
- 󰎵 Media player
- 󰽥 Focus mode
- 󰍬 Microphone
- 󰄋 Car mode
- 󰽥 Focus indicator
- And many more...

### Border & Rounding

- **Borders**: 2px on windows, 1px on UI elements
- **Rounding**: 0px (sharp corners) throughout
- **Gaps**: 4px inner, 10px outer (Dwindle layout)

### Animations

Smooth animations with custom bezier curves:

```
Smooth Curve: (0.05, 0.9, 0.1, 1.0)
Fast Curve: (0.0, 0.6, 0.4, 1.0)

Duration: 1s for windows, layers, workspaces
         2s for fade effects
```

### Opacity & Transparency

- **Waybar**: rgba(20, 20, 20, 0.92) - 92% opaque dark background
- **Wofi/Wlogout**: rgba(20, 20, 20, 0.92) - Consistent styling
- **Window Shadow**: rgba(0, 0, 0, 0.4) - 40% black shadow
- **Blur passes**: 2-3 passes for smooth effect

---

## Required Packages & Dependencies

### Core Window Manager & Display
- `hyprland` - Wayland compositor
- `hyprlock` - Lock screen
- `hypridle` - Idle manager
- `wayland` - Wayland protocol
- `libxwayland0` - X11 compatibility

### Panel & Launchers
- `waybar` - Status bar
- `wofi` - Application launcher
- `rofi` - Application/menu launcher
- `wlogout` - Logout menu

### Notification System
- `dunst` - Notification daemon

### System Utilities
- `brightnessctl` - Brightness control
- `playerctl` - Media control
- `wpctl` - PulseAudio volume control
- `pamixer` - Pulse audio mixer
- `pavucontrol` - PulseAudio GUI
- `btop` - System monitor (terminal)
- `grim` - Wayland screenshot
- `slurp` - Area selection tool
- `wl-clipboard` - Clipboard utilities
- `wl-paste` - Clipboard read
- `cliphist` - Clipboard history

### Network & Bluetooth
- `nm-applet` - Network Manager applet
- `blueman` - Bluetooth manager
- `network-manager` - Network management

### Audio & Effects
- `easyeffects` - Audio effects
- `pipewire` or `pulseaudio` - Audio server

### Additional Tools
- `tesseract` - OCR engine (for OCR script)
- `imagemagick` (`magick`) - Image processing
- `flatpak` - For Flatpak apps
- `kdeconnect` - Phone integration
- `swww` - Wallpaper daemon
- `kitty` - GPU-accelerated terminal
- `nautilus` - File manager
- `systemd` - Init system

### Optional (used in setup)
- `zen-browser` - Web browser
- `spotify` or `spotify-tui` - Music player
- `gnome-software` or `discover` - Software store
- `localsend` - Local file sharing
- `tlp` - Power management
- `cuda`/`nvidia` - For GPU support

---

## System Components

### Systemd Integration

Several components use systemd user services:

**hypridle.service**
- Managed by custom scripts
- Signals: SIGUSR1 (start), SIGUSR2 (stop)
- Controlled by caffeine/focus mode scripts

**User Services Started at Boot**:
- `easyeffects.service` - Audio effects
- `tlp.service` - Power management
- Dbus services for bluetooth, network, etc.

### File Permissions

Scripts require executable permissions:
```bash
chmod +x ~/.config/hyprland/hypr/scripts/*.sh
chmod +x ~/.config/hyprland/waybar/scripts/*.sh
```

### Cache & State Files

Temporary state files stored in `~/.cache/`:
- `caffeine-state` - Caffeine on/off flag
- `focus-mode-state` - Focus mode active flag
- `dnd-state` - Do Not Disturb flag
- `current_wallpaper` - Current wallpaper path
- `wallpicker/` - Wallpaper thumbnail cache

### Session Variables

Important environment variables set at startup:
```bash
XDG_SESSION_TYPE=wayland           # Use Wayland
HYPRLAND_NO_QTUTILS=1              # Disable Qt utilities
QT_QPA_PLATFORMTHEME=qt6ct         # Use Qt6 theme
XCURSOR_SIZE=24                    # Cursor size
```

---

## Advanced Features

### Dwindle Layout

The setup uses **Dwindle** layout (tree-based tiling):
- **Pseudotile**: Windows can simulate tiling while floating
- **Split preservation**: Remembers split direction on new windows
- **Visual organization**: Clear hierarchy of window placement

### Window Rules & Automation

Smart window management rules:
- Dialogs auto-float and center
- Utilities open on specific workspaces
- PiP videos float with fixed size/position
- Workspace auto-assignment for apps

### Multi-Monitor Support

- Auto-detect and arrange monitors
- Seamless wallpaper across displays
- Per-monitor workspace support

### Dynamic Updates

Waybar modules use signals for real-time updates:
- Signal 8: Caffeine mode indicator refresh
- Signal 9: Focus mode indicator refresh
- Interval-based updates for system stats

### Conditional Logic

Scripts use state files for:
- Toggling features (caffeine, DND, focus)
- Preventing duplicate instances
- Persistent settings across sessions

---

## Workflow Examples

### Example 1: Deep Work Session
1. Press `Super + I` (control panel)
2. Select "Focus Mode"
3. Workstation enters deep work:
   - DND mutes all notifications
   - Caffeine prevents sleep
   - Indicator shows in waybar
4. After work, press waybar icon to disable

### Example 2: Media Watching
1. Start playing video
2. `auto-caffeine.sh` detects fullscreen
3. Caffeine auto-enables
4. System won't sleep during playback
5. Automatically disables when video ends

### Example 3: Wallpaper Change
1. Press `Super + W`
2. Rofi opens with thumbnail previews
3. Select wallpaper
4. Smooth fade transition applied
5. Wallpaper cached for lock screen

### Example 4: Quick Settings Access
1. Press `Super + I` (or `Ctrl + I` in control-panel-enhanced.sh)
2. Menu shows options:
   - Wi-Fi (nm-connection-editor)
   - Bluetooth (blueman-manager)
   - DND toggle
   - Caffeine toggle
   - Focus Mode toggle
   - Software Store
   - KDE Connect
   - LocalSend
   - Config opener

---

## Troubleshooting

### Caffeine Not Working
- Check: `[ -f ~/.cache/caffeine-state ] && echo "Active"`
- Verify: `systemctl --user status hypridle`
- Reset: `rm ~/.cache/caffeine-state`

### Microphone Detection Issues
- Check active sources: `pactl list sources short`
- Verify PulseAudio/PipeWire running
- Check script: `~/.config/hyprland/waybar/scripts/mic-indicator.sh`

### Waybar Not Updating
- Restart: `pkill waybar && waybar &`
- Check config: `waybar -c ~/.config/hyprland/waybar/config.jsonc`

### Wallpaper Not Changing
- Verify: `swww-daemon` is running
- Check wallpaper directory: `~/Downloads/walls/`
- Test: `swww img /path/to/image.png`

### Focus Mode Not Working
- Check files exist: `[ -f ~/.cache/focus-mode-state ]`
- Verify dunstctl installed: `which dunstctl`
- Check hypridle signals: `systemctl --user status hypridle`

---

## Tips & Tricks

### Speed Up Wallpaper Switching
Wallpaper picker caches thumbnails. Delete cache to refresh:
```bash
rm -rf ~/.cache/wallpicker/*
```

### View Active Workspace Config
```bash
hyprctl workspaces
```

### Monitor Connected Displays
```bash
hyprctl monitors
```

### Inspect Window Rules
```bash
hyprctl clients
```

### Real-time Performance Monitoring
Open btop in terminal:
```bash
btop
```

### Manual Caffeine Control
```bash
# Enable caffeine
touch ~/.cache/caffeine-state
systemctl --user stop hypridle.service

# Disable caffeine
rm ~/.cache/caffeine-state
systemctl --user start hypridle.service
```

---

## Customization Guide

### Change Color Scheme
Edit color values in:
- `hypr/hyprland.conf` - Border colors
- `waybar/style.css` - Module colors
- `wofi/style.css` - Launcher styling
- `wlogout/style.css` - Logout menu

### Modify Keybindings
Edit `hypr/hyprland.conf` section `# Keybinds`

### Adjust Animations
Modify `animations` section in `hypr/hyprland.conf`

### Change Fonts
Update `font-family` in CSS files

### Customize Workspace Count
Adjust persistent-workspaces in `waybar/config.jsonc`

---

## Performance Notes

- **GPU Acceleration**: Hyprland is fully GPU-accelerated
- **Blur Passes**: 2-3 passes balances quality and performance
- **Animation Framerate**: Synced to monitor refresh rate
- **Memory**: Lightweight compared to X11 setups
- **Battery**: Hypridle + Caffeine system minimizes power draw

---

## Version Information

- **Hyprland**: Latest stable
- **Waybar**: Latest stable
- **Hypridle**: Latest stable
- **Hyprlock**: Latest stable
- **Configuration Format**: TOML (hyprland.conf) + JSON (waybar, wlogout) + CSS (styling)

---

## Additional Resources

- [Hyprland Documentation](https://wiki.hyprland.org)
- [Waybar GitHub](https://github.com/Alexays/Waybar)
- [Hyprland Community](https://discord.gg/hQ9XvMUjjr)

---

## License & Credits

This configuration is a personal setup combining:
- Official Hyprland configurations
- Community scripts and best practices
- Custom automation for workflow efficiency

Feel free to adapt and modify for your needs!

---

**Last Updated**: January 6, 2026
