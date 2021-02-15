-- PING PONG --

push = require 'push'

Class = require 'class'

require 'Paddle'
require 'Ball'

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

PADDLE_SPEED = 200

winningScore = 10

-- Required Sounds

hitSound = love.audio.newSource("Powerup.wav", "static")
pwnSound = love.audio.newSource("LaserShoot.wav", "static")
winSound = love.audio.newSource("Win.mp3", "stream")

-- LOAD(): Runs only once at game start. In it we will load the game resources, such as images, sounds or animations. 

function love.load()

    love.graphics.setDefaultFilter('nearest', 'nearest')
    smallFont = love.graphics.newFont('Neon.ttf', 15)
    scoreFont = love.graphics.newFont('Neon.ttf', 32)

    math.randomseed(os.time())

    love.graphics.setFont(smallFont)
    background = love.graphics.newImage("RedPong.png")
    background2 = love.graphics.newImage("RedPong2.png")

    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false, 
        resizable = false, 
        vsync = true})   


    player1 = Paddle(10, VIRTUAL_HEIGHT/2, 5, 20)    
    player2 = Paddle(VIRTUAL_WIDTH-10, VIRTUAL_HEIGHT/2, 5, 20)

    ball = Ball(VIRTUAL_WIDTH/2-2, VIRTUAL_HEIGHT/2-2, 4, 4)

    player1Score = 0
    player2Score = 0

    servingPlayer = 1

    gameState = 'start';
end


-- UPDATE(): It contains the logic of the game. It runs constantly in a loop and updates the information by performing the necessary calculations.
-- In it, all the processes are calculated, such as the positions of the elements of the game, the movement of objects, actions or events.


function love.update(dt)

    if gameState == 'serve' then
        if servingPlayer == 1 then
            ball.dx = math.random(-140, 200)
        else
            ball.dx = -math.random(-140, 200)
        end
        ball.dy = math.random(-50, 50)


    elseif gameState == 'play' then
        if ball.y <= 0 then
            ball.y = 0
            ball.dy = -ball.dy
        end

        if ball.y >= VIRTUAL_HEIGHT - 4 then
            ball.y = VIRTUAL_HEIGHT - 4
            ball.dy = -ball.dy
        end


        if ball:collides(player1) then
            ball.dx = -ball.dx * 3
            ball.x = player1.x + 5
            love.audio.play(hitSound)

            if ball.dy < 0 then
                ball.dy = -math.random(10, 150)
                love.audio.play(hitSound)
            else
                ball.dy = math.random(10, 150)
                love.audio.play(hitSound)    
            end
        end

        if ball:collides(player2) then
            ball.dx = -ball.dx * 1.04
            ball.x = player2.x - 4
            love.audio.play(hitSound)

            if ball.dy < 0 then
                ball.dy = -math.random(10, 150)
                love.audio.play(hitSound)
            else
                ball.dy = math.random(10, 150)
                love.audio.play(hitSound)    
            end
        end
    end


    if ball.x < 0 then -- SERVE
        player2Score = player2Score + 1
        love.audio.play(pwnSound)
        servingPlayer = 1
        ball:reset()
        if player2Score == winningScore then
            winningPlayer = 2
            gameState = 'victory'
        else
            
            gameState = 'serve'
        end
    end

    if ball.x > VIRTUAL_WIDTH then   
        player1Score = player1Score + 1
        love.audio.play(pwnSound)
        servingPlayer = 2
        ball:reset()
        
        if player1Score == winningScore then
            winningPlayer = 1
            gameState = 'victory'
        else
            
            gameState = 'serve'
        end
    end



    if love.keyboard.isDown('w') then
        player1.dy = -PADDLE_SPEED
    elseif love.keyboard.isDown('s') then
        player1.dy = PADDLE_SPEED
    else
        player1.dy = 0
    end

    if love.keyboard.isDown('up') then
        player2.dy = -PADDLE_SPEED
    elseif love.keyboard.isDown('down') then
        player2.dy = PADDLE_SPEED
    else
        player2.dy = 0
    end

    if gameState == 'play' then
        ball:update(dt)
    end

    player1:update(dt)
    player2:update(dt)

end


function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    elseif key == 'enter' or key == 'return' then
        if gameState == 'start' then
            gameState = 'serve'  
        elseif gameState == 'serve' then
            gameState = 'play'
        elseif gameState == 'victory' then
            gameState = 'serve'
            ball:reset()
            player1Score = 0
            player2Score = 0

            if winninPlayer == 1 then
                savingPlayer = 2
            else
                servingPlayer = 1
            end
        else
            gameState = 'start'
            ball:reset()
        end
    end 
end


--DRAW(): It is responsible for displaying on the screen, with this function we show the objects, without it we would not see anything.
-- It is always executed after update (). 

function love.draw()
    push:apply("start")
    
    love.graphics.draw(background, 0, 0)

    love.graphics.setFont(smallFont)

    if gameState == 'start' then
        love.audio.stop()
         love.graphics.setColor( 255, 0, 0)
        love.graphics.printf('Press to enter to pwn the pong', 0, 20, VIRTUAL_WIDTH + 18, 'center')
    elseif gameState == 'serve' then
        love.audio.stop()
        love.graphics.setColor( 255, 0, 0)
        love.graphics.printf("Player ".. tostring(servingPlayer).."'s serve", 0, 10, VIRTUAL_WIDTH + 18, 'center')
        love.graphics.printf('Press enter to serve', 0, 20, VIRTUAL_WIDTH + 18, 'center')
    --elseif gamestate == 'play' then
    elseif gameState == 'victory' then
        love.audio.play(winSound)
        love.graphics.setColor( 255, 0, 0)
        love.graphics.printf("Player ".. tostring(servingPlayer).."'s has been PWNED!", 0, 10, VIRTUAL_WIDTH + 18, 'center')
        love.graphics.printf('Press enter to restart', 0, 20, VIRTUAL_WIDTH + 18, 'center')
    end
        

    love.graphics.setFont(scoreFont)
    love.graphics.draw(background2, 0, 0)
    love.graphics.setColor( 255, 0, 0)
    love.graphics.print(tostring(player1Score), VIRTUAL_WIDTH / 2 - 35, VIRTUAL_HEIGHT / 4)
    love.graphics.print(tostring(player2Score), VIRTUAL_WIDTH / 2 + 25, VIRTUAL_HEIGHT / 4)

    player1:render()
    player2:render()
    ball:render()
    push:apply("end")

end

