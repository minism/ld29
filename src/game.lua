local tween = require 'lib.tween'

local assets = require 'assets'
local const = require 'constants'
local enemy = require 'entities.enemy'
local Explosion = require 'entities.explosion'
local Input = require 'input'
local Spawner = require 'spawner'
local Sprite = require 'sprite'
local Timer = require 'timer'
local Player = require 'entities.player'
local util = require 'util'

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
    restart = Timer(1.5),
  }
  self.ts = 0
  self.player_death = false

  -- Setup screen 
  screen.setSize(const.SCREEN_WIDTH, const.SCREEN_HEIGHT)

  -- Setup box2d physics world
  love.physics.setMeter(const.METER_SCALE)
  self.world = love.physics.newWorld(0, const.GRAVITY*const.METER_SCALE, true)

  -- Setup game subsystems
  self.player = Player(self.world)
  self.spawner = Spawner(self.world)

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
    heli_count = 0,
    sky_color = {135, 206, 255},
  }

  -- Start game
  console:write('Game initialized')
  self:start()
end


-- Start or restart game
function Game:start()
  if self.music then self.music:stop() end
  self.music = assets.music.mus1:play()
  self.music:setLooping(true)
  self.music:setVolume(0.8)
  self.player:reposition(10, 10)
  self.ldata.bullets = {} 
  self.ldata.fish = 0
  self.ldata.heli_count = 0
  self.entities = {}
  self.spawner = Spawner(self.world)
  self.ts = 0
  self.player_death = false
end


----------------------------------------------------------------------------------------------------
-- State/Data functions

function Game:fire()
  local x, y = self.player:getNose()
  local bullet = vector(x + 1, y + 1)
  bullet.speed = const.BULLET_SPEED
  table.insert(self.ldata.bullets, bullet)

  assets.sound.shot:play()
end


function Game:collectFish(fish)
  self.ldata.fish = self.ldata.fish + 1
  local mass = math.random(10, 20)
  self.player:addBucketWeight(mass)

  assets.sound.fish:play()
end


function Game:playerDeath()
  self.player_death = true
  assets.sound.die:play()
  self.timers.restart:reset()
  self.music:stop()
  local a, b, c, d = self.player:getRect()
  a, b, c, d = rect.translate(a,b,c,d, -self.player.w / 2, -self.player.h / 2)
  for i=1,3 do
    local explosion = Explosion(util.randompoint(rect(a,b,c,d)))
    table.insert(self.entities, explosion)
  end
end


----------------------------------------------------------------------------------------------------
-- Update logic


function Game:update(dt)
  -- Update timers
  for k, v in pairs(self.timers) do v:update(dt) end
  self.ts = self.ts + dt

  -- Update systems
  tween.update(dt)
  self.world:update(dt)
  self.input:update(dt)
  self.spawner:update(dt)

  -- Check for new entities to spawn
  for i, entity in ipairs(self.spawner:getEntities()) do
    if entity.heli then
      if self.ldata.heli_count < const.HELI_LIMIT then
        self.ldata.heli_count = self.ldata.heli_count + 1
        table.insert(self.entities, entity)
      end
    else
      table.insert(self.entities, entity)
    end
  end

  -- Update entity data
  self:updateLocalData(dt)
  self.player:update(dt)
  for i, entity in ipairs(self.entities) do
    entity:update(dt)

    -- Check for entity events!
    -- This is garbage design, but its 5AM and im tired, so we're doing it this way now
    if entity:popEvent() == 'rocket' then
      local x, y = entity:getNose()
      x = x - 5
      table.insert(self.entities, enemy.Rocket(x, y))
      assets.sound.rocket:play()
    end

    -- Check for OOB entities
    if not rect.contains(0, 0, screen.width, screen.height, entity.x, entity.y) then
      entity.dead = true
    end
  end

  if not self.player_death then
    self:handleInput()
    self:handleCollisions()
  end

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
        return self:playerDeath()  -- Short circuit
      end

      for i, bullet in ipairs(self.ldata.bullets) do
        local a,b,c,d = entity:getRect()
        if rect.contains(a,b,c,d, bullet.x, bullet.y) then

          -- Entity was killed
          if entity:hit() then
            table.insert(self.entities, Explosion(entity:getCenter()))
            if entity.heli then
              self.ldata.heli_count = self.ldata.heli_count - 1
            end
          end
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

  -- Draw background w/ day/night cycle
  local speed = 40
  local darken = (math.sin((self.ts - math.pi * speed / 2) / speed) + 1) * 100
  local r,g,b = color.darken(self.ldata.sky_color, darken)
  lg.setColor(r,g,b)
  lg.rectangle('fill', 0, 0, screen.width, screen.height)
  self:drawParallax()

  -- Draw objects
  if not self.player_death then
    self.player:draw()
  end
  self:drawLocalData()
  for i, entity in ipairs(self.entities) do
    entity:draw()
  end

  if self.player_death then
    lg.setColor(0, 0, 0, 128)
    lg.rectangle('fill', 0, 0, screen.width, screen.height)
  end

  if self.debug then
    self:drawDebug()
  end
  screen.revert()

  -- Draw UI
  if not self.player_death then
    self:drawInterface()
  else
    self:drawDeathScreen()
  end
  if self.debug then
    console:drawLog()
  end

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
    lg.setColor(255, 255, 255)
    lg.draw(assets.img.bullet, bullet.x, bullet.y)
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


function Game:drawInterface()
  lg.setFont(assets.font_large)
  lg.setColor(255, 255, 255)
  lg.print("Carrying " .. self.player.bucket_weight .. " pounds", 7, 2)
end


function Game:drawDeathScreen()
  lg.setFont(assets.font_huge)
  lg.setColor(255, 255, 255)
  local padding = 150
  local text = "You died carrying " .. self.player.bucket_weight .. " pounds of shark meat." ..
               " Press any button to try again, or escape to quit."
  lg.printf(text, padding, padding, love.graphics.getWidth() - padding * 2, "center")
end


----------------------------------------------------------------------------------------------------
-- Input

function Game:mousepressed(x, y, button)
  if self.player_death and self.timers.restart:check() then
    self:start()
  end
end


function Game:keypressed(key, unicode)
  if key == 'escape' then
    love.event.quit()
  elseif self.player_death and self.timers.restart:check() then
    self:start()
  -- TODO protect debug keys
  elseif key == 'f1' then
    self:start()
  elseif key == 'f2' then
    self.debug = not self.debug
  elseif key == 'f3' then
    console:write(#self.entities)
  end
end


return Game