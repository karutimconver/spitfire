local BaseZeroLiftAoAd = -2.0 -- angle in degrees!!
local BaseStallAnglePd = 14 -- positive angle (in degrees) at which the plain stalls
local BaseStallAngleNd = -7 -- negative angle (in degrees) at which the plain stalls
local Cla0 = math.pi * 2 -- 2d lift curve slope
local k = 0.374 -- experimently found constant for the delta ClMax
local e = 0.85 -- Oswald efficiency factor

local function lerp(a, b, t)
    if t == 1 then
        return b
    else
        return a + (b - a) * t
    end
end

function airSurface(config)
    return {
        span = config.span,
        chord = config.chord,
        AspectRatio = config.span / config.chord,
        flap = config.flap or false,
        flapChordRatio = config.flapChordRatio,
        flapDeflection = 0,

        deflect = function (self, angle)
            print(not self.flap)
            assert(self.flap, "ERROR! This airSurface (" .. ") does not have a flap but is trying to deflect!")
            self.flapDeflection = math.rad(angle)
        end,

        calculateCoefficients = function(self, AoAd)
            local BaseZeroLiftAoA = math.rad(BaseZeroLiftAoAd)
            local BaseStallAngleP = math.rad(BaseStallAnglePd)
            local BaseStallAngleN = math.rad(BaseStallAngleNd)
            local AoA = math.rad(AoAd)
            -- Lift Coefficient
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

            local Cl = 0

            print(math.deg(StallAngleN))
            print(math.deg(StallAngleP))

            if StallAngleN < AoA and AoA < StallAngleP then
                Cl = Cla * (AoA - ZeroLiftAoA)
            end

            return Cl
        end
    }
end

local function validateCoefficient(airfoil, min, max)
    for i = min, max, 0.5 do
        print("AoA = ".. i .. "degrees -> Cl = " .. airfoil:calculateCoefficients(i))
    end
end

local airfoil = airSurface({span = 561, chord = 100, flap = true, flapChordRatio = 0.25}) -- asa com o aspect ratio do spitfire
airfoil:deflect(10)

validateCoefficient(airfoil, -5, 5)