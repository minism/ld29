local Entity = Object:extend()


function Entity:init(x, y, w, h)
  h = h or w
  self.x, self.y = x, y
  self.w = w or self.w
  self.h = h or self.h
  self.dead = false
end


function Entity:getPosition()
  return self.x, self.y
end


function Entity:getNose()
  local x, y = self:getPosition()
  return x + self.w, y + self.h / 2
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


function Entity:update(dt) end

-- TODO debug protect this
function Entity:draw() 
  lg.setColor(255, 255, 255)
  lg.rectangle('fill', self.x, self.y, self.w, self.h)
end


return Entity