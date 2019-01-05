-- Extensions to the lua core library

-- Convert table to string.
--
-- Note: this is not recursive, because a recursive function would cause
-- an endless loop with tables that mutualy reference each other.
function table:to_string()
    local str = "{"

    for k, v in pairs(self) do
        str = str .. tostring(k) .. "=" .. tostring(v) .. ","
    end

    str = str .. "}"

    return str
end

-- Split a string by a pattern
function string:split(pattern)
    local t = {}
    local i = 1

    while i do
        local s, e = string.find(self, pattern, i)
        local sub = string.sub(self, i, s ~= nil and s - 1 or nil)
        table.insert(t, sub)
        i = e ~= nil and e + 1 or nil
    end

    return t
end
