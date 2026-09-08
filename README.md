# Dell Latitude 7210 2-in-1 (`archtablet`)

Repository and project hub for the **Dell Latitude 7210 2-in-1** running **Arch Linux** with **Hyprland**.

---

## 💻 Hardware Specifications

| Component | Specification | Notes |
| :--- | :--- | :--- |
| **Device** | Dell Latitude 7210 2-in-1 | Detachable folio keyboard + kickstand |
| **Display** | 12.3″ 1920×1280 (3:2) | HiDPI scale `1.33` (1440×960 logical canvas) |
| **Refresh Rates** | 60Hz / 48Hz | Dynamic toggle via `Super + Shift + D` |
| **Touch & Pen** | Alps Touchpad + Wacom Digitizer | Native multi-touch and active stylus support |
| **Network** | Intel Wi-Fi + Tailscale Mesh | Hostname: `archtablet` (`100.72.121.23`) |
| **Power Profile** | Magic Eco Mode (~3.2W idle/light load) | 8h+ battery life via `Super + Shift + E` |
| **Sleep / Hibernation** | `systemd-suspend-then-hibernate` | `s2idle` initial suspend -> 30m timeout -> 16GB NVMe swap |

---

## 🖥️ Desktop Architecture

* **Compositor**: [Hyprland](https://hyprland.org/) (UWSM session managed; Lua-configured at `~/.config/hypr/hyprland.lua`)
* **Status Bar**: [Waybar](https://github.com/Alexays/Waybar) (`~/.config/waybar/`)
* **App Launcher**: Wofi (`~/.config/wofi/`)
* **Terminal**: Kitty (`~/.config/kitty/kitty.conf`)
* **Notification Daemon**: Mako (`~/.config/mako/`)
* **Theme Engine**: Omarchy Multi-Theme Engine (`~/.local/bin/omarchy-theme`)
* **Audio & Media**: PipeWire / WirePlumber + `ytm` (`mpv` + `ytfzf` + `youtube-upnext.lua`)
* **Editor & Git**: Neovim (LazyVim), Lazygit

---

## ⚡ Key Shortcuts & Workflows

| Shortcut | Action | Description |
| :--- | :--- | :--- |
| `Super + Space` / `Super + S` | AI Scratchpad | Attaches to remote Herdr session on `ai-server` (`ubuntu@100.76.44.71`) |
| `Super + Shift + R` | Rotate Display | Toggles portrait / landscape orientation |
| `Super + Shift + D` | Refresh Rate Toggle | Switches between 60Hz and 48Hz power saving |
| `Super + Shift + E` | Magic Eco Mode | Enforces ~3.2W profile for maximum battery retention |
| `Super + Shift + C` | AI Crash Diagnostics | Invokes `~/.local/bin/ai-debug-crash` |
| `Super + Alt + Space` | Omarchy Menu | Central desktop control and utility hub |
| `Super + Alt + T` | Theme Selector | Cycles Tokyo Night, Catppuccin, Gruvbox, Nord, etc. |
| `Super + G` | Floating Lazygit | Centered modal Git client |
| `Super + Alt + M` | YouTube Music | Detached low-overhead background player |

---

## 📁 Project Directory Structure

```text
~/7210/
├── README.md               # Hardware, desktop stack, and shortcut reference
├── .gitignore
├── config/                 # Version-controlled configuration mirrors
│   ├── hypr/               # hyprland.lua, hyprlock.conf, hypridle.conf, hyprpaper.conf
│   ├── waybar/             # config.jsonc, style.css
│   ├── kitty/              # kitty.conf
│   └── wofi/               # config, style.css
├── scripts/                # Utility and hardware management scripts
│   ├── display/            # rotate-screen, toggle-refresh-rate
│   ├── power/              # toggle-eco-mode, sleep inhibitors
│   └── audio/              # ytm, playerctl helpers
└── docs/                   # Guides, hardware quirks, and battery benchmarks
```

---

## ⚠️ Known Quirks & Invariants

1. **UEFI Sleep Bug (S3 `deep`)**:
   * *Never* set `mem_sleep_default=deep`. The Dell Latitude 7210 UEFI hangs upon resuming from S3.
   * Always use `s2idle` with `systemd-suspend-then-hibernate` and an NVMe swapfile.
2. **Hyprland 0.56+ Lua Configuration**:
   * Separate sections into individual `hl.config({...})` calls.
   * Avoid obsolete keys such as `disable_splash_rendering`.
   * Runtime monitor changes require `hyprctl eval "hl.monitor({ ... })"`.
3. **Screen Resolution & Margins**:
   * Logical resolution at scale 1.33 is 1440×960.
   * Centered floating scratchpads should use `1420x896` with `bordersize 0` to prevent right-edge clipping.
4. **AUR Helpers**:
   * Pacman $\ge$ 7.1 (`libalpm.so.16`) breaks prebuilt `paru-bin`. Use `yay-bin` or compile `paru` from source.
