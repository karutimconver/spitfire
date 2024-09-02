require "globals"
local love = require "love"

function love.conf(t)
    t.window.resizable = true
    t.window.fullscreen = fullscreen
end