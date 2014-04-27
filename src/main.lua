require 'math'
require 'os'

require 'lib.strict'
require 'leaf'

-- Import leaf locally
for k, v in pairs(leaf) do
  _G[k] = v
end

local assets = require 'assets'
local Game = require 'game'

-- Setup global objects
console = leaf.Console()
lg = love.graphics


function love.load()
  -- Seed randomness
  math.randomseed(os.time()); math.random()

  -- Setup love callback handling
  local app = leaf.App()
  app:bind()

  -- Load assets
  console:write 'Loading assets'
  assets.load()

  -- Start game
  local game = Game()
  app:pushContext(game)
end
