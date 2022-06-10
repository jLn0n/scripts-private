if game.PlaceId ~= 391104146 then return end
-- services
local logService = game:GetService("LogService")
local players = game:GetService("Players")
-- objects
local player = players.LocalPlayer
local getIP_Script = player.PlayerScripts:FindFirstChild("GetIP")
-- variables
local oldNamecall
local funcENV = getfenv(getsenv(getIP_Script).start)
-- main
for _, connection in ipairs(getconnections(logService.MessageOut)) do
	connection:Disable()
end
funcENV.tick = function()
	return 1
end
oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
	local namecallMethod = getnamecallmethod()

	if not checkcaller() then
		if (self.Name == "\32\32\32\32\32\32" and namecallMethod == "InvokeServer") then
			return
		elseif (self == player and namecallMethod == "Kick") then
			return task.wait(9e9)
		end
	end
	return oldNamecall(self, ...)
end))