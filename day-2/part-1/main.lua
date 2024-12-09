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

local function split_reports(line)
    local report = {}
    for value in line:gmatch("%d+") do
        table.insert(report, tonumber(value))
    end
    return report
end

local function check_diff(num1, num2)
    local diff = num1 - num2
    if diff > 3 or diff < -3 or diff == 0 then
        return false
    end
    return true 
end


local function check_report(report)
    local is_asc = true
    local has_changed = false
    local current = report[1]

    for i = 2, #report do
        if report[i] < current then
            if has_changed and is_asc then
                return false
            end
            is_asc = false
            has_changed = true
        elseif report[i] > current then
            if has_changed and not is_asc then
                return false
            end
            is_asc = true
            has_changed = true
        end

        if not check_diff(report[i], current) then
            return false
        end

        current = report[i]
    end
    return true
end


-- Main Program
local input = read_input("input.txt")
local reports = {}

for line in input:gmatch("[^\n]+") do
    local report = split_reports(line)
    table.insert(reports, report)
end

local valid_reports = 0
for _, report in ipairs(reports) do
    if check_report(report) then
        valid_reports = valid_reports + 1
    end
end

print("Valid reports: " .. valid_reports)

