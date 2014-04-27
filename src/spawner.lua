local const = require 'constants'
local Timer = require 'timer'
local util = require 'util'
local enemy = require 'entities.enemy'
local Fish = require 'entities.fish'
local Mountain = require 'entities.mountain'

local Spawner = Object:extend()


-- Entity spawner controls construction and spawning of entities based on game time
-- Game difficulty curve logic should be entirely contained within this class
-- as well as all entity factory logic.  Entity classes should not be responsible
-- for populating their own initial values.
function Spawner:init(world)
  self.ts = 0
  self.queue = {}
  self.world = world
  self.stage = 1

  self.timers = {
    fish = {Timer(2, 4), self.createFish},
    jet = {Timer(4, 8), self.createJet},
    heli = {Timer(5, 10), self.createHeli},
    mountain = {Timer(10, 20), self.createMountain},
  }

  -- Start with timers at max
  -- for k, v in pairs(self.timers) do v[1]:reset() end
end


function Spawner:advance()
  self.stage = self.stage + 1
  for k, v in pairs(self.timers) do
    v[1].duration_low = v[1].duration_low * const.PROGRESSION_FACTOR
    if v[1].duration_high then v[1].duration_high = v[1].duration_high * const.PROGRESSION_FACTOR end
  end
end


function Spawner:update(dt)
  self.ts = self.ts + dt

  if self.stage % 2 > 0 then
  -- Update timers
    for k, v in pairs(self.timers) do 
      v[1]:update(dt)
      if v[1]:check() then
        local e = v[2](self)
        if e then
          table.insert(self.queue, e)
        end
      end
    end
  end
end


-- Flush entity queue
function Spawner:getEntities()
  local tmp = self.queue
  self.queue = {}
  return tmp
end


----------------------------------------------------------------------------------------------------
-- Factories

function Spawner:createFish()
  local x = screen.width - 1
  local y = util.randrange(screen.height / 2 + 50, screen.height - 80)
  local factor = 1 + (self.stage - 1) * 0.25
  local speed = util.randvariance(const.FISH_SPEED_BASE * factor, const.FISH_SPEED_VARIANCE)
  local spread = math.random(20, 40)
  return Fish(x, y, speed, spread)
end

function Spawner:createJet()
  local x = screen.width - 1
  local y = util.randrange(60, screen.height / 2 - 50)
  local speed = util.randvariance(const.JET_SPEED_BASE, const.JET_SPEED_VARIANCE)
  return enemy.Jet(x, y, speed)
end

function Spawner:createHeli()
  if self.ts < 30 then
    return
  end
  local x = screen.width - 1
  local y = util.randrange(20, screen.height / 2 - 20) 
  local speed = 100
  return enemy.Heli(x, y, speed)
end

function Spawner:createMountain()
  local x = screen.width - 1
  local y = screen.height - math.random(40, 90)
  return Mountain(self.world, x, y)
end

return Spawner