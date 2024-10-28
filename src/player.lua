local cpml = require("lib/cpml")
local love = require "love"

function Player(pos)
    local object = {
        position = pos or cpml.vec3.new(0, 0, 0),
        forward = cpml.vec3.new(0, 0, 1),
        right = cpml.vec3.new(1, 0, 0),
        up = cpml.vec3.new(0, 1, 0),

        move = function(self, dt)
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

        update = function(self, dt)
            self:move(dt)
        end
    }

    return object
end