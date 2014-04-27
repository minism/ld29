local Entity = require 'entity'

local PhysEntity = Entity:extend()


function PhysEntity:init(world, x, y, w, h)
  Entity.init(self, x, y, w, h)
  self.body = love.physics.newBody(world, x, y, 'dynamic')
  self.shape = love.physics.newRectangleShape(self.w, self.h)
  self.fixture = love.physics.newFixture(self.body, self.shape)
  self.fixture:setRestitution(0.9)

  -- Unset for safety
  self.x = nil
  self.y = nil
end


-- Override
function PhysEntity:getPosition()
  return self.body:getX(), self.body:getY()
end


-- Override
function PhysEntity:getVelocity()
  return self.body:getLinearVelocity()
end



return PhysEntity