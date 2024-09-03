require "src/globals"
local font = require "src/draw/font"
local love = require "love"

function _G.drawLine(_x1, _y1, _x2, _y2)
    local x1 = math.floor(_x1 + 0.5); local y1 = math.floor(_y1 + 0.5)
    local x2 = math.floor(_x2 + 0.5); local y2 = math.floor(_y2 + 0.5)

    local length = (math.sqrt((x1 - x2) ^ 2 + (y1 - y2) ^ 2))

    local y_step = -(y1 - y2) / length
    local x_step = -(x1 - x2) / length
    local px = x1
    local py = y1

    for pixel = 0, math.floor(length) do
      love.graphics.points(math.floor(px + 0.5), math.floor(py + 0.5))

      px = (px + x_step)
      py = (py + y_step)
    end
end

------------------
-- Basic Shapes --
------------------

function _G.drawRect(x, y, width, height, center)
    if center then
      drawLine(x - round(width / 2), y + round(height / 2), x - round(width / 2), y - height + round(height / 2))
      drawLine(x - round(width / 2), y + round(height / 2), x + width - round(width / 2), y + round(height / 2))
      drawLine(x + width - round(width / 2), y + round(height / 2), x + width - round(width / 2), y - height + round(height / 2))
      drawLine(x - round(width / 2), y - height + round(height / 2), x + width - round(width / 2), y - height + round(height / 2))
    else
      drawLine(x, y, x, y - height )
      drawLine(x, y, x + width, y)
      drawLine(x + width, y, x + width, y - height)
      drawLine(x, y - height, x + width, y - height)
    end
end

function _G.fillRect(x, y, width, height, center)
    if center then
        love.graphics.rectangle("fill", x - width / 2, y - height / 2, width, height)
    else
        love.graphics.rectangle("fill", x, y, width, height)
    end

    drawRect(x, y,width, height, center)
end

function _G.drawCircle(x, y, radius)
  local px = x
  local py = y

  local d = radius - 1
  local a = radius
  local b = 0

  while a >= b do
    love.graphics.points(px + b, py + a)
    love.graphics.points(px + a, py + b)
    love.graphics.points(px - b, py + a)
    love.graphics.points(px - a, py + b)
    love.graphics.points(px + b, py - a)
    love.graphics.points(px + a, py - b)
    love.graphics.points(px - b, py - a)
    love.graphics.points(px - a, py - b) 

    if d >= 2 * b then
      d=d - 2*b - 1
      b= b + 1
    elseif d < 2*(radius - a) then
      d=d + 2*a - 1
      a=a - 1
    else
      d=d + 2*( a - b - 1)
      a=a - 1
      b=b + 1
    end
  end
end

function _G.fillCircle(x, y, radius)
    for r = 0, radius do
        drawCircle(x, y, r)
    end
end

function _G.drawPoly(points)
    if #points % 2 ~= 0 then
        print("Error! the number of x values is not equal to the number of y values")
        return
    end

    for i = 1, #points, 2 do
        if i ~= #points - 1 then
            drawLine(points[i], points[i+1], points[i+2], points[i+3])
        else
            drawLine(points[i], points[i+1], points[1], points[2])
        end
    end
end

function _G.fillPoly(points)
    local floored = {}
    for i, p in pairs(points) do
        table.insert(floored, math.floor(p))
    end

    love.graphics.polygon("fill", floored)
    drawPoly(points)
end

---------------
-- draw Text --
---------------

function _G.drawGlyph(glyph, x, y, color)
    if glyph == " " then
        return
    end

    if string.len(glyph) ~= 1 then
        print("Error! drawGlyph only draws 1 glyph!")
        return
    end

    glyph = string.upper(glyph)

    local line = -2
    local column = -1

    if font[glyph] == nil then
        print("Error! glyph " .. glyph .. " doesn't exist")
        return
    end

    for _, code in pairs(font[glyph]) do
        if code == 1 then
            love.graphics.setColor(color[1] / 255, color[2] / 255, color[3] / 255)
            love.graphics.points(x + column, y + line)
            love.graphics.setColor(1, 1, 1)
        end

        column = column + 1

        if code == "N" then
            column = -1
            line = line + 1
        elseif code == "E" then
            return
        end
    end

    print("Warning: glyph " .. glyph .. " doesn't have an end flag!")
end

function _G.drawText(text, x, y, color)
    local c = color or {255, 255, 255}
    local w = 3

    local l = string.len(text)

    local lenght = (l * w) + (l - 1)

    local glyph_x = x - math.floor(lenght / 2) + 1

    for glyph in text:gmatch(".") do
        drawGlyph(glyph, glyph_x, y, c)

        glyph_x = glyph_x + w + 1
    end
end