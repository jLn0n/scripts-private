-- services
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
local resetBindable = Instance.new("BindableEvent")
local partHandles, partArcHandles, weldHolder = Instance.new("Handles"), Instance.new("ArcHandles"), Instance.new("Part")
weldHolder.Anchored, weldHolder.Name, weldHolder.Position, weldHolder.Transparency = true, "WeldHolder", Vector3.zero, 1
partHandles.Style = Enum.HandlesStyle.Movement
partHandles.Transparency, partArcHandles.Transparency = 0, 0
partHandles.Parent, partArcHandles.Parent, weldHolder.Parent = coreGui.RobloxGui, coreGui.RobloxGui, workspace
-- variables
local controllingPart, resetBindableConnection, handlesDragArgs
local controlMode = 1 -- 1 = move | 2 = rotate
local partControllers = table.create(0)
local moveIncrement, rotationIncrement = 2.5, math.rad(5)
local arcPrevAngle = 0
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
	}
end
local function getPartFromMouseHit()
	local cameraPos = camera.CFrame.Position
	local rayResult = workspace:Raycast(cameraPos, CFrame.new(cameraPos, mouse.Hit.Position).LookVector * 5000, hitRayParams)

	if rayResult then
		return rayResult.Instance
	end
end
local function unpackOrientation(vect3, useRadians)
	vect3 = useRadians and vect3 * (math.pi / 180) or vect3
	return vect3.X, vect3.Y, vect3.Z
end
local function wrapArgsPack()
	return function(...)
		handlesDragArgs = table.pack(...)
	end
end
-- main
_G.Connections = _G.Connections or table.create(0)
for _, connection in ipairs(_G.Connections) do connection:Disconnect() end;table.clear(_G.Connections)

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
		elseif object:IsA("BasePart") and object.Name ~= "Head" then
			destroyFunc(object)
		end
	end
end)

_G.Connections[#_G.Connections + 1] = runService.Heartbeat:Connect(function()
	for basePart, partData in pairs(partControllers) do
		if not basePart:IsDescendantOf(workspace) then
			partControllers[basePart] = nil
			continue
		end
		partData.attachment.CFrame = partData.cframe
		basePart.CanCollide, basePart.Massless, basePart.RootPriority = false, false, 127
		basePart.Velocity, basePart.RotVelocity = Vector3.yAxis * 30, Vector3.zero
		sethiddenproperty(basePart, "NetworkIsSleeping", false)
		sethiddenproperty(basePart, "NetworkOwnershipRule", Enum.NetworkOwnership.Manual)
	end
	partHandles.Visible = (controlMode == 1 and partHandles.Adornee) and true or false
	partArcHandles.Visible = (controlMode == 2 and partArcHandles.Adornee) and true or false
end)

_G.Connections[#_G.Connections + 1] = runService.Heartbeat:Connect(function()
	local partData = partControllers[controllingPart]
	if partData and handlesDragArgs then
		if controlMode == 1 then
			local face, distance = unpack(handlesDragArgs)
			partData.cframe += (Vector3.fromNormalId(face) * math.floor(distance / moveIncrement + .5) / moveIncrement)
		elseif controlMode == 2 then
			local axis, relativeAngle = unpack(handlesDragArgs)
			local currentAngle = (math.floor(relativeAngle / rotationIncrement + .5) * rotationIncrement)
			partControllers[controllingPart].cframe *= CFrame.fromAxisAngle(Vector3.fromAxis(axis), currentAngle - arcPrevAngle) --CFrame.Angles(unpackOrientation(axisAngle))
			arcPrevAngle = currentAngle
		end
		handlesDragArgs = nil
	end
end)

_G.Connections[#_G.Connections + 1] = inputService.InputBegan:Connect(function(input)
	if not inputService:GetFocusedTextBox() then
		if input.UserInputType == Enum.UserInputType.MouseButton1 and inputService:IsKeyDown(Enum.KeyCode.Q) then
			local targetPart = getPartFromMouseHit()
			controllingPart = (if targetPart and targetPart:IsDescendantOf(character) and not (targetPart.Anchored or targetPart:IsGrounded()) then targetPart else nil) --(targetPart and targetPart:IsDescendantOf(character) and (not (targetPart.Anchored or targetPart:IsGrounded()) or #targetPart:GetJoints() == 0)) and targetPart or nil
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

_G.Connections[#_G.Connections + 1] = partHandles.MouseDrag:Connect(wrapArgsPack())
_G.Connections[#_G.Connections + 1] = partArcHandles.MouseDrag:Connect(wrapArgsPack())

resetBindableConnection = resetBindable.Event:Connect(function()
	starterGui:SetCore("ResetButtonCallback", true)
	resetBindableConnection:Disconnect()
	local daModel = Instance.new("Model")
	local _daModelHumanoid = Instance.new("Humanoid")
	_daModelHumanoid.Parent = daModel
	player.Character = daModel
	task.delay(players.RespawnTime + .05, destroyFunc, daModel)
end)
starterGui:SetCore("ResetButtonCallback", resetBindable)
