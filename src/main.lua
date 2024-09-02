require "globals"
local love = require("love")
local maid64 = require("maid64")

function love.load()
    maid64.setup(SCREEN_WIDTH, SCREEN_HEIGHT)
end

function love.update()
    
end

function love.draw()
    maid64.start()--starts the maid64 process
    love.graphics.clear(12 / 255, 120 / 255, 255 / 255, 1)
    --love.graphics.rectangle("fill", 0, 0, 320, 180)
    love.graphics.setColor(255, 255, 255)
    love.graphics.rectangle("fill", 0, 0, 2, 2)

    maid64.finish()
end

function love.keypressed(key)
    if key == "f11" then
        fullscreen = not fullscreen
        love.window.setFullscreen(fullscreen)
    end
end

function love.resize(w, h)
    -- this is used to resize the screen correctly
    maid64.resize(w, h)
end