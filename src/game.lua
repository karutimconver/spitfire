require "src/globals"
local states = {"running", "menu", "pause"}
local isHost = false

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