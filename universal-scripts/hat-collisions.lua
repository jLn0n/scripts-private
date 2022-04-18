-- services
local players = game:GetService("Players")
local starterGui = game:GetService("StarterGui")
-- objects
local player = players.LocalPlayer
local character = player.Character
local resetBindable = Instance.new("BindableEvent")
-- variables
local destroyFunc, resetBindableConnection = character.Destroy, nil
-- main
player.Character = nil
player.Character = character
task.wait(players.RespawnTime + .05)

destroyFunc(character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso"))
destroyFunc(character.HumanoidRootPart)

for _, object in ipairs(character:GetChildren()) do
	if object:IsA("Accoutrement") then
		sethiddenproperty(object, "BackendAccoutrementState", 0)
		destroyFunc(object:FindFirstChildWhichIsA("MeshPart", true) or object:FindFirstChildWhichIsA("SpecialMesh", true))
	elseif object:IsA("BasePart") and object.Name ~= "Head" then
		destroyFunc(object)
	end
end

resetBindableConnection = resetBindable.Event:Connect(function()
	starterGui:SetCore("ResetButtonCallback", true)
	resetBindableConnection:Disconnect()
	local daModel = Instance.new("Model")
	local _daModelHumanoid = Instance.new("Humanoid")
	_daModelHumanoid.Parent = daModel
	player.Character = daModel
end)
starterGui:SetCore("ResetButtonCallback", resetBindable)
