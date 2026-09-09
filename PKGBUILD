# Maintainer: Johnny Guerra <johnny.guerra@gmail.com>
pkgname=dell-latitude-7210-hyprland-git
pkgver=r1.a6f3beb
pkgrel=1
pkgdesc="Turnkey, touch-optimized Hyprland tablet suite for Dell Latitude 7210 2-in-1 on Arch Linux"
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
    install -Dm755 "waybar/slider-popup" "${pkgdir}/usr/bin/slider-popup"
    install -Dm755 "keyboard/keyboard-status" "${pkgdir}/usr/bin/keyboard-status"
    install -Dm755 "keyboard/keyboard-mode-menu" "${pkgdir}/usr/bin/keyboard-mode-menu"
    install -Dm755 "keyboard/toggle-keyboard" "${pkgdir}/usr/bin/toggle-keyboard"
    install -Dm755 "system/toggle-eco-mode" "${pkgdir}/usr/bin/toggle-eco-mode"

    # Install systemd user service
    install -Dm644 "auto-rotate/auto-rotate.service" "${pkgdir}/usr/lib/systemd/user/auto-rotate.service"
    sed -i 's|%h/.local/bin/auto-rotate-daemon.py|/usr/bin/auto-rotate-daemon|g' "${pkgdir}/usr/lib/systemd/user/auto-rotate.service"

    # Install udev rules
    install -Dm644 "system/90-backlight.rules" "${pkgdir}/usr/lib/udev/rules.d/90-backlight.rules"

    # Install Waybar & Hyprland config presets
    install -Dm644 "waybar/config.jsonc" "${pkgdir}/usr/share/dell-latitude-7210-hyprland/waybar/config.jsonc"
    install -Dm644 "waybar/style.css" "${pkgdir}/usr/share/dell-latitude-7210-hyprland/waybar/style.css"
    install -Dm644 "hyprland/touch-gestures.conf" "${pkgdir}/usr/share/dell-latitude-7210-hyprland/hyprland/touch-gestures.conf"

    # Install documentation and license
    install -Dm644 "README.md" "${pkgdir}/usr/share/doc/${pkgname}/README.md"
    install -Dm644 "LICENSE" "${pkgdir}/usr/share/licenses/${pkgname}/LICENSE"
}
