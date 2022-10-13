push = require 'lib/push'
Class = require 'lib/class'

require 'Obj_Ball'
require 'Obj_Paddle'

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720 

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

PADDLE_SPEED = 200

function love.load()

    love.graphics.setDefaultFilter('nearest', 'nearest')

    love.window.setTitle('Pong!')

    math.randomseed(os.time())

    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false, 
        resizable = true, 
        vsync = true
    })

    -- Sound setting
    sounds = {
        ['paddle_hit'] = love.audio.newSource('sounds/paddle_hit.wav', 'static'),
        ['score'] = love.audio.newSource('sounds/score.wav', 'static'),
        ['wall_hit'] = love.audio.newSource('sounds/wall_hit.wav', 'static')
    }

    -- Font setting
    smallFont = love.graphics.newFont('font/font.ttf', 8)
    largeFont = love.graphics.newFont('font/font.ttf', 16)
    scoreFont = love.graphics.newFont('font/font.ttf', 32)

    -- Initialize the Obj : ball & paddle1 & paddle2

    ball = Ball(VIRTUAL_WIDTH / 2 - 2, VIRTUAL_HEIGHT / 2 - 2, 4, 4)

    player1 = Paddle(10, 30, 5, 25)
    player2 = Paddle(VIRTUAL_WIDTH - 10, VIRTUAL_HEIGHT - 30, 5, 25)

    analyze_flag = 1
    -- reset parameter -- 

    -- game statement 
    gameState = 'start'

    -- Score record on two players
    player1Score = 0 
    player2Score = 0

    -- randomize the serve
    serveingPlayer = math.random(2)

end

function love.resize(w, h)
    push:resize(w, h)
end

function love.update(dt)

    -- Ball Movement --
    -- Collision Detection : 'play' - with paddles and upper-lower walls
    -- Winner Detection : 'play' - with right and left walls
    -- Serveing Player : 'serve' - the ball will move towards the newest loser
    
    -- Any other time, the ball's state will not alter

    if gameState == 'play' then 

        -- Collistion Detection --

        if ball:collides(player1) then  -- paddle on leftside

            -- set the ball next to the paddle 1 and reverse the movement on x asix
            ball.x = player1.x + player1.width
            ball.dx = -ball.dx * 1.03

            -- keep velocity going in the same direction, yet randomize it
            if ball.dy < 0 then 
                ball.dy = - math.random(10, 150)
            else
                ball.dy = math.random(10, 150)
            end
            
            sounds['paddle_hit']:play()

        end

        if ball:collides(player2) then    -- paddle on rightside

            -- set the ball next to the paddle 2 and reverse the movement on x asix
            ball.x = player2.x - ball.width
            ball.dx = -ball.dx * 1.03

            -- keep velocity going in the same direction, yet randomize it
            if ball.dy < 0 then
                ball.dy = - math.random(10, 150)
            else
                ball.dy = math.random(10, 150)
            end

            sounds['paddle_hit']:play()

        end

        if ball.y <= 0 then -- upper boundary
            ball.y = 0 
            ball.dy = - ball.dy
            sounds['wall_hit']:play()
        end

        if ball.y >= VIRTUAL_HEIGHT - ball.height then -- lower boundary
            ball.y = VIRTUAL_HEIGHT - ball.height
            ball.dy = - ball.dy
            sounds['wall_hit']:play()
        end   

        -- Winner Detection --

        if ball.x <= 0 then 
            serveingPlayer = 1
            player2Score = player2Score + 1
            sounds['score']:play()

            if player2Score == 5 then 
                winningPlayer = 2
                gameState = 'done'
            else
                ball:reset()
                gameState = 'serve'
            end 

        elseif ball.x >= VIRTUAL_WIDTH - ball.width then 
            serveingPlayer = 2
            player1Score = player1Score + 1
            sounds['score']:play()

            if player1Score == 5 then 
                winningPlayer = 1
                gameState = 'done'
            else
                ball:reset()
                gameState = 'serve'
            end

        end

    -- Serving Player --

    elseif gameState == 'serve' then 
        ball.dy = math.random(-50, 50)
        if serveingPlayer == 1 then
            ball.dx = 100 
        else
            ball.dx = -100
        end
    end

    if gameState == 'play' then    
        ball:update(dt)
    end
    
    -- Paddle Movement : 'start' & 'play' & 'serve'
    
    if gameState ~= 'pause' then 

        -- player 1 movement : by control it speed on y asix
        if love.keyboard.isDown('w') then
            player1:updateSpeed(-PADDLE_SPEED)
        elseif love.keyboard.isDown('s') then 
            player1:updateSpeed(PADDLE_SPEED)
        else 
            player1:updateSpeed(0) -- paddle 1 : stay put
        end

        -- player 2 movement : by control it speed on y asix
        if love.keyboard.isDown('up') then 
            player2:updateSpeed(-PADDLE_SPEED)
        elseif love.keyboard.isDown('down') then 
            player2:updateSpeed(PADDLE_SPEED)
        else
            player2:updateSpeed(0) -- paddle 2 : stay put
        end

        player1:update(dt)
        player2:update(dt)

    end

end

function love.draw()

    push:apply('start')     -- start

    -- clear the screen with a specific color, draw background 
    love.graphics.clear(40/255, 45/255, 52/255, 255/255)

    displayScore()

    -- declear the current statement 
    love.graphics.setFont(smallFont)
    if gameState == 'start' then 
        love.graphics.printf('Welcom to Pong!', 0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('Press Enter to begin!', 0, 20, VIRTUAL_WIDTH, 'center')
    elseif gameState == 'serve' then 
        love.graphics.printf('Player ' .. tostring(serveingPlayer) .. ',s serve!', 0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('Press Enter to serve!', 0, 20, VIRTUAL_WIDTH, 'center')
    elseif gameState == 'play' then
        -- no message for playing
    elseif gameState == 'pause' then 
        love.graphics.printf('Pause!', 0, 20, VIRTUAL_WIDTH, 'center')
    elseif gameState == 'done' then
        love.graphics.setFont(largeFont)
        love.graphics.printf('Player ' .. tostring(winningPlayer) .. ' wins!', 0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.setFont(smallFont)
        love.graphics.printf('Press Enter to restart!', 0, 30, VIRTUAL_WIDTH, 'center')
    end

    -- render paddel for player 1 (left side)
    player1:render()
    -- render paddel for player 2 (right side)
    player2:render()
    -- render ball (center)
    ball:render()

    if analyze_flag == 1 then
        displayFPS()
        displayBallState()
    end

    push:apply('end')       -- end

end

function displayFPS()
    love.graphics.setFont(smallFont)
    love.graphics.setColor(0, 255, 0, 255)
    love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), 10, 10)
end

function displayBallState()
    love.graphics.setFont(smallFont)
    love.graphics.print('Ball dx: ' .. tostring(ball.dx), VIRTUAL_WIDTH-60, 10)
    love.graphics.print('Ball dy: ' .. tostring(ball.dy), VIRTUAL_WIDTH-60, 20)
end

function displayScore()
    love.graphics.setFont(scoreFont)
    love.graphics.print(tostring(player1Score), VIRTUAL_WIDTH / 2 - 50, VIRTUAL_HEIGHT / 3)
    love.graphics.print(tostring(player2Score), VIRTUAL_WIDTH / 2 + 30, VIRTUAL_HEIGHT / 3)
end

-- control on the game state

-- State 1 : ( init or reset the game playing ) start -> play 
-- State 2 : ( the game playing is officially on ) play  -> start & pause
-- State 3 : ( the game is temporarily frozen ) pause -> play & start
-- State 4 : serve
-- State 5 : done

function love.keypressed(key)

    if key == 'escape' then  -- exist ongoing game
        love.event.quit()

    elseif key == 'enter' or key == 'return' then -- forward the game & reset the game
        if gameState == 'start' then 
            gameState = 'serve'
        elseif gameState == 'serve' then
            gameState = 'play'
        elseif gameState == 'pause' then
            gameState = 'serve'
            ball:reset()
            serveingPlayer = math.random(2)
            player1Score, player2Score = 0, 0
        elseif gameState == 'done' then
            gameState = 'serve'
            ball:reset()
            serveingPlayer = math.random(2)
            player1Score, player2Score = 0, 0
        end

    elseif key == 'space' then      -- pause the game : only happen when the game is on
        if gameState == 'play' then
            gameState = 'pause'
        elseif gameState == 'pause' then
            gameState = 'play'
        end

    elseif key == 'tab' then
        analyze_flag = analyze_flag == 1 and 0 or 1
    end
    
end

