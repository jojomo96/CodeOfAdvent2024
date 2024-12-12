local function readInputFile(filename)
    local map = {}
    for line in io.lines(filename) do
        table.insert(map, line)
    end
    return map
end

local function floodFill(map, x, y, visited, plantType)
    local stack = {{x, y}}
    local area = 0
    local perimeter = 0

    while #stack > 0 do
        local cell = table.remove(stack)
        local cx, cy = cell[1], cell[2]

        if visited[cy][cx] then
            goto continue
        end

        visited[cy][cx] = true
        area = area + 1

        local directions = {
            {0, -1}, -- Up
            {0, 1},  -- Down
            {-1, 0}, -- Left
            {1, 0}   -- Right
        }

        for _, dir in ipairs(directions) do
            local nx, ny = cx + dir[1], cy + dir[2]

            if nx < 1 or ny < 1 or ny > #map or nx > #map[1] then
                perimeter = perimeter + 1
            elseif map[ny]:sub(nx, nx) ~= plantType then
                perimeter = perimeter + 1
            elseif not visited[ny][nx] then
                table.insert(stack, {nx, ny})
            end
        end

        ::continue::
    end

    return area, perimeter
end

local function calculateFencingCost(map)
    local visited = {}
    for y = 1, #map do
        visited[y] = {}
        for x = 1, #map[y] do
            visited[y][x] = false
        end
    end

    local totalCost = 0

    for y = 1, #map do
        for x = 1, #map[y] do
            if not visited[y][x] then
                local plantType = map[y]:sub(x, x)
                if plantType ~= " " then
                    local area, perimeter = floodFill(map, x, y, visited, plantType)
                    totalCost = totalCost + (area * perimeter)
                end
            end
        end
    end

    return totalCost
end

-- Main Execution
local map = readInputFile("input.txt")
local totalCost = calculateFencingCost(map)
print("Total cost of fencing: " .. totalCost)
