-- // SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local UIS = game:GetService("UserInputService")
-- // OBJECTS
local Player = Players.LocalPlayer
local Character = Player.Character
local Humanoid = Character.Humanoid
local HRP = Character.HumanoidRootPart
local HRP2 = HRP:Clone()
-- // VARIABLES
_G.Settings = _G.Settings or {}
_G.Connections = _G.Connections or {}
local OldPos
local rad = math.rad
-- // MAIN
_G.Settings = {
	HeadName = _G.Settings.HeadName or "MediHood",
	HeadOffset = _G.Settings.HeadOffset or CFrame.new(Vector3.new(0, .125, .25)),
	RemoveHeadMesh = _G.Settings.RemoveHeadMesh or false,
}
assert(not Character:FindFirstChild(Player.UserId), [[\n["NETLESS-R6-BOT.LUA"]: Please reset to be able to run the script again!]])
assert(Humanoid.RigType == Enum.HumanoidRigType.R6, [[\n["NETLESS-R6-BOT.LUA"]: Sorry, This script will only work on R6 character rig only!]])
for _, connection in ipairs(_G.Connections) do connection:Disconnect() end _G.Connections = {}
local BodyParts = {
	["Head"] = Character:FindFirstChild(_G.Settings.HeadName),
	["Torso"] = Character:FindFirstChild("SeeMonkey"),
	["Torso1"] = Character:FindFirstChild("Robloxclassicred"),
	["Torso2"] = Character:FindFirstChild("LavanderHair"),
	["Left Arm"] = Character:FindFirstChild("Left Arm"),
	["Right Arm"] = Character:FindFirstChild("Right Arm"),
	["Left Leg"] = Character:FindFirstChild("Left Leg"),
	["Right Leg"] = Character:FindFirstChild("Right Leg")
}

local DummyChar = game:GetObjects("rbxassetid://6843243348")[1]
DummyChar.Name, DummyChar.Parent = Player.UserId, Character
OldPos = Character:GetPrimaryPartCFrame()

for _, object in ipairs(DummyChar:GetChildren()) do if object:IsA("BasePart") then object.Transparency = 1 end end
for _, object in ipairs(Character.Torso:GetChildren()) do
	if object:IsA("Motor6D") and object.Name ~= "Neck" then
		object:Destroy()
	end
end
for PartName, object in pairs(BodyParts) do
	if object:IsA("Accessory") and object:FindFirstChild("Handle") then
		object.Handle:FindFirstChildWhichIsA("Weld"):Destroy()
		if PartName == "Head" and _G.Settings.RemoveHeadMesh then
			object.Handle:FindFirstChildWhichIsA("SpecialMesh"):Destroy()
		elseif PartName ~= "Head" then
			object.Handle:FindFirstChildWhichIsA("SpecialMesh"):Destroy()
		end
	end
end

workspace.FallenPartsDestroyHeight = 0 / 1 / 0
HRP.CFrame = CFrame.new(Vector3.new(0, 10e10, 0))
HRP.Anchored = true
Character.Animate.Disabled = true
Character.Animate.Parent = DummyChar
Humanoid.Animator:Clone().Parent = DummyChar.Humanoid
DummyChar.Parent = Character
DummyChar.Animate.Disabled = false
DummyChar:SetPrimaryPartCFrame(OldPos)
Player.Character = DummyChar

_G.Connections[#_G.Connections + 1] = RunService.Heartbeat:Connect(function()
	for PartName, object in next, BodyParts do
		if object then
			if object:IsA("Accessory") and object:FindFirstChild("Handle") then
				object.Handle.LocalTransparencyModifier = DummyChar.Head.LocalTransparencyModifier
				if PartName == "Head" then
					object.Handle.CFrame = DummyChar.Head.CFrame * _G.Settings.HeadOffset
				elseif PartName == "Torso" then
					object.Handle.CFrame = DummyChar.Torso.CFrame * CFrame.Angles(rad(90), 0, 0)
				elseif PartName == "Torso1" then
					object.Handle.CFrame = DummyChar.Torso.CFrame * CFrame.new(Vector3.new(0, .5, 0)) * CFrame.Angles(0, rad(90), 0)
				elseif PartName == "Torso2" then
					object.Handle.CFrame = DummyChar.Torso.CFrame * CFrame.new(Vector3.new(0, -.5, 0)) * CFrame.Angles(0, rad(90), 0)
				end
			elseif object:IsA("BasePart") then
				object.LocalTransparencyModifier = DummyChar.Head.LocalTransparencyModifier
				object.CFrame = DummyChar[object.Name].CFrame
			end
		end
	end
end)

_G.Connections[#_G.Connections + 1] = RunService.Stepped:Connect(function()
	settings().Physics.AllowSleep = false
	settings().Physics.PhysicsEnvironmentalThrottle = Enum.EnviromentalPhysicsThrottle.DefaultAuto
	settings().Physics.ThrottleAdjustTime = 0 / 1 / 0

	for _, object in pairs(BodyParts) do
		if object then
			if object:IsA("Accessory") and object:FindFirstChild("Handle") then
				object.Handle.Velocity = Vector3.new(-30, -30, -30)
				object.Handle.RotVelocity = Vector3.new()
			elseif object:IsA("BasePart") then
				object.Velocity = Vector3.new(-30, -30, -30)
				object.RotVelocity = Vector3.new()
			end
		end
	end

	workspace.CurrentCamera.CameraSubject = DummyChar.Humanoid
end)

if not _G.PlayerResetConnection then
	local ResetBindable = Instance.new("BindableEvent")
	_G.PlayerResetConnection = ResetBindable.Event:Connect(function()
		for _, connection in ipairs(_G.Connections) do connection:Disconnect() end _G.Connections = {}
		Player.Character = Player.Character.Parent
		Player.Character:BreakJoints()
		Player.Character.Parent = nil
		Player.Character = Player.Character[Player.UserId]
	end)
	StarterGui:SetCore("ResetButtonCallback", ResetBindable)
end

StarterGui:SetCore("SendNotification", {
	Title = "REANIMATE",
	Text = "REANIMATE is now ready!\nThanks for using the script!\n",
	Cooldown = 1
})