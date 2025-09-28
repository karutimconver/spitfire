require "src/globals"

local love = require "love"

local function inputBox(x, y, max_length, text)
    return {
        x = x,
        y = y,
        lenght = max_length,
        width = max_length * 3 + max_length - 1,

        draw = function (self)
        end
    }
end

return inputBox