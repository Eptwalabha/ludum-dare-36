Aqueduc = {
    width = 0,
    height = 0,
    start = {
        x = 0,
        y = 0
    },
    goal = {
        x = 0,
        y = 0
    },
    nodes = {}
}

Aqueduc.__index = Aqueduc

function Aqueduc.load_from_file(file)
    local aqueduc = {}
    setmetatable(aqueduc, Aqueduc)

    local image = love.image.newImageData(file)
    local w, h = image:getDimensions()
    aqueduc.width = w
    aqueduc.height = height

    for y = 1, h, 1 do
        for x = 1, w, 1 do
            local r, g, b = image:getPixel(x - 1, y - 1)
            if r == 0 and g == 0 and (b == 150 or b == 255) then
                aqueduc:insert_node(x - 1, y - 1, 1)
                if b == 150 then
                    aqueduc.start.x = x - 1
                    aqueduc.start.y = y - 1
                end
            elseif r == 255 and g == 0 and b == 0 then
                aqueduc:insert_node(x - 1, y - 1, 1)
                aqueduc.goal.x = x - 1
                aqueduc.goal.y = y - 1
            end
        end
    end
    return aqueduc
end

function Aqueduc:insert_node_at(x, y, delay)
    if self.nodes[x + y * self.width + 1] then
        return false
    end
    self:insert_node(x, y, delay)
    return true
end

function Aqueduc:insert_node(x, y, delay)
    if not delay then delay = 1 end
    local index = x + y * self.width + 1
    self.nodes[index] = {
        index = index,
        x = x,
        y = y,
        delay = delay
    }
end

function Aqueduc:is_completed()
    local nodes = {}
    for index, node in pairs(self.nodes) do
        if node.delay == 0 then nodes[index] = node end
    end
    local a = astar.create(self.width, nodes)
    local path = astar.find(self.start.x, self.start.y, self.goal.x, self.goal.y, a, true)
    return #path > 1
end

function Aqueduc:tic()
    local done = false
    for _, node in pairs(self.nodes) do
        if node.delay > 0 then
            node.delay = node.delay - 1
            if node.delay == 0 then
                done = true
            end
        end
    end
    if done then
        return self:is_completed()
    end
    return false
end

function Aqueduc:draw(x, y, zoom)
    for p, node in pairs(self.nodes) do
        if node.delay > 0 then
            love.graphics.setColor(100, 100, 100, 150)
        else
            love.graphics.setColor(200, 200, 200)
        end
        love.graphics.rectangle('fill', node.x * zoom + x, node.y * zoom + y, zoom, zoom)
        love.graphics.setColor(0, 0, 255, 100)
        love.graphics.rectangle('fill', node.x * zoom + x, node.y * zoom + y + zoom / 4, zoom, zoom / 2)
    end
end
