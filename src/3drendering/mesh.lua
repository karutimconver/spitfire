local love = require "love"

function Mesh(mesh, texture)
    local vertexFormat = {
        {"VertexPosition", "float", 3},
        {"VertexTexCoord", "float", 2},
        {"VertexNormal", "float", 3},
        {"VertexColor", "byte", 4},
    }

    local object =  {
        m = nil,
        texture = nil,

        loadObjectFile = function (self, path)
            assert(function() return love.filesystem.getInfo(path) ~= nil end, "Couldn't load mesh \"" .. path .. "\" file not found!")

            local lines = {}
            for line in love.filesystem.lines(path) do
                table.insert(lines, line)
            end

            local vertices = {}

            local file_vertices = {}
            local file_textureCoords = {}
            local file_normals = {}

            for _, line in ipairs(lines) do
                local data = split(line)

                if data[1] == "v" then
                    table.insert(file_vertices, {data[2], data[3], data[4]})
                elseif data[1] == "vt" then
                    table.insert(file_textureCoords, {data[2], data[3], data[4]})
                elseif data[1] == "vn" then
                    table.insert(file_normals, {data[2], data[3], data[4]})
                elseif data[1] == "f" then
                    local d1 = split(data[2], "/")
                    local d2 = split(data[3], "/")
                    local d3 = split(data[4], "/")

                    local v1 = file_vertices[tonumber(d1[1])]
                    local v2 = file_vertices[tonumber(d2[1])]
                    local v3 = file_vertices[tonumber(d3[1])]

                    local t1 = file_textureCoords[tonumber(d1[2])] or {0, 0}
                    local t2 = file_textureCoords[tonumber(d2[2])] or {0, 0}
                    local t3 = file_textureCoords[tonumber(d3[2])] or {0, 0}

                    local n1 = file_normals[tonumber(d1[#d1])] or {0, 0, 0}
                    local n2 = file_normals[tonumber(d2[#d2])] or {0, 0, 0}
                    local n3 = file_normals[tonumber(d3[#d3])] or {0, 0, 0}

                    table.insert(vertices, {v1[1],v1[2],v1[3],   t1[1],t1[2],    unpack(n1)})
                    table.insert(vertices, {v2[1],v2[2],v2[3],   t2[1],t2[2],    unpack(n2)})
                    table.insert(vertices, {v3[1],v3[2],v3[3],   t3[1],t3[2],    unpack(n3)})
                end
            end

            self.m = love.graphics.newMesh(vertexFormat, vertices, "triangles")
        end,

        setTexture = function (self, tex)
            self.texture = tex
            self.m:setTexture(tex)
        end
    }

    if mesh then
        if type(mesh) == "string" then
            object:loadObjectFile(mesh)
        elseif type(mesh) == "table" then
            object.m = love.graphics.newMesh(vertexFormat, mesh, "triangles")
        end
    end

    if texture then
        if type(texture) == "string" then
            texture = love.graphics.newImage(texture)
        end

        object:setTexture(texture)
    end

    return object
end