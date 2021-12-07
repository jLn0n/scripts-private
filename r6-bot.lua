-- services
local players = game:GetService("Players")
local runService = game:GetService("RunService")
local starterGui = game:GetService("StarterGui")
-- objects
local player = players.LocalPlayer
local character = player.Character
local humanoid = character.Humanoid
local rootPart = character.HumanoidRootPart
-- init
assert(not character.Parent:FindFirstChild(string.format("%s-reanimation", player.UserId)), string.format([[\n["R6-BOT.LUA"]: Please reset to be able to run the script again]]))
assert(humanoid.RigType == Enum.HumanoidRigType.R6, string.format([[\n["R6-BOT.LUA"]: Sorry, This script will only work on R6 character rig]]))
do -- config initialization
	_G.Connections, _G.Settings = _G.Connections or table.create(0), _G.Settings or table.create(0)
	_G.Settings.HeadName = _G.Settings.HeadName or "MediHood"
	_G.Settings.Velocity = _G.Settings.Velocity or Vector3.new(-35, -25.05, 0)
	_G.Settings.RemoveHeadMesh = _G.Settings.RemoveHeadMesh == nil and false or _G.Settings.RemoveHeadMesh
	_G.Settings.UseBuiltinNetless = _G.Settings.UseBuiltinNetless == nil or true or _G.Settings.UseBuiltinNetless
end
for _, connection in ipairs(_G.Connections) do connection:Disconnect() end table.clear(_G.Connections)
-- variables
local charOldPos = rootPart.CFrame
local accessories, bodyParts = table.create(0), {
	["Head"] = character:FindFirstChild(_G.Settings.HeadName),
	["Torso"] = character:FindFirstChild("SeeMonkey"),
	["Torso1"] = character:FindFirstChild("Robloxclassicred"),
	["Torso2"] = character:FindFirstChild("LavanderHair"),
	["Left Arm"] = character:FindFirstChild("Pal Hair"),
	["Left Leg"] = character:FindFirstChild("Pink Hair"),
	["Right Arm"] = character:FindFirstChild("Hat1"),
	["Right Leg"] = character:FindFirstChild("Kate Hair"),
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
	rootPart.Anchored = true
	local animScript, plrFace = character.Animate, character.Head.face:Clone()
	humanoid.Animator:Clone().Parent = botChar.Humanoid
	animScript.Disabled = true
	animScript.Parent = botChar
	animScript.Disabled = false
	botChar.HumanoidRootPart.CFrame = charOldPos
	plrFace.Parent, plrFace.Transparency = botChar.Head, 1
	for PartName, object in pairs(bodyParts) do
		if object and object:FindFirstChild("Handle") then
			object.Name = (string.match(PartName, "Torso") and "Torso" or PartName)
			local accHandle = object.Handle
			if PartName == "Head" and _G.Settings.RemoveHeadMesh then
				accHandle:FindFirstChildWhichIsA("SpecialMesh"):Destroy()
			elseif PartName ~= "Head" then
				accHandle:FindFirstChildWhichIsA("SpecialMesh"):Destroy()
			end
			accHandle:FindFirstChildWhichIsA("Weld"):Destroy()
		end
	end
	for _, object in ipairs(character:GetChildren()) do
		if object:IsA("Accessory") and not botChar:FindFirstChild(object.Name) then
			local cloneAcce = object:Clone()
			local cloneAcceHandle, cloneAcceWeld = cloneAcce:FindFirstChild("Handle"), cloneAcce.Handle:FindFirstChildWhichIsA("Weld")
			cloneAcceHandle.Transparency = 1
			cloneAcce.Parent = botChar
			cloneAcceWeld.Part1 = botChar:FindFirstChild(object.Handle:FindFirstChildWhichIsA("Weld").Part1.Name) or botChar.HumanoidRootPart
			object.Handle:FindFirstChildWhichIsA("Weld"):Destroy()
			table.insert(accessories, object)
		end
	end
	player.Character, botChar.Parent = botChar, character
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
	settings().Physics.PhysicsEnvironmentalThrottle = Enum.EnviromentalPhysicsThrottle.Skip8

	_G.Connections[#_G.Connections + 1] = runService.Heartbeat:Connect(function()
		for _, object in ipairs(character:GetChildren()) do
			object = (object:IsA("Accessory") and object:FindFirstChild("Handle") or nil)
			if object then
				object.Massless, object.CanCollide = true, false
				object.Velocity, object.RotVelocity = _G.Settings.Velocity, Vector3.new()
				sethiddenproperty(object, "NetworkIsSleeping", false)
			end
		end
		setsimulationradius(-1, -1)
	end)

	player:GetPropertyChangedSignal("Character"):Wait()
	for _, object in ipairs(character:GetChildren()) do
		object = (object:IsA("Accessory") and object:FindFirstChild("Handle") or nil)
		if object then
			local BodyVel, BodyAngVel = Instance.new("BodyVelocity"), Instance.new("BodyAngularVelocity")
			BodyVel.MaxForce, BodyVel.Velocity = _G.Settings.Velocity, _G.Settings.Velocity
			BodyAngVel.MaxTorque, BodyAngVel.AngularVelocity = Vector3.new(), Vector3.new()
			BodyVel.Parent, BodyAngVel.Parent = object, object
		end
	end
end

_G.Connections[#_G.Connections + 1] = runService.Heartbeat:Connect(function()
	for PartName, object in pairs(bodyParts) do
		object = (object:IsA("Accessory") and object:FindFirstChild("Handle") or nil)
		if object then
			object.LocalTransparencyModifier = botChar.Head.LocalTransparencyModifier
			if PartName == "Head" then
				object.CFrame = botChar.Head.CFrame
			elseif PartName == "Torso1" then
				object.CFrame = botChar.Torso.CFrame * CFrame.new(Vector3.new(0, .5, 0)) * CFrame.Angles(0, math.rad(90), 0)
			elseif PartName == "Torso2" then
				object.CFrame = botChar.Torso.CFrame * CFrame.new(Vector3.new(0, -.5, 0)) * CFrame.Angles(0, math.rad(90), 0)
			else
				object.CFrame = botChar[PartName].CFrame * CFrame.Angles(math.rad(90), 0, 0)
			end
		end
	end
	for _, object in pairs(accessories) do
		object = object:FindFirstChild("Handle")
		if object then
			object.LocalTransparencyModifier = botChar.Head.LocalTransparencyModifier
			object.CFrame = botChar:FindFirstChild(object.Parent.Name).Handle.CFrame
		end
	end
	workspace.CurrentCamera.CameraSubject = botChar.Humanoid
end)
