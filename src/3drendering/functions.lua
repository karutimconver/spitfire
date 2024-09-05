function MultiplyMatrixVector(v, m)
    local o = Vec3()
    o.x = v.x * m.m[1][1] + v.y * m.m[2][1] + v.z * m.m[3][1] + m.m[4][1];
    o.y = v.x * m.m[1][2] + v.y * m.m[2][2] + v.z * m.m[3][2] + m.m[4][2];
    o.z = v.x * m.m[1][3] + v.y * m.m[2][3] + v.z * m.m[3][3] + m.m[4][3];
    local w = v.x * m.m[1][4] + v.y * m.m[2][4] + v.z * m.m[3][4] + m.m[4][4];

    if (w ~= 0.0) then
        o.x = o.x / w; o.y = o.y / w; o.z = o.z / w;
    end
    return o
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
    local matrix = Matrix_MakeIdentity()

    matrix.m[4][1] = x
    matrix.m[4][2] = y
    matrix.m[4][3] = z

    return matrix
end

function Matrix_MakeProjection(FOV, AspectRatio, Near, Far)
	local fov = 1.0 / math.tan(math.rad(FOV * 0.5))
    local matrix = Matrix()

    matrix.m[1][1] = AspectRatio * fov
	matrix.m[2][2] = fov
	matrix.m[3][3] = Far / (Far - Near)
	matrix.m[4][3] = (-Far * Near) / (Far - Near)
	matrix.m[3][4] = 1.0
	matrix.m[4][4] = 0.0

    return matrix
end

function Matrix_MultiplyMatrix(m1, m2)
    local matrix = Matrix()

    for c = 1, 4 do
        for r = 0, 4 do
            matrix.m[r][c] = m1.m[r][1] * m2.m[1][c] + m1.m[r][2] * m2.m[2][c] + m1.m[r][3] * m2.m[3][c] + m1.m[r][4] * m2.m[4][c];
        end
    end

    return matrix;
end

------------
-- Vector --
------------

function Vector_Add(v1, v2)
    return Vec3(v1.x + v2.x, v1.y + v2.y, v1.z + v2.z)
end

function Vector_Sub(v1, v2)
    return Vec3(v1.x - v2.x, v1.y - v2.y, v1.z - v2.z)
end

function Vector_Mul(v, k)
    return Vec3(v.x * k, v.y * k, v.z * k)
end

function Vector_Div(v, k)
    return Vec3(v.x / k, v.y / k, v.z / k)
end

function Vector_Dot(v1, v2)
    return v1.x * v2.x + v1.y * v2.y + v1.z * v2.z
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