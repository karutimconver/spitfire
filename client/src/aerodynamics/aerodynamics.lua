local cpml = require "lib/cpml"

local G = 9.80665
local MASS = 2500
local WEIGHT = G*MASS
local AIR_DENSITY = 0.4582725
local THRUST = 770000
local MOMENT_OF_INERTIA = 1625 -- aproximation. Might have to be calculated


local function applyForce(force)
    local direction = cpml.vec3.normalize(force)
    local linearAcceleration = cpml.vec3.scale(direction, cpml.vec3.len(force) / MASS)

    return linearAcceleration
end

local function applyTorque(torque)
    local direction = cpml.vec3.normalize(torque)
    local angularAccelaration = cpml.vec3.scale(direction, cpml.vec3.len(torque) / MOMENT_OF_INERTIA)

    return angularAccelaration
end

function aerodynamics(airfoils, forward, up, right, velocity)
    local totalForce = cpml.vec3.new(0, 0, 0)
    local pitchingMoment = 0
    local totalTorque = cpml.vec3.new(0, 0, 0)

    local perspective = cpml.mat4.transpose(cpml.mat4.new(), cpml.mat4.from_direction(forward, up))
    local relativeVelocity = cpml.mat4.mul_vec3_perspective(cpml.vec3.new(), perspective, velocity)

    local AoA = math.atan(relativeVelocity.y, -relativeVelocity.z)

    local aForce, aTorque
    for _, airfoil in pairs(airfoils) do
        aForce, aTorque = airfoil:calculateForcesAndTorque(velocity, right, AoA, AIR_DENSITY)
        totalForce = cpml.vec3.add(totalForce, aForce)
        pitchingMoment = pitchingMoment + aTorque
        totalTorque = cpml.vec3.add(cpml.vec3.cross(airfoil:position(forward, up), aForce), totalTorque)
    end

    totalTorque = cpml.vec3.add(totalTorque, cpml.vec3.scale(cpml.vec3.normalize(right), -pitchingMoment))

    -- Calculate acceleration

    local angularAccelaration = applyTorque(totalTorque)
    local linearAcceleration = applyForce(totalForce)

    return {linear = linearAcceleration, angular = angularAccelaration}
end