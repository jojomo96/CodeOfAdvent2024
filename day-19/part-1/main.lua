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
-- Example: "r, wr, b, g, bwu, rb, gb, br"
local patterns = {}
for pat in pattern_line:gmatch("[^,]+") do
    pat = pat:match("^%s*(.-)%s*$") -- trim whitespace
    if #pat > 0 then
        table.insert(patterns, pat)
    end
end

local blank = f:read("*l")
-- Now read designs until EOF
local designs = {}
for line in f:lines() do
    if #line > 0 then
        table.insert(designs, line)
    end
end
f:close()

-- Function to check if a given design can be formed from the patterns
local function can_form_design(design, patterns)
    local n = #design
    local dp = {}
    dp[0] = true  -- empty prefix can always be formed

    -- To speed up matches, we can organize patterns by their first character if desired,
    -- but here we’ll just brute force all patterns.
    
    for i = 0, n-1 do
        if dp[i] then
            for _, p in ipairs(patterns) do
                local plen = #p
                if i+plen <= n then
                    if design:sub(i+1, i+plen) == p then
                        dp[i+plen] = true
                    end
                end
            end
        end
    end

    return dp[n] == true
end

local count = 0
for _, design in ipairs(designs) do
    if can_form_design(design, patterns) then
        count = count + 1
    end
end

print(count)
