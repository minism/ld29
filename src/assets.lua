local assets = {}


function assets.load()
  assets.img = fs.loadImages('img')
  for k, v in pairs(assets.img) do
      v:setFilter('nearest', 'nearest')
  end
end


return assets