require "src/globals"
require "src/3drendering/mesh"

local shader = require "src/3drendering/shader"
local cpml = require "lib/cpml"
local love = require "love"

local Near = 0.1
local Far = 1000.0
local FOV = 90.0
local AspectRatio = SCREEN_WIDTH / SCREEN_HEIGHT

function _G.init3d()
    love.graphics.setDepthMode("lequal", true)
    Timer = 0
    _G.mesh = Mesh("res/meshes/spitfire.obj", "res/images/icon.png")
    _G.Camera = cpml.vec3.new(0, 0, 0)
end

function _G.update3d(dt)
    --Timer = Timer + dt

    if love.keyboard.isDown("a") then
        Camera.x = Camera.x + 8 * dt
    end
    if love.keyboard.isDown("d") then
        Camera.x = Camera.x - 8 * dt
    end

    if love.keyboard.isDown("w") then
        Camera.z = Camera.z + 8 * dt
    end

    if love.keyboard.isDown("s") then
        Camera.z = Camera.z - 8 * dt
    end

    if love.keyboard.isDown("space") then
        Camera.y = Camera.y + 8 * dt
    end

    if love.keyboard.isDown("b") then
        Camera.y = Camera.y - 8 * dt
    end

    local scale = cpml.mat4.scale(cpml.mat4.identity(), cpml.mat4.identity(), cpml.vec3.new(1, 1, 1))

    local rotx = cpml.mat4.rotate(cpml.mat4.identity(), scale, Timer, cpml.vec3.new(1, 0, 0))
    local roty = cpml.mat4.rotate(cpml.mat4.identity(), rotx, Timer, cpml.vec3.new(0, 1, 0))
    local rotz = cpml.mat4.rotate(cpml.mat4.identity(), roty, Timer, cpml.vec3.new(0, 0, 1))

    _G.model = cpml.mat4.translate(cpml.mat4.identity(), rotz, cpml.vec3.new(0, 0, 16))
end

function _G.draw3d()
    love.graphics.setShader(shader)
    shader:send("usingCanvas", true)
    shader:send("projectionMatrix", "column", cpml.mat4.from_perspective(FOV, AspectRatio, Near, Far))
    -- Cuidado com esta matrix!
    shader:send("viewMatrix", "column", cpml.mat4.look_at(cpml.mat4.new(), cpml.vec3.new(Camera.x, Camera.y, Camera.z), cpml.vec3.new(Camera.x, Camera.y, Camera.z + 1), cpml.vec3.new(0, 1, 0)))
    shader:send("objectMatrix", "column", model)

    love.graphics.draw(mesh.m)
    love.graphics.setShader()
end