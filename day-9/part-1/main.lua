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
for i = #data, 1, -1 do
    local value = data[i]
	if value ~= "." then
		for j = 1, #data do
			if i == j then
				break
			end
			local value2 = data[j]
			if value2 == "." then
				data[j] = value
				data[i] = "."
				break
			end
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
