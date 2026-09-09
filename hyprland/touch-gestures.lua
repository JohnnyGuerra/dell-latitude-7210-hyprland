-- ==============================================================================
-- Dell Latitude 7210 2-in-1: Touch & Tablet Gestures for Hyprland 0.56+ (Lua)
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

-- Multi-Finger Gestures
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
            hl.dsp.workspace.toggle_special(agent)
        end
    }
})

hl.gesture({
    fingers = 4,
    direction = vertical,
    action = {
        finish = function()
            hl.dsp.exec_cmd(os.getenv(HOME) .. /.local/bin/toggle-keyboard)
        end
    }
})

hl.gesture({
    fingers = 4,
    direction = horizontal,
    action = {
        finish = function()
            hl.dsp.exec_cmd(wofi --show drun)
        end
    }
})
