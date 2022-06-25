-- options
local options = table.create(0)
options.headName = "MediHood"

options.headScale = 3
options.rotationOffset = {
	["LeftHand"] = Vector3.new(),
	["RightHand"] = Vector3.new()
}
-- services
local inputService = game:GetService("UserInputService")
local players = game:GetService("Players")
local runService = game:GetService("RunService")
local VRService = game:GetService("VRService")
-- objects
local camera = workspace.CurrentCamera
local player = players.LocalPlayer
local character = player.Character
local humanoid = character.Humanoid
local rootPart, torso = character.HumanoidRootPart, character.Torso
local userCFrameChanged = Instance.new("BindableEvent")
-- functions
local destroyFunc = character.Destroy
local function createWeld(part, parent, cframeOffset)
	if not (part or parent) then return end
	part = (part and part:IsA("Accessory")) and part.Handle or part
	parent = (parent and parent:IsA("Accessory")) and parent.Handle or parent
	cframeOffset = cframeOffset or CFrame.identity
	local alignPos, alignOrt = Instance.new("AlignPosition"), Instance.new("AlignOrientation")
	local attachment, _attachment = Instance.new("Attachment"), Instance.new("Attachment")
	alignPos.ApplyAtCenterOfMass = true
	alignPos.MaxForce, alignOrt.MaxTorque = 67752, 67752
	alignPos.MaxVelocity, alignOrt.MaxAngularVelocity = (math.huge / 9e110), (math.huge / 9e110)
	alignPos.ReactionForceEnabled, alignOrt.ReactionTorqueEnabled = false, false
	alignPos.Responsiveness, alignOrt.Responsiveness = 200, 200
	alignPos.RigidityEnabled, alignOrt.RigidityEnabled = false, false
	alignPos.Attachment0, alignOrt.Attachment0 = _attachment, _attachment
	alignPos.Attachment1, alignOrt.Attachment1 = attachment, attachment
	alignPos.Parent, alignOrt.Parent = part, part
	attachment.Name = "Offset"
	attachment.Parent, _attachment.Parent = parent, part
	attachment.CFrame = cframeOffset
end
local function createPart(name, size)
	local partObj = Instance.new("Part")
	partObj.Name = name
	partObj.Anchored = true
	partObj.CanCollide = false
	partObj.CFrame = rootPart.CFrame
	partObj.Size = size
	partObj.Transparency = 1
	partObj.Parent = character
	return partObj
end
local function unpackOrientation(vect3, useRadians)
	vect3 = (if useRadians then vect3 * (math.pi / 180) else vect3)
	return vect3.X, vect3.Y, vect3.Z
end
-- variables
local R1ButtonDown = false
local bodyParts, fakeBodyParts = {
	["Head"] = character:FindFirstChild(options.headName),
	["LeftHand"] = character:FindFirstChild("Pal Hair"),
	["RightHand"] = character:FindFirstChild("Right Arm")
}, {
	["Head"] = createPart("vrHead", Vector3.one),
	["LeftHand"] = createPart("vrLArm", Vector3.new(1, 1, 2)),
	["RightHand"] = createPart("vrRArm", Vector3.new(1, 1, 2))
}
-- main
camera.CameraType = Enum.CameraType.Scriptable
camera.HeadScale = 3

task.defer(function()
	camera.CFrame = (CFrame.identity + camera.CFrame.Position)
	rootPart.Anchored, torso.Anchored = true, true

	for partName, object in pairs(bodyParts) do
		if object and object:FindFirstChild("Handle") then
			sethiddenproperty(object, "BackendAccoutrementState", 0)
			object.Handle:BreakJoints()
			destroyFunc(object:FindFirstChildWhichIsA("MeshPart", true) or object:FindFirstChildWhichIsA("SpecialMesh", true))
			createWeld(object, fakeBodyParts[partName])
		end
	end

	humanoid.AnimationPlayed:Connect(function(animation)
		animation:Stop()
	end)
	for _, animation in ipairs(humanoid:GetPlayingAnimationTracks()) do
		animation:AdjustSpeed(0)
	end
end)

do
	settings().Physics.AllowSleep = false
	settings().Physics.ThrottleAdjustTime = math.huge
	settings().Physics.PhysicsEnvironmentalThrottle = Enum.EnviromentalPhysicsThrottle.Disabled
	sethiddenproperty(workspace, "HumanoidOnlySetCollisionsOnStateChange", Enum.HumanoidOnlySetCollisionsOnStateChange.Disabled)
	sethiddenproperty(workspace, "InterpolationThrottling", Enum.InterpolationThrottlingMode.Disabled)
	sethiddenproperty(humanoid, "InternalBodyScale", Vector3.one * 9e99)
	sethiddenproperty(humanoid, "InternalHeadScale", 9e99)
	player.ReplicationFocus = workspace

	runService.Heartbeat:Connect(function()
		for _, object in ipairs(bodyParts) do
			object = (object:IsA("Accessory") and object:FindFirstChild("Handle") or nil)
			if object then
				object.CanCollide, object.Massless = false, true
				object.Velocity, object.RotVelocity = _G.Settings.Velocity, Vector3.zero
				sethiddenproperty(object, "NetworkIsSleeping", false)
				sethiddenproperty(object, "NetworkOwnershipRule", Enum.NetworkOwnership.Manual)
			end
		end
	end)
end

if VRService.VREnabled then
	inputService.UserCFrameChanged:Connect(function(type, value)
		userCFrameChanged:Fire(type, value)
	end)
else -- TODO: make a compatible shenanigans for pc

end

userCFrameChanged.Event:Connect(function(type, value)
	local bodyPartObj = fakeBodyParts[type.Name]
	if bodyPartObj then
		bodyPartObj.CFrame = camera.CFrame * ((CFrame.identity + (value.Position * (camera.HeadScale - 1))) * value * CFrame.Angles(unpackOrientation(options.rotationOffset[type.Name] or Vector3.zero, true)))
	end
end)

runService.RenderStepped:Connect(function()
	if R1ButtonDown then
		camera.CFrame = camera.CFrame:Lerp(camera.CFrame + (fakeBodyParts.RightHand.CFrame * CFrame.Angles(unpackOrientation(options.rotationOffset.RightHand - (Vector3.zAxis * 180)))).LookVector * (camera.HeadScale / 2), .5)
	end
end)

inputService.InputBegan:Connect(function(input)
	if (input.KeyCode == Enum.KeyCode.ButtonR1 or input.UserInputType == Enum.UserInputType.MouseButton1) then
		R1ButtonDown = true
	end
end)

inputService.InputChanged:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.ButtonR1 then
		R1ButtonDown = (if input.Position.Z > .9 then true else false)
	end
end)

inputService.InputEnded:Connect(function(input)
	if (input.KeyCode == Enum.KeyCode.ButtonR1 or input.UserInputType == Enum.UserInputType.MouseButton1) then
		R1ButtonDown = false
	end
end)