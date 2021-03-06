astar = {}

function astar.create(width, graph)
    local nodes = {}
    local count = 0
    for index, node in pairs(graph) do
        count = count + 1
        local y = math.floor((index - 1) / width)
        local x = (index - 1) % width
        if not nodes[x] then nodes[x] = {} end
        nodes[x][y] = {
            x = x,
            y = y,
            parent = {},
            F = -1,
            G = 0,
            heuristic = 0,
            index = index
        }
    end
    return nodes
end

function astar.prepare (maps)
    local nodes = {}
    local w = maps.width - 1
    local h = maps.height - 1
    for x = 0, w, 1 do
        nodes[x] = {}
        for y = 0, h, 1 do
            node = {
                x = x,
                y = y,
                parent = {},
                F = -1,
                G = 0,
                heuristic = 0,
                index = x + y * (w + 1) + 1
            }
            nodes[x][y] = node
        end
    end
    return nodes
end

function astar.find (start_x, start_y, goal_x, goal_y, nodes, only_side)
    if start_x == goal_x and start_y == goal_y then
        return {{x = start_x, y = start_y}}
    end
    if not astar.in_graph(start_x, start_y, nodes) or
       not astar.in_graph(goal_x, goal_y, nodes) then
        return {}
    end
    local closed_set = {}
    local open_set = {}
    local start = nodes[start_x][start_y]
    open_set[start.index] = start

    astar.set_heuristic(nodes[goal_x][goal_y], nodes)
    local shortest_dist = -1
    local safe = 2000

    while astar.count(open_set) > 0 and safe > 0 do
        local node = astar.next_node(open_set)
        safe = safe - 1

        if shortest_dist ~= -1 and node.G > shortest_dist then
            break
        end

        open_set, closed_set = astar.move_from_open_to_close(node, open_set, closed_set)

        local neigbours = astar.get_node_neighbours(node, nodes, closed_set, only_side)

        for _, neighbor in pairs(neigbours) do
            local G = astar.compute_g(node, neighbor)
            local F = G + neighbor.heuristic
            if not open_set[neighbor.index] or neighbor.F == -1 or F < neighbor.F then
                neighbor.F = F
                neighbor.G = G
                neighbor.parent = node
                if not open_set[neighbor.index] then
                    open_set[neighbor.index] = neighbor
                end
            end
            if neighbor.x == goal_x and neighbor.y == goal_y then
                if shortest_dist == -1 or shortest_dist > G then
                    shortest_dist = G
                end
            end
        end
    end
    local path = {}
    if shortest_dist ~= -1 then
        path = astar.build_path(nodes[goal_x][goal_y])
    end
    return path
end

function astar.in_graph(x, y, nodes)
    return nodes[x] and nodes[x][y]
end

function astar.count (t)
    local i = 0
    for _ in pairs(t) do i = i + 1 end
    return i
end

function astar.build_path (node)
    if not node then return {} end
    local node_path = {
        x = node.x,
        y = node.y,
        index = node.index
    }
    if not node.parent then return {node_path} end
    local path = astar.build_path (node.parent)
    table.insert(path, node_path)
    return path
end

function astar.compute_g (parent, child)
    local dx = parent.x - child.x
    local dy = parent.y - child.y
    return parent.G + math.sqrt(dx * dx + dy * dy)
end

function astar.get_node_neighbours (node, nodes, closed_set, only_side)
    local x = node.x
    local y = node.y
    local neigbours = {}
    for i = -1, 1, 1 do
        for j = -1, 1, 1 do
            if (not only_side or (only_side and (i + j * 3) % 2 ~= 0)) and
               nodes[x + i] and nodes[x + i][y + j] then
                if i ~= 0 or j ~= 0 then
                    local n = nodes[x + i][y + j]
                    if map:is_buildable(n.index) then
                        if not closed_set[n.index] then
                            neigbours[n.index] = n
                        end
                    end
                end
            end
        end
    end
    return neigbours
end

function astar.move_from_open_to_close (node, open, closed)
    local new_open = {}
    for i, n in pairs(open) do
        if n.index ~= node.index then
            new_open[n.index] = n
        end
    end
    closed[node.index] = node
    return new_open, closed
end

function astar.next_node (open_set)
    local index = -1
    local lowerScore = -1
    for i, node in pairs(open_set) do
        if index == -1 then
            index = i
            lowerScore = node.F
        elseif node.F < lowerScore then
            index = i
            lowerScore = node.F
        end
    end
    return open_set[index]
end

function astar.set_heuristic (node, nodes)
    for i, nodes_i in pairs(nodes) do
        for j, _ in pairs(nodes_i) do
            nodes[i][j].parent = nil
            nodes[i][j].heuristic = math.abs(node.x - nodes[i][j].x) +
                                    math.abs(node.y - nodes[i][j].y)
            nodes[i][j].F = -1
            nodes[i][j].G = 0
        end
    end
end
