local const = require 'constants'
local util = require 'util'

local Input = Object:extend()


function Input:init()
  self.dx, self.dy = 0, 0
  self.origin_x = lg.getWidth() / 2
  self.origin_y = lg.getHeight() / 2

  -- Mouse config
  love.mouse.setVisible(false)
  love.mouse.setGrabbed(true)
end


function Input:update(dt)
  local mx, my = love.mouse.getPosition()
  self.dx = mx - self.origin_x
  self.dy = my - self.origin_y
  love.mouse.setPosition(self.origin_x, self.origin_y)
end


function Input:getForce()
  local fx, fy = self.dx, self.dy
  return util.constrain(const.PLAYER_INPUT_LIMIT * -1, const.PLAYER_INPUT_LIMIT, fx),
         util.constrain(const.PLAYER_INPUT_LIMIT * -1, const.PLAYER_INPUT_LIMIT, fy)
end


function Input:getFiring()
  return love.mouse.isDown('l') or love.mouse.isDown('r')
end


return Input