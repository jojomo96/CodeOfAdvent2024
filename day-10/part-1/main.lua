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
function countPaths(matrix, x, y, currentValue, visited)
    -- Check if the current position is out of bounds or invalid
    if x < 1 or x > #matrix or y < 1 or y > #matrix[1] then
        return 0
    end

    -- Check if the current cell value is not the expected increment
    if matrix[x][y] ~= currentValue then
        return 0
    end

    -- Check if the current cell value is 9 and hasn't been visited yet
    if matrix[x][y] == 9 and not visited[x][y] then
        visited[x][y] = true -- Mark this 9 as visited
        return 1
    end

    -- Temporarily mark the cell as visited
    local temp = matrix[x][y]
    matrix[x][y] = -1

    -- Explore all four possible directions: up, down, left, right
    local paths = countPaths(matrix, x - 1, y, currentValue + 1, visited) + -- up
                  countPaths(matrix, x + 1, y, currentValue + 1, visited) + -- down
                  countPaths(matrix, x, y - 1, currentValue + 1, visited) + -- left
                  countPaths(matrix, x, y + 1, currentValue + 1, visited)   -- right

    -- Restore the cell value
    matrix[x][y] = temp

    return paths
end

-- Function to find all paths starting from 0
function findPaths(matrix)
    local totalPaths = 0

    -- Keep track of visited 9s for each traversal from 0
    for i = 1, #matrix do
        for j = 1, #matrix[i] do
            if matrix[i][j] == 0 then
                -- Reset visited tracking for each new starting point (0)
                local visited = {}
                for m = 1, #matrix do
                    visited[m] = {}
                    for n = 1, #matrix[m] do
                        visited[m][n] = false
                    end
                end
                totalPaths = totalPaths + countPaths(matrix, i, j, 0, visited)
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

