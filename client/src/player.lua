local cpml = require "lib/cpml"
local love = require "love"
local Aircraft = require "src/aerodynamics/aircraft"

local function Player(pos)
    local object = {
        position = pos or cpml.vec3.new(0, 100, 0),
        forward = cpml.vec3.new(0, 0, 1),
        right = cpml.vec3.new(1, 0, 0),
        up = cpml.vec3.new(0, 1, 0),
        linearVelocity = cpml.vec3.new(0, 0, 100),
        angularVelocity = cpml.vec3.new(0, 0, 0),
        aircraft = Aircraft(),

        speed = 15,

        controls = function (self, dt)
            self.aircraft.airfoils.leftAileron:deflect(0)
            self.aircraft.airfoils.rightAileron:deflect(0)
            self.aircraft.airfoils.leftElevator:deflect(0)
            self.aircraft.airfoils.rightElevator:deflect(0)

            if love.keyboard.isDown("left") then
                --self.up = cpml.vec3.normalize(cpml.mat4.mul_vec3_perspective(cpml.vec3.new(), cpml.mat4.from_angle_axis(1.5*dt, self.forward), self.up))
                --self.right = cpml.vec3.normalize(cpml.mat4.mul_vec3_perspective(cpml.vec3.new(), cpml.mat4.from_angle_axis(1.5*dt, self.forward), self.right))

                self.aircraft.airfoils.leftAileron:deflect(10)
                self.aircraft.airfoils.rightAileron:deflect(-10)
            end

            if love.keyboard.isDown("right") then
                --self.up = cpml.vec3.normalize(cpml.mat4.mul_vec3_perspective(cpml.vec3.new(), cpml.mat4.from_angle_axis(-1.5*dt, self.forward), self.up))
                --self.right = cpml.vec3.normalize(cpml.mat4.mul_vec3_perspective(cpml.vec3.new(), cpml.mat4.from_angle_axis(-1.5*dt, self.forward), self.right))

                self.aircraft.airfoils.leftAileron:deflect(-10)
                self.aircraft.airfoils.rightAileron:deflect(10)
            end

            if love.keyboard.isDown("up") then
                --self.forward = cpml.vec3.normalize(cpml.mat4.mul_vec3_perspective(cpml.vec3.new(), cpml.mat4.from_angle_axis(1*dt, self.right), self.forward))
                --self.up = cpml.vec3.normalize(cpml.mat4.mul_vec3_perspective(cpml.vec3.new(), cpml.mat4.from_angle_axis(1*dt, self.right), self.up))

                self.aircraft.airfoils.leftElevator:deflect(25)
                self.aircraft.airfoils.rightElevator:deflect(25)
            end

            if love.keyboard.isDown("down") then
                --self.forward = cpml.vec3.normalize(cpml.vec3.normalize(cpml.mat4.mul_vec3_perspective(cpml.vec3.new(), cpml.mat4.from_angle_axis(-1*dt, self.right), self.forward)))
                --self.up = cpml.vec3.normalize(cpml.mat4.mul_vec3_perspective(cpml.vec3.new(), cpml.mat4.from_angle_axis(-1*dt, self.right), self.up))

                self.aircraft.airfoils.leftElevator:deflect(-25)
                self.aircraft.airfoils.rightElevator:deflect(-25)
            end
        end,

        rotate = function (self, angularVelocity, dt)
            self.forward = cpml.mat4.mul_vec3_perspective(self.forward, cpml.mat4.from_angle_axis(cpml.vec3.len(angularVelocity * dt), angularVelocity), self.forward)
            self.right = cpml.mat4.mul_vec3_perspective(self.right, cpml.mat4.from_angle_axis(cpml.vec3.len(angularVelocity * dt), angularVelocity), self.right)
            self.up = cpml.mat4.mul_vec3_perspective(self.up, cpml.mat4.from_angle_axis(cpml.vec3.len(angularVelocity * dt), angularVelocity), self.up)
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

            local accelerations = self.aircraft:aerodynamics(self.forward, self.up, self.right, self.linearVelocity, self.angularVelocity)

            self.linearVelocity = self.linearVelocity + accelerations.linear * dt
            self.angularVelocity = self.angularVelocity + accelerations.angular * dt

            self.position = self.position + self.linearVelocity * dt

            self:rotate(self.angularVelocity, dt)

            if self.position.y < 0 then
                self.position.y = 0
                self.linearVelocity.y = 0
            end
        end,

        update = function(self, dt)
            self:move(dt)
        end
    }
    print(object.aircraft.leftAileron)
    return object
end

return Player