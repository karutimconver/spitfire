require "src/player"
require "src/globals"
require "src/draw/draw"
require "src/3drendering/main3d"

local love = require "love"
local maid64 = require "lib/maid64"
local game = require "src/game"

love.graphics.setDefaultFilter("nearest", "nearest")

function love.load()
    maid64.setup(SCREEN_WIDTH, SCREEN_HEIGHT)
    init3d()
    _G.player = Player()
end

function love.update(dt)
    if game:checkState("running") then
        if DEBBUGGING then
            update3d(dt)
        else
            player:update(dt)
            update3d(dt, player)
        end
    end
end

function love.draw()
    maid64.start()
    love.graphics.clear(12 / 255, 120 / 255, 255 / 255, 1)
    draw3d()
    love.graphics.print(love.timer.getFPS(), 10, 10)
    maid64.finish()
end

function love.keypressed(key)
    if key == "f11" then
        FULLSCREEN = not FULLSCREEN
        love.window.setFullscreen(FULLSCREEN)
    end
    if key == "p" then
        game:setState("running")
    end
end

function love.resize(w, h)
    maid64.resize(w, h)
end