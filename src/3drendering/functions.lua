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