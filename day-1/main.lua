-- Advent of Code - Day 1

local list1 = {}
local list2 = {}
local differences = {}


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

-- Function to insert a number while keeping the list sorted
local function insert_sorted(list, value)
    local inserted = false
    for i = 1, #list do
        if value < list[i] then
            table.insert(list, i, value)
            inserted = true
            break
        end
    end
    if not inserted then
        table.insert(list, value)
    end
end

local input = read_input("input.txt")

for line in input:gmatch("[^\n]+") do
    local a, b = split_pair_of_numbers(line)
    if not a or not b then
        print("Error: Invalid input")
    else 
        insert_sorted(list1, a)
        insert_sorted(list2, b)
    end
end

for i = 1, #list1 do
    local difference = list2[i] - list1[i]
    if difference < 0 then 
        difference = difference * -1
    end
    table.insert(differences, difference)
end

local sum = 0

for i = 1, #differences do
    sum = sum + differences[i]
end

print("Sum of differences: " .. sum)
