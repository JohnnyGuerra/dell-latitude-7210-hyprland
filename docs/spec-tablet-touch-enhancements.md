# Spec: Dell Latitude 7210 Tablet Touch & Phosh-Inspired UX Enhancements

## Objective
Transform the Dell Latitude 7210 2-in-1 touchscreen experience under Hyprland by porting the core mobile UX principles of Phosh (predictability, glanceable controls, touch target ergonomics, edge navigation, and rotation stability) while retaining Hyprland's high-performance tiling engine and ultra-low idle battery footprint (~3.8W).

---

## Assumptions
1. **Target Hardware**: Dell Latitude 7210 2-in-1 running Arch Linux with Linux kernel 7.2+, iio-sensor-proxy, and Hyprland (Lua/conf hybrid).
2. **Notification & Control Center**: We replace `mako` with `swaync` (0.12+) to gain native touch sliders (brightness/volume), quick-action toggle buttons, and touch-dismissible notifications in a single layer-shell panel.
3. **Touch Edge Gestures**: We use `/usr/bin/lisgd` (already installed on target) mapped to the hardware touchscreen device (`/dev/input/event*`) with edge-boundary thresholds to prevent accidental triggers while scrolling.
4. **On-Screen Keyboard**: We retain `wvkbd-deskintl` via `smart-keyboard-daemon` (with touch edge swipe and auto-show on focus), preserving low memory overhead (<15MB).
5. **Deployment Channel**: All changes are maintained in `/home/ubuntu/7210`, synced to `johnny@archtablet` via `scripts/sync.sh push`, and verified via SSH.

---

## Tech Stack
- **Compositor**: Hyprland (Wayland)
- **Status Bar**: Waybar (`config.jsonc`, `style.css`)
- **Control Center & Notifications**: `swaync` (GTK4 / libadwaita / gtk4-layer-shell)
- **Gesture Daemon**: `lisgd` (libinput 1:1 edge gesture listener)
- **Touch Launcher & Switcher**: `wofi` (Wayland native, custom touch-styled CSS)
- **Sensors & Automation**: Python 3 (`gi.repository.Gio`, `GLib`), Bash, D-Bus (`net.hadess.SensorProxy`)
- **Hardware Integration**: Sysfs folio path (`/sys/bus/usb/devices/1-4`)

---

## Architecture & Interaction Workflow

```
                        ┌───────────────────────────────┐
                        │   Hardware Dell 7210 Touch    │
                        └───────────────┬───────────────┘
                                        │
           ┌────────────────────────────┼────────────────────────────┐
           │ (Top Edge Swipe)           │ (Bottom Edge)              │ (Left/Right Edge)
           ▼                            ▼                            ▼
  ┌─────────────────┐          ┌─────────────────┐          ┌─────────────────┐
  │  lisgd Daemon   │          │  lisgd Daemon   │          │  lisgd Daemon   │
  │  swaync-client  │          │ toggle-keyboard │          │ hyprctl dispatch│
  │    -t -sw       │          │ (wvkbd layer)   │          │  workspace +/-  │
  └────────┬────────┘          └─────────────────┘          └─────────────────┘
           │
           ▼
┌────────────────────────────────────────────────────────┐
│             SwayNC Quick Settings Shade                │
│  ┌────────────────────────┐  ┌──────────────────────┐  │
│  │ Brightness / Volume    │  │ Quick Action Toggles │  │
│  │ Smooth Touch Sliders   │  │ Rotation Lock, Wi-Fi │  │
│  └────────────────────────┘  └──────────────────────┘  │
└──────────────────────────┬─────────────────────────────┘
                           │ (Toggles Lock File)
                           ▼
               ┌───────────────────────┐
               │ /tmp/rotation-lock    │
               └───────────┬───────────┘
                           │
                           ▼
          ┌───────────────────────────────────┐
          │ auto-rotate-daemon.py (D-Bus)     │
          │ Evaluates orientation ONLY if     │
          │ rotation lock is NOT set          │
          └───────────────────────────────────┘
```

---

## All 5 Implementation Phases & Task Breakdown

### Phase 1: One-Tap Rotation Lock
- [ ] **Task 1.1: Create `toggle-rotation-lock` Script**
  - **Acceptance**: Script toggles `$XDG_RUNTIME_DIR/rotation-lock`. When executed with no args, it outputs JSON formatted for Waybar (`{"text": "󰌾", "class": "locked"}` or `{"text": "󰘥", "class": "unlocked"}`). Emits `pkill -RTMIN+8 waybar`.
  - **Verify**: `scripts/bin/toggle-rotation-lock` creates and removes lock file cleanly and prints valid JSON.
  - **Files**: `scripts/bin/toggle-rotation-lock`
- [ ] **Task 1.2: Update `auto-rotate-daemon.py` with Lock Check**
  - **Acceptance**: Daemon checks `$XDG_RUNTIME_DIR/rotation-lock` before executing `apply_transform`. If locked, orientation events from `net.hadess.SensorProxy` are ignored.
  - **Verify**: `python3 -m py_compile scripts/bin/auto-rotate-daemon.py`; manual tilt test with lock engaged leaves display unchanged.
  - **Files**: `scripts/bin/auto-rotate-daemon.py`
- [ ] **Task 1.3: Add Rotation Lock Module to Waybar**
  - **Acceptance**: Waybar configuration includes `custom/rotation-lock` module with click handler running `toggle-rotation-lock`. Highlighted with active accent color when locked.
  - **Verify**: Waybar displays lock icon and updates on touch tap.
  - **Files**: `config/waybar/config.jsonc`, `config/waybar/style.css`

---

### Phase 2: Touch Quick Settings Shade (`swaync`)
- [ ] **Task 2.1: Package & Service Transition from Mako to SwayNC**
  - **Acceptance**: `swaync` installed on `archtablet`; Mako service replaced with `swaync.service` in systemd user session.
  - **Verify**: `ssh johnny@archtablet "which swaync && swaync-client --version"` returns valid binary.
  - **Files**: `scripts/bin/start-swaync` (or systemd unit)
- [ ] **Task 2.2: SwayNC Configuration & Widget Styling**
  - **Acceptance**: `config.json` defines control center widgets: volume slider, brightness slider, notification list, and quick toggle buttons (Rotation Lock, Wi-Fi, Bluetooth, Eco Mode, Power). `style.css` uses 48px touch targets, rounded corners, and Catppuccin/Nord dark aesthetic.
  - **Verify**: `swaync-client -t -sw` smoothly toggles the control center; sliders move responsively on touch.
  - **Files**: `config/swaync/config.json`, `config/swaync/style.css`
- [ ] **Task 2.3: Waybar Control Center Tap Hook**
  - **Acceptance**: Tapping the clock/tray area in Waybar opens/closes the SwayNC shade via `swaync-client -t -sw`.
  - **Verify**: Tap on clock in Waybar opens shade, second tap closes it.
  - **Files**: `config/waybar/config.jsonc`

---

### Phase 3: Hardware Edge Gestures (`lisgd`)
- [ ] **Task 3.1: Determine Touchscreen Input Device & Geometries**
  - **Acceptance**: Identify the exact `/dev/input/event*` node for the Dell 7210 touchscreen sensor and screen dimensions.
  - **Verify**: `libinput list-devices` identifies Dell touch panel.
  - **Files**: `scripts/bin/tablet-edge-gestures`
- [ ] **Task 3.2: Create Edge Gesture Daemon Script**
  - **Acceptance**: Launch `lisgd` with discrete edge configurations:
    - Swipe down from top 5% edge (`-e top`): `swaync-client -t -sw`
    - Swipe up from bottom 5% edge (`-e bottom`): `toggle-keyboard`
    - Swipe left from right edge: `hyprctl dispatch workspace e+1`
    - Swipe right from left edge: `hyprctl dispatch workspace e-1`
  - **Verify**: Edge swipes reliably trigger actions while inner screen scrolling remains untouched.
  - **Files**: `scripts/bin/tablet-edge-gestures`, `config/hypr/hyprland.conf`

---

### Phase 4: Touch-Optimized Visual Window Switcher
- [ ] **Task 4.1: Touch-Styled Wofi Window Switcher**
  - **Acceptance**: Script `touch-switcher` launches `wofi --show window` with custom CSS (`touch-style.css`) featuring 56px list items, large window titles, clear app icons, and tap-to-focus behavior.
  - **Verify**: Executing `touch-switcher` opens an easy-to-tap fullscreen/card window list.
  - **Files**: `scripts/bin/touch-switcher`, `config/wofi/touch-style.css`
- [ ] **Task 4.2: Add Switcher Trigger to Waybar & Gesture**
  - **Acceptance**: Waybar includes an "Overview / Tasks" icon (`󰕰`) on the left that triggers `touch-switcher`. 3-finger swipe up or tap activates it.
  - **Verify**: Tap on task icon opens window switcher immediately.
  - **Files**: `config/waybar/config.jsonc`, `config/hypr/hyprland.conf`

---

### Phase 5: Adaptive Tablet vs. Desktop Mode
- [ ] **Task 5.1: Create `tablet-mode-daemon`**
  - **Acceptance**: Daemon monitors folio USB device `/sys/bus/usb/devices/1-4`:
    - On detach: Triggers `tablet-mode enable`
    - On attach: Triggers `tablet-mode disable`
  - **Verify**: Physically detaching/attaching folio triggers respective script hooks within 1 second.
  - **Files**: `scripts/bin/tablet-mode-daemon`
- [ ] **Task 5.2: Implement Adaptive UI Scaling & Window Rules**
  - **Acceptance**:
    - In Tablet Mode: Waybar increases height to 44px with extra padding; Hyprland gaps set to 8px; new windows auto-maximized.
    - In Desktop Mode: Waybar height set to 30px; standard tiling gaps; standard window splitting.
  - **Verify**: Toggling tablet mode visibly switches Waybar hitboxes and window layout rules smoothly.
  - **Files**: `scripts/bin/toggle-tablet-mode`, `config/waybar/style.css`, `config/hypr/hyprland.conf`

---

## Testing & Verification Checklist
| Phase | Feature | Verification Command | Expected Outcome |
|---|---|---|---|
| **Phase 1** | Rotation Lock | `toggle-rotation-lock` | Lock file created, Waybar icon changes, screen ignores tilts |
| **Phase 2** | Quick Settings | `swaync-client -t -sw` | Control Center slides out with brightness/volume sliders |
| **Phase 3** | Edge Gestures | Edge swipe from top | Control Center drops down from bezel |
| **Phase 4** | App Switcher | `touch-switcher` | Large finger-friendly window cards appear on screen |
| **Phase 5** | Adaptive Mode | Folio detach | Waybar enlarges, tablet window policy engages |

---

## Boundaries
- **Always**: Keep idle power consumption within the ~3.8W–4.2W target; preserve existing user shortcuts and Waydroid integration.
- **Ask First**: Replacing running daemons permanently in systemd user units; modifying display resolution or core monitor DPI.
- **Never**: Introduce heavy GNOME/KDE background daemons; hardcode static UID/paths that break multi-session Wayland.
