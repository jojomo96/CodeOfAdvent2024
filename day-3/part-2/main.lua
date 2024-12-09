-- Open and read the entire file contents
local file = io.open("input.txt", "r")
if not file then
    error("Could not open file 'index.txt'")
end

local s = file:read("*all")
file:close()

local active = true
local pos = 1
local count_do = 0
local count_dont = 0
local count_mul = 0

local sum_of_mul = 0

while true do
    -- Find the next occurrences of each pattern after 'pos'
    local doStart, doEnd = string.find(s, "do%(%)", pos)
    local dontStart, dontEnd = string.find(s, "don't%(%)", pos)
    local mulStart, mulEnd, arg1, arg2 = string.find(s, "mul%((%d%d?%d?),%s*(%d%d?%d?)%)", pos)

    -- If none are found, we're done
    if not doStart and not dontStart and not mulStart then
        break
    end

    -- Determine which pattern occurs next in the string
    local nextEventType
    local nextEventStart, nextEventEnd = math.huge, math.huge
    local nextArg1, nextArg2

    if doStart and doStart < nextEventStart then
        nextEventType = "do"
        nextEventStart, nextEventEnd = doStart, doEnd
    end
    if dontStart and dontStart < nextEventStart then
        nextEventType = "dont"
        nextEventStart, nextEventEnd = dontStart, dontEnd
    end
    if mulStart and mulStart < nextEventStart then
        nextEventType = "mul"
        nextEventStart, nextEventEnd = mulStart, mulEnd
        nextArg1, nextArg2 = arg1, arg2
    end

    -- Process the found event
    if nextEventType == "do" then
        -- Switch on processing
        count_do = count_do + 1
        active = true
    elseif nextEventType == "dont" then
        -- Switch off processing
        active = false
        count_dont = count_dont + 1
    elseif nextEventType == "mul" then
        -- Process mul only if active
        count_mul = count_mul + 1
        if active then
            print("Processing mul with args:", nextArg1, nextArg2)
            sum_of_mul = sum_of_mul + tonumber(nextArg1) * tonumber(nextArg2)
        end
    end

    -- Move past this occurrence
    pos = nextEventEnd + 1
end

print(sum_of_mul)
print(count_do)
print(count_dont)
print(count_mul)
