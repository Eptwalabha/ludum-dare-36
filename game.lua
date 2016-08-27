game = {}

terrain = {}
game_menu = {}
active = terrain

function game.enter()
    state = 'game'
    terrain = Terrain.create(30,30,0,0,0)
    game_menu = GameMenu.create()
    love.graphics.setBackgroundColor(0, 0, 0)
end

function game.update(dt)
end

function game.draw()
    terrain:draw()
    game_menu:draw()
    --mini_map:draw()
    --dialog:draw()
end

function game.keypressed(key)
    if key == 'escape' then
        love.event.push('quit')
    end
end

function game.keyreleased(key)

end

function game.mousepressed (x, y, button, isTouch)
    mousedown = true
end

function game.mousereleased (x, y, button, isTouch)
    mousedown = false
end

function game.mousemoved (x, y, dx, dy, isTouch)

    if not mousedown then
        active = terrain
        if game_menu:is_mouse_over(x, y) then
            active = game_menu
        end
    end
    active:mouse_moved(x, y, dx, dy)
end

function game.wheelmoved (x, y)
    active:wheel_moved(x, y)
end

function game.leave()
end
