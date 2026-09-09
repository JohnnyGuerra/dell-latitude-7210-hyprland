# Dell Latitude 7210 2-in-1: Complete Hyprland Tablet Suite

[![Arch Linux](https://img.shields.io/badge/Arch_Linux-1793D1?logo=arch-linux&logoColor=fff&style=flat-square)](https://archlinux.org)
[![Hyprland](https://img.shields.io/badge/Hyprland-Wayland-00B4D8?style=flat-square)](https://hyprland.org)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=flat-square)](https://opensource.org/licenses/MIT)
[![Dell Latitude 7210 2-in-1](https://img.shields.io/badge/Dell_Latitude-7210_2--in--1-0076CE?logo=dell&logoColor=white&style=flat-square)](https://www.dell.com)

A turnkey, touch-optimized workstation suite for running **Hyprland** on the **Dell Latitude 7210 2-in-1** tablet running Arch Linux. 

This repository provides zero-polling hardware auto-rotation with magnetic folio awareness, synchronized Wacom pen/touch digitizer matrix mapping, zero-lag GTK layer-shell touch sliders, an enlarged 54px Waybar with Catppuccin theme, one-handed mobile on-screen keyboard docking (`wvkbd`), and aggressive battery life optimizations.

---

## 🎯 The Problems This Solves

Running Hyprland or Wayland compositors on convertible 2-in-1 laptops often results in frustrating hardware quirks:

1. **Undesired Rotation with Folio Attached**: Most generic rotation daemons tilt the screen while you are typing on a desk or your lap. This suite checks `/sys/bus/usb/devices/1-4` to automatically lock orientation to landscape while the magnetic folio keyboard is connected, enabling full free auto-rotation only when in handheld tablet mode.
2. **Pen & Touch Inversion**: Rotating the screen display without synchronizing Hyprland's input matrices causes touch and stylus pen coordinates to register inverted or sideways. This daemon updates `touchdevice` and `tablet` matrices atomically on every rotation.
3. **Unresponsive Waybar Drawers on Touchscreens**: Waybar's native drawer modules suffer from [upstream bug #4644](https://github.com/Alexays/Waybar/issues/4644) where GTK eventboxes swallow touchscreen tap events. Our standalone layer-shell slider popup provides an iOS/Android-style floating touch card with oversized 34px knobs and debounced capacitive touch handling.
4. **Subprocess UI Freezing**: Frequent volume and brightness slider ticks often stutter the UI when making blocking shell calls. We use a dedicated non-blocking background PipeWire worker thread and direct kernel sysfs writes (`0.01ms` latency) for instant 60 FPS response.

---

## ✨ Features

### 1. Hardware Folio-Aware Auto-Rotation (`auto-rotate/`)
- **Event-Driven D-Bus (`net.hadess.SensorProxy`)**: 0% idle CPU usage. Listens for orientation events from `iio-sensor-proxy` without polling loops.
- **Folio Keyboard Lock**: Monitors Dell magnetic pogo-pin folio (`/sys/bus/usb/devices/1-4`). Locks to landscape when docked; unlocks in tablet mode.
- **Atomic Digitizer Mapping**:
  - `wacom-hid-48ce-pen` (Wacom AES Stylus)
  - `wacom-hid-48ce-finger` (Capacitive Touchscreen)
  - Dispatches `hl.config({ input = { touchdevice = { transform = tf }, tablet = { transform = tf } } })`.

### 2. Touch-Optimized Waybar & Floating Sliders (`waybar/`)
- **54px Bar Height**: Finger-friendly hitboxes across all pills and workspaces.
- **Tactile Touch Feedback**: Immediate visual highlight (`#cba6f7`) on touch-down.
- **Layer-Shell Slider Popup (`slider-popup`)**:
  - Tapping **Volume (`󰕿`)** or **Brightness (`󰃞`)** opens a centered floating card directly below the bar.
  - Sub-millisecond direct sysfs write to `/sys/class/backlight/intel_backlight/brightness`.
  - Non-blocking `AudioWorker` daemon thread coalesces rapid drag ticks so PipeWire IPC never drops frames.
  - Auto-unmute when dragging volume up from zero.
  - 4.5s idle auto-dismiss with on-card **✕** dismiss button and `Escape` key support.

### 3. One-Handed Keyboard Docking (`keyboard/`)
- Integrates with [`wvkbd`](https://github.com/jjsullivan5196/wvkbd):
  - **Full Width**: Standard landscape/portrait typing.
  - **Right-Handed Docking (`--dock right --ratio 0.68`)**: Reaches across the screen for right thumb typing.
  - **Left-Handed Docking (`--dock left --ratio 0.68`)**: Ergonomic left thumb typing.
- **Dynamic Waybar Module**: Real-time signal-based status (`⌨ Full`, `⌨ R`, `⌨ L`, `⌨ [R]`).
  - **Tap**: Toggle on/off.
  - **Right-Tap / Double-Tap**: Open Wofi mode selector.

### 4. System Tuning & Power Management Suite (`system/`)
The Dell Latitude 7210 2-in-1 is notorious for firmware sleep hangs and aggressive thermal throttling under Linux without proper tuning. This suite includes the complete battle-tested power stack:

- **Rock-Solid Sleep (`suspend-then-hibernate.conf`)**:
  - Dell Latitude 7210 UEFI firmware hangs when entering or waking from standard deep ACPI S3 sleep.
  - Fix: Configures `s2idle` initial suspend with a 30-minute transition timeout to NVMe swapfile via `systemd-suspend-then-hibernate` (verified 75h+ standby retention with ~1% total battery loss, 0 firmware hangs).
- **Folio Clamshell Lid Switch (`lid_switch.conf`)**:
  - Properly hooks the Dell magnetic folio close event to `suspend-then-hibernate`.
- **Intel RAPL Power Clamping (`apply-rapl-limits` + `rapl-limits.service`)**:
  - Clamps Running Average Power Limits (PL1/PL2) for the 10th-Gen Intel Core i7-10610U:
    - **Battery**: 10W PL1 sustained / 15W PL2 burst (eliminates fan noise and thermal throttling in tablet mode).
    - **AC Mains**: 15W PL1 sustained / 25W PL2 burst.
- **Battery Preservation TLP Profile (`tlp-7210.conf`)**:
  - Dell battery charge thresholds (stops charging at 80% to preserve lithium health, resumes below 75%).
  - Intel UHD Graphics frequency capping on battery (300MHz min, 700MHz max).
  - PCIe ASPM powersave policy.
- **Display Refresh Rate Switcher (`toggle-refresh-rate`)**:
  - Toggles the Sharp 1920x1280 panel between **60Hz** (smooth) and **48Hz** (battery saver, saving ~0.4W continuously).
- **3.2W Magic Eco-Mode (`toggle-eco-mode`)**:
  - Dynamic CPU governor (`powersave`), EPP (`power`), and backlight level toggling extending battery life beyond 7+ hours.
- **Backlight Udev Rule (`90-backlight.rules`)**:
  - Unprivileged write access to `/sys/class/backlight/%k/brightness` for instant 0.01ms slider adjustments.

---

## 🚀 Quick Start & Installation

### Option A: Native Arch Linux Package (`makepkg -si`) — Recommended

Build and install as a native Arch package managed by `pacman`:

```bash
git clone https://github.com/JohnnyGuerra/dell-latitude-7210-hyprland.git
cd dell-latitude-7210-hyprland
makepkg -si
```

Enable the auto-rotation user service:
```bash
systemctl --user enable --now auto-rotate.service
```

### Option B: Standalone Shell Installer

If you prefer installing scripts directly into `~/.local/bin/` without pacman:

```bash
git clone https://github.com/JohnnyGuerra/dell-latitude-7210-hyprland.git
cd dell-latitude-7210-hyprland
./install.sh
```

The installer will:
1. Copy helper scripts to `~/.local/bin/`.
2. Enable and start the `auto-rotate.service` systemd user service.
3. Install the backlight udev rule to `/etc/udev/rules.d/90-backlight.rules`.
4. Optionally install the touch-friendly Waybar configuration (with automatic backup).

---

## 📦 Dependencies

On Arch Linux / EndeavourOS:

```bash
sudo pacman -S \
    hyprland \
    waybar \
    iio-sensor-proxy \
    gtk-layer-shell \
    python-gobject \
    brightnessctl \
    libpulse \
    wireplumber \
    pipewire \
    wofi
```

For the on-screen keyboard:
```bash
yay -S wvkbd-git
```

---

## 🔧 Hardware Verification & Diagnostics

Verify that your Latitude 7210 sensors and input devices match:

```bash
# Check Wacom touchscreen and pen digitizers:
hyprctl devices | grep -E 'wacom-hid'

# Check accelerometer D-Bus orientation streaming:
gdbus monitor --system --dest net.hadess.SensorProxy --object-path /net/hadess/SensorProxy

# Check magnetic keyboard attachment status:
ls -d /sys/bus/usb/devices/1-4 2>/dev/null && echo "Folio Attached" || echo "Tablet Mode"
```

---

## 📜 Systemd User Service

The auto-rotation daemon runs as an unprivileged user service:

```bash
systemctl --user status auto-rotate.service
systemctl --user restart auto-rotate.service
journalctl --user -u auto-rotate.service -f
```

---

## 📄 License

MIT License © 2026 [Johnny Guerra](https://github.com/JohnnyGuerra).
