local max_row, max_col = 70, 70
local map = {}

-- Obstacles
local obstacles = {}

-- State tables for pathfinding
local visited_from_start = {}
local visited_from_goal = {}
local frontier_start = {}
local frontier_goal = {}
local parents_start = {}
local parents_goal = {}

local directions = {
    { x = 0,  y = -1 },
    { x = 1,  y = 0 },
    { x = 0,  y = 1 },
    { x = -1, y = 0 }
}

local start_row, start_col = 0, 0
local end_row, end_col = max_row, max_col

-- Variables for obstacle failure
local failed_obstacle = nil
local failed_line_number = nil

local function readFile(filename)
    local file = io.open(filename, "r")
    if not file then
        error("Could not open file " .. filename)
    end
    local content = file:read("*all")
    file:close()
    return content
end

local function parseInput(content)
    for line in content:gmatch("[^\n]+") do
        local row, col = line:match("(%d+),(%d+)")
        row, col = tonumber(row), tonumber(col)
        if not row or not col or row > max_row or col > max_col then
            error("Invalid input: row or col out of bounds.")
        end
        table.insert(obstacles, {row=row, col=col})
    end
end

local function initializeMap()
    for row = 0, max_row do
        map[row] = {}
        for col = 0, max_col do
            map[row][col] = "."
        end
    end
    map[start_row][start_col] = "S"
    map[end_row][end_col] = "E"
end

local function clearState()
    visited_from_start = {}
    visited_from_goal = {}
    frontier_start = {}
    frontier_goal = {}
    parents_start = {}
    parents_goal = {}
end

local function isVisited(visited_table, row, col)
    return visited_table[row .. "," .. col] or false
end

local function markVisited(visited_table, row, col)
    visited_table[row .. "," .. col] = true
end

local function calcDistance(r1, c1, r2, c2)
    return math.abs(r1 - r2) + math.abs(c1 - c2)
end

local function neighbors(row, col)
    local result = {}
    for _, d in ipairs(directions) do
        local nr, nc = row + d.y, col + d.x
        if nr >= 0 and nr <= max_row and nc >= 0 and nc <= max_col and map[nr][nc] ~= "#" then
            table.insert(result, { r = nr, c = nc })
        end
    end
    return result
end

local function pushNode(frontier, r, c, g, h, parent, parents)
    local f = g + h
    table.insert(frontier, { row = r, col = c, g = g, h = h, f = f })
    parents[r .. "," .. c] = parent
end

local function bidirectionalAStar()
    clearState()

    local start_h = calcDistance(start_row, start_col, end_row, end_col)
    pushNode(frontier_start, start_row, start_col, 0, start_h, nil, parents_start)
    markVisited(visited_from_start, start_row, start_col)

    local goal_h = calcDistance(end_row, end_col, start_row, start_col)
    pushNode(frontier_goal, end_row, end_col, 0, goal_h, nil, parents_goal)
    markVisited(visited_from_goal, end_row, end_col)

    while #frontier_start > 0 and #frontier_goal > 0 do
        table.sort(frontier_start, function(a, b) return a.f < b.f end)
        table.sort(frontier_goal, function(a, b) return a.f < b.f end)

        -- Expand from start side
        local current_start = table.remove(frontier_start, 1)
        local sr, sc = current_start.row, current_start.col
        local sg = current_start.g
        for _, nbr in ipairs(neighbors(sr, sc)) do
            if not isVisited(visited_from_start, nbr.r, nbr.c) then
                local ng = sg + 1
                local nh = calcDistance(nbr.r, nbr.c, end_row, end_col)
                pushNode(frontier_start, nbr.r, nbr.c, ng, nh, sr .. "," .. sc, parents_start)
                markVisited(visited_from_start, nbr.r, nbr.c)
                if isVisited(visited_from_goal, nbr.r, nbr.c) then
                    return true
                end
            end
        end

        -- Expand from goal side
        local current_goal = table.remove(frontier_goal, 1)
        local gr, gc = current_goal.row, current_goal.col
        local gg = current_goal.g
        for _, nbr in ipairs(neighbors(gr, gc)) do
            if not isVisited(visited_from_goal, nbr.r, nbr.c) then
                local ng = gg + 1
                local nh = calcDistance(nbr.r, nbr.c, start_row, start_col)
                pushNode(frontier_goal, nbr.r, nbr.c, ng, nh, gr .. "," .. gc, parents_goal)
                markVisited(visited_from_goal, nbr.r, nbr.c)
                if isVisited(visited_from_start, nbr.r, nbr.c) then
                    return true
                end
            end
        end
    end

    return false
end

local function main()
    local input = readFile("input.txt")
    parseInput(input)

    initializeMap()

    local initial_obstacles = 2910
    for i = 1, initial_obstacles do
        local obs = obstacles[i]
        map[obs.row][obs.col] = "#"
    end

    if not bidirectionalAStar() then
        print("No path exists after inserting the first 1024 obstacles.")
        return
    end

    for i = initial_obstacles + 1, #obstacles do
        local obs = obstacles[i]
        map[obs.row][obs.col] = "#"

        if not bidirectionalAStar() then
            failed_obstacle = obs
            failed_line_number = i
            print("The obstacle inserted at line " .. failed_line_number .. " (" .. obs.row .. "," .. obs.col .. ") blocked the last possible path.")
            return
        end
    end

    print("All obstacles inserted, but a path still exists.")
end

main()
