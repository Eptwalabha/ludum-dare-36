Aqueduc = {
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
    for y = 1, h, 1 do
        for x = 1, w, 1 do
            local r, g, b = image:getPixel(x - 1, y - 1)
            if r == 0 and g == 0 and (b == 150 or b == 255) then
                local node = Aqueduc.make_node(x - 1, y - 1, math.random(10))
                aqueduc:insert_node(node)
                if b == 150 then
                    aqueduc.start.x = x - 1
                    aqueduc.start.y = y - 1
                end
            elseif r == 255 and g == 0 and b == 0 then
                local node = Aqueduc.make_node(x - 1, y - 1, 0)
                aqueduc:insert_node(node)
                aqueduc.goal.x = x - 1
                aqueduc.goal.y = y - 1
            end
        end
    end
    return aqueduc
end

function Aqueduc:insert_node_at(x, y, delay)
    for i, node in ipairs(self.nodes) do
        if node.x == x and node.y == y then
            return false
        end
    end
    return self:insert_node(Aqueduc.make_node(x, y, delay))
end

function Aqueduc:insert_node(node)
    table.insert(self.nodes, node)
    return true
end

function Aqueduc.make_node(x, y, delay)
    if not delay then
        delay = 10
    end
    return { x = x, y = y, delay = delay }
end

function Aqueduc:is_completed()
    return false
end

function Aqueduc:tic()
    for _, node in ipairs(self.nodes) do
        if node.delay > 0 then
            node.delay = node.delay - 1
        end
    end
end

function Aqueduc:draw(x, y, zoom)
    for _, node in ipairs(self.nodes) do
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
