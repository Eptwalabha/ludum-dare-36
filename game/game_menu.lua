GameMenu = {
}

GameMenu.__index = GameMenu

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

    local h = GAME_H - BOTTOM_HEIGHT
    love.graphics.setColor(100, 100, 100)
    love.graphics.rectangle('fill', 0, 0, GAME_W, TOP_HEIGHT)
    love.graphics.rectangle('fill', 0, h, GAME_W, GAME_H)
    love.graphics.setColor(200, 200, 200)
    love.graphics.line(0, TOP_HEIGHT, GAME_W, TOP_HEIGHT)
    love.graphics.line(0, h, GAME_W, h)
    love.graphics.setColor(255, 255, 255)
    love.graphics.draw(assets.textures.menu,
                       assets.images.menu.aqueduc, 10, h + 10, 0, 2, 2)
    love.graphics.draw(assets.textures.menu,
                       assets.images.menu.building, 84, h + 10, 0, 2, 2)
    love.graphics.draw(assets.textures.menu,
                       assets.images.menu.trade, 158, h + 10, 0, 2, 2)
    love.graphics.draw(assets.textures.menu,
                       assets.images.menu.discover, 168 + 64, h + 10, 0, 2, 2)
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


