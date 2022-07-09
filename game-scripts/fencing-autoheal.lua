-- services
local players = game:GetService("Players")
-- objects
local player = players.LocalPlayer
local character = player.Character
local button = workspace.Button
local partIdk
-- main
while true do task.wait()
	character = player.Character or nil
	partIdk = character and character:FindFirstChild("Torso") or nil
	if partIdk then
		firetouchinterest(partIdk, button, 0)
		firetouchinterest(partIdk, button, 1)
	end
end
