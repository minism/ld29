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

  -- Water data
  self.water_y = lg.getHeight () / 2

  console:write('Game initialized')

  -- Start game
  self:start()
end


-- Start or restart game
function Game:start()
  self.player:reposition(100, 100)
end


function Game:update(dt)
  -- Update systems
  self.world:update(dt)
  self.input:update(dt)
  self.player:update(dt)

  -- Handle input
  local fx, fy = self.input:getForce()
  self.player.body:applyForce(vector.scale(fx, fy, const.PLAYER_FORCE))

  -- Check collisions
  local px, py = self.player:getPos()
  if py > self.water_y - self.player.h / 2 then
    -- TODO
    console:write "Water death"
    self:start()
  end
end


function Game:draw()
  -- Draw bg
  local sx, sy = lg.getWidth(), lg.getHeight()
  lg.setColor(0, 0, 0)
  lg.rectangle('fill', 0, 0, sx, sy)
  lg.setColor(0, 50, 100)
  lg.rectangle('fill', 0, self.water_y, sx, sy)

  -- Draw objects
  self.player:draw()

  -- Draw UI
  console:drawLog()
end


function Game:keypressed(key, unicode)
  -- TODO protect debug keys
  if key == 'escape' then
    love.event.quit()
  elseif key == 'f1' then
    self:start()
  end
end


return Game