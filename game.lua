game = {}

map = {}
game_menu = {}
active = map
days_per_tic = 1
tic_duration = .2
next_tic = tic_duration

trade_open = false

cursor = {
    action = 'none',
    item = {}
}

party = {
    infinity = true,
    gold = 99100,
    stone = 100,
    iron = 100,
    wood = 100,
    days_left = 99999,
    buildings = {},
    aqueduc = {}
}

local item_test = {
    name = 'lol',
    image = 'test',
    size = 3
}

items = {}
local path = {}

local mouse = {
    down = false,
    released = false,
    moved = false,
    drag = false,
    origin = {
        x = 0,
        y = 0
    }
}

function game.enter()
    state = 'game'

    local file = 'assets/maps/map_test.png'
    game.reset_party(file)

    game_menu = GameMenu.create()
    love.graphics.setBackgroundColor(0, 0, 0)
end

function game.reset_party(file)
    map = Map.load_from_file(file)
    party.infinity = false
    party.aqueduc = Aqueduc.load_from_file(file)
    map.nodes = astar.prepare(map)
    path = astar.find (1, 1, map.width - 10, map.height -10, map.nodes)

    party.gold = 999
    party.stone = 999
    party.iron = 999
    party.wood = 999
    party.days_left = 1000
    party.buildings = {}
    next_tic = tic_duration
    active = map
    items = love.filesystem.load('game/items.lua')()
end

function game.update(dt)
    next_tic = next_tic - dt
    if next_tic < 0 then
        next_tic = next_tic + tic_duration
        game.tic()
        if party.days_left < 0 then
            game_over:failure('timeout')
        end
    end
end

function game.tic()
    if party.aqueduc:tic() then
        game_over:victory()
    end

    local iron, stone, wood = 0, 0, 0
    for _, building in pairs(party.buildings) do
        if building.delay > 0 then
            building.delay = building.delay - 1
        end
        if building.radius ~= nil and building.capacity and building.delay == 0 then
            map:fetch_ressouces(building)
            iron = iron + building.fetch.iron
            stone = stone + building.fetch.stone
            wood = wood + building.fetch.wood
        end
    end

    party.iron = party.iron + iron
    party.stone = party.stone + stone
    party.wood = party.wood + wood

    if not party.infinity then party.days_left = party.days_left - 1 end
    trade.tic()
end

function game.draw()
    map:draw(party.buildings)
    game.draw_entities()

    party.aqueduc:draw(map.origin.x, map.origin.y, map.zoom)
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
    if cursor.action == 'build' then
        local mouse_x, mouse_y = love.mouse.getPosition()
        map:draw_entity(mouse_x, mouse_y, item_test)
    end
end

function game.keypressed(key)
    if key == 'escape' then
        if cursor.action == 'none' then
            pause:enter()
            love.event.push('quit')
        else
            cursor.action = 'none'
            map.mode_mask = false
            game_menu:deselect_all()
        end
    end
end

function game.keyreleased(key)
end

function game.mousepressed (x, y, button, isTouch)
    mouse.down = true
    mouse.origin.x = x
    mouse.origin.y = y

    if active then
        if active == game_menu then
            local action_menu = game_menu:mouse_pressed(x, y, button)
            game.update_menu(action_menu)
        elseif active == map then
            if cursor.action == 'build_aqueduc' then
                local index, _, _ = map:get_index(x, y)
                cursor.action = 'building_aqueduc'
                cursor.start = map.data[index]
            elseif cursor.action == 'build' then
                game.build(x, y)
            end
        end
    end
end

function game.mousereleased (x, y, button, isTouch)
    mouse.drag = false
    mouse.down = false

    if cursor.action == 'building_aqueduc' then
        cursor.action = 'build_aqueduc'
        if not love.keyboard.isDown('lctrl') then
            cursor.action = 'none'
            map.mode_mask = false
            game_menu:select_menu('aqueduc', false)
        end
        if #path > 0 then
            game.build_aqueduc(path)
        end
    end
end

function game.update_menu(action)
    local x, y = love.mouse.getPosition()
    cursor.action = 'none'
    if action == 'none' then
        game_menu:deselect_all()
        map.mode_mask = false
    elseif action == 'aqueduc' then
        game_menu:select_menu('aqueduc')
        if game_menu:is_menu_selected('aqueduc') then
            cursor.action = 'build_aqueduc'
            map.mode_mask = true
            map:set_forbiden_mask(true, true, true, true)
        else
            cursor.action = 'none'
            map.mode_mask = false
        end
    elseif action == 'building' then
        game_menu:select_menu('building')
        if game_menu:is_menu_selected('building') then
            map.mode_mask = true
            map:set_forbiden_mask(true, false, true, true)
            cursor.action = 'build'
            cursor.item = item_test
        else
            map.mode_mask = false
        end
    elseif action == 'trade' then
        game_menu:select_menu('trade')
        trade_open = true
        trade.enter()
    elseif action == 'discover' then
        game_menu:select_menu('discover')
    end
end

function game.build_aqueduc(path)
    for i, node in ipairs(path) do
        local inserted = party.aqueduc:insert_node_at(node.x, node.y)
        if not inserted then
            break
        end
    end
end

function game.build(mx, my)
    if map:add_entity(mx, my, item_test) then
        party.gold = party.gold - 1000
        if not love.keyboard.isDown('lctrl') then
            cursor.action = 'none'
            game_menu:toggle_menu('building')
            map.mode_mask = false
        end
        local item = {}
        item.delay = 5
        item.image = 'test'
        item.name = item_test.name
        item.x = item_test.x
        item.y = item_test.y
        item.radius = 3
        item.capacity = {
            iron = 10,
            stone = 0,
            wood = 100
        }
        table.insert(party.buildings, item)
    else
    end
end

function game.mousemoved (x, y, dx, dy, isTouch)
    mouse.moved = true
    if mouse.down then
        mouse.drag = true
        if active == map then
            map:set_active_tile(x, y)
            if cursor.action == 'building_aqueduc' then
                local _, x1, y1 = map:get_index(mouse.origin.x, mouse.origin.y)
                local _, x2, y2 = map:get_index(x, y)
                path = astar.find(x1, y1, x2, y2, map.nodes, true)
            elseif cursor.action == 'none' then
                map:move_origin(dx, dy)
            end
        elseif active and active.mouse_moved then
            active:mouse_moved(x, y, dx, dy)
        end
    else
        active = map
        if game_menu:is_mouse_over(x, y) then
            active = game_menu
        end
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
        if party.infinity then
            return ': --'
        else
            local unit = ' days'
            if party.days_left <= 1 then unit = ' day' end
            return ': ' .. party.days_left .. unit
        end
    elseif party[icon_name] then
        return ': ' .. party[icon_name]
    else
        return ': ???'
    end
end
