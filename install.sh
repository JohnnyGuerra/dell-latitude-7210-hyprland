#!/usr/bin/env bash
# ==============================================================================
# Dell Latitude 7210 2-in-1: Complete Hyprland Tablet & Power Suite Installer
# Author: Johnny Guerra
# Repository: https://github.com/JohnnyGuerra/dell-latitude-7210-hyprland
# ==============================================================================

set -e

GREEN="\033[1;32m"
BLUE="\033[1;34m"
YELLOW="\033[1;33m"
CYAN="\033[1;36m"
RED="\033[1;31m"
RESET="\033[0m"

echo -e "${CYAN}======================================================${RESET}"
echo -e "${CYAN}  Dell Latitude 7210 2-in-1: Hyprland Tablet Suite    ${RESET}"
echo -e "${CYAN}======================================================${RESET}"
echo

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_DIR="${HOME}/.local/bin"
SYSTEMD_USER_DIR="${HOME}/.config/systemd/user"
WAYBAR_DIR="${HOME}/.config/waybar"
WOFI_DIR="${HOME}/.config/wofi"

mkdir -p "${BIN_DIR}" "${SYSTEMD_USER_DIR}" "${WAYBAR_DIR}" "${WOFI_DIR}"

echo -e "${BLUE}[1/7] Checking runtime dependencies...${RESET}"
MISSING_PKGS=()
for cmd in brightnessctl pactl wpctl python3 lisgd; do
    if ! command -v "$cmd" &>/dev/null; then
        MISSING_PKGS+=("$cmd")
    fi
done

if [ ${#MISSING_PKGS[@]} -ne 0 ]; then
    echo -e "${YELLOW}Warning: Missing tools: ${MISSING_PKGS[*]}${RESET}"
    echo -e "On Arch Linux, install with: sudo pacman -S brightnessctl libpulse wireplumber python python-gobject gtk-layer-shell iio-sensor-proxy tlp"
    echo -e "And install lisgd via AUR: yay -S lisgd-git"
fi

echo -e "${BLUE}[2/7] Installing tablet helper scripts to ~/.local/bin...${RESET}"
install -m 755 "${SCRIPT_DIR}/auto-rotate/auto-rotate-daemon.py" "${BIN_DIR}/auto-rotate-daemon.py"
install -m 755 "${SCRIPT_DIR}/auto-rotate/fit-agent-window" "${BIN_DIR}/fit-agent-window"
install -m 755 "${SCRIPT_DIR}/waybar/slider-popup" "${BIN_DIR}/slider-popup"
install -m 755 "${SCRIPT_DIR}/keyboard/keyboard-status" "${BIN_DIR}/keyboard-status"
install -m 755 "${SCRIPT_DIR}/keyboard/keyboard-mode-menu" "${BIN_DIR}/keyboard-mode-menu"
install -m 755 "${SCRIPT_DIR}/keyboard/toggle-keyboard" "${BIN_DIR}/toggle-keyboard"
install -m 755 "${SCRIPT_DIR}/gestures/touch-gestures" "${BIN_DIR}/touch-gestures"
install -m 755 "${SCRIPT_DIR}/system/toggle-eco-mode" "${BIN_DIR}/toggle-eco-mode"
install -m 755 "${SCRIPT_DIR}/system/toggle-refresh-rate" "${BIN_DIR}/toggle-refresh-rate"
echo -e "${GREEN}  ✓ Helper scripts installed successfully.${RESET}"

echo -e "${BLUE}[3/7] Installing systemd user services (auto-rotate & touch-gestures)...${RESET}"
cp "${SCRIPT_DIR}/auto-rotate/auto-rotate.service" "${SYSTEMD_USER_DIR}/auto-rotate.service"
cp "${SCRIPT_DIR}/gestures/touch-gestures.service" "${SYSTEMD_USER_DIR}/touch-gestures.service"
systemctl --user daemon-reload
systemctl --user enable --now auto-rotate.service
systemctl --user enable --now touch-gestures.service
echo -e "${GREEN}  ✓ auto-rotate.service and touch-gestures.service enabled and started.${RESET}"

echo -e "${BLUE}[4/7] Installing hardware backlight & touchscreen udev rules...${RESET}"
if [ -d "/etc/udev/rules.d" ]; then
    sudo cp "${SCRIPT_DIR}/system/90-backlight.rules" /etc/udev/rules.d/90-backlight.rules
    sudo cp "${SCRIPT_DIR}/system/95-touchscreen-uaccess.rules" /etc/udev/rules.d/95-touchscreen-uaccess.rules
    sudo udevadm control --reload-rules && sudo udevadm trigger --subsystem-match=backlight && sudo udevadm trigger --subsystem-match=input
    sudo chmod u+s /usr/bin/brightnessctl 2>/dev/null || true
    sudo usermod -aG video,input "${USER}" 2>/dev/null || true
    echo -e "${GREEN}  ✓ Udev backlight & touchscreen permissions applied.${RESET}"
fi

echo -e "${BLUE}[5/7] Installing 7210 Power Management & Sleep Fixes...${RESET}"
if [ -d "/etc/systemd" ]; then
    sudo mkdir -p /etc/systemd/sleep.conf.d /etc/systemd/logind.conf.d /etc/tlp.d
    # 1. Suspend-then-hibernate (Fixes Dell Latitude S3 sleep firmware hang)
    sudo cp "${SCRIPT_DIR}/system/power/suspend-then-hibernate.conf" /etc/systemd/sleep.conf.d/
    # 2. Folio clamshell lid switch
    sudo cp "${SCRIPT_DIR}/system/power/lid_switch.conf" /etc/systemd/logind.conf.d/
    # 3. TLP battery and charging thresholds
    sudo cp "${SCRIPT_DIR}/system/power/tlp-7210.conf" /etc/tlp.d/00-custom.conf 2>/dev/null || true
    # 4. Intel RAPL power clamping (10W PL1 / 15W PL2 on battery)
    sudo install -m 755 "${SCRIPT_DIR}/system/power/apply-rapl-limits" /usr/local/bin/apply-rapl-limits
    sudo cp "${SCRIPT_DIR}/system/power/rapl-limits.service" /etc/systemd/system/
    sudo sed -i 's|/usr/bin/apply-rapl-limits|/usr/local/bin/apply-rapl-limits|g' /etc/systemd/system/rapl-limits.service
    sudo systemctl daemon-reload
    sudo systemctl enable --now rapl-limits.service 2>/dev/null || true
    echo -e "${GREEN}  ✓ Dell 7210 power management and sleep fixes installed.${RESET}"
fi

echo -e "${BLUE}[6/7] Waybar & Wofi Touch Configuration...${RESET}"
if [ -f "${WAYBAR_DIR}/config.jsonc" ]; then
    echo -e "${CYAN}  Found existing Waybar config.${RESET}"
    read -r -p "  Do you want to backup and install the 54px touch-optimized Waybar config? [y/N]: " REPLY
    if [[ "$REPLY" =~ ^[Yy]$ ]]; then
        cp "${WAYBAR_DIR}/config.jsonc" "${WAYBAR_DIR}/config.jsonc.bak.$(date +%s)"
        cp "${WAYBAR_DIR}/style.css" "${WAYBAR_DIR}/style.css.bak.$(date +%s)" 2>/dev/null || true
        cp "${SCRIPT_DIR}/waybar/config.jsonc" "${WAYBAR_DIR}/config.jsonc"
        cp "${SCRIPT_DIR}/waybar/style.css" "${WAYBAR_DIR}/style.css"
        echo -e "${GREEN}  ✓ Waybar touch config installed.${RESET}"
        pkill -x waybar 2>/dev/null || true
    fi
else
    cp "${SCRIPT_DIR}/waybar/config.jsonc" "${WAYBAR_DIR}/config.jsonc"
    cp "${SCRIPT_DIR}/waybar/style.css" "${WAYBAR_DIR}/style.css"
    echo -e "${GREEN}  ✓ Waybar touch config installed.${RESET}"
fi

# Touch-friendly Wofi launcher
if [ ! -f "${WOFI_DIR}/config" ]; then
    cp "${SCRIPT_DIR}/wofi/config" "${WOFI_DIR}/config"
    cp "${SCRIPT_DIR}/wofi/style.css" "${WOFI_DIR}/style.css"
    echo -e "${GREEN}  ✓ Wofi touch config installed.${RESET}"
fi

# Chrome touch flags
if [ -f "${HOME}/.config/chrome-flags.conf" ]; then
    cp "${SCRIPT_DIR}/browser/chrome-flags.conf" "${HOME}/.config/chrome-flags.conf"
fi

echo -e "${BLUE}[7/7] Hyprland Touch Configuration...${RESET}"
echo -e "  Review ${SCRIPT_DIR}/hyprland/touch-gestures.lua or touch-gestures.conf to add"
echo -e "  touchscreen workspace swiping (workspace_swipe_touch = true) and multi-finger gestures."

echo
echo -e "${GREEN}======================================================${RESET}"
echo -e "${GREEN}  Installation Complete!                              ${RESET}"
echo -e "${GREEN}======================================================${RESET}"
echo -e "Edge Gestures (iPad-style):"
echo -e "  • Swipe UP from bottom edge: Toggle on-screen keyboard (wvkbd)"
echo -e "  • Swipe DOWN from bottom edge: Dismiss on-screen keyboard"
echo -e "  • Swipe DOWN from top edge: Toggle brightness touch slider"
echo -e "  • Swipe LEFT from right edge: Pull out AI Agent scratchpad"
echo -e "  • Swipe RIGHT from left edge: Pull out Touch App Launcher (wofi)"
echo -e "Multi-Finger Gestures:"
echo -e "  • 3-finger horizontal swipe: Seamless workspace transition"
echo -e "  • 3-finger vertical swipe: Toggle AI Agent scratchpad"
echo -e "  • 4-finger vertical swipe: Toggle keyboard"
echo -e "  • 4-finger horizontal swipe: Toggle App Launcher"
echo
