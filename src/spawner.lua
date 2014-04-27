local const = require 'constants'
local Timer = require 'timer'
local util = require 'util'
local enemy = require 'entities.enemy'
local Fish = require 'entities.fish'

local Spawner = Object:extend()


-- Entity spawner controls construction and spawning of entities based on game time
-- Game difficulty curve logic should be entirely contained within this class
-- as well as all entity factory logic.  Entity classes should not be responsible
-- for populating their own initial values.
function Spawner:init()
  self.ts = 0
  self.queue = {}

  self.timers = {
    fish = {Timer(1, 3), self.createFish},
    jet = {Timer(3, 8), self.createJet},
    heli = {Timer(1), self.createHeli},
  }

  -- Start with timers at max
  -- for k, v in pairs(self.timers) do v:reset() end
end


function Spawner:update(dt)
  self.ts = self.ts + dt

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


-- Flush entity queue
function Spawner:getEntities()
  local tmp = self.queue
  self.queue = {}
  return tmp
end


----------------------------------------------------------------------------------------------------
-- Factories

function Spawner:createFish()
  local x = screen.width - Fish.w
  local y = util.randrange(screen.height / 2, screen.height - 100)
  local speed = util.randvariance(const.FISH_SPEED_BASE, const.FISH_SPEED_VARIANCE)
  return Fish(x, y, speed)
end

function Spawner:createJet()
  local x = screen.width - enemy.Jet.w
  local y = util.randrange(60, screen.height / 2 - 50)
  local speed = util.randvariance(const.JET_SPEED_BASE, const.JET_SPEED_VARIANCE)
  -- return enemy.Jet(x, y, speed)
end

function Spawner:createHeli()
  local x = screen.width - enemy.Heli.w
  local y = util.randrange(20, screen.height / 2 - 20) 
  local speed = 100
  return enemy.Heli(x, y, speed)
end

return Spawner