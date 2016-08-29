Map = {
    mode_mask = false,
    mask = {},
    width = 10,
    origin = {
        x = 0,
        y = 30
    },
    zoom = 15,
    height = 10,
    active = {
        hover = false,
        x = 0,
        y = 0
    },
    data = {},
}

Map.__index = Map

ZOOM_MIN = 10
ZOOM_MAX = 30

function Map.load_from_file(file)
    local image = love.image.newImageData(file)
    local map = {}
    setmetatable(map, Map)
    local w, h = image:getDimensions()
    map.width = w
    map.height = h

    for y = 1, map.height, 1 do
        for x = 1, map.width, 1 do
            local r, g, b = image:getPixel(x - 1, y - 1)
            table.insert(map.data, Map.get_spec_from_color(r, g, b))
        end
    end

    return map
end

function Map.spec(building, mountain, wood, iron, stone)
    if not mountain then
        mountain = false
    end
    return {
        building = building,
        wood = wood,
        iron = iron,
        stone = stone,
        mountain = mountain
    }
end

function Map.get_spec_from_color(r, g, b)
    if r == 50 and g == 50 and b == 50 then
        return Map.spec(false, true, 0, 0, 0)
    elseif r == 100 and g == 100 and b == 100 then
        return Map.spec(false, true, 0, 100, 0)
    elseif r == 0 and b == 0 then
        if g == 255 then
            return Map.spec(false, false, 0, 0, 0)
        elseif g == 150 then
            return Map.spec(false, false, 100, 0, 0)
        end
    elseif r == 255 and g == 255 and b == 255 then
        return Map.spec(false, false, 0, 0, 100)
    end
    return Map.spec(false, false, 0, 0, 0)
end

function Map.create(x, y, wood, stone, iron)
    local map = {}
    setmetatable(map, Map)

    map.width = x
    map.height = y

    for i = 0, x - 1, 1 do
        for j = 0, y - 1, 1 do
            local spec = {
                pos = {
                    x = i,
                    y = j
                },
                building = (math.random() > 0.9),
                wood = 0,
                iron = 0,
                stone = 0
            }
            table.insert(map.data, spec)
        end
    end
    map:update_altitude()
    map:update_iron()
    map:update_stone()
    map:update_wood()
    return map
end

function Map:update_altitude ()
end

function Map:update_iron ()
end

function Map:update_wood ()
end

function Map:update_stone ()
end

function Map:is_mouse_over (x, y)
    return true
end

function Map:mouse_pressed (x, y, button)
    local index = self:get_index(x, y)
    if index > 0 and index <= #self.data then
        return self.data[index]
    end
    return nil
end

function Map:wheel_moved (x, y)
    self.zoom = self.zoom + y
    if self.zoom < ZOOM_MIN then self.zoom = ZOOM_MIN end
    if self.zoom > ZOOM_MAX then self.zoom = ZOOM_MAX end
end

function Map:set_active_tile (x, y)
    local _, x2, y2 = self:get_index (x, y)
    self.active.x = x2
    self.active.y = y2
    self.active.hover = x2 < self.width and x2 >= 0 and y2 < self.height and y2 >= 0
end

function Map:move_origin (dx, dy)
    local lower_limit = 20
    self.origin.x = self.origin.x + dx
    self.origin.y = self.origin.y + dy
    if self.origin.x > lower_limit then
        self.origin.x = lower_limit
    end
    if self.origin.y > lower_limit + TOP_HEIGHT then
        self.origin.y = lower_limit + TOP_HEIGHT
    end
end

function Map:draw (buildings)
    for x = 0, self.width - 1, 1 do
        local x2 = self.origin.x + x * self.zoom
        for y = 0, self.height - 1, 1 do
            local y2 = self.origin.y + y * self.zoom
            local index = y * self.width + x + 1
            local r, g, b = self:set_color(index)
            love.graphics.setColor(r, g, b)
            if self.active.hover and self.active.x == x and self.active.y == y then
                love.graphics.setColor(0, 100, 100)
            end
            love.graphics.rectangle('fill', x2, y2, self.zoom, self.zoom)
            love.graphics.setColor(255, 255, 255, 50)
            love.graphics.rectangle('line', x2, y2, self.zoom, self.zoom)
        end
    end
    if buildings then
        self:draw_buildings(buildings)
    end
end

function Map:set_color(index)
    local tile = self.data[index]
    if self.mode_mask then
        if tile.mountain then
            return 150, 0, 0
        end
        if tile.building and self.mask.building or
           tile.wood ~= 0 and self.mask.wood or
           tile.iron ~= 0 and self.mask.iron or
           tile.stone ~= 0 and self.mask.stone then
           return 150, 0, 0
       end
    end

    if tile.wood ~= 0 then
        return 0, 100, 0
    elseif tile.iron ~= 0 then
        return 100, 100, 100
    elseif tile.stone ~= 0 then
        return 255, 255, 255
    elseif tile.mountain then
        return 50, 50, 50
    end
    return 0, 200, 100
end

function Map:draw_buildings(buildings)
    for i, building in ipairs(buildings) do
        love.graphics.setColor(255, 255, 255)
        if building.delay ~= 0 then
            love.graphics.setColor(255, 255, 255, 150)
        end
        local scale = self.zoom / 32
        love.graphics.draw(assets.textures.building,
                           assets.images.building[building.image],
                           self.origin.x + building.x * self.zoom,
                           self.origin.y + building.y * self.zoom,
                           0, scale, scale)
    end
end

function Map:draw_entity (mx, my, item)
    if item.name then
        local _, x, y = self:get_index(mx, my)
        local x0 = x - math.floor((item.size - 1) / 2)
        local y0 = y - math.floor((item.size - 1) / 2)
        local buildable = true
        for x_s = x0, x0 + item.size - 1, 1 do
            local x2 = self.origin.x + x_s * self.zoom
            for y_s = y0, y0 + item.size - 1, 1 do
                local y2 = self.origin.y + y_s * self.zoom
                local index = self:pos_to_index(x_s, y_s)
                if self:is_buildable (index) then
                    love.graphics.setColor(0, 255, 0)
                else
                    buildable = false
                    love.graphics.setColor(255, 0, 0)
                end
                love.graphics.rectangle('fill', x2, y2, self.zoom, self.zoom)
            end
        end
        if buildable then
            love.graphics.setColor(0, 255, 0)
        else
            love.graphics.setColor(255, 0, 0)
        end
        local scale = self.zoom / 32
        love.graphics.draw(assets.textures.building,
                           assets.images.building[item.image],
                           self.origin.x + x * self.zoom,
                           self.origin.y + y * self.zoom,
                           0, scale, scale)
    end
end

function Map:is_buildable (index, mask)
    if not mask then mask = self.mask end
    if not index or index < 1 or index > #self.data then
        return false
    end

    local spec = self.data[index]

    if self.mode_mask then
        return not spec.mountain and not Map.spec_compatible_with_mask(spec, mask)
    end
    return not spec.mountain
end

function Map.spec_compatible_with_mask (spec, mask)
    return spec.building and mask.building or
           spec.wood > 0 and mask.wood or
           spec.iron > 0 and mask.iron or
           spec.stone > 0 and mask.stone
end

function Map:get_index (mx, my)
    local x = math.floor((mx - self.origin.x) / self.zoom)
    local y = math.floor((my - self.origin.y) / self.zoom)
    local index = y * self.width + x + 1
    return index, x, y
end

function Map:pos_to_index (x, y)
    if x < 0 or x >= self.width or y < 0 or y >= self.height then
        return nil
    end
    return y * self.width + x + 1
end

function Map:index_to_pos (index)
    local y = math.floor((index - 1) / self.width)
    local x = index - 1 - y * self.width
    return x, y
end

function Map:add_entity (mx, my, item)
    local _, x, y = self:get_index(mx, my)
    local x0 = x - math.floor((item.size - 1) / 2)
    local y0 = y - math.floor((item.size - 1) / 2)
    local to_check = self:get_indexes_from_area(x0, y0, item.size, item.size)

    for i = 1, #to_check, 1 do
        if not self:is_buildable (to_check[i]) then
            return false
        end
    end

    for i = 1, #to_check, 1 do
        self.data[to_check[i]].building = true
    end
    item.x = x
    item.y = y
    return true
end

function Map:get_indexes_from_mouse_area (mx, my, w, h)
    local _, x, y = self:get_index(mx, my)
    return self:get_indexes_from_area(x, y, w, h)
end

function Map:get_indexes_from_area (x, y, w, h)
    local indexes = {}
    for i = x, x + w - 1, 1 do
        for j = y, y + h - 1, 1 do
            local index = self:pos_to_index(i, j)
            table.insert(indexes, index)
        end
    end
    return indexes
end

function Map:set_forbiden_mask(building, wood, iron, stone)
    self.mask = Map.make_mask(building, wood, iron, stone)
end

function Map:fetch_ressouces(building)
    building.fetch = {}
    building.fetch.iron = 0
    building.fetch.stone = 0
    building.fetch.wood = 0

    if building.delay == 0 then
        local all_ressources = false
        for radius = 0, building.radius, 1 do
            all_ressources = self:fetch_ressouces_at(building, radius)
            if all_ressources then break end
        end
    end
end

function Map:fetch_ressouces_at(building, radius)
   local x, y = building.x, building.y
   local indexes = {}

   for x = building.x - radius, building.x + radius, 1 do
       for y = building.y - radius, building.y + radius, 1 do
           if x >= 0 and x < self.width and y >= 0 and y < self.height then
               if x == building.x - radius or x == building.x + radius or
                  y == building.y - radius or y == building.y + radius then
                   local index = x + y * self.width + 1
                   table.insert(indexes, index)
               end
           end
       end
   end

   for index = 1, #indexes, 1 do
       local spec = self.data[indexes[index]]
       local left_iron = building.capacity.iron - building.fetch.iron
       if left_iron > 0 and spec.iron > 0 then
           local amount = math.min(left_iron, spec.iron)
           building.fetch.iron = building.fetch.iron + amount
           spec.iron = spec.iron - amount
       end
       local left_stone = building.capacity.stone - building.fetch.stone
       if left_stone > 0 and spec.stone > 0 then
           local amount = math.min(left_stone, spec.stone)
           building.fetch.stone = building.fetch.stone + amount
           spec.stone = spec.stone - amount
       end
       local left_wood = building.capacity.wood - building.fetch.wood
       if left_wood > 0 and spec.wood > 0 then
           local amount = math.min(left_wood, spec.wood)
           building.fetch.wood = building.fetch.wood + amount
           spec.wood = spec.wood - amount
       end
       if building.fetch.iron == building.capacity.iron and
           building.fetch.stone == building.capacity.stone and
           building.fetch.wood == building.capacity.wood then
           return true
       end
   end
   return false
end

function Map.make_mask(building, wood, iron, stone)
    return { building = building, wood = wood, iron = iron, stone = stone }
end
