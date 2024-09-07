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
    _G.LookDir = Vec3(0, 0, 1)
    _G.Yaw = 0

    _G.matProj = Matrix_MakeProjection(FOV, AspectRatio, Near, Far)

    _G.Theta = 0

    meshCube:loadObjectFile("res/meshes/spitfire2.obj")
    --meshCube:loadObjectFile("res/meshes/untitled.obj")
end

function _G.update3d(dt)
    if love.keyboard.isDown("w") then
        Camera.y = Camera.y + 8 * dt
    elseif love.keyboard.isDown("s") then
        Camera.y = Camera.y - 8 * dt
    end

    if love.keyboard.isDown("d") then
        Camera.x = Camera.x + 8 * dt
    elseif love.keyboard.isDown("a") then
        Camera.x = Camera.x - 8 * dt
    end

    local forward = Vector_Mul(LookDir, 8 * dt)

    if love.keyboard.isDown("left") then
        Yaw = Yaw + 2 * dt
    elseif love.keyboard.isDown("right") then
        Yaw = Yaw - 2 * dt
    end

    if love.keyboard.isDown("up") then
        Camera = Vector_Add(Camera, forward)
    elseif love.keyboard.isDown("down") then
        Camera = Vector_Sub(Camera, forward)
    end

    -- Rotation Z
	_G.matRotZ = Matrix_MakeRotationZ(Theta)

	-- Rotation X
	_G.matRotX = Matrix_MakeRotationX(Theta * 0.5)

    _G.matTrans = Matrix_MakeTranslation(0, 0, 18)

    _G.matWorld = Matrix_MakeIdentity()
    _G.matWorld = Matrix_MultiplyMatrix(matRotZ, matRotX)
    _G.matWorld = Matrix_MultiplyMatrix(matWorld, matTrans)

    local Up = Vec3(0, 1, 0)
    local Target = Vec3(0, 0, 1)
    local matCameraRot = Matrix_MakeRotationY(Yaw)
    LookDir = Matrix_MultiplyVector(matCameraRot, Target)
    Target = Vector_Add(Camera, LookDir)

    local matCamera = Matrix_PointAt(Camera, Target, Up)
    _G.matView = Matrix_QuickInverse(matCamera)
end

function _G.draw3d()
    -- Draw triangle
    local trianglesToDraw = {}

    -- Draw
    for _, triangle in pairs(meshCube.triangles) do
        local triProjected = Triangle()
        local triTransformed = Triangle()
        local triViewed = Triangle()
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
            local light_direction = Vec3(0, 1, -1)
            light_direction = Vector_Normalise(light_direction)

            triViewed.dp = math.max(0.1, Vector_Dot(normal, light_direction))

            -- Convert world space into view space
            triViewed.p[1] = Matrix_MultiplyVector(matView, triTransformed.p[1])
            triViewed.p[2] = Matrix_MultiplyVector(matView, triTransformed.p[2])
            triViewed.p[3] = Matrix_MultiplyVector(matView, triTransformed.p[3])

            local clipped = Triangle_ClippedAgainstPlane(Vec3(0, 0, 0.1), Vec3(0, 0, 1), triViewed)
            local clippedTriangles = #clipped

            local i = 0
            while i < clippedTriangles do
                i = i + 1
                -- project
                triProjected.p[1] = Matrix_MultiplyVector(matProj, clipped[i].p[1])
                triProjected.p[2] = Matrix_MultiplyVector(matProj, clipped[i].p[2])
                triProjected.p[3] = Matrix_MultiplyVector(matProj, clipped[i].p[3])

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
    end

    -- Sort triangle
    table.sort(trianglesToDraw, function(a, b)
        local z1 = (a.p[1].z + a.p[2].z + a.p[3].z) / 3;
		local z2 = (b.p[1].z + b.p[2].z + b.p[3].z) / 3;
		return z1 > z2;

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