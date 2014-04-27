local assets = require 'assets'
local const = require 'constants'
local Entity = require 'entity'
local Timer = require 'timer'

local Enemy = Entity:extend {
  w = 32,
  h = 24,
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
  lg.draw(assets.img.heli2, self.x, self.y)
  if self.hit_timer:active() then
    lg.setBlendMode('additive')
    lg.draw(assets.img.heli2, self.x, self.y)
    lg.draw(assets.img.heli2, self.x, self.y)
  end
  lg.setBlendMode('alpha')
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