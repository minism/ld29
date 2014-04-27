local const = require 'constants'
local Input = require 'input'
local Player = require 'player'

local Game = Context:extend()


local StateTimer = Object:extend()

function StateTimer:init(duration)
  self.duration = duration
  self.t = 0
end

function StateTimer:update(dt)
  self.t = self.t - dt
end

-- Return the timer state and reset if expired
function StateTimer:check()
  if self.t < 0 then
    self.t = self.duration
    return true
  end
  return false
end



----------------------------------------------------------------------------------------------------
-- Helper functions



----------------------------------------------------------------------------------------------------
-- Initialization


function Game:init()
  self.input = Input()

  -- Game timers
  self.timers = {
    firing = StateTimer(const.FIRING_SPEED),
  }

  -- Setup physics world
  love.physics.setMeter(const.METER_SCALE)
  self.world = love.physics.newWorld(0, const.GRAVITY*const.METER_SCALE, true)

  -- Setup player system
  self.player = Player(self.world)

  -- Simple entity data
  self.water_y = lg.getHeight () / 2
  self.bullets = {}

  -- Start game
  console:write('Game initialized')
  self:start()
end


-- Start or restart game
function Game:start()
  self.player:reposition(100, 100)
  self.bullets = {}
end


----------------------------------------------------------------------------------------------------
-- State/Data functions

function Game:fire()
  local bullet = vector(self.player:getNose())
  table.insert(self.bullets, bullet)
end


----------------------------------------------------------------------------------------------------
-- Update logic


function Game:update(dt)
  -- Update timers
  for k, v in pairs(self.timers) do v:update(dt) end

  -- Update systems
  self.world:update(dt)
  self.input:update(dt)
  self.player:update(dt)
  self:updateLocalEntities(dt)

  -- Handle input and apply force to player
  local fx, fy = self.input:getForce()
  self.player.body:applyForce(vector.scale(fx, fy, const.PLAYER_FORCE))
  if self.input:getFiring() and self.timers.firing:check() then
    self:fire()
  end

  -- Check collisions
  local px, py = self.player:getPosition()
  if py > self.water_y - self.player.h / 2 then
    -- TODO
    console:write "Water death"
    self:start()
  end
end


-- Update simple entity data owned by Game
function Game:updateLocalEntities(dt)
  for i, bullet in ipairs(self.bullets) do
    bullet.x, bullet.y = vector.translate(bullet, const.BULLET_SPEED * dt, 0)
  end
end

----------------------------------------------------------------------------------------------------
-- Rendering

function Game:draw()
  -- Draw bg
  local sx, sy = lg.getWidth(), lg.getHeight()
  lg.setColor(0, 0, 0)
  lg.rectangle('fill', 0, 0, sx, sy)
  lg.setColor(0, 50, 100)
  lg.rectangle('fill', 0, self.water_y, sx, sy)

  -- Draw objects
  self.player:draw()
  self:drawLocalEntities()

  -- Draw UI
  console:drawLog()
end


-- Draw simple entity data owned by Game
function Game:drawLocalEntities(dt)
  lg.setColor(255, 255, 255)
  for i, bullet in ipairs(self.bullets) do
    lg.point(bullet.x, bullet.y)
  end
end


----------------------------------------------------------------------------------------------------
-- Input

function Game:mousepressed(x, y, button)
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