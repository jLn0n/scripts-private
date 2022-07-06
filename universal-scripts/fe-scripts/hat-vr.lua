-- options
local options = table.create(0)
options.headName = "MediHood"

options.headScale = 3
options.rotationOffset = {
	["LeftHand"] = Vector3.new(),
	["RightHand"] = Vector3.new()
}
-- services
local contextActionService = game:GetService("ContextActionService")
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
-- variables
local bodyParts, fakeBodyParts
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
local function GetFocusDistance(cameraFrame)
	local znear = 0.1
	local viewport = camera.ViewportSize
	local projy = 2 * math.tan(camera.FieldOfView / 2)
	local projx = viewport.X / viewport.Y * projy
	local fx = cameraFrame.RightVector
	local fy = cameraFrame.UpVector
	local fz = cameraFrame.LookVector

	local minVect = Vector3.new()
	local minDist = 512

	for x = 0, 1, 0.5 do
		for y = 0, 1, 0.5 do
			local cx = (x - 0.5) * projx
			local cy = (y - 0.5) * projy
			local offset = fx * cx - fy * cy + fz
			local origin = cameraFrame.p + offset * znear
			local rayResult = workspace:Raycast(origin, offset.unit * minDist)
			if rayResult then
				local dist = (rayResult.Position - origin).Magnitude
				if minDist > dist then
					minDist = dist
					minVect = offset.unit
				end
			end
		end
	end

	return fz:Dot(minVect) * minDist
end
local function unpackOrientation(vectRot, useRadians)
	vectRot = (if useRadians then vectRot * (math.pi / 180) else vectRot)
	return vectRot.X, vectRot.Y, (if typeof(vectRot) == "Vector2" then 0 else vectRot.Z)
end
-- main
bodyParts, fakeBodyParts = {
	["Head"] = character:FindFirstChild(options.headName),
	["LeftHand"] = character:FindFirstChild("Pal Hair"),
	["RightHand"] = character:FindFirstChild("Right Arm")
}, {
	["Head"] = createPart("vrHead", Vector3.one),
	["LeftHand"] = createPart("vrLArm", Vector3.new(1, 1, 2)),
	["RightHand"] = createPart("vrRArm", Vector3.new(1, 1, 2))
}

camera.HeadScale = 3

task.defer(function()
	camera.CFrame = (CFrame.identity + camera.CFrame.Position)
	rootPart.Anchored, torso.Anchored = true, true

	for partName, object in pairs(bodyParts) do
		if object and object:FindFirstChild("Handle") then
			--sethiddenproperty(object, "BackendAccoutrementState", 1)
			object.Handle:BreakJoints()
			createWeld(object, fakeBodyParts[partName])
			if partName ~= "Head" then
				destroyFunc(object:FindFirstChildWhichIsA("MeshPart", true) or object:FindFirstChildWhichIsA("SpecialMesh", true))
			end
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
	camera.CameraType = Enum.CameraType.Scriptable

	local R1ButtonDown = false

	inputService.UserCFrameChanged:Connect(function(type, value)
		userCFrameChanged:Fire(type, value)
	end)

	runService.RenderStepped:Connect(function()
		if R1ButtonDown then
			camera.CFrame = camera.CFrame:Lerp(camera.CFrame + (fakeBodyParts.RightHand.CFrame * CFrame.Angles(unpackOrientation(options.rotationOffset.RightHand - (Vector3.zAxis * 180)))).LookVector * (camera.HeadScale / 2), .5)
		end
	end)

	inputService.InputBegan:Connect(function(input)
		if (input.KeyCode == Enum.KeyCode.ButtonR1) then
			R1ButtonDown = true
		end
	end)

	inputService.InputChanged:Connect(function(input)
		if input.KeyCode == Enum.KeyCode.ButtonR1 then
			R1ButtonDown = (if input.Position.Z > .9 then true else false)
		end
	end)

	inputService.InputEnded:Connect(function(input)
		if (input.KeyCode == Enum.KeyCode.ButtonR1) then
			R1ButtonDown = false
		end
	end)
else
	camera.CameraType = Enum.CameraType.Custom
	camera.CameraSubject = nil

	local camRotation, camPosition = Vector2.new(camera.CFrame:ToEulerAnglesYXZ()), camera.CFrame.Position

	local VRCamSettings = {
		PAN_GAIN = Vector2.new(0.75, 1) * 8,
		NAV_GAIN = Vector3.one * 64,
		PITCH_LIMIT = math.rad(90)
	}

	local VRInput do
		VRInput = {}

		local keyboard = {
			W = 0,
			A = 0,
			S = 0,
			D = 0,
			E = 0,
			Q = 0,
			Up = 0,
			Down = 0,
			LeftShift = 0,
			RightShift = 0
		}

		local mouse = {
			Delta = Vector2.zero,
		}

		local NAV_KEYBOARD_SPEED = Vector3.one
		local PAN_MOUSE_SPEED = Vector2.one * (math.pi / 128)
		local NAV_ADJ_SPEED = 0.75
		local NAV_SHIFT_MUL = 0.25

		local navSpeed = 1

		function VRInput.Vel(dt)
			navSpeed = math.clamp(navSpeed + dt * (keyboard.Up - keyboard.Down) * NAV_ADJ_SPEED, 0.01, 4)

			local kKeyboard = Vector3.new(
				keyboard.D - keyboard.A,
				keyboard.E - keyboard.Q,
				keyboard.S - keyboard.W
			) * NAV_KEYBOARD_SPEED

			local shift =
				inputService:IsKeyDown(Enum.KeyCode.LeftShift) or
				inputService:IsKeyDown(Enum.KeyCode.RightShift)

			return kKeyboard * (navSpeed * (shift and NAV_SHIFT_MUL or 1))
		end

		function VRInput.Pan(dt)
			local kMouse = mouse.Delta * PAN_MOUSE_SPEED
			mouse.Delta = Vector2.zero
			return kMouse
		end

		do
			local function Keypress(action, state, input)
				keyboard[input.KeyCode.Name] = state == Enum.UserInputState.Begin and 1 or 0
				return Enum.ContextActionResult.Sink
			end

			local function MousePan(action, state, input)
				local delta = input.Delta
				mouse.Delta = -Vector2.new(delta.Y, delta.X)
				return Enum.ContextActionResult.Sink
			end

			local function Zero(t)
				for k, v in pairs(t) do
					t[k] = v * 0
				end
			end

			function VRInput.StartCapture()
				contextActionService:BindActionAtPriority(
					"VRKeyboard",
					Keypress,
					false,
					Enum.ContextActionPriority.High.Value,
					Enum.KeyCode.W,
					Enum.KeyCode.A,
					Enum.KeyCode.S,
					Enum.KeyCode.D,
					Enum.KeyCode.E,
					Enum.KeyCode.Q,
					Enum.KeyCode.Up,
					Enum.KeyCode.Down
				)
				contextActionService:BindActionAtPriority(
					"VRMousePan",
					MousePan,
					false,
					Enum.ContextActionPriority.High.Value,
					Enum.UserInputType.MouseMovement
				)
			end

			function VRInput.StopCapture()
				navSpeed = 1
				Zero(keyboard)
				Zero(mouse)
				contextActionService:UnbindAction("VRKeyboard")
				contextActionService:UnbindAction("VRMousePan")
			end
		end
	end

	local function stepVRCam(deltaTime)
		local vel = VRInput.Vel(deltaTime)
		local pan = VRInput.Pan(deltaTime)

		local zoomFactor = math.sqrt(math.tan(math.rad(70 / 2)) / math.tan(math.rad(camera.FieldOfView / 2)))

		camRotation += pan * VRCamSettings.PAN_GAIN * (deltaTime / zoomFactor)
		camRotation = Vector2.new(
			math.clamp(camRotation.X, -VRCamSettings.PITCH_LIMIT,
			VRCamSettings.PITCH_LIMIT), camRotation.Y % (2 * math.pi)
		)

		local camCFrame = (
			(CFrame.identity + camPosition) *
			CFrame.fromOrientation(unpackOrientation(camRotation)) *
			(CFrame.identity + (vel * VRCamSettings.NAV_GAIN * deltaTime))
		)
		camPosition = camCFrame.Position

		camera.CFrame = camCFrame
		camera.Focus = camCFrame * (CFrame.identity + (Vector3.zAxis * -GetFocusDistance(camCFrame)))
	end

	-- TODO: Calculate the correct VR position
	local function stepVRLocation(deltaTime)
		local headCFrame = camera.CFrame:ToObjectSpace()
		print(headCFrame)
		local rHandCFrame = (
			headCFrame *
			(CFrame.identity + (Vector3.new(2.75, -5, -2.5)))
		)
		local lHandCFrame = (
			headCFrame *
			(CFrame.identity + (Vector3.new(-2.75, -5, -2.5)))
		)

		userCFrameChanged:Fire(Enum.UserCFrame.Head, headCFrame)
		userCFrameChanged:Fire(Enum.UserCFrame.RightHand, rHandCFrame)
		userCFrameChanged:Fire(Enum.UserCFrame.LeftHand, lHandCFrame)
	end

	VRInput.StartCapture()
	inputService.MouseBehavior = Enum.MouseBehavior.Default
	runService:BindToRenderStep("VRCam", Enum.RenderPriority.Camera.Value, stepVRCam)
	runService:BindToRenderStep("VRInput", Enum.RenderPriority.Input.Value, stepVRLocation)
end

userCFrameChanged.Event:Connect(function(type, value)
	local bodyPartObj = fakeBodyParts[type.Name]
	if bodyPartObj then
		bodyPartObj.CFrame = camera.CFrame * ((CFrame.identity + (value.Position * (camera.HeadScale - 1))) * value * CFrame.Angles(unpackOrientation(options.rotationOffset[type.Name] or Vector3.zero, true)))
	end
end)
