-- // INIT (maybe _G detection bypass lol)
if not getgenv().globalTableProtected then
	local protectedGlobal = {["_Settings"] = _G.Settings or {}, ["Connections"] = {}}
	for name, value in pairs(getgenv()._G) do
		if name ~= "Settings" and not protectedGlobal[name] and protectedGlobal[name] ~= getgenv()._G[name] then
			protectedGlobal[name] = value
		end
	end
	getgenv()._G, getgenv().globalTableProtected = setmetatable(protectedGlobal, {
		__index = function(self, index)
			return index == "Settings" and rawget(self, "_Settings") or rawget(self, index)
		end,
		__newindex = function(self, index, value)
			if index == "Settings" and type(value) == "table" then
				for name, value2 in pairs(value) do
					rawset(self._Settings, name, value2)
				end
			elseif index ~= "Settings" then
				rawset(self, index, value)
			end
		end
	}), true
end
-- // SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
-- // OBJECTS
local Player = Players.LocalPlayer
local Character = Player.Character
local Humanoid = Character.Humanoid
local HRP = Character.HumanoidRootPart
-- // LIBRARIES
local getobjects = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/jLn0n/created-scripts-public/main/libraries/getobjects.lua", true))()
-- // VARIABLES
local CharacterOldPos = HRP.CFrame
local task_defer = task.defer
-- // MAIN
assert(not Character.Parent:FindFirstChild(Player.UserId), string.format([[\n["R6-BOT.LUA"]: Please reset to be able to run the script again!]]))
assert(Humanoid.RigType == Enum.HumanoidRigType.R6, string.format([[\n["R6-BOT.LUA"]: Sorry, This script will only work on R6 character rig only!]]))
for _, connection in ipairs(_G.Connections) do connection:Disconnect() end table.clear(_G.Connections)
_G._Settings = {
	["HeadName"] = _G.Settings.HeadName or "International Fedora",
	["HeadOffset"] = _G.Settings.HeadOffset or CFrame.new(),
	["RemoveHeadMesh"] = _G.Settings.RemoveHeadMesh == nil and true or _G.Settings.RemoveHeadMesh,
	["UseBuiltinNetless"] = _G.Settings.UseBuiltinNetless or true,
	["Velocity"] = _G.Settings.Velocity or Vector3.new(0, -35, 25.05)
}

local HatParts = {
	["Head"] = Character:FindFirstChild(_G._Settings.HeadName),
	["Torso"] = Character:FindFirstChild("SeeMonkey"),
	["Torso1"] = Character:FindFirstChild("Robloxclassicred"),
	["Torso2"] = Character:FindFirstChild("LavanderHair"),
	["Left Arm"] = Character:FindFirstChild("Pal Hair"),
	["Right Arm"] = Character:FindFirstChild("Hat1"),
	["Left Leg"] = Character:FindFirstChild("Pink Hair"),
	["Right Leg"] = Character:FindFirstChild("Kate Hair"),
}

local DummyChar = getobjects("rbxassetid://6843243348")[1]
DummyChar.Name = Player.UserId

local onCharRemoved = function()
	for _, connection in ipairs(_G.Connections) do connection:Disconnect() end table.clear(_G.Connections)
	DummyChar:Destroy()
	Player.Character = Character
	Player.Character:BreakJoints()
	Player.Character = nil
end

for _, object in ipairs(DummyChar:GetChildren()) do if object:IsA("BasePart") then object.Transparency = 1 end end
for _, object in ipairs(DummyChar:GetChildren()) do
	if object:IsA("BasePart") and object.Name ~= "HumanoidRootPart" then
		local Attachment = Instance.new("Attachment")
		Attachment.Name = "Offset"
		Attachment.CFrame = (object.Name == "Head" and _G._Settings.HeadOffset) and (
			typeof(_G._Settings.HeadOffset) == "CFrame" and _G._Settings.HeadOffset or
			typeof(_G._Settings.HeadOffset) == "Vector3" and CFrame.new(_G._Settings.HeadOffset)
		) or CFrame.new()
		Attachment.Parent = object
	end
end

task_defer(function() -- // REANIMATE INITIALIZATION
	Character:SetPrimaryPartCFrame(CFrame.new((Vector3.new(1, 1, 1) * 10e10)))
	task.wait(.25)
	HRP.Anchored = true
	Humanoid.BreakJointsOnDeath = false
	local Animate, face = Character.Animate, Character.Head.face:Clone()
	Humanoid.Animator:Clone().Parent = DummyChar.Humanoid
	Animate.Disabled = true
	Animate.Parent = DummyChar
	Animate.Disabled = false
	face.Parent, face.Transparency = DummyChar.Head, 1
	DummyChar.HumanoidRootPart.CFrame = CharacterOldPos
	for PartName, object in pairs(HatParts) do
		if object and object:FindFirstChild("Handle") then
			local accHandle = object.Handle
			if PartName == "Head" and _G._Settings.RemoveHeadMesh == true then
				accHandle:FindFirstChildWhichIsA("SpecialMesh"):Destroy()
			elseif PartName ~= "Head" then
				accHandle:FindFirstChildWhichIsA("SpecialMesh"):Destroy()
			end
			accHandle:FindFirstChildWhichIsA("Weld"):Destroy()
		end
	end
	Player.Character, DummyChar.Parent = DummyChar, Character
	_G.Connections[#_G.Connections + 1] = DummyChar.Humanoid.Died:Connect(onCharRemoved)
	_G.Connections[#_G.Connections + 1] = Player.CharacterRemoving:Connect(onCharRemoved)
	StarterGui:SetCore("SendNotification", {
		Title = "REANIMATE",
		Text = "REANIMATE is now ready!\nThanks for using the script!\n",
		Cooldown = 1
	})
end)

if _G._Settings.UseBuiltinNetless then
	settings().Physics.AllowSleep = false
	settings().Physics.ThrottleAdjustTime = 0 / 0
	settings().Physics.PhysicsEnvironmentalThrottle = Enum.EnviromentalPhysicsThrottle.DefaultAuto

	for _, object in pairs(HatParts) do
		if object and object:FindFirstChild("Handle") then
			local BodyVel, BodyAngVel = Instance.new("BodyVelocity"), Instance.new("BodyAngularVelocity")
			BodyVel.MaxForce, BodyVel.Velocity = _G._Settings.Velocity, _G._Settings.Velocity
			BodyAngVel.MaxTorque, BodyAngVel.AngularVelocity = Vector3.new(), Vector3.new()
			BodyVel.Parent, BodyAngVel.Parent = object.Handle, object.Handle
		end
	end

	_G.Connections[#_G.Connections + 1] = RunService.Heartbeat:Connect(function()
		for _, object in pairs(HatParts) do
			if object and object:FindFirstChild("Handle") then
				object.Handle.CanCollide, object.Handle.Massless = false, true
				object.Handle.Velocity, object.Handle.RotVelocity = _G._Settings.Velocity, Vector3.new()
			end
		end
	end)
end

_G.Connections[#_G.Connections + 1] = RunService.Heartbeat:Connect(function()
	for PartName, object in pairs(HatParts) do
		if object and object:FindFirstChild("Handle") then
			object.Handle.LocalTransparencyModifier = DummyChar.Head.LocalTransparencyModifier
			if PartName == "Head" then
				object.Handle.CFrame = DummyChar.Head.CFrame * DummyChar.Head.Offset.CFrame
			elseif PartName == "Torso" then
				object.Handle.CFrame = DummyChar.Torso.CFrame * DummyChar.Torso.Offset.CFrame * CFrame.Angles(math.rad(90), 0, 0)
			elseif PartName == "Torso1" then
				object.Handle.CFrame = DummyChar.Torso.CFrame * DummyChar.Torso.Offset.CFrame * CFrame.new(Vector3.new(0, .5, 0)) * CFrame.Angles(0, math.rad(90), 0)
			elseif PartName == "Torso2" then
				object.Handle.CFrame = DummyChar.Torso.CFrame * DummyChar.Torso.Offset.CFrame * CFrame.new(Vector3.new(0, -.5, 0)) * CFrame.Angles(0, math.rad(90), 0)
			else
				object.Handle.CFrame = DummyChar[PartName].CFrame * DummyChar[PartName].Offset.CFrame * CFrame.Angles(math.rad(90), 0, 0)
			end
		end
	end
	DummyChar.Humanoid.MaxHealth, DummyChar.Humanoid.Health = Humanoid.MaxHealth, Humanoid.Health
	workspace.CurrentCamera.CameraSubject = DummyChar.Humanoid
end)
