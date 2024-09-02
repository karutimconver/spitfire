require "src/globals"
local love = require "love"

function love.conf(t)
    t.window.resizable = true
    
    t.window.icon = "res/images/icon.png"

    t.window.width = 1068
    t.window.height = 600
    t.window.fullscreen = fullscreen
    t.console = true
end