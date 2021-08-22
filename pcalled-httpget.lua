local game_namecall, httpGet
local oldHttpGet = game.HttpGet
local checkIfCallingHttpGet = function(namecallMethod)
	namecallMethod = string.lower(namecallMethod)
	return namecallMethod == "httpget" or namecallMethod == "httpgetasync"
end
httpGet = hookfunction(game.HttpGet, function(...)
	local tries, args = 0, table.create(1, ...)
	spawn(function()
		local succ, result
		print("pcall start")
		repeat
			succ, result = pcall(httpGet, game, table.unpack(args))
			tries = (not succ and tries <= 5) and tries + 1 or tries
		until succ or tries >= 5
		print("pcall finished", succ)
		return succ and result or warn(result)
	end)
end)
print(httpGet, oldHttpGet, httpGet ~= oldHttpGet, httpGet == oldHttpGet)
--[[
game_namecall = hookmetamethod(game, "__namecall", function(self, ...)
	local callingHttpGet = checkIfCallingHttpGet(getnamecallmethod())
	if (self == game and callingHttpGet and checkcaller()) then
		return game.HttpGet(self, ...)
	else
		return game_namecall(self, ...)
	end
end)
--]]
