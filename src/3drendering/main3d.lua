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
    local Far = 1000
    local FOV = 90
    local AspectRatio = SCREEN_HEIGHT / SCREEN_WIDTH
    local fov = 1 / math.tan(math.rad(FOV / 2))

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

    matRotZ.m[1][1] = math.sin(Theta)
	matRotZ.m[1][2] = math.sin(Theta)
	matRotZ.m[2][1] = -math.sin(Theta)
	matRotZ.m[2][2] = math.cos(Theta)
	matRotZ.m[3][3] = 1
	matRotZ.m[4][4] = 1

	matRotX.m[1][1] = 1
	matRotX.m[2][2] = math.cos(Theta * 0.5)
	matRotX.m[2][3] = math.sin(Theta * 0.5)
	matRotX.m[3][2] = -math.sin(Theta * 0.5)
	matRotX.m[3][3] = math.cos(Theta * 0.5)
	matRotX.m[4][4] = 1
end

function _G.update3d()
end

function _G.draw3d()
    -- Draw triangle
    for _, triangle in pairs(meshCube.triangles) do
        local triProjected = Triangle()
        local triTranslated = copy(triangle)

        triTranslated.p[1].z = triangle.p[1].z + 3
        triTranslated.p[2].z = triangle.p[2].z + 3
        triTranslated.p[3].z = triangle.p[3].z + 3

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

        drawPoly({math.floor(triProjected.p[1].x + 0.5), math.floor(triProjected.p[1].y + 0.5),
                  math.floor(triProjected.p[2].x + 0.5), math.floor(triProjected.p[2].y + 0.5),
                  math.floor(triProjected.p[3].x + 0.5), math.floor(triProjected.p[3].y + 0.5)})
    end
end