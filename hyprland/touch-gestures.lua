-- ==============================================================================
-- Dell Latitude 7210 2-in-1: Touchscreen & Touchpad Gestures (Hyprland 0.56+)
-- ==============================================================================

-- Touch Environment Variables
hl.env(MOZ_ENABLE_WAYLAND, 1)
hl.env(GTK_OVERLAY_SCROLLING, 1)

-- Touchscreen Input & Output Association
hl.config({
    input = {
        touchdevice = {
            output = eDP-1,
        },
        tablet = {
            output = eDP-1,
        },
    },
    gestures = {
        workspace_swipe_touch = true,
        workspace_swipe_distance = 250,
        workspace_swipe_invert = true,
    },
})

-- Touchpad Native Multi-Finger Gestures
hl.gesture({
    fingers = 3,
    direction = horizontal,
    action = workspace
})

hl.gesture({
    fingers = 3,
    direction = vertical,
    action = {
        finish = function()
            hl.dispatch(hl.dsp.workspace.toggle_special(agent))
        end
    }
})

hl.gesture({
    fingers = 4,
    direction = vertical,
    action = {
        finish = function()
            hl.dispatch(hl.dsp.exec_cmd(os.getenv(HOME) .. /.local/bin/touch-action keyboard))
        end
    }
})

hl.gesture({
    fingers = 4,
    direction = horizontal,
    action = {
        finish = function()
            hl.dispatch(hl.dsp.exec_cmd(os.getenv(HOME) .. /.local/bin/touch-action launcher))
        end
    }
})
