-- based on: https://github.com/jLn0n/scripts-private/blob/main/celery-scripts/control-parts.lua without the rnet stuff (u will be missed :( )
-- services
local players = game:GetService("Players")
local inputService = game:GetService("UserInputService")
-- objects
local player = players.LocalPlayer
local mouse = player:GetMouse()
local character = player.Character
local rootPart = character.HumanoidRootPart
local attachment, _attachment = Instance.new("Attachment"), Instance.new("Attachment")
local weldHolder, alignPos, alignOrt = Instance.new("Part"), Instance.new("AlignPosition"), Instance.new("AlignOrientation")
weldHolder.Anchored, weldHolder.Name, weldHolder.Position, weldHolder.Transparency = true, "WeldHolder", Vector3.zero, .5
weldHolder.Parent = workspace
-- variables
local smoothMove = false
local disabledThingys = {}
local controllingPart, currentPartPos
-- functions
local function setPartWeld(partObj)
	_attachment.Parent = partObj
	alignPos.Parent, alignOrt.Parent = partObj, partObj
end
local function togglePhysicsManipulator(partObj, toggle) -- needs to optimize?
	if not partObj then return end
	if not disabledThingys[partObj] then
		disabledThingys[partObj] = (disabledThingys[partObj] or table.create(0))
		for _, object in ipairs(partObj:GetChildren()) do
			if (object:IsA("BodyMover") or (object:IsA("LuaSourceContainer") and not object:IsA("ModuleScript"))) then -- uhh idk about this one
				disabledThingys[partObj][object] = disabledThingys[partObj][object] or object.Parent
			end
		end
	end
	for object, cachedParent in pairs(disabledThingys[partObj]) do
		object.Parent = (if toggle then cachedParent else nil)
	end
end
local function claimPartNetOwnership(partObj)
	if not partObj then return end
	local oldPos = rootPart.Position
	character:PivotTo(partObj.CFrame)
	task.wait()
	task.delay(.075, character.MoveTo, character, oldPos)
end
-- main
do -- alignPos/Ort init
	alignPos.ApplyAtCenterOfMass = true
	alignPos.MaxForce, alignOrt.MaxTorque = math.huge, math.huge
	alignPos.MaxVelocity, alignOrt.MaxAngularVelocity = 10e10, 10e10
	alignPos.ReactionForceEnabled, alignOrt.ReactionTorqueEnabled = false, false
	alignPos.Responsiveness, alignOrt.Responsiveness = math.huge, math.huge
	alignPos.RigidityEnabled, alignOrt.RigidityEnabled = smoothMove, smoothMove -- what to decide here?
	alignPos.Attachment0, alignOrt.Attachment0 = _attachment, _attachment
	alignPos.Attachment1, alignOrt.Attachment1 = attachment, attachment
	attachment.Parent, _attachment.Parent = weldHolder, nil
end

inputService.InputBegan:Connect(function(input)
	if not inputService:GetFocusedTextBox() then
		if input.UserInputType == Enum.UserInputType.Keyboard then
			if input.KeyCode == Enum.KeyCode.KeypadOne then
				task.spawn(claimPartNetOwnership, controllingPart)
			elseif input.KeyCode == Enum.KeyCode.KeypadTwo then
				togglePhysicsManipulator(controllingPart, true)
				controllingPart = nil
				setPartWeld(nil)
			elseif input.KeyCode == Enum.KeyCode.KeypadZero then
				character:MoveTo(controllingPart and controllingPart.Position or (rootPart and rootPart.Position or Vector3.zero))
			end
		elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
			if inputService:IsKeyDown(Enum.KeyCode.X) then
				local targetPart = mouse.Target
				if rootPart and targetPart and not targetPart.Anchored and (not targetPart:IsGrounded() and #targetPart:GetJoints() == 0) then
					controllingPart, currentPartPos = targetPart, rootPart.Position
					for _ = 1, 5 do
						task.spawn(claimPartNetOwnership, controllingPart)
						controllingPart.Position = rootPart.Position
					end
					setPartWeld(controllingPart)
					togglePhysicsManipulator(controllingPart, false)
					character:MoveTo(currentPartPos)
				end
			elseif inputService:IsKeyDown(Enum.KeyCode.Z) and controllingPart then
				currentPartPos = mouse.Hit.Position
			end
		end
	end
end)

while true do task.wait()
	--setsimulationradius(0x7fff, 0x7fff)
	character, rootPart = (player.Character or nil), (if character then character.PrimaryPart else nil)
	weldHolder.Position = (currentPartPos or Vector3.zero)
	if controllingPart and controllingPart:IsDescendantOf(workspace) then
		weldHolder.Size, attachment.Position = Vector3.new(controllingPart.Size.X, .05, controllingPart.Size.Z), (Vector3.yAxis * ((controllingPart.Size.Y / 2) - weldHolder.Size.Y))
		controllingPart.CustomPhysicalProperties = PhysicalProperties.new(0, 0, 0, 0, 0)
		controllingPart.RotVelocity = Vector3.zero
		controllingPart.Velocity = (Vector3.yAxis * 30.05)
		controllingPart.Velocity = -controllingPart.Velocity
	end
end
