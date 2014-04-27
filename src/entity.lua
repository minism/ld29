local Entity = Object:extend()


function Entity:init(x, y, w, h)
  self.x, self.y = x, y
  self.w, self.h = w, h
end


function Entity:getPosition()
  return self.x, self.y
end


function Entity:getNose()
  local x, y = self:getPosition()
  return x + self.w, y + self.h / 2
end


return Entity