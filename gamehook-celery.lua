local insertService = game:GetService("InsertService");

local gameMt = getrawmetatable(game);
local gameRealIndex = gameMt.__index;
local gameRealNameCall = gameMt.__namecall;

setreadonly(gameMt, false);

gameMt.__index = function(...)
	local args = {...}
	local nameIndex = args[2]
	if nameIndex == "HttpGet" then
		local url, isAsync = args[3], args[4]
		return httpget(url, isAsync)
	elseif nameIndex == "GetObjects" then
		return { insertService:LoadLocalAsset(args[3]) }
	end
	return gameRealIndex(...);
end

gameMt.__namecall = function(...)
	if checkcaller() then
		local args = {...}
		local namecallMethod = getnamecallmethod();
		if namecallMethod == "HttpGet" then
			return httpget(args[1], args[2])
		elseif namecallMethod == "GetObjects" then
			return {insertService:LoadLocalAsset(args[1])}
		end
	end
	return gameRealNameCall(...);
end

setreadonly(gameMt, true);
