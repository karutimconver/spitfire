local cpml = require "lib/cpml"

local G = 9.80665
local MASS = 1000
local WEIGHT = G*MASS
local AIR_DENSITY = 0.4582725
local AspectRatio =  5.61
local e = 0.85

local function calculateForcesAndTorque(airfoil, AoA, velocity)
    local airflowVelocity = cpml.vec3.len(velocity)
    local wingLength = airfoil.length
    local wingArea = airfoil.area
    local Cl, Cd, Cm = calculateCoeficients(AoA, airfoil)

    local liftModule = Cl * AIR_DENSITY * airflowVelocity^2 / 2 * wingArea
    local dragModule = Cd * AIR_DENSITY * airflowVelocity^2 / 2 * wingArea
    local torque = Cm * AIR_DENSITY * airflowVelocity^2 / 2 * wingArea * wingLength

    local lift = cpml.vec3.new(0, liftModule, 0)
    local drag = cpml.vec3.normalize(velocity) * -dragModule

    return cpml.vec3.add(lift, drag), torque
end

function aerodynamics(airfoils, forward, up, right, velocity)
    local totalForce = cpml.vec3.new(0, 0, 0)
    local pitchingMoment = 0
    local totalTorque = cpml.vec3.new(0, 0, 0)

    local AoA = math.acos(cpml.vec3.dot(forward, velocity) / (cpml.vec3.len(forward) * cpml.vec3.len(velocity)))

    for _, airfoil in pairs(airfoils) do
        aForce, aTorque = calculateForcesAndTorque(airfoils, AoA, velocity)
        totalForce = cpml.vec3.add(totalForce, aForce)
        pitchingMoment = pitchingMoment + aTorque
        totalTorque = cpml.vec3.add(cpml.vec3.cross(airfoil.position, totalForce), totalTorque)
    end

    totalTorque = cpml.vec3.add(totalTorque, cpml.vect.normalize(right)*pitchingMoment)
end