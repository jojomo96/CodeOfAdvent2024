local function transform_stones_optimized(stones)
    local newStones = {}
    
    for number, count in pairs(stones) do
        local numValue = tonumber(number)

        if numValue == 0 then
            -- Rule 1: Replace with "1"
            newStones["1"] = (newStones["1"] or 0) + count
        elseif #number % 2 == 0 then
            -- Rule 2: Split into two stones
            local half_length = math.floor(#number / 2)
            local left = number:sub(1, half_length)
            local right = number:sub(half_length + 1)
            
            -- Remove leading zeros
            left = tostring(tonumber(left))
            right = tostring(tonumber(right))
            
            newStones[left] = (newStones[left] or 0) + count
            newStones[right] = (newStones[right] or 0) + count
        else
            -- Rule 3: Multiply by 2024
            local multiplied = tostring(numValue * 2024)
            newStones[multiplied] = (newStones[multiplied] or 0) + count
        end
    end

    return newStones
end

-- Load and process the input file
local function load_stones(filename)
    local file = io.open(filename, "r")
    if not file then
        error("Could not open " .. filename)
    end

    local content = file:read("*a")
    file:close()

    local stones = {}
    for number in content:gmatch("%S+") do
        stones[number] = (stones[number] or 0) + 1
    end

    return stones
end

-- Simulate the process
local function simulate(filename, blinks)
    local stones = load_stones(filename)

    for i = 1, blinks do
        stones = transform_stones_optimized(stones)
        -- print("Number of stones after " .. i .. " blinks: " .. table.concat(keys(stones), ", "))
    end

    return stones
end

-- Helper function to count total stones
local function count_total_stones(stones)
    local total = 0
    for _, count in pairs(stones) do
        total = total + count
    end
    return total
end

-- Run the simulation
local stones = simulate("input.txt", 75)
print(string.format("Total stones after 75 blinks: %.0f", count_total_stones(stones)))
