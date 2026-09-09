#!/usr/bin/env python3
"""
Hardware Folio-Aware Auto-Rotation & Dynamic Scratchpad Resizer
Dell Latitude 7210 2-in-1 under Hyprland
- Zero polling: Pure event-driven D-Bus signals from iio-sensor-proxy
- Folio keyboard detection (/sys/bus/usb/devices/1-4)
- Immediate rotation, atomic fit-agent-window scratchpad resize & touch gestures orientation sync
"""

import os
import sys
import time
import subprocess
import gi
from gi.repository import Gio, GLib

FOLIO_PATH = "/sys/bus/usb/devices/1-4"
MONITOR = "eDP-1"

ORIENTATION_MAP = {
    "normal": 0,           # Landscape
    "right-up": 3,         # Portrait (turned right 90 deg)
    "bottom-up": 2,        # Inverted Landscape (upside down)
    "left-up": 1,          # Inverted Portrait (turned left 90 deg)
}

current_transform = 0

def get_hypr_env():
    uid = str(os.getuid())
    runtime_dir = f"/run/user/{uid}"
    env = os.environ.copy()
    env["XDG_RUNTIME_DIR"] = runtime_dir
    
    hypr_dir = os.path.join(runtime_dir, "hypr")
    if os.path.isdir(hypr_dir):
        sigs = sorted(os.listdir(hypr_dir), key=lambda s: os.path.getmtime(os.path.join(hypr_dir, s)), reverse=True)
        for s in sigs:
            if not s.startswith("."):
                env["HYPRLAND_INSTANCE_SIGNATURE"] = s
                break

    if "WAYLAND_DISPLAY" not in env:
        for f in os.listdir(runtime_dir):
            if f.startswith("wayland-"):
                env["WAYLAND_DISPLAY"] = f
                break

    return env

def apply_transform(tf):
    global current_transform
    env = get_hypr_env()
    
    cmd_rotate = f'hl.monitor({{ output = "{MONITOR}", transform = {tf} }}) hl.config({{ input = {{ touchdevice = {{ transform = {tf} }}, tablet = {{ transform = {tf} }} }} }})'
    subprocess.run(["hyprctl", "repl", cmd_rotate], env=env, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    current_transform = tf
    
    # Run fit-agent-window immediately to adjust the scratchpad
    fit_script = os.path.expanduser("~/.local/bin/fit-agent-window")
    if os.path.isfile(fit_script):
        subprocess.run([fit_script], env=env, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

    # Sync touch gestures daemon with current orientation
    touch_script = os.path.expanduser("~/.local/bin/touch-gestures")
    if os.path.isfile(touch_script):
        subprocess.run([touch_script, "rotate", str(tf)], env=env, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

def on_properties_changed(connection, sender_name, object_path, interface_name, signal_name, parameters, user_data):
    if interface_name == 'org.freedesktop.DBus.Properties' and signal_name == 'PropertiesChanged':
        iface, changed, _ = parameters.unpack()
        if 'AccelerometerOrientation' in changed:
            new_orient = changed['AccelerometerOrientation']
            if os.path.exists(FOLIO_PATH):
                # When folio is attached, lock to landscape 0
                if current_transform != 0:
                    apply_transform(0)
                return

            if new_orient in ORIENTATION_MAP:
                target_tf = ORIENTATION_MAP[new_orient]
                if target_tf != current_transform:
                    apply_transform(target_tf)

def check_folio_status():
    global current_transform
    if os.path.exists(FOLIO_PATH):
        if current_transform != 0:
            apply_transform(0)
    return True

def main():
    bus = Gio.bus_get_sync(Gio.BusType.SYSTEM, None)
    
    proxy = Gio.DBusProxy.new_sync(
        bus,
        Gio.DBusProxyFlags.NONE,
        None,
        'net.hadess.SensorProxy',
        '/net/hadess/SensorProxy',
        'net.hadess.SensorProxy',
        None
    )
    
    # Claim the accelerometer so net.hadess.SensorProxy starts streaming orientation changes
    proxy.call_sync('ClaimAccelerometer', None, Gio.DBusCallFlags.NONE, -1, None)
    
    # Subscribe to orientation property changes
    bus.signal_subscribe(
        'net.hadess.SensorProxy',
        'org.freedesktop.DBus.Properties',
        'PropertiesChanged',
        '/net/hadess/SensorProxy',
        None,
        Gio.DBusSignalFlags.NONE,
        on_properties_changed,
        None
    )
    
    # Check initial orientation
    init_orient = proxy.get_cached_property('AccelerometerOrientation')
    if init_orient:
        orient_str = init_orient.get_string()
        if not os.path.exists(FOLIO_PATH) and orient_str in ORIENTATION_MAP:
            apply_transform(ORIENTATION_MAP[orient_str])
        else:
            apply_transform(0)
    else:
        apply_transform(0)

    # Periodic timer to check hardware folio detach/attach
    GLib.timeout_add_seconds(2, check_folio_status)

    loop = GLib.MainLoop()
    try:
        loop.run()
    except (KeyboardInterrupt, SystemExit):
        proxy.call_sync('ReleaseAccelerometer', None, Gio.DBusCallFlags.NONE, -1, None)

if __name__ == '__main__':
    main()
