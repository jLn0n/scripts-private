--[[
	TODO:
	* BUG #1: (fixed)
		global funcs that are created in as executor closure should not be returned (it currently doesn't do that)
	
--]]
--Returns the instance from the string path
---@param strPath string
---@return Instance | nil
local function stringPathToInstance(strPath: string)
	local pathSplit = string.split(strPath, ".")
	local result = game
	for _, path in ipairs(pathSplit) do
		result = (if result then result:FindFirstChild(path) else nil)
	end
	return result
end

--Gets the function that is calling the function that is hooked
---@param indexLvlStart number
---@return function
local function getcallingfunction(indexLvlStart: number)
	indexLvlStart = indexLvlStart or 10
	local funcCaller
	for indexLvl = indexLvlStart, 0, -1 do
		local func = debug.info(indexLvl, "f")
		local funcSource = (func and debug.info(func, "s") or nil)
		if ((func and (stringPathToInstance(funcSource) or not isourclosure(func)))) then
			funcCaller = func
			break
		end
	end
	return funcCaller
end

--Gets the script that is calling the function
---@return LocalScript | ModuleScript | nil
local function getcallingscript()
	local funcCaller = getcallingfunction()
	if funcCaller then return stringPathToInstance(debug.info(funcCaller, "s")) end
	for indexLvl = 10, 0, -1 do
		local strResult = string.match(debug.traceback("", indexLvl), "%w+:[%d%s]+$")
		if strResult then
			local strPath = string.split(strResult, ":")[1]
			local object = stringPathToInstance(strPath)
			if object and object:IsA("LuaSourceContainer") then
				return object
			end
		end
	end
	return nil
end
-- examples:

local function test()
	local funcCaller, scriptCaller = getcallingfunction(), getcallingscript()
	print(debug.info(funcCaller, "n"), scriptCaller) -- this will print the function name
end

local function icallthetestfunc()
	test()
end
icallthetestfunc()
