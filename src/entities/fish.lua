local assets = require 'assets'
local const = require 'constants'
local Entity = require 'entity'

local Fish = Entity:extend {
  w = 24,
  h = 16,
}


function Fish:init(x, y, speed, spread)
  Entity.init(self, x, y)
  self.speed = speed
  self.spread = spread
  self.center = y
  self.ts = 0

  -- TODO better way than this flag? like a "collide behavior" field
  self.fish = true
end


function Fish:update(dt)
  self.ts = self.ts + dt
  self.x = self.x - self.speed * dt
  self.y = self.center + math.sin(self.ts * 1.5) * self.spread
  console:write(self.y)
end


function Fish:draw()
  local x, y = self:getPosition()
  lg.setColor(255, 255, 255)
  lg.draw(assets.img.shark, self.x, self.y)
end


return Fish