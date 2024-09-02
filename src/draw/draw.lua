local love = require "love"

function _G.drawLine(x1, y1, x2, y2)
    local length = (math.sqrt((x1 - x2) ^ 2 + (y1 - y2) ^ 2))

    local y_step = -(y1 - y2) / length
    local x_step = -(x1 - x2) / length
    print(y_step)
    print(x_step)
    local px = x1
    local py = y1

    for pixel = 0, math.floor(length) do
      love.graphics.points(math.floor(px + 0.5), math.floor(py + 0.5))

      px = (px + x_step)
      py = (py + y_step)
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
    drawPoly(points)
    love.graphics.polygon("fill", points)
end