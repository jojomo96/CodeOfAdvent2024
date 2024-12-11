-- Function to apply transformation rules to stones
local function transform_stones(stones)
    local i = 1
    local newStones = {}
    while i <= #stones do
        local stone = stones[i]
        local number = tonumber(stone.number)

        if number == 0 then
            table.insert(newStones, { number = "1" })
        elseif #stone.number % 2 == 0 then
            -- Rule 2: If the number has an even number of digits, split into two stones
            local half_length = math.floor(#stone.number / 2)
            local left = stone.number:sub(1, half_length)
            local right = stone.number:sub(half_length + 1)

            -- Remove leading zeros
            left = tostring(tonumber(left))
            right = tostring(tonumber(right))

            table.insert(newStones, { number = left })
            table.insert(newStones, { number = right })
        else
            -- Rule 3: Multiply the number by 2024 and replace the stone
 
            table.insert(newStones, { number = tostring(number * 2024)})
        end
        i = i + 1
    end

    return newStones
end

-- Table to store stones
local Stones = {}

-- Open the file and read numbers
local file = io.open("input.txt", "r")
if not file then
    error("Could not open input.txt")
end

-- Read content from the file
local content = file:read("*a")
file:close()

-- Process each number in the file (separated by spaces)
for number in content:gmatch("%S+") do -- Match non-space sequences
    local stone = {
        number = tostring(number) -- Store the whole number as a string
    }
    table.insert(Stones, stone)
end

-- Apply transformations and print the results for one blink

for i = 1, 75, 1 do
    
    Stones = transform_stones(Stones)
    print("Number of stones after " .. i .. " blinks: " .. #Stones)
end

print("Number of stones after 25 blinks: " .. #Stones)
