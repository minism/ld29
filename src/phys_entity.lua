local Entity = require 'entity'

local PhysEntity = Entity:extend()


function PhysEntity:init(world, x, y, w, h)
  h = h or w
  self.body = love.physics.newBody(world, x, y, 'dynamic')
  self.shape = love.physics.newRectangleShape(w, h)
  self.fixture = love.physics.newFixture(self.body, self.shape)
  self.fixture:setRestitution(0.9)

  -- Kinda dangerous to use this
  self.w, self.h = w, h
end


-- Override
function PhysEntity:getPosition()
  return self.body:getX(), self.body:getY()
end



return PhysEntity