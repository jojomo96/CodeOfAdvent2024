-- Open the file for reading
local f = io.open("input.txt", "r")
if not f then
    error("Could not open input.txt for reading")
end

-- Read the first line and parse the patterns
local pattern_line = f:read("*l")
if not pattern_line then
    error("Input file does not contain any patterns")
end

-- Patterns are separated by commas (and possibly spaces)
local patterns = {}
for pat in pattern_line:gmatch("[^,]+") do
    pat = pat:match("^%s*(.-)%s*$") -- trim whitespace
    if #pat > 0 then
        table.insert(patterns, pat)
    end
end

-- Skip blank line
local blank = f:read("*l")

-- Read designs until EOF
local designs = {}
for line in f:lines() do
    if #line > 0 then
        table.insert(designs, line)
    end
end
f:close()

-- Function to count the number of ways to form a given design
-- using the patterns.
local function count_ways(design, patterns)
    local n = #design
    local dp = {}
    for i=0,n do dp[i] = 0 end
    dp[0] = 1

    for i=0,n-1 do
        if dp[i] > 0 then
            for _, p in ipairs(patterns) do
                local plen = #p
                if i+plen <= n and design:sub(i+1, i+plen) == p then
                    dp[i+plen] = dp[i+plen] + dp[i]
                end
            end
        end
    end

    return dp[n]
end

local total_count = 0
for _, design in ipairs(designs) do
    total_count = total_count + count_ways(design, patterns)
end

print(total_count)
