local const = require 'constants'
local Entity = require 'entity'

local Fish = Entity:extend {
  w = 20,
  h = 10,
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


return Fish