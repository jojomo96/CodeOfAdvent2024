local function readInputFile(filename)
    local map = {}
    for line in io.lines(filename) do
        table.insert(map, line)
    end
    return map
end

local function floodFill(map, x, y, visited, outside, plantType)
    local stack = { { x, y } }
    local area = 0
    local perimeter = 0

    while #stack > 0 do
        local cell = table.remove(stack)
        local cx, cy = cell[1], cell[2]

        -- Skip already visited cells
        if visited[cy] and visited[cy][cx] then
            goto continue
        end

        -- Mark the cell as visited
        if visited[cy] == nil then
            visited[cy] = {}
        end
        visited[cy][cx] = true

        -- Count area
        area = area + 1

        -- Directions for neighbors
        local directions = {
            { 0,  -1 }, -- Up
            { 0,  1 }, -- Down
            { -1, 0 }, -- Left
            { 1,  0 } -- Right
        }

        for _, dir in ipairs(directions) do
            local nx, ny = cx + dir[1], cy + dir[2]

            if nx < 1 or ny < 1 or ny > #map or nx > #map[1] then
                -- Out-of-bounds adds to perimeter and mark outside if not already marked
                if not (outside[ny] and outside[ny][nx]) then
                    perimeter = perimeter + 1
                    if outside[ny] == nil then
                        outside[ny] = {}
                    end
                    outside[ny][nx] = true
                end
            elseif map[ny]:sub(nx, nx) ~= plantType then
                -- Different plant type adds to perimeter if not already marked
                if not (outside[ny] and outside[ny][nx]) then
                    perimeter = perimeter + 1
                    if outside[ny] == nil then
                        outside[ny] = {}
                    end
                    outside[ny][nx] = true
                end
            elseif not (visited[ny] and visited[ny][nx]) then
                -- Same plant type and not visited, add to stack
                table.insert(stack, { nx, ny })
            end
        end

        ::continue::
    end

    return area, perimeter
end

local function printOutsideMatrix(outside, mapWidth, mapHeight)
    for y = 1, mapHeight do
        local row = {}
        for x = 1, mapWidth do
            if outside[y] and outside[y][x] then
                table.insert(row, "O")
            else
                table.insert(row, ".")
            end
        end
        print(table.concat(row))
    end
end

local function calculateFencingCost(map)
    local visited = {}
    local outside = {} -- Track the "outside" cells for all plant types

    local totalCost = 0

    for y = 1, #map do
        for x = 1, #map[y] do
            if not (visited[y] and visited[y][x]) then
                local plantType = map[y]:sub(x, x)
                if plantType ~= " " then
                    outside = {} -- Reset the outside map for each plant type
                    local area, perimeter = floodFill(map, x, y, visited, outside, plantType)
                    print("Plant type: " .. plantType .. ", Area: " .. area .. ", Perimeter: " .. perimeter)
                    totalCost = totalCost + (area * perimeter)

                    -- Optionally print the outside map
                    printOutsideMatrix(outside, #map[y], #map)
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
