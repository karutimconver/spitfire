local cpml = require "lib/cpml"
local shader = require "src/3drendering/shader"

local function object(_position, _rotation, _scale)
    assert(_position ~= nil, "position not provided!")
    local position
    if _position.x then position = _position else position = cpml.vec3.new(position) end

    local rotation
    if _rotation.direction then
        rotation = cpml.mat4.from_perspective(_rotation.direction, _rotation.up)
    else
        rotation = _rotation
    end

    local scale
    if _scale.x then
        scale = cpml.mat4.scale(cpml.mat4.new(), cpml.mat4.identity(), cpml.vec3.new(_scale[1], _scale[2], _scale[3]))
    else
        scale = cpml.mat4.scale(cpml.mat4.new(), cpml.mat4.identity(), cpml.vec3.new(_scale[1], _scale[2], _scale[3]))
    end

    return {
        position = cpml.mat4.translate(cpml.mat4.identity(), position),
        rotation = rotation,
        scale = scale,

        draw = function(self)
            local modelMatrix = 

            shader:send("objectMatrix", "column", modelMatrix)
        end
    }
end

return object