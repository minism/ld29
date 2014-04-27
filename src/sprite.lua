local const = require 'constants'
local Timer = require 'timer'

local Sprite = Object:extend()


-- Animation encapsulation class
function Sprite:init(image, w, h, speed)
  self.w, self.h = w, h
  self.image = image
  self.quads = build_quads(image, w, h)
  self.speed = speed or const.ANIM_SPEED
  self.frame = 1
  self.timer = Timer(self.speed)
  self.corner_quad = lg.newQuad(0, self.h - 1, 1, 1, self.image:getWidth(), self.image:getHeight())
end


function Sprite:update(dt)
  self.timer:update(dt)
  if self.timer:check() then
    self.frame = (self.frame % #self.quads) + 1
  end
end


function Sprite:getQuad()
  return self.quads[self.frame]
end


return Sprite