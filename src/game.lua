require "src/globals"
local enet = require "enet"

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

    update = function (self, state)
        if isHost then
            -- game server code
        else
            -- game client code
        end
    end
}

return game