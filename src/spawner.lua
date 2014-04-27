local const = require 'constants'
local Timer = require 'timer'
local util = require 'util'
local Fish = require 'entities.fish'

local Spawner = Object:extend()

local sx, sy = love.graphics.getWidth(), love.graphics.getHeight()


-- Entity spawner controls construction and spawning of entities based on game time
-- Game difficulty curve logic should be entirely contained within this class
-- as well as all entity factory logic.  Entity classes should not be responsible
-- for populating their own initial values.
function Spawner:init()
  self.ts = 0
  self.queue = {}

  self.timers = {
    fish = Timer(3, 8)
  }

  -- Start with timers at max
  for k, v in pairs(self.timers) do v:reset() end
end


function Spawner:update(dt)
  self.ts = self.ts + dt

  -- Update timers
  for k, v in pairs(self.timers) do v:update(dt) end

  if self.timers.fish:check() then
    table.insert(self.queue, self:createFish())
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
  local x = sx - Fish.w
  local y = util.randrange(sy / 2, sy - 100) -- TODO water pos and constants for this
  local speed = util.randvariance(const.FISH_SPEED_BASE, const.FISH_SPEED_VARIANCE)
  return Fish(x, y, speed)
end

return Spawner