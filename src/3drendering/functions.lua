function Matrix_MultiplyVector(m, v)
    local o = Vec3()

    o.x = v.x * m.m[1][1] + v.y * m.m[2][1] + v.z * m.m[3][1] + m.m[4][1]
    o.y = v.x * m.m[1][2] + v.y * m.m[2][2] + v.z * m.m[3][2] + m.m[4][2]
    o.z = v.x * m.m[1][3] + v.y * m.m[2][3] + v.z * m.m[3][3] + m.m[4][3]
    o.w = v.x * m.m[1][4] + v.y * m.m[2][4] + v.z * m.m[3][4] + m.m[4][4]

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

function Matrix_MakeProjection(fov, aspectRatio, near, far)
	--[[local fov = 1.0 / math.tan(math.rad(FOV * 0.5))
    local matrix = Matrix()

    matrix.m[1][1] = AspectRatio * fov
	matrix.m[2][2] = fov
	matrix.m[3][3] = Far / (Far - Near)
	matrix.m[4][3] = (-Far * Near) / (Far - Near)
	matrix.m[3][4] = 1.0
	matrix.m[4][4] = 0.0

    return matrix]]
    local top = near * math.tan(fov/2)
    local bottom = -1*top
    local right = top * aspectRatio
    local left = -1*right
    return {
        2*near/(right-left), 0, (right+left)/(right-left), 0,
        0, 2*near/(top-bottom), (top+bottom)/(top-bottom), 0,
        0, 0, -1*(far+near)/(far-near), -2*far*near/(far-near),
        0, 0, -1, 0
    }
end

function Matrix_MultiplyMatrix(m1, m2)
    local matrix = Matrix()

    for c = 1, 4 do
        for r = 1, 4 do
            matrix.m[r][c] = m1.m[r][1] * m2.m[1][c] + m1.m[r][2] * m2.m[2][c] + m1.m[r][3] * m2.m[3][c] + m1.m[r][4] * m2.m[4][c];
        end
    end

    return matrix;
end

function Matrix_PointAt(pos, target, up)
    -- Calculate a new forward vector
    local newForward = Vector_Sub(target, pos)
    newForward = Vector_Normalise(newForward)

    -- Calculate new Up direction
    local a = Vector_Mul(newForward, Vector_Dot(up, newForward))
    local newUp = Vector_Sub(up, a)
    newUp = Vector_Normalise(newUp)

    -- New Right direction is easy, its just cross product
    local newRight = Vector_Cross(newUp, newForward)

    -- Construct Dimensioning and Translation Matrix	
    local matrix = Matrix()
    matrix.m[1][1] = newRight.x;	matrix.m[1][2] = newRight.y;	matrix.m[1][3] = newRight.z;	matrix.m[1][4] = 0
    matrix.m[2][1] = newUp.x;		matrix.m[2][2] = newUp.y;		matrix.m[2][3] = newUp.z;		matrix.m[2][4] = 0
    matrix.m[3][1] = newForward.x;	matrix.m[3][2] = newForward.y;	matrix.m[3][3] = newForward.z;	matrix.m[3][4] = 0
    matrix.m[4][1] = pos.x;			matrix.m[4][2] = pos.y;			matrix.m[4][3] = pos.z;			matrix.m[4][4] = 1
    return matrix
end

function Matrix_QuickInverse(m)
    local matrix = Matrix()
    matrix.m[1][1] = m.m[1][1]; matrix.m[1][2] = m.m[2][1]; matrix.m[1][3] = m.m[3][1]; matrix.m[1][4] = 0
    matrix.m[2][1] = m.m[1][2]; matrix.m[2][2] = m.m[2][2]; matrix.m[2][3] = m.m[3][2]; matrix.m[2][4] = 0
    matrix.m[3][1] = m.m[1][3]; matrix.m[3][2] = m.m[2][3]; matrix.m[3][3] = m.m[3][3]; matrix.m[3][4] = 0
    matrix.m[4][1] = -(m.m[4][1] * matrix.m[1][1] + m.m[4][2] * matrix.m[2][1] + m.m[4][3] * matrix.m[3][1])
    matrix.m[4][2] = -(m.m[4][1] * matrix.m[1][2] + m.m[4][2] * matrix.m[2][2] + m.m[4][3] * matrix.m[3][2])
    matrix.m[4][3] = -(m.m[4][1] * matrix.m[1][3] + m.m[4][2] * matrix.m[2][3] + m.m[4][3] * matrix.m[3][3])
    matrix.m[4][4] = 1
    return matrix
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

function Vector_IntersectPlane(plane_p, plane_n, lineStart, lineEnd)
    plane_n = Vector_Normalise(plane_n)
    local plane_d = -Vector_Dot(plane_n, plane_p)
    local ad = Vector_Dot(lineStart, plane_n)
    local bd = Vector_Dot(lineEnd, plane_n)
    local t = (-plane_d - ad) / (bd - ad)
    local lineStartToEnd = Vector_Sub(lineEnd, lineStart)
    local lineToIntersect = Vector_Mul(lineStartToEnd, t)
    return Vector_Add(lineStart, lineToIntersect)
end

function Triangle_ClipAgainstPlane(plane_p, plane_n, in_tri)
    plane_n = Vector_Normalise(plane_n)

    local dist = function (p)
        return (plane_n.x * p.x + plane_n.y * p.y + plane_n.z * p.z - Vector_Dot(plane_n, plane_p));
    end

    local insidePoints = {}; local insidePointCount = 0
    local outsidePoints = {}; local outsidePointCount = 0

    local d1 = dist(in_tri.p[1])
    local d2 = dist(in_tri.p[2])
    local d3 = dist(in_tri.p[3])

    if d1 >= 0 then insidePointCount = insidePointCount + 1; insidePoints[insidePointCount] = in_tri.p[1]
	else outsidePointCount = outsidePointCount + 1; outsidePoints[outsidePointCount] = in_tri.p[1] end
	if d2 >= 0 then insidePointCount = insidePointCount + 1; insidePoints[insidePointCount] = in_tri.p[2]
	else outsidePointCount = outsidePointCount + 1; outsidePoints[outsidePointCount] = in_tri.p[2] end
	if d3 >= 0 then insidePointCount = insidePointCount + 1; insidePoints[insidePointCount] = in_tri.p[3]
	else outsidePointCount = outsidePointCount + 1; outsidePoints[outsidePointCount] = in_tri.p[3] end

    if insidePointCount == 0 then
        return {}
    elseif insidePointCount == 3 then
        return {in_tri}
    elseif insidePointCount == 1 and outsidePointCount == 2 then
        local out_tri = Triangle()
        out_tri.dp = in_tri.dp

        out_tri.p[1] = insidePoints[1]
        out_tri.p[2] = Vector_IntersectPlane(plane_p, plane_n, insidePoints[1], outsidePoints[1])
        out_tri.p[3] = Vector_IntersectPlane(plane_p, plane_n, insidePoints[1], outsidePoints[2])
        return {out_tri}
    elseif insidePointCount == 2 and outsidePointCount == 1 then
        local out_tri1 = Triangle()
        local out_tri2 = Triangle()

        out_tri1.dp = in_tri.dp
        out_tri2.dp = in_tri.dp

        out_tri1.p[1] = insidePoints[1];
        out_tri1.p[2] = insidePoints[2];
        out_tri1.p[3] = Vector_IntersectPlane(plane_p, plane_n, insidePoints[1], outsidePoints[1]);

        out_tri2.p[1] = insidePoints[2];
        out_tri2.p[2] = out_tri1.p[3];
        out_tri2.p[3] = Vector_IntersectPlane(plane_p, plane_n, insidePoints[2], outsidePoints[1])
        return {out_tri1, out_tri2}
    end
end