local max_row, max_col = 70, 70
local map = {}

-- We'll read all obstacles first and then insert them one by one.
local obstacles = {}

-- State tables will be reinitialized each time we run pathfinding.
local visited_from_start = {}
local visited_from_goal = {}
local frontier_start = {}
local frontier_goal = {}
local parents_start = {}
local parents_goal = {}

-- Add a variable to track the last added obstacle
local last_added_obstacle = nil


local directions = {
	{ x = 0,  y = -1 },
	{ x = 1,  y = 0 },
	{ x = 0,  y = 1 },
	{ x = -1, y = 0 }
}

local start_row, start_col = 0, 0
local end_row, end_col = max_row, max_col

-- Colors
local RESET = "\27[0m"
local GREEN = "\27[32m"
local RED = "\27[31m"
local YELLOW = "\27[33m"

-- A variable to store the failed obstacle if path gets blocked
local failed_obstacle = nil
local failed_line_number = nil

-- Read file
local function readFile(filename)
	local file = io.open(filename, "r")
	if not file then
		error("Could not open file " .. filename)
	end
	local content = file:read("*all")
	file:close()
	return content
end

-- We'll parse the input but not immediately place obstacles. We'll store them.
local function parseInput(content)
	for line in content:gmatch("[^\n]+") do
		local row, col = line:match("(%d+),(%d+)")
		row, col = tonumber(row), tonumber(col)
		if not row or not col or row > max_row or col > max_col then
			error("Invalid input: row or col out of bounds.")
		end
		table.insert(obstacles, { row = row, col = col })
	end
end

local function initializeMap()
	for row = 0, max_row do
		map[row] = {}
		for col = 0, max_col do
			map[row][col] = "."
		end
	end
	map[start_row][start_col] = "S"
	map[end_row][end_col] = "E"
end

local function clearState()
	visited_from_start = {}
	visited_from_goal = {}
	frontier_start = {}
	frontier_goal = {}
	parents_start = {}
	parents_goal = {}
end

local function isVisited(visited_table, row, col)
	return visited_table[row .. "," .. col] or false
end

local function markVisited(visited_table, row, col)
	visited_table[row .. "," .. col] = true
end

local function calcDistance(r1, c1, r2, c2)
	return math.abs(r1 - r2) + math.abs(c1 - c2)
end

local function neighbors(row, col)
	local result = {}
	for _, d in ipairs(directions) do
		local nr, nc = row + d.y, col + d.x
		if nr >= 0 and nr <= max_row and nc >= 0 and nc <= max_col and map[nr][nc] ~= "#" then
			table.insert(result, { r = nr, c = nc })
		end
	end
	return result
end

local function pushNode(frontier, r, c, g, h, parent, parents)
	local f = g + h
	table.insert(frontier, { row = r, col = c, g = g, h = h, f = f })
	parents[r .. "," .. c] = parent
end

local function reconstructPartialPath(parents, node_r, node_c)
	local path = {}
	local cur = node_r .. "," .. node_c
	while cur do
		table.insert(path, 1, cur)
		cur = parents[cur]
	end
	return path
end

local function reconstructFullPath(meet_r, meet_c)
	-- Reconstruct from start
	local path_from_start = {}
	do
		local cur = meet_r .. "," .. meet_c
		while parents_start[cur] do
			table.insert(path_from_start, 1, cur)
			cur = parents_start[cur]
		end
		table.insert(path_from_start, 1, start_row .. "," .. start_col)
	end

	-- Reconstruct from goal
	local path_from_goal = {}
	do
		local cur = meet_r .. "," .. meet_c
		while parents_goal[cur] do
			table.insert(path_from_goal, cur)
			cur = parents_goal[cur]
		end
		table.insert(path_from_goal, end_row .. "," .. end_col)
	end

	table.remove(path_from_goal, 1) -- remove duplicate meet point
	for _, node in ipairs(path_from_goal) do
		table.insert(path_from_start, node)
	end

	return path_from_start
end

local function buildGridString(path_from_start, path_from_goal, final)
	-- Convert paths to sets for quick lookup
	local start_set = {}
	local goal_set = {}
	if path_from_start then
		for _, pos in ipairs(path_from_start) do
			start_set[pos] = true
		end
	end
	if path_from_goal then
		for _, pos in ipairs(path_from_goal) do
			goal_set[pos] = true
		end
	end

	local lines = {}
	for row = 0, max_row do
		local line_parts = {}
		for col = 0, max_col do
			local symbol = map[row][col]
			local pos_str = row .. "," .. col
			if final then
				-- In final print, show final path in yellow or if failed_obstacle print red
				if failed_obstacle and row == failed_obstacle.row and col == failed_obstacle.col then
					table.insert(line_parts, RED .. "#" .. RESET)
				elseif last_added_obstacle and row == last_added_obstacle.row and col == last_added_obstacle.col then
					table.insert(line_parts, RED .. "#" .. RESET)
				elseif symbol == "o" then
					table.insert(line_parts, YELLOW .. "o" .. RESET)
				else
					if symbol == "." then symbol = " " end
					table.insert(line_parts, symbol)
				end
			else
				-- During search visualization
				if last_added_obstacle and row == last_added_obstacle.row and col == last_added_obstacle.col then
					table.insert(line_parts, RED .. "#" .. RESET)
				elseif symbol == "." or symbol == "S" or symbol == "E" or symbol == "#" then
					if start_set[pos_str] and goal_set[pos_str] then
						table.insert(line_parts, GREEN .. "o" .. RESET)
					elseif start_set[pos_str] then
						table.insert(line_parts, GREEN .. "o" .. RESET)
					elseif goal_set[pos_str] then
						table.insert(line_parts, RED .. "x" .. RESET)
					else
						if symbol == "." then symbol = " " end
						-- If it's an obstacle and final is not true, just show it normally
						if symbol == "#" then
							line_parts[#line_parts + 1] = "#"
						else
							line_parts[#line_parts + 1] = symbol
						end
					end
				else
					-- obstacle or final S/E
					line_parts[#line_parts + 1] = symbol
				end
			end
		end
		table.insert(lines, table.concat(line_parts))
	end
	return table.concat(lines, "\n")
end


local function printGridWithPaths(path_from_start, path_from_goal, final)
	io.write("\27[2J\27[H")
	io.write(buildGridString(path_from_start, path_from_goal, final))
	io.write("\n")
	io.flush()
	os.execute("sleep 0.001")
end

local function bidirectionalAStar()
	clearState()

	local start_h = calcDistance(start_row, start_col, end_row, end_col)
	pushNode(frontier_start, start_row, start_col, 0, start_h, nil, parents_start)
	markVisited(visited_from_start, start_row, start_col)

	local goal_h = calcDistance(end_row, end_col, start_row, start_col)
	pushNode(frontier_goal, end_row, end_col, 0, goal_h, nil, parents_goal)
	markVisited(visited_from_goal, end_row, end_col)

	while #frontier_start > 0 and #frontier_goal > 0 do
		table.sort(frontier_start, function(a, b) return a.f < b.f end)
		table.sort(frontier_goal, function(a, b) return a.f < b.f end)

		-- Expand from start side
		local current_start = table.remove(frontier_start, 1)
		local sr, sc = current_start.row, current_start.col
		local sg = current_start.g
		for _, nbr in ipairs(neighbors(sr, sc)) do
			if not isVisited(visited_from_start, nbr.r, nbr.c) then
				local ng = sg + 1
				local nh = calcDistance(nbr.r, nbr.c, end_row, end_col)
				pushNode(frontier_start, nbr.r, nbr.c, ng, nh, sr .. "," .. sc, parents_start)
				markVisited(visited_from_start, nbr.r, nbr.c)
				if isVisited(visited_from_goal, nbr.r, nbr.c) then
					-- Path found!
					local final_path = reconstructFullPath(nbr.r, nbr.c)
					-- Mark final path on map
					for _, node in ipairs(final_path) do
						local r, c = node:match("(%d+),(%d+)")
						r, c = tonumber(r), tonumber(c)
						if map[r][c] ~= "S" and map[r][c] ~= "E" then
							map[r][c] = "o"
						end
					end
					printGridWithPaths(nil, nil, true)
					return final_path
				end
			end
		end
		local path_from_start_side = reconstructPartialPath(parents_start, sr, sc)

		-- Expand from goal side
		local current_goal = table.remove(frontier_goal, 1)
		local gr, gc = current_goal.row, current_goal.col
		local gg = current_goal.g
		for _, nbr in ipairs(neighbors(gr, gc)) do
			if not isVisited(visited_from_goal, nbr.r, nbr.c) then
				local ng = gg + 1
				local nh = calcDistance(nbr.r, nbr.c, start_row, start_col)
				pushNode(frontier_goal, nbr.r, nbr.c, ng, nh, gr .. "," .. gc, parents_goal)
				markVisited(visited_from_goal, nbr.r, nbr.c)
				if isVisited(visited_from_start, nbr.r, nbr.c) then
					-- Path found!
					local final_path = reconstructFullPath(nbr.r, nbr.c)
					for _, node in ipairs(final_path) do
						local r, c = node:match("(%d+),(%d+)")
						r, c = tonumber(r), tonumber(c)
						if map[r][c] ~= "S" and map[r][c] ~= "E" then
							map[r][c] = "o"
						end
					end
					printGridWithPaths(nil, nil, true)
					return final_path
				end
			end
		end
		local path_from_goal_side = reconstructPartialPath(parents_goal, gr, gc)

		-- Print current step (can comment out if not needed)
		printGridWithPaths(path_from_start_side, path_from_goal_side, false)
	end

	return nil
end

local function main()
	local input = readFile("input.txt")
	parseInput(input)

	initializeMap()

	-- Insert the first 1024 obstacles initially
	local initial_obstacles = 1024
	for i = 1, initial_obstacles do
		local obs = obstacles[i]
		map[obs.row][obs.col] = "#"
	end

	-- Check if a path exists after inserting the first 1024 obstacles
	local path = bidirectionalAStar()
	if not path then
		print("No path exists after inserting the first 1024 obstacles.")
		printGridWithPaths(nil, nil, true)
		return
	end

	initializeMap()
	for j = 1, initial_obstacles do
		local o = obstacles[j]
		map[o.row][o.col] = "#"
	end

	-- Insert the remaining obstacles one by one and check for a path each time
	for i = initial_obstacles + 1, #obstacles do
		local obs = obstacles[i]
		map[obs.row][obs.col] = "#"
		last_added_obstacle = obs -- Track the last added obstacle

		-- Check if the current path is blocked
		local blocked = false
		for _, pos in ipairs(path) do
			local r, c = pos:match("(%d+),(%d+)")
			r, c = tonumber(r), tonumber(c)
			if map[r][c] == "#" then
				blocked = true
				break
			end
		end

		if blocked then

			initializeMap()
			for j = 1, i do
				local o = obstacles[j]
				map[o.row][o.col] = "#"
			end

			-- Attempt to find path again
			path = bidirectionalAStar()

			if not path then
				-- No path after inserting this obstacle
				failed_obstacle = obs
				failed_line_number = i
				printGridWithPaths(nil, nil, true)

				-- Print details
				print("The obstacle inserted at line " ..
					failed_line_number .. " (" .. obs.row .. "," .. obs.col .. ") blocked the last possible path.")
				return
			else
				-- A path still exists, continue
				-- Clear the final path marks ('o') so the next attempt starts clean
				-- We only keep the obstacles. Also reset the map start/end markers.
				initializeMap()
				for j = 1, i do
					local o = obstacles[j]
					map[o.row][o.col] = "#"
				end
			end
		end

		for _, node in ipairs(path) do
			local r, c = node:match("(%d+),(%d+)")
			r, c = tonumber(r), tonumber(c)
			if map[r][c] ~= "S" and map[r][c] ~= "E" then
				map[r][c] = "o"
			end
		end
		-- No need to check path, just update the map
		printGridWithPaths(nil, nil, true)
		os.execute("sleep 0.005")
	end

	-- If we reach here, no obstacle blocked the path completely
	print("All obstacles inserted, but a path still exists.")
end

main()
