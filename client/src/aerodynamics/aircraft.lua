local cpml = require "lib/cpml"
local AirSurface = require "src/aerodynamics/AirSurface"

local G = 9.80665
local MASS = 2500
local WEIGHT = cpml.vec3.new(0, -G*MASS, 0)
local AIR_DENSITY = 0.4582725
local MOMENT_OF_INERTIA = 1625 -- aproximation.  Might have to be calculated
local POWER = 770000
local n = 0.91               -- propeller efficiency


local function Aircraft()
    return {
        airfoils = {
            leftWing = AirSurface({
                x = -1.6,
                y = 0.6,
                span = 3.0,
                chord = 2.2,
                AR = 5.61,
                id = "leftWing",
                flap = false
            }),
            rightWing = AirSurface({
                x = 1.6,
                y = 0.6,
                span = 3.0,
                chord = 2.2,
                AR = 5.61,
                id = "rightWing",
                flap = false
            }),

            leftAileron = AirSurface({
                x = -4.1,
                y = 0.6,
                span = 2.6,
                chord = 1.8,
                AR = 5.61,
                id = "leftAileron",
                flap = true,
                flapChordRatio = 0.25
            }),
            rightAileron = AirSurface({
                x = 4.1,
                y = 0.6,
                span = 2.6,
                chord = 1.8,
                AR = 5.61,
                id = "rightAileron",
                flap = true,
                flapChordRatio = 0.25
            }),

            leftElevator = AirSurface({
                x = -0.8,
                y = -5.2,
                span = 1.6,
                chord = 1.3,
                AR = 4.16,
                id = "leftElevator",
                flap = true,
                flapChordRatio = 0.25,
            }),
            rightElevator = AirSurface({
                x = 0.8,
                y = -5.2,
                span = 1.6,
                chord = 1.3,
                AR = 4.16,
                id = "leftElevator",
                flap = true,
                flapChordRatio = 0.25,
            })
        },


        applyForce = function(force)
            return cpml.vec3.scale(force, 1 / MASS)
        end,

        applyTorque = function(torque)
            return cpml.vec3.scale(torque, 1 / MOMENT_OF_INERTIA)
        end,

        aerodynamics = function(self, forward, up, right, velocity)
            local totalForce = cpml.vec3.new(0, 0, 0)
            local pitchingMoment = 0
            local totalTorque = cpml.vec3.new(0, 0, 0)

            local perspective = cpml.mat4.transpose(cpml.mat4.new(), cpml.mat4.from_direction(forward, up))
            local relativeVelocity = cpml.mat4.mul_vec3_perspective(cpml.vec3.new(), perspective, cpml.vec3.scale(velocity, -1))

            --local AoA = math.atan(relativeVelocity.y / relativeVelocity.z)]]

            local v = cpml.vec3.normalize(cpml.vec3.new(velocity.x, velocity.y, velocity.z))

            local v_fwd = cpml.vec3.dot(v, forward)
            local v_up  = cpml.vec3.dot(v, up)

            local AoA = math.deg(-math.atan(v_up / v_fwd))

            local aForce, aTorque
            for _, airfoil in pairs(self.airfoils) do
                aForce, aTorque = airfoil:calculateForcesAndTorque(velocity, right, AoA, AIR_DENSITY)
                totalForce = cpml.vec3.add(totalForce, aForce)
                pitchingMoment = pitchingMoment + aTorque
                totalTorque = cpml.vec3.add(cpml.vec3.cross(airfoil:position(forward, up), aForce), totalTorque)
            end
            --print("totalForce: ", totalForce)
            totalForce = cpml.vec3.add(totalForce, WEIGHT)
            local speed = cpml.vec3.len(velocity)
            local thrust = n * POWER / speed
            totalForce = cpml.vec3.add(totalForce, cpml.vec3.scale(forward, thrust))
            totalTorque = cpml.vec3.add(totalTorque, cpml.vec3.scale(cpml.vec3.normalize(right), -pitchingMoment))

            -- Calculate acceleration

            print("AoA: ", AoA)
            print("Relative velocity: ", relativeVelocity)
            print("totalForce: ", totalForce)
            local angularAccelaration = self.applyTorque(totalTorque)
            local linearAcceleration = self.applyForce(totalForce)

            return {linear = linearAcceleration, angular = angularAccelaration}
        end
    }
end

return Aircraft