-- services
local players = game:GetService("Players")
local runService = game:GetService("RunService")
local starterGui = game:GetService("StarterGui")
-- objects
local player = players.LocalPlayer
local character = player.Character
local humanoid = character.Humanoid
local rootPart, partToAnchor = character.HumanoidRootPart, character.Torso
-- init
assert(character.Name ~= string.format("%s-reanimation", player.UserId), string.format([[["r6-bot.LUA"]: Please reset to be able to run the script again]]))
assert(humanoid.RigType == Enum.HumanoidRigType.R6, string.format([[["r6-bot.LUA"]: Sorry, This script will only work on R6 character rig]]))
do -- config initialization
	_G.Connections, _G.Settings = (_G.Connections or table.create(0)), (_G.Settings or table.create(0))
	_G.Settings.HeadName = (if not _G.Settings.HeadName then "MediHood" else _G.Settings.HeadName)
	_G.Settings.Velocity = (if not _G.Settings.Velocity then Vector3.new(25.05, -30, 0) else _G.Settings.Velocity)
	_G.Settings.RemoveHeadMesh = (if typeof(_G.Settings.RemoveHeadMesh) ~= "boolean" then false else _G.Settings.RemoveHeadMesh)
	_G.Settings.UseBuiltinNetless = (if typeof(_G.Settings.UseBuiltinNetless) ~= "boolean" then true else _G.Settings.UseBuiltinNetless)
	_G.Settings.FlingEnabled = (if typeof(_G.Settings.FlingEnabled) ~= "boolean" then true else _G.Settings.FlingEnabled)
end
for _, connection in ipairs(_G.Connections) do connection:Disconnect() end table.clear(_G.Connections)
-- variables
local botChar = game:GetObjects("rbxassetid://6843243348")[1]
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
local flingBodyPos, flingAtt
-- functions
local function initWelder(part, parent, position, orientation)
	if not (part or parent) then return end
	part = (part and part:IsA("Accessory")) and part.Handle or part
	parent = (parent and parent:IsA("Accessory")) and parent.Handle or parent
	local bodyPos, bodyGyro, attachment = Instance.new("BodyPosition"), Instance.new("BodyGyro"), Instance.new("Attachment")
	attachment.Name = "Offset"
	attachment.Position, attachment.Orientation = (position or Vector3.zero), (orientation or Vector3.zero)
	bodyPos.D, bodyGyro.D = 975, 2250
	bodyPos.P, bodyGyro.P = 1e6, 1e6
	bodyPos.MaxForce, bodyGyro.MaxTorque = Vector3.one * 4e5, Vector3.one * 4e5
	bodyPos.Parent, bodyGyro.Parent, attachment.Parent = part, part, part
end

local function getInstance(inst, instName) -- uhh this thing uses string.find
	for _, object in ipairs(inst:GetChildren()) do
		if string.match(instName, object.Name) then
			return object
		end
	end
end

local function onCharRemoved()
	for _, connection in ipairs(_G.Connections) do connection:Disconnect() end table.clear(_G.Connections)
	player.Character = character
	player.Character:BreakJoints()
	player.Character = nil
	botChar:Destroy()
end

local function orientationToAngles(vect3)
	return math.rad(vect3.X), math.rad(vect3.Y), math.rad(vect3.Z)
end
-- main
botChar.Name = string.format("%s-reanimation", player.UserId)
for _, object in ipairs(botChar:GetChildren()) do if object:IsA("BasePart") then object.Transparency = 1 end end
task.defer(function() -- initializing reanimation after the code below ran
	local animScript, plrFace = character.Animate, character.Head.face:Clone()
	humanoid.Animator:Clone().Parent = botChar.Humanoid
	animScript.Disabled = true
	animScript.Parent = botChar
	animScript.Disabled = false
	botChar.HumanoidRootPart.CFrame = charOldPos
	plrFace.Parent, plrFace.Transparency = botChar.Head, 1

	for partName, object in pairs(bodyParts) do
		if object and object:FindFirstChild("Handle") then
			object.Name = partName
			local accHandle = object.Handle
			if partName == "Head" and _G.Settings.RemoveHeadMesh then
				accHandle:FindFirstChildWhichIsA("SpecialMesh"):Destroy()
				elseif partName ~= "Head" then
				accHandle:FindFirstChildWhichIsA("SpecialMesh"):Destroy()
			end
			accHandle:FindFirstChildWhichIsA("Weld"):Destroy()
		end
	end

	for _, motorObj in ipairs(partToAnchor:GetChildren()) do
		if (not motorObj:IsA("Motor6D") or motorObj.Name == "Neck") then continue end
		motorObj.Part1:Destroy()
		motorObj:Destroy()
	end

	for _, object in ipairs(character:GetChildren()) do
		if (object:IsA("Accessory") and not getInstance(botChar, object.Name)) then
			accessories[object.Name] = object
			local cloneAcce = object:Clone()
			local cloneAcceHandle, cloneAcceWeld = cloneAcce:FindFirstChild("Handle"), cloneAcce.Handle:FindFirstChildWhichIsA("Weld")
			cloneAcceHandle.Transparency = 1
			cloneAcce.Parent = botChar
			cloneAcceWeld.Part1 = botChar:FindFirstChild(object.Handle:FindFirstChildWhichIsA("Weld").Part1.Name) or botChar.HumanoidRootPart
			object.Handle:FindFirstChildWhichIsA("Weld"):Destroy()
		end
	end

	task.defer(rootPart.BreakJoints, rootPart)
	partToAnchor.Anchored = true
	player.Character, botChar.Parent = botChar, workspace
	_G.Connections[#_G.Connections + 1] = botChar.Humanoid.Died:Connect(onCharRemoved)
	_G.Connections[#_G.Connections + 1] = player.CharacterRemoving:Connect(onCharRemoved)
	starterGui:SetCore("SendNotification", {
		Title = "r6-bot.lua",
		Text = "r6-bot.lua is now ready!\nThanks for using the script!\n",
		Cooldown = 2.5
	})
end)

task.defer(function() -- fling initialization
	flingBodyPos, flingAtt = Instance.new("BodyPosition"), Instance.new("Attachment")
	flingAtt.Name = "Fling"
	flingBodyPos.MaxForce, flingBodyPos.D, flingBodyPos.P = Vector3.one * 4e5, 5, 1e6
	flingBodyPos.Parent, flingAtt.Parent = rootPart, botChar.HumanoidRootPart
	rootPart.Transparency, rootPart.Color = 0, Color3.new(255, 255, 255)
end)

if _G.Settings.UseBuiltinNetless then
	settings().Physics.AllowSleep = false
	settings().Physics.PhysicsEnvironmentalThrottle = Enum.EnviromentalPhysicsThrottle.DefaultAuto
	settings().Physics.ThrottleAdjustTime = -math.huge

	_G.Connections[#_G.Connections + 1] = runService.Heartbeat:Connect(function()
		for _, object in ipairs(character:GetChildren()) do
			object = (object:IsA("Accessory") and object:FindFirstChild("Handle") or nil)
			if object then
				object.CanCollide, object.Massless = false, true
				object.Velocity, object.RotVelocity = _G.Settings.Velocity, Vector3.zero
				sethiddenproperty(object, "NetworkIsSleeping", false)
			end
		end
		rootPart.Velocity, rootPart.RotVelocity = Vector3.zero, (Vector3.one * 6942069)
		player.ReplicationFocus = workspace
	end)
end

_G.Connections[#_G.Connections + 1] = runService.Heartbeat:Connect(function()
	flingBodyPos.Position = (botChar.HumanoidRootPart.Position + (_G.Settings.FlingEnabled and flingAtt.Position or Vector3.yAxis * 256))
	workspace.CurrentCamera.CameraSubject = botChar.Humanoid
	for _, object in ipairs(character:GetChildren()) do
		object = (object:IsA("Accessory") and object:FindFirstChild("Handle") or nil)
		if object then
			object.LocalTransparencyModifier = botChar.Head.LocalTransparencyModifier
			local bodyPos, bodyGyro, offsetAtt = object:FindFirstChildWhichIsA("BodyPosition"), object:FindFirstChildWhichIsA("BodyGyro"), object:FindFirstChild("Offset")
			local botCharObj = botChar:FindFirstChild(string.find(object.Parent.Name, "Torso") and "Torso" or object.Parent.Name)
			botCharObj = (botCharObj and (botCharObj:IsA("Accessory") and botCharObj:FindFirstChild("Handle") or botCharObj:IsA("BasePart") and botCharObj) or nil)
			bodyPos.Position, bodyGyro.CFrame = (botCharObj.Position + offsetAtt.Position), (botCharObj.CFrame * CFrame.Angles(orientationToAngles(offsetAtt.Orientation)))
		end
	end
end)

task.defer(table.foreach, accessories, function(accessoryName, accessoryObj)
	local staticAccObj = botChar:FindFirstChild(accessoryName)
	if accessoryObj and staticAccObj then
		initWelder(accessoryObj, staticAccObj)
	end
end)

initWelder(bodyParts.Head, botChar.Head)
initWelder(bodyParts.Torso, botChar.Torso)
initWelder(bodyParts.Torso1, botChar.Torso, Vector3.yAxis * .5, Vector3.yAxis * 90)
initWelder(bodyParts.Torso2, botChar.Torso, -Vector3.yAxis * .5, Vector3.yAxis * 90)
initWelder(bodyParts["Left Arm"], botChar["Left Arm"], nil, Vector3.xAxis * 90)
initWelder(bodyParts["Left Leg"], botChar["Left Leg"], nil, Vector3.xAxis * 90)
initWelder(bodyParts["Right Arm"], botChar["Right Arm"], nil, Vector3.xAxis * 90)
initWelder(bodyParts["Right Leg"], botChar["Right Leg"], nil, Vector3.xAxis * 90)
