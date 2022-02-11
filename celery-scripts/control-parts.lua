-- services
local players = game:GetService("Players")
local inputService = game:GetService("UserInputService")
-- objects
local player = players.LocalPlayer
local mouse = player:GetMouse()
local partHolder = Instance.new("Part")
local partThingy, controlledPart, currentPickedPos
local cPartBodyPos, cPartBodyGyro
-- variables
local nonceCFrame = CFrame.new()
-- function
local function initFloaties(object)
	if not object then return end
	for _, _object in ipairs(object:GetChildren()) do
		if not (_object:IsA("LuaSourceContainer") or string.find(_object.ClassName, "Body")) then continue end
		_object:Destroy()
	end
	local bodyPos, bodyGyro = Instance.new("BodyPosition"), Instance.new("BodyGyro")
	bodyPos.D, bodyGyro.D = 50, 300
	bodyPos.MaxForce, bodyGyro.MaxTorque = Vector3.one * math.huge, Vector3.one * math.huge
	bodyPos.P, bodyGyro.P = 5000, 5000
	bodyPos.Parent, bodyGyro.Parent = object, object
	return bodyPos, bodyGyro
end
-- main
partHolder.Anchored, partHolder.Transparency, partHolder.Size, partHolder.Parent = true, .5, Vector3.new(2.5, .05, 2.5), workspace
inputService.InputBegan:Connect(function(input)
	if not inputService:GetFocusedTextBox() then
		if input.UserInputType == Enum.UserInputType.Keyboard then
			if input.KeyCode == Enum.KeyCode.KeypadZero then
				controlledPart, cPartBodyPos, cPartBodyGyro = nil, nil, nil
			elseif input.KeyCode == Enum.KeyCode.KeypadOne then
				player.Character:MoveTo(controlledPart.Position)
			end
		elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
			if inputService:IsKeyDown(Enum.KeyCode.X) then
				local targetPart = mouse.Target
				if partThingy and targetPart and not targetPart.Anchored and not targetPart:FindFirstChildWhichIsA("Weld", true) then
					cPartBodyPos, cPartBodyGyro = initFloaties(targetPart)
					controlledPart, currentPickedPos = targetPart, partThingy.Position
					for _ = 1, 5 do
						rnet.sendposition(targetPart.Position)
						targetPart.Position = currentPickedPos
						rnet.sendposition(partThingy.Position)
						task.wait()
					end
					player.Character:MoveTo(partThingy.Position)
				end
			elseif inputService:IsKeyDown(Enum.KeyCode.Z) and controlledPart then
				currentPickedPos = mouse.Hit.Position
			end
		end
	end
end)
while true do task.wait()
	partThingy = player.Character and player.Character:FindFirstChild("HumanoidRootPart") or nil
	if controlledPart and controlledPart:IsDescendantOf(workspace) and (cPartBodyPos and cPartBodyGyro) then
		cPartBodyPos.Position, cPartBodyGyro.CFrame = currentPickedPos, nonceCFrame
		partHolder.Position, partHolder.Size = controlledPart.Position + (Vector3.yAxis * ((controlledPart.Size.Y + partHolder.Size.Y) / 2)), Vector3.new(controlledPart.Size.X, .05, controlledPart.Size.Z)
		controlledPart.Velocity, controlledPart.RotVelocity = (Vector3.yAxis * 25.05), Vector3.zero
		controlledPart.AssemblyAngularVelocity, controlledPart.AssemblyLinearVelocity = Vector3.zero, Vector3.zero
		controlledPart.CustomPhysicalProperties = PhysicalProperties.new(0, 0, 0, 0, 0)
	end
end
