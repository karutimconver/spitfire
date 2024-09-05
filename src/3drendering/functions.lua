function Matrix_MultiplyVecto(m, v)
    local output = Vec3()
    output.x = v.x * m.m[1][1] + v.y * m.m[2][1] + v.z * m.m[3][1] + v.w * m.m[4][1]
    output.y = v.x * m.m[1][2] + v.y * m.m[2][2] + v.z * m.m[3][2] + v.w * m.m[4][2]
    output.z = v.x * m.m[1][3] + v.y * m.m[2][3] + v.z * m.m[3][3] + v.w * m.m[4][3]
    output.w = v.x * m.m[1][4] + v.y * m.m[2][4] + v.z * m.m[3][4] + v.w * m.m[4][4]
    return v
end

function Matrix_MakeIdentity()
    local matrix = Matrix()

    matrix.m[1][1] = 1
    matrix.m[2][2] = 1
    matrix.m[3][3] = 1
    matrix.m[4][4] = 1

    return matrix
end

function Matrix_MakeRotationX(angle)
    local matrix = Matrix()

    matrix.m[1][1] = 1
	matrix.m[2][2] = math.cos(angle)
	matrix.m[2][3] = math.sin(angle)
	matrix.m[3][2] = -math.sin(angle)
	matrix.m[3][3] = math.cos(angle)
	matrix.m[4][4] = 1

    return matrix
end

function Matrix_MakeRotationY(angle)
    local matrix = Matrix()

    matrix.m[1][1] = math.cos(angle)
    matrix.m[1][3] = math.sin(angle)
    matrix.m[3][1] = -math.sin(angle)
    matrix.m[2][2] = 1
    matrix.m[3][3] = math.cos(angle)
    matrix.m[4][4] = 1

    return matrix
end

function Matrix_MakeRotationZ(angle)
    local matrix = Matrix()

    matrix.m[1][1] = math.cos(angle)
	matrix.m[1][2] = math.sin(angle)
	matrix.m[2][1] = -math.sin(angle)
	matrix.m[2][2] = math.cos(angle)
	matrix.m[3][3] = 1
	matrix.m[4][4] = 1

    return matrix
end

function Matrix_MakeTranslation(x, y, z)
    local matrix = Matrix()

    matrix.m[1][1] = 1
    matrix.m[2][2] = 1
    matrix.m[3][3] = 1
    matrix.m[4][4] = 1
    matrix.m[4][1] = x
    matrix.m[4][2] = y
    matrix.m[4][3] = z

    return matrix;
end

function Matrix_MakeProjection(FOV, AspectRatio, Near, Far)
    local fov = 1.0 / math.tan(math.rad(FOV * 0.5))
    local matrix = Matrix()

    matrix.m[1][1] = AspectRatio * fov
	matrix.m[2][2] = fov
	matrix.m[3][3] = Far / (Far - Near)
	matrix.m[4][3] = (-Far * Near) / (Far - Near)
	matrix.m[3][4] = 1
	matrix.m[4][4] = 0

    return matrix
end

function Matrix_MultiplyMatrix(m1, m2)
    local matrix = Matrix()

    for c = 1, 4 do
        for r = 1, 4 do
            matrix.m[r][c] = m1.m[r][0] * m2.m[0][c] + m1.m[r][1] * m2.m[1][c] + m1.m[r][2] * m2.m[2][c] + m1.m[r][3] * m2.m[3][c];
        end
    end

    return matrix;
end

----------------------
-- Vector functions --
----------------------

function Vector_Add(v1, v2)
    return Vec3(v1.x + v2.x, v1.y + v2.y, v1.z + v2.z)
end

function Vector_Subtract(v1, v2)
    return Vec3(v1.x - v2.x, v1.y - v2.y, v1.z - v2.z)
end

function Vector_Mul(v1, k)
    return Vec3(v1.x * k, v1.y * k, v1.z * k)
end

function Vector_Div(v1, k)
    return Vec3(v1.x / k, v1.y / k, v1.z / k)
end

function Vector_Dot(v1, v2)
    return v1.x*v2.x + v1.y*v2.y + v1.z * v2.z
end

function Vector_Length(v)
    return math.sqrt(Vector_Dot(v, v))
end

function Vector_Normalise(v)
    local l = Vector_Length(v)
    return Vec3(v.x / l, v.y / l, v.z / l)
end

function Vector_Cross(v1, v2)
    local v = Vec3()

    v.x = v1.y * v2.z - v1.z * v2.y
    v.y = v1.z * v2.x - v1.x * v2.z
    v.z = v1.x * v2.y - v1.y * v2.x

    return v
end