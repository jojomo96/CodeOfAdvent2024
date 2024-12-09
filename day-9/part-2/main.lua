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

local current_value = -1
local data_block = {}
for i = #data, 1, -1 do
	local value = data[i]

		if value ~= current_value then

			if #data_block > 0 then
				-- print("found data block at index " .. i)
				-- print("data at index " .. i .. ": " .. value)
				-- print("data block: " .. table.concat(data_block, ", "))

				local space_count = 0
				local space_index = -1
				for j = 1, #data do


					local value2 = data[j]
					if value2 == "." then
						if space_index == -1 then
							space_index = j
						end
						space_count = space_count + 1
						if space_count == #data_block then

							for k = 1, #data_block do
								data[space_index + k - 1] = data_block[k]
							end

							for a = i, i + #data_block -1  do
								data[a + 1] = "."
							end
							break
						end
					else
						space_count = 0
						space_index = -1
					end

					if i <= j then
						space_count = 0
						space_index = -1
						data_block = {}
						current_value = -1
						break
					end
				end
			end

			data_block = {value}
			current_value = value
		else
			table.insert(data_block, value)
		end

end

for i = 1, #data do
	local value = data[i]
	io.write(value)
end
print("")

print("00992111777.44.333....5555.6666.....8888..")

local sum = 0

for i = 1, #data do
	local value = data[i]
	if value ~= "." then
		sum = sum + value * (i - 1)
	end
end

print(sum)
