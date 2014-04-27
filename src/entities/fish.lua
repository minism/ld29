local assets = require 'assets'
local const = require 'constants'
local Entity = require 'entity'

local Fish = Entity:extend {
  w = 24,
  h = 16,
}


function Fish:init(x, y, speed)
  Entity.init(self, x, y)
  self.speed = speed

  -- TODO better way than this flag? like a "collide behavior" field
  self.fish = true
end


function Fish:update(dt)
  self.x = self.x - self.speed * dt
end


function Fish:draw()
  local x, y = self:getPosition()
  lg.setColor(255, 255, 255)
  lg.draw(assets.img.shark, self.x, self.y)
end


return Fish