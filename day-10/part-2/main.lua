-- Function to split a string into individual characters
function splitToCharacters(inputstr)
    local t = {}
    for i = 1, #inputstr do
        local char = inputstr:sub(i, i) -- Extract each character
        table.insert(t, tonumber(char)) -- Convert to number
    end
    return t
end

-- Read a matrix from a file and save its dimensions
function readMatrixFromFile(filename)
    local matrix = {}
    local rows = 0
    local cols = 0

    local file = io.open(filename, "r")
    if not file then
        print("Error: Cannot open file " .. filename)
        return nil
    end

    for line in file:lines() do
        local row = splitToCharacters(line) -- Split into individual digits
        table.insert(matrix, row)
        rows = rows + 1
        if cols == 0 then
            cols = #row -- Set the number of columns based on the first row
        elseif #row ~= cols then
            print("Error: Inconsistent number of columns in the matrix.")
            return nil
        end
    end
    file:close()

    return matrix, rows, cols
end

-- Define the function to count paths
function countPaths(matrix, x, y, currentValue)
    -- Check if the current position is out of bounds or invalid
    if x < 1 or x > #matrix or y < 1 or y > #matrix[1] then
        return 0
    end

    -- Check if the current cell value is not the expected increment
    if matrix[x][y] ~= currentValue then
        return 0
    end

    -- Check if the current cell value is 9
    if matrix[x][y] == 9 then
        return 1
    end

    -- Temporarily mark the cell as visited
    local temp = matrix[x][y]
    matrix[x][y] = -1

    -- Explore all four possible directions: up, down, left, right
    local paths = countPaths(matrix, x - 1, y, currentValue + 1) + -- up
                  countPaths(matrix, x + 1, y, currentValue + 1) + -- down
                  countPaths(matrix, x, y - 1, currentValue + 1) + -- left
                  countPaths(matrix, x, y + 1, currentValue + 1)   -- right

    -- Restore the cell value
    matrix[x][y] = temp

    return paths
end

-- Function to find all paths starting from 0
function findPaths(matrix)
    local totalPaths = 0
    for i = 1, #matrix do
        for j = 1, #matrix[i] do
            if matrix[i][j] == 0 then
                totalPaths = totalPaths + countPaths(matrix, i, j, 0)
            end
        end
    end
    return totalPaths
end


-- Example usage
local filename = "input.txt"
local matrix, rows, cols = readMatrixFromFile(filename)

if matrix then
    print("Matrix dimensions: " .. rows .. " x " .. cols)
    print("Matrix content:")
    for i = 1, rows do
        for j = 1, cols do
            io.write(matrix[i][j] .. " ")
        end
        print()
    end
end

local totalPaths = findPaths(matrix)
print("Total Score: " .. totalPaths)

