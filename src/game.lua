local const = require 'constants'
local Input = require 'input'
local PhysEntity = require 'phys_entity'

local Game = Context:extend()




function Game:init()
  self.input = Input()

  -- Setup physics world
  love.physics.setMeter(const.METER_SCALE)
  self.world = love.physics.newWorld(0, 29.8*const.METER_SCALE, true)

  -- Setup player physics object
  self.player = PhysEntity(self.world, 100, 100, 40, 25)
  self.player.body:setGravityScale(0)
  self.player.body:setLinearDamping(const.PLAYER_DAMPING)
  self.player.body:setMass(const.PLAYER_MASS)

  -- Setup fish bucket
  local bucket_y = self.player.body:getY() + const.ROPE_LENGTH * const.METER_SCALE
  self.bucket = PhysEntity(self.world, 100, bucket_y, 30)
  self.bucket.body:setMass(const.BUCKET_MASS)

  -- Setup joints
  local a, b = self.player:getPos()
  local c, d = self.bucket:getPos()
  self.player_joint = love.physics.newRopeJoint(
      self.player.body, self.bucket.body, a, b, c, d, const.ROPE_LENGTH * const.METER_SCALE)

  console:write('Game initialized')
end


function Game:update(dt)
  -- Update systems
  self.world:update(dt)
  self.input:update(dt)

  -- Handle input
  local fx, fy = self.input:getForce()
  self.player.body:applyForce(vector.scale(fx, fy, const.PLAYER_FORCE))
end


function Game:draw()
  -- Draw player
  local px, py = self.player:getPos()
  lg.setColor(200, 100, 0)
  lg.rectangle('fill', px, py, self.player.w, self.player.h)

  -- Draw bucket
  local bx, by = self.bucket:getPos()
  lg.setColor(255, 255, 2550)
  lg.rectangle('fill', bx, by, self.bucket.w, self.bucket.h)

  -- Draw rope
  lg.setLineWidth(2)
  lg.line(px, py, bx, by)

  -- Draw UI
  console:drawLog()
end


function Game:keypressed(key, unicode)
  if key == 'escape' then
    love.event.quit()
  end

end


return Game