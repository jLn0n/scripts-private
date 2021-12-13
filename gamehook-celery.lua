-- services
local insertService = game:GetService("InsertService")
-- variables
local gameMt = getrawmetatable(game)
local oldIndex, oldNamecall = gameMt.__index, gameMt.__namecall
-- main
setreadonly(gameMt, false)
gameMt.__index = function(...)
	if checkcaller() then
		local args = {...}
		local nameIndex = args[2]
		if nameIndex == "HttpGet" then
			return httpget(args[3], args[4])
		elseif nameIndex == "GetObjects" then
			return {insertService:LoadLocalAsset(args[3])}
		end
	end
	return oldIndex(...)
end
gameMt.__namecall = function(...)
	if checkcaller() then
		local args = {...}
		local namecallMethod = getnamecallmethod()
		if namecallMethod == "HttpGet" then
			return httpget(args[2], args[3])
		elseif namecallMethod == "GetObjects" then
			return {insertService:LoadLocalAsset(args[2])}
		end
	end
	return oldNamecall(...)
end
setreadonly(gameMt, true)
