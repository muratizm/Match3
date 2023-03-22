
-- this time, we're keeping all requires and assets in our Dependencies.lua file
require 'src/Dependencies'


function love.load()

    love.graphics.setDefaultFilter('nearest', 'nearest')
    -- window bar title
    love.window.setTitle('Match 3')

    -- seed the RNG
    math.randomseed(os.time())

    -- initialize our virtual resolution
    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        vsync = true,
        fullscreen = false,
        resizable = true,
        canvas = true
    })

    -- set music to loop and start
    gSounds['music']:setLooping(true)
    gSounds['music']:play()

    -- initialize state machine with all state-returning functions
    gStateMachine = StateMachine {
        ['start'] = function() return StartState() end,
        ['begin-game'] = function() return BeginGameState() end,
        ['play'] = function() return PlayState() end,
        ['game-over'] = function() return GameOverState() end
    }
    gStateMachine:change('start')

    -- keep track of scrolling our background on the X axis
    backgroundX = 0

    -- initialize input table
    love.keyboard.keysPressed = {}
    love.mouse.buttonPressed = {}
end

function love.resize(w, h)
    push:resize(w, h)
end

function love.keypressed(key)
    
    -- add to our table of keys pressed this frame
    love.keyboard.keysPressed[key] = true
end
function love.mousepressed(x,y,button)
    love.mouse.buttonPressed[button] = {x,y}
end
function love.mouse.wasPressed(button)
    if love.mouse.buttonPressed[button] then
        return love.mouse.buttonPressed[button]
    else
        return false
    end
end
function love.keyboard.wasPressed(key)
    if love.keyboard.keysPressed[key] then
        return true
    else
        return false
    end
end

function love.update(dt)
    -- scroll background, used across all states
    backgroundX = backgroundX - BACKGROUND_SCROLL_SPEED * dt
    
    -- if we've scrolled the entire image, reset it to 0
    if backgroundX <= -1024 + VIRTUAL_WIDTH - 4 + 51 then
        backgroundX = 0
    end

    gStateMachine:update(dt)
    love.mouse.buttonPressed = {}
    love.keyboard.keysPressed = {}
end

function love.draw()
    push:start()
    -- scrolling background drawn behind every state
    love.graphics.draw(gTextures['background'], backgroundX, 0)

    gStateMachine:render()
    --fps_counter()
    push:finish()
end

function fps_counter()
    love.graphics.setFont(gFonts['small'])
    love.graphics.setColor(0,255,0,255)
    love.graphics.print("FPS: " .. tostring(love.timer.getFPS()),10,10)
end
