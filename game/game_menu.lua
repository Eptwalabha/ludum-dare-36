GameMenu = {}

GameMenu.__index = GameMenu

local ui_items = {
    top = {
        [1] = {
            name = 'gold'
        },
        [2] = {
            name = 'stone'
        },
        [3] = {
            name = 'iron'
        },
        [4] = {
            name = 'wood'
        },
        [5] = {
            name = 'days_left'
        }
    },
    bottom = {
        [1] = {
            name = 'aqueduc',
            active = true,
            selected = false
        },
        [2] = {
            name = 'building',
            active = true,
            selected = true
        },
        [3] = {
            name = 'trade',
            active = true,
            selected = false
        },
        [4] = {
            name = 'discover',
            active = true,
            selected = false
        }
    }
}

TOP_HEIGHT = 32
BOTTOM_HEIGHT = 84

function GameMenu.create ()
    local game_menu = {}
    setmetatable(game_menu, GameMenu)
    return game_menu
end

function GameMenu:update(dt)
end

function GameMenu:draw()
    self:draw_ui_top()
    self:draw_ui_bottom()
end

function GameMenu:draw_ui_top ()
    love.graphics.setColor(100, 100, 100)
    love.graphics.rectangle('fill', 0, 0, GAME_W, TOP_HEIGHT)
    love.graphics.setColor(200, 200, 200)
    love.graphics.line(0, TOP_HEIGHT, GAME_W, TOP_HEIGHT)
    for i = 1, #ui_items.top, 1 do
        local x = 10 + (i - 1) * 5 + (i - 1) * 85
        self:draw_icon_text_at(x, 0, ui_items.top[i].name)
    end
end

function GameMenu:draw_ui_bottom ()
    local h = GAME_H - BOTTOM_HEIGHT
    love.graphics.setColor(100, 100, 100)
    love.graphics.rectangle('fill', 0, h, GAME_W, GAME_H)
    love.graphics.setColor(200, 200, 200)
    love.graphics.line(0, h, GAME_W, h)
    for i = 1, #ui_items.bottom, 1 do
        love.graphics.setColor(255, 255, 255)
        if ui_items.bottom[i].selected then
            love.graphics.setColor(0, 255, 0)
        end
        if not ui_items.bottom[i].active then
            love.graphics.setColor(50, 50, 50)
        end
        local x = 10 + (i - 1) * 10 + (i - 1) * 64
        love.graphics.draw(assets.textures.menu,
                           assets.images.menu[ui_items.bottom[i].name],
                           x, h + 10, 0, 2, 2)
    end
end

function GameMenu:draw_icon_text_at (x, y, icon_name)
    local text = game.get_text_icon(icon_name)
    love.graphics.draw(assets.textures.icon,
                       assets.images.icon[icon_name], x, y)
    love.graphics.print(text, x + 32, y + 10)
end

function GameMenu:is_mouse_over (x, y)
    return self:is_mouse_over_top_menu(x, y) or
           self:is_mouse_over_bottom_menu(x, y) or
           self:is_mouse_over_sub_menu(x, y)
end

function GameMenu:is_mouse_over_top_menu (x, y)
    return x >= 0 and x <= GAME_W and y >= 0 and y <= TOP_HEIGHT
end

function GameMenu:is_mouse_over_bottom_menu (x, y)
    return x >= 0 and x <= GAME_W and y >= GAME_H - BOTTOM_HEIGHT and y <= GAME_H
end

function GameMenu:is_mouse_over_sub_menu (x, y)
    return false
end

function GameMenu:mouse_moved (x, y, dx, dy)
end

function GameMenu:wheel_moved (x, y)
end

function GameMenu:mouse_released (x, y, button)
    if button == 1 then
        local action = GameMenu.get_action(x, y)
        if action then
            current_action = ui_items.bottom[action].name
        else
            current_action = 'none'
        end
        for i = 1, #ui_items.bottom, 1 do
            ui_items.bottom[i].selected = (i == action)
        end
    end
end

function GameMenu.get_action (x, y)
    if y > GAME_H - BOTTOM_HEIGHT + 10 and y < GAME_H - 10 then
        for i = 1, #ui_items.bottom, 1 do
            if ui_items.bottom[i].active then
                local xm = 10 + (i - 1) * 10 + (i - 1) * 64
                if x >= xm and x < xm + 64 then
                    return i
                end
            end
        end
    end
    return nil
end
