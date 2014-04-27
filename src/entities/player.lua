local assets = require 'assets'
local const = require 'constants'
local PhysEntity = require 'phys_entity'


local Player = PhysEntity:extend()


local function getBucketPosition(player)
  return player.body:getX(), player.body:getY() + const.ROPE_LENGTH * const.METER_SCALE
end


function Player:init(world)
  PhysEntity.init(self, world, 0, 0, 40, 25)
  self.body:setGravityScale(0)
  self.body:setLinearDamping(const.PLAYER_DAMPING)
  self.body:setMass(const.PLAYER_MASS)

  -- Setup fish bucket
  local bx, by = getBucketPosition(self)
  self.bucket = PhysEntity(world, bx, by, 30)
  self.bucket.body:setMass(const.PLAYER_BUCKET_MASS)
  self.bucket.body:setLinearDamping(const.PLAYER_BUCKET_DAMPING)

  -- Setup joints
  local px, py = self:getPosition()
  self.rope = love.physics.newRopeJoint(
      self.body, self.bucket.body, px, py, bx, by, const.ROPE_LENGTH * const.METER_SCALE)
end


-- Reposition entire system and stop forces.
function Player:reposition(x, y)
  self.body:setLinearVelocity(0, 0)
  self.bucket.body:setLinearVelocity(0, 0)
  self.body:setPosition(x, y)
  self.bucket.body:setPosition(getBucketPosition(self))
end


function Player:update(dt)
  -- Apply upward force to the player to imitate helicopter lift
  local f = (const.PLAYER_MASS * const.PLAYER_BUCKET_MASS) * const.GRAVITY * 2
  self.body:applyForce(0, -f * dt)

  -- Constrain player
  local x, y = self:getPosition()
  if x < 0 then x = 0 elseif x + self.w > screen.width then x = screen.width - self.w end
  if y < 0 then y = 0 end
  self.body:setPosition(x, y)
end


function Player:draw()
  -- Draw player
  local px, py = self:getPosition()
  lg.setColor(255, 255, 255)
  lg.draw(assets.img.heli1, px, py)

  -- Draw bucket
  local bx, by = self.bucket:getPosition()
  lg.rectangle('fill', bx, by, self.bucket.w, self.bucket.h)

  -- Draw rope
  lg.setLineWidth(2)
  bx = bx + self.bucket.w / 2
  px = px + self.w / 2
  py = py + self.h
  lg.line(px, py, bx, by)
end


return Player