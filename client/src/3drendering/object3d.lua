local cpml = require "lib/cpml"
local shader = require "src/3drendering/shader"
local mesh = require "src/3drendering/mesh"
local love = require "love"

_G.Objects3dSet = {}

local function object(_mesh, transform)
    local _position, _rotation, _scale = transform.position, transform.rotation, transform.scale
    assert(_position ~= nil, "position not provided!")
    local position
    if _position.x then position = _position else position = cpml.vec3.new(position) end

    local rotation
    if _rotation then
        if _rotation.direction then
            rotation = cpml.mat4.from_perspective(_rotation.direction, _rotation.up)
        else
            local x, y, z
            if _rotation.x then
                x = _rotation.x
                y = _rotation.y
                z = _rotation.z
            else
                x = _rotation[1]
                y = _rotation[2]
                z = _rotation[3]
            end

            rotation = cpml.mat4.rotate(cpml.mat4.identity(), cpml.mat4.identity(), x, cpml.vec3.new(1, 0, 0))
            rotation = cpml.mat4.rotate(cpml.mat4.identity(), rotation, y, cpml.vec3.new(0, 1, 0))
            rotation = cpml.mat4.rotate(cpml.mat4.identity(), rotation, z, cpml.vec3.new(0, 0, 1))
        end
    else
        rotation = cpml.mat4.identity()
    end

    local scale
    if _scale then
        if _scale.x then
            scale = cpml.mat4.scale(cpml.mat4.new(), cpml.mat4.identity(), cpml.vec3.new(_scale.x, _scale.y, _scale.xz))
        else
            scale = cpml.mat4.scale(cpml.mat4.new(), cpml.mat4.identity(), cpml.vec3.new(_scale[1], _scale[2], _scale[3]))
        end
    else
        scale = cpml.mat4.identity()
    end

    local mesh = _mesh
    if type(mesh) == "string" then
        mesh = Mesh(mesh)
    else
        mesh = _mesh
    end

    _object = {
        position = cpml.mat4.translate(cpml.mat4.new(), cpml.mat4.identity(), position),
        rotation = rotation,
        scale = scale,
        mesh = mesh,

        draw = function(self)
            local rotated = cpml.mat4.mul(cpml.mat4.new(), self.scale, self.rotation)
            local modelMatrix = cpml.mat4.mul(cpml.mat4.new(), rotated, self.position)

            shader:send("objectMatrix", "column", modelMatrix)

            love.graphics.draw(self.mesh.m)
        end
    }

    assert(mesh ~= nil, "No mesh provided!")

    table.insert(Objects3dSet, _object)

    return _object
end

return object