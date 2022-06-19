--[[
	TODO:
	  #1: head should fly
	  #2: fix the rotation being fucked up sometimes
	  #3: add gui configuration?
	  #4: have a properly working script of this
	  #5: make the move tools works like in roblox studio
--]]
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
local controllingPart
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
local function unpackOrientation(vect3, useRadians)
	vect3 = (if useRadians then vect3 * (math.pi / 180) else vect3)
	return vect3.X, vect3.Y, vect3.Z
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
				currentAngle - (if (partData._internal.prevRotAxis == axis) then partData._internal.prevRotAngleAxis else 0)
			)
			partData._internal.prevRotAngleAxis, partData._internal.prevRotAxis = currentAngle, axis
		end
		handlesInternals.args = nil
	end
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
	player.Character = daModel
	task.delay(players.RespawnTime + .05, destroyFunc, daModel)
end)
starterGui:SetCore("ResetButtonCallback", resetBindable)
