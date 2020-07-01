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
terminal = "/home/nikola/bin/kitty-launch.sh"
editor = os.getenv("EDITOR") or "vim"
editor_cmd = terminal .. " -e " .. editor

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
widget_text_clock = wibox.widget.textclock()

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
    local default_layout = awful.layout.suit.max
    awful.tag({ "~", "1", "2", "3", "4", "5", "6", "7", "8", "9" }, s, default_layout)
    s.tags[2]:view_only()

    -- Create a promptbox for each screen
    local mypromptbox = awful.widget.prompt()

    -- Create a list of tags
    local widget_tag_list = awful.widget.taglist(s, awful.widget.taglist.filter.all, taglist_buttons)

    -- Create a list of windows on this tag
    local widget_task_list =  awful.widget.tasklist {
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
    local widget_task_list = wibox.container.margin(widget_task_list, 5, 5)

    -- Create the bar wibox and populate it with widgets
    local my_bar = awful.wibar({ position = "top", screen = s })
    my_bar:setup {
        layout = wibox.layout.align.horizontal,
        { -- Left widgets
            layout = wibox.layout.fixed.horizontal,
            widget_tag_list,
            mypromptbox,
        },
        {
            layout = wibox.layout.fixed.horizontal,
            widget_task_list,
        },
        { -- Right widgets
            layout = wibox.layout.fixed.horizontal,
            wibox.widget.systray(),
            kb_layout.widget,
            wibox.widget.textbox(' |'),
            widget_text_clock,
        }
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

    binding.key("M-C-Left", function () awful.screen.focus_relative(-1) end,
        {description = "focus next screen", group = "screen"}),
    binding.key("M-C-Right", function () awful.screen.focus_relative( 1) end,
        {description = "focus prev screen", group = "screen"}),

    binding.key("M-a", awful.client.movetoscreen,
        {description = "move to another screen", group = "screen"}),

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
        {description = "focus prev window", group = "client"}),

    binding.key("M-[",
        function()
            awful.client.focus.byidx(-1)
            if client.focus then
                client.focus:raise()
            end
        end,
        {description = "focus prev window", group = "layout"}),

    binding.key("M-]",
        function ()
            awful.client.focus.byidx(1)
            if client.focus then
                client.focus:raise()
            end
        end,
        {description = "focus next window", group = "layout"}),

    binding.key("M-S-[", function() awful.client.swap.byidx(-1) end,
        {description = "swap with prev window", group = "layout"}),

    binding.key("M-S-]", function() awful.client.swap.byidx(1) end,
        {description = "swap with next window", group = "layout"}),

    binding.key("M-z", function() awful.layout.set(awful.layout.suit.max) end,
        {description = "set layout to MAX", group = "layout" }),
    binding.key("M-x", function() awful.layout.set(awful.layout.suit.tile.right) end,
        {description = "set layout to TILE RIGHT", group = "layout" }),
    binding.key("M-S-x", function() awful.layout.set(awful.layout.suit.tile.left) end,
        {description = "set layout to TILE LEFT", group = "layout" }),
    binding.key("M-c", function() awful.layout.set(awful.layout.suit.tile.bottom) end,
        {description = "set layout to TILE BOTTOM", group = "layout" }),
    binding.key("M-S-c", function() awful.layout.set(awful.layout.suit.tile.top) end,
        {description = "set layout to TILE TOP", group = "layout" }),

    binding.key("M-,", function () awful.tag.incmwfact(-0.05) end,
        {description = "dec master width", group = "layout param"}),
    binding.key("M-.", function () awful.tag.incmwfact( 0.05) end,
        {description = "inc master width", group = "layout param"}),

    binding.key("M-m", function() awful.tag.incnmaster(1, nil, true) end,
        {description = "inc number of masters", group = "layout param"}),
    binding.key("M-S-m", function() awful.tag.incnmaster(-1, nil, true) end,
        {description = "dec number of masters", group = "layout param"}),

    binding.key("M-n", function() awful.tag.incncol(1, nil, true) end,
        {description = "inc number of columns", group = "layout param"}),
    binding.key("M-S-n", function() awful.tag.incncol(-1, nil, true) end,
        {description = "dec number of columns", group = "layout param"}),

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

    -- binding.key("M-x",
    --     function ()
    --         awful.prompt.run {
    --             prompt       = "Run Lua code: ",
    --             textbox      = awful.screen.focused().mypromptbox.widget,
    --             exe_callback = awful.util.eval,
    --             history_path = awful.util.get_cache_dir() .. "/history_eval"
    --         }
    --     end,
    --     {description = "lua execute prompt", group = "awesome"}),

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
            awful.util.spawn_with_shell(
                'magick /home/nikola/pictures/wallpaper/crypt_of_the_necrodancer.jpg -resize 1920x1080! rgb:- ' ..
                '| i3lock --raw 1920x1080:rgb --image /dev/stdin --tiling')
        end,
        {description = "lock screen", group = "awesome" }),

    -- Keyboard layout
    binding.key("M-space", kb_layout.next_layout,
        {description = "next keyboard layout", group = "awesome"}),
    binding.key("M-S-space", kb_layout.prev_layout,
        {description = "prev keyboard layout", group = "awesome"})
)

clientkeys = gears.table.join(
    binding.key("M-h",
        function (c)
            c.fullscreen = not c.fullscreen
            c:raise()
        end,
        {description = "toggle fullscreen", group = "client"}),

    binding.key("M-q", function (c) c:kill() end,
        {description = "close", group = "client"})
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
handle_tag('`', 1)

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
