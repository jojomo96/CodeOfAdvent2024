-- Function to read lines from a file
local function readFile(filePath)
	local lines = {}
	local file = io.open(filePath, "r")
	if not file then
		error("Could not open file: " .. filePath)
	end

	for line in file:lines() do
		table.insert(lines, line)
	end

	file:close()
	return lines
end

-- Function to parse a line into a rule
local function parseRuleLine(line)
	local rule = {}
	for value in string.gmatch(line, "[^|]+") do
		table.insert(rule, tonumber(value))
	end
	return rule
end

-- Function to parse a line into an update
local function parseUpdateLine(line)
	local update = {}
	for value in string.gmatch(line, "[^,]+") do
		table.insert(update, tonumber(value))
	end
	return update
end

-- Function to process the file into rules and updates
local function processFile(filePath)
	local rules = {}
	local updates = {}
	local lines = readFile(filePath)

	local parsingRules = true

	for _, line in ipairs(lines) do
		if line == "" then
			parsingRules = false
		elseif parsingRules then
			local rule = parseRuleLine(line)
			table.insert(rules, rule)
		else
			local update = parseUpdateLine(line)
			table.insert(updates, update)
		end
	end

	return rules, updates
end

local function find_number_in_update(update, number)
	for i, value in ipairs(update) do
		if value == number then
			return i
		end
	end
	return -1
end

local function check_update(rules, update)
	for _, number in ipairs(update) do
		for _, rule in ipairs(rules) do
			if rule[1] == number then
				local index = find_number_in_update(update, rule[1])
				local index2 = find_number_in_update(update, rule[2])

				if index > index2 and index2 ~= -1 then
					return false
				end
			end
		end
	end
	return true
end

local function find_middle_number(update)
	local middle = math.ceil(#update / 2)
	return update[middle]
end

-- Main execution logic
local function main()
	local filePath = "input.txt" -- Replace with your file path if needed
	local rules, updates = processFile(filePath)
	local sum = 0

	-- Print the rules for demonstration
	print("Rules:")
	for i, rule in ipairs(rules) do
		print("Rule " .. i .. ": " .. table.concat(rule, ", "))
	end

	-- Print the updates for demonstration
	print("\nUpdates:")
	for i, update in ipairs(updates) do
		print("Update " .. i .. ": " .. table.concat(update, ", "))
	end

	for i, update in ipairs(updates) do
		local valid = check_update(rules, update)
		if valid then
			print("Update " .. i .. " is valid")
			local middle = find_middle_number(update)
			sum = sum + middle
		else
			print("Update " .. i .. " is invalid")
		end
	end

	print("\nSum of middle numbers in valid updates: " .. sum)
end

-- Execute the main function
main()
