local wibox = require("wibox")

local layouts = { "us", "bg" }
local widget = wibox.widget.textbox()

local set_global_layout = function(i)
    local layout = layouts[i]
    os.execute(table.concat({"setxkbmap", layout}, " "))
    widget:set_text(layout)
end

local new_client = function()
    local i = 1

    local set = function()
        set_global_layout(i)
    end

    local next = function()
        i = i % #layouts + 1
        set()
    end

    local prev = function()
        i = (i + #layouts) % #layouts - 1
        set()
    end

    return {
        next = next,
        prev = prev,
        set = set
    }
end

set_global_layout(1)

return {
    widget = widget,
    new_client = new_client,
}
