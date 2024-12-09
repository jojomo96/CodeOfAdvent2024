-- Open the input file in read mode
local file = io.open("input.txt", "r")

-- Check if the file was successfully opened
if not file then
	error("Could not open the file!")
end

-- Read the content of the file
local bigNumber = file:read("*all")

-- Close the file
file:close()

-- Print the big number stored as a string
print(bigNumber)

local is_data_block = true
local data = {}
local index = 0
for i = 1, #bigNumber do
	local char = bigNumber:sub(i, i)
	local num = tonumber(char)

	if num == nil then

	else
		for j = 1, num do
			if is_data_block then
				table.insert(data, index)
			else
				table.insert(data, ".")
			end
		end
		if is_data_block then
			index = index + 1
			is_data_block = false
		else
			is_data_block = true
		end
	end
end
for i = 1, #data do
	local value = data[i]
	io.write(value)
end
print("")




local function getSameNumberBlocks(data)
	local blocks = {}
	local currentBlock = {}
	local currentIndex = nil

	for i = #data, 1, -1 do
		if data[i] ~= "." then
			if #currentBlock == 0 or data[i] == currentBlock[1] then
				table.insert(currentBlock, 1, data[i])
				currentIndex = i
			else
				table.insert(blocks, { block = currentBlock, index = currentIndex })
				currentBlock = { data[i] }
				currentIndex = i
			end
		end
	end

	if #currentBlock > 0 then
		table.insert(blocks, { block = currentBlock, index = currentIndex })
	end

	return blocks
end

local function find_empty_space_with_size(data, size)
    for i = 1, #data - size + 1 do
        local isEmptySpace = true
        for j = 0, size - 1 do
            if data[i + j] ~= "." then
                isEmptySpace = false
                break
            end
        end
        if isEmptySpace then
            return i
        end
    end
    return nil -- Return nil if no empty space of the specified size is found
end

local blocks = getSameNumberBlocks(data)
for _, block_info in pairs(blocks) do
	local index_empty_space = find_empty_space_with_size(data, #block_info.block)
	if index_empty_space ~= nil and index_empty_space < block_info.index then
		for i = 1, #block_info.block do
			data[index_empty_space + i - 1] = block_info.block[i]
		end
		for i = 1, #block_info.block do
			data[block_info.index + i - 1] = "."
		end
	end
end

for i = 1, #data do
	local value = data[i]
	io.write(value)
end
print("")

local sum = 0

for i = 1, #data do
	local value = data[i]
	if value ~= "." then
		sum = sum + value * (i - 1)
	end
end

print(sum)
