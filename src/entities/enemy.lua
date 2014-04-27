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


local Jet = Enemy:extend()

function Jet:update(dt)
  Enemy.update(self, dt)
  self.x = self.x - self.speed * dt
end



local Heli = Enemy:extend {
  w = 32,
  h = 24,
  health = 10,
  heli = true,
}


function Heli:init(...)
  Enemy.init(self, ...)
  local padding = 40
  self.move_rect = rect(screen.width / 2, padding, screen.width - self.w,
                        screen.height / 2 - padding)
  self.tween = nil
  self:act(0)
end


function Heli:act(action)
  local nx, ny = util.randompoint(self.move_rect)
  console:write(nx)
  if action > 0 then
    self.tween = tween.start(1, self, {x = nx, y = ny}, 'outQuad')
  else
  end
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


return {
  Jet = Jet,
  Heli = Heli,
}