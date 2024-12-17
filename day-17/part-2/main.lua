-- Function to read the file content
local function readFile(filename)
    local file = io.open(filename, "r")
    if not file then
        error("Could not open file " .. filename)
    end
    local content = file:read("*all")
    file:close()
    return content
end

-- Function to parse the content
local function parseContent(content)
    local A, B, C
    local program = {}

    for line in content:gmatch("[^\r\n]+") do
        if line:match("Register") then
            local reg, value = line:match("Register (%a): (%d+)")
            value = tonumber(value)
            if reg == "B" then
                B = value
            elseif reg == "C" then
                C = value
            end
        elseif line:match("Program") then
            local programLine = line:match("Program: (.+)")
            for num in programLine:gmatch("%d+") do
                table.insert(program, tonumber(num))
            end
        end
    end
    A = 0
    return A, B, C, program
end

-- Helper function to get combo operand value
local function getComboValue(operand, A, B, C)
    -- 0-3: literal 0-3
    -- 4: value of A
    -- 5: value of B
    -- 6: value of C
    -- 7: reserved (should not appear)
    if operand <= 3 then
        return operand
    elseif operand == 4 then
        return A
    elseif operand == 5 then
        return B
    elseif operand == 6 then
        return C
    else
        error("Invalid combo operand 7 encountered.")
    end
end

local function executeProgram(A, B, C, program)
    local IP = 0
    local outputValues = {}

    local function adv(operand)
        local denom = 2 ^ getComboValue(operand, A, B, C)
        A = math.floor(A / denom)
    end

    local function bxl(operand)
        -- operand is literal
        B = B ~ operand
    end

    local function bst(operand)
        B = getComboValue(operand, A, B, C) % 8
    end

    local function jnz(operand)
        -- operand is literal
        if A ~= 0 then
            IP = operand
            return true -- indicate jump
        end
    end

    local function bxc(operand)
        -- ignore operand
        B = B ~ C
    end

    local function outInstruction(operand)
        local val = getComboValue(operand, A, B, C) % 8
        table.insert(outputValues, val)
    end

    local function bdv(operand)
        local denom = 2 ^ getComboValue(operand, A, B, C)
        B = math.floor(A / denom)
    end

    local function cdv(operand)
        local denom = 2 ^ getComboValue(operand, A, B, C)
        C = math.floor(A / denom)
    end

    local opcodeFuncs = {
        [0] = adv,
        [1] = bxl,
        [2] = bst,
        [3] = jnz,
        [4] = bxc,
        [5] = outInstruction,
        [6] = bdv,
        [7] = cdv
    }

    while true do
        if IP >= #program then
            break -- halt
        end

        local opcode = program[IP + 1]
        if not opcode then break end
        local operand = program[IP + 2]
        if operand == nil then
            break
        end

        local func = opcodeFuncs[opcode]
        if not func then
            error("Unknown opcode: " .. opcode)
        end

        local jumped = func(operand)
        if opcode ~= 3 or not jumped then
            IP = IP + 2
        end
    end

    return outputValues
end

local function isProgrammTheSame(program1, program2)
    if #program1 ~= #program2 then
        return false
    end

    for i = 1, #program1 do
        if program1[i] ~= program2[i] then
            return false
        end
    end

    return true
end

local function findAssosoatedProgramm(A, B, C, targetProgram)
    local counter = 0
    while true do
        if isProgrammTheSame(executeProgram(A, B, C, targetProgram), targetProgram) then
            break
        end

        A = A + 1
        counter = counter + 1
        if counter % 10000 == 0 then
            print(A)
        end
    end
    return A
end

-- Main function
local function main()
    local filename = "input.txt"
    local content = readFile(filename)
    local A, B, C, targetProgram = parseContent(content)

    local result = findAssosoatedProgramm(A, B, C, targetProgram)
    print(result)
end

main()
