#!/usr/bin/env bash
set -euo pipefail

TARGET_HOST="johnny@archtablet"
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

usage() {
    echo "Usage: $0 [pull|push|diff|reload]"
    echo "  pull   : Fetch configs and scripts from archtablet to repository"
    echo "  push   : Deploy repository configs and scripts to archtablet"
    echo "  diff   : Show differences between local repo and archtablet"
    echo "  reload : Trigger reload of Hyprland, Waybar, and Kitty on archtablet"
    exit 1
}

[ $# -lt 1 ] && usage

ACTION="$1"

case "$ACTION" in
    pull)
        echo "==> Pulling configs from $TARGET_HOST..."
        mkdir -p "$REPO_DIR/config/hypr" "$REPO_DIR/config/waybar" "$REPO_DIR/config/kitty" \
                 "$REPO_DIR/config/wofi" "$REPO_DIR/config/mako" "$REPO_DIR/config/systemd/user" \
                 "$REPO_DIR/scripts/bin"

        scp -q -r "$TARGET_HOST":~/.config/hypr/* "$REPO_DIR/config/hypr/"
        scp -q -r "$TARGET_HOST":~/.config/waybar/* "$REPO_DIR/config/waybar/"
        scp -q -r "$TARGET_HOST":~/.config/kitty/* "$REPO_DIR/config/kitty/"
        scp -q -r "$TARGET_HOST":~/.config/wofi/* "$REPO_DIR/config/wofi/"
        scp -q -r "$TARGET_HOST":~/.config/mako/* "$REPO_DIR/config/mako/"
        scp -q "$TARGET_HOST":~/.config/starship.toml "$REPO_DIR/config/" 2>/dev/null || true
        scp -q "$TARGET_HOST":~/.config/chrome-flags.conf "$REPO_DIR/config/" 2>/dev/null || true
        scp -q -r "$TARGET_HOST":~/.config/systemd/user/* "$REPO_DIR/config/systemd/user/" 2>/dev/null || true

        echo "==> Pulling scripts from $TARGET_HOST:~/.local/bin/..."
        for f in "$REPO_DIR"/scripts/bin/*; do
            [ -f "$f" ] || continue
            name="$(basename "$f")"
            scp -q "$TARGET_HOST:~/.local/bin/$name" "$REPO_DIR/scripts/bin/" 2>/dev/null || true
        done
        echo "==> Pull complete."
        ;;

    push)
        echo "==> Pushing configs to $TARGET_HOST..."
        scp -q -r "$REPO_DIR/config/hypr/"* "$TARGET_HOST":~/.config/hypr/
        scp -q -r "$REPO_DIR/config/waybar/"* "$TARGET_HOST":~/.config/waybar/
        scp -q -r "$REPO_DIR/config/kitty/"* "$TARGET_HOST":~/.config/kitty/
        scp -q -r "$REPO_DIR/config/wofi/"* "$TARGET_HOST":~/.config/wofi/
        scp -q -r "$REPO_DIR/config/mako/"* "$TARGET_HOST":~/.config/mako/
        ssh "$TARGET_HOST" "mkdir -p ~/.config/swaync"
        scp -q -r "$REPO_DIR/config/swaync/"* "$TARGET_HOST":~/.config/swaync/
        scp -q "$REPO_DIR/config/starship.toml" "$TARGET_HOST":~/.config/ 2>/dev/null || true
        scp -q "$REPO_DIR/config/chrome-flags.conf" "$TARGET_HOST":~/.config/ 2>/dev/null || true

        echo "==> Pushing scripts to $TARGET_HOST:~/.local/bin/..."
        for f in "$REPO_DIR"/scripts/bin/*; do
            [ -f "$f" ] || continue
            name="$(basename "$f")"
            scp -q "$f" "$TARGET_HOST:~/.local/bin/$name"
            ssh "$TARGET_HOST" "chmod +x ~/.local/bin/$name"
        done

        echo "==> Deploy complete. Reloading desktop components..."
        ssh "$TARGET_HOST" 'export XDG_RUNTIME_DIR="/run/user/$(id -u)"; export WAYLAND_DISPLAY="$(ls "$XDG_RUNTIME_DIR"/wayland-* 2>/dev/null | head -n 1 | xargs -r basename)"; export HYPRLAND_INSTANCE_SIGNATURE="$(ls -t "$XDG_RUNTIME_DIR"/hypr/ 2>/dev/null | head -n 1)"; hyprctl reload 2>/dev/null || true; killall -SIGUSR2 waybar 2>/dev/null || true; killall mako 2>/dev/null || true; (pgrep swaync >/dev/null && swaync-client -R && swaync-client -rs || nohup swaync >/dev/null 2>&1 &); killall -SIGUSR1 kitty 2>/dev/null || true'
        echo "==> Desktop reloaded."
        ;;

    diff)
        echo "==> Checking diff against $TARGET_HOST..."
        TMP_DIR=$(mktemp -d)
        trap "rm -rf $TMP_DIR" EXIT
        mkdir -p "$TMP_DIR/remote/hypr" "$TMP_DIR/remote/waybar" "$TMP_DIR/remote/kitty"
        
        scp -q -r "$TARGET_HOST":~/.config/hypr/* "$TMP_DIR/remote/hypr/" 2>/dev/null || true
        scp -q -r "$TARGET_HOST":~/.config/waybar/* "$TMP_DIR/remote/waybar/" 2>/dev/null || true
        scp -q -r "$TARGET_HOST":~/.config/kitty/* "$TMP_DIR/remote/kitty/" 2>/dev/null || true

        echo "--- hypr ---"
        diff -ruN "$REPO_DIR/config/hypr" "$TMP_DIR/remote/hypr" || true
        echo "--- waybar ---"
        diff -ruN "$REPO_DIR/config/waybar" "$TMP_DIR/remote/waybar" || true
        echo "--- kitty ---"
        diff -ruN "$REPO_DIR/config/kitty" "$TMP_DIR/remote/kitty" || true
        ;;

    reload)
        echo "==> Reloading Hyprland, Waybar, and Kitty on $TARGET_HOST..."
        ssh "$TARGET_HOST" 'export XDG_RUNTIME_DIR="/run/user/$(id -u)"; export WAYLAND_DISPLAY="$(ls "$XDG_RUNTIME_DIR"/wayland-* 2>/dev/null | head -n 1 | xargs -r basename)"; export HYPRLAND_INSTANCE_SIGNATURE="$(ls -t "$XDG_RUNTIME_DIR"/hypr/ 2>/dev/null | head -n 1)"; hyprctl reload 2>/dev/null || true; killall -SIGUSR2 waybar 2>/dev/null || true; killall -SIGUSR1 kitty 2>/dev/null || true'
        echo "==> Reloaded."
        ;;

    *)
        usage
        ;;
esac
