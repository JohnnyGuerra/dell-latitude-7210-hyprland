-- ==========================================================
-- Omarchy Hyprland Configuration for Dell Latitude 7210 2-in-1
-- ==========================================================

------------------
---- MONITORS ----
------------------
-- Dell 7210 12.3" 1920x1280 (3:2) display
hl.monitor({
    output   = "eDP-1",
    mode     = "1920x1280@60.005",
    position = "0x0",
    scale    = "1.33",
})

hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = "auto",
})

---------------------
---- MY PROGRAMS ----
---------------------
local terminal    = "kitty"
local fileManager = "nautilus"
local menu        = "wofi --show drun"

-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("GDK_BACKEND", "wayland,x11,*")
hl.env("CLUTTER_BACKEND", "wayland")
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")

-----------------------
---- LOOK AND FEEL ----
-----------------------
hl.config({
    general = {
        gaps_in  = 5,
        gaps_out = 10,
        border_size = 2,
        col = {
            active_border   = { colors = {"rgba(cba6f7ee)", "rgba(89b4faee)"}, angle = 45 },
            inactive_border = "rgba(495068aa)",
        },
        resize_on_border = true,
        allow_tearing = false,
        layout = "dwindle",
    },

    decoration = {
        rounding       = 10,
        rounding_power = 2,
        active_opacity   = 1.0,
        inactive_opacity = 0.95,
        shadow = {
            enabled      = true,
            range        = 8,
            render_power = 3,
            color        = 0xee1a1a1a,
        },
        blur = {
            enabled   = true,
            size      = 4,
            passes    = 2,
            vibrancy  = 0.17,
        },
    },

    animations = {
        enabled = true,
    },
})

hl.config({
    dwindle = {
        preserve_split = true,
    },
})

hl.config({
    misc = {
        force_default_wallpaper = 0,
        disable_hyprland_logo   = true,
    },
})

hl.config({
    input = {
        kb_layout  = "us",
        follow_mouse = 1,
        sensitivity = 0,
        touchpad = {
            natural_scroll = false,
            scroll_factor = 1.0,
            tap_to_click = true,
            clickfinger_behavior = true,
            middle_button_emulation = true,
        },
    },
})

--------------------
---- ANIMATIONS ----
--------------------
hl.curve("easeOutQuint",   { type = "bezier", points = { {0.23, 1},    {0.32, 1}    } })
hl.curve("easeInOutCubic", { type = "bezier", points = { {0.65, 0.05}, {0.36, 1}    } })
hl.curve("almostLinear",   { type = "bezier", points = { {0.5, 0.5},   {0.75, 1}    } })
hl.curve("quick",          { type = "bezier", points = { {0.15, 0},    {0.1, 1}     } })
hl.curve("easy",           { type = "spring", mass = 1, stiffness = 238.12, dampening = 24.21 })

hl.animation({ leaf = "global",        enabled = true,  speed = 8,    bezier = "default" })
hl.animation({ leaf = "border",        enabled = true,  speed = 5,    bezier = "easeOutQuint" })
hl.animation({ leaf = "windows",       enabled = true,  speed = 4.5,  spring = "easy" })
hl.animation({ leaf = "windowsIn",     enabled = true,  speed = 4,    spring = "easy",         style = "popin 87%" })
hl.animation({ leaf = "windowsOut",    enabled = true,  speed = 2,    bezier = "almostLinear", style = "popin 87%" })
hl.animation({ leaf = "fadeIn",        enabled = true,  speed = 2,    bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut",       enabled = true,  speed = 2,    bezier = "almostLinear" })
hl.animation({ leaf = "workspaces",    enabled = true,  speed = 3,    bezier = "easeOutQuint", style = "slide" })

----------------------------------------
---- TOUCH & TABLET GESTURES (7210) ----
----------------------------------------
hl.gesture({
    fingers = 3,
    direction = "horizontal",
    action = "workspace"
})

---------------------
---- KEYBINDINGS ----
---------------------
local mainMod = "SUPER"

-- Core Apps & Window Controls
hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + Q",      hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + D",      hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + E",      hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + C",      hl.dsp.window.close())
hl.bind(mainMod .. " + W",      hl.dsp.window.close())
hl.bind(mainMod .. " + V",      hl.dsp.exec_cmd(os.getenv("HOME") .. "/.local/bin/clipboard-history"))
hl.bind(mainMod .. " + SHIFT + V",hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + SHIFT + S",hl.dsp.exec_cmd(os.getenv("HOME") .. "/.local/bin/take-screenshot"))
hl.bind(mainMod .. " + K",      hl.dsp.exec_cmd(os.getenv("HOME") .. "/.local/bin/toggle-keyboard"))
hl.bind(mainMod .. " + F",      hl.dsp.window.fullscreen())
hl.bind(mainMod .. " + P",      hl.dsp.window.pseudo())
hl.bind(mainMod .. " + J",      hl.dsp.layout("togglesplit"))
hl.bind(mainMod .. " + M",      hl.dsp.exec_cmd(os.getenv("HOME") .. "/.local/bin/session-exit-prompt"))

-- Lock screen, Theme switcher & Omarchy Control Hub
hl.bind(mainMod .. " + L",           hl.dsp.exec_cmd("hyprlock"))
hl.bind(mainMod .. " + ALT + Space", hl.dsp.exec_cmd(os.getenv("HOME") .. "/.local/bin/omarchy-menu"))
hl.bind(mainMod .. " + ALT + T",     hl.dsp.exec_cmd(os.getenv("HOME") .. "/.local/bin/omarchy-theme"))
hl.bind(mainMod .. " + G",           hl.dsp.exec_cmd("kitty --class lazygit-float -e lazygit"))
hl.bind(mainMod .. " + ALT + M",     hl.dsp.exec_cmd("kitty --class ytfzf-music -e ytm"))

-- Focus navigation (Arrows)
hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "down" }))

-- Workspaces 1-9
for i = 1, 9 do
    hl.bind(mainMod .. " + " .. i,         hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. i, hl.dsp.window.move({ workspace = i }))
end

-- Mouse window manipulation
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Hardware keys (Dell 7210 Audio & Brightness)
hl.bind("XF86PowerOff", hl.dsp.exec_cmd(os.getenv("HOME") .. "/.local/bin/session-exit-prompt"), { locked = true })
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      { locked = true, repeating = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     { locked = true, repeating = true })
hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),   { locked = true, repeating = true })

-- Media Playback Controls (Hardware keys + Bluetooth headsets)
hl.bind("XF86AudioPlay",        hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPause",       hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioNext",        hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPrev",        hl.dsp.exec_cmd("playerctl previous"),   { locked = true })
hl.bind("XF86AudioStop",        hl.dsp.exec_cmd("playerctl stop"),       { locked = true })

-- Tablet/Folio Media Shortcuts (Super + \ to toggle, Super + ] next, Super + [ prev)
hl.bind(mainMod .. " + backslash",    hl.dsp.exec_cmd("playerctl play-pause"))
hl.bind(mainMod .. " + bracketright", hl.dsp.exec_cmd("playerctl next"))
hl.bind(mainMod .. " + bracketleft",  hl.dsp.exec_cmd("playerctl previous"))
hl.bind("XF86MonBrightnessUp",  hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"),                  { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown",hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"),                  { locked = true, repeating = true })

-- Dell 7210 Tablet Screen Rotation (Super + Shift + R) & Refresh Rate Toggle (Super + Shift + D)
hl.bind(mainMod .. " + SHIFT + R", hl.dsp.exec_cmd(os.getenv("HOME") .. "/.local/bin/rotate-screen"))
hl.bind(mainMod .. " + SHIFT + D", hl.dsp.exec_cmd(os.getenv("HOME") .. "/.local/bin/toggle-refresh-rate"))
hl.bind(mainMod .. " + SHIFT + E", hl.dsp.exec_cmd(os.getenv("HOME") .. "/.local/bin/toggle-eco-mode"))

-- Omarchy AI Agent Emulation (herdr + agy)
hl.bind(mainMod .. " + Space",       hl.dsp.workspace.toggle_special("agent"))
hl.bind(mainMod .. " + S",           hl.dsp.workspace.toggle_special("agent"))
hl.bind(mainMod .. " + SHIFT + C",   hl.dsp.exec_cmd(os.getenv("HOME") .. "/.local/bin/ai-debug-crash"))

-- Keybindings Cheatsheet (Super + ? / Super + /)
hl.bind(mainMod .. " + slash",         hl.dsp.exec_cmd(os.getenv("HOME") .. "/.local/bin/hypr-cheatsheet"))
hl.bind(mainMod .. " + SHIFT + slash", hl.dsp.exec_cmd(os.getenv("HOME") .. "/.local/bin/hypr-cheatsheet"))

--------------------------------
---- WINDOW & WORKSPACE RULES --
--------------------------------
hl.layer_rule({
    name = "wvkbd-blur",
    match = "wvkbd",
    blur = true,
    
})

hl.workspace_rule({
    workspace = "special:agent",
    gaps_out = 14,
    gaps_in = 8,
    on_created_empty = os.getenv("HOME") .. "/.local/bin/agent-scratchpad",
})

hl.window_rule({
    name = "agent-terminal-float",
    match = { class = "agent-terminal" },
    workspace = "special:agent",
    float = true,
    center = true,
})

hl.window_rule({
    name = "fullscreen-no-border",
    match = { fullscreen = true },
    border_size = 0,
    rounding = 0,
})

hl.window_rule({
    name = "lazygit-float",
    match = { class = "lazygit-float" },
    float = true,
    size = "85% 85%",
    center = true,
})

hl.window_rule({
    name = "ytfzf-music-float",
    match = { class = "ytfzf-music" },
    float = true,
    size = "85% 85%",
    center = true,
})

hl.window_rule({
    name = "suppress-maximize-events",
    match = { class = ".*" },
    suppress_event = "maximize",
})

-------------------
---- AUTOSTART ----
-------------------
hl.on("hyprland.start", function ()
    hl.exec_cmd("waybar")
    hl.exec_cmd("swaync")
    hl.exec_cmd("hyprpaper")
    hl.exec_cmd("hypridle")
    hl.exec_cmd("wl-paste --watch cliphist store")
end)
