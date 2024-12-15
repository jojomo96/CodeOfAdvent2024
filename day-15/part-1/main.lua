local directions = {
    ["^"] = {x = -1, y = 0},
    ["v"] = {x = 1, y = 0},
    ["<"] = {x = 0, y = -1},
    [">"] = {x = 0, y = 1}
}

local function findRobot(map, mapWidth, mapHeight)
    for y = 1, mapHeight do
        for x = 1, mapWidth do
            if map[x][y] == "@" then
                return x, y
            end
        end
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
                mapWidth = #line
                local row = {}
                for i = 1, #line do
                    table.insert(row, line:sub(i, i))
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
    for y = 1, #map do
        for x = 1, #map[y] do
            io.write(map[y][x])
        end
        io.write("\n")
    end
end

local function moveRobot(map, direction)
    local dx = directions[direction].x
    local dy = directions[direction].y

    local current_x, current_y = findRobot(map, #map[1], #map)

    local look_x, look_y = dx + current_x, dy + current_y
    while map[look_x][look_y ] == "O" do
        look_x = look_x + dx
        look_y = look_y + dy
    end
    if map[look_x][look_y] == "#" then
        return false
    end
    if map[look_x][look_y] == "." then
        map[look_x][look_y] = "O"
        map[current_x][current_y] = "."
        map[current_x + dx][current_y + dy] = "@"
    end
end

local function calcScore(map)
    local score = 0
    for y = 1, #map do
        for x = 1, #map[y] do
            if map[x][y] == "O" then
                score = score + ((x-1) * 100) + (y-1)
            end
        end
    end
    return score
end

local function main()
    local map, mapWidth, mapHeight, moveInstructions = parseInput()
    for i = 1, #moveInstructions do
        local move = moveInstructions:sub(i, i)
        moveRobot(map, move)
    end
    printMap(map)
    print(calcScore(map))
end

main()
