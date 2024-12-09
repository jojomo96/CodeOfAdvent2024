local function parse_input_file(filename)
	local results = {}

	-- Open file for reading
	local file = io.open(filename, "r")
	if not file then
		return nil, "Could not open file"
	end

	-- Read each line
	for line in file:lines() do
		-- Skip empty lines
		if line:match("%S") then
			-- Split on colon
			local result, numbers = line:match("(%d+):%s*(.*)")

			if result then
				-- Convert result to number
				result = tonumber(result)

				-- Split remaining numbers
				local nums = {}
				for num in numbers:gmatch("%d+") do
					table.insert(nums, tonumber(num))
				end

				-- Create operations array
				local operations = {}
				for i = 1, #nums - 1 do
					operations[i] = "+"
				end

				-- Store in results table
				results[#results + 1] = {
					result = result,
					numbers = nums
				}
			end
		end
	end

	file:close()
	return results
end

local function brute_force_solution(result, numbers)
	-- Create a table of all possible combinations of operations
	local combinations = {}
	for i = 0, 2 ^ (#numbers - 1) - 1 do
		local combination = {}
		for j = 1, #numbers - 1 do
			combination[j] = (i % 2 ^ j) // 2 ^ (j - 1)
		end
		combinations[i + 1] = combination
	end

	-- Iterate over all combinations
	for _, combination in ipairs(combinations) do
		-- Calculate the result of the combination
		local current = numbers[1]
		for i = 1, #combination do
			if combination[i] == 0 then
				current = current + numbers[i + 1]
			else
				current = current * numbers[i + 1]
			end
		end

		-- Check if the result matches the expected result
		if current == result then
			return true
		end
	end

	return false
end

-- Example usage:
local data = parse_input_file("input.txt")
local end_result = 0
if data then
	for i, entry in ipairs(data) do
		print("Line " .. i)
		print("Result:", entry.result)
		print("Numbers:", table.concat(entry.numbers, ", "))
		if brute_force_solution(entry.result, entry.numbers) then
			print("Solution found")
			end_result = end_result + entry.result
		else
			print("Solution not found")
		end
		print()
	end
end

print("Sum of all results with a solution:", end_result)
