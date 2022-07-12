--[[
	TODO:
	  #1 (done): head should fly
	  #2: fix the rotation being fucked up sometimes
	  #3: add gui configuration?
	  #4: have a properly working script of this
	  #5: make the move tools works like in roblox studio
	  #6: the move should be relative to the part rotation
--]]
-- services
local contextActionService = game:GetService("ContextActionService")
local coreGui = game:GetService("CoreGui")
local inputService = game:GetService("UserInputService")
local players = game:GetService("Players")
local runService = game:GetService("RunService")
local starterGui = game:GetService("StarterGui")
-- objects
local camera = workspace.CurrentCamera
local player = players.LocalPlayer
local mouse = player:GetMouse()
local character = player.Character
local head = character:FindFirstChild("Head")
local resetBindable = Instance.new("BindableEvent")
local partHandles, partArcHandles, weldHolder = Instance.new("Handles"), Instance.new("ArcHandles"), Instance.new("Part")
weldHolder.Anchored, weldHolder.Name, weldHolder.Position, weldHolder.Transparency = true, "WeldHolder", Vector3.zero, 1
partHandles.Style = Enum.HandlesStyle.Movement
partHandles.Transparency, partArcHandles.Transparency = 0, 0
partHandles.Parent, partArcHandles.Parent, weldHolder.Parent = coreGui.RobloxGui, coreGui.RobloxGui, workspace
-- variables
local controllingPart
local Freecam
local moveIncrement, rotationIncrement = .5, 45
local controlMode = 1 -- 1 = move | 2 = rotate
local partControllers = table.create(0)
local handlesInternals = {
	args = nil,
}
local hitRayParams = RaycastParams.new()
hitRayParams.FilterType = Enum.RaycastFilterType.Blacklist
hitRayParams.FilterDescendantsInstances = {character.Head, weldHolder}
-- functions
local destroyFunc = character.Destroy
local function createPartWeld(basePart)
	if not basePart then return end
	local alignPos, alignOrt = Instance.new("AlignPosition"), Instance.new("AlignOrientation")
	local attachment, _attachment = Instance.new("Attachment"), Instance.new("Attachment")
	alignPos.ApplyAtCenterOfMass = true
	alignPos.MaxForce, alignOrt.MaxTorque = 9e9, math.huge
	alignPos.MaxVelocity, alignOrt.MaxAngularVelocity = math.huge, math.huge
	alignPos.ReactionForceEnabled, alignOrt.ReactionTorqueEnabled = false, false
	alignPos.Responsiveness, alignOrt.Responsiveness = 200, 200
	alignPos.RigidityEnabled, alignOrt.RigidityEnabled = false, false
	alignPos.Attachment0, alignOrt.Attachment0 = _attachment, _attachment
	alignPos.Attachment1, alignOrt.Attachment1 = attachment, attachment
	alignPos.Parent, alignOrt.Parent = basePart, basePart
	attachment.Parent, _attachment.Parent = weldHolder, basePart
	partControllers[basePart] = {
		attachment = attachment,
		cframe = CFrame.identity,
		_internal = {
			prevRotAngleAxis = 0,
			prevRotAxis = nil,
			oldCurrentCFrame = nil
		}
	}
end
local function getFocusDistance(cameraFrame)
	local znear = 0.1
	local viewport = camera.ViewportSize
	local projy = 2 * math.tan(camera.FieldOfView / 2)
	local projx = viewport.X / viewport.Y * projy
	local fx = cameraFrame.RightVector
	local fy = cameraFrame.UpVector
	local fz = cameraFrame.LookVector

	local minVect = Vector3.zero
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
local function getPartFromMouseHit()
	local cameraPos = camera.CFrame.Position
	local rayResult = workspace:Raycast(cameraPos, CFrame.new(cameraPos, mouse.Hit.Position).LookVector * 5000, hitRayParams)

	if rayResult then
		return rayResult.Instance
	end
end
local function snapToClosestIncrement(axisValue)
	local rotIncToRad = math.rad(rotationIncrement)
	local leftOvers = axisValue % rotIncToRad
	local roundedNum = math.floor((leftOvers / rotIncToRad) + .5)
	local divisions = (axisValue - leftOvers) / rotIncToRad
	divisions += 1 * roundedNum
	return rotIncToRad * divisions -- snapNumber
end
local function unpackOrientation(vectRot, dontUseRadians)
	vectRot = (if not dontUseRadians then vectRot * (math.pi / 180) else vectRot)
	return vectRot.X, vectRot.Y, (if typeof(vectRot) == "Vector2" then 0 else vectRot.Z)
end
local function wrapArgsPack()
	return function(...)
		handlesInternals.args = table.pack(...)
	end
end
-- main
_G.Connections = _G.Connections or table.create(0)
task.defer(function()
	player.Character = nil
	player.Character = character
	task.wait(players.RespawnTime + .05)
	destroyFunc(character.HumanoidRootPart)

	for _, object in ipairs(character:GetChildren()) do
		if object:IsA("Accoutrement") then
			sethiddenproperty(object, "BackendAccoutrementState", 0)
			destroyFunc(object.Handle:FindFirstChildWhichIsA("Weld"))
			destroyFunc(object:FindFirstChildWhichIsA("MeshPart", true) or object:FindFirstChildWhichIsA("SpecialMesh", true))
			if not object.Handle.CanCollide then
				createPartWeld(object.Handle)
			end
		elseif object:IsA("BasePart") and (object.Name ~= "Head") then
			destroyFunc(object)
		end
	end
end)

do -- camera stuff
	-- variables
	local camRotation, camPosition = Vector2.new(camera.CFrame:ToEulerAnglesYXZ()), camera.CFrame.Position
	-- main
	camera.CameraType = Enum.CameraType.Custom
	camera.CameraSubject = nil

	do -- actually taken off from the Freecam.lua but I removed the spring stuff and the gamepad controls
		Freecam = {
			Constants = {
				PAN_GAIN = Vector2.new(0.75, 1) * 4,
				NAV_GAIN = Vector3.one * 64,
				PITCH_LIMIT = math.rad(90)
			}
		}

		local keyboard = {
			W = 0,
			A = 0,
			S = 0,
			D = 0,
			Up = 0,
			Down = 0,
			LeftShift = 0,
			RightShift = 0
		}

		local mouseDelta = Vector2.zero

		local NAV_KEYBOARD_SPEED = Vector3.one
		local PAN_MOUSE_SPEED = Vector2.one * (math.pi / 96)
		local NAV_ADJ_SPEED = 0.75
		local NAV_SHIFT_MUL = 0.25

		local navSpeed = 1

		function Freecam.Vel(dt)
			navSpeed = math.clamp(navSpeed + dt * (keyboard.Up - keyboard.Down) * NAV_ADJ_SPEED, 0.01, 4)

			local kKeyboard = Vector3.new(
				keyboard.D - keyboard.A,
				0,
				keyboard.S - keyboard.W
			) * NAV_KEYBOARD_SPEED

			local shift =
				inputService:IsKeyDown(Enum.KeyCode.LeftShift) or
				inputService:IsKeyDown(Enum.KeyCode.RightShift)

			return kKeyboard * (navSpeed * (shift and NAV_SHIFT_MUL or 1))
		end

		function Freecam.Pan(dt)
			local kMouse = mouseDelta * PAN_MOUSE_SPEED
			mouseDelta = Vector2.zero
			return kMouse
		end

		do
			local function Keypress(action, state, input)
				keyboard[input.KeyCode.Name] = (state == Enum.UserInputState.Begin and 1 or 0)
				return Enum.ContextActionResult.Sink
			end

			local function MousePan(action, state, input)
				local delta = input.Delta
				mouseDelta = -Vector2.new(delta.Y, delta.X)
				return Enum.ContextActionResult.Sink
			end

			local function Zero(t)
				for k, v in pairs(t) do
					t[k] = v * 0
				end
			end

			function Freecam.StartCapture()
				contextActionService:BindActionAtPriority(
					"Freecam_Keyboard",
					Keypress,
					false,
					Enum.ContextActionPriority.High.Value,
					Enum.KeyCode.W,
					Enum.KeyCode.A,
					Enum.KeyCode.S,
					Enum.KeyCode.D,
					Enum.KeyCode.Up,
					Enum.KeyCode.Down
				)
				contextActionService:BindActionAtPriority(
					"Freecam_MousePan",
					MousePan,
					false,
					Enum.ContextActionPriority.High.Value,
					Enum.UserInputType.MouseMovement
				)
			end

			function Freecam.StopCapture()
				navSpeed = 1
				Zero(keyboard)
				mouseDelta *= 0
				contextActionService:UnbindAction("Freecam_Keyboard")
				contextActionService:UnbindAction("Freecam_MousePan")
			end
		end
	end

	local function stepFreecam(deltaTime)
		local vel = Freecam.Vel(deltaTime)
		local pan = Freecam.Pan(deltaTime)

		local zoomFactor = math.sqrt(math.tan(math.rad(70 / 2)) / math.tan(math.rad(camera.FieldOfView / 2)))

		camRotation += pan * Freecam.Constants.PAN_GAIN * (deltaTime / zoomFactor)
		camRotation = Vector2.new(
			math.clamp(camRotation.X, -Freecam.Constants.PITCH_LIMIT, Freecam.Constants.PITCH_LIMIT),
			camRotation.Y % (2 * math.pi)
		)

		local camCFrame = (
			(CFrame.identity + camPosition) *
			CFrame.fromOrientation(unpackOrientation(camRotation, true)) *
			(CFrame.identity + (vel * Freecam.Constants.NAV_GAIN * deltaTime))
		)
		camPosition = camCFrame.Position

		camera.CFrame = camCFrame
		camera.Focus = camCFrame * (CFrame.identity + (Vector3.zAxis * -getFocusDistance(camCFrame)))
	end

	Freecam.StartCapture()
	inputService.MouseBehavior = Enum.MouseBehavior.Default
	runService:BindToRenderStep("Freecam", Enum.RenderPriority.Camera.Value, stepFreecam)
end

_G.Connections[#_G.Connections + 1] = runService.Heartbeat:Connect(function()
	for basePart, partData in pairs(partControllers) do
		if not basePart:IsDescendantOf(workspace) then
			partControllers[basePart] = nil
			continue
		end
		partData.attachment.CFrame = partData.cframe
		basePart.CanCollide, basePart.Massless, basePart.RootPriority = false, true, 127
		basePart.Velocity, basePart.RotVelocity = Vector3.yAxis * 30, Vector3.zero
		sethiddenproperty(basePart, "NetworkIsSleeping", false)
		sethiddenproperty(basePart, "NetworkOwnershipRule", Enum.NetworkOwnership.Manual)
	end
	partHandles.Visible = (controlMode == 1 and partHandles.Adornee) and true or false
	partArcHandles.Visible = (controlMode == 2 and partArcHandles.Adornee) and true or false
end)

_G.Connections[#_G.Connections + 1] = runService.Heartbeat:Connect(function()
	local partData = partControllers[controllingPart]
	if partData and handlesInternals.args then
		if controlMode == 1 then
			local face, distance = unpack(handlesInternals.args)
			distance = math.round(distance / moveIncrement) * moveIncrement
			partData.cframe = (partData._internal.oldCurrentCFrame + (Vector3.fromNormalId(face) * distance))
		elseif controlMode == 2 then -- TODO #2
			local axis, relativeAngle = unpack(handlesInternals.args)
			local currentAngle = snapToClosestIncrement(relativeAngle)
			partData.cframe *= CFrame.fromAxisAngle(
				Vector3.fromAxis(axis),
				currentAngle - (if (axis == partData._internal.prevRotAxis) then partData._internal.prevRotAngleAxis else 0)
			)
			partData._internal.prevRotAngleAxis, partData._internal.prevRotAxis = currentAngle, axis
		end
		handlesInternals.args = nil
	end

	head.CFrame = camera.CFrame
end)

_G.Connections[#_G.Connections + 1] = inputService.InputBegan:Connect(function(input)
	if not inputService:GetFocusedTextBox() then
		if input.UserInputType == Enum.UserInputType.MouseButton1 and inputService:IsKeyDown(Enum.KeyCode.Q) then
			local targetPart = getPartFromMouseHit()
			controllingPart = (if targetPart and not (targetPart.Anchored or targetPart:IsGrounded()) then targetPart else nil)
			partHandles.Adornee, partArcHandles.Adornee = controllingPart, controllingPart
			if (controllingPart and not partControllers[controllingPart]) then createPartWeld(controllingPart) end
		elseif input.UserInputType == Enum.UserInputType.Keyboard then
			if input.KeyCode == Enum.KeyCode.E and controlMode ~= 1 then
				controlMode = 1
			elseif input.KeyCode == Enum.KeyCode.R and controlMode ~= 2 then
				controlMode = 2
			end
		end
	end
end)

_G.Connections[#_G.Connections + 1] = partHandles.MouseButton1Down:Connect(function()
	local partData = partControllers[controllingPart]
	if partData then
		partData._internal.oldCurrentCFrame = partData.cframe
	end
end)
_G.Connections[#_G.Connections + 1] = partHandles.MouseDrag:Connect(wrapArgsPack())
_G.Connections[#_G.Connections + 1] = partArcHandles.MouseDrag:Connect(wrapArgsPack())

_G.Connections[#_G.Connections + 1] = resetBindable.Event:Connect(function()
	for _, connection in ipairs(_G.Connections) do connection:Disconnect() end; table.clear(_G.Connections)
	starterGui:SetCore("ResetButtonCallback", true)

	local daModel = Instance.new("Model")
	local _daModelHumanoid = Instance.new("Humanoid")
	_daModelHumanoid.Parent = daModel

	Freecam.StopCapture()
	runService:UnbindFromRenderStep("Freecam")
	player.Character = daModel
	task.delay(players.RespawnTime + .05, destroyFunc, daModel)
end)
starterGui:SetCore("ResetButtonCallback", resetBindable)
