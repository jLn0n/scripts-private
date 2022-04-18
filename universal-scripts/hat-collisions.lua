-- services
local players = game:GetService("Players")
-- objects
local player = players.LocalPlayer
local character = player.Character
-- variables
local destroyFunc = character.Destroy
-- main
player.Character = nil
player.Character = character
task.wait(players.RespawnTime + .05)

task.defer(character.BreakJoints, character)
task.spawn(destroyFunc, (character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")))
task.spawn(destroyFunc, character.HumanoidRootPart)

for _, object in ipairs(character:GetChildren()) do
	if object:IsA("Accoutrement") then
		sethiddenproperty(object, "BackendAccoutrementState", 0)
		destroyFunc(object:FindFirstChildWhichIsA("MeshPart", true) or object:FindFirstChildWhichIsA("SpecialMesh", true))
	elseif object:IsA("BasePart") and object.Name ~= "Head" then
		destroyFunc(object)
	end
end
