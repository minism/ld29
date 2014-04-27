local util = {}


function util.constrain(lower, upper, value)
  return math.max(lower, math.min(upper, value))
end


return util