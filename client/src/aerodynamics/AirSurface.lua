local BaseZeroLiftAoAd = -2.0 -- angle in degrees!!
local Cla0 = math.pi * 2 -- 2d lift curve slope
local k = 0.374 -- experimently found constant for the delta ClMax
local e = 0.85 -- Oswald efficiency factor
local n = 1 -- delta Cl correction factor

function airSurface(span, chord, flap, flapChordRatio)
    return {
        span = span,
        chord = chord,
        AspectRatio = span / chord,
        flap = flap or false,
        flapChordRatio = flapChordRatio,
        flapDeflection = 0,

        deflect = function (self, angle)
            print(not self.flap)
            assert(self.flap, "ERROR! This airSurface (" .. ") does not have a flap but is trying to deflect!")
            self.flapDeflection = math.rad(angle)
        end,

        calculateCoefficients = function(self, AoAd)
            local BaseZeroLiftAoA = math.rad(BaseZeroLiftAoAd)
            local AoA = math.rad(AoAd)
            -- Lift Coefficient
            local Cla = Cla0 * self.AspectRatio / (self.AspectRatio + 2 * (self.AspectRatio + 4) / self.AspectRatio + 2) -- Lift curve slope corrected for finite wing area
            local deltaCl = 0
            if self.flap then
                local theta = math.acos(2 * self.flapChordRatio - 1)
                local t = 1 - (theta - math.sin(theta)) / math.pi --flap efficiency factor 
                deltaCl = Cla * t * n * self.flapDeflection
            end

            local ZeroLiftAoA = BaseZeroLiftAoA - deltaCl / Cla

            local Cl = Cla * (AoA - ZeroLiftAoA)

            return Cl
        end
    }
end

local function validateCoefficient(airfoil, min, max)
    for i = min, max, 0.5 do
        print("AoA = ".. i .. "degrees -> Cl = " .. airfoil:calculateCoefficients(i))
    end
end

local airfoil = airSurface(561, 100, true, 0.24) -- asa com o aspect ratio do spitfire
airfoil:deflect(10)

validateCoefficient(airfoil, -5, 5)