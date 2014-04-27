require 'lib.slam'

local assets = {}


function assets.load()
  assets.img = fs.loadImages('img')
  for k, v in pairs(assets.img) do
      v:setFilter('nearest', 'nearest')
  end

  assets.sound = fs.loadSounds('sfx')
  assets.music = fs.loadSounds('music')
end


return assets