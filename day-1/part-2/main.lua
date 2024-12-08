-- Advent of Code - Day 1

local function read_input(file)
    local f = io.open(file, "r")
    if not f then 
        error("Unable to open file: " .. file)
    end
    local content = f:read("*all")
    f:close()
    return content
end

local function split_pair_of_numbers(line)
    local a, b = line:match("(%d+)%s+(%d+)")
    return tonumber(a), tonumber(b)
end

local function insert_sorted(list, value)
    for i = 1, #list do
        if value < list[i] then
            table.insert(list, i, value)
            return
        end
    end
    table.insert(list, value) -- Append if not inserted
end

local function calculate_occurances(list1, list2)
    local occurances = {}
    for i = 1, #list1 do
        for j = 1, #list2 do
            if list1[i] == list2[j] then
                table.insert(occurances, list1[i])
            end
            if list1[i] < list2[j] then
                break
            end
        end

    end
    return occurances
end

local function sum_list(list)
    local sum = 0
    for _, value in ipairs(list) do
        sum = sum + value
    end
    return sum
end

-- Main Program
local input = read_input("input.txt")
local list1, list2 = {}, {}

for line in input:gmatch("[^\n]+") do
    local a, b = split_pair_of_numbers(line)
    if a and b then
        insert_sorted(list1, a)
        insert_sorted(list2, b)
    else
        error("Invalid input: " .. line)
    end
end

local occurances = calculate_occurances(list1, list2)
local sum = sum_list(occurances)

print("Sum of occurances: " .. sum)
