-- Utility Functions
local function read_input(file)
    local f, err = io.open(file, "r")
    if not f then 
        error("Unable to open file: " .. file .. ". Error: " .. err)
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

-- Check if the difference between two numbers is within bounds
local function is_diff_valid(num1, num2)
    local diff = math.abs(num1 - num2)
    return diff > 0 and diff <= 3
end

-- Check if the report is valid based on ascending/descending pattern rules
local function is_valid_report(report)
    local is_ascending = true
    local has_changed = false

    for i = 2, #report do
        if not is_diff_valid(report[i], report[i - 1]) then
            return false
        end

        if report[i] < report[i - 1] then
            if has_changed and is_ascending then
                return false
            end
            is_ascending = false
            has_changed = true
        elseif report[i] > report[i - 1] then
            if has_changed and not is_ascending then
                return false
            end
            is_ascending = true
            has_changed = true
        end
    end
    return true
end

-- Check if removing one number can make the report valid
local function can_become_valid(report)
    for i = 1, #report do
        local temp = table.move(report, 1, i - 1, 1, {})
        table.move(report, i + 1, #report, i, temp)
        if is_valid_report(temp) then
            return true
        end
    end
    return false
end

-- Main Program
local function main()
    local input = read_input("input.txt")
    local reports = {}

    for line in input:gmatch("[^\n]+") do
        local report = split_reports(line)
        table.insert(reports, report)
    end

    local valid_reports = 0
    for _, report in ipairs(reports) do
        if is_valid_report(report) or can_become_valid(report) then
            valid_reports = valid_reports + 1
        end
    end

    print("Valid reports: " .. valid_reports)
end

main()
