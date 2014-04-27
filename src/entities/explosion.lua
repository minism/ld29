local assets = require 'assets'
local Entity = require 'entity'
local Sprite = require 'sprite'


local Explosion = Entity:extend {
  w = 32,
  h = 32,
}


-- Explosion created at center
function Explosion:init(x, y)
  Entity.init(self, x - self.w / 2, y - self.h / 2)
  self.sprite = Sprite(assets.img.explosion, 32, 32, 1 / 30)
end


function Explosion:update(dt)
  self.sprite:update(dt)
  if self.sprite.frame == 1 then
    self.dead = true
  end
end


function Explosion:draw()
  local x, y = self:getPosition()
  self.sprite:draw(x, y)
end


return Explosion