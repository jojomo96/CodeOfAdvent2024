-- Utility Functions
local pattern = "mul%((%d%d?%d?),%s*(%d%d?%d?)%)"

local function read_input(file)
    local f, err = io.open(file, "r")
    if not f then
        error("Unable to open file: " .. file .. ". Error: " .. err)
    end
    local content = f:read("*all")
    f:close()
    return content
end

-- Main Program
local function main()
    local sum_of_mul = 0
    local content = read_input("input.txt")
    for mul1, mul2 in content:gmatch(pattern) do
        sum_of_mul = sum_of_mul + tonumber(mul1) * tonumber(mul2)
    end
    print(sum_of_mul)
end

main()
