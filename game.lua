game = {}

map = {}
game_menu = {}
active = map
days_per_tic = 1
tic_duration = .1
next_tic = tic_duration

cursor = {
    action = 'none',
    item = {}
}

party = {
    gold = 99100,
    stone = 100,
    iron = 100,
    wood = 100,
    days_left = 99999,
    buildings = {}
}

local item_test = {
    name = 'lol',
    image = 'test',
    size = 3
}

items = {}
local path = {}
local mousemoved = false

function game.enter()
    state = 'game'

    map = Map.load_from_file('assets/maps/map_test.png')

    map.nodes = astar.prepare(map)
    path = astar.find (1, 1, map.width - 10, map.height -10, map.nodes)

    active = map
    next_tic = tic_duration
    game_menu = GameMenu.create()
    love.graphics.setBackgroundColor(0, 0, 0)
    items = love.filesystem.load('game/items.lua')()
        trade.enter()
end

function game.update(dt)
    next_tic = next_tic - dt
    if next_tic < 0 then
        next_tic = next_tic + tic_duration
        game.tic()
        if party.days_left < 0 then
            print('game over!')
            party.days_left = 99999
        end
    end
    if mousemoved then
        local _, x, y = map:get_index(love.mouse.getX(), love.mouse.getY())
        path = astar.find(1, 1, x, y, map.nodes)
    end
    mousemoved = false
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
    map:draw(party.buildings)
    game.draw_entities()

    local lines = {}
    for i, node in ipairs(path) do
        table.insert(lines, map.origin.x + node.x * map.zoom + map.zoom / 2)
        table.insert(lines, map.origin.y + node.y * map.zoom + map.zoom / 2)
    end
    if #lines >= 4 then
        love.graphics.setColor(0, 0, 255)
        love.graphics.line(lines)
    end

    game_menu:draw()
    --mini_map:draw()
    --dialog:draw()
end

function game.draw_entities ()
    if cursor.action ~= 'none' then
        local mouse_x, mouse_y = love.mouse.getPosition()
        map:draw_entity(mouse_x, mouse_y, item_test)
    end
end

function game.keypressed(key)
    if key == 'escape' then
        pause:enter()
    end
end

function game.keyreleased(key)
end

function game.mousepressed (x, y, button, isTouch)
    mousedown = true
    if active then
        if active == game_menu then
            local action_menu = game_menu:mouse_pressed(x, y, button)
            game.update_menu(action_menu)
        elseif active == map then
            local spec = map:mouse_pressed(x, y, button)
        end
    end

    if active == map and cursor.action == 'build' then
        game.build()
    end
end

function game.mousereleased (x, y, button, isTouch)
    mousedown = false
    if active then
        if active == game_menu then
            game_menu:mouse_released(x, y, button)
        end
    end
end

function game.update_menu(action)
    cursor.action = 'none'
    if action == 'none' then
        game_menu:deselect_all()
        map.mode_mask = false
    elseif action == 'aqueduc' then
        game_menu:select_menu('aqueduc')
    elseif action == 'building' then
        game_menu:select_menu('building')
        if game_menu:is_menu_selected('building') then
            map.mode_mask = true
            map:set_allowed_mask(true, false, true, true)
            cursor.action = 'build'
            cursor.item = item_test
        else
            map.mode_mask = false
        end
    elseif action == 'trade' then
        game_menu:select_menu('trade')
        trade.enter()
    elseif action == 'discover' then
        game_menu:select_menu('discover')
    end
end

function game.build()
    local mx, my = love.mouse.getPosition()
    if map:add_entity(mx, my, item_test) then
        party.gold = party.gold - 1000
        if not love.keyboard.isDown('lctrl') then
            cursor.action = 'none'
            game_menu:toggle_menu('building')
            map.mode_mask = false
        end
        local item = {}
        item.name = item_test.name
        item.x = item_test.x
        item.y = item_test.y
        table.insert(party.buildings, item)
    else
    end
end

function game.mousemoved (x, y, dx, dy, isTouch)
    mousemoved = true
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
    if active and active.wheel_moved then
        active:wheel_moved(x, y)
    end
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
