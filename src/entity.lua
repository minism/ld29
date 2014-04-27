local Entity = Object:extend()


function Entity:init(x, y, w, h)
  h = h or w
  self.x, self.y = x, y
  self.w = w or self.w
  self.h = h or self.h
  self.dead = false
end


function Entity:popEvent()
  local ev = self.event
  self.event = nil
  return ev
end


function Entity:getPosition()
  return self.x, self.y
end


function Entity:getNose()
  local x, y = self:getPosition()
  return x + self.w, y + self.h / 2
end


function Entity:getCenter()
  local x, y = self:getPosition()
  return x + self.w / 2, y + self.h / 2
end


-- Get the left,top,right,bottom AABB for this entity
function Entity:getRect()
  local x, y = self:getPosition()
  return x, y, x + self.w, y + self.h
end


-- Test if an entity intersects another entity
function Entity:intersects(other)
  local a, b, c, d = self:getRect()
  local e, f, g, h = other:getRect()
  return rect.intersects(a, b, c, d, e, f, g, h)
end


-- Phys entity can use box2d for this, but we have to mock it out for regular entitie
function Entity:getVelocity()
  return 0, 0
end


function Entity:update(dt) end

-- TODO debug protect this
function Entity:draw() 
  lg.setColor(255, 255, 255)
  lg.rectangle('fill', self.x, self.y, self.w, self.h)
end


-- Draw an image with correct rotation based on velocity
function Entity:velocityDraw(image, scale)
  scale = scale or 1
  local x, y = self:getPosition()
  local vx, vy = self:getVelocity()
  lg.push()
  lg.setColor(255, 255, 255)
  lg.translate(x + self.w / 2, y + (self.h / 2) * scale)
  lg.rotate(vx / 1000)
  lg.scale(scale)
  lg.draw(image, -self.w / 2, -self.h / 2)
  lg.pop()
end


return Entity