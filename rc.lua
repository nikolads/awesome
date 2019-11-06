require("src/core_ext")

-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
local menubar = require("menubar")

-- Handle awesome errors
require("src/errors")

local kb_layout = require("src/keys/layout")
local binding = require("src/keys/binding")
local theme = require("src/theme")

local hotkeys_popup = require("awful.hotkeys_popup").widget.new({labels = binding.AWFUL_LABELS})

-- This is used later as the default terminal and editor to run.
terminal = "kitty"
editor = os.getenv("EDITOR") or "nano"
editor_cmd = terminal .. " -e " .. editor

-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = {
    awful.layout.suit.max,
    -- awful.layout.suit.floating,
    awful.layout.suit.tile.right,
    awful.layout.suit.tile.bottom,
}
-- }}}

local modkey = "Mod4"

-- {{{ Helper functions
local function client_menu_toggle_fn()
    local instance = nil

    return function ()
        if instance and instance.wibox.visible then
            instance:hide()
            instance = nil
        else
            instance = awful.menu.clients({ theme = { width = 250 } })
        end
    end
end
-- }}}

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- {{{ Wibar
-- Create a textclock widget
mytextclock = wibox.widget.textclock()

-- Create a wibox for each screen and add it
local taglist_buttons = gears.table.join(
    awful.button({ }, 1, function(t) t:view_only() end),
    awful.button({ modkey }, 1, function(t) if client.focus then client.focus:move_to_tag(t) end end),
    awful.button({ }, 3, awful.tag.viewtoggle),
    awful.button({ modkey }, 3, function(t) if client.focus then client.focus:toggle_tag(t) end end),
    awful.button({ }, 4, function(t) awful.tag.viewnext(t.screen) end),
    awful.button({ }, 5, function(t) awful.tag.viewprev(t.screen) end)
)

local tasklist_buttons = gears.table.join(
    awful.button({ }, 1, function (c)
        if c == client.focus then
            c.minimized = true
        else
            -- Without this, the following :isvisible() makes no sense
            c.minimized = false
            if not c:isvisible() and c.first_tag then
                c.first_tag:view_only()
            end
            -- This will also un-minimize the client, if needed
            client.focus = c
            c:raise()
        end
    end),
    awful.button({ }, 3, client_menu_toggle_fn()),
    awful.button({ }, 4, function () awful.client.focus.byidx(1) end),
    awful.button({ }, 5, function () awful.client.focus.byidx(-1) end)
)

awful.screen.connect_for_each_screen(function(s)
    -- Wallpaper
    theme.set_wallpaper(s)

    -- Each screen has its own tag table.
    awful.tag({ "~", "1", "2", "3", "4", "5", "6", "7", "8", "9" }, s, awful.layout.layouts[1])
    s.tags[2]:view_only()

    -- Create a promptbox for each screen
    s.mypromptbox = awful.widget.prompt()
    -- Create an imagebox widget which will contain an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    s.mylayoutbox = awful.widget.layoutbox(s)
    s.mylayoutbox:buttons(gears.table.join(
                           awful.button({ }, 1, function () awful.layout.inc( 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(-1) end),
                           awful.button({ }, 4, function () awful.layout.inc( 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(-1) end)))
    -- Create a taglist widget
    s.mytaglist = awful.widget.taglist(s, awful.widget.taglist.filter.all, taglist_buttons)

    -- Create a tasklist widget
    s.mytasklist =  awful.widget.tasklist {
        screen = s,
        filter = awful.widget.tasklist.filter.currenttags,
        buttons = tasklist_buttons,
        widget_template = {
           widget = wibox.container.background,
           id = 'background_role',
           {
                layout = wibox.layout.fixed.horizontal,
                {
                    widget = wibox.container.margin,
                    margins = 3,
                    {
                        widget = wibox.widget.imagebox,
                        id = 'icon_role',
                    },
                },
                {
                    widget = wibox.container.constraint,
                    strategy = "exact",
                    width = 300,
                    {
                        widget = wibox.widget.textbox,
                        id = 'text_role',
                    }
                },
            },
        }
    }
    s.mytasklist = wibox.container.margin(s.mytasklist, 5, 5)

    -- Create the wibox
    s.mywibox = awful.wibar({ position = "top", screen = s })

    -- Add widgets to the wibox
    s.mywibox:setup {
        layout = wibox.layout.align.horizontal,
        { -- Left widgets
            layout = wibox.layout.fixed.horizontal,
            s.mytaglist,
            s.mypromptbox,
        },
        {
            layout = wibox.layout.fixed.horizontal,
            s.mytasklist,
        },
        { -- Right widgets
            layout = wibox.layout.fixed.horizontal,
            wibox.widget.systray(),
            kb_layout.widget,
            wibox.widget.textbox(' |'),
            mytextclock,
            --s.mylayoutbox,
        },
    }
end)
-- }}}

-- {{{ Mouse bindings
-- }}}

-- {{{ Key bindings
globalkeys = gears.table.join(
    binding.key("M-/", function() hotkeys_popup:show_help() end,
        {description = "show help", group = "awesome"}),
    binding.key("M-S-r", awesome.restart, {description = "reload awesome", group = "awesome"}),
    binding.key("M-S-q", awesome.quit, {description = "quit awesome", group = "awesome"}),

    -- Media
    binding.key("XF86MonBrightnessDown", function() awful.util.spawn("xbacklight -10%") end),
    binding.key("XF86MonBrightnessUp", function() awful.util.spawn("xbacklight +10%") end),
    binding.key("XF86AudioMute", function() awful.util.spawn("pactl set-sink-mute @DEFAULT_SINK@ toggle") end),
    binding.key("XF86AudioLowerVolume", function() awful.util.spawn("pactl set-sink-volume @DEFAULT_SINK@ -5%") end),
    binding.key("XF86AudioRaiseVolume", function() awful.util.spawn("pactl set-sink-volume @DEFAULT_SINK@ +5%") end),
    binding.key("XF86AudioMicMute", function() awful.util.spawn("pactl set-source-mute @DEFAULT_SOURCE@ toggle") end),

    -- Layout manipulation
    binding.key("M-Tab",
        function ()
            awful.client.focus.byidx(1)
            if client.focus then
                client.focus:raise()
            end
        end,
        {description = "focus next window", group = "client"}),

    binding.key("M-S-Tab",
        function()
            awful.client.focus.byidx(-1)
            if client.focus then
                client.focus:raise()
            end
        end,
        {description = "focus previous window", group = "client"}),

    binding.key("M-o", function() awful.layout.inc(1) end,
        {description = "next layout", group = "awesome"}),

    binding.key("M-S-o", function() awful.layout.inc(-1) end,
        {description = "prev layout", group = "awesome"}),

    -- Standard programs
    binding.key("M-Return", function() awful.spawn(terminal) end,
        {description = "open a terminal", group = "launcher"}),

    binding.key("M-f", function() awful.spawn("firefox") end,
        {description = "open web browser", group = "launcher"}),

    binding.key("M-S-f", function() awful.spawn("firefox --private-window") end,
        {description = "open web browser (private window)", group = "launcher"}),

    -- Prompt
    binding.key("M-r", function () awful.screen.focused().mypromptbox:run() end,
        {description = "run prompt", group = "launcher"}),

    binding.key("M-x",
        function ()
            awful.prompt.run {
                prompt       = "Run Lua code: ",
                textbox      = awful.screen.focused().mypromptbox.widget,
                exe_callback = awful.util.eval,
                history_path = awful.util.get_cache_dir() .. "/history_eval"
            }
        end,
        {description = "lua execute prompt", group = "awesome"}),

    -- Menubar
    binding.key("M-p", function() menubar.show() end,
        {description = "show the menubar", group = "launcher"}),

    -- Lock screen
    binding.key("M-l",
        function()
            -- TODO: handle keyboard layout
            -- Lock screen will use the last set keyboard layout and there is
            -- no way to change it from inside the lock screen.
            -- This can lead to a screen that cannot be unlocked.
            awful.util.spawn_with_shell('magick import -window root jpg:- ' ..
                '| magick jpg:- -scale 5% +level 0%,60% -scale 2000% png:- ' ..
                '| i3lock -i /dev/stdin')
        end,
        {description = "lock screen", group = "awesome" }),

    -- Keyboard layout
    binding.key("M-space", kb_layout.next_layout,
        {description = "next keyboard layout", group = "awesome"}),
    binding.key("M-S-space", kb_layout.prev_layout,
        {description = "previous keyboard layout", group = "awesome"})
)

clientkeys = gears.table.join(
    --[[
    binding.key("M-f",
        function (c)
            c.fullscreen = not c.fullscreen
            c:raise()
        end,
        {description = "toggle fullscreen", group = "client"}),
    --]]

    binding.key("M-q", function (c) c:kill() end,
        {description = "close", group = "client"}),

    binding.key("M-bracketleft", function() awful.tag.incmwfact(-0.02) end,
        {description = "decrease client width", group = "client"}),
    binding.key("M-bracketright", function() awful.tag.incmwfact(0.02) end,
        {description = "increase client width", group = "client"})


    -- leaved
    --[[
    binding.key("M-y", leaved.keys.shiftOrder),
    binding.key("M-t", leaved.keys.shiftStyle),
    binding.key("M-S-h", leaved.keys.splitH),
    binding.key("M-S-v", leaved.keys.splitV),
    binding.key("M-comma", leaved.keys.swap),
    binding.key("M-period", leaved.keys.focus),
    binding.key("M-S-period", leaved.keys.focus_container),
    binding.key("M-n", leaved.keys.min_container),
    binding.key("M-b", leaved.keys.select_use_container)
    --]]
)

-- Bind all key numbers to tags.
local function handle_tag(key, i)
    globalkeys = gears.table.join(globalkeys,
        -- View tag only.
        binding.key("M-" .. key,
                  function ()
                        local screen = awful.screen.focused()
                        local tag = screen.tags[i]
                        if tag then
                           tag:view_only()
                        end
                  end,
                  {description = "view tag #"..i, group = "tag"}),
        -- Toggle tag display.
        binding.key("M-C-" .. key,
                  function ()
                      local screen = awful.screen.focused()
                      local tag = screen.tags[i]
                      if tag then
                         awful.tag.viewtoggle(tag)
                      end
                  end,
                  {description = "toggle tag #" .. i, group = "tag"}),
        -- Move client to tag.
        binding.key("M-S-" .. key,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:move_to_tag(tag)
                          end
                     end
                  end,
                  {description = "move focused client to tag #"..i, group = "tag"}),
        -- Toggle tag on focused client.
        binding.key("M-C-S-" .. key,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:toggle_tag(tag)
                          end
                      end
                  end,
                  {description = "toggle focused client on tag #" .. i, group = "tag"})
    )
end

for i = 1, 9 do
    handle_tag(i, i + 1)
end
handle_tag('grave', 1)

clientbuttons = gears.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
    -- All clients will match this rule.
    {
        rule = {},
        properties = {
            border_width = theme.beautiful.border_width,
            border_color = theme.beautiful.border_normal,
            focus = awful.client.focus.filter,
            raise = true,
            keys = clientkeys,
            buttons = clientbuttons,
            screen = awful.screen.preferred,
            placement = awful.placement.no_overlap + awful.placement.no_offscreen
        }
    },

    -- Floating clients.
    {
        rule_any = {
            role = { "pop-up",}
        },
        properties = {
            floating = true
        }
    },

    -- Add titlebars to normal clients and dialogs
    {
        rule_any = {
            type = { "normal", "dialog" }
        },
        properties = {
            titlebars_enabled = true
        }
    },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c)
    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
    if not awesome.startup then awful.client.setslave(c) end

    if awesome.startup
        and not c.size_hints.user_position
        and not c.size_hints.program_position
    then
        -- Prevent clients from being unreachable after screen count changes.
        awful.placement.no_offscreen(c)
    end
end)

-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal("request::titlebars", function(c)
    -- buttons for the titlebar
    local buttons = gears.table.join(
        awful.button({ }, 1, function()
            client.focus = c
            c:raise()
            awful.mouse.client.move(c)
        end),
        awful.button({ }, 3, function()
            client.focus = c
            c:raise()
            awful.mouse.client.resize(c)
        end)
    )

    if client.focus == c then
        awful.titlebar(c):setup {
            { -- Left
                awful.titlebar.widget.iconwidget(c),
                buttons = buttons,
                layout  = wibox.layout.fixed.horizontal
            },
            { -- Middle
                { -- Title
                    align  = "center",
                    widget = awful.titlebar.widget.titlewidget(c)
                },
                buttons = buttons,
                layout  = wibox.layout.flex.horizontal
            },
            { -- Right
                awful.titlebar.widget.closebutton(c),
                layout = wibox.layout.fixed.horizontal()
            },
            layout = wibox.layout.align.horizontal
        }
    end
end)
-- }}}
