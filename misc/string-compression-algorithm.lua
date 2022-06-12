-- variables
local stringList = "qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM1234567890"
-- functions
local function generateRandString(lenght)
	if lenght < 1 then return end
	local result = ""
	for iter = 1, lenght do
		local randInteger = math.random(1, (iter == 1 and #stringList - 10 or #stringList))
		result ..= string.sub(stringList, randInteger, randInteger)
	end
	return result
end

local function compressStr(stringArg)
	local output = ""
	local index = 1
	local function genCharVal()
		local result = ""
		local randInt = math.random(1, 4)
		local charIndex = string.byte(stringArg, index, index) --string.char(string.sub(stringArg, index, index))
		result ..= tostring(randInt)
		result ..= generateRandString(randInt) or ""
		result ..= string.char(charIndex - randInt)
		return result
	end
	output ..= genCharVal()
	while index < #stringArg do
		index += 1
		output ..= genCharVal()
	end
	return output
end

local function decompressStr(stringArg)
	local L_29_, L_30_, tableResult = "", "", {}
	local charIndexEnd = 256
	local charVars = {}
	for index = 0, charIndexEnd - 1 do
		charVars[index] = string.char(index)
	end
	local i_getCharVal = 1
	local function getCharVal()
		local n1 = tonumber(string.sub(stringArg, i_getCharVal, i_getCharVal), 36)
		i_getCharVal += 1
		local n2 = tonumber(string.sub(stringArg, i_getCharVal, ((i_getCharVal + n1) - 1)), 36)
		i_getCharVal += n1
		print(n1, n2, i_getCharVal)
		return n2
	end
	L_29_ = string.char(getCharVal())
	tableResult[1] = L_29_
	while i_getCharVal < #stringArg do
		local charVal = getCharVal()
		if charVars[charVal] then
			L_30_ = charVars[charVal]
		else
			L_30_ = L_29_ .. string.sub(L_29_, 1, 1)
		end
		charVars[charIndexEnd] = L_29_ .. string.sub(L_30_, 1, 1)
		tableResult[#tableResult + 1], L_29_, charIndexEnd = L_30_, L_30_, charIndexEnd + 1
	end
	return table.concat(tableResult)
end
-- main
local compressedStr = compressStr([[print("Hello World!")]])
-- "1J1H2751J1K2751H22P22R23C23J22T1J27427522H23C1L2791327L2751G27M1N1H27Q27H2751M27927427Q1H1I279280279279"
local decompressedStr = decompressStr(compressedStr)
print(compressStr, decompressedStr)