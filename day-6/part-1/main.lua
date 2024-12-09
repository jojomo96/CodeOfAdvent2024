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
        return "_"
    end
    return matrix[row][col]
end

local directions = {
    up    = {-1, 0},
    down  = {1, 0},
    left  = {0, -1},
    right = {0, 1}
}

local function find_char_in_matrix(matrix, char)
    for i = 1, n do
        for j = 1, m do
            if matrix[i][j] == char then
                return {
                    row = i,
                    col = j,
                    found = true
                }
            end
        end
    end
    return {
        row = nil,
        col = nil,
        found = false
    }
end

local current_direction = directions.up
local is_out_of_bounds = false

local function move(matrix, row, col)
	local new_row = row + current_direction[1]
	local new_col = col + current_direction[2]

	local value = getValue(matrix, new_row, new_col)
	if value == "#" then
		-- Turn right
		if current_direction == directions.up then
			current_direction = directions.right
		elseif current_direction == directions.right then
			current_direction = directions.down
		elseif current_direction == directions.down then
			current_direction = directions.left
		elseif current_direction == directions.left then
			current_direction = directions.up
		end
		return row, col
	elseif value == "_" then
		is_out_of_bounds = true
	end
	return new_row, new_col
end


local filename = "input.txt"
local lines = read_file(filename)
validate_lines(lines)  -- sets global n, m
local matrix = lines_to_matrix(lines)
print_matrix(matrix)

local current_position = find_char_in_matrix(matrix, "^")
local steps = 1
print("Current position:", current_position.row, current_position.col)

matrix[current_position.row][current_position.col] = "X"

while not is_out_of_bounds do
	current_position.row, current_position.col = move(matrix, current_position.row, current_position.col)
	if is_out_of_bounds then
		break
	end
	local value = getValue(matrix, current_position.row, current_position.col)
	if value == "." or value == "^"  then
		steps = steps + 1
		matrix[current_position.row][current_position.col] = "X"
	end
end

print_matrix(matrix)
print("Steps:", steps)
