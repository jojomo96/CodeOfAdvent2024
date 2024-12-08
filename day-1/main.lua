-- Advent of Code - Day 1

local list1 = {}
local list2 = {}


-- Read input from file
local function read_input(file)
    local f = io.open(file, "r")
    if not f then 
        print("Error: Unable to open file: " .. file)
        os.exit(1)
    end
    local input = f:read("*all")
    f:close()
    return input
end

-- Split input into two numbers
local function split_pair_of_numbers(line)
    local a, b = line:match("(%d+)%s+(%d+)")
    return tonumber(a), tonumber(b)
end

local input = read_input("testinput.txt")

for line in input:gmatch("[^\n]+") do
    local a, b = split_pair_of_numbers(line)
    if not a or not b then
        print("Error: Invalid input")
    else 
        table.insert(list1, a)
        table.insert(list2, b)
    end
end

-- Print the results
print("List 1 (First numbers):", table.concat(list1, ", "))
print("List 2 (Second numbers):", table.concat(list2, ", "))