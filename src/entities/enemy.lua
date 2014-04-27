local const = require 'constants'
local Entity = require 'entity'
local Timer = require 'timer'

local Enemy = Entity:extend {
  w = 30,
  h = 20,
}


function Enemy:init(x, y, speed)
  Entity.init(self, x, y)
  self.speed = speed
  self.health = 5
  self.hit_timer = Timer(0.1)

  -- Flags
  self.enemy = true
end


function Enemy:update(dt)
  self.hit_timer:update(dt)
  self.x = self.x - self.speed * dt
end


function Enemy:draw()
  local x, y = self:getPosition()
  if self.hit_timer:active() then
    lg.setColor(255, 255, 255)
  else
    lg.setColor(255, 255, 0)
  end
  lg.rectangle('fill', self.x, self.y, self.w, self.h)
end


function Enemy:hit(n)
  local n = n or 1
  self.hit_timer:reset()
  self.health = self.health - 1
  if self.health < 1 then
    self:die()
  end
end


function Enemy:die()
  self.dead = true
end


return Enemy