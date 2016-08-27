game = {}

terrain = {}
game_menu = {}
active = terrain
days_per_tic = 1
next_tic = 1
current_action = 'none'

party = {
    gold = 0,
    stone = 0,
    iron = 0,
    wood = 0,
    day_left = 600
}

function game.enter()
    state = 'game'
    terrain = Terrain.create(30,30,0,0,0)
    next_tic = 1
    game_menu = GameMenu.create()
    love.graphics.setBackgroundColor(0, 0, 0)
end

function game.update(dt)
    next_tic = next_tic - dt
    if next_tic < 0 then
        next_tic = next_tic + 1
        game.tic()
    end
end

function game.tic()
    local nbr = days_per_tic
    for day = 1, nbr, 1 do

    end
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
    if active and active.mouse_pressed then
        active:mouse_pressed(x, y, button)
    end
end

function game.mousereleased (x, y, button, isTouch)
    mousedown = false
    if active and active.mouse_released then
        active:mouse_released(x, y, button)
    end
end

function game.mousemoved (x, y, dx, dy, isTouch)
    if not mousedown then
        active = terrain
        if game_menu:is_mouse_over(x, y) then
            active = game_menu
        end
    end
    if active and active.mouse_moved then
        active:mouse_moved(x, y, dx, dy)
    end
end

function game.wheelmoved (x, y)
    active:wheel_moved(x, y)
end

function game.leave()
end
