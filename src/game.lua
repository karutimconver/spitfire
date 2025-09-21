require "src/player"
require "src/globals"
require "src/draw/draw"
require "src/3drendering/main3d"

local maid64 = require "lib/maid64"
local enet = require "enet"
local love = require "love"
local cpml = require "lib/cpml"

local isHost = false

_G.Server = {
    create = function (self)
        isHost = true
        self.host = enet.host_create("127.0.0.1:8888")
    end,

    update = function (self)
        local event = self.host:service(100)
        if event and event.type == "receive" then
            print("Got message: ", event.data, event.peer)
            event.peer:send(event.data)
        end
    end
}

_G.gameStates = {menu = 0,
lobby = 1,
running = 2}

local states = {"running", "menu", "pause", "lobby"}
local game = {
    state = "running",

    setState = function (self, state)
        assert(table.contains(states, state), "Invalid game state \"" .. state .. "\"!")

        self.state = state
    end,

    checkState = function (self, state)
        assert(table.contains(states, state), "Invalid game state \"" .. state .. "\"!")

        return self.state == state
    end,

    load = function (self)
        maid64.setup(SCREEN_WIDTH, SCREEN_HEIGHT)
        init3d()
        _G.player = Player()
    end,

    update = function (self, dt)
        if self:checkState("running") then
            if DEBBUGGING then
                player:update(dt)
                update3d(dt, player)
            else
                update3d(dt)
            end
        end
    end,

    draw = function(self)
        maid64.start()

        if self:checkState("menu") then
            love.graphics.clear(12 / 255, 120 / 255, 255 / 255, 1)
        elseif self:checkState("lobby") then
            love.graphics.clear(0, 0, 0, 1)
        else
            --if game:checkState("running") then
                love.graphics.clear(12 / 255, 120 / 255, 255 / 255, 1)
                draw3d()
                love.graphics.print(love.timer.getFPS(), 10, 10)
            --end
        end

        maid64.finish()
    end,

    keypress = function(self, key)
        if key == "f11" then
            FULLSCREEN = not FULLSCREEN
            love.window.setFullscreen(FULLSCREEN)
        end
        if key == "p" then
            if self:checkState("pause") then
                self:setState("running")
            else
                self:setState("pause")
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
}

return game