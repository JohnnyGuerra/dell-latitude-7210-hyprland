# Maintainer: Johnny Guerra <johnny.guerra@gmail.com>
pkgname=dell-latitude-7210-hyprland-git
pkgver=r7.dee5094
pkgrel=1
pkgdesc="Turnkey, touch-optimized Hyprland tablet suite & power management for Dell Latitude 7210 2-in-1 on Arch Linux"
arch=('any')
url="https://github.com/JohnnyGuerra/dell-latitude-7210-hyprland"
license=('MIT')
depends=(
    'hyprland'
    'waybar'
    'iio-sensor-proxy'
    'gtk-layer-shell'
    'python'
    'python-gobject'
    'brightnessctl'
    'libpulse'
    'wireplumber'
    'pipewire'
)
optdepends=(
    'lisgd-git: hardware touch edge-swipe gesture recognition daemon'
    'tlp: advanced Linux power and battery life management'
    'wvkbd: on-screen keyboard with one-handed docking support'
    'wofi: application and keyboard mode launcher'
)
makedepends=('git')
provides=('dell-latitude-7210-hyprland')
conflicts=('dell-latitude-7210-hyprland')
source=("git+https://github.com/JohnnyGuerra/dell-latitude-7210-hyprland.git")
sha256sums=('SKIP')

pkgver() {
    cd "${srcdir}/${pkgname%-git}"
    printf "r%s.%s" "$(git rev-list --count HEAD)" "$(git rev-parse --short HEAD)"
}

package() {
    cd "${srcdir}/${pkgname%-git}"

    # Install binaries
    install -Dm755 "auto-rotate/auto-rotate-daemon.py" "${pkgdir}/usr/bin/auto-rotate-daemon"
    install -Dm755 "auto-rotate/fit-agent-window" "${pkgdir}/usr/bin/fit-agent-window"
    install -Dm755 "waybar/slider-popup" "${pkgdir}/usr/bin/slider-popup"
    install -Dm755 "keyboard/keyboard-status" "${pkgdir}/usr/bin/keyboard-status"
    install -Dm755 "keyboard/keyboard-mode-menu" "${pkgdir}/usr/bin/keyboard-mode-menu"
    install -Dm755 "keyboard/toggle-keyboard" "${pkgdir}/usr/bin/toggle-keyboard"
    install -Dm755 "gestures/touch-gestures" "${pkgdir}/usr/bin/touch-gestures"
    install -Dm755 "system/toggle-eco-mode" "${pkgdir}/usr/bin/toggle-eco-mode"
    install -Dm755 "system/toggle-refresh-rate" "${pkgdir}/usr/bin/toggle-refresh-rate"
    install -Dm755 "system/power/apply-rapl-limits" "${pkgdir}/usr/bin/apply-rapl-limits"

    # Install systemd services
    install -Dm644 "auto-rotate/auto-rotate.service" "${pkgdir}/usr/lib/systemd/user/auto-rotate.service"
    sed -i 's|%h/.local/bin/auto-rotate-daemon.py|/usr/bin/auto-rotate-daemon|g' "${pkgdir}/usr/lib/systemd/user/auto-rotate.service"
    install -Dm644 "gestures/touch-gestures.service" "${pkgdir}/usr/lib/systemd/user/touch-gestures.service"
    sed -i 's|/home/johnny/.local/bin/touch-gestures|/usr/bin/touch-gestures|g' "${pkgdir}/usr/lib/systemd/user/touch-gestures.service"
    install -Dm644 "system/power/rapl-limits.service" "${pkgdir}/usr/lib/systemd/system/rapl-limits.service"

    # Install udev and power management configs
    install -Dm644 "system/90-backlight.rules" "${pkgdir}/usr/lib/udev/rules.d/90-backlight.rules"
    install -Dm644 "system/95-touchscreen-uaccess.rules" "${pkgdir}/usr/lib/udev/rules.d/95-touchscreen-uaccess.rules"
    install -Dm644 "system/power/suspend-then-hibernate.conf" "${pkgdir}/usr/lib/systemd/sleep.conf.d/7210-suspend-then-hibernate.conf"
    install -Dm644 "system/power/lid_switch.conf" "${pkgdir}/usr/lib/systemd/logind.conf.d/7210-lid-switch.conf"

    # Install Waybar, Wofi, Hyprland, and TLP presets
    install -Dm644 "waybar/config.jsonc" "${pkgdir}/usr/share/dell-latitude-7210-hyprland/waybar/config.jsonc"
    install -Dm644 "waybar/style.css" "${pkgdir}/usr/share/dell-latitude-7210-hyprland/waybar/style.css"
    install -Dm644 "wofi/config" "${pkgdir}/usr/share/dell-latitude-7210-hyprland/wofi/config"
    install -Dm644 "wofi/style.css" "${pkgdir}/usr/share/dell-latitude-7210-hyprland/wofi/style.css"
    install -Dm644 "browser/chrome-flags.conf" "${pkgdir}/usr/share/dell-latitude-7210-hyprland/browser/chrome-flags.conf"
    install -Dm644 "hyprland/touch-gestures.conf" "${pkgdir}/usr/share/dell-latitude-7210-hyprland/hyprland/touch-gestures.conf"
    install -Dm644 "hyprland/touch-gestures.lua" "${pkgdir}/usr/share/dell-latitude-7210-hyprland/hyprland/touch-gestures.lua"
    install -Dm644 "system/power/tlp-7210.conf" "${pkgdir}/usr/share/dell-latitude-7210-hyprland/system/power/tlp-7210.conf"

    # Install documentation and license
    install -Dm644 "README.md" "${pkgdir}/usr/share/doc/${pkgname}/README.md"
    install -Dm644 "LICENSE" "${pkgdir}/usr/share/licenses/${pkgname}/LICENSE"
}
