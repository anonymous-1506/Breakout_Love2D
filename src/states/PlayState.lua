--[[
    GD50
    Breakout Remake

    -- PlayState Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    Represents the state of the game in which we are actively playing;
    player should control the paddle, with the ball actively bouncing between
    the bricks, walls, and the paddle. If the ball goes below the paddle, then
    the player should lose one point of health and be taken either to the Game
    Over screen if at 0 health or the Serve screen otherwise.
]]

PlayState = Class{__includes = BaseState}

--[[
    We initialize what's in our PlayState via a state table that we pass between
    states as we go from playing to serving.
]]
function PlayState:enter(params)
    self.paddle = params.paddle
    self.bricks = params.bricks
    self.health = params.health
    self.score = params.score
    self.highScores = params.highScores
    --the table is imported 
    self.balls = params.balls
    self.level = params.level
    -- new table is initiated to store all the powerups 
    self.Powerups1 = {}
    self.Keys = {}
    self.collectedKey = {}
    self.usedKey = {}

    self.recoverPoints = 5000

    -- give the first ball random starting velocity
    self.balls[1].dx = math.random(-200, 200)
    self.balls[1].dy = math.random(-50, -60)
end
local timer = 0
function PlayState:update(dt)
        -- MY CODE : 
        -- 1. Code to Spawn a powerup rabdomly in every 10 to 15 seconds:
        timer = timer + dt
        local timer2 = math.random(10,15)
    
        if timer >= timer2 then
            -- inserting a new powerup in the table
            table.insert(self.Powerups1,Powerup(math.random(9)))
            timer = 0
        end
        -- 2. Code to update the powwerups :
        for i, pairs in pairs(self.Powerups1) do
            pairs:update(dt)
        end
        -- incase powerup collides with the paddle or crosses the window:
        for i, pairs in pairs(self.Powerups1) do
            if pairs.y > WINDOW_HEIGHT or pairs:collides(self.paddle) then
                pairs.death = true
                -- inserting new balls in the table if powerup is indeed collected.
                if pairs:collides(self.paddle) then
                    gSounds['confirm']:play()
                    -- local two = math.random(7,9)
                    table.insert(self.balls,Ball(math.random(4),pairs.x,pairs.y,math.random(-200, 200),math.random(-50, -60)))
                    table.insert(self.balls,Ball(math.random(4),pairs.x + 10,pairs.y,math.random(-200, 200),math.random(-50, -60)))
                end
            end
        end
        -- 3. In case, the powerup is dead (collected or crossed the window) then tae it off the table and save memory:
        for k, pairs in pairs(self.Powerups1) do
            if pairs.death then
                table.remove(self.Powerups1,k)
            end
        end
        -- same as above but for the balls:
        for k, pairs in pairs(self.balls) do
            if pairs.y > VIRTUAL_HEIGHT then
                table.remove(self.balls,k)
            end
        end

        -- 4.Code to resize the paddle: 
    if self.paddle.dec then
        self.paddle.size = math.max(1,self.paddle.size - 1)
        self.paddle.width = self.paddle.size * 32
        self.paddle.dec = false
    end
    if self.paddle.inc then
        self.paddle.size = math.min(self.paddle.size + 1,4)
        self.paddle.width = self.paddle.size * 32
        self.paddle.inc = false
    end


    -- ORIGINAL CODE STARTS HERE:
    if self.paused then
        if love.keyboard.wasPressed('space') then
            self.paused = false
            gSounds['pause']:play()
        else
            return
        end
    elseif love.keyboard.wasPressed('space') then
        self.paused = true
        gSounds['pause']:play()
        return
    end

    -- update positions based on velocity
    self.paddle:update(dt)
    --
    for j, pairs in pairs(self.balls) do
        pairs:update(dt)
    end

    --logic to release the key powerup based on the total number of bricks
    local liveBrics = 0
    for i, brick in pairs(self.bricks) do
        if brick.inPlay then
            liveBrics = liveBrics + 1
        end
    end
    if liveBrics <= #self.bricks/2 then
        if #self.Keys < self.level and #self.collectedKey < self.level then
        table.insert(self.Keys,Key())
    end
    end
    --end of the above logic

    for i, pairs in ipairs(self.balls) do
        if pairs:collides(self.paddle) then
            -- raise ball above paddle in case it goes below it, then reverse dy
            pairs.y = self.paddle.y - 8
            pairs.dy = -pairs.dy
    
            --
            -- tweak angle of bounce based on where it hits the paddle
            --
    
            -- if we hit the paddle on its left side while moving left...
            if pairs.x < self.paddle.x + (self.paddle.width / 2) and self.paddle.dx < 0 then
                pairs.dx = -50 + -(8 * (self.paddle.x + self.paddle.width / 2 - pairs.x))
            
            -- else if we hit the paddle on its right side while moving right...
            elseif pairs.x > self.paddle.x + (self.paddle.width / 2) and self.paddle.dx > 0 then
                pairs.dx = 50 + (8 * math.abs(self.paddle.x + self.paddle.width / 2 - pairs.x))
            end
    
            gSounds['paddle-hit']:play()
        end
    end

    for l, Key in pairs(self.Keys) do
        Key:update(dt)
    end

    for l, Key in pairs(self.Keys) do
        if Key:collides(self.paddle) or Key.y > VIRTUAL_HEIGHT then
            Key.death = true
            if Key:collides(self.paddle) then
                table.insert(self.collectedKey,Key)
                collected = collected + 1

            end
        end
    end

    for l, Key in pairs(self.Keys) do
        if Key.death then
            table.remove(self.Keys,l)
        end
    end

    --logic to remove used Keys:
    local diff = #self.collectedKey - collected
    for i=1,diff do
        table.remove(self.collectedKey,#self.collectedKey)
    end
    --end of prev logic

    -- for l, Key in pairs(self.collectedKey) do
    --     if Key.death then
    --         table.remove(self.collectedKey,l)
    --     end
    -- end

    -- for i, brick in pairs(self.bricks) do
        
    --     for j, ball in pairs(self.balls) do

    --         if brick.loc and ball:collides(brick) then
    --             if #self.collectedKey > 1 then
    --                 brick.loc = false
    --                 brick.inPlay = false
    --                 brick.locval = 0
    --             end
    --         end
            
    --     end
        
    -- end

    -- detect collision across all bricks with the ball
    for k, brick in pairs(self.bricks) do

        for l, pairs in pairs(self.balls) do
            -- only check collision if we're in play
        if brick.inPlay and pairs:collides(brick) then
            -- add to score
            if not brick.loc then
                self.score = self.score + (brick.tier * 200 + brick.color * 25)
            elseif brick.loc then
                if #self.collectedKey == 0 then
                    self.score = self.score + (brick.tier * 200 + brick.color * 25) 
                elseif #self.collectedKey >= 1 then
                    self.score = self.score + (brick.tier * 200 + brick.color * 25) + 500
                end
            end
            self.score = self.score + (brick.tier * 200 + brick.color * 25)


            -- trigger the brick's hit function, which removes it from play
            brick:hit()

            -- if brick.loc and brick.ht == 2 then
            --     if #self.collectedKey < self.level and #self.Keys < self.level then
            --         table.insert(self.Keys,Key())
            --     end
            -- end


            -- if we have enough points, recover a point of health
            if self.score > self.recoverPoints then
                -- can't go above 3 health
                self.health = math.min(3, self.health + 1)
                self.paddle.inc = true

                -- multiply recover points by 2
                self.recoverPoints = self.recoverPoints + math.min(100000, self.recoverPoints * 2)

                -- play recover sound effect
                gSounds['recover']:play()
            end

            -- go to our victory screen if there are no more bricks left
            if self:checkVictory() then
                gSounds['victory']:play()

                gStateMachine:change('victory', {
                    level = self.level,
                    paddle = self.paddle,
                    health = self.health,
                    score = self.score,
                    highScores = self.highScores,
                    balls = self.balls,
                    recoverPoints = self.recoverPoints
                })
            end

            --
            -- collision code for bricks
            --
            -- we check to see if the opposite side of our velocity is outside of the brick;
            -- if it is, we trigger a collision on that side. else we're within the X + width of
            -- the brick and should check to see if the top or bottom edge is outside of the brick,
            -- colliding on the top or bottom accordingly 
            --

            -- left edge; only check if we're moving right, and offset the check by a couple of pixels
            -- so that flush corner hits register as Y flips, not X flips
            if pairs.x + 2 < brick.x and pairs.dx > 0 then
                
                -- flip x velocity and reset position outside of brick
                pairs.dx = -pairs.dx
                pairs.x = brick.x - 8
            
            -- right edge; only check if we're moving left, , and offset the check by a couple of pixels
            -- so that flush corner hits register as Y flips, not X flips
            elseif pairs.x + 6 > brick.x + brick.width and pairs.dx < 0 then
                
                -- flip x velocity and reset position outside of brick
                pairs.dx = -pairs.dx
                pairs.x = brick.x + 32
            
            -- top edge if no X collisions, always check
            elseif pairs.y < brick.y then
                
                -- flip y velocity and reset position outside of brick
                pairs.dy = -pairs.dy
                pairs.y = brick.y - 8
            
            -- bottom edge if no X collisions or top collision, last possibility
            else
                
                -- flip y velocity and reset position outside of brick
                pairs.dy = -pairs.dy
                pairs.y = brick.y + 16
            end

            -- slightly scale the y velocity to speed up the game, capping at +- 150
            if math.abs(pairs.dy) < 150 then
                pairs.dy = pairs.dy * 1.02
            end

            -- only allow colliding with one brick, for corners
            break
        end
        end
    end
    
    -- using the idea that balls are taken off the table , to call defeat upon the player when no balls left:

    if #self.balls < 2 then
        for k, balls in pairs(self.balls) do
            -- if ball goes below bounds, revert to serve state and decrease health
       if balls.y >= VIRTUAL_HEIGHT then
           self.health = self.health - 1
           self.paddle.dec = true
           gSounds['hurt']:play()
   
           if self.health == 0 then
               gStateMachine:change('game-over', {
                   score = self.score,
                   highScores = self.highScores
               })
           else
               gStateMachine:change('serve', {
                   paddle = self.paddle,
                   bricks = self.bricks,
                   health = self.health,
                   score = self.score,
                   highScores = self.highScores,
                   level = self.level,
                   recoverPoints = self.recoverPoints
               })
           end
       end
       end
    end


    -- for rendering particle systems
    for k, brick in pairs(self.bricks) do
        brick:update(dt)
    end

    if love.keyboard.wasPressed('escape') then
        love.event.quit()
    end
end

function PlayState:render()
    
    --MY CODE:
    for i, pairs in pairs(self.Powerups1) do
        pairs:render()
    end 
    
    for l, Key in pairs(self.Keys) do
        Key:render()
    end
    if #self.collectedKey > 0 then
        local x = 10
        local y = 10
        for i = 1,#self.collectedKey do
            love.graphics.draw(gTextures['main'], gFrames['powerups'][10],
            x,y)
            x = x + 18
        end
    end

    
    --ORIGINAL CODE:
    -- render bricks
    for k, brick in pairs(self.bricks) do
        brick:render()
    end

    -- render all particle systems
    for k, brick in pairs(self.bricks) do
        brick:renderParticles()
    end

    self.paddle:render()
    for k, balls in pairs(self.balls) do
        balls:render()
    end

    -- Random print statements used while debugging:

    -- love.graphics.printf('number of balls : '.. tostring(#self.balls),0,30,VIRTUAL_WIDTH,'left')
    -- love.graphics.printf('number of powerups : '.. tostring(#self.Powerups1),0,60,VIRTUAL_WIDTH,'left')
    -- love.graphics.printf('number of eys : '.. tostring(#self.collectedKey),0,60,VIRTUAL_WIDTH,'left')
    --end of prev comment.

    renderScore(self.score)
    renderHealth(self.health)

    -- pause text, if paused
    if self.paused then
        love.graphics.setFont(gFonts['large'])
        love.graphics.printf("PAUSED", 0, VIRTUAL_HEIGHT / 2 - 16, VIRTUAL_WIDTH, 'center')
    end

end

function PlayState:checkVictory()
    for k, brick in pairs(self.bricks) do
        if brick.inPlay then
            return false
        end 
    end

    return true
end