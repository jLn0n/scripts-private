-- // SERVICES
local Players = game:GetService("Players")
-- // OBJECTS
local Player = Players.LocalPlayer
local Character = Player.Character
-- // MAIN
Character:BreakJoints()
for _, object in ipairs(Character:GetChildren()) do
	if object:IsA("Accessory") then
		local accHandle = object.Handle
		accHandle.CanCollide = true
		accHandle.Massless = true
		object.Parent = workspace.Terrain
	elseif object:IsA("BasePart") then
		object:Destroy()
	end
end