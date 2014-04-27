local assets = require 'assets'
local Entity = require 'entity'
local util = require 'util'


local FishGeyser = Entity:extend {
  w = 1,
  h = 1,
}


function FishGeyser:init(x, y, lost)
  Entity.init(self, x, y, lost)
  local numfish = math.floor(lost / 20)
  self.vy = -30
  self.ay = 300
  local amt = 20
  self.vx, self.xs, self.r = {}, {}, {}
  for i=1,numfish do
    self.vx[i] = math.random(-amt, amt)
    self.xs[i] = self.x
    self.r[i] = util.randrange(90, 100)
  end
end


function FishGeyser:update(dt)
  self.vy = self.vy + self.ay * dt
  self.y = self.y + self.vy * dt
  for i, v in ipairs(self.vx) do
    self.xs[i] = self.xs[i] + v * dt
    self.x = self.xs[i]
  end
end


function FishGeyser:draw()
  for i, v in ipairs(self.xs) do
    lg.draw(assets.img.shark, v, self.y, self.r[i], 0.75, 0.75)
  end
end


return FishGeyser
