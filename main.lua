require "src/globals"
local love = require("love")
local maid64 = require("lib/maid64")

function love.load()
    maid64.setup(SCREEN_WIDTH, SCREEN_HEIGHT)
end

function love.update()
end

function love.draw()
    maid64.start()

    love.graphics.clear(12 / 255, 120 / 255, 255 / 255, 1)
    love.graphics.setColor(255, 255, 255)
    love.graphics.circle("fill", 10, 10, 5)

    maid64.finish()
end

function love.keypressed(key)
    if key == "f11" then
        fullscreen = not fullscreen
        love.window.setFullscreen(fullscreen)
    end
end

function love.resize(w, h)
    maid64.resize(w, h)
end