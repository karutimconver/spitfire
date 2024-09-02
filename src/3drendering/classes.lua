function Vec3(x, y, z)
    return {
        x = x or 0,
        y = y or 0,
        z = z or 0
    }
end

function Triangle(p1, p2, p3)
    return {
        p = {p1, p2, p3}
    }
end

function Mesh(triangles)
    return {
        triangles = triangles
    }
end

function Matrix()
    return {
        m = {{0, 0, 0, 0},
             {0, 0, 0, 0},
             {0, 0, 0, 0},
             {0, 0, 0, 0}}
    }
end