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
	partIdk = character and character:FindFirstChild("HumanoidRootPart") or nil
	if torso then
		firetouchinterest(torso, button, 0)
		firetouchinterest(torso, button, 1)
	end
end
