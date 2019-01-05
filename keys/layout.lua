-- Keyboard layout switching logic and widget

local wibox = require("wibox")

local available_layouts = { "us", "bg" }
local widget = wibox.widget.textbox()

local set_system_layout = function(i)
    local layout = available_layouts[i]
    os.execute(table.concat({"setxkbmap", layout}, " "))
    widget:set_text(layout)
end

local Layout = {}

function Layout.new(initial)
    local obj = {
        i = initial and initial.i or 1,
    }

    setmetatable(obj, Layout.prototype)
    return obj
end

Layout.prototype = {
    set = function(self)
        set_system_layout(self.i)
    end,

    next = function(self)
        self.i = self.i % #available_layouts + 1
        self:set()
    end,

    prev = function(self)
        self.i = (self.i + #available_layouts) % #available_layouts - 1
        self:set()
    end,
}
Layout.prototype.__index = Layout.prototype

local global_layout = Layout.new()
global_layout:set()

client.connect_signal("manage", function (c)
    c.kb_layout = Layout.new(global_layout)
    c.kb_layout:set()
end)

client.connect_signal("focus", function(c)
    c.kb_layout:set()
end)

client.connect_signal("unfocus", function(c)
    global_layout:set()
end)

local next_layout = function()
    if client.focus then
        client.focus.kb_layout:next()
    else
        global_layout:next()
    end
end

local prev_layout = function()
    if client.focus then
        client.focus.kb_layout:prev()
    else
        global_layout:prev()
    end
end

return {
    widget = widget,
    next_layout = next_layout,
    prev_layout = prev_layout,
}
