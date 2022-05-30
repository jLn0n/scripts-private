--[[
	Gets the function that is calling the function that is hooked

	```lua
	local function test()
		local funcCaller = getcallingfunc()
		print(debug.info(lmao, "n")) -- this will print the function name of the caller
	end
	test()
	```
--]]
local function getcallingfunc(indexLvl: number)
	indexLvl = indexLvl or 3
	local func = debug.info(indexLvl, "f")
	return (func or nil)
end

--[[
	Gets the script that is calling the function

	```lua
	local function test()
		local scriptCaller = getcallingscript()
		print(scriptCaller.Name) -- this will print the script name of the caller
	end
	test()
	```
--]]
local function getcallingscript(indexLvl: number): LuaSourceContainer
	indexLvl = indexLvl or 3
	local func = debug.info(indexLvl, "f")
	return (func and rawget(getfenv(func), "script") or nil)
end

-- examples:

local function test()
	local funcCaller, scriptCaller = getcallingfunc(), getcallingscript()
	print(debug.info(funcCaller, "n"), scriptCaller.Name) -- this will print the function name
end

local function icallthetestfunc()
	test()
end
icallthetestfunc()
