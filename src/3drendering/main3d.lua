require "src/globals"
require "src/3drendering/classes"
require "src/3drendering/functions"
require "src/draw/draw"

local love = require "love"

function _G.init3d()
    _G.meshCube = Mesh()

    -- Projection matrix
    local Near = 0.1
	local Far = 1000.0
	local FOV = 90.0
	local AspectRatio = SCREEN_HEIGHT / SCREEN_WIDTH

    _G.Camera = Vec3()

    _G.matProj = Matrix_MakeProjection(FOV, AspectRatio, Near, Far)

    _G.Theta = 0

    meshCube:loadObjectFile("res/meshes/spitfire.obj")
    --meshCube:loadObjectFile("res/meshes/untitled.obj")
end

function _G.update3d(dt)
    Theta = Theta + 1 * dt

    -- Rotation Z
	matRotZ = Matrix_MakeRotationZ(Theta)

	-- Rotation X
	matRotX = Matrix_MakeRotationX(Theta)
end

function _G.draw3d()
    -- Draw triangle
    local trianglesToDraw = {}

    -- Draw
    for _, triangle in pairs(meshCube.triangles) do
        local triProjected = Triangle()
        local triRotatedZ = Triangle()
        local triRotatedZX = Triangle()
        -- Rotate
        triRotatedZ.p[1] = MultiplyMatrixVector(triangle.p[1], matRotZ)
        triRotatedZ.p[2] = MultiplyMatrixVector(triangle.p[2], matRotZ)
        triRotatedZ.p[3] = MultiplyMatrixVector(triangle.p[3], matRotZ)

        triRotatedZX.p[1] = MultiplyMatrixVector(triRotatedZ.p[1], matRotX)
        triRotatedZX.p[2] = MultiplyMatrixVector(triRotatedZ.p[2], matRotX)
        triRotatedZX.p[3] = MultiplyMatrixVector(triRotatedZ.p[3], matRotX)

        -- offset
        local triTranslated = triRotatedZX
        triTranslated.p[1].z = triRotatedZX.p[1].z + 18
        triTranslated.p[2].z = triRotatedZX.p[2].z + 18
        triTranslated.p[3].z = triRotatedZX.p[3].z + 18

        -- Calculate normal
        local normal = Vec3()

        local line1 = Vec3()
        line1.x = triTranslated.p[2].x - triTranslated.p[1].x
        line1.y = triTranslated.p[2].y - triTranslated.p[1].y
        line1.z = triTranslated.p[2].z - triTranslated.p[1].z

        local line2 = Vec3()
        line2.x = triTranslated.p[3].x - triTranslated.p[1].x
        line2.y = triTranslated.p[3].y - triTranslated.p[1].y
        line2.z = triTranslated.p[3].z - triTranslated.p[1].z

        normal.x = line1.y * line2.z - line1.z * line2.y
        normal.y = line1.z * line2.x - line1.x * line2.z
        normal.z = line1.x * line2.y - line1.y * line2.x

        local l = math.sqrt(normal.x*normal.x + normal.y*normal.y + normal.z*normal.z)
        normal.x = normal.x / l
        normal.y = normal.y / l
        normal.z = normal.z / l

        if normal.x * (triTranslated.p[1].x - Camera.x) + 
           normal.y * (triTranslated.p[1].y - Camera.y) +
           normal.z * (triTranslated.p[1].z - Camera.z) < 0 then
            -- light
            local light_direction = Vec3(0, 0, -1)
            light_direction = Vector_Normalise(light_direction)

            triProjected.dp = Vector_Dot(normal, light_direction)

            -- project
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

            table.insert(trianglesToDraw, triProjected)
        end
    end

    -- Sort triangle
    table.sort(trianglesToDraw, function(a, b)
        local triangle1 = (a.p[1].z + a.p[2].z + a.p[3].z) / 3;
		local triangle2 = (b.p[1].z + b.p[2].z + b.p[3].z) / 3;
		return triangle1 > triangle2;

        end)

    -- Render
    for _, triangle in pairs(trianglesToDraw) do
        love.graphics.setColor(0 * triangle.dp, 1 * triangle.dp, 0 * triangle.dp)
        fillPoly({triangle.p[1].x, triangle.p[1].y,
                  triangle.p[2].x, triangle.p[2].y,
                  triangle.p[3].x, triangle.p[3].y})

        -- Wireframe object
        if debugging then
            love.graphics.setColor(0, 0, 0)
            drawPoly({triangle.p[1].x, triangle.p[1].y,
                      triangle.p[2].x, triangle.p[2].y,
                      triangle.p[3].x, triangle.p[3].y})
        end
        love.graphics.setColor(1, 1, 1)
    end
end