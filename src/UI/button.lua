require "src/draw/draw"
require "src/globals"
local love = require "love"

local function Button(x, y, width, height, func, text, color, text_color, hover_color)
    if color and #color == 3 then table.insert(color, 1) end
    if text_color and #text_color == 3 then table.insert(color, 1) end
    if hover_color and #hover_color == 3 then table.insert(color, 1) end

    return {
        text = text or "no text!",
        func = func or function () print("pressed!") end,
        x = x,
        y = y,
        width = width,
        height = height,
        color = color or {1, 1, 1, 1},
        text_color = text_color or {1, .5, .5, 1},

        checkHover = function (self)
            local x = love.mouse.getX() / love.graphics.getWidth() * SCREEN_WIDTH
            local y = love.mouse.getY() / love.graphics.getHeight() * SCREEN_HEIGHT

            if self.x - self.width / 2 < x and x < self.x + self.width / 2 and 
               self.y - self.height / 2 < y and y < self.y + self.height / 2 then
                    return true
            end

            return false
        end,

        clicked = function (self, args)
            if args then
                self.func(unpack(args))
            else
                self.func()
            end
        end,

        draw = function (self)
            fillRect(self.x, self.y, self.width, self.height, true, self.color)
            drawText(self.text, self.x, self.y, self.text_color)
        end
    }
end

return Button