game = {}

map = {}
game_menu = {}
active = map
days_per_tic = 1
next_tic = 1
current_action = 'none'

party = {
    gold = 99999,
    stone = 99999,
    iron = 99999,
    wood = 99999,
    days_left = 10
}

function game.enter()
    state = 'game'
    map = Map.create(30,30,0,0,0)
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
        local gold_spent = math.random(10)
        party.gold = party.gold - gold_spent
        party.wood = party.wood + math.random(90) + 10
        party.iron = party.iron + math.random(90) + 10
        party.stone = party.stone + math.random(90) + 10
        party.days_left = party.days_left - 1
    end
end

function game.draw()
    map:draw()
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
        active = map
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

function game.get_text_icon(icon_name)
    if icon_name == 'days_left' then
        local unit = ' days'
        if party.days_left <= 1 then unit = ' day' end
        return ': ' .. party.days_left .. unit
    elseif party[icon_name] then
        return ': ' .. party[icon_name]
    else
        return ': ???'
    end
end
