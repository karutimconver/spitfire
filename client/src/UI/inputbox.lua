require "src/globals"
require "src/draw/draw"

local love = require "love"
local sSimbols = {"a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z", " ", ".", "-", "1", "2", "3", "4", "5", "6", "7", "8", "9", "0"}
local cSimbols = {["0"]  = "=", ["1"] = "!", ["'"] = "?", ["-"] = "_", ["4"] = "$"}

local function inputBox(x, y, max_length, text)
    return {
        x = x,
        y = y,
        width = max_length * 3 + max_length,
        text = text or "",

        input = function (self, key)
            if key == "backspace" then
                if #self.text == 0 then
                    return ""
                end
                self.text = self.text:sub(1, -2)
            end

            if #self.text < max_length then
                if table.contains(table.keys(cSimbols), key) then
                    if love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift") then
                        self.text = self.text .. cSimbols[key]
                    end
                elseif table.contains(sSimbols, key) then
                    self.text = self.text .. key
                end
            end

            return self.text
        end,

        draw = function (self)
            drawLine(self.x-self.width/2, self.y+4, self.x+self.width/2, self.y+4)
            drawText(self.text, self.x, self.y)
        end
    }
end

return inputBox