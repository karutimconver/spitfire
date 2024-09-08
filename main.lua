require "src/globals"
require "src/draw/draw"
require "src/3drendering/main3d"

local love = require("love")
local maid64 = require("lib/maid64")

function love.load()
    maid64.setup(SCREEN_WIDTH, SCREEN_HEIGHT)
    init3d()
    _G.pause = false
end

function love.update(dt)
    --print(love.graphics.getWidth())
    --print(love.graphics.getHeight())
    if not pause then
        update3d(dt)
    end
    tris = 0
    print(love.timer.getFPS())
end

function love.draw()
    maid64.start()
    love.graphics.clear(12 / 255, 120 / 255, 255 / 255, 1)
    draw3d()
    love.graphics.print(tris, 10, 10)
    maid64.finish()
end

function love.keypressed(key)
    if key == "f11" then
        _G.fullscreen = not fullscreen
        love.window.setFullscreen(fullscreen)
    end
    if key == "p" then
        _G.pause = not pause
    end
end

function love.resize(w, h)
    maid64.resize(w, h)
end