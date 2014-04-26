local constants = require 'constants'
local Input = require 'input'

local Game = Context:extend()


function Game:init()
  self.input = Input()

  -- Setup physics world
  local pscale = 32
  love.physics.setMeter(pscale)
  self.world = love.physics.newWorld(0, 9.8*pscale, true)

  -- Setup player physics object
  self.player = {
    size = 20,
    body = love.physics.newBody(self.world, 100, 100, 'dynamic'),
    shape = love.physics.newRectangleShape(20, 20),
  }
  self.player.fixture = love.physics.newFixture(self.player.body, self.player.shape)
  self.player.fixture:setRestitution(0.9)
  self.player.body:setGravityScale(0)
  self.player.body:setLinearDamping(constants.PLAYER_DAMPING)

  console:write('Game initialized')
end


function Game:update(dt)
  -- Update systems
  self.world:update(dt)
  self.input:update(dt)

  -- Handle input
  local fx, fy = self.input:getForce()
  self.player.body:applyForce(vector.scale(fx, fy, constants.PLAYER_FORCE))
end


function Game:draw()
  local x, y = self.player.body:getX(), self.player.body:getY()
  love.graphics.rectangle('fill', x, y, self.player.size, self.player.size)

  -- Draw UI
  console:drawLog()
end


function Game:keypressed(key, unicode)
  if key == 'escape' then
    love.event.quit()
  end

end


return Game