require 'lib.slam'

local assets = {}


function assets.load()
  assets.img = fs.loadImages('img')
  for k, v in pairs(assets.img) do
      v:setFilter('nearest', 'nearest')
  end

  assets.sound = fs.loadSounds('sfx')
  assets.music = fs.loadSounds('music')

  for k, v in pairs(assets.sound) do
    v:setVolume(0.5)
  end

  -- Fonts
  assets.font_large = lg.newFont("font/ObelixProB-cyr.ttf", 24)
end


function assets.createSmokeSystem(img)
  local system = love.graphics.newParticleSystem(assets.img.smoke, 100)
  system:setEmissionRate(10)
  system:setParticleLifetime(1)
  system:setLinearAcceleration(0, -20)
  system:setSizes(1.0, 3.0)
  system:setSpin(0.5)
  system:setColors(255, 255, 255, 255, 255, 255, 255, 0)
  system:start()
  return system
end


return assets