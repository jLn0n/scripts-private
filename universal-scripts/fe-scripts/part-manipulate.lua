-- based on: https://github.com/jLn0n/scripts-private/blob/main/celery-scripts/control-parts.lua without the rnet stuff (u will be missed :( )
-- services
local players = game:GetService("Players")
local inputService = game:GetService("UserInputService")
-- objects
local player = players.LocalPlayer
local mouse = player:GetMouse()
local attachment, _attachment = Instance.new("Attachment"), Instance.new("Attachment")
local weldHolder, alignPos, alignOrt = Instance.new("Part"), Instance.new("AlignPosition"), Instance.new("AlignOrientation")
weldHolder.Anchored, weldHolder.CanCollide, weldHolder.Name, weldHolder.Position, weldHolder.Transparency = true, false, "WeldHolder", Vector3.zero, .5
weldHolder.Parent = workspace
-- variables
local controllingPart, rootPart, currentPartPos
-- functions
local function setPartWeld(partObj)
	_attachment.Parent = partObj
	alignPos.Parent, alignOrt.Parent = partObj, partObj
end
local function disablePhysicsManipulator(partObj)
	if not partObj then return end
	for _, _object in ipairs(partObj:GetChildren()) do
		if _object:IsA("LuaSourceContainer") and not _object:IsA("ModuleScript") then -- uhh idk about this one
			_object.Disabled = true
		elseif _object:IsA("BodyMover") then
			_object:Destroy()
		end
	end
end
local function getPartNetOwnership(partObj)
	if not partObj then return end
	local oldPos, canCollideCache = rootPart.CFrame, partObj.CanCollide
	partObj.CanCollide = false
	rootPart.CFrame = partObj.CFrame
	task.wait()
	rootPart.CFrame = oldPos
	partObj.CanCollide = canCollideCache
end
-- main
do -- alignPos/Ort init
	alignPos.ApplyAtCenterOfMass = true
	alignPos.MaxForce, alignOrt.MaxTorque = 10e9, math.huge
	alignPos.MaxVelocity, alignOrt.MaxAngularVelocity = math.huge, math.huge
	alignPos.ReactionForceEnabled, alignOrt.ReactionTorqueEnabled = false, false
	alignPos.Responsiveness, alignOrt.Responsiveness = 200, 200
	alignPos.RigidityEnabled, alignOrt.RigidityEnabled = true, true -- what to decide here?
	alignPos.Attachment0, alignOrt.Attachment0 = _attachment, _attachment
	alignPos.Attachment1, alignOrt.Attachment1 = attachment, attachment
	attachment.Parent, _attachment.Parent = weldHolder, nil
end

inputService.InputBegan:Connect(function(input)
	if not inputService:GetFocusedTextBox() then
		if input.UserInputType == Enum.UserInputType.Keyboard then
			if input.KeyCode == Enum.KeyCode.KeypadOne then
				controllingPart = nil
				setPartWeld(nil)
			elseif input.KeyCode == Enum.KeyCode.KeypadZero then
				player.Character:MoveTo(controllingPart and controllingPart.Position or (rootPart and rootPart.Position or Vector3.zero))
			end
		elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
			if inputService:IsKeyDown(Enum.KeyCode.X) then
				local targetPart = mouse.Target
				if rootPart and targetPart and not targetPart.Anchored and (not targetPart:IsGrounded() and #targetPart:GetJoints() == 0) then
					controllingPart, currentPartPos = targetPart, rootPart.Position
					setPartWeld(controllingPart)
					disablePhysicsManipulator(controllingPart)
					for _ = 1, 5 do task.wait()
						getPartNetOwnership(controllingPart)
						controllingPart.Position = rootPart.Position
					end
					player.Character:MoveTo(currentPartPos)
				end
			elseif inputService:IsKeyDown(Enum.KeyCode.Z) and controllingPart then
				currentPartPos = mouse.Hit.Position
			end
		end
	end
end)

while true do task.wait()
	--setsimulationradius(0x7fff, 0x7fff)
	rootPart = (if player.Character then player.Character.PrimaryPart else nil)
	weldHolder.Position = (currentPartPos or Vector3.zero)
	if controllingPart then
		controllingPart.CustomPhysicalProperties = PhysicalProperties.new(0, 0, 0, 0, 0)
		controllingPart.RotVelocity = Vector3.zero
		controllingPart.Velocity = (Vector3.yAxis * 30.05)
		controllingPart.Velocity = -controllingPart.Velocity
	end
end
