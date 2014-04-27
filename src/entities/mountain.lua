local assets = require 'assets'
local Entity = require 'entity'
local PhysEntity = require 'phys_entity'


local Mountain = PhysEntity:extend {
  w = 16,
  h = 92,
  mountain = true,
}

-- TOTAL OVERRIDE FOR KINEMATIC BODY
function Mountain:init(world, x, y)
  Entity.init(self, x, y)
  self.body = love.physics.newBody(world, x, y, 'kinematic')
  self.shape = love.physics.newRectangleShape(0, self.h / 2, self.w, self.h)
  self.fixture = love.physics.newFixture(self.body, self.shape)
end


function Mountain:getRect()
  local a,b,c,d = PhysEntity.getRect(self)
  a,b,c,d = rect.translate(a,b,c,d,0,8)
  a,b,c,d = rect.scale(a,b,c,d,2,1)
  return rect.scaleCenter(a,b,c,d, 1.1)
end


function Mountain:update(dt)
  self.body:setLinearVelocity(-50, 0)
end


function Mountain:draw()
  local x, y = self:getPosition()
  lg.draw(assets.img.mountain, x, y)
end


return Mountain