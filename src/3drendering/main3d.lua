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
    local vertexFormat = {
        {"VertexPosition", "float", 3},
        {"VertexTexCoord", "float", 2},
        {"VertexNormal", "float", 3},
        {"VertexColor", "byte", 4},
    }

    local verts = {
        {-1, -1, -1, 0,0},
        { 1, -1, -1, 1,0},
        {-1,  1, -1, 0,1},
        { 1,  1, -1, 1,1},
        { 1, -1, -1, 1,0},
        {-1,  1, -1, 0,1},

        {-1, -1,  1, 0,0},
        { 1, -1,  1, 1,0},
        {-1,  1,  1, 0,1},
        { 1,  1,  1, 1,1},
        { 1, -1,  1, 1,0},
        {-1,  1,  1, 0,1},

        {-1, -1, -1, 0,0},
        { 1, -1, -1, 1,0},
        {-1, -1,  1, 0,1},
        { 1, -1,  1, 1,1},
        { 1, -1, -1, 1,0},
        {-1, -1,  1, 0,1},

        {-1,  1, -1, 0,0},
        { 1,  1, -1, 1,0},
        {-1,  1,  1, 0,1},
        { 1,  1,  1, 1,1},
        { 1,  1, -1, 1,0},
        {-1,  1,  1, 0,1},

        {-1, -1, -1, 0,0},
        {-1,  1, -1, 1,0},
        {-1, -1,  1, 0,1},
        {-1,  1,  1, 1,1},
        {-1,  1, -1, 1,0},
        {-1, -1,  1, 0,1},

        { 1, -1, -1, 0,0},
        { 1,  1, -1, 1,0},
        { 1, -1,  1, 0,1},
        { 1,  1,  1, 1,1},
        { 1,  1, -1, 1,0},
        { 1, -1,  1, 0,1},
    }

    mesh = love.graphics.newMesh(vertexFormat, verts, "triangles")

    love.graphics.setDepthMode("lequal", true)
    Timer = 0
    testMesh = Mesh("res/meshes/spitfire2.obj", "res/images/icon.png")
    mesh:setTexture(love.graphics.newImage("res/images/icon.png"))
end

function _G.update3d(dt)
    Timer = Timer + dt

    local scale = cpml.mat4.scale(cpml.mat4.identity(), cpml.mat4.identity(), cpml.vec3.new(1, 1, 1))

    local rotx = cpml.mat4.rotate(cpml.mat4.identity(), scale, Timer, cpml.vec3.new(1, 0, 0))
    local roty = cpml.mat4.rotate(cpml.mat4.identity(), rotx, Timer, cpml.vec3.new(0, 1, 0))
    local rotz = cpml.mat4.rotate(cpml.mat4.identity(), roty, Timer, cpml.vec3.new(0, 0, 1))

    _G.model = cpml.mat4.translate(cpml.mat4.identity(), rotz, cpml.vec3.new(0, 0, 16))
end

function _G.draw3d()
    love.graphics.setShader(shader)
    shader:send("projectionMatrix", "column", cpml.mat4.from_perspective(FOV, AspectRatio, Near, Far))
    -- Cuidado com esta matrix!
    shader:send("viewMatrix", "column", cpml.mat4.look_at(cpml.mat4.new(), cpml.vec3.new(0, 0, 0), cpml.vec3.new(0, 0, 1), cpml.vec3.new(0, 1, 0)))
    shader:send("objectMatrix", "column", model)

    love.graphics.draw(testMesh.m)
    love.graphics.setShader()
end