local n, m  -- global dimensions

local function read_file(filename)
    local file = io.open(filename, "r")
    if not file then
        error("Could not open file " .. filename)
    end

    local lines = {}
    for line in file:lines() do
        lines[#lines + 1] = line
    end

    file:close()
    return lines
end

local function validate_lines(lines)
    n = #lines
    if n == 0 then
        error("Input file is empty, can't form a matrix.")
    end

    -- Determine the length of the first line to define the number of columns
    m = #lines[1]
    if m == 0 then
        error("First line is empty, can't form a matrix.")
    end

    -- Check that all lines have the same length
    for i = 2, n do
        if #lines[i] ~= m then
            error(string.format("Line %d length (%d) does not match expected number of columns (%d).",
                i, #lines[i], m))
        end
    end

    return n, m
end

local function lines_to_matrix(lines)
    local matrix = {}
    for i = 1, n do
        matrix[i] = {}
        for j = 1, m do
            matrix[i][j] = lines[i]:sub(j, j)
        end
    end
    return matrix
end

local function print_matrix(matrix)
    for i = 1, n do
        for j = 1, m do
            io.write(matrix[i][j])
        end
        io.write("\n")
    end
end

-- A helper function to get a value from the matrix or "." if out-of-bounds
local function getValue(matrix, row, col)
    if row < 1 or row > n or col < 1 or col > m then
        return "."
    end
    return matrix[row][col]
end

local filename = "input.txt"
local lines = read_file(filename)
validate_lines(lines)  -- sets global n, m
local matrix = lines_to_matrix(lines)
print_matrix(matrix)

----------------------------------------------------------------------

-- Original pattern (0°)
local pattern_0 = {
    {r=0,c=0,ch='M'},
    {r=0,c=2,ch='S'},
    {r=1,c=1,ch='A'},
    {r=2,c=0,ch='M'},
    {r=2,c=2,ch='S'}
}

-- 90° rotation pattern
local pattern_90 = {
    {r=0,c=2,ch='M'},
    {r=2,c=2,ch='S'},
    {r=1,c=1,ch='A'},
    {r=0,c=0,ch='M'},
    {r=2,c=0,ch='S'}
}

-- 180° rotation pattern
local pattern_180 = {
    {r=2,c=2,ch='M'},
    {r=2,c=0,ch='S'},
    {r=1,c=1,ch='A'},
    {r=0,c=2,ch='M'},
    {r=0,c=0,ch='S'}
}

-- 270° rotation pattern
local pattern_270 = {
    {r=2,c=0,ch='M'},
    {r=0,c=0,ch='S'},
    {r=1,c=1,ch='A'},
    {r=2,c=2,ch='M'},
    {r=0,c=2,ch='S'}
}

local patterns = {pattern_0, pattern_90, pattern_180, pattern_270}


local function matches_pattern(matrix, start_row, start_col, pattern)
    -- start_row, start_col will be the top-left corner of a 3x3 block in the matrix
    for _, p in ipairs(pattern) do
        local mr = start_row + p.r
        local mc = start_col + p.c
        if getValue(matrix, mr, mc) ~= p.ch then
            return false
        end
    end
    return true
end

local occurrences = {}

for i = 1, n-2 do
    for j = 1, m-2 do
        -- Check all rotations
        for _, pat in ipairs(patterns) do
            if matches_pattern(matrix, i, j, pat) then
                table.insert(occurrences, {row=i, col=j, pattern=pat})
            end
        end
    end
end

-- Print results
if #occurrences == 0 then
    print("No occurrences of the pattern found.")
else
    print("Found occurrences of the pattern:")
    for _, occ in ipairs(occurrences) do
        local rotation_label = "0°"
        if occ.pattern == pattern_90 then
            rotation_label = "90°"
        elseif occ.pattern == pattern_180 then
            rotation_label = "180°"
        elseif occ.pattern == pattern_270 then
            rotation_label = "270°"
        end
        print(string.format("Top-left at (%d,%d), Rotation: %s", occ.row, occ.col, rotation_label))
    end
end

print("Number of occurrences found: " .. #occurrences)
