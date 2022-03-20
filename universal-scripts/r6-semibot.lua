-- services
local players = game:GetService("Players")
local runService = game:GetService("RunService")
local starterGui = game:GetService("StarterGui")
local uis = game:GetService("UserInputService")
-- objects
local player = players.LocalPlayer
local character = player.Character
local humanoid = character.Humanoid
local hRootPart = character.HumanoidRootPart
-- init
assert(not character.Parent:FindFirstChild(string.format("%s-reanimation", player.UserId)), string.format([[\n["R6-SEMIBOT.LUA"]: Please reset to be able to run the script again]]))
assert(humanoid.RigType == Enum.HumanoidRigType.R6, string.format([[\n["R6-SEMIBOT.LUA"]: Sorry, This script will only work on R6 character rig]]))
do -- config initialization
	_G.Connections, _G.Settings = _G.Connections or table.create(0), _G.Settings or table.create(0)
	_G.Settings.HeadName = _G.Settings.HeadName or "NinjaMaskOfShadows"
	_G.Settings.Velocity = _G.Settings.Velocity or Vector3.new(-35, 25.05, 0)
	_G.Settings.RemoveHeadMesh = _G.Settings.RemoveHeadMesh == nil and false or _G.Settings.RemoveHeadMesh
	_G.Settings.UseBuiltinNetless = _G.Settings.UseBuiltinNetless == nil or true or _G.Settings.UseBuiltinNetless
end
for _, connection in ipairs(_G.Connections) do connection:Disconnect() end table.clear(_G.Connections)
-- variables
local charOldPos = hRootPart.CFrame
local accessories, bodyParts = table.create(0), {
	["Head"] = character:FindFirstChild(_G.Settings.HeadName),
	["Torso"] = character:FindFirstChild("SeeMonkey"),
	["Torso1"] = character:FindFirstChild("Robloxclassicred"),
	["Torso2"] = character:FindFirstChild("LavanderHair"),
	["Left Arm"] = character:FindFirstChild("Left Arm"),
	["Left Leg"] = character:FindFirstChild("Left Leg"),
	["Right Arm"] = character:FindFirstChild("Right Arm"),
	["Right Leg"] = character:FindFirstChild("Right Leg"),
}
-- main
local botChar = game:GetObjects("rbxassetid://6843243348")[1]
botChar.Name = string.format("%s-reanimation", player.UserId)
for _, object in ipairs(botChar:GetChildren()) do if object:IsA("BasePart") then object.Transparency = 1 end end

local function onCharRemoved()
	for _, connection in ipairs(_G.Connections) do connection:Disconnect() end table.clear(_G.Connections)
	botChar:Destroy()
	player.Character = character
	player.Character:BreakJoints()
	player.Character = nil
end

task.defer(function() -- initializing reanimation after the code below ran
	hRootPart.Anchored = true
	local animScript, plrFace = character.Animate, character.Head.face:Clone()
	humanoid.Animator:Clone().Parent = botChar.Humanoid
	animScript.Disabled = true
	animScript.Parent = botChar
	animScript.Disabled = false
	plrFace.Parent, plrFace.Transparency = botChar.Head, 1
	botChar.HumanoidRootPart.CFrame = charOldPos
	for PartName, object in pairs(bodyParts) do
		if object and object:FindFirstChild("Handle") then
			object.Name = string.match(PartName, "Torso") and "Torso" or PartName
			local accHandle = object.Handle
			if PartName == "Head" and _G.Settings.RemoveHeadMesh then
				accHandle:FindFirstChildWhichIsA("SpecialMesh"):Destroy()
			elseif PartName ~= "Head" then
				accHandle:FindFirstChildWhichIsA("SpecialMesh"):Destroy()
			end
			accHandle:FindFirstChildWhichIsA("Weld"):Destroy()
		end
	end
	for _, object in ipairs(character.Torso:GetChildren()) do
		if object:IsA("Motor6D") and object.Name ~= "Neck" then
			object:Destroy()
		end
	end
	for _, object in ipairs(character:GetChildren()) do
		if object:IsA("Accessory") and not botChar:FindFirstChild(object.Name) then
			local fakeAccessory = object:Clone()
			local fakeAccHandle, fakeAccWeld = fakeAccessory.Handle, fakeAccessory.Handle:FindFirstChildWhichIsA("Weld")
			fakeAccHandle.Transparency = 1
			fakeAccessory.Parent = botChar
			fakeAccWeld.Part1 = botChar:FindFirstChild(fakeAccWeld.Part1.Name) or botChar.HumanoidRootPart
			object.Handle:FindFirstChildWhichIsA("Weld"):Destroy()
			table.insert(accessories, object)
		end
	end
	botChar.Parent = character
	_G.Connections[#_G.Connections + 1] = botChar.Humanoid.Died:Connect(onCharRemoved)
	_G.Connections[#_G.Connections + 1] = player.CharacterRemoving:Connect(onCharRemoved)
	starterGui:SetCore("SendNotification", {
		Title = "REANIMATE",
		Text = "REANIMATE is now ready!\nThanks for using the script!\n",
		Cooldown = 2.5
	})
end)

if _G.Settings.UseBuiltinNetless then
	settings().Physics.AllowSleep = false
	settings().Physics.ThrottleAdjustTime = 0 / 0
	settings().Physics.PhysicsEnvironmentalThrottle = Enum.EnviromentalPhysicsThrottle.DefaultAuto

	for _, object in pairs(bodyParts) do
		object = object and ((object:IsA("Accessory") and object:FindFirstChild("Handle")) and object.Handle or object:IsA("BasePart") and object or nil)
		if object then
			local BodyVel, BodyAngVel = Instance.new("BodyVelocity"), Instance.new("BodyAngularVelocity")
			BodyVel.P, BodyVel.MaxForce, BodyVel.Velocity = math.huge, Vector3.new(1, 1, 1) * math.huge, _G.Settings.Velocity
			BodyAngVel.MaxTorque, BodyAngVel.AngularVelocity = Vector3.new(), Vector3.new()
			BodyVel.Parent, BodyAngVel.Parent = object, object
		end
	end

	_G.Connections[#_G.Connections + 1] = runService.Stepped:Connect(function()
		for _, object in pairs(bodyParts) do
			object = object and ((object:IsA("Accessory") and object:FindFirstChild("Handle")) and object.Handle or object:IsA("BasePart") and object or nil)
			if object then
				object.Massless, object.CanCollide = true, false
				object.Velocity, object.RotVelocity = _G.Settings.Velocity, Vector3.new()
				sethiddenproperty(object, "NetworkIsSleeping", false)
			end
		end
	end)
end

_G.Connections[#_G.Connections + 1] = runService.Heartbeat:Connect(function()
	for PartName, object in pairs(bodyParts) do
		object = object and ((object:IsA("Accessory") and object:FindFirstChild("Handle")) and object.Handle or object:IsA("BasePart") and object or nil)
		if object then
			object.LocalTransparencyModifier = botChar.Head.LocalTransparencyModifier
			if PartName == "Head" then
				object.CFrame = botChar.Head.CFrame
			elseif PartName == "Torso1" then
				object.CFrame = botChar.Torso.CFrame * CFrame.new(Vector3.new(0, .5, 0)) * CFrame.Angles(0, math.rad(90), 0)
			elseif PartName == "Torso2" then
				object.CFrame = botChar.Torso.CFrame * CFrame.new(Vector3.new(0, -.5, 0)) * CFrame.Angles(0, math.rad(90), 0)
			else
				object.CFrame = botChar[PartName].CFrame
			end
		end
	end
	for _, object in ipairs(accessories) do
		if object and object:FindFirstChild("Handle") then
			object.Handle.LocalTransparencyModifier = botChar.Head.LocalTransparencyModifier
			object.Handle.CFrame = botChar[object.Name].Handle.CFrame
		end
	end
	workspace.CurrentCamera.CameraSubject = botChar.Humanoid
	botChar.Humanoid:Move(humanoid.MoveDirection, false)
	if uis:IsKeyDown(Enum.KeyCode.Space) and uis:GetFocusedTextBox() == nil then
		botChar.Humanoid.Jump = true
	end
end)
