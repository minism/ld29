local assets = require 'assets'
local const = require 'constants'
local PhysEntity = require 'phys_entity'


local Player = PhysEntity:extend()


local function getBucketPosition(player)
  return player.body:getX(), player.body:getY() + const.ROPE_LENGTH * const.METER_SCALE
end


function Player:init(world)
  PhysEntity.init(self, world, 0, 0, 32, 18)
  self.body:setGravityScale(0)
  self.body:setLinearDamping(const.PLAYER_DAMPING)
  self.body:setMass(const.PLAYER_MASS)

  -- Setup fish bucket
  local bx, by = getBucketPosition(self)
  self.bucket = PhysEntity(world, bx, by, 32, 32, 0.2)
  self.bucket.body:setMass(const.PLAYER_BUCKET_MASS)
  self.bucket.body:setLinearDamping(const.PLAYER_BUCKET_DAMPING)
  self.bucket_weight = 0

  -- Setup joints
  local px, py = self:getPosition()
  self.rope = love.physics.newRopeJoint(
      self.body, self.bucket.body, px, py, bx, by, const.ROPE_LENGTH * const.METER_SCALE)
end


function Player:getRect()
  local a, b, c, d = PhysEntity.getRect(self)
  return rect.translate(a, b, c, d, 0, 4)
end


-- Add weight to bucket
function Player:addBucketWeight(w)
  self.bucket_weight = self.bucket_weight + w
  self.bucket.body:setMass(self.bucket_weight)
end


-- Get scaling factor for bucket AABB
function Player:getBucketScale()
  return 0.5 + self.bucket_weight / const.PLAYER_BUCKET_GROWTH
end


-- Get AABB for bucket
function Player:getBucketRect()
  local scale = self:getBucketScale()
  local a,b,c,d = self.bucket:getRect()
  a,b,c,d = rect.scale(a,b,c,d, scale, scale)
  a,b,c,d = rect.translate(a,b,c,d, - self.w * scale / 2 + self.w / 2, 0)
  return a,b,c,d
end


-- Reposition entire system and stop forces.
function Player:reposition(x, y)
  self.body:setLinearVelocity(0, 0)
  self.bucket.body:setLinearVelocity(0, 0)
  self.body:setPosition(x, y)
  self.bucket.body:setPosition(getBucketPosition(self))
  self.bucket_weight = 0
end


function Player:update(dt)
  -- Apply upward force to the player to imitate helicopter lift
  local bucket_mass = self.bucket.body:getMass()
  local f = (const.PLAYER_MASS * bucket_mass) * const.GRAVITY * 1.8
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
  self:velocityDraw(assets.img.heli1)

  -- Draw bucket
  local bx, by = self.bucket:getPosition()
  self.bucket:velocityDraw(assets.img.bucket, self:getBucketScale())

  -- Draw rope
  lg.setLineWidth(1)
  lg.setColor(255, 255, 0)
  bx = bx + self.bucket.w / 2
  px = px + self.w / 2
  py = py + self.h
  lg.line(px, py, bx, by)
end


return Player