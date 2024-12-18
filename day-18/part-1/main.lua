local max_row, max_col = 70, 70
local max_bytes = 1024
local map = {}
local visited = {}
local frontier = {}

local directions = {
    N = { x = 0, y = -1 },
    E = { x = 1, y = 0 },
    S = { x = 0, y = 1 },
    W = { x = -1, y = 0 }
}

local start_row, start_col = 0, 0
local end_row, end_col = max_row, max_col

-- Function to read the file content
local function readFile(filename)
    local file = io.open(filename, "r")
    if not file then
        error("Could not open file " .. filename)
    end
    local content = file:read("*all")
    file:close()
    return content
end

-- Parse input and populate the map
local function parseInput(input)
    for row = 0, max_row do
        map[row] = {}
        for col = 0, max_col do
            map[row][col] = "."
        end
    end

    local count = 0
    for line in input:gmatch("[^\n]+") do
        if count < max_bytes then
            local row, col = line:match("(%d+),(%d+)")
            row, col = tonumber(row), tonumber(col)
            if not row or not col or row > max_row or col > max_col then
                error("Invalid input: row or col out of bounds.")
            end
            map[row][col] = "#"
            count = count + 1
        else
            break
        end
    end
end

-- Print the grid
local function printGrid()
    for row = 0, max_row do
        for col = 0, max_col do
            io.write(map[row][col])
        end
        io.write("\n")
    end
end

-- Calculate Manhattan distance
local function calcDistance(current_row, current_col, goal_row, goal_col)
    return math.abs(current_row - goal_row) + math.abs(current_col - goal_col)
end

-- Mark a node as visited
local function markVisited(row, col)
    visited[row .. "," .. col] = true
end

-- Check if a node is visited
local function isVisited(row, col)
    return visited[row .. "," .. col] or false
end

-- Check if the current position is the goal
local function isGoal(row, col)
    return row == end_row and col == end_col
end

-- Generate possible next steps
local function generateNextSteps(cur_row, cur_col, current_g)
    for _, delta in pairs(directions) do
        local new_row, new_col = cur_row + delta.y, cur_col + delta.x
        if new_row >= 0 and new_row <= max_row and new_col >= 0 and new_col <= max_col and map[new_row][new_col] ~= "#" then
            local new_g = current_g + 1
            local new_h = calcDistance(new_row, new_col, end_row, end_col)
            local new_f = new_g + new_h
            if not isVisited(new_row, new_col) then
                table.insert(frontier, { row = new_row, col = new_col, g = new_g, h = new_h, f = new_f })
            end
        end
    end
end

-- A* Algorithm
local function aStar()
    while #frontier > 0 do
        -- Sort frontier by total cost (f = g + h)
        table.sort(frontier, function(a, b) return a.f < b.f end)

        local current = table.remove(frontier, 1)
        local cur_row, cur_col = current.row, current.col
        local current_g = current.g

        if isGoal(cur_row, cur_col) then
            print("Goal reached at (" .. cur_row .. ", " .. cur_col .. ") with cost: " .. current_g)
            return
        end

        markVisited(cur_row, cur_col)
        generateNextSteps(cur_row, cur_col, current_g)
    end

    print("No path to goal found.")
end

-- Main function
local function main()
    local input = readFile("input.txt")
    parseInput(input)
    printGrid()

    table.insert(frontier, {
        row = start_row,
        col = start_col,
        g = 0,
        h = calcDistance(start_row, start_col, end_row, end_col),
        f = calcDistance(start_row, start_col, end_row, end_col)
    })
    aStar()
end

main()
