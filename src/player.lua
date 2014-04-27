local const = require 'constants'
local PhysEntity = require 'phys_entity'


local Player = PhysEntity:extend()


function Player:init(world)
  PhysEntity.init(self, world, 100, 100, 40, 25)
  self.body:setGravityScale(0)
  self.body:setLinearDamping(const.PLAYER_DAMPING)
  self.body:setMass(const.PLAYER_MASS)

  -- Setup fish bucket
  local bucket_y = self.body:getY() + const.ROPE_LENGTH * const.METER_SCALE
  self.bucket = PhysEntity(world, 100, bucket_y, 30)
  self.bucket.body:setMass(const.BUCKET_MASS)

  -- Setup joints
  local a, b = self:getPos()
  local c, d = self.bucket:getPos()
  self.rope = love.physics.newRopeJoint(
      self.body, self.bucket.body, a, b, c, d, const.ROPE_LENGTH * const.METER_SCALE)
end


function Player:update(dt)
  -- Apply upward force to the player to imitate helicopter lift
  local f = (const.PLAYER_MASS * const.BUCKET_MASS) * const.GRAVITY * 2.2
  self.body:applyForce(0, -f * dt)
end


function Player:draw()
  -- Draw player
  local px, py = self:getPos()
  lg.setColor(200, 100, 0)
  lg.rectangle('fill', px, py, self.w, self.h)

  -- Draw bucket
  local bx, by = self.bucket:getPos()
  lg.setColor(255, 255, 2550)
  lg.rectangle('fill', bx, by, self.bucket.w, self.bucket.h)

  -- Draw rope
  lg.setLineWidth(2)
  bx = bx + self.bucket.w / 2
  px = px + self.w / 2
  py = py + self.h
  lg.line(px, py, bx, by)
end


return Player