Ball = Class{}

function Ball:init(x, y, width, height)
    
    self.x = x
    self.y = y
    self.width = width
    self.height = height 

    -- random velocity variables for ball
    self.dx = math.random(2) == 1 and 100 or -100
    self.dy = math.random(-50, 50)
    -- the velocity on x asix is fixed to 100 otherwise -100, no other options
    -- since we don't want the ball move too fast towards the players
    -- yet the dy is totally random determining the shooting angle

end

function Ball:collides(paddle)

    -- x asix check 
    if self.x > paddle.x + paddle.width or paddle.x > self.x + self.width then 
        return false
    end

    -- y asix check
    if self.y > paddle.y + paddle.height or paddle.y > self.y + self.height then 
        return false
    end

    return true

end

function Ball:reset()
    self.x = VIRTUAL_WIDTH / 2 - 2
    self.y = VIRTUAL_HEIGHT / 2 - 2
    
    self.dx = math.random(2) == 1 and 100 or -100
    self.dy = math.random(-50, 50)
end

function Ball:update(dt) -- Only about position 
    self.x = self.x + self.dx * dt
    self.y = self.y + self.dy * dt
end

function Ball:render()
    love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
end
