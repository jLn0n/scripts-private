-- // SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
-- // OBJECTS
local Player = Players.LocalPlayer
local Character = Player.Character
local Humanoid = Character.Humanoid
local HRP = Character.HumanoidRootPart
-- // VARIABLES
_G.Settings = _G.Settings or {}
_G.Connections = _G.Connections or {}
local rad = math.rad
-- // MAIN
_G.Settings = {
	HeadName = _G.Settings.HeadName or "MediHood",
	HeadOffset = _G.Settings.HeadOffset or CFrame.new(Vector3.new(0, .125, .25)),
	RemoveHeadMesh = _G.Settings.RemoveHeadMesh or false,
}
assert(not Character:FindFirstChild(Player.UserId), [[\n["NETLESS-R6-BOT.LUA"]: Please reset to be able to run the script again!]])
assert(Humanoid.RigType == Enum.HumanoidRigType.R6, [[\n["NETLESS-R6-BOT.LUA"]: Sorry, This script will only work on R6 character rig only!]])

local HatParts = {
	["Head"] = Character:FindFirstChild(_G.Settings.HeadName),
	["Left Arm"] = Character:FindFirstChild("Pal Hair"),
	["Right Arm"] = Character:FindFirstChild("Hat1"),
	["Left Leg"] = Character:FindFirstChild("Pink Hair"),
	["Right Leg"] = Character:FindFirstChild("Kate Hair"),
	["Torso"] = Character:FindFirstChild("SeeMonkey"),
	["Torso1"] = Character:FindFirstChild("Robloxclassicred"),
	["Torso2"] = Character:FindFirstChild("LavanderHair"),
}

local onCharRemoved = function()
	for _, connection in ipairs(_G.Connections) do connection:Disconnect() end _G.Connections = {}
	Player.Character = Player.Character.Parent
	Player.Character:BreakJoints()
	Player.Character:Destroy()
	Player.Character = nil
end

workspace.FallenPartsDestroyHeight = 0 / 1 / 0
HRP.Anchored = true
Character.Parent = nil
Character.Head.face.Transparency = 1
HRP.Parent = nil
HRP.Parent = Character
HRP.Anchored = false
Character.Parent = workspace

for _, connection in ipairs(_G.Connections) do connection:Disconnect() end _G.Connections = {}
for _, object in ipairs(Character:GetChildren()) do if object:IsA("BasePart") then object.Transparency = 1 end end
for PartName, object in pairs(HatParts) do
	if object and object:FindFirstChild("Handle") then
		object.Handle:FindFirstChildWhichIsA("Weld"):Destroy()
		if PartName == "Head" and _G.Settings.RemoveHeadMesh then
			object.Handle:FindFirstChildWhichIsA("SpecialMesh"):Destroy()
		elseif PartName ~= "Head" then
			object.Handle:FindFirstChildWhichIsA("SpecialMesh"):Destroy()
		end
	end
end

_G.Connections[#_G.Connections + 1] = RunService.Stepped:Connect(function()
	settings().Physics.AllowSleep = false
	settings().Physics.PhysicsEnvironmentalThrottle = Enum.EnviromentalPhysicsThrottle.DefaultAuto
	settings().Physics.ThrottleAdjustTime = 0 / 0

	for _, object in pairs(HatParts) do
		if object and object:FindFirstChild("Handle") then
			object.Handle.Velocity = Vector3.new(-30, -30, -30)
			object.Handle.RotVelocity = Vector3.new()
		end
	end
end)

_G.Connections[#_G.Connections + 1] = RunService.Heartbeat:Connect(function()
	for PartName, object in pairs(HatParts) do
		if object and object:IsA("Accessory") and object:FindFirstChild("Handle") then
			object.Handle.LocalTransparencyModifier = Character.Head.LocalTransparencyModifier
			if PartName == "Head" then
				object.Handle.CFrame = Character.Head.CFrame * _G.Settings.HeadOffset
			elseif PartName == "Torso" then
				object.Handle.CFrame = Character.Torso.CFrame * CFrame.Angles(rad(90), 0, 0)
			elseif PartName == "Torso1" then
				object.Handle.CFrame = Character.Torso.CFrame * CFrame.new(Vector3.new(0, .5, 0)) * CFrame.Angles(0, rad(90), 0)
			elseif PartName == "Torso2" then
				object.Handle.CFrame = Character.Torso.CFrame * CFrame.new(Vector3.new(0, -.5, 0)) * CFrame.Angles(0, rad(90), 0)
			else
				object.Handle.CFrame = Character[PartName].CFrame * CFrame.Angles(rad(90), 0, 0)
			end
		end
	end
end)

_G.Connections[#_G.Connections + 1] = Humanoid.Died:Connect(onCharRemoved)
_G.Connections[#_G.Connections + 1] = Player.CharacterRemoving:Connect(onCharRemoved)

StarterGui:SetCore("SendNotification", {
	Title = "REANIMATE",
	Text = "REANIMATE is now ready!\nThanks for using the script!\n",
	Cooldown = 1
})
