local assets = require 'assets'
local const = require 'constants'
local Input = require 'input'
local Spawner = require 'spawner'
local Sprite = require 'sprite'
local Timer = require 'timer'
local Player = require 'entities.player'

local Game = Context:extend()



----------------------------------------------------------------------------------------------------
-- Helper functions



----------------------------------------------------------------------------------------------------
-- Initialization


function Game:init()
  self.debug = false
  self.input = Input()

  -- Setup game timers
  self.timers = {
    firing = Timer(const.FIRING_SPEED),
  }
  self.ts = 0

  -- Setup screen 
  screen.setSize(const.SCREEN_WIDTH, const.SCREEN_HEIGHT)

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
    water_y = screen.height / 2,
    water_sprite = Sprite(assets.img.water, 16, 16),
    water_sprite_batch = lg.newSpriteBatch(assets.img.water),
    bullets = {},
    fish = 0,
  }

  -- Start music
  love.audio.play(assets.music.musdemo)

  -- Start game
  console:write('Game initialized')
  self:start()
end


-- Start or restart game
function Game:start()
  self.player:reposition(10, 10)
  self.ldata.bullets = {} 
  self.ldata.fish = 0
  self.entities = {}
  self.spawner = Spawner()
end


----------------------------------------------------------------------------------------------------
-- State/Data functions

function Game:fire()
  local x, y = self.player:getNose()
  local bullet = vector(x + 1, y + 2)
  bullet.speed = const.BULLET_SPEED
  table.insert(self.ldata.bullets, bullet)

  assets.sound.shot:play()
end


function Game:collectFish(fish)
  self.ldata.fish = self.ldata.fish + 1
  self.player:addBucketWeight(fish.mass)

  assets.sound.fish:play()
end


function Game:playerDeath()
  assets.sound.die:play()

  self:start()
end


----------------------------------------------------------------------------------------------------
-- Update logic


function Game:update(dt)
  -- Update timers
  for k, v in pairs(self.timers) do v:update(dt) end
  self.ts = self.ts + dt

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
  remove_if(self.ldata.bullets, function(e) return e.dead end)
end


-- Update local data owned by Game
function Game:updateLocalData(dt)
  for i, bullet in ipairs(self.ldata.bullets) do
    bullet.x, bullet.y = vector.translate(bullet, bullet.speed * dt, 0)
    if not rect.contains(0, 0, screen.width, screen.height, bullet.x, bullet.y) then
      bullet.dead = true
    end
  end

  -- Update local sprites
  self.ldata.water_sprite:update(dt)
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
    self:playerDeath()
  end

  -- Check entity collisions
  for i, entity in ipairs(self.entities) do

    -- Enemy checks
    if entity.enemy then
      if self.player:intersects(entity) then
        return self:playerDeath() -- Short circuit
      end

      for i, bullet in ipairs(self.ldata.bullets) do
        local a,b,c,d = entity:getRect()
        if rect.contains(a,b,c,d, bullet.x, bullet.y) then
          entity:hit()
          bullet.dead = true
        end
      end
    end

    -- Check for bucket collisions
    if entity.fish then
      local a, b, c, d = self.player:getBucketRect()
      if rect.intersects(a,b,c,d, entity:getRect()) then
        self:collectFish(entity)
        entity.dead = true
      end
    end
  end
end


----------------------------------------------------------------------------------------------------
-- Rendering

function Game:draw()
  screen.apply()

  -- Draw background
  lg.setColor(135, 206, 255)
  lg.rectangle('fill', 0, 0, screen.width, screen.height)
  self:drawParallax()

  -- Draw objects
  self.player:draw()
  self:drawLocalData()
  for i, entity in ipairs(self.entities) do
    entity:draw()
  end

  if self.debug then
    self:drawDebug()
  end
  screen.revert()

  -- Draw UI
  console:drawLog()
  self:drawDebugUi()

end


function Game:drawParallax()
  -- Draw land
  lg.setColor(150, 150, 150, 100)
  local land_y = 60
  local offset = (self.ts * 10) % screen.w
  lg.draw(assets.img.land, -offset, land_y)
  lg.draw(assets.img.land, -offset + screen.w, land_y)
  lg.setColor(150, 150, 150)
  local offset = (self.ts * 20) % screen.w
  lg.draw(assets.img.land2, -offset, land_y + 20)
  lg.draw(assets.img.land2, -offset + screen.w, land_y + 20)

  -- Draw water
  lg.setColor(0, 100, 150)
  local sprite, batch = self.ldata.water_sprite, self.ldata.water_sprite_batch
  batch:clear()
  local quad = sprite:getQuad()
  for i=0, screen.width / sprite.w + 1 do
    batch:add(quad, i * sprite.w, self.ldata.water_y)
  end
  -- Add corner quad to fill in the rest of water
  batch:add(sprite.corner_quad, 0, self.ldata.water_y + sprite.h, 0,
            screen.width + sprite.w, screen.height / 2)
  local offset = (self.ts * 60) % sprite.w
  lg.draw(batch, -offset)
end


-- Draw local data owned by Game
function Game:drawLocalData(dt)
  lg.setColor(255, 255, 255)
  for i, bullet in ipairs(self.ldata.bullets) do
    lg.setColor(255, 255, 0)
    lg.rectangle('fill', bullet.x, bullet.y, 1, 1)
  end
end


-- Draw debugging data in screen transformation
function Game:drawDebug()
  -- Draw BBs
  local a,b,c,d = self.player:getBucketRect()
  lg.setColor(255, 0, 0)
  lg.rectangle('line', a, b, c - a, d - b)
  local a,b,c,d = self.player:getRect()
  lg.setColor(255, 0, 0)
  lg.rectangle('line', a, b, c - a, d - b)
  for i, entity in ipairs(self.entities) do
    local a,b,c,d = entity:getRect()
    lg.rectangle('line', a, b, c - a, d - b)
  end
end



-- Draw debugging data
function Game:drawDebugUi()
  local sx, sy = lg.getWidth(), lg.getHeight()
  local r = rect(sx - 200, 10, sx, 100)
  lg.print("Fish collected:  " .. self.ldata.fish, r.left, r.top)
  lg.print("Bucket weight:  " .. self.player.bucket_weight, r.left, r.top + 20)
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
  elseif key == 'f2' then
    self.debug = not self.debug
  end
end


return Game