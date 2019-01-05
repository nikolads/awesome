local awful = require('awful')

local modkey = "Mod4"

local split_mods = function(keys)
    local mods = {}
    local key_name = nil

    for _, part in ipairs(string.split(keys, "-")) do
        if     part == "M" then table.insert(mods, modkey)
        elseif part == "C" then table.insert(mods, "Control")
        elseif part == "S" then table.insert(mods, "Shift")
        elseif part == "A" then table.insert(mods, "Alt")
        else   key_name = part end
    end

    return mods, key_name
end

local key = function(keys, action, desc)
    local mods, key_name = split_mods(keys)

    return awful.key(mods, key_name, action, desc)
end

return {
    key = key
}
