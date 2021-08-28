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
local CharacterOldPos = Character:GetPrimaryPartCFrame()
-- // MAIN
assert(not Character.Parent:FindFirstChild(Player.UserId), string.format([[\n["R6-BOT.LUA"]: Please reset to be able to run the script again]]))
assert(Humanoid.RigType == Enum.HumanoidRigType.R6, string.format([[\n["R6-BOT.LUA"]: Sorry, This script will only work on R6 character rig]]))
for _, connection in ipairs(_G.Connections) do connection:Disconnect() end table.clear(_G.Connections)
_G._Settings = {
	["HeadName"] = _G.Settings.HeadName or "NinjaMaskOfShadows",
	["Velocity"] = _G.Settings.Velocity or Vector3.new(0, -35, 25.05),
	["RemoveHeadMesh"] = _G.Settings.RemoveHeadMesh == nil and false or _G.Settings.RemoveHeadMesh,
	["EnableCollisions"] = _G.Settings.EnableCollisions == nil or true or _G.Settings.EnableCollisions,
	["UseBuiltinNetless"] = _G.Settings.UseBuiltinNetless == nil or true or _G.Settings.UseBuiltinNetless,
}

local HatParts, Accessories = {
	["Head"] = Character:FindFirstChild(_G._Settings.HeadName),
	["Torso"] = Character:FindFirstChild("SeeMonkey"),
	["Torso1"] = Character:FindFirstChild("Robloxclassicred"),
	["Torso2"] = Character:FindFirstChild("LavanderHair"),
	["Left Arm"] = Character:FindFirstChild("Pal Hair"),
	["Left Leg"] = Character:FindFirstChild("Pink Hair"),
	["Right Arm"] = Character:FindFirstChild("Hat1"),
	["Right Leg"] = Character:FindFirstChild("Kate Hair"),
}, table.create(0)

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
task.defer(function() -- // REANIMATE INITIALIZATION
	Character:SetPrimaryPartCFrame(CFrame.new((Vector3.new(1, 1, 1) * 10e5)))
	task.wait(.25)
	HRP.Anchored = true
	Humanoid.PlatformStand = true
	local Animate, face = Character.Animate, Character.Head.face:Clone()
	Humanoid.Animator:Clone().Parent = DummyChar.Humanoid
	Animate.Disabled = true
	Animate.Parent = DummyChar
	Animate.Disabled = false
	face.Parent, face.Transparency = DummyChar.Head, 1
	DummyChar:SetPrimaryPartCFrame(CharacterOldPos)
	for PartName, object in pairs(HatParts) do
		if object and object:FindFirstChild("Handle") then
			object.Name = string.match(PartName, "Torso") and "Torso" or PartName
			local accHandle = object.Handle
			if PartName == "Head" and _G._Settings.RemoveHeadMesh then
				accHandle:FindFirstChildWhichIsA("SpecialMesh"):Destroy()
			elseif PartName ~= "Head" then
				accHandle:FindFirstChildWhichIsA("SpecialMesh"):Destroy()
			end
			accHandle:FindFirstChildWhichIsA("Weld"):Destroy()
		end
	end
	for _, object in ipairs(Character:GetChildren()) do
		if object:IsA("Accessory") and not DummyChar:FindFirstChild(object.Name) then
			local fakeAccessory = object:Clone()
			local fakeAccHandle, fakeAccWeld = fakeAccessory.Handle, fakeAccessory.Handle:FindFirstChildWhichIsA("Weld")
			fakeAccHandle.Transparency = 1
			fakeAccessory.Parent = DummyChar
			fakeAccWeld.Part1 = DummyChar:FindFirstChild(fakeAccWeld.Part1.Name) or DummyChar.HumanoidRootPart
			object.Handle:FindFirstChildWhichIsA("Weld"):Destroy()
			table.insert(Accessories, object)
		end
	end
	Player.Character, DummyChar.Parent = DummyChar, Character
	_G.Connections[#_G.Connections + 1] = DummyChar.Humanoid.Died:Connect(onCharRemoved)
	_G.Connections[#_G.Connections + 1] = Player.CharacterRemoving:Connect(onCharRemoved)
	StarterGui:SetCore("SendNotification", {
		Title = "REANIMATE",
		Text = "REANIMATE is now ready!\nThanks for using the script!\n",
		Cooldown = 2.5
	})
end)

if _G._Settings.UseBuiltinNetless then Player:GetPropertyChangedSignal("Character"):Wait()
	settings().Physics.AllowSleep = false
	settings().Physics.ThrottleAdjustTime = 0 / 0
	settings().Physics.PhysicsEnvironmentalThrottle = Enum.EnviromentalPhysicsThrottle.Skip8

	for _, object in ipairs(Character:GetChildren()) do
		if object:IsA("Accessory") and object:FindFirstChild("Handle") then
			local BodyVel, BodyAngVel = Instance.new("BodyVelocity"), Instance.new("BodyAngularVelocity")
			BodyVel.MaxForce, BodyVel.Velocity = _G._Settings.Velocity, _G._Settings.Velocity
			BodyAngVel.MaxTorque, BodyAngVel.AngularVelocity = Vector3.new(), Vector3.new()
			BodyVel.Parent, BodyAngVel.Parent = object.Handle, object.Handle
		end
	end

	_G.Connections[#_G.Connections + 1] = RunService.Stepped:Connect(function()
		for _, object in ipairs(Character:GetChildren()) do
			if object:IsA("Accessory") and object:FindFirstChild("Handle") then
				object.Handle.Massless, object.Handle.CanCollide = true, false
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
				object.Handle.CFrame = DummyChar.Head.CFrame
			elseif PartName == "Torso1" then
				object.Handle.CFrame = DummyChar.Torso.CFrame * CFrame.new(Vector3.new(0, .5, 0)) * CFrame.Angles(0, math.rad(90), 0)
			elseif PartName == "Torso2" then
				object.Handle.CFrame = DummyChar.Torso.CFrame * CFrame.new(Vector3.new(0, -.5, 0)) * CFrame.Angles(0, math.rad(90), 0)
			else
				object.Handle.CFrame = DummyChar[PartName].CFrame * CFrame.Angles(math.rad(90), 0, 0)
			end
		end
	end
	for _, object in ipairs(Accessories) do
		if object and object:FindFirstChild("Handle") then
			object.Handle.LocalTransparencyModifier = DummyChar.Head.LocalTransparencyModifier
			object.Handle.CFrame = DummyChar[object.Name].Handle.CFrame
		end
	end
	DummyChar.Humanoid.MaxHealth, DummyChar.Humanoid.Health = Humanoid.MaxHealth, Humanoid.Health
	workspace.CurrentCamera.CameraSubject = DummyChar.Humanoid
end)
