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

-- Function to check if pattern is found starting at (row, col) in a given direction
-- dx, dy represent the movement steps in row and column respectively
local function check_direction(matrix, row, col, pattern, dx, dy)
    for i = 1, #pattern do
        local r = row + (i-1)*dx
        local c = col + (i-1)*dy
        if getValue(matrix, r, c) ~= pattern:sub(i,i) then
            return false
        end
    end
    return true
end

-- Main code
local filename = "input.txt"
local lines = read_file(filename)
validate_lines(lines)  -- sets global n, m
local matrix = lines_to_matrix(lines)
print_matrix(matrix)

-- Now we search for "XMAS" in all directions
local pattern = "XMAS"
local pattern_len = #pattern

-- Directions to search (dx, dy):
-- Horizontal: (0,1), (0,-1)
-- Vertical: (1,0), (-1,0)
-- Diagonal: (1,1), (1,-1), (-1,1), (-1,-1)
local directions = {
    {dx = 0, dy = 1},   -- left to right
    {dx = 0, dy = -1},  -- right to left
    {dx = 1, dy = 0},   -- top to bottom
    {dx = -1, dy = 0},  -- bottom to top
    {dx = 1, dy = 1},   -- diagonal top-left to bottom-right
    {dx = -1, dy = -1}, -- diagonal bottom-right to top-left
    {dx = 1, dy = -1},  -- diagonal top-right to bottom-left
    {dx = -1, dy = 1},  -- diagonal bottom-left to top-right
}

local occurrences = {}  -- to store found positions

for i = 1, n do
    for j = 1, m do
        if matrix[i][j] == pattern:sub(1,1) then
            -- Check all directions
            for _, dir in ipairs(directions) do
                if check_direction(matrix, i, j, pattern, dir.dx, dir.dy) then
                    table.insert(occurrences, {row = i, col = j, dx = dir.dx, dy = dir.dy})
                end
            end
        end
    end
end

-- Print the results
if #occurrences == 0 then
    print("No occurrences of '" .. pattern .. "' found.")
else
    print("Found occurrences of '" .. pattern .. "':")
    for _, occ in ipairs(occurrences) do
        -- Compute the ending position of the pattern
        local end_row = occ.row + (pattern_len - 1) * occ.dx
        local end_col = occ.col + (pattern_len - 1) * occ.dy
        print(string.format("Start: (%d,%d) End: (%d,%d) Direction: dx=%d, dy=%d", 
            occ.row, occ.col, end_row, end_col, occ.dx, occ.dy))
    end
end

print("Number of occurrences found: " .. #occurrences)
