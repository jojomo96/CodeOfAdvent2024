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
            io.write(map[y][x])
        end
        io.write("\n")
    end
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

local function markVisited(x, y, direction)
    visited[x .. "," .. y .. "," .. direction] = true
end

local function isVisited(x, y, direction)
    return visited[x .. "," .. y .. "," .. direction] or false
end

local function isGoal(x, y)
    return x == goal_x and y == goal_y
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

        -- Avoid revisiting
        if not isVisited(new_x, new_y, new_direction) then
            local new_g = current_g + cost
            local f = new_g + calcDistance(new_x, new_y, goal_x, goal_y)
            table.insert(frontier, { x = new_x, y = new_y, g = new_g, direction = new_direction, f = f })
        end
    end
end

local function aStar()
    while #frontier > 0 do
        -- Sort frontier by total cost (f = g + h)
        table.sort(frontier, function(a, b) return a.f < b.f end)

        -- Pop the state with the lowest cost
        local current = table.remove(frontier, 1)
        local current_x, current_y = current.x, current.y
        local current_direction = current.direction
        local current_g = current.g

        -- Check if the goal is reached
        if isGoal(current_x, current_y) then
            print("Goal reached at (" .. current_x .. ", " .. current_y .. ") with cost: " .. current_g)
            return
        end

        -- Mark the current state as visited
        markVisited(current_x, current_y, current_direction)

        -- Generate next steps
        generateNextSteps(current_x, current_y, current_direction, current_g)
    end

    print("No path to goal found.")
end

local function main()
    parseInput()
    local start_x, start_y = findStart()
    goal_x, goal_y = findGoal()

    local current_x, current_y = start_x, start_y
    local current_direction = "E"
    local g = 0

    -- Initialize the frontier with the start position
    table.insert(frontier, { x = current_x, y = current_y, g = g, direction = current_direction, f = calcDistance(start_x, start_y, goal_x, goal_y) })

    printMap()
    aStar()
end

main()
