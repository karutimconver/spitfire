local love = require "love"

function Vec3(x, y, z)
    return {
        x = x or 0,
        y = y or 0,
        z = z or 0
    }
end

function Triangle(p1, p2, p3)
    return {
        p = {p1, p2, p3},
        dp = 0,
    }
end

function Mesh(triangles)
    return {
        triangles = triangles or {},

        loadObjectFile = function (self, path)
            assert(function() return love.filesystem.getInfo(path) ~= nil end, "Couldn't load mesh \"" .. path .. "\" file not found!")

            local lines = {}
            for line in love.filesystem.lines(path) do
                table.insert(lines, line)
            end

            local vertices = {}

            for _, line in pairs(lines) do
                local data = split(line)

                -- Create verticies

                if data[1] == "v" then
                    table.insert(vertices, Vec3(data[2], data[3], data[4]))
                end

                if data[1] == "f" then
                    local v1
                    local v2
                    local v3
                    if string.find(line, "/") == nil then
                        v1 = tonumber(data[2])
                        v2 = tonumber(data[3])
                        v3 = tonumber(data[4])
                    else
                        v1 = tonumber(split(data[2], "/")[1])
                        v2 = tonumber(split(data[3], "/")[1])
                        v3 = tonumber(split(data[4], "/")[1])

                        if vertices[v1] == nil then print("nil val found") end
                        if vertices[v2] == nil then print("nil val found") end
                        if vertices[v3] == nil then print("nil val found") end
                    end

                    table.insert(self.triangles, Triangle(vertices[v1], vertices[v2], vertices[v3]))
                end
            end

            --for j, point in pairs(vertices) do
            --    print("point " .. j .. ":")
            --    print("x: " .. point.x .. "    y: " .. point.y, "   z: " .. point.z)
            --end

            --[[for i, e in pairs(self.triangles) do
                print("triangle " .. i .. ":")
                for j, point in pairs(e.p) do
                    print("point " .. j .. ":")
                    print("x: " .. point.x .. "    y: " .. point.y, "   z: " .. point.z)
                end
            end]]
        end
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