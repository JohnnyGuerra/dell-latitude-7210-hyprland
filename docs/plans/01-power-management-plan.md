# Implementation Plan: Power Management & Idle Automation

## Phase 2: Technical Plan

### Components & Dependencies
1. **Target Package Installation**: `hypridle` from official Arch Linux repositories via `pacman`.
2. **Idle Configuration**: [`config/hypr/hypridle.conf`](file:///home/ubuntu/7210/config/hypr/hypridle.conf) using Hyprland 0.56 Lua dispatch for DPMS on/off.
3. **Compositor Integration**: Ensure Hyprland autostart in [`config/hypr/hyprland.lua`](file:///home/ubuntu/7210/config/hypr/hyprland.lua) properly manages/restarts `hypridle`.
4. **TLP Battery EPP Profile**: Update `/etc/tlp.d/00-custom.conf` on `archtablet` to enforce `CPU_ENERGY_PERF_POLICY_ON_BAT="power"`.

### Implementation Order
1. **Task 1**: Configure [`config/hypr/hypridle.conf`](file:///home/ubuntu/7210/config/hypr/hypridle.conf) with exact user timers (90s dim to 10%, 180s lock + display off, 600s suspend) and 0.56 Lua syntax.
2. **Task 2**: Install `hypridle` on `archtablet`, deploy `hypridle.conf`, and verify daemon starts and runs cleanly.
3. **Task 3**: Update TLP configuration (`/etc/tlp.d/00-custom.conf`) on `archtablet` and apply via `tlp start`.
4. **Task 4**: Verify idle stages (dim, lock/sleep, wake on touch) and confirm EPP sysfs state under battery. Commit and push to GitHub.

### Risks & Mitigations
- **Risk**: Screen turn-off fails to wake on touchscreen tap.
  - **Mitigation**: Verified that Wacom touch controller triggers libinput wake events under Hyprland; test wake via both touch tap and touchpad prior to finalizing.
- **Risk**: Display shutoff crashes SwayNC or Waybar if brightness hits 0.
  - **Mitigation**: Dimmer target is explicitly clamped to 10% (`brightnessctl -s set 10%`), safely above the 1% floor.

---

## Phase 3: Task Breakdown

- [ ] **Task 1: Update `hypridle.conf` with 90s dim, 180s lock/off, and 0.56 Lua syntax**
  - **Acceptance**: `hypridle.conf` implements 90s dimming, 180s lock and dpms off via `hyprctl eval 'hl.dispatch(hl.dsp.dpms({ state = "off" }))'`, and 600s suspend.
  - **Verify**: `grep -E 'timeout|dpms|lock' config/hypr/hypridle.conf`
  - **Files**: `config/hypr/hypridle.conf`

- [ ] **Task 2: Install `hypridle` on target and deploy daemon**
  - **Acceptance**: `hypridle` binary installed; config deployed to `~/.config/hypr/hypridle.conf`; `hypridle` daemon active and running.
  - **Verify**: `ssh johnny@archtablet "which hypridle && pgrep -a hypridle"`
  - **Files**: Remote system package & `~/.config/hypr/hypridle.conf`

- [ ] **Task 3: Apply TLP `power` EPP profile on battery**
  - **Acceptance**: `/etc/tlp.d/00-custom.conf` sets `CPU_ENERGY_PERF_POLICY_ON_BAT="power"`; TLP reloaded.
  - **Verify**: `ssh johnny@archtablet "cat /sys/devices/system/cpu/cpu0/cpufreq/energy_performance_preference"`
  - **Files**: `/etc/tlp.d/00-custom.conf` on target

- [ ] **Task 4: End-to-end verification and GitHub sync**
  - **Acceptance**: Touch and touchpad wake verified; all repo changes committed and pushed to `main`.
  - **Verify**: `git status` clean and upstream synced.
  - **Files**: Git repository
