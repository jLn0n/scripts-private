-- services
local insertService = game:GetService("InsertService")
-- variables / functions
local gameMt = getrawmetatable(game)
local oldIndex, oldNamecall = gameMt.__index, gameMt.__namecall
local loadLocalAsset = function(...)
	return {insertService.LoadLocalAsset(insertService, ...)}
end
local function newcclosure(...)
	return ...
end
-- main
setreadonly(gameMt, false)
gameMt.__index = newcclosure(function(...)
	local self, indexKey = select(1, ...)
	if self == game and checkcaller() then
		if indexKey == "HttpGet" then
			return httpget
		elseif indexKey == "GetObjects" then
			return loadLocalAsset
		end
	end
	return oldIndex(...)
end)
gameMt.__namecall = newcclosure(function(...)
	local self, arg1, arg2 = select(1, ...)
	local namecallMethod = getnamecallmethod()
	if self == game and checkcaller() then
		if namecallMethod == "HttpGet" then
			return httpget(arg1, arg2)
		elseif namecallMethod == "GetObjects" then
			return loadLocalAsset(arg1)
		end
	end
	return oldNamecall(...)
end)
setreadonly(gameMt, true)
