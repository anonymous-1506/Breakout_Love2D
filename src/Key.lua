--[[
    GD50
    Breakout Remake

    -- Ball Class --

    Author: J Harishwar Rao

    Represents a powerup.
]]

Key = Class{}

function Key:init()
    -- simple positional and dimensional variables
    self.width = 16
    self.height = 16
    --math.randomseed(os.time())
    self.x = math.random(VIRTUAL_WIDTH)
    self.y = 0
    self.type = 10
    self.death = false

    -- these variables are for keeping track of our velocity on both the
    -- X and Y axis, since the ball can move in two dimensions
    self.dy = 15
    self.dx = 0
    
end

--[[
    Expects an argument with a bounding box, be that a paddle or a brick,
    and returns true if the bounding boxes of this and the argument overlap.
]]
function Key:collides(target)
    -- first, check to see if the left edge of either is farther to the right
    -- than the right edge of the other
    if self.x > target.x + target.width or target.x > self.x + self.width then
        return false
    end

    -- then check to see if the bottom edge of either is higher than the top
    -- edge of the other
    if self.y > target.y + target.height or target.y > self.y + self.height then
        return false
    end 

    -- if the above aren't true, they're overlapping
    return true
end

--[[
    Places the ball in the middle of the screen, with no movement.
]]
-- function Powerup:reset()
--     self.x = VIRTUAL_WIDTH / 2 - 2
--     self.y = VIRTUAL_HEIGHT / 2 - 2
--     self.dx = 0
--     self.dy = 0
-- end

function Key:update(dt)
    
    self.dy = self.dy + dt
    self.y = self.y + self.dy * dt

    -- allow ball to bounce off walls
    -- if self.x <= 0 then
    --     self.x = 0
    --     self.dx = -self.dx
    --     gSounds['wall-hit']:play()
    -- end

    -- if self.x >= VIRTUAL_WIDTH - 8 then
    --     self.x = VIRTUAL_WIDTH - 8
    --     self.dx = -self.dx
    --     gSounds['wall-hit']:play()
    -- end

    -- if self.y <= 0 then
    --     self.y = 0
    --     self.dy = -self.dy
    --     gSounds['wall-hit']:play()
    -- end
end

function Key:render()
    -- gTexture is our global texture for all blocks
    -- gBallFrames is a table of quads mapping to each individual ball skin in the texture
    love.graphics.draw(gTextures['main'], gFrames['powerups'][self.type],
        self.x, self.y)
end