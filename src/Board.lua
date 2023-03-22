
Board = Class{}
math.randomseed(os.time())

function Board:init(x, y, lvl, ifNotMove)
    self.x = x
    self.y = y
    self.level = lvl    if ifNotMove then
        self.color = 14
    else
        self.color = math.min(14,math.floor(self.level/2)+4)
    end
    self.matches = {}
    self.tMatches = 0
    self.shinies = 0

    self.pattern = math.min(6,math.floor(self.level/2)+1)
    self:initializeTiles()
end

function Board:initializeTiles()
    self.tiles = {}
    for tileY = 1, 8 do
        -- empty table that will serve as a new row
        table.insert(self.tiles, {})
        for tileX = 1, 8 do
            -- create a new tile at X,Y with a random color and variety
            table.insert(self.tiles[tileY],Tile(tileX,tileY, math.random(self.color),math.random(self.pattern), SHINY_CHANCE == math.random(SHINY_CHANCE) and true or false))
        end
    end

    while self:moveCheck() do
        self:initializeTiles()
    end


end
--[[
    Goes left to right, top to bottom in the board, calculating matches by counting consecutive
    tiles of the same color. Doesn't need to check the last tile in every row or column if the
    last two haven't been a match.
]]

function Board:calculateMatches()
    local matches = {}

    -- how many of the same color blocks in a row we've found
    local matchNum = 1

    -- horizontal matches first
    for y = 1, 8 do
        local colorToMatch = self.tiles[y][1].color

        matchNum = 1

        -- every horizontal tile
        for x = 2, 8 do

            -- if this is the same color as the one we're trying to match...
            if self.tiles[y][x].color == colorToMatch then
                matchNum = matchNum + 1
            else

                -- set this as the new color we want to watch for
                colorToMatch = self.tiles[y][x].color

                -- if we have a match of 3 or more up to now, add it to our matches table
                if matchNum >= 3 then
                    local match = {}

                    -- go backwards from here by matchNum
                    for x2 = x - 1, x - matchNum, -1 do
                        if self.tiles[y][x2].shiny then
                            for shinyX = 1, 8 do
                                table.insert(match, self.tiles[y][shinyX])
                            end
                        else
                            table.insert(match, self.tiles[y][x2])
                        end
                    end

                    -- add this match to our total matches table
                    table.insert(matches, match)
                end

                matchNum = 1

                -- don't need to check last two if they won't be in a match
                if x >= 7 then
                    break
                end
            end
        end

        -- account for the last row ending with a match
        if matchNum >= 3 then
            local match = {}

            -- go backwards from end of last row by matchNum
            for x = 8, 8 - matchNum + 1, -1 do
                if self.tiles[y][x].shiny then
                    for shinyX = 1, 8 do
                        table.insert(match, self.tiles[y][shinyX])
                    end
                else
                    table.insert(match, self.tiles[y][x])
                end
            end

            table.insert(matches, match)
        end
    end

    -- vertical matches
    for x = 1, 8 do
        local colorToMatch = self.tiles[1][x].color

        matchNum = 1

        -- every vertical tile
        for y = 2, 8 do
            if self.tiles[y][x].color == colorToMatch then
                matchNum = matchNum + 1
            else
                colorToMatch = self.tiles[y][x].color

                if matchNum >= 3 then
                    local match = {}

                    for y2 = y - 1, y - matchNum, -1 do
                        if self.tiles[y2][x].shiny then
                            for shinyX = 1, 8 do
                                table.insert(match, self.tiles[y2][shinyX])
                            end
                        else
                            table.insert(match, self.tiles[y2][x])
                        end
                    end

                    table.insert(matches, match)
                end

                matchNum = 1

                -- don't need to check last two if they won't be in a match
                if y >= 7 then
                    break
                end
            end
        end

        -- account for the last column ending with a match
        if matchNum >= 3 then
            local match = {}

            -- go backwards from end of last row by matchNum
            for y = 8, 8 - matchNum + 1, -1 do
                -- check if it's a shiny tile and set the whole row as a match
                if self.tiles[y][x].shiny then
                    for shinyX = 1, 8 do
                        table.insert(match, self.tiles[y][shinyX])
                    end
                else
                    table.insert(match, self.tiles[y][x])
                end
            end

            table.insert(matches, match)
        end
    end

    -- store matches for later reference
    self.matches = matches

    -- return matches table if > 0, else just return false
    return self.matches
end

--[[
    Remove the matches from the Board by just setting the Tile slots within
    them to nil, then setting self.matches to nil.
]]
function Board:removeMatches()
    for k, match in pairs(self.matches) do
        for k, tile in pairs(match) do
            self.tiles[tile.gridY][tile.gridX] = nil
        end
    end

    self.matches = nil
end


--[[
    Remove the matches from the Board by just setting the Tile slots within
    them to nil, then setting self.matches to nil.
]]
function Board:removeMatches()
    for k, match in pairs(self.matches) do
        for k, tile in pairs(match) do
            self.tiles[tile.gridY][tile.gridX] = nil
        end
    end

    self.matches = nil
end

--[[
    Shifts down all of the tiles that now have spaces below them, then returns a table that
    contains tweening information for these new tiles.
]]
function Board:getFallingTiles()
    -- tween table, with tiles as keys and their x and y as the to values
    local shiny = false
    local tweens = {}
    -- for each column, go up tile by tile till we hit a space
    for x = 1, 8 do
        local spaceY = 0
        local space = false

        local y = 8
        while y >= 1 do

            -- if our last tile was a space...
            local tile = self.tiles[y][x]

            if space then

                -- if the current tile is *not* a space, bring this down to the lowest space
                if tile then

                    -- put the tile in the correct spot in the board and fix its grid positions
                    self.tiles[spaceY][x] = tile
                    tile.gridY = spaceY

                    -- set its prior position to nil
                    self.tiles[y][x] = nil

                    -- tween the Y position to 32 x its grid position
                    tweens[tile] = {
                        y = (tile.gridY - 1) * 32
                    }

                    -- set Y to spaceY so we start back from here again
                    space = false
                    y = spaceY

                    -- set this back to 0 so we know we don't have an active space
                    spaceY = 0
                end
            elseif tile == nil then
                space = true

                -- if we haven't assigned a space yet, set this to it
                if spaceY == 0 then
                    spaceY = y
                end
            end

            y = y - 1
        end
    end

    -- create replacement tiles at the top of the screen
    for x = 1, 8 do
        for y = 8, 1, -1 do
            local tile = self.tiles[y][x]

            -- if the tile is nil, we need to add a new one
            if not tile then
                -- new tile with random color and variety
                local tile = Tile(x, y, math.random(self.color), math.random(self.pattern),SHINY_CHANCE == math.random(SHINY_CHANCE) and true or false)
                tile.y = -32
                self.tiles[y][x] = tile

                -- create a new tween to return for this tile to fall down
                tweens[tile] = {
                    y = (tile.gridY - 1) * 32
                }
            end
        end
    end

    return tweens
end


function Board:moveCheck()
    local shiny_col = false
    local matchNum = 1
    -- horizontal matches
    for y = 1, 8 do
        local colorToMatch = self.tiles[y][1].color
        matchNum = 1
        shiny_col = self.tiles[y][1].shiny
        --  horizontal tiles
        for x = 2, 8 do
            -- if this is the same color as the one we're trying to match...
            if self.tiles[y][x].color == colorToMatch then
                matchNum = matchNum + 1

            else

                -- set this as the new color we want to watch for
                colorToMatch = self.tiles[y][x].color
                shiny_col = self.tiles[y][x].shiny
                -- if we have a match of 3 or more up to now, add it to our matches table
                if matchNum >= 3 then
                    return true
                end

                matchNum = 1

                -- don't need to check last two if they won't be in a match
                if x >= 7 then
                    break
                end
            end
        end

        -- account for the last row ending with a match
        if matchNum >= 3 then
            return true
        end
    end

    -- vertical matches
    for x = 1, 8 do
        local colorToMatch = self.tiles[1][x].color
        matchNum = 1
        shiny_col = self.tiles[1][x].shiny
        -- every vertical tile
        for y = 2, 8 do
            if self.tiles[y][x].color == colorToMatch then
                matchNum = matchNum + 1
            else

                colorToMatch = self.tiles[y][x].color
                shiny_col = self.tiles[y][x].shiny

                if matchNum >= 3 then
                    return true
                end

                matchNum = 1

                -- don't need to check last two if they won't be in a match
                if y >= 7 then
                    break
                end
            end
        end

        -- account for the last column ending with a match
        if matchNum >= 3 then
            return true
        end
    end
    return false
end

function Board:BControl()
    local y2 = 1
    local x2 = 1
    local swaps =1
    local temporary = deepcopy(self.tiles)
    local previous = temporary[y2][x2]
    for y=1,8 do
        y2=y
        x2=1
        for x=2,8 do
            previous = temporary[y2][x2]
            -- swap positions
            local tempY = previous.gridY
            local tempX = previous.gridX
            local newTile = temporary[y][x]

            previous.gridY = newTile.gridY
            newTile.gridY = tempY
            previous.gridX = newTile.gridX
            newTile.gridX = tempX

            -- swap tiles
            temporary[newTile.gridY][newTile.gridX] = newTile
            temporary[previous.gridY][previous.gridX] = previous

            if self:Validation(temporary) then
                return true
            end
            swaps = swaps + 1
            x2=x
        end
    end
    for x=1,8 do
        y2=1
        x2=x
        for y=1,8 do
            previous = temporary[y2][x2]
            -- swap positions
            local tempY = previous.gridY
            local tempX = previous.gridX

            local newTile = temporary[y][x]

            previous.gridY = newTile.gridY
            newTile.gridY = tempY
            previous.gridX = newTile.gridX
            newTile.gridX = tempX

            -- swap tiles
            temporary[previous.gridY][previous.gridX] = previous
            temporary[newTile.gridY][newTile.gridX] = newTile

            if self:Validation(temporary) then
                return true
            end
            swaps = swaps + 1
            y2 = y
        end
    end
    return false
end

function Board:getMatches()
    return self.matches
end


function Board:render()
    for y = 1, #self.tiles do
        for x = 1, #self.tiles[1] do
            self.tiles[y][x]:render(self.x, self.y)
        end
    end
end



function Board:Validation(tiles)

    -- same color blocks in a row found
    local shiny_col = false
    local matchNum = 1
    -- horizontal matches first
    for y = 1, 8 do
        shiny_col = tiles[y][1].shiny
        local colorToMatch = tiles[y][1].color
        matchNum = 1
        -- horizontal matches
        for x = 2, 8 do
            -- if this is the same color as the one we're trying to match...
            if tiles[y][x].color == colorToMatch then
                matchNum = matchNum + 1
            else

                shiny_col = tiles[y][x].shiny
                colorToMatch = tiles[y][x].color
                -- if we have a match of 3 or more
                if matchNum >= 3 then
                    return true
                end
                matchNum = 1
            end
        end

        -- if last row ending with a match
        if matchNum >= 3 then
            return true
        end
    end

    -- vertical matches
    for x = 1, 8 do
        matchNum = 1
        shiny_col = tiles[1][x].shiny
        local colorToMatch = tiles[1][x].color
        -- every vertical tile
        for y = 2, 8 do
            if tiles[y][x].color == colorToMatch then
                matchNum = matchNum + 1

            else

                shiny_col = tiles[y][x].shiny
                colorToMatch = tiles[y][x].color

                if matchNum >= 3 then
                    return true
                end
                matchNum = 1

            end
        end

        -- account for the last column ending with a match
        if matchNum >= 3 then
            return true
        end
    end
    return false
end

function Board:getLevel()
    return self.level
end




function Board:Valid(x1, y1, x2, y2, tiles)
    local tiles = tiles ~= nil and tiles or self.tiles
    local min_item = {
        [3] = 1,
        [2] = 1,
        [1] = 1
    }
    local max_item = {
        [6] = 8,
        [7] = 8,
        [8] = 8
    }
    local max_y = y1 >= 6 and max_item[y1] or y1 + 2
    local min_y = y1 <= 3 and min_item[y1] or y1 - 2
    local max_x = x1 >= 6 and max_item[x1] or x1 + 2
    local min_x = x1 <= 3 and min_item[x1] or x1 - 2
    local colorToMatch = tiles[y1][min_x].color
    local matchNum = 1
    for x=min_x+1,max_x do
        if tiles[y1][x].color == colorToMatch then
            matchNum = matchNum +1
        else
            if matchNum >= 3 then
                return true
            end
            matchNum = 1
            colorToMatch= tiles[y1][x].color
        end
    end
    if matchNum >=3 then
        return true
    end
    matchNum = 1
    colorToMatch = tiles[min_y][x1].color
    for y=min_y+1,max_y do
        if tiles[y][x1].color == colorToMatch then
            matchNum = matchNum + 1
        else
            if matchNum >=3 then
                return true
            end
            matchNum = 1
            colorToMatch = tiles[y][x1].color
        end
    end
    if matchNum >= 3 then
        return true
    end
    max_y = y2 >= 6 and max_item[y2] or y2 + 2
    min_y = y2 <= 3 and min_item[y2] or y2 - 2
    max_x = x2 >= 6 and max_item[x2] or x2 + 2
    min_x = x2 <= 3 and min_item[x2] or x2 - 2
    colorToMatch = tiles[y2][min_x].color
    matchNum = 1
    for x=min_x+1,max_x do
        if tiles[y2][x].color == colorToMatch then
            matchNum = matchNum +1
        else
            if matchNum >= 3 then
                return true
            end
            matchNum = 1
            colorToMatch = tiles[y2][x].color
        end
    end
    if matchNum >= 3 then
        return true
    end
    colorToMatch = tiles[min_y][x2].color
    matchNum = 1
    for y=min_y+1,max_y do
        if tiles[y][x2].color == colorToMatch then
            matchNum = matchNum + 1
        else
            if matchNum >=3 then
                return true
            end
            matchNum = 1
            colorToMatch = tiles[y][x2].color
        end
    end
    if matchNum >=3 then
        return true
    end
    return false
end

function Board:getTotalMatches()
    return self.totalMatches
end

