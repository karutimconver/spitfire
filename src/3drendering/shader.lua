local love = require("love")

local shader = love.graphics.newShader([[
    uniform mat4 projectionMatrix;
    uniform mat4 objectMatrix;
    uniform mat4 viewMatrix;

    uniform bool usingCanvas;
    
    varying vec4 vertexColor;
    
    #ifdef VERTEX
        attribute vec3 VertexNormal;
        vec4 position(mat4 transform_projection, vec4 vertex_position)
        {
            vertexColor = VertexColor;
            vec4 vertexPosition = projectionMatrix * viewMatrix * objectMatrix * vertex_position;
        
            if (usingCanvas) {
                vertexPosition.y = -vertexPosition.y;
            }
            
            return vertexPosition;
        }
    #endif

    #ifdef PIXEL
        vec4 effect(vec4 color, Image tex, vec2 texcoord, vec2 pixcoord)
        {
            vec4 texcolor = Texel(tex, vec2(texcoord.x, 1-texcoord.y));
            if (texcolor.a == 0.0) { discard; }

            return texcolor*color*vertexColor;
        }
    #endif
]])

return shader