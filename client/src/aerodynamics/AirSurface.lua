local cpml = require("lib/cpml")

local BaseZeroLiftAoAd = -2.0 -- angle in degrees!!
local BaseStallAnglePd = 14 -- positive angle (in degrees) at which the plain stalls
local BaseStallAngleNd = -7 -- negative angle (in degrees) at which the plain stalls
local BaseSmothingAnglePd = 5
local BaseSmothingAngleNd = 5
local Cla0 = math.pi * 2 -- 2d lift curve slope
local Cd0 = 0.02 -- skin friction coefficient
local k = 0.374 -- experimently found coefficient for the delta ClMax

local function lerp(a, b, t)
    if t == 1 then
        return b
    else
        return a + (b - a) * t
    end
end

local function clamp(v, a, b)
    if a > b then
        return math.min(b, math.max(a, v))
    else
        return math.min(a, math.max(b, v))
    end
end

function airSurface(config)
    return {
        x = config.x or config.position.x,
        y = config.y or config.position.y,
        id = config.id,
        span = config.span,
        chord = config.chord,
        AspectRatio = config.span / config.chord,
        flap = config.flap or false,
        flapChordRatio = config.flapChordRatio,
        flapDeflection = 0,
        Cd0 = config.Cd0 or Cd0,

        position = function (self, forward, up)
            local rotation = cpml.mat4.from_direction(forward, up)

            local position = cpml.mat4.mul_vec3_perspective(cpml.vec3.new(), rotation, cpml.vec3.new(self.x, self.y, 0))
            return position
        end,

        deflect = function (self, angle)
            assert(self.flap, "ERROR! This airSurface (" .. 0 .. ") does not have a flap but is trying to deflect!")
            self.flapDeflection = math.rad(angle)
        end,

        calculateForcesAndTorque = function(self, velocity, right, AoA, airDensity)
            -- velocity is the aircraft velocity
            local airflowVelocity = cpml.vec3.len(velocity)
            local wingLength = self.chord
            local wingArea = self.span * self.chord
            local Cl, Cd, Cm = self:calculateCoefficients(AoA)

            local liftModule = Cl * airDensity * airflowVelocity^2 / 2 * wingArea
            local dragModule = Cd * airDensity * airflowVelocity^2 / 2 * wingArea
            local torque = Cm * airDensity * airflowVelocity^2 / 2 * wingArea * wingLength

            local drag = cpml.vec3.scale(cpml.vec3.normalize(velocity), -dragModule)
            local lift = cpml.vec3.scale(cpml.vec3.normalize(cpml.vec3.cross(drag, right)), liftModule)

            return cpml.vec3.add(lift, drag), torque
        end,

        calculateCoefficients = function(self, AoAd)
            local BaseZeroLiftAoA = math.rad(BaseZeroLiftAoAd)
            local BaseStallAngleP = math.rad(BaseStallAnglePd)
            local BaseStallAngleN = math.rad(BaseStallAngleNd)
            local AoA = math.rad(AoAd)

            -- Calculating stall angles
            local Cla = Cla0 * self.AspectRatio / (self.AspectRatio + 2 * (self.AspectRatio + 4) / self.AspectRatio + 2) -- Lift curve slope corrected for finite wing area
            local deltaCl = 0
            if self.flap then
                local theta = math.acos(2 * self.flapChordRatio - 1)
                local t = 1 - (theta - math.sin(theta)) / math.pi -- flap efficiency factor 
                local n = lerp(0.8, 0.4, (math.deg(math.abs(self.flapDeflection)) - 10) / 50) -- correction factor

                deltaCl = Cla * t * n * self.flapDeflection
            end

            local ZeroLiftAoA = BaseZeroLiftAoA - deltaCl / Cla

            local deltaClmax = k * deltaCl

            local ClmaxP = Cla*(BaseStallAngleP - BaseZeroLiftAoA) + deltaClmax
            local ClmaxN = Cla*(BaseStallAngleN - BaseZeroLiftAoA) + deltaClmax

            local StallAngleP = ZeroLiftAoA + ClmaxP / Cla
            local StallAngleN = ZeroLiftAoA + ClmaxN / Cla

            -- Calculating coefficients
            local Cl = 0
            local Cd = 0
            local Cm = 0

            local smothingAngleP = math.rad(BaseSmothingAnglePd)     -- constant but it could depend on flap deflection for more accurate results
            local smothingAngleN = math.rad(BaseSmothingAngleNd)     -- constant but it could depend on flap deflection for more accurate results

            Cl, Cd, Cm = self:calculateCoefficientsBeforeStall(ZeroLiftAoA, AoA, Cla)
            Cls, Cds, Cms = self:calculateCoefficientsAtStall(ZeroLiftAoA, AoA, Cla, StallAngleP, StallAngleN)

            if AoA > ZeroLiftAoA then
                Cl = lerp(Cl, Cls, clamp((AoA-StallAngleP)/smothingAngleP, 0, 1))
                Cd = lerp(Cd, Cds, clamp((AoA-StallAngleP)/smothingAngleP, 0, 1))
                Cm = lerp(Cm, Cms, clamp((AoA-StallAngleP)/smothingAngleP, 0, 1))
            else
                Cl = lerp(Cl, Cls, clamp(math.abs((AoA+StallAngleN)/smothingAngleN), 0, 1))
                Cd = lerp(Cd, Cds, clamp(math.abs((AoA+StallAngleN)/smothingAngleN), 0, 1))
                Cm = lerp(Cm, Cms, clamp(math.abs((AoA+StallAngleN)/smothingAngleN), 0, 1))
            end

            return Cl, Cd, Cm
        end,

        calculateCoefficientsBeforeStall = function (self, ZeroLiftAoA, AoA, Cla)
            local Cl = Cla * (AoA - ZeroLiftAoA)

            local AoAi = Cl / (math.pi * self.AspectRatio)  -- induced angle of attack
            local AoAe = AoA - ZeroLiftAoA - AoAi           -- effective angle of attack
            local Ctangencial = self.Cd0 * math.cos(AoAe)
            local Cnormal = (Cl + Ctangencial*math.sin(AoAe)) / math.cos(AoAe)

            local Cd = Cnormal * math.sin(AoAe) + Ctangencial*math.cos(AoAe)
            local Cm = -Cnormal*(0.25-0.175*(1 - 2*AoAe/math.pi))

            return Cl, Cd, Cm
        end,

        calculateCoefficientsAtStall = function (self, ZeroLiftAoA, AoA, Cla, stallAngleP, stallAngleN)
            local ClLowAoA

            if AoA > stallAngleP then
                ClLowAoA = Cla * (stallAngleP - ZeroLiftAoA)
            else
                ClLowAoA = Cla * (stallAngleN - ZeroLiftAoA)
            end
            local AoAi = ClLowAoA / (math.pi * self.AspectRatio)  -- induced angle of attack at low AoA

            local lerpParam
            if AoA > stallAngleP then
                lerpParam = (math.pi/2 - math.max(-math.pi/2, math.min(math.pi/2, AoA))) / (math.pi/2 - stallAngleP)
            else
                lerpParam = (math.pi/2 - math.max(-math.pi/2, math.min(math.pi/2, AoA))) / (math.pi/2 - stallAngleN)
            end
            AoAi = lerp(0, AoAi, lerpParam)

            local AoAe = AoA - ZeroLiftAoA - AoAi           -- effective angle of attack

            local Cd90 = -0.0426*self.flapDeflection^2 + 0.21*self.flapDeflection + 1.98

            local Cnormal = Cd90 * math.sin(AoAe) * (1/(0.56+0.44*math.abs(math.sin(AoAe)))-0.41*(1-math.exp(-17/self.AspectRatio)))

            local Ctangencial = 0.5 * Cd0 * math.cos(AoAe)

            local Cl = Cnormal * math.cos(AoAe) - Ctangencial * math.sin(AoAe)
            local Cd = Cnormal * math.sin(AoAe) + Ctangencial * math.sin(AoAe)
            local Cm = -Cnormal * (0.25 - 0.175*(1 - 2 * math.abs(AoAe) / math.pi))

            return Cl, Cd, Cm
        end
    }
end

--[[local function validateCoefficient(airfoil, min, max)
    for i = min, max, 0.5 do
        local Cl, Cd, Cm = airfoil:calculateCoefficients(i)
        print("AoA = ".. i .. "degrees -> Cl = " .. Cl .. " Cd = " .. Cd .. " Cm = " .. Cm)
    end
end

local airfoil = airSurface({span = 561, chord = 100, flap = true, flapChordRatio = 0.25}) -- asa com o aspect ratio do spitfire
airfoil:deflect(0)

validateCoefficient(airfoil, -10, 15)]]