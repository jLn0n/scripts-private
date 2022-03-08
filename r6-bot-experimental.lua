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
	_G.Connections, _G.Settings = (_G.Connections or table.create(0)), (_G.Settings or table.create(0))
	_G.Settings.HeadName = (if not _G.Settings.HeadName then "MediHood" else _G.Settings.HeadName)
	_G.Settings.Velocity = (if not _G.Settings.Velocity then Vector3.new(-30, 25.05, 0) else _G.Settings.Velocity)
	_G.Settings.RemoveHeadMesh = (if typeof(_G.Settings.RemoveHeadMesh) ~= "boolean" then false else _G.Settings.RemoveHeadMesh)
	_G.Settings.UseBuiltinNetless = (if typeof(_G.Settings.UseBuiltinNetless) ~= "boolean" then true else _G.Settings.UseBuiltinNetless)
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
-- functions
local function onCharRemoved()
	for _, connection in ipairs(_G.Connections) do connection:Disconnect() end table.clear(_G.Connections)
	player.Character = character
	player.Character:BreakJoints()
	player.Character = nil
	botChar:Destroy()
end
local function align101(part, parent, position, orientation)
	print(part, parent)
	if not (part or parent) then return end
	part = (part and part:IsA("Accessory")) and part.Handle or part
	parent = (parent and parent:IsA("Accessory")) and parent.Handle or parent
	local alignPos, alignOrt = Instance.new("AlignPosition"), Instance.new("AlignOrientation")
	local attachment, _attachment = Instance.new("Attachment"), Instance.new("Attachment")
	alignPos.ApplyAtCenterOfMass = true
	alignPos.MaxForce = 9e9
	alignPos.MaxVelocity = math.huge
	alignPos.ReactionForceEnabled = false
	alignPos.Responsiveness = 200
	alignPos.RigidityEnabled = false
	alignPos.Visible = true
	alignOrt.MaxTorque = math.huge
	alignOrt.MaxAngularVelocity = math.huge
	alignOrt.ReactionTorqueEnabled = false
	alignOrt.Responsiveness = 200
	alignOrt.RigidityEnabled = false
	alignPos.Parent, alignOrt.Parent = part, part
	attachment.Parent, _attachment.Parent = parent, part
	alignPos.Attachment0, alignOrt.Attachment0 = _attachment, _attachment
	alignPos.Attachment1, alignOrt.Attachment1 = attachment, attachment
	attachment.Position, attachment.Orientation = position or Vector3.new(), orientation or Vector3.new()
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
	rootPart.Anchored = true
	player.Character, botChar.Parent = botChar, character
	_G.Connections[#_G.Connections + 1] = botChar.Humanoid.Died:Connect(onCharRemoved)
	_G.Connections[#_G.Connections + 1] = player.CharacterRemoving:Connect(onCharRemoved)
	starterGui:SetCore("SendNotification", {
		Title = "r6-bot.lua",
		Text = "r6-bot.lua is now ready!\nThanks for using the script!\n",
		Cooldown = 2.5
	})
end)

if _G.Settings.UseBuiltinNetless then
	_G.Connections[#_G.Connections + 1] = runService.Heartbeat:Connect(function()
		for _, object in ipairs(character:GetChildren()) do
			object = (object:IsA("Accessory") and object:FindFirstChild("Handle") or nil)
			if object then
				object.Massless, object.CanCollide = true, false
				object.Velocity, object.RotVelocity = _G.Settings.Velocity, Vector3.new()
				sethiddenproperty(object, "NetworkIsSleeping", false)
			end
		end
		setsimulationradius(1e10, 1e10)
		player.ReplicationFocus = workspace
	end)
end

_G.Connections[#_G.Connections + 1] = runService.Heartbeat:Connect(function()
	for _, object in ipairs(character:GetChildren()) do
		object = (object:IsA("Accessory") and object:FindFirstChild("Handle") or nil)
		if not object then continue end
		object.LocalTransparencyModifier = botChar.Head.LocalTransparencyModifier
	end
	workspace.CurrentCamera.CameraSubject = botChar.Humanoid
end)

for _, object in ipairs(accessories) do
	print(object.Name, object:FindFirstChild("Handle"))
	object = object:FindFirstChild("Handle")
	if object then
		align101(object, botChar:FindFirstChild(object.Parent.Name))
	end
end
align101(bodyParts.Head, botChar.Head)
align101(bodyParts.Torso, botChar.Torso)
align101(bodyParts.Torso1, botChar.Torso, Vector3.yAxis * .5, Vector3.yAxis * 90)
align101(bodyParts.Torso2, botChar.Torso, -Vector3.yAxis * .5, Vector3.yAxis * 90)
align101(bodyParts["Left Arm"], botChar["Left Arm"], nil, Vector3.xAxis * 90)
align101(bodyParts["Left Leg"], botChar["Left Leg"], nil, Vector3.xAxis * 90)
align101(bodyParts["Right Arm"], botChar["Right Arm"], nil, Vector3.xAxis * 90)
align101(bodyParts["Right Leg"], botChar["Right Leg"], nil, Vector3.xAxis * 90)
