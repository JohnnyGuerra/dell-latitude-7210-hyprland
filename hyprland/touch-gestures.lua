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

-- Animated vertical sliders dropping from top bar buttons
hl.animation({ leaf = "layers",        enabled = true,  speed = 4,    spring = "easy",         style = "slidevert" })
hl.animation({ leaf = "layersIn",      enabled = true,  speed = 4,    spring = "easy",         style = "slidevert" })
hl.animation({ leaf = "layersOut",     enabled = true,  speed = 3,    bezier = "almostLinear", style = "slidevert" })

hl.layer_rule({
    name = "slider-popup-anim",
    match = "slider-popup",
    animation = "noanim",
    blur = true,
})
