local const = require 'constants'
local Input = require 'input'
local Spawner = require 'spawner'
local Timer = require 'timer'
local Player = require 'entities.player'

local Game = Context:extend()



----------------------------------------------------------------------------------------------------
-- Helper functions



----------------------------------------------------------------------------------------------------
-- Initialization


function Game:init()
  self.input = Input()

  -- Setup game timers
  self.timers = {
    firing = Timer(const.FIRING_SPEED),
  }

  -- Setup box2d physics world
  love.physics.setMeter(const.METER_SCALE)
  self.world = love.physics.newWorld(0, const.GRAVITY*const.METER_SCALE, true)

  -- Setup game subsystems
  self.player = Player(self.world)
  self.spawner = Spawner()

  -- Entity objects fed by spawner
  self.entities = {}

  -- "Local data", simple data owned by game not encapsulated in entities.  This is basically
  -- for simplicity, as using Entity objects may be overengineering for things like water position.
  self.ldata = {
    water_y = lg.getHeight () / 2,
    bullets = {},
    fish = 0,
  }

  -- Start game
  console:write('Game initialized')
  self:start()
end


-- Start or restart game
function Game:start()
  self.player:reposition(100, 100)
  self.ldata.bullets = {}
end


----------------------------------------------------------------------------------------------------
-- State/Data functions

function Game:fire()
  local bullet = vector(self.player:getNose())
  table.insert(self.ldata.bullets, bullet)
end


function Game:collectFish(fish)
  self.ldata.fish = self.ldata.fish + 1
end


----------------------------------------------------------------------------------------------------
-- Update logic


function Game:update(dt)
  -- Update timers
  for k, v in pairs(self.timers) do v:update(dt) end

  -- Update systems
  self.world:update(dt)
  self.input:update(dt)
  self.spawner:update(dt)

  -- Check for new entities to spawn
  for i, entity in ipairs(self.spawner:getEntities()) do
    table.insert(self.entities, entity)
  end

  -- Update entity data
  self:updateLocalData(dt)
  self.player:update(dt)
  for i, entity in ipairs(self.entities) do
    entity:update(dt)
  end

  self:handleInput()
  self:handleCollisions()

  -- Prune any dead entities
  remove_if(self.entities, function(e) return e.dead end)
end


-- Update local data owned by Game
function Game:updateLocalData(dt)
  for i, bullet in ipairs(self.ldata.bullets) do
    bullet.x, bullet.y = vector.translate(bullet, const.BULLET_SPEED * dt, 0)
  end
end


function Game:handleInput()
  -- Apply force to player
  local fx, fy = self.input:getForce()
  self.player.body:applyForce(vector.scale(fx, fy, const.PLAYER_FORCE))

  -- Fire bullets
  if self.input:getFiring() and self.timers.firing:check() then
    self:fire()
  end
end


function Game:handleCollisions()
  -- Check player collisions
  local px, py = self.player:getPosition()
  if py > self.ldata.water_y - self.player.h / 2 then
    -- TODO
    console:write "Water death"
    self:start()
  end

  -- Check bucket collisions
  for i, entity in ipairs(self.entities) do
    if entity.fish and self.player.bucket:intersects(entity) then
      self:collectFish(entity)
      entity.dead = true
    end
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
  lg.rectangle('fill', 0, self.ldata.water_y, sx, sy)

  -- Draw objects
  self.player:draw()
  self:drawLocalData()
  for i, entity in ipairs(self.entities) do
    entity:draw()
  end

  -- Draw UI
  console:drawLog()
  self:drawDebug()
end


-- Draw local data owned by Game
function Game:drawLocalData(dt)
  lg.setColor(255, 255, 255)
  for i, bullet in ipairs(self.ldata.bullets) do
    lg.point(bullet.x, bullet.y)
  end
end


-- Draw debugging data
function Game:drawDebug()
  local sx, sy = lg.getWidth(), lg.getHeight()
  local r = rect(sx - 200, 10, sx, 100)
  lg.print("Fish collected:  " .. self.ldata.fish, r.left, r.top)

  -- Draw BBs
  -- local a,b,c,d = self.player.bucket:getRect()
  -- lg.setColor(255, 0, 0)
  -- lg.rectangle('fill', a, b, c - a, d - b)
  -- for i, entity in ipairs(self.entities) do
  --   local a,b,c,d = entity:getRect()
  --   lg.rectangle('fill', a, b, c - a, d - b)
  -- end
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