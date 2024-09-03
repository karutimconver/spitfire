require "src/globals"
local love = require "love"

function love.conf(t)
    t.window.resizable = true
    
    t.window.icon = "res/images/icon.png"
    t.window.title = "Spitfire"

    t.window.width = 1069
    t.window.height = 600
    t.window.fullscreen = fullscreen
    t.console = debugging
end