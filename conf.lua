require "src/globals"
local love = require "love"

function love.conf(t)
    t.window.resizable = false

    t.window.icon = "res/images/icon.png"
    t.window.title = "Spitfire"

    t.window.depth = 16
    t.window.width = 960
    t.window.height = 540
    t.window.fullscreen = fullscreen
    t.console = debugging
end