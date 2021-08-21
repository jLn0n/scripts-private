local game_namecall
local oldHttpGet = game.HttpGet
local httpGetPcall = function(...)
	local tries = 0
	local succ, result
	while (not succ and tries ~= 5) do
		succ, result = pcall(oldHttpGet, game, ...)
		if (not succ and tries ~= 5) then
			tries += 1
		elseif succ or (succ and tries == 5) then
			break
		end
	end
	return succ and result or warn(result)
end
game_namecall = hookmetamethod(game, "__namecall", function(self, ...)
	local args = table.pack(...)
	local namecallMethod = getnamecallmethod()
	if (self == game and string.match(string.lower(namecallMethod), "httpget") and checkcaller()) then
		local result = httpGetPcall(unpack(args))
		return result
	else
		return game_namecall(self, ...)
	end
end)
