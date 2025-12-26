local cpml = require "lib/cpml"

local G = 9.80665
local MASS = 2500
local WEIGHT = G*MASS
local AIR_DENSITY = 0.4582725
local THRUST = 770000

function aerodynamics(airfoils, forward, up, right, velocity)
    local totalForce = cpml.vec3.new(0, 0, 0)
    local pitchingMoment = 0
    local totalTorque = cpml.vec3.new(0, 0, 0)

    local AoA = math.acos(cpml.vec3.dot(forward, velocity) / (cpml.vec3.len(forward) * cpml.vec3.len(velocity)))

    for _, airfoil in pairs(airfoils) do
        aForce, aTorque = airfoil:calculateForcesAndTorque(velocity, right, AoA, AIR_DENSITY)
        totalForce = cpml.vec3.add(totalForce, aForce)
        pitchingMoment = pitchingMoment + aTorque
        totalTorque = cpml.vec3.add(cpml.vec3.cross(airfoil:position(forward, up), totalForce), totalTorque) -- NEED TO TAKE CALCULATE AIRFOIL:POSITION!!!!!!!!!!
    end

    totalTorque = cpml.vec3.add(totalTorque, cpml.vec3.scale(cpml.vec3.normalize(right), -pitchingMoment))

    -- Calculate acceleration

    local direction = cpml.vec3.normalize(totalForce)
    local linearAcceleration = cpml.vec3.scale(direction, cpml.vec3.len(totalForce) / MASS)



    return linearAcceleration
end