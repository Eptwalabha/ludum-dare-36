require 'game'
require 'pause'
require 'trade'
require 'game_over'

require 'game/map'
require 'game/game_menu'
require 'game/aqueduc'

require 'lib/astar'
-- require 'lib/util'

game_states = {
    ['game'] = game,
    ['game_over'] = game_over,
    ['pause'] = pause,
    ['trade'] = trade
}

GAME_W = love.graphics.getWidth()
GAME_H = love.graphics.getHeight()

state = 'splash_screen'
assets = {
    textures = {
    },
    images = {
        menu = {},
        icon = {},
        building = {}
    },
    musics = {
    },
    sounds = {
    }
}

function love.load()
    state = 'splash_screen'

    load_assets()

    game.enter()
end

function love.update(dt)
    game_states[state].update(dt)
end

function love.draw()
    game_states[state].draw()
end

function love.quit()
    game_states[state].leave()
    print("thanks for thaying!")
end

function love.keypressed(key)
    game_states[state].keypressed(key)
end

function love.keyreleased(key)
    game_states[state].keyreleased(key)
end

function love.mousepressed (x, y, button, isTouch)
    if game_states[state].mousepressed then
        game_states[state].mousepressed(x, y, button, isTouch)
    end
end

function love.mousereleased (x, y, button, isTouch)
    if game_states[state].mousereleased then
        game_states[state].mousereleased(x, y, button, isTouch)
    end
end

function love.mousemoved (x, y, dx, dy, isTouch)
    if game_states[state].mousemoved then
        game_states[state].mousemoved(x, y, dx, dy, isTouch)
    end
end

function love.wheelmoved (x, y)
    if state == 'game' then
        game_states['game'].wheelmoved(x, y)
    end
end

function love.resize (w, h)
    GAME_W = w
    GAME_H = h
end

function load_assets()

    load_images()
end

function load_images()
    assets.textures.menu = love.graphics.newImage('assets/menus.png')
    local w0, h0 = assets.textures.menu:getDimensions()
    assets.textures.icon = love.graphics.newImage('assets/icons.png')
    local w1, h1 = assets.textures.icon:getDimensions()
    assets.textures.building = love.graphics.newImage('assets/menus.png')
    local w2, h2 = assets.textures.icon:getDimensions()
    assets.images.menu.aqueduc = love.graphics.newQuad(0, 0, 32, 32, w0, h0)
    assets.images.menu.building = love.graphics.newQuad(33, 0, 32, 32, w0, h0)
    assets.images.menu.trade = love.graphics.newQuad(66, 0, 32, 32, w0, h0)
    assets.images.menu.discover = love.graphics.newQuad(99, 0, 32, 32, w0, h0)
    assets.images.icon.gold = love.graphics.newQuad(0, 0, 32, 32, w1, h1)
    assets.images.icon.iron = love.graphics.newQuad(33, 0, 32, 32, w1, h1)
    assets.images.icon.stone = love.graphics.newQuad(66, 0, 32, 32, w1, h1)
    assets.images.icon.wood = love.graphics.newQuad(99, 0, 32, 32, w1, h1)
    assets.images.icon.days_left = love.graphics.newQuad(132, 0, 32, 32, w1, h1)
    assets.images.icon.minus = love.graphics.newQuad(165, 0, 32, 32, w1, h1)
    assets.images.icon.plus = love.graphics.newQuad(198, 0, 32, 32, w1, h1)
    assets.images.icon.close = love.graphics.newQuad(231, 0, 32, 32, w1, h1)
    assets.images.building.test = love.graphics.newQuad(0, 0, 32, 32, w2, h2)

    assets.images.trade = love.graphics.newImage('assets/trade.png')
end
