-- services
local players = game:GetService("Players")
local inputService = game:GetService("UserInputService")
-- objects
local player = players.LocalPlayer
local mouse = player:GetMouse()
local headPart = player.Character:FindFirstChild("Head")
local controlledPart, currentBodyPos, currentMousePos
-- functions
local function controlPart(object)
	if object:IsA("BasePart") and not object:IsDescendantOf(player.Character) then
		for _, sobject in ipairs(object:GetChildren()) do
			if sobject:IsA("Attachment") and sobject:IsA("AlignPosition") and sobject:IsA("Torque") and sobject:IsA("BodyMover") or sobject:IsA("RocketPropulsion") then
				sobject:Destroy()
			end
		end
		local bodyPos = Instance.new("BodyPosition")
		bodyPos.MaxForce = Vector3.one * 400
		bodyPos.Parent = object
		currentBodyPos = bodyPos
	end
end
-- main
inputService.InputBegan:Connect(function(input)
	if not inputService:GetFocusedTextBox() then
		if input.UserInputType == Enum.UserInputType.Keyboard then
			if input.KeyCode == Enum.KeyCode.KeypadZero then
				currentBodyPos = nil
			elseif input.KeyCode == Enum.KeyCode.KeypadOne then
				for _, object in ipairs(player.Character:GetChildren()) do
					if object:IsA("Tool") then
						object.Parent = workspace
					end
				end
			end
		elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
			if inputService:IsKeyDown(Enum.KeyCode.X) then
				local targetPart = mouse.Target
				if headPart and targetPart and not targetPart.Anchored then
					for _ = 1, 5 do
						rnet.sendposition(targetPart.Position)
						targetPart.CFrame = headPart.CFrame
						rnet.sendposition(headPart.Position)
						controlledPart = targetPart
					end
					currentMousePos = input.Position + Vector3.yAxis
					controlPart(targetPart)
					player.Character:MoveTo(headPart.Position)
				end
			elseif inputService:IsKeyDown(Enum.KeyCode.Z) then
				currentMousePos = input.Position + Vector3.yAxis
			end
		end
	end
end)
while true do task.wait()
	headPart = player.Character and player.Character:FindFirstChild("Head") or nil
	if controlledPart and currentBodyPos then
		currentBodyPos.Position = currentMousePos or (headPart.Position + (Vector3.yAxis * 2))
		controlledPart.Velocity = Vector3.yAxis * 40
	end
end