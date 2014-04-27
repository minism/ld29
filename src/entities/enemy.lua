local tween = require 'lib.tween'

local assets = require 'assets'
local const = require 'constants'
local Entity = require 'entity'
local Timer = require 'timer'
local util = require 'util'


local Enemy = Entity:extend {
  w = 24,
  h = 16,
  health = 3,
}


function Enemy:init(x, y, speed)
  Entity.init(self, x, y)
  self.speed = speed
  self.hit_timer = Timer(0.1)

  -- Flags
  self.enemy = true
end


function Enemy:update(dt)
  self.hit_timer:update(dt)
end


function Enemy:draw()
  local x, y = self:getPosition()
  lg.draw(assets.img.jet, self.x, self.y)
  if self.hit_timer:active() then
    lg.setBlendMode('additive')
    lg.draw(assets.img.jet, self.x, self.y)
    lg.draw(assets.img.jet, self.x, self.y)
  end
  lg.setBlendMode('alpha')
end


function Enemy:hit(n)
  local n = n or 1
  self.hit_timer:reset()
  self.health = self.health - 1
  if self.health < 1 then
    assets.sound.enemy_die:play()
    self:die()
    return true
  else
    assets.sound.hit:play()
  end
  return false
end


function Enemy:die()
  self.dead = true
end


----------------------------------------------------------------------------------------------------


local Jet = Enemy:extend()

function Jet:update(dt)
  Enemy.update(self, dt)
  self.x = self.x - self.speed * dt
end



----------------------------------------------------------------------------------------------------



local Heli = Enemy:extend {
  w = 32,
  h = 24,
  health = 10,
  heli = true,
  act_speed = 1,
}


function Heli:init(...)
  Enemy.init(self, ...)
  local padding = 40
  self.move_rect = rect(screen.width / 2, padding, screen.width - self.w,
                        screen.height / 2 - padding)
  self.tween = nil
  self:act(1)
end


function Heli:act(action)
  action = action or math.random()
  local nx, ny = self:getPosition()
  if action > 0.8 then
    -- Move
    nx, ny = util.randompoint(self.move_rect)
  elseif action > 0.2 then
    -- Shoot
    self.event = 'rocket'
  else
    -- Wait
  end
  local time = util.randrange(self.act_speed, self.act_speed * 1.5)
  self.tween = tween.start(time, self, {x = nx, y = ny}, 'outQuad', function() self:act() end)
end


function Heli:update(dt)
  Enemy.update(self, dt)
end


function Heli:draw(dt)
  local x, y = self:getPosition()
  lg.draw(assets.img.heli2, self.x, self.y)
  if self.hit_timer:active() then
    lg.setBlendMode('additive')
    lg.draw(assets.img.heli2, self.x, self.y)
    lg.draw(assets.img.heli2, self.x, self.y)
  end
  lg.setBlendMode('alpha')
end


function Heli:die()
  Enemy.die(self)
  tween.stop(self.tween)
end


local Boss = Heli:extend {
  w = 64,
  h = 52,
  boss = true,
  act_speed = 0.75,
  heli = false,
}

function Boss:init(stage)
  local x = screen.width - 1
  local y = screen.height / 3
  self.stage = stage
  Enemy.init(self, x, y)
  self.health = stage * 25
  local padding = 20
  self.move_rect = rect(screen.width * 2 / 3, padding, screen.width - self.w,
                        screen.height / 2 - padding)
  self.tween = nil
  self.firing = 0
  self.firing_timer = Timer(1 / self.stage)
  self:act(1)
end

function Boss:act(action)
  if self.firing > 0 then
    return
  end

  action = action or math.random()
  local nx, ny = self:getPosition()
  if action > 0.7 then
    -- Move
    nx, ny = util.randompoint(self.move_rect)
  elseif action > 0.1 then
    -- Shoot
    self.firing = math.random(5, 8)
  else
    -- Wait
  end
  local time = util.randrange(self.act_speed, self.act_speed * 1.5)
  self.tween = tween.start(time, self, {x = nx, y = ny}, 'outQuad', function() self:act() end)
end


function Boss:update(dt)
  Heli.update(self, dt)
  self.firing_timer:update(dt)
  if self.firing > 0 then
    if self.firing_timer:check() then
      self.event = 'boss_rocket'
      self.firing = self.firing - 1
      if self.firing <= 0 then
        self:act()
      end
    end
  end
end


function Boss:draw()
  lg.push()
  local x, y = self:getPosition()
  lg.draw(assets.img.boss, self.x, self.y, 0, 2, 2)
  if self.hit_timer:active() then
    lg.setBlendMode('additive')
    lg.draw(assets.img.boss, self.x, self.y, 0, 2, 2)
    lg.draw(assets.img.boss, self.x, self.y, 0, 2, 2)
  end
  lg.setBlendMode('alpha')
  lg.pop()
end



----------------------------------------------------------------------------------------------------


local Rocket = Enemy:extend { 
  w = 12,
  h = 5,
  health = 2,

  -- Rocket basic physics
  ax = -350,
  ay = 0,
}


function Rocket:init(x, y, vx, vy)
  Enemy.init(self, x, y)
  self.smoke = assets.createSmokeSystem()
  self.vx = vx or 50
  self.vy = vy or 20
end


function Rocket:update(dt)
  self.x = self.x + self.vx * dt
  self.y = self.y + self.vy * dt
  self.vx = self.vx + self.ax * dt
  self.smoke:update(dt)
  self.smoke:setPosition(self.x + 14, self.y + self.h / 2)
end


function Rocket:draw()
  lg.draw(assets.img.rocket, self.x, self.y)
  lg.draw(self.smoke, 0, 0)
end


return {
  Jet = Jet,
  Heli = Heli,
  Rocket = Rocket,
  Boss = Boss,
}