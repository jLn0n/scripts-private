-- services
local players = game:GetService("Players")
local runService = game:GetService("RunService")
local starterGui = game:GetService("StarterGui")
-- objects
local player = players.LocalPlayer
local character = player.Character
local humanoid = character.Humanoid
local rootPart, torso = character.HumanoidRootPart, character:FindFirstChild("Torso")
-- init
assert(character.Name ~= string.format("%s-reanimation", player.UserId), string.format([[["r6-bot.lua"]: Please reset to be able to run the script again]]))
assert(humanoid.RigType == Enum.HumanoidRigType.R6, string.format([[["r6-bot.lua"]: Sorry, This script will only work on R6 character rig]]))
do -- config initialization
	_G.Connections, _G.Settings = (_G.Connections or table.create(0)), (_G.Settings or table.create(0))
	_G.Settings.HeadName = (if not _G.Settings.HeadName then "MediHood" else _G.Settings.HeadName)
	_G.Settings.Velocity = (if not _G.Settings.Velocity then Vector3.xAxis * -30.05 else _G.Settings.Velocity)
	_G.Settings.RemoveHeadMesh = (if typeof(_G.Settings.RemoveHeadMesh) ~= "boolean" then false else _G.Settings.RemoveHeadMesh)
	_G.Settings.UseBodyMovers = (if typeof(_G.Settings.UseBodyMovers) ~= "boolean" then false else _G.Settings.UseBodyMovers)
	_G.Settings.UseBuiltinNetless = (if typeof(_G.Settings.UseBuiltinNetless) ~= "boolean" then true else _G.Settings.UseBuiltinNetless)
	_G.Settings.CollisionEnabled = (if typeof(_G.Settings.CollisionEnabled) ~= "boolean" then false else _G.Settings.CollisionEnabled)
end
for _, connection in ipairs(_G.Connections) do connection:Disconnect() end table.clear(_G.Connections)
-- variables
local botChar = game:GetObjects("rbxassetid://6843243348")[1]
local charOldPos = character:GetPivot()
local destroyFunc = rootPart.Destroy
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
local function unpackOrientation(vectRot, dontUseRadians)
	vectRot = (if not dontUseRadians then vectRot * (math.pi / 180) else vectRot)
	return vectRot.X, vectRot.Y, (if typeof(vectRot) == "Vector2" then 0 else vectRot.Z)
end

local function initWelder(part, parent, position, orientation)
	if not (part or parent) then return end
	part = (part and part:IsA("Accessory")) and part.Handle or part
	parent = (parent and parent:IsA("Accessory")) and parent.Handle or parent
	position, orientation = (position or Vector3.zero), (orientation or Vector3.zero)
	local attachment = Instance.new("Attachment")
	attachment.Name = "Offset"
	attachment.CFrame = (CFrame.new(position) * CFrame.Angles(unpackOrientation(orientation)))
	if _G.Settings.UseBodyMovers then
		local bodyPos, bodyGyro = Instance.new("BodyPosition"), Instance.new("BodyGyro")
		bodyPos.D, bodyGyro.D = 1250, 2500
		bodyPos.P, bodyGyro.P = 1e6, 1e6
		bodyPos.MaxForce, bodyGyro.MaxTorque = Vector3.one * math.huge, Vector3.one * math.huge
		bodyPos.Parent, bodyGyro.Parent, attachment.Parent = part, part, part
	else
		local alignPos, alignOrt = Instance.new("AlignPosition"), Instance.new("AlignOrientation")
		local _attachment = Instance.new("Attachment")
		alignPos.ApplyAtCenterOfMass = true
		alignPos.MaxForce, alignOrt.MaxTorque = 9e9, math.huge
		alignPos.MaxVelocity, alignOrt.MaxAngularVelocity = math.huge, math.huge
		alignPos.ReactionForceEnabled, alignOrt.ReactionTorqueEnabled = false, false
		alignPos.Responsiveness, alignOrt.Responsiveness = 200, 200
		alignPos.RigidityEnabled, alignOrt.RigidityEnabled = false, false
		alignPos.Attachment0, alignOrt.Attachment0 = _attachment, _attachment
		alignPos.Attachment1, alignOrt.Attachment1 = attachment, attachment
		alignPos.Parent, alignOrt.Parent = part, part
		attachment.Parent, _attachment.Parent = parent, part
	end
end

local function killReanimation()
	for _, connection in ipairs(_G.Connections) do connection:Disconnect() end table.clear(_G.Connections)
	player.Character = character
	player.Character:BreakJoints()
	player.Character = nil
	botChar:Destroy()
end
-- main
botChar.Name = string.format("%s-reanimation", player.UserId)
for _, object in ipairs(botChar:GetChildren()) do if object:IsA("BasePart") then object.Transparency = 1 end end
task.defer(function() -- initializing reanimation after the code below ran
	-- TODO: rewrite this pile of shit and make the character teleport to far away without breaking this shit
	--[[
		far character phenomena: (can't find a better name)
		when character (you) is far from players then unanchored parts that the player claimed
		will be unclaimable thats why i need to make player far
	--]]
	local animScript, plrFace = character.Animate, character.Head.face:Clone()
	humanoid.Animator:Clone().Parent = botChar.Humanoid
	animScript.Disabled = true
	animScript.Parent = botChar
	animScript.Disabled = false
	botChar:PivotTo(charOldPos)
	plrFace.Parent, plrFace.Transparency = botChar.Head, 1

	for partName, object in bodyParts do
		if object and object:FindFirstChild("Handle") then
			object.Name = partName
			local accHandle = object.Handle
			if (partName == "Head" and _G.Settings.RemoveHeadMesh) or partName ~= "Head" then
				accHandle:FindFirstChildWhichIsA("SpecialMesh"):Destroy()
			end
			accHandle:FindFirstChildWhichIsA("Weld"):Destroy()
		end
	end

	for _, object in humanoid:GetAccessories() do
		if (not (botChar:FindFirstChild(object.Name) or string.find(object.Name, "Torso"))) then
			accessories[object.Name] = object
			local cloneAcce = object:Clone()
			local cloneAcceHandle, cloneAcceWeld = cloneAcce:FindFirstChild("Handle"), cloneAcce.Handle:FindFirstChildWhichIsA("Weld")
			cloneAcceHandle.Transparency = 1
			cloneAcce.Parent = botChar
			cloneAcceWeld.Part1 = botChar:FindFirstChild(object.Handle:FindFirstChildWhichIsA("Weld").Part1.Name) or botChar.HumanoidRootPart
			--object.Handle:FindFirstChildWhichIsA("Weld"):Destroy()
		end
	end

	if _G.Settings.CollisionEnabled then
		destroyFunc(rootPart)

		for _, object in humanoid:GetAccessories() do
			if not object:FindFirstChild("Handle") then continue end
			sethiddenproperty(object, "BackendAccoutrementState", 0)
			--object.Handle:FindFirstChildWhichIsA("Weld"):Destroy()
		end

		_G.Connections[#_G.Connections + 1] = runService.Stepped:Connect(function()
			for _, object in humanoid:GetAccessories() do
				object = object:FindFirstChild("Handle")
				if not object then continue end
				object.CanCollide = false
			end	
		end)
	end

	player.Character, botChar.Parent = botChar, workspace
	--initWelder(torso, botChar.HumanoidRootPart, Vector3.yAxis * -25)
	_G.Connections[#_G.Connections + 1] = botChar.Humanoid.Died:Connect(killReanimation)
	_G.Connections[#_G.Connections + 1] = player.CharacterRemoving:Connect(killReanimation)
	starterGui:SetCore("SendNotification", {
		Title = "r6-bot.lua",
		Text = "r6-bot.lua is now ready!\nThanks for using the script!\n",
		Cooldown = 2.5
	})
end)

if _G.Settings.UseBuiltinNetless then
	settings().Physics.AllowSleep = false
	settings().Physics.PhysicsEnvironmentalThrottle = Enum.EnviromentalPhysicsThrottle.Disabled
	settings().Rendering.EagerBulkExecution = true
	settings().Physics.ForceCSGv2 = false
	settings().Physics.DisableCSGv2 = true
	settings().Physics.UseCSGv2 = false
	game:GetService("NetworkClient"):SetOutgoingKBPSLimit(math.huge)
	workspace.FallenPartsDestroyHeight = 0 / 0
	sethiddenproperty(workspace, "HumanoidOnlySetCollisionsOnStateChange", Enum.HumanoidOnlySetCollisionsOnStateChange.Disabled)
	sethiddenproperty(workspace, "InterpolationThrottling", Enum.InterpolationThrottlingMode.Disabled)
	sethiddenproperty(humanoid, "InternalBodyScale", (Vector3.one * 9e99))
	sethiddenproperty(humanoid, "InternalHeadScale", 9e99)
	player.ReplicationFocus = workspace

	_G.Connections[#_G.Connections + 1] = runService.Heartbeat:Connect(function()
		for _, object in humanoid:GetAccessories() do
			object = object:FindFirstChild("Handle")
			if object then
				local calcVel = (_G.Settings.Velocity + (Vector3.yAxis * botChar.HumanoidRootPart.Velocity.Y))

				sethiddenproperty(object, "NetworkIsSleeping", false)
				sethiddenproperty(object, "NetworkOwnershipRule", Enum.NetworkOwnership.Manual)
				object:ApplyImpulse(object:GetVelocityAtPosition(object.Position))
				object.CanCollide, object.Massless = false, true
				object.Velocity, object.RotVelocity = calcVel, Vector3.zero
			end
		end
	end)

	for _, object in humanoid:GetAccessories() do
		object = object:FindFirstChild("Handle")
		if object then
			object:FindFirstChildWhichIsA("Weld"):Destroy()

			local mass, maxThing = object:GetMass(), Vector3.one * (math.pi * 1000000)
			local bVel, bAngVel = Instance.new("BodyVelocity"), Instance.new("BodyAngularVelocity")
			
			bVel.P, bAngVel.P = mass, mass
			bVel.MaxForce, bAngVel.MaxTorque = maxThing, maxThing
			bVel.Velocity, bAngVel.AngularVelocity = _G.Settings.Velocity, Vector3.yAxis * -12.05
			bVel.Parent, bAngVel.Parent = object, object
		end
	end
end

_G.Connections[#_G.Connections + 1] = runService.Heartbeat:Connect(function()
	workspace.CurrentCamera.CameraSubject = botChar.Humanoid
	if botChar.HumanoidRootPart.Position.Y <= workspace.FallenPartsDestroyHeight then
		killReanimation()
		return
	end
	for _, object in ipairs(humanoid:GetAccessories()) do
		object = object:FindFirstChild("Handle")
		if object then
			object.LocalTransparencyModifier = botChar.Head.LocalTransparencyModifier
			if not _G.Settings.UseBodyMovers then continue end
			local bodyPos, bodyGyro, offsetAtt = object:FindFirstChildWhichIsA("BodyPosition"), object:FindFirstChildWhichIsA("BodyGyro"), object:FindFirstChild("Offset")
			if (bodyPos and bodyGyro and offsetAtt) then
				local botCharObj = botChar:FindFirstChild(string.find(object.Parent.Name, "Torso") and "Torso" or object.Parent.Name)
				botCharObj = (botCharObj and (botCharObj:IsA("Accessory") and botCharObj:FindFirstChild("Handle") or botCharObj:IsA("BasePart") and botCharObj) or nil)
				bodyPos.Position, bodyGyro.CFrame = (botCharObj.Position + offsetAtt.Position), (botCharObj.CFrame * CFrame.Angles(unpackOrientation(offsetAtt.Orientation)))
			end
		end
	end
end)

_G.Connections[#_G.Connections + 1] = runService.Stepped:Connect(function()
	character.Head.CFrame = (botChar.HumanoidRootPart.CFrame * (CFrame.identity + (Vector3.yAxis * -25)))

	for _, object in character:GetChildren() do
		if not object:IsA("BasePart") then continue end
		object.CanCollide = false
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