local awful = require("awful")

-- Tree layout
local Tree = {}

Tree.new = function()
    local self = {
        name = "tree",
        clients = {},

        root = {
            type = "vert",
            children = {},
        },
    }

    --[[
-- tree {
--  type = "stack",
--  client { firefox }
--  tree {
--      type = "vert"
--      chient { left kitty, "master" },
--      tree {
--          client { top right kitty },
--          client { bot right kitty },
--      }
--  },
--}
--
--
    --]]

    local arrange = function(params)
        local naughty = require("naughty")

        naughty.notify {
             preset = naughty.config.presets.critical,
             title = "arrange",
             text = table.to_string(params) .. "\n" ..
        --         -- "workarea => " .. table.to_string(params.workarea) .. "\n" ..
        --         -- "geometries =>" .. table.to_string(params.geometries) .. "\n" ..
        --         -- "geometry => " .. table.to_string(params.geometry) .. "\n" ..
        --         -- "clients =>" .. table.to_string(params.clients) .. "\n" ..
        --         -- "padding =>" .. table.to_string(params.padding) .. "\n" ..
        --         -- "\n" .. table.to_string(self) ..
        --         -- "clients => " .. table.to_string(split_horiz) .."\n" ..
        --         -- "rows => " .. table.to_string(self.rows) .."\n" ..
        --         -- "cols => " .. table.to_string(self.cols) .."\n" ..
                 ""
        }

        local cls = params.clients
        local wa = params.workarea

        -- local modified = false

        for _, c in pairs(cls) do
            if self.clients[c] == nil then
                self.clients[c] = true

                table.insert(self.root.children, c)

                -- modified = true
            end
        end

        -- if modified == false then
        --    return nil
        -- end

        if self.root.type == "vert" then
            local split_x = #self.root.children
            local split_y = 1

            for i, c in pairs(self.root.children) do
                local start_x = wa.x + math.floor((i - 1) * (1.0 / split_x) * wa.width)
                local end_x = wa.x + math.floor(i * (1.0 / split_x) * wa.width)

                local start_y = wa.y
                local end_y = wa.y + wa.height

                -- naughty.notify({
                --     preset = naughty.config.presets.critical,
                --     title = "geom",
                --     text = table.to_string({x = start_x, y = start_y, width = end_x - start_x, height = end_y - start_y})
                -- })

                c:geometry({
                    x = start_x,
                    y = start_y,
                    width = end_x - start_x,
                    height = end_y - start_y
                })
                -- c:raise()
            end
        end
    end

    self.arrange = function(params)
        local status, err = pcall(function() arrange(params) end)

        if not status then
            naughty.notify {
                preset = naughty.config.presets.critical,
                title = "ERR: arrange",
                text = tostring(err),
            }
        end
    end

    return self
end

return {
    Tree = Tree
}
