AntinodeList = {}
AntinodeList.__index = AntinodeList

function AntinodeList.new()
	local self = setmetatable({}, AntinodeList)
	self.coords = {} -- Store coordinates as string keys for uniqueness
	self.size = 0
	return self
end

function AntinodeList:add(x, y)
	local key = string.format("%d,%d", x, y)
	if not self.coords[key] then
		self.coords[key] = { x = x, y = y }
		self.size = self.size + 1
	end
end

function AntinodeList:contains(x, y)
	local key = string.format("%d,%d", x, y)
	return self.coords[key] ~= nil
end

function AntinodeList:getAll()
	local result = {}
	for _, coord in pairs(self.coords) do
		table.insert(result, { coord.x, coord.y })
	end
	return result
end

function AntinodeList:print()
	for _, coord in pairs(self.coords) do
		print(string.format("(%d, %d)", coord.x, coord.y))
	end
end

-- Read matrix from file and group coordinates by character
local function read_matrix_coordinates(filename)
    -- Store char coordinates
    local charPositions = {}

    -- Read file contents
    local file = io.open(filename, "r")
    if not file then
        error("Could not open file " .. filename)
    end
    local matrix = {}
    local y = 1
    local width = 0
    local height = 0

    -- Read matrix line by line
    for line in file:lines() do
        matrix[y] = {}
        width = math.max(width, #line)
        for x = 1, #line do
            local char = line:sub(x, x)
            if char ~= '.' then
                -- Initialize table for new chars
                if not charPositions[char] then
                    charPositions[char] = {}
                end
                -- Store coordinate pair
                table.insert(charPositions[char], { x, y })
            end
        end
        y = y + 1
    end
    height = y - 1
    file:close()

    -- Print results
    for char, positions in pairs(charPositions) do
        io.write(char .. " ")
        for _, pos in ipairs(positions) do
            io.write(string.format("(%d,%d) ", pos[1], pos[2]))
        end
        print()
    end

    return charPositions, width, height
end

local function calculate_delta_distance(pos1, pos2)
	local delta_x = pos1[1] - pos2[1]
	local delta_y = pos1[2] - pos2[2]
	return delta_x, delta_y
end

local function print_matrix_with_antinodes(char_positions, antinodes, width, height)
    -- Initialize the matrix with empty spaces
    local matrix = {}
    for y = 1, height do
        matrix[y] = {}
        for x = 1, width do
            matrix[y][x] = '.'
        end
    end

    -- Place characters in the matrix
    for char, positions in pairs(char_positions) do
        for _, pos in ipairs(positions) do
            local x, y = pos[1], pos[2]
            matrix[y][x] = char
        end
    end

    -- Place antinodes in the matrix
    for _, pos in ipairs(antinodes) do
        local x, y = pos[1], pos[2]
        matrix[y][x] = '#'
    end

    -- Print the matrix
    for y = 1, height do
        for x = 1, width do
            io.write(matrix[y][x])
        end
        io.write("\n")
    end
end


local function generate_antinodes(char_positions, antinodeList, width, height)
	for i = 1, #char_positions do
		for j = i + 1, #char_positions do
			if i ~= j then
				local pos1 = char_positions[i]
				local pos2 = char_positions[j]
				if pos1 and pos2 then  -- Validate positions exist
					local delta_x, delta_y = calculate_delta_distance(pos1, pos2)
					if delta_x and delta_y then  -- Validate deltas exist
						-- Calculate new coordinates
						local new_x1 = pos1[1] + delta_x
						local new_y1 = pos1[2] + delta_y
						local new_x2 = pos2[1] - delta_x
						local new_y2 = pos2[2] - delta_y

						-- Add valid coordinates only
						if new_x1 and new_y1 and new_x1 >= 1 and new_x1 <= width and new_y1 >= 1 and new_y1 <= height then
							antinodeList:add(new_x1, new_y1)
						end
						if new_x2 and new_y2 and new_x2 >= 1 and new_x2 <= width and new_y2 >= 1 and new_y2 <= height then
							antinodeList:add(new_x2, new_y2)
						end
					end
				end
			end
		end
	end
end

local char_positions, width, height = read_matrix_coordinates("input.txt")
local antinodeList = AntinodeList.new()
for char, positions in pairs(char_positions) do
	generate_antinodes(positions, antinodeList, width, height)
end

print_matrix_with_antinodes(char_positions, antinodeList:getAll(), width, height)
print()
print("Antinode count: " .. antinodeList.size)
