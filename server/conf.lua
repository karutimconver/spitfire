local love = require "love"

function love.conf(t)
    t.window.resizable = false

    t.window.width = 1
    t.window.height = 1
    t.window.fullscreen = false
    t.console = true
end