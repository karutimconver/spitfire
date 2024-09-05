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