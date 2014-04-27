local util = require 'util'

local Timer = Object:extend()


-- Simple query-based timer rather than callback-based
function Timer:init(duration_low, duration_high)
  self.duration_low = duration_low
  self.duration_high = duration_high
  self.t = 0
end

function Timer:update(dt)
  self.t = self.t - dt
end

function Timer:reset()
  if self.duration_high then
    self.t = util.randrange(self.duration_low, self.duration_high)
  else
    self.t = self.duration_low
  end
end

-- Return the timer state and reset if expired
function Timer:check()
  if self.t < 0 then
    self:reset()
    return true
  end
  return false
end


return Timer