local Game = leaf.Context:extend()


function Game:init()
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

  console:write('Game initialized')
end


function Game:update(dt)
  self.world:update(dt)
end


function Game:draw()
  local x, y = self.player.body:getX(), self.player.body:getY()
  love.graphics.rectangle('fill', x, y, self.player.size, self.player.size)

  -- Draw UI
  console:drawLog()
end


return Game