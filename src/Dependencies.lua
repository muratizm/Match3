
--
-- libraries
--
Class = require 'lib/class'

push = require 'lib/push'

-- used for timers and tweening
Timer = require 'lib/knife.timer'

--
-- our own code
--

-- utility
require 'src/StateMachine'
require 'src/Util'
require 'src/constants'

-- game pieces
require 'src/Board'
require 'src/Tile'

-- game states
require 'src/states/BaseState'
require 'src/states/BeginGameState'
require 'src/states/GameOverState'
require 'src/states/PlayState'
require 'src/states/StartState'
-- love11 doesn't support creating a new audio source w/o the type being specified.
if LOVE_VERSION_11 then
    gSounds = {
        ['music'] = love.audio.newSource('sounds/music3.mp3','stream'),
        ['select'] = love.audio.newSource('sounds/select.wav','static'),
        ['error'] = love.audio.newSource('sounds/error.wav','static'),
        ['match'] = love.audio.newSource('sounds/match.wav','static'),
        ['clock'] = love.audio.newSource('sounds/clock.wav','static'),
        ['game-over'] = love.audio.newSource('sounds/game-over.wav','static'),
        ['next-level'] = love.audio.newSource('sounds/next-level.wav','static')
    }
else
    gSounds = {
        ['music'] = love.audio.newSource('sounds/music3.mp3', 'static'),
        ['game-over'] = love.audio.newSource('sounds/game-over.wav', 'static'),
        ['match'] = love.audio.newSource('sounds/match.wav', 'static'),
        ['clock'] = love.audio.newSource('sounds/clock.wav', 'static'),
        ['error'] = love.audio.newSource('sounds/error.wav', 'static'),
        ['next-level'] = love.audio.newSource('sounds/next-level.wav', 'static'),
        ['select'] = love.audio.newSource('sounds/select.wav', 'static')
    }
end

gTextures = {
    ['main'] = love.graphics.newImage('graphics/match3.png'),
    ['shine'] = love.graphics.newImage('graphics/shine2.png'),
    ['background'] = love.graphics.newImage('graphics/background.png')
}

gFrames = {
    
    -- divided into sets for each tile type in this game, instead of one large
    -- table of Quads
    ['tiles'] = GenerateTileQuads(gTextures['main'])
}

-- this time, we're keeping our fonts in a global table for readability
gFonts = {
    ['large'] = love.graphics.newFont('fonts/font.ttf', 32),
    ['medium'] = love.graphics.newFont('fonts/font.ttf', 16),
    ['small'] = love.graphics.newFont('fonts/font.ttf', 8)
}