#!/usr/bin/env bash
if [ "$1" = "post" ]; then
    # Resilient post-resume display wake for Dell Latitude 7210 (Intel Comet Lake eDP + Hyprland)
    su - johnny -c "/home/johnny/.local/bin/wake-display" &
fi
