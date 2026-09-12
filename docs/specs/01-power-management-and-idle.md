# Spec: Dell Latitude 7210 Power Management & Idle Automation

## Objective
Optimize battery runtime and prevent unnecessary display drain on the Dell Latitude 7210 2-in-1 running Arch Linux and Hyprland 0.56 by:
1. Installing and configuring `hypridle` with Hyprland 0.56 Lua syntax (`hl.dispatch(hl.dsp.dpms({ state = ... }))`) to automate screen dimming (90s), session locking and display sleep (3 min / 180s), and system suspend (10 min / 600s).
2. Tuning TLP Energy Performance Preference (EPP) to `power` when discharging on battery, targeting a drop in active dynamic power consumption while preserving balanced responsiveness on AC.

## Tech Stack
- **OS**: Arch Linux (Kernel 7.2.4-arch1-2, x86_64)
- **Compositor**: Hyprland 0.56.2 (Lua configuration interface)
- **Idle Daemon**: `hypridle` (official Hyprland ecosystem idle daemon)
- **Lock Screen**: `hyprlock`
- **Backlight Control**: `brightnessctl` (subsystem `backlight`, controller `intel_backlight`)
- **Power Management**: `tlp` 1.10.2 (`/etc/tlp.d/00-custom.conf`)
- **Supervision**: `systemd --user` (`graphical-session.target`)

## Commands
```bash
# Package Installation (Target: archtablet)
sudo pacman -S --needed --noconfirm hypridle

# Syntax / Dispatch Verification (Hyprland 0.56 Lua)
hyprctl eval 'return tostring(hl.dispatch(hl.dsp.dpms({ state = "on" })))'
hyprctl eval 'return tostring(hl.dispatch(hl.dsp.dpms({ state = "off" })))'

# TLP Configuration & Reload
sudo tlp start
sudo tlp-stat -p | grep -E "EPP|energy_perf"

# Service Verification
hypridle --validate -c ~/.config/hypr/hypridle.conf
systemctl --user status hypridle.service 2>/dev/null || pgrep -a hypridle

# Power Telemetry
upower -i $(upower -e | grep BAT) | grep -E "percentage|energy-rate|state"
```

## Project Structure
```
config/
└── hypr/
    ├── hypridle.conf        → Hyprland idle daemon configuration (updated with Lua dispatch)
    └── hyprland.lua         → Autostart hook ensuring hypridle is running
/etc/tlp.d/
└── 00-custom.conf          → Target system TLP overrides (CPU_ENERGY_PERF_POLICY_ON_BAT)
scripts/
└── sync.sh                 → Deployment and reload orchestrator
docs/
└── specs/
    └── 01-power-management-and-idle.md → This specification document
```

## Code Style & Configuration Conventions
1. **Hyprland 0.56 Lua Dispatch**:
   Never use legacy CLI dispatch syntax (`hyprctl dispatch dpms on`). Use the verified Hyprland 0.56 evaluation syntax:
   ```ini
   # hypridle.conf listener block (180s: lock + screen off)
   listener {
       timeout = 180
       on-timeout = loginctl lock-session; hyprctl eval 'hl.dispatch(hl.dsp.dpms({ state = "off" }))'
       on-resume = hyprctl eval 'hl.dispatch(hl.dsp.dpms({ state = "on" }))'
   }
   ```
2. **TLP Overrides**:
   Keep system modifications isolated in `/etc/tlp.d/00-custom.conf` rather than modifying the vendor default `/etc/tlp.conf`.

## Testing Strategy
- **Syntax Verification**: Execute `hypridle --validate -c ...` on target.
- **DPMS Hook Verification**: Test manual execution of `on-timeout` and `on-resume` commands to ensure no Lua errors or crashed pipes occur.
- **Idle Simulation**: Run a test timeout (e.g. 5 seconds) to observe screen dimming and recovery on touch/trackpad input.
- **EPP Verification**: Inspect `/sys/devices/system/cpu/cpu*/cpufreq/energy_performance_preference` under battery discharge to confirm `power` is active.

## Boundaries
- **Always do:**
  - Verify syntax with `hyprctl eval` before putting commands in daemon configs.
  - Test screen wake responsiveness via touchscreen tap and touchpad event.
  - Commit all repository changes and push to GitHub `main`.
- **Ask first:**
  - Adjusting suspend/hibernate timeouts (e.g., shorter or longer than 10m).
  - Installing kernel-level power undervolting or thermald custom xml policies.
- **Never do:**
  - Set brightness below 1% (`brightnessctl -s set 0%`), which causes panel core dumps in SwayNC / GTK.
  - Unmask `power-profiles-daemon`, which conflicts with `tlp`.

## Success Criteria
1. `hypridle` package installed on `archtablet` and supervised by Hyprland/systemd.
2. Display dims to 10% after 90 seconds of inactivity, and restores on user interaction.
3. Session locks via `hyprlock` and display powers off (`dpms off`) after 180 seconds (3 minutes) of inactivity without throwing Hyprland Lua syntax errors.
4. Screen wakes and lock screen displays immediately upon touch/trackpad interaction.
5. Tablet automatically initiates deep sleep/suspend after 600 seconds (10 minutes).
6. TLP enforces `CPU_ENERGY_PERF_POLICY_ON_BAT="power"` when unplugged, verified in sysfs `energy_performance_preference`.

## Resolved Decisions
- **Dimming**: 90 seconds to 10% brightness.
- **Lock & Display Off**: 3 minutes (180s) to lock session and turn display off simultaneously.
- **Suspend**: 10 minutes (600s) to suspend system.
