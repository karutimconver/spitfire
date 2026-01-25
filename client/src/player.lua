local cpml = require "lib/cpml"
local love = require "love"
local Aircraft = require "src/aerodynamics/aircraft"

local function Player(pos)
    local object = {
        position = pos or cpml.vec3.new(0, 10, 0),
        forward = cpml.vec3.new(0, 0, 1),
        right = cpml.vec3.new(1, 0, 0),
        up = cpml.vec3.new(0, 1, 0),
        linearVelocity = cpml.vec3.new(0, 0, 15),
        angularVelocity = cpml.vec3.new(0, 0, 0),
        aircraft = Aircraft(),

        speed = 15,

        controls = function (self, dt)
            if love.keyboard.isDown("left") then
                self.up = cpml.vec3.normalize(cpml.mat4.mul_vec3_perspective(cpml.vec3.new(), cpml.mat4.from_angle_axis(1.5*dt, self.forward), self.up))
                self.right = cpml.vec3.normalize(cpml.mat4.mul_vec3_perspective(cpml.vec3.new(), cpml.mat4.from_angle_axis(1.5*dt, self.forward), self.right))
            end

            if love.keyboard.isDown("right") then
                self.up = cpml.vec3.normalize(cpml.mat4.mul_vec3_perspective(cpml.vec3.new(), cpml.mat4.from_angle_axis(-1.5*dt, self.forward), self.up))
                self.right = cpml.vec3.normalize(cpml.mat4.mul_vec3_perspective(cpml.vec3.new(), cpml.mat4.from_angle_axis(-1.5*dt, self.forward), self.right))
            end

            if love.keyboard.isDown("up") then
                self.forward = cpml.vec3.normalize(cpml.mat4.mul_vec3_perspective(cpml.vec3.new(), cpml.mat4.from_angle_axis(1*dt, self.right), self.forward))
                self.up = cpml.vec3.normalize(cpml.mat4.mul_vec3_perspective(cpml.vec3.new(), cpml.mat4.from_angle_axis(1*dt, self.right), self.up))
            end

            if love.keyboard.isDown("down") then
                self.forward = cpml.vec3.normalize(cpml.vec3.normalize(cpml.mat4.mul_vec3_perspective(cpml.vec3.new(), cpml.mat4.from_angle_axis(-1*dt, self.right), self.forward)))
                self.up = cpml.vec3.normalize(cpml.mat4.mul_vec3_perspective(cpml.vec3.new(), cpml.mat4.from_angle_axis(-1*dt, self.right), self.up))
            end
        end,

        move = function(self, dt)
            self:controls(dt)

            -- projetar o vetor right para o plano Oxz
            local p_right = cpml.vec3.normalize(cpml.vec3.new(self.right.x, 0, self.right.z))

            -- projetar o vetor up no plano que contem o vetor right e o vetor forward
            local normal_fr = cpml.vec3.normalize(cpml.vec3.cross(self.forward, p_right))
            local normal_ur = cpml.vec3.normalize(cpml.vec3.cross(self.up, p_right))
            local p_up = cpml.vec3.normalize(cpml.vec3.cross(normal_fr, normal_ur))
            local dp = -cpml.vec3.dot(p_right, self.up)
            p_up = cpml.vec3.mul(p_up, cpml.vec3.new(dp, dp, dp))
            p_up = cpml.vec3.new(p_up.x, 0, p_up.z)

            -- fator de escala da projeção de p_up
            local vertical_vector = cpml.vec3.new(0, 1, 0)           -- vetor no semieixo Oy
            local dp = cpml.vec3.dot(vertical_vector, self.forward)  -- produto escalar entre vetor no semieixo Oy e vetor forward para saber o quão longe está forward de Oy
            local diff = 1 - math.abs(dp)                            -- um se for perpendicular
            p_up = cpml.vec3.mul(p_up, cpml.vec3.new(diff, diff, diff))
            --print(p_up)
            --self.position = cpml.vec3.add(self.position, cpml.vec3.mul(self.forward, cpml.vec3.new(self.speed * dt, self.speed * dt, self.speed * dt)))
            --self.position = cpml.vec3.add(self.position, cpml.vec3.mul(p_up, cpml.vec3.new(dt * 20, dt * 20, dt * 20)))

            --[[   Novo Método    ]]

            local accelerations = self.aircraft:aerodynamics(self.forward, self.up, self.right, self.linearVelocity)

            self.linearVelocity = self.linearVelocity + accelerations.linear * dt
            self.angularVelocity = self.angularVelocity + accelerations.angular * dt

            self.position = cpml.vec3.add(self.position, cpml.vec3.scale(self.linearVelocity, dt))
        end,

        update = function(self, dt)
            self:move(dt)
        end
    }

    return object
end

return Player