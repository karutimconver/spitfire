require "src/player"
require "src/globals"
require "src/draw/draw"
require "src/3drendering/main3d"

local love = require "love"
local maid64 = require "lib/maid64"
local game = require "src/game"
local cpml = require "lib/cpml"

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
    --if game:checkState("running") then
        love.graphics.clear(12 / 255, 120 / 255, 255 / 255, 1)
        draw3d()
        love.graphics.print(love.timer.getFPS(), 10, 10)
    --end
    maid64.finish()
end

function love.keypressed(key)
    if key == "f11" then
        FULLSCREEN = not FULLSCREEN
        love.window.setFullscreen(FULLSCREEN)
    end
    if key == "p" then
        if game:checkState("pause") then
            game:setState("running")
        else
            game:setState("pause")
        end
    end
    if key == "i" then
        print(viewMatrix[1], viewMatrix[2], viewMatrix[3], viewMatrix[4])
        print(viewMatrix[5], viewMatrix[6], viewMatrix[7], viewMatrix[8])
        print(viewMatrix[9], viewMatrix[10], viewMatrix[11], viewMatrix[12])
        print(viewMatrix[13], viewMatrix[14], viewMatrix[15], viewMatrix[16])

        local view = cpml.mat4.look_at(cpml.mat4.new(), Camera,
        cpml.vec3.new(Camera.x + forward.x, Camera.y + forward.y, Camera.z + forward.z),
        up)

        print(view[1], view[2], view[3], view[4])
        print(view[5], view[6], view[7], view[8])
        print(view[9], view[10], view[11], view[12])
        print(view[13], view[14], view[15], view[16])
    end
end

function love.resize(w, h)
    maid64.resize(w, h)
end