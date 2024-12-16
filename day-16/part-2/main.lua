local directions = {
    N = { x = 0, y = -1 },
    E = { x = 1, y = 0 },
    S = { x = 0, y = 1 },
    W = { x = -1, y = 0 }
}

local leftTurns = {
    N = "W",
    E = "N",
    S = "E",
    W = "S"
}

local rightTurns = {
    N = "E",
    E = "S",
    S = "W",
    W = "N"
}

local visited = {}
local frontier = {}
local cameFrom = {}
local best_path_tiles = {}
local best_cost = math.huge

local goal_x, goal_y, map

local function parseInput()
    map = {}
    for line in io.lines("input.txt") do
        local row = {}
        for i = 1, #line do
            table.insert(row, line:sub(i, i))
        end
        table.insert(map, row)
    end
end

local function printMap()
    for y = 1, #map do
        for x = 1, #map[y] do
            if best_path_tiles[x .. "," .. y] then
                io.write("O")
            else
                io.write(map[y][x])
            end
        end
        io.write("\n")
    end
end

local function calculateTiles()
    local count = 0
    for y = 1, #map do
        for x = 1, #map[y] do
            if best_path_tiles[x .. "," .. y] then
                count = count + 1
            end
        end
    end
    return count
end

local function findGoal()
    for y = 1, #map do
        for x = 1, #map[y] do
            if map[y][x] == "E" then
                return x, y
            end
        end
    end
end

local function findStart()
    for y = 1, #map do
        for x = 1, #map[y] do
            if map[y][x] == "S" then
                return x, y
            end
        end
    end
end

local function calcDistance(current_x, current_y, goal_x, goal_y)
    return math.abs(current_x - goal_x) + math.abs(current_y - goal_y)
end

local function stepForward(current_x, current_y, current_direction)
    local dx = directions[current_direction].x
    local dy = directions[current_direction].y
    local look_x, look_y = dx + current_x, dy + current_y
    if map[look_y] and map[look_y][look_x] and map[look_y][look_x] ~= "#" then
        return look_x, look_y
    else
        return current_x, current_y
    end
end

local function rotateLeft(current_direction)
    return leftTurns[current_direction]
end

local function rotateRight(current_direction)
    return rightTurns[current_direction]
end

local function markVisited(x, y, direction, cost)
    local key = x .. "," .. y .. "," .. direction
    visited[key] = visited[key] or {}
    table.insert(visited[key], cost)
end

local function isVisitedWithCost(x, y, direction, cost)
    local key = x .. "," .. y .. "," .. direction
    if not visited[key] then return false end
    for _, recorded_cost in ipairs(visited[key]) do
        if recorded_cost < cost then
            return true
        end
    end
    return false
end

local function isGoal(x, y)
    return x == goal_x and y == goal_y
end

local function markBestPathTile(x, y)
    best_path_tiles[x .. "," .. y] = true
end

local function reconstructAllPaths(cameFrom, current)
    while current do
        markBestPathTile(current.x, current.y)
        local key = current.x .. "," .. current.y .. "," .. current.direction
        if not cameFrom[key] then break end
        for _, parent in ipairs(cameFrom[key]) do
            reconstructAllPaths(cameFrom, parent)
        end
        break -- Exit loop after visiting the first parent (recursive calls handle others)
    end
end

local function generateNextSteps(current_x, current_y, current_direction, current_g)
    for _, action in ipairs({ "L", "F", "R" }) do
        local new_x, new_y = current_x, current_y
        local new_direction = current_direction
        local cost = 0

        if action == "L" then
            new_direction = rotateLeft(current_direction)
            cost = 1000
        elseif action == "R" then
            new_direction = rotateRight(current_direction)
            cost = 1000
        elseif action == "F" then
            new_x, new_y = stepForward(current_x, current_y, current_direction)
            cost = 1
        end

        local new_g = current_g + cost
        local f = new_g + calcDistance(new_x, new_y, goal_x, goal_y)

        if not isVisitedWithCost(new_x, new_y, new_direction, new_g) then
            if new_g <= best_cost then
                table.insert(frontier, { x = new_x, y = new_y, g = new_g, direction = new_direction, f = f })
                cameFrom[new_x .. "," .. new_y .. "," .. new_direction] = cameFrom[new_x .. "," .. new_y .. "," .. new_direction] or {}
                table.insert(cameFrom[new_x .. "," .. new_y .. "," .. new_direction], { x = current_x, y = current_y, direction = current_direction })
                markVisited(new_x, new_y, new_direction, new_g)
            end
        end
    end
end

local function aStar()
    while #frontier > 0 do
        table.sort(frontier, function(a, b) return a.f < b.f end)
        local current = table.remove(frontier, 1)
        local current_x, current_y = current.x, current.y
        local current_direction = current.direction
        local current_g = current.g

        if isGoal(current_x, current_y) then
            if current_g <= best_cost then
                if current_g < best_cost then
                    best_cost = current_g
                    best_path_tiles = {} -- Clear previous paths
                end
                reconstructAllPaths(cameFrom, current)
            end
            goto continue
        end

        markVisited(current_x, current_y, current_direction, current_g)
        generateNextSteps(current_x, current_y, current_direction, current_g)
    end
    ::continue::
    printMap()
    print("Best cost:", best_cost)
    print("Tiles:", calculateTiles())
end

local function main()
    parseInput()
    local start_x, start_y = findStart()
    goal_x, goal_y = findGoal()
    local current_x, current_y = start_x, start_y
    local current_direction = "E"
    local g = 0
    table.insert(frontier, { x = current_x, y = current_y, g = g, direction = current_direction, f = calcDistance(start_x, start_y, goal_x, goal_y) })
    aStar()
end

main()
