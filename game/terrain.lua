Terrain = {
    ['mode'] = 1,
    ['width'] = 10,
    ['origin'] = {
        x = 0,
        y = 30
    },
    ['zoom'] = 15,
    ['height'] = 10,
    ['active'] = {
        hover = false,
        x = 0,
        y = 0
    },
    ['data'] = {},
}

Terrain.__index = Terrain

ZOOM_MIN = 5
ZOOM_MAX = 30

function Terrain.create(x, y, wood, stone, iron)
    local terrain = {}
    setmetatable(terrain, Terrain)

    terrain.width = x
    terrain.height = y

    for i = 1, x * y, 1 do
        local spec = {
            ['altitude'] = 0,
            ['iron'] = 0,
            ['stone'] = 0
        }
        table.insert(terrain.data, spec)
    end
    terrain:update_altitude()
    terrain:update_iron()
    terrain:update_stone()
    terrain:update_wood()
    print(#terrain)
    return terrain
end

function Terrain:update_altitude ()
end

function Terrain:update_iron ()
end

function Terrain:update_wood ()
end

function Terrain:update_stone ()
end

function Terrain:is_mouse_over (x, y)
    return true
end

function Terrain:mouse_moved (x, y, dx, dy)
    if mousedown then
        self:move_origin(dx, dy)
    else
        self:set_active_tile(x, y)
    end
end

function Terrain:wheel_moved (x, y)
    self.zoom = self.zoom + y
    if self.zoom < ZOOM_MIN then self.zoom = ZOOM_MIN end
    if self.zoom > ZOOM_MAX then self.zoom = ZOOM_MAX end
end

function Terrain:set_active_tile (x, y)
    local x2 = math.floor((x - self.origin.x) / self.zoom)
    local y2 = math.floor((y - self.origin.y) / self.zoom)
    self.active.x = x2
    self.active.y = y2
    self.active.hover = x2 < self.width and x2 >= 0 and y2 < self.height and y2 >= 0
end

function Terrain:move_origin (dx, dy)
    local lower_limit = 20
    self.origin.x = self.origin.x + dx
    if self.origin.x > lower_limit then self.origin.x = lower_limit end
    self.origin.y = self.origin.y + dy
    if self.origin.y > lower_limit + 30 then self.origin.y = lower_limit + 30 end
end

function Terrain:draw()
    for x = 0, self.width - 1, 1 do
        local x2 = self.origin.x + x * self.zoom
        for y = 0, self.height - 1, 1 do
            local y2 = self.origin.y + y * self.zoom
            local index = y * self.width + x
            if self.active.hover and self.active.x == x and self.active.y == y then
                love.graphics.setColor(0, 100, 100)
            else
                love.graphics.setColor(0, 200, 100)
            end
            love.graphics.rectangle('fill', x2, y2, self.zoom, self.zoom)
            love.graphics.setColor(255, 255, 255)
            love.graphics.rectangle('line', x2, y2, self.zoom, self.zoom)
        end
    end
end
