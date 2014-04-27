function love.conf(t)
    -- Love settings
    t.title = "ld29"
    -- t.version = "0.0.0"
    t.author = "joshbothun@gmail.com"
    t.identity = nil
    t.console = false
    t.window.width = 1024
    t.window.height = 768
    t.window.fullscreen = false
    t.window.vsync = true
    t.window.fsaa = 0
    
    -- Modules
    t.modules.joystick = true
    t.modules.audio = true
    t.modules.keyboard = true
    t.modules.event = true
    t.modules.image = true
    t.modules.graphics = true
    t.modules.timer = true
    t.modules.mouse = true
    t.modules.sound = true   
    t.modules.physics = true
end
