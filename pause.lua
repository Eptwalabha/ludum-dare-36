pause = {}

function pause.enter()
    state = 'pause'
end

function pause.update(dt)
end

function pause.draw()
    game.draw()
    love.graphics.setColor(0, 0, 0, 150)
    love.graphics.rectangle('fill', 0, TOP_HEIGHT, GAME_W, GAME_H - BOTTOM_HEIGHT - TOP_HEIGHT)
    love.graphics.setColor(255, 255, 255)
    love.graphics.print("lol", GAME_W / 2, GAME_H / 2 - 10)
end

function pause.keypressed(key)
    if key == 'escape' then
        state = 'game'
    end
end

function pause.keyreleased(key)

end

function pause.mousepressed (x, y, button, isTouch)
end

function pause.mousereleased (x, y, button, isTouch)
end

function pause.mousemoved (x, y, dx, dy, isTouch)
end

function pause.wheelmoved (x, y)
end

function pause.leave()
end
