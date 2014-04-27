local assets = require 'assets'
local Entity = require 'entity'
local PhysEntity = require 'phys_entity'


local Mountain = PhysEntity:extend()


local VERTEX_DATA = {
  0, 127,
  39, 77,
  54, 36,
  75, 9,
  104, 40,
  109, 105,
  125, 127,
}


-- TOTAL OVERRIDE FOR KINEMATIC BODY
function Mountain:init(world, x, y)
  Entity.init(self, x, y)
  self.body = love.physics.newBody(world, x, y, 'kinematic')
  self.shape = love.physics.newPolygonShape(unpack(VERTEX_DATA))
  self.fixture = love.physics.newFixture(self.body, self.shape)
end


function Mountain:update(dt)
  self.body:setLinearVelocity(-50, 0)
end


function Mountain:draw()
  local x, y = self:getPosition()
  lg.draw(assets.img.mountain, x, y)
end


return Mountain