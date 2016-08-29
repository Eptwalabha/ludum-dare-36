trade = {}

local trading = {
    sell = {
        stone = {
            amount = 0,
            quotation = 10,
            price = 0
        },
        iron = {
            amount = 0,
            quotation = 10,
            price = 0
        },
        wood = {
            amount = 0,
            quotation = 10,
            price = 0
        }
    },
    buy = {
        stone = {
            amount = 0,
            quotation = 20,
            price = 0
        },
        iron = {
            amount = 0,
            quotation = 20,
            price = 0
        },
        wood = {
            amount =0,
            quotation = 20,
            price = 0
        }
    }
}

local repeat_delay = 0

function trade.enter()
    state = 'trade'
end

function trade.update(dt)
    trade.update_prices()
    repeat_delay = repeat_delay - dt
    if love.mouse.isDown(1) and repeat_delay <= 0 then
        trade.check_sliders()
    end
end

function trade.draw()
    game.draw()
    love.graphics.setColor(0, 0, 0, 150)
    love.graphics.rectangle('fill', 0, TOP_HEIGHT, GAME_W, GAME_H - BOTTOM_HEIGHT - TOP_HEIGHT)
    love.graphics.setColor(100, 100, 100)
    love.graphics.rectangle('fill', 100, TOP_HEIGHT + 50, GAME_W - 200, GAME_H - BOTTOM_HEIGHT - TOP_HEIGHT - 100)
    love.graphics.setColor(50, 50, 50)
    love.graphics.line(GAME_W / 2, GAME_H / 2 - 150, GAME_W / 2, GAME_H / 2 + 80)
    trade.draw_quotations(GAME_W / 2, GAME_H / 2 - 100)
    trade.draw_sliders(GAME_W / 2, GAME_H / 2 - 20)
    trade.draw_summary(GAME_W / 2, GAME_H / 2 + 100)
end

function trade.draw_summary(x, y)
    local iron, stone, wood, gold = trade.compute_transaction()
    trade.draw_icon(x - 200, y, 'iron', iron)
    trade.draw_icon(x - 100, y, 'stone', stone)
    trade.draw_icon(x, y, 'wood', wood)
    trade.draw_icon(x + 100, y, 'gold', gold)
end

function trade.draw_quotations()
end

function trade.draw_icon(x, y, icon, value)
    love.graphics.setColor(255, 255, 255)
    love.graphics.draw(assets.textures.icon, assets.images.icon[icon],
                       x, y - 16)
    local price = value
    if price > 0 then
        love.graphics.setColor(0, 255, 0)
        price = '+' .. price
    elseif price < 0 then
        love.graphics.setColor(255, 0, 0)
    end
    love.graphics.print(price, x + 40, y - 7)

end

function trade.draw_sliders(x, y)
    local buy = trading.buy
    local sell = trading.sell
    trade.draw_slider(x - 290, y, 'stone', buy.stone, -1)
    trade.draw_slider(x - 290, y + 30, 'iron', buy.iron, -1)
    trade.draw_slider(x - 290, y + 60, 'wood', buy.wood, -1)
    trade.draw_slider(x + 10, y, 'stone', sell.stone, 1)
    trade.draw_slider(x + 10, y + 30, 'iron', sell.iron, 1)
    trade.draw_slider(x + 10, y + 60, 'wood', sell.wood, 1)
end

function trade.update_prices()
    local sell = trading.sell
    local buy = trading.buy
    sell.wood.price = sell.wood.amount * sell.wood.quotation / 10
    sell.iron.price = sell.iron.amount * sell.iron.quotation / 10
    sell.stone.price = sell.stone.amount * sell.stone.quotation / 10
    buy.wood.price = buy.wood.amount * buy.wood.quotation / 10
    buy.iron.price = buy.iron.amount * buy.iron.quotation / 10
    buy.stone.price = buy.stone.amount * buy.stone.quotation / 10
end

function trade.keypressed(key)
    if key == 'escape' then
        state = 'game'
        game_menu:select_menu('trade')
        love.event.push('quit')
    end
end

function trade.draw_slider(x, y, icon, item, sign)
    love.graphics.setColor(255, 255, 255)
    love.graphics.draw(assets.textures.icon, assets.images.icon[icon],
                       x, y - 16)
    love.graphics.draw(assets.textures.icon, assets.images.icon.minus,
                       x + 50, y - 16)
    love.graphics.print(item.amount, x + 90, y - 7)
    love.graphics.draw(assets.textures.icon, assets.images.icon.plus,
                       x + 140, y - 16)
    love.graphics.print('=', x + 180, y - 7)
    love.graphics.draw(assets.textures.icon, assets.images.icon.gold,
                       x + 195, y - 16)

    local price = item.price
    if price ~= 0 then
        price = price * sign
    end
    if price < 0 then
        love.graphics.setColor(255, 0, 0)
    elseif price > 0 then
        love.graphics.setColor(0, 255, 0)
        price = '+' .. price
    else
        love.graphics.setColor(255, 255, 255)
    end
    love.graphics.print(price, x + 225, y - 7)
end

function trade.keyreleased(key)

end

function trade.mousepressed (x, y, button, isTouch)
    repeat_delay = 0.4
    trade.check_sliders()
end

function trade.mousereleased (x, y, button, isTouch)
    repeat_delay = 0
    if x < 100 or x > GAME_W - 100 or
       y < TOP_HEIGHT + 50 or y > GAME_H - 100 then
        state = 'game'
        game_menu:select_menu('trade')
    end
end

function trade.mousemoved (x, y, dx, dy, isTouch)
end

function trade.wheelmoved (x, y)
end

function trade.leave()
end

function trade.trade()
    local iron, stone, wood, gold = trade.compute_transaction()
    party.iron = party.iron + iron
    party.stone = party.stone + stone
    party.wood = party.wood + wood
    party.gold = party.gold + gold
end

function trade.compute_transaction()
    local buy = trading.buy
    local sell = trading.sell
    local iron = buy.iron.amount - sell.iron.amount
    local stone = buy.stone.amount - sell.stone.amount
    local wood = buy.wood.amount - sell.wood.amount
    local gold = buy.stone.amount * -1 * buy.stone.quotation / 10
    gold = gold + buy.iron.amount * -1 * buy.iron.quotation / 10
    gold = gold + buy.wood.amount * -1 * buy.wood.quotation / 10
    gold = gold + sell.stone.amount * sell.stone.quotation / 10
    gold = gold + sell.iron.amount * sell.iron.quotation / 10
    gold = gold + sell.wood.amount * sell.wood.quotation / 10

    return iron, stone, wood, gold
end

function trade.check_sliders()
    local x, y = love.mouse.getPosition()
    repeat_delay = repeat_delay + 0.1
    local xb = GAME_W / 2 - 290 + 50
    local yb = GAME_H / 2 - 20 - 16

    if x >= xb and x < xb + 32 and y >= yb and y < yb + 32 then
        trading.buy.stone.amount = trading.buy.stone.amount - 10
        if trading.buy.stone.amount < 0 then
            trading.buy.stone.amount = 0
        end
    end
    if x >= xb and x < xb + 32 and y >= yb + 30 and y < yb + 62 then
        trading.buy.iron.amount = trading.buy.iron.amount - 10
        if trading.buy.iron.amount < 0 then
            trading.buy.iron.amount = 0
        end
    end
    if x >= xb and x < xb + 32 and y >= yb + 60 and y < yb + 92 then
        trading.buy.wood.amount = trading.buy.wood.amount - 10
        if trading.buy.wood.amount < 0 then
            trading.buy.wood.amount = 0
        end
    end
    if x >= xb + 90 and x < xb + 122 and y >= yb and y < yb + 32 then
        trading.buy.stone.amount = trading.buy.stone.amount + 10
        local _, _, _, gold = trade.compute_transaction()
        if party.gold + gold < 0 then
            trading.buy.stone.amount = trading.buy.stone.amount - 10
        end
    end
    if x >= xb + 90 and x < xb + 122 and y >= yb + 30 and y < yb + 62 then
        trading.buy.iron.amount = trading.buy.iron.amount + 10
        local _, _, _, gold = trade.compute_transaction()
        if party.gold + gold < 0 then
            trading.buy.iron.amount = trading.buy.iron.amount - 10
        end
    end
    if x >= xb + 90 and x < xb + 122 and y >= yb + 60 and y < yb + 92 then
        trading.buy.wood.amount = trading.buy.wood.amount + 10
        local _, _, _, gold = trade.compute_transaction()
        if party.gold + gold < 0 then
            trading.buy.wood.amount = trading.buy.wood.amount - 10
        end
    end

    xb = GAME_W / 2 + 10 + 50

    if x >= xb and x < xb + 32 and y >= yb and y < yb + 32 then
        trading.sell.stone.amount = trading.sell.stone.amount - 10
        if trading.sell.stone.amount < 0 then
            trading.sell.stone.amount = 0
        end
    end
    if x >= xb and x < xb + 32 and y >= yb + 30 and y < yb + 62 then
        trading.sell.iron.amount = trading.sell.iron.amount - 10
        if trading.sell.iron.amount < 0 then
            trading.sell.iron.amount = 0
        end
    end
    if x >= xb and x < xb + 32 and y >= yb + 60 and y < yb + 92 then
        trading.sell.wood.amount = trading.sell.wood.amount - 10
        if trading.sell.wood.amount < 0 then
            trading.sell.wood.amount = 0
        end
    end
    if x >= xb + 90 and x < xb + 122 and y >= yb and y < yb + 32 then
        trading.sell.stone.amount = trading.sell.stone.amount + 10
        if party.stone - trading.sell.stone.amount < 0 then
            trading.sell.stone.amount = trading.sell.stone.amount - 10
        end
    end
    if x >= xb + 90 and x < xb + 122 and y >= yb + 30 and y < yb + 62 then
        trading.sell.iron.amount = trading.sell.iron.amount + 10
        if party.iron - trading.sell.iron.amount < 0 then
            trading.sell.iron.amount = trading.sell.iron.amount - 10
        end
    end
    if x >= xb + 90 and x < xb + 122 and y >= yb + 60 and y < yb + 92 then
        trading.sell.wood.amount = trading.sell.wood.amount + 10
        if party.wood - trading.sell.wood.amount < 0 then
            trading.sell.wood.amount = trading.sell.wood.amount - 10
        end
    end
end
