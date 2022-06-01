--[[
	TODO:
	* BUG #1:
		global funcs that are created in as executor closure should not be returned (it currently doesn't do that)
--]]

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
		local funcName = (func and debug.info(func, "n") or "")
		if ((func and not is_fluxus_closure(func)) and (funcName ~= "")) then -- BUG #1
			funcCaller = func
			break
		end
	end
	return funcCaller
end

--Gets the script that is calling the function
---@return LocalScript | ModuleScript
local function getcallingscript()
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
