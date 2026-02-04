local love = require "love"
local maid64 = require "lib/maid64"
local game = require "src/game"

love.graphics.setDefaultFilter("nearest", "nearest")

function love.load()
    game:load()
end

function love.update(dt)
    game:update(dt)
end

function love.draw()
    game:draw()
end

function love.mousepressed(x, y, button, istouch, presses)
    game:mousepressed(x, y, button, istouch, presses)
end

function love.keypressed(key)
    game:keypress(key)
end

function love.resize(w, h)
    maid64.resize(w, h)
end