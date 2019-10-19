local awful = require("awful")

local Grid = {}

Grid.new = function()
    local self = {
        name = "grid",
        cols = {},
        rows = {{}},
        clients = {},
    }

    self.arrange = function(params)
        local naughty = require("naughty")

        -- naughty.notify({
        --     preset = naughty.config.presets.critical,
        --     title = "arrange",
        --     text = table.to_string(params) .. "\n" ..
        --         -- "workarea => " .. table.to_string(params.workarea) .. "\n" ..
        --         -- "geometries =>" .. table.to_string(params.geometries) .. "\n" ..
        --         -- "geometry => " .. table.to_string(params.geometry) .. "\n" ..
        --         -- "clients =>" .. table.to_string(params.clients) .. "\n" ..
        --         -- "padding =>" .. table.to_string(params.padding) .. "\n" ..
        --         -- "\n" .. table.to_string(self) ..
        --         -- "clients => " .. table.to_string(self.clients) .."\n" ..
        --         "rows => " .. table.to_string(self.rows) .."\n" ..
        --         "cols => " .. table.to_string(self.cols) .."\n" ..
        --         ""
        --     })

        local cls = params.clients
        local wa = params.workarea

        local modified = false

        for _, c in pairs(cls) do
            -- naughty.notify({
            --     preset = naughty.config.presets.critical,
            --     title = "client",
            --     text = tostring(c)
            --     })

            if self.clients[c] == nil then
                table.insert(self.cols, {})

                local start_row = #self.rows
                local start_col = #self.cols

                self.clients[c] = {
                    col_start = start_col - 1,
                    col_end = start_col,
                    row_start = start_row - 1,
                    row_end = start_row,
                }

                modified = true
            end
        end

        if modified == false then
            return nil
        end

        for c, v in pairs(self.clients) do
            local start_x = wa.x + math.floor(v.col_start * (1.0 / #self.cols) * wa.width)
            local end_x = wa.x + math.floor(v.col_end * (1.0 / #self.cols) * wa.width)
            local start_y = wa.y + math.floor(v.row_start * (1.0 / #self.rows) * wa.height)
            local end_y = wa.y + math.floor(v.row_end * (1.0 / #self.rows) * wa.height)

            naughty.notify({
                preset = naughty.config.presets.critical,
                title = "geom",
                text = table.to_string({x = start_x, y = start_y, width = end_x - start_x, height = end_y - start_y})
            })

            c:geometry({
                x = start_x,
                y = start_y,
                width = end_x - start_x,
                height = end_y - start_y
            })
        end
    end

    return self
end

return {
    Grid = Grid
}
