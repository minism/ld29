local util = {}


function util.constrain(lower, upper, value)
  return math.max(lower, math.min(upper, value))
end


function util.randrange(lower, upper)
  local delta = upper - lower
  return lower + math.random() * delta
end


function util.randvariance(base, variance)
  return util.randrange(base - variance, base + variance)
end


-- Get a random x, y point inside of a rectangle
function util.randompoint(rect)
  local x = math.random(rect.left, rect.right)
  local y = math.random(rect.top, rect.bottom)
  return x, y
end


return util