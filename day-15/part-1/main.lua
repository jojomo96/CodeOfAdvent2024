local function parseInput(filename)
    local robots = {}
    for line in io.lines(filename) do
        local x, y = line:match("p=(%d+),(%d+)")
        x, y = tonumber(x), tonumber(y)

        local vx, vy = line:match("v=(-?%d+),(-?%d+)")
        vx, vy = tonumber(vx), tonumber(vy)

        table.insert(robots, { x = x + 1, y = y + 1, vx = vx, vy = vy })
    end
    return robots
end

local function printRobots(robots)
    for _, robot in ipairs(robots) do
        print("p=" .. robot.x .. "," .. robot.y .. " v=" .. robot.vx .. "," .. robot.vy)
    end
end

local function createMap(robots, map_x, map_y)
    local map = {}
    for i = 1, map_y do
        map[i] = {}
        for j = 1, map_x do
            map[i][j] = 0
        end
    end

    for _, robot in ipairs(robots) do
        map[robot.y][robot.x] = map[robot.y][robot.x] + 1
    end

    return map
end

local function printMap(map, map_x, map_y)
    for i = 1, map_y do
        for j = 1, map_x do
            if map[i][j] == 0 then
                io.write(".")
            else
                io.write(map[i][j])
            end
        end
        io.write("\n")
    end
    io.write("\n")
end

local function createAndPrintMap(robots, map_x, map_y)
    local map = createMap(robots, map_x, map_y)
    printMap(map, map_x, map_y)
end

local function calculateSafeFactorQuadrant(map, start_x, start_y, end_x, end_y, mid_x, mid_y)
    local safeFactor = 0
    for i = start_y, end_y do
        for j = start_x, end_x do
            if not (i == mid_y and j == mid_x) and map[i][j] > 0 then
                safeFactor = safeFactor + map[i][j]
            end
        end
    end
    return safeFactor
end

local function calculateSafeFactor(map, map_x, map_y)
    local safeFactor
    local mid_x = math.ceil(map_x / 2)
    local mid_y = math.ceil(map_y / 2)

    safeFactor = calculateSafeFactorQuadrant(map, 1, 1, mid_x - 1, mid_y - 1, mid_x, mid_y)
    safeFactor = safeFactor * calculateSafeFactorQuadrant(map, mid_x + 1, 1, map_x, mid_y - 1, mid_x, mid_y)
    safeFactor = safeFactor * calculateSafeFactorQuadrant(map, 1, mid_y + 1, mid_x - 1, map_y, mid_x, mid_y)
    safeFactor = safeFactor * calculateSafeFactorQuadrant(map, mid_x + 1, mid_y + 1, map_x, map_y, mid_x, mid_y)

    return safeFactor
end

local function moveRobots(robots, map_x, map_y)
    for _, robot in ipairs(robots) do
        robot.x = robot.x + robot.vx
        robot.y = robot.y + robot.vy

        if robot.x < 1 then
            robot.x = map_x + robot.x
        elseif robot.x > map_x then
            robot.x = robot.x - map_x
        end

        if robot.y < 1 then
            robot.y = map_y + robot.y
        elseif robot.y > map_y then
            robot.y = robot.y - map_y
        end
    end
end

local function main()
    local map_x, map_y = 101,103
    local robots = parseInput("input.txt")
    printRobots(robots)
    local map = createMap(robots, map_x, map_y)
    printMap(map, map_x, map_y)


    local seconds = 100
    for i = 1, seconds do
        moveRobots(robots, map_x, map_y)
    end
    local map = createMap(robots, map_x, map_y)
    printMap(map, map_x, map_y)
    
    local safeFactor = calculateSafeFactor(map, map_x, map_y)
    print("Safe factor:", safeFactor)
end

main()
