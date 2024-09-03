require "src/globals"
require "src/3drendering/classes"
require "src/3drendering/functions"
require "src/draw/draw"

local love = require "love"

function _G.init3d()
    _G.meshCube = Mesh(
    --{
    --    -- SOUTH
    --    Triangle(Vec3(0.0, 0.0, 0.0), Vec3(0.0, 1.0, 0.0), Vec3(1.0, 1.0, 0.0)),
    --    Triangle(Vec3(0.0, 0.0, 0.0), Vec3(1.0, 1.0, 0.0), Vec3(1.0, 0.0, 0.0)),
--
    --    -- EAST                                                      
    --    Triangle(Vec3(1.0, 0.0, 0.0), Vec3(1.0, 1.0, 0.0), Vec3(1.0, 1.0, 1.0)),
    --    Triangle(Vec3(1.0, 0.0, 0.0), Vec3(1.0, 1.0, 1.0), Vec3(1.0, 0.0, 1.0)),
--
    --    -- NORTH                                                     
    --    Triangle(Vec3(1.0, 0.0, 1.0), Vec3(1.0, 1.0, 1.0), Vec3(0.0, 1.0, 1.0)),
    --    Triangle(Vec3(1.0, 0.0, 1.0), Vec3(0.0, 1.0, 1.0), Vec3(0.0, 0.0, 1.0)),
--
    --    -- WEST                                                      
    --    Triangle(Vec3(0.0, 0.0, 1.0), Vec3(0.0, 1.0, 1.0), Vec3(0.0, 1.0, 0.0)),
    --    Triangle(Vec3(0.0, 0.0, 1.0), Vec3(0.0, 1.0, 0.0), Vec3(0.0, 0.0, 0.0)),
--
    --    -- TOP                                                       
    --    Triangle(Vec3(0.0, 1.0, 0.0), Vec3(0.0, 1.0, 1.0), Vec3(1.0, 1.0, 1.0)),
    --    Triangle(Vec3(0.0, 1.0, 0.0), Vec3(1.0, 1.0, 1.0), Vec3(1.0, 1.0, 0.0)),
--
    --    -- BOTTOM                                                    
    --    Triangle(Vec3(1.0, 0.0, 1.0), Vec3(0.0, 0.0, 1.0), Vec3(0.0, 0.0, 0.0)),
    --    Triangle(Vec3(1.0, 0.0, 1.0), Vec3(0.0, 0.0, 0.0), Vec3(1.0, 0.0, 0.0)),
    --}
    )

    -- Projection matrix
    local Near = 0.1
	local Far = 1000.0
	local FOV = 90.0
	local AspectRatio = SCREEN_HEIGHT / SCREEN_WIDTH
	local fov = 1.0 / math.tan(math.rad(FOV * 0.5))

    _G.Camera = Vec3()

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

    meshCube:loadObjectFile("res/meshes/ship.obj")
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
        -- Rotate
        triRotatedZ.p[1] = MultiplyMatrixVector(triangle.p[1], matRotZ)
        triRotatedZ.p[2] = MultiplyMatrixVector(triangle.p[2], matRotZ)
        triRotatedZ.p[3] = MultiplyMatrixVector(triangle.p[3], matRotZ)

        triRotatedZX.p[1] = MultiplyMatrixVector(triRotatedZ.p[1], matRotX)
        triRotatedZX.p[2] = MultiplyMatrixVector(triRotatedZ.p[2], matRotX)
        triRotatedZX.p[3] = MultiplyMatrixVector(triRotatedZ.p[3], matRotX)

        -- offset
        local triTranslated = triRotatedZX
        triTranslated.p[1].z = triRotatedZX.p[1].z + 8
        triTranslated.p[2].z = triRotatedZX.p[2].z + 8
        triTranslated.p[3].z = triRotatedZX.p[3].z + 8

        -- Calculate normal
        local normal = Vec3(); local line1 = Vec3(); local line2 = Vec3()

        line1.x = triTranslated.p[2].x - triTranslated.p[1].x
        line1.y = triTranslated.p[2].y - triTranslated.p[1].y
        line1.z = triTranslated.p[2].z - triTranslated.p[1].z

        line2.x = triTranslated.p[3].x - triTranslated.p[1].x
        line2.y = triTranslated.p[3].y - triTranslated.p[1].y
        line2.z = triTranslated.p[3].z - triTranslated.p[1].z

        normal.x = line1.y * line2.z - line1.z * line2.y
		normal.y = line1.z * line2.x - line1.x * line2.z
		normal.z = line1.x * line2.y - line1.y * line2.x

		local l = math.sqrt(normal.x*normal.x + normal.y*normal.y + normal.z*normal.z)
		normal.x = normal.y / l; normal.y = normal.y / l; normal.z = normal.z / l

        if normal.x * (triTranslated.p[1].x - Camera.x) +
           normal.y * (triTranslated.p[1].y - Camera.y) +
           normal.z * (triTranslated.p[1].z - Camera.z) < 0 then
            -- light
            local light_direction = Vec3(0, 0, -1);
            local l = math.sqrt(light_direction.x^2 + light_direction.y^2 + light_direction.z^2)
            light_direction.x = light_direction.x / l
            light_direction.y = light_direction.y / l
            light_direction.z = light_direction.z / l

            local dp = normal.x * light_direction.x + normal.y * light_direction.y + normal.z * light_direction.z

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

            love.graphics.setColor(0 * dp, 1 * dp, 0 * dp)
            fillPoly({triProjected.p[1].x, triProjected.p[1].y,
                      triProjected.p[2].x, triProjected.p[2].y,
                      triProjected.p[3].x, triProjected.p[3].y})

            -- Wireframe object
            if debugging then
                love.graphics.setColor(0, 0, 0)
                drawPoly({triProjected.p[1].x, triProjected.p[1].y,
                          triProjected.p[2].x, triProjected.p[2].y,
                          triProjected.p[3].x, triProjected.p[3].y})
            end
            love.graphics.setColor(1, 1, 1)
        end
    end
end