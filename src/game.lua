local const = require 'constants'
local Input = require 'input'
local PhysEntity = require 'phys_entity'
local Player = require 'player'

local Game = Context:extend()


function Game:init()
  self.input = Input()

  -- Setup physics world
  love.physics.setMeter(const.METER_SCALE)
  self.world = love.physics.newWorld(0, const.GRAVITY*const.METER_SCALE, true)

  -- Setup player system
  self.player = Player(self.world)

  console:write('Game initialized')
end


function Game:update(dt)
  -- Update systems
  self.world:update(dt)
  self.input:update(dt)
  self.player:update(dt)

  -- Handle input
  local fx, fy = self.input:getForce()
  self.player.body:applyForce(vector.scale(fx, fy, const.PLAYER_FORCE))
end


function Game:draw()
  -- Draw objects
  self.player:draw()

  -- Draw UI
  console:drawLog()
end


function Game:keypressed(key, unicode)
  if key == 'escape' then
    love.event.quit()
  end

end


return Game