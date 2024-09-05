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
	_G.matRotZ = Matrix_MakeRotationZ(Theta)

	-- Rotation X
	_G.matRotX = Matrix_MakeRotationX(Theta * 0.5)

    _G.matTrans = Matrix_MakeTranslation(0, 0, 18)

    _G.matWorld = Matrix_MakeIdentity()
    _G.matWorld = Matrix_MultiplyMatrix(matRotZ, matRotX)
    _G.matWorld = Matrix_MultiplyMatrix(matWorld, matTrans)
end

function _G.draw3d()
    -- Draw triangle
    local trianglesToDraw = {}

    -- Draw
    for _, triangle in pairs(meshCube.triangles) do
        local triProjected = Triangle()
        local triTransformed = Triangle()
        -- Rotate
        triTransformed.p[1] = Matrix_MultiplyVector(matWorld, triangle.p[1])
        triTransformed.p[2] = Matrix_MultiplyVector(matWorld, triangle.p[2])
        triTransformed.p[3] = Matrix_MultiplyVector(matWorld, triangle.p[3])

        -- Calculate normal
        local normal = Vec3()

        local line1 = Vector_Sub(triTransformed.p[2], triTransformed.p[1]);
        local line2 = Vector_Sub(triTransformed.p[3], triTransformed.p[1]);

        normal = Vector_Cross(line1, line2);

        normal = Vector_Normalise(normal);

        local l = math.sqrt(normal.x*normal.x + normal.y*normal.y + normal.z*normal.z)
        normal.x = normal.x / l
        normal.y = normal.y / l
        normal.z = normal.z / l

        local CameraRay = Vector_Sub(triTransformed.p[1], Camera)

        if Vector_Dot(normal, CameraRay) < 0 then
            -- light
            local light_direction = Vec3(0, 0, -1)
            light_direction = Vector_Normalise(light_direction)

            triProjected.dp = math.max(0.1, Vector_Dot(normal, light_direction))

            -- project
            triProjected.p[1] = Matrix_MultiplyVector(matProj, triTransformed.p[1])
            triProjected.p[2] = Matrix_MultiplyVector(matProj, triTransformed.p[2])
            triProjected.p[3] = Matrix_MultiplyVector(matProj, triTransformed.p[3])

            triProjected.p[1] = Vector_Div(triProjected.p[1], triProjected.p[1].w)
            triProjected.p[2] = Vector_Div(triProjected.p[2], triProjected.p[2].w)
            triProjected.p[3] = Vector_Div(triProjected.p[3], triProjected.p[3].w)

            -- offset
            local offset = Vec3(1, 1, 0)
            triProjected.p[1] = Vector_Add(triProjected.p[1], offset)
            triProjected.p[2] = Vector_Add(triProjected.p[2], offset)
            triProjected.p[3] = Vector_Add(triProjected.p[3], offset)

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