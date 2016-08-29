game_over = {
    message = ''
}

function game_over.victory()
    state = 'game_over'
    game_over.message = 'Great!'
end

function game_over.failure(cause)
    state = 'game_over'
    game_over.message = 'Booo!'
end

function game_over.retry()
end

function game_over.next_level()
end

function game_over.update(dt)
end

function game_over.draw()
    game.draw()
    game_over.draw_message()
end

function game_over.draw_message()
    love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle('fill', GAME_W / 2 - 150, GAME_H / 2 - 50, 300, 100)
    love.graphics.setColor(255, 255, 255)
    love.graphics.print(game_over.message, GAME_W / 2 - 10, GAME_H / 2)
end

function game_over.keypressed(key)
    if key == 'escape' then
        love.event.push('quit')
    end
end

function game_over.keyreleased(key)
end

function game_over.mousepressed (x, y, button, isTouch)
end

function game_over.mousereleased (x, y, button, isTouch)
end

function game_over.mousemoved (x, y, dx, dy, isTouch)
end

function game_over.wheelmoved (x, y)
end

function game_over.leave()
end
