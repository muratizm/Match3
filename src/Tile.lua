
Tile = Class{}

function Tile:init(x, y, color, variety,shiny)
    
    -- board positions
    self.gridY = y
    self.gridX = x

    -- coordinate positions
    self.y = (self.gridY - 1) * 32
    self.x = (self.gridX - 1) * 32

    self.variety = variety
    self.color = color
    self.shiny = shiny
    self.psystem = love.graphics.newParticleSystem(gTextures['shine'], 64)
    self.psystem:setSizeVariation(1)
    self.psystem:setEmissionRate(10)
    self.psystem:setColors(1, 1, 1, 1, 1, 1, 1, 0) -- Fade to transparency
    self.psystem:setLinearAcceleration(-20, -20, 20, 20) -- Random movement in all directions.
end

function Tile:render(x, y)
    -- draw shadow
    love.setColor(34, 32, 52, 255)
    love.graphics.draw(gTextures['main'], gFrames['tiles'][self.color][self.variety],
            self.x + x + 2, self.y + y + 2)
    love.graphics.setColor(255,255,255,255)
    love.graphics.draw(gTextures['main'], gFrames['tiles'][self.color][self.variety],
    self.x + x, self.y + y)
    love.graphics.setColor(255,255,0,255)
    if self.shiny then
        -- the shiny ones
        love.graphics.draw(gTextures['shine'],self.x+x+2,self.y+y+2,0.5,0.5,0.5)
    end
    -- reset the colors.
    love.setColor(255,255,255,255)
end
