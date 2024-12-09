local n, m -- global dimensions

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

local function clear_x(matrix)
    for i = 1, n do
        for j = 1, m do
            if matrix[i][j] == "X" then
                matrix[i][j] = "."
            end
        end
    end
    return matrix
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
	up    = { -1, 0 },
	down  = { 1, 0 },
	left  = { 0, -1 },
	right = { 0, 1 }
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

local function get_direction_name(vector)
    for name, vec in pairs(directions) do
        if vec[1] == vector[1] and vec[2] == vector[2] then
            return name
        end
    end
    return nil -- Return nil if the vector does not match any direction
end

local function initialize_passed_directions(n, m)
    if type(n) ~= "number" or type(m) ~= "number" then
        error("Dimensions must be numbers")
    end

    local passed = {}
    for row = 1, n do
        passed[row] = {}
        for col = 1, m do
            passed[row][col] = {
                up = false,
                down = false,
                left = false,
                right = false
            }
        end
    end
    return passed
end


local filename = "input.txt"
local lines = read_file(filename)
validate_lines(lines) -- sets global n, m
local matrix = lines_to_matrix(lines)
print_matrix(matrix)

-- Initialize passed directions table
local passed = initialize_passed_directions(n, m)

-- Helper function to mark direction as passed
local function mark_direction(row, col, vector)
    -- Ensure the row exists
    if not passed[row] then
        passed[row] = {}
    end

    -- Ensure the cell exists
    if not passed[row][col] then
        passed[row][col] = {
            up = false,
            down = false,
            left = false,
            right = false
        }
    end

    -- Get the direction name from the vector
    local direction = get_direction_name(vector)
    if direction and passed[row][col][direction] ~= nil then
        passed[row][col][direction] = true
    else
        error("Invalid vector: " .. tostring(vector[1]) .. ", " .. tostring(vector[2]))
    end
end

local function print_passed()
    for row, cols in pairs(passed) do
        for col, directions in pairs(cols) do
            print(string.format("Cell (%d, %d):", row, col))
            for direction, status in pairs(directions) do
                print(string.format("  %s: %s", direction, status and "true" or "false"))
            end
        end
    end
end

local function already_passed(row, col, vector)
    -- Get the direction name
    local direction = get_direction_name(vector)
    if passed[row] and passed[row][col] and direction then
        return passed[row][col][direction] == true
    end
    return false
end

local function deep_copy(original)
    if type(original) ~= 'table' then return original end
    local copy = {}
    for k, v in pairs(original) do
        copy[k] = type(v) == 'table' and deep_copy(v) or v
    end
    return copy
end


local current_position = find_char_in_matrix(matrix, "^")
local current_position_temp = deep_copy(current_position)
local steps = 0


for i = 1, n do
	for j = 1, m do
		if matrix[i][j] ~= "#" then
			matrix[i][j] = "#"

			while not is_out_of_bounds do
				if not already_passed(current_position.row, current_position.col, current_direction) then
					mark_direction(current_position.row, current_position.col, current_direction)
					-- matrix[current_position.row][current_position.col] = "X"
				else
					steps = steps + 1
					print("Steps:", steps)
					break
				end


				current_position.row, current_position.col = move(matrix, current_position.row, current_position.col)
				if is_out_of_bounds then
					break
				end
			end
			-- print_matrix(matrix)
			-- clear_x(matrix)
			passed = initialize_passed_directions(n, m)
			current_position = deep_copy(current_position_temp)
			current_direction = directions.up
			is_out_of_bounds = false

			-- print("Current Player position:", current_position.row, current_position.col)
			matrix[i][j] = "."
			-- print("Current position:", i, j)
		end
	end
	print("Row:", i)
end


mark_direction(current_position.row, current_position.col, directions.up)


print_matrix(matrix)
print("Steps:", steps)
