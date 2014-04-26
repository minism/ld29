require 'math'
require 'os'

require 'lib.strict'
require 'leaf'

local Game = require 'game'

-- Setup global objects
console = leaf.Console()


function love.load()
  -- Seed randomness
  math.randomseed(os.time()); math.random()

  -- Setup love callback handling
  local app = leaf.App()
  app:bind()

  -- Load assets
  console:write 'Loading assets'

  -- Start game
  local game = Game()
  app:pushContext(game)
end
