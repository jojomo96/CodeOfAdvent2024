local directions = {
    ["^"] = { x = 0, y = -1 },
    ["v"] = { x = 0, y = 1 },
    ["<"] = { x = -1, y = 0 },
    [">"] = { x = 1, y = 0 }
}

local function findRobot(map, mapWidth, mapHeight)
    for y = 1, #map do
        for x = 1, #map[y] do
            if map[y][x] == "@" then
                return x, y
            end
        end
    end
end

local function transformTile(tile)
    if tile == "#" then
        return "##"
    elseif tile == "O" then
        return "[]"
    elseif tile == "." then
        return ".."
    elseif tile == "@" then
        return "@."
    else
        return tile .. tile
    end
end

local function parseInput()
    local map = {}
    local mapWidth = 0
    local mapHeight = 0
    local moveInstructions = ""

    local isMap = true
    for line in io.lines("input.txt") do
        if line:match("^#") then
            if isMap then
                mapHeight = mapHeight + 1
                mapWidth = #line * 2
                local row = {}
                for i = 1, #line do
                    local tile = line:sub(i, i)
                    local transformedTile = transformTile(tile)
                    for j = 1, #transformedTile do
                        table.insert(row, transformedTile:sub(j, j))
                    end
                end
                table.insert(map, row)
            end
        else
            isMap = false
            moveInstructions = moveInstructions .. line
        end
    end

    return map, mapWidth, mapHeight, moveInstructions
end

local function printMap(map)
    local output = ""
    for y = 1, #map do
        for x = 1, #map[y] do
            if map[y][x] == '@' then
                output = output .. "\27[31m" .. map[y][x] .. "\27[0m"  -- Red color for '@'
            elseif map[y][x] == '.' then
                output = output .. " "  -- Replace '.' with a space
            else
                output = output .. map[y][x]
            end
        end
        output = output .. "\n"
    end
    io.write(output)
end

-- local function printMap(map)
--     for y = 1, #map do
--         for x = 1, #map[y] do
--             io.write(map[y][x])
--         end
--         io.write("\n")
--     end
-- end

local function isValid(map, dx, dy, current_x, current_y)
    local char = map[current_y][current_x]
    if not char or char == "#" then
        return false
    end

    if dx == 0 then
        if char == "[" then
            return isValid(map, dx, dy, current_x + dx, current_y + dy) and
                isValid(map, dx, dy, current_x + 1 + dx, current_y + dy)
        end

        if char == "]" then
            return isValid(map, dx, dy, current_x - 1 + dx, current_y + dy) and
                isValid(map, dx, dy, current_x + dx, current_y + dy)
        end
    end

    if dy == 0 and (char == '[' or char == ']') then
        return isValid(map, dx, dy, current_x + dx, current_y + dy)
    end

    return true
end

local function isMoveValid(map, direction)
    local current_x, current_y = findRobot(map)
    local dx, dy = directions[direction].x, directions[direction].y

    return isValid(map, dx, dy, current_x + dx, current_y + dy)
end

local function move(map, dx, dy, current_x, current_y)
    local char = map[current_y][current_x]
    if dx == 0 then
        if char == '[' then
            move(map, dx, dy, current_x + dx, current_y + dy)
            move(map, dx, dy, current_x + 1 + dx, current_y + dy)
            map[current_y][current_x + 1] = "."
            map[current_y + dy][current_x + 1 + dx] = "]"
        elseif char == ']' then
            move(map, dx, dy, current_x - 1 + dx, current_y + dy)
            move(map, dx, dy, current_x + dx, current_y + dy)
            map[current_y][current_x - 1] = "."
            map[current_y + dy][current_x - 1 + dx] = "["
        end  
    end
    if char ~= '.' and char ~= '#' then
        move(map, dx, dy, current_x + dx, current_y + dy)
    end

    if char == "@" then
        map[current_y][current_x] = "."
        map[current_y + dy][current_x + dx] = "@"
        return
    end

    if char == "[" then
        map[current_y][current_x] = "."
        map[current_y + dy][current_x + dx] = "["
        return
    end

    if char == "]" then
        map[current_y][current_x] = "."
        map[current_y + dy][current_x + dx] = "]"
        return
    end
end

local function moveRobot(map, direction)
    local current_x, current_y = findRobot(map)
    local dx, dy = directions[direction].x, directions[direction].y

    if isMoveValid(map, direction) then
        move(map, dx, dy, current_x, current_y)
    end
end

local function calcScore(map)
    local score = 0
    for y = 1, #map do
        for x = 1, #map[y] do
            if map[y][x] == "[" then
                score = score + ((y - 1) * 100) + (x-1)
            end
        end
    end
    return score
end

local function main()
    local map, mapWidth, mapHeight, moveInstructions = parseInput()
    -- printMap(map)
    for i = 1, #moveInstructions do
        local move = moveInstructions:sub(i, i)
        moveRobot(map, move)
        io.write("\27[2J\27[H")  -- Clear the screen and move the cursor to the top-left corner
        os.execute("sleep 0.05")  -- Add a short delay
        printMap(map)
    end
    printMap(map)
    -- print(calcScore(map))
end

main()
