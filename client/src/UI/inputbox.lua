require "src/globals"

local love = require "love"
local draw = require "src/draw/draw"
local letters = {"a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"}

local function inputBox(x, y, max_length, text)
    return {
        x = x,
        y = y,
        width = max_length * 3 + max_length - 1,
        text = text,

        input = function (self, key)
            if key == "backspace" then
                if #self.text == 0 then
                    return ""
                end
                self.text = self.text:sub(1, -2)
            end

            if #self.text < max_length then
                if table.contains(letters, key) then
                    self.text = self.text .. key
                end
            end

            return self.text
        end,

        draw = function (self)
            drawLine(self.x-self.width/2, self.y+4, self.x+self.width/2, self.y+4)


        end
    }
end

return inputBox