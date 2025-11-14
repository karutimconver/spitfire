local G = 9.80665
local MASS = 1000
local WEIGHT = G*MASS
local AIR_DENSITY = 0.4582725
local AspectRatio =  5.61
local e = 0.85

local function calculateLiftCoefficient(AoA, airfoil)
    --Lift curve slope
    local AoAr = math.rad(AoA)
    local AoA0 = math.rad(airfoil.ZeroLiftAoA)

    -- 2D and finite-wing lift curve slopes
    local a0 = 2 * math.pi
    local a = 1 * a0 / (1 + (a0 / (math.pi * AspectRatio * e)))

    -- Compute CL (linear region)
    local Cl = a * (AoAr - AoA0)

    if airfoil.flap then
        
    end

    return Cl
end

airfoil = {ZeroLiftAoA = -2.6}
for i = -5, 5, 0.5 do    
    print("Cl at "..i.." AoA: ".. calculateLiftCoefficient(i, airfoil))
end

local function compute_CL_and_stats(airfoil, aoa_start_deg, aoa_end_deg, step_deg)
    step_deg = step_deg or 0.5
    aoa_start_deg = aoa_start_deg or -5
    aoa_end_deg   = aoa_end_deg   or  5

    -- compute a and a_per_deg used by your model
    local a0 = 2 * math.pi
    local a  = a0 / (1 + (a0 / (math.pi * AspectRatio * e)))
    local a_per_deg = a / 57.29577951308232

    print(string.format("Internal: a0=%.6f rad^-1, a=%.6f rad^-1, a_per_deg=%.6f per degree", a0, a, a_per_deg))
    print("Assuming calculateLiftCoefficient(AoA_deg, airfoil) expects AoA in degrees and converts inside.")

    -- generate points using your function (assumes your calculateLiftCoefficient uses math.rad inside)
    local xs = {}
    local ys = {}
    for x = aoa_start_deg, aoa_end_deg, step_deg do
        local Cl = calculateLiftCoefficient(x, airfoil)   -- your function
        table.insert(xs, x)
        table.insert(ys, Cl)
    end

    -- compute linear fit slope (least squares) of Cl vs AoA_deg
    local n = #xs
    local sumx, sumy, sumxy, sumxx = 0,0,0,0
    for i=1,n do
        sumx = sumx + xs[i]
        sumy = sumy + ys[i]
        sumxy = sumxy + xs[i]*ys[i]
        sumxx = sumxx + xs[i]*xs[i]
    end
    local slope = (n*sumxy - sumx*sumy) / (n*sumxx - sumx*sumx)
    local intercept = (sumy - slope*sumx)/n

    print(string.format("Measured linear fit: Cl = %.6f + %.6f * AoA_deg", intercept, slope))
    print(string.format("Measured slope per deg = %.6f (expected a_per_deg = %.6f)", slope, a_per_deg))

    print("Sample points:")
    for i = 1, n do
        print(string.format(" AoA=%.2f degrees -> Cl=%.6f", xs[i], ys[i]))
    end

    return {
        a = a,
        a_per_deg = a_per_deg,
        measured_slope = slope,
        intercept = intercept,
        xs = xs, ys = ys
    }
end

-- Example usage:
local stats = compute_CL_and_stats(airfoil, -5, 5, 0.5)