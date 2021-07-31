-- // INIT (maybe _G detection bypass lol)
getgenv()._G = #getgenv()._G == 0 and {["Settings"] = _G.Settings or {}, ["Connections"] = _G.Connections or {}} or getgenv()._G
-- // SERVICES
local InsertService = game:GetService("InsertService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
-- // OBJECTS
local Player = Players.LocalPlayer
local Character = Player.Character
local Humanoid = Character.Humanoid
local HRP = Character.HumanoidRootPart
-- // VARIABLES
_G.Settings = {
	["HeadName"] = _G.Settings.HeadName or "MediHood",
	["HeadOffset"] = _G.Settings.HeadOffset or CFrame.new(Vector3.new(0, .125, .25)),
	["RemoveHeadMesh"] = _G.Settings.RemoveHeadMesh or false,
	["UseBuiltinNetless"] = _G.Settings.UseBuiltinNetless or true
}
local rad = math.rad
-- // MAIN
assert(not workspace:FindFirstChild(Player.UserId), [[\n["R6-BOT.LUA"]: Please reset to be able to run the script again!]])
assert(Humanoid.RigType == Enum.HumanoidRigType.R6, [[\n["R6-BOT.LUA"]: Sorry, This script will only work on R6 character rig only!]])

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
	for _, connection in ipairs(_G.Connections) do connection:Disconnect() end table.clear(_G.Connections)
	Player.Character = Player.Character[Player.Name]
	Player.Character:BreakJoints()
	Player.Character.Parent:Destroy()
	Player.Character = nil
end

local OldPos = HRP.CFrame
local DummyChar = InsertService:LoadLocalAsset("rbxassetid://6843243348")
DummyChar.Name = Player.UserId

for _, connection in ipairs(_G.Connections) do connection:Disconnect() end table.clear(_G.Connections)
for _, object in ipairs(DummyChar:GetChildren()) do if object:IsA("BasePart") then object.Transparency = 1 end end
for PartName, object in pairs(HatParts) do
	if object and object:FindFirstChild("Handle") then
		local accHandle = object.Handle
		if PartName == "Head" and _G.Settings.RemoveHeadMesh then
			accHandle:FindFirstChildWhichIsA("SpecialMesh"):Destroy()
		elseif PartName ~= "Head" then
			accHandle:FindFirstChildWhichIsA("SpecialMesh"):Destroy()
		end
		accHandle:FindFirstChildWhichIsA("Weld"):Destroy()
	end
end

for _, object in ipairs(DummyChar:GetChildren()) do
	if object:IsA("BasePart") and object.Name ~= "HumanoidRootPart" then
		local Attachment = Instance.new("Attachment")
		Attachment.Name = "Offset"
		Attachment.Parent = object
		Attachment.CFrame = (object.Name == "Head" and _G.Settings.HeadOffset or CFrame.new())
	end
end

workspace.FallenPartsDestroyHeight = 0 / 0
HRP.Anchored = true
Character.Animate.Disabled = true
Character.Animate.Parent = DummyChar
Humanoid.Animator:Clone().Parent = DummyChar.Humanoid
DummyChar.Parent = Character
DummyChar.Animate.Disabled = false
DummyChar.HumanoidRootPart.CFrame = OldPos * CFrame.new(Vector3.new(0, 0, -1.5))
Player.Character = DummyChar
DummyChar.Parent = workspace
Character.Parent = DummyChar

_G.Connections[#_G.Connections + 1] = RunService.Heartbeat:Connect(function()
	for PartName, object in pairs(HatParts) do
		if object and object:FindFirstChild("Handle") then
			object.Handle.LocalTransparencyModifier = DummyChar.Head.LocalTransparencyModifier
			if PartName == "Head" then
				object.Handle.CFrame = DummyChar.Head.CFrame * DummyChar.Head.Offset.CFrame
			elseif PartName == "Torso" then
				object.Handle.CFrame = DummyChar.Torso.CFrame * DummyChar.Torso.Offset.CFrame * CFrame.Angles(rad(90), 0, 0)
			elseif PartName == "Torso1" then
				object.Handle.CFrame = DummyChar.Torso.CFrame * DummyChar.Torso.Offset.CFrame * CFrame.new(Vector3.new(0, .5, 0)) * CFrame.Angles(0, rad(90), 0)
			elseif PartName == "Torso2" then
				object.Handle.CFrame = DummyChar.Torso.CFrame * DummyChar.Torso.Offset.CFrame * CFrame.new(Vector3.new(0, -.5, 0)) * CFrame.Angles(0, rad(90), 0)
			else
				object.Handle.CFrame = DummyChar[PartName].CFrame * DummyChar[PartName].Offset.CFrame * CFrame.Angles(rad(90), 0, 0)
			end
		end
	end
	workspace.CurrentCamera.CameraSubject = DummyChar.Humanoid
end)

if _G.Settings.UseBuiltinNetless then
	settings().Physics.AllowSleep = false
	settings().Physics.PhysicsEnvironmentalThrottle = Enum.EnviromentalPhysicsThrottle.Skip8
	settings().Physics.ThrottleAdjustTime = 0 / 0

	for _, object in pairs(HatParts) do
		if object and object:FindFirstChild("Handle") then
			local BodyVel, BodyAngVel = Instance.new("BodyVelocity"), Instance.new("BodyAngularVelocity")
			BodyVel.MaxForce, BodyVel.Velocity = Vector3.new(0, -35, 25.05), Vector3.new(0, -35, 25.05)
			BodyAngVel.MaxTorque, BodyAngVel.AngularVelocity = Vector3.new(), Vector3.new()
			BodyVel.Parent, BodyAngVel.Parent = object.Handle, object.Handle
		end
	end

	_G.Connections[#_G.Connections + 1] = RunService.Stepped:Connect(function()
		for _, object in pairs(HatParts) do
			if object and object:FindFirstChild("Handle") then
				object.Handle.CanCollide = false
				object.Handle.Massless = true
				object.Handle.Velocity = Vector3.new(0, -35, 25.05)
				object.Handle.RotVelocity = Vector3.new()
			end
		end
	end)
end

_G.Connections[#_G.Connections + 1] = DummyChar.Humanoid.Died:Connect(onCharRemoved)
StarterGui:SetCore("SendNotification", {
	Title = "REANIMATE",
	Text = "REANIMATE is now ready!\nThanks for using the script!\n",
	Cooldown = 2.5
})
