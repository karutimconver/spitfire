require "src/globals"
require "src/3drendering/classes"
require "src/3drendering/functions"
require "src/draw/draw"

local love = require "love"

function _G.init3d()
    _G.meshCube = Mesh({
        -- SOUTH
        Triangle(Vec3(0.0, 0.0, 0.0), Vec3(0.0, 1.0, 0.0), Vec3(1.0, 1.0, 0.0)),
        Triangle(Vec3(0.0, 0.0, 0.0), Vec3(1.0, 1.0, 0.0), Vec3(1.0, 0.0, 0.0)),

        -- EAST                                                      
        Triangle(Vec3(1.0, 0.0, 0.0), Vec3(1.0, 1.0, 0.0), Vec3(1.0, 1.0, 1.0)),
        Triangle(Vec3(1.0, 0.0, 0.0), Vec3(1.0, 1.0, 1.0), Vec3(1.0, 0.0, 1.0)),

        -- NORTH                                                     
        Triangle(Vec3(1.0, 0.0, 1.0), Vec3(1.0, 1.0, 1.0), Vec3(0.0, 1.0, 1.0)),
        Triangle(Vec3(1.0, 0.0, 1.0), Vec3(0.0, 1.0, 1.0), Vec3(0.0, 0.0, 1.0)),

        -- WEST                                                      
        Triangle(Vec3(0.0, 0.0, 1.0), Vec3(0.0, 1.0, 1.0), Vec3(0.0, 1.0, 0.0)),
        Triangle(Vec3(0.0, 0.0, 1.0), Vec3(0.0, 1.0, 0.0), Vec3(0.0, 0.0, 0.0)),

        -- TOP                                                       
        Triangle(Vec3(0.0, 1.0, 0.0), Vec3(0.0, 1.0, 1.0), Vec3(1.0, 1.0, 1.0)),
        Triangle(Vec3(0.0, 1.0, 0.0), Vec3(1.0, 1.0, 1.0), Vec3(1.0, 1.0, 0.0)),

        -- BOTTOM                                                    
        Triangle(Vec3(1.0, 0.0, 1.0), Vec3(0.0, 0.0, 1.0), Vec3(0.0, 0.0, 0.0)),
        Triangle(Vec3(1.0, 0.0, 1.0), Vec3(0.0, 0.0, 0.0), Vec3(1.0, 0.0, 0.0)),
    })

    -- Projection matrix
    local Near = 0.1
	local Far = 1000.0
	local FOV = 90.0
	local AspectRatio = SCREEN_HEIGHT / SCREEN_WIDTH
	local fov = 1.0 / math.tan(math.rad(FOV * 0.5))

    _G.matProj = Matrix()
    _G.matRotZ = Matrix()
    _G.matRotX = Matrix()

    _G.Theta = 0

    matProj.m[1][1] = AspectRatio * fov
	matProj.m[2][2] = fov
	matProj.m[3][3] = Far / (Far - Near)
	matProj.m[4][3] = (-Far * Near) / (Far - Near)
	matProj.m[3][4] = 1.0
	matProj.m[4][4] = 0.0
end

function _G.update3d(dt)
    Theta = Theta + 1 * dt

    -- Rotation Z
	matRotZ.m[1][1] = math.cos(Theta)
	matRotZ.m[1][2] = math.sin(Theta)
	matRotZ.m[2][1] = -math.sin(Theta)
	matRotZ.m[2][2] = math.cos(Theta)
	matRotZ.m[3][3] = 1
	matRotZ.m[4][4] = 1

	-- Rotation X
	matRotX.m[1][1] = 1
	matRotX.m[2][2] = math.cos(Theta * 0.5)
	matRotX.m[2][3] = math.sin(Theta * 0.5)
	matRotX.m[3][2] = -math.sin(Theta * 0.5)
	matRotX.m[3][3] = math.cos(Theta * 0.5)
	matRotX.m[4][4] = 1
end

function _G.draw3d()
    -- Draw triangle
    for _, triangle in pairs(meshCube.triangles) do
        local triProjected = Triangle()
        local triRotatedZ = Triangle()
        local triRotatedZX = Triangle()

        triRotatedZ.p[1] = MultiplyMatrixVector(triangle.p[1], matRotZ)
        triRotatedZ.p[2] = MultiplyMatrixVector(triangle.p[2], matRotZ)
        triRotatedZ.p[3] = MultiplyMatrixVector(triangle.p[3], matRotZ)

        triRotatedZX.p[1] = MultiplyMatrixVector(triRotatedZ.p[1], matRotX)
        triRotatedZX.p[2] = MultiplyMatrixVector(triRotatedZ.p[2], matRotX)
        triRotatedZX.p[3] = MultiplyMatrixVector(triRotatedZ.p[3], matRotX)

        local triTranslated = triRotatedZX
        triTranslated.p[1].z = triRotatedZX.p[1].z + 3
        triTranslated.p[2].z = triRotatedZX.p[2].z + 3
        triTranslated.p[3].z = triRotatedZX.p[3].z + 3

        triProjected.p[1] = MultiplyMatrixVector(triTranslated.p[1], matProj)
        triProjected.p[2] = MultiplyMatrixVector(triTranslated.p[2], matProj)
        triProjected.p[3] = MultiplyMatrixVector(triTranslated.p[3], matProj)

        triProjected.p[1].x = triProjected.p[1].x + 1; triProjected.p[1].y = triProjected.p[1].y + 1
        triProjected.p[2].x = triProjected.p[2].x + 1; triProjected.p[2].y = triProjected.p[2].y + 1
        triProjected.p[3].x = triProjected.p[3].x + 1; triProjected.p[3].y = triProjected.p[3].y + 1

        triProjected.p[1].x = triProjected.p[1].x * SCREEN_WIDTH * 0.5
        triProjected.p[1].y = triProjected.p[1].y * SCREEN_HEIGHT * 0.5
        triProjected.p[2].x = triProjected.p[2].x * SCREEN_WIDTH * 0.5
        triProjected.p[2].y = triProjected.p[2].y * SCREEN_HEIGHT * 0.5
        triProjected.p[3].x = triProjected.p[3].x * SCREEN_WIDTH * 0.5
        triProjected.p[3].y = triProjected.p[3].y * SCREEN_HEIGHT * 0.5

        love.graphics.setColor(0, 1, 0)
        drawPoly({triProjected.p[1].x, triProjected.p[1].y,
                  triProjected.p[2].x, triProjected.p[2].y,
                  triProjected.p[3].x, triProjected.p[3].y})
        love.graphics.setColor(1, 1, 1)
    end
end