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

-- Gesture-aligned animations:
hl.animation({ leaf = "specialWorkspace",    enabled = true,  speed = 3.5,  bezier = "easeOutQuint", style = "slidevert" })
hl.animation({ leaf = "specialWorkspaceIn",  enabled = true,  speed = 3.5,  bezier = "easeOutQuint", style = "slidevert" })
hl.animation({ leaf = "specialWorkspaceOut", enabled = true,  speed = 2.5,  bezier = "almostLinear", style = "slidevert" })

hl.animation({ leaf = "layers",              enabled = true,  speed = 3.5,  bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn",            enabled = true,  speed = 3.5,  bezier = "easeOutQuint", style = "slide bottom" })
hl.animation({ leaf = "layersOut",           enabled = true,  speed = 2.5,  bezier = "almostLinear", style = "slide bottom" })

hl.layer_rule({
    name = "wvkbd-touch",
    match = { namespace = "^(wvkbd)$" },
    above_lock = 2,
    blur = true,
    animation = "slide bottom",
})

hl.layer_rule({
    name = "wofi-touch",
    match = { namespace = "^(wofi)$" },
    animation = "slide bottom",
})

hl.layer_rule({
    name = "swaync-control-center-slide",
    match = { namespace = "^(swaync-control-center)$" },
    animation = "slide top",
})

hl.layer_rule({
    name = "swaync-notification-slide",
    match = { namespace = "^(swaync-notification-window)$" },
    animation = "slide right",
})

hl.layer_rule({
    name = "slider-popup-anim",
    match = { namespace = "^(slider-popup)$" },
    animation = "noanim",
    blur = true,
})
