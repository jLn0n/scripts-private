-- services
local players = game:GetService("Players")
local inputService = game:GetService("UserInputService")
-- objects
local player = players.LocalPlayer
local mouse = player:GetMouse()
local partThingy, controlledPart, controlledPartPos
-- function
local function initFloaties(object)
	if not object then return end
	for _, _object in ipairs(object:GetChildren()) do
		if not (_object:IsA("LuaSourceContainer") or string.find(_object.ClassName, "Body")) then continue end
		_object:Destroy()
	end
	local bodyPos = Instance.new("BodyPosition")
	bodyPos.D = 150000
	bodyPos.MaxForce = Vector3.one * 4e6
	bodyPos.P = 1e6
	bodyPos.Parent = object
end
-- main
inputService.InputBegan:Connect(function(input)
	if not inputService:GetFocusedTextBox() then
		if input.UserInputType == Enum.UserInputType.Keyboard then
			if input.KeyCode == Enum.KeyCode.KeypadZero then
				controlledPart = nil
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
				if partThingy and targetPart and not targetPart.Anchored and not targetPart:FindFirstChildWhichIsA("Weld", true) then
					controlledPart, controlledPartPos = targetPart, partThingy.Position
					targetPart.CanCollide = false
					for _ = 1, 5 do
						rnet.sendposition(targetPart.Position)
						targetPart.Position = controlledPartPos
						rnet.sendposition(partThingy.Position)
						task.wait()
					end
					initFloaties(targetPart)
					player.Character:MoveTo(partThingy.Position)
					targetPart.CanCollide = true
				end
			elseif inputService:IsKeyDown(Enum.KeyCode.Z) and controlledPart then
				controlledPartPos = mouse.Hit.Position
			end
		end
	end
end)
while true do task.wait()
	partThingy = player.Character and player.Character:FindFirstChild("HumanoidRootPart") or nil
	if controlledPart and controlledPart:IsDescendantOf(workspace) then
		controlledPart:FindFirstChildWhichIsA("BodyPosition").Position = controlledPartPos
		controlledPart.Velocity, controlledPart.RotVelocity = (Vector3.yAxis * 25.05), Vector3.zero
		controlledPart.Velocity, controlledPart.RotVelocity = -(Vector3.yAxis * 20.05), Vector3.zero
	end
end
