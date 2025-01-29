require "src/globals"
require "src/3drendering/mesh"

local shader = require "src/3drendering/shader"
local cpml = require "lib/cpml"
local love = require "love"

local Near = 0.1
local Far = 1000.0
local FOV = 60.0
local AspectRatio = SCREEN_WIDTH / SCREEN_HEIGHT


function _G.init3d()
    love.graphics.setDepthMode("lequal", true)
    Timer = 0
    _G.mesh = Mesh("res/meshes/mountains.obj", "res/images/spitfire textures/noise.png")
    _G.Camera = cpml.vec3.new(0, 0, 0)
    _G.right = cpml.vec3.new(1, 0, 0)
    _G.up = cpml.vec3.new(0, 1, 0)
    _G.forward = cpml.vec3.new(0, 0, 1)

    shader:send("usingCanvas", true)
    shader:send("projectionMatrix", "column", cpml.mat4.from_perspective(FOV, AspectRatio, Near, Far))

end

function _G.update3d(dt, player)
    if not player then
        if love.keyboard.isDown("a") then
            Camera = cpml.vec3.add(Camera, cpml.vec3.mul(right, cpml.vec3.new(-0.1, -0.1, -0.1)))
        end

        if love.keyboard.isDown("d") then
            Camera = cpml.vec3.add(Camera, cpml.vec3.mul(right, cpml.vec3.new(0.1, 0.1, 0.1)))
        end

        if love.keyboard.isDown("w") then
            Camera = cpml.vec3.add(Camera, cpml.vec3.mul(forward, cpml.vec3.new(0.1, 0.1, 0.1)))
        end

        if love.keyboard.isDown("s") then
            Camera = cpml.vec3.add(Camera, cpml.vec3.mul(forward, cpml.vec3.new(-0.1, -0.1, -0.1)))
        end

        if love.keyboard.isDown("space") then
            Camera.y = Camera.y + 8 * dt
        end

        if love.keyboard.isDown("lshift") then
            Camera.y = Camera.y - 8 * dt
        end

        if love.keyboard.isDown("left") then
            up = cpml.vec3.normalize(cpml.mat4.mul_vec3_perspective(cpml.vec3.new(), cpml.mat4.from_angle_axis(1.5*dt, forward), up))
            right = cpml.vec3.normalize(cpml.mat4.mul_vec3_perspective(cpml.vec3.new(), cpml.mat4.from_angle_axis(1.5*dt, forward), right))
        end

        if love.keyboard.isDown("right") then
            up = cpml.vec3.normalize(cpml.mat4.mul_vec3_perspective(cpml.vec3.new(), cpml.mat4.from_angle_axis(-1.5*dt, forward), up))
            right = cpml.vec3.normalize(cpml.mat4.mul_vec3_perspective(cpml.vec3.new(), cpml.mat4.from_angle_axis(-1.5*dt, forward), right))
        end

        if love.keyboard.isDown("up") then
            forward = cpml.vec3.normalize(cpml.mat4.mul_vec3_perspective(cpml.vec3.new(), cpml.mat4.from_angle_axis(1*dt, right), forward))
            up = cpml.vec3.normalize(cpml.mat4.mul_vec3_perspective(cpml.vec3.new(), cpml.mat4.from_angle_axis(1*dt, right), up))
        end

        if love.keyboard.isDown("down") then
            forward = cpml.vec3.normalize(cpml.vec3.normalize(cpml.mat4.mul_vec3_perspective(cpml.vec3.new(), cpml.mat4.from_angle_axis(-1*dt, right), forward)))
            up = cpml.vec3.normalize(cpml.mat4.mul_vec3_perspective(cpml.vec3.new(), cpml.mat4.from_angle_axis(-1*dt, right), up))
        end

        if love.keyboard.isDown("f") then
            Camera = cpml.vec3.add(Camera, cpml.vec3.mul(forward, cpml.vec3.new(0.1, 0.1, 0.1)))
        end

        _G.viewMatrix = cpml.mat4.look_at(cpml.mat4.new(), Camera,
                    cpml.vec3.new(Camera.x + forward.x, Camera.y + forward.y, Camera.z + forward.z),
                    up)
    else
        _G.viewMatrix = cpml.mat4.look_at(cpml.mat4.new(), player.position, cpml.vec3.new(player.position.x + player.forward.x,
                                          player.position.y + player.forward.y, player.position.z + player.forward.z), player.up)
    end
    local scale = cpml.mat4.scale(cpml.mat4.identity(), cpml.mat4.identity(), cpml.vec3.new(1, 1, 1))

    local rotx = cpml.mat4.rotate(cpml.mat4.identity(), scale, 0, cpml.vec3.new(1, 0, 0))
    local roty = cpml.mat4.rotate(cpml.mat4.identity(), rotx, 0, cpml.vec3.new(0, 1, 0))
    local rotz = cpml.mat4.rotate(cpml.mat4.identity(), roty, 0, cpml.vec3.new(0, 0, 1))

    _G.modelMatrix = cpml.mat4.translate(cpml.mat4.identity(), rotz, cpml.vec3.new(0, 0, 16))
end

function _G.draw3d()
    love.graphics.setShader(shader)
    shader:send("viewMatrix", "column", viewMatrix)
    shader:send("objectMatrix", "column", modelMatrix)

    love.graphics.draw(mesh.m)
    love.graphics.setShader()
end