local gears = require("gears")
local beautiful = require("beautiful")

-- Themes define colours, icons, font and wallpapers.
beautiful.init(gears.filesystem.get_themes_dir() .. "default/theme.lua")
beautiful.wallpaper = "/home/nikola/pictures/wallpaper/sunless_sea_eye.jpg"

beautiful.hotkeys_modifiers_fg = '#aaaaaa'

local function set_wallpaper(screen)
    if beautiful.wallpaper then
        local wallpaper = beautiful.wallpaper
        if type(wallpaper) == "function" then
            wallpaper = wallpaper(screen)
        end

        gears.wallpaper.maximized(wallpaper, screen, true)
    end
end

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", set_wallpaper)

client.connect_signal("focus", function(c)
    c.border_color = beautiful.border_focus
end)

client.connect_signal("unfocus", function(c)
    c.border_color = beautiful.border_normal
end)

return {
    beautiful = beautiful,
    set_wallpaper = set_wallpaper,
}
