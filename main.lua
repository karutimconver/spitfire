require "src/globals"
require "src/draw/font"
require "src/draw/draw"
require "src/3drendering/main3d"

local love = require("love")
local maid64 = require("lib/maid64")

function love.load()
    maid64.setup(SCREEN_WIDTH, SCREEN_HEIGHT)
    init3d()
end

function love.update(dt)
    --print(love.graphics.getWidth())
    --print(love.graphics.getHeight())
    update3d()
end

function love.draw()
    maid64.start()
    love.graphics.clear(12 / 255, 120 / 255, 255 / 255, 1)
    draw3d()
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