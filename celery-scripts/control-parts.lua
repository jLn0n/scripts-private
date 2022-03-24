-- services
local players = game:GetService("Players")
local inputService = game:GetService("UserInputService")
-- objects
local player = players.LocalPlayer
local mouse = player:GetMouse()
local partHolder = Instance.new("Part")
local rootPart, controlledPart, setControlledPart, partPos
-- function
local function setControlling(partObj)
	setControlledPart = partObj or rootPart
	rnet.setphysicsrootpart(setControlledPart)
end
local function setPartPosition(partObj, posVec3)
	if not partObj then return end
	if setControlledPart ~= partObj then
		setControlling(partObj)
	end
	local cframeThingy = CFrame.new(posVec3 or Vector3.zero)
	rnet.sendphysics(cframeThingy)
	--partObj.CFrame = cframeThingy
end
local function disableUselessThingys(partObj)
	if not partObj then return end
	for _, _object in ipairs(partObj:GetChildren()) do
		if not (_object:IsA("LuaSourceContainer") or string.find(_object.ClassName, "Body")) then continue end
		_object:Destroy()
	end
end
-- main
partHolder.Anchored, partHolder.Transparency, partHolder.Parent = true, .5, workspace
inputService.InputBegan:Connect(function(input)
	if not inputService:GetFocusedTextBox() then
		if input.UserInputType == Enum.UserInputType.Keyboard then
			if input.KeyCode == Enum.KeyCode.KeypadOne then
				controlledPart = nil
				setControlling(nil)
			elseif input.KeyCode == Enum.KeyCode.KeypadZero then
				player.Character:MoveTo(controlledPart and controlledPart.Position or rootPart.Position)
			end
		elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
			if inputService:IsKeyDown(Enum.KeyCode.X) then
				local targetPart = mouse.Target
				if rootPart and targetPart and not targetPart.Anchored and #targetPart:GetJoints() == 0 then
					controlledPart, partPos = targetPart, rootPart.Position
					setControlling(rootPart)
					disableUselessThingys(controlledPart)
					for _ = 1, 5 do
						rnet.sendphysics(CFrame.new(targetPart.Position))
						targetPart.Position = rootPart.Position
						rnet.sendphysics(CFrame.new(rootPart.Position))
						task.wait()
					end
					setPartPosition(targetPart, partPos)
					player.Character:MoveTo(rootPart.Position)
				end
			elseif inputService:IsKeyDown(Enum.KeyCode.Z) and controlledPart then
				partPos = mouse.Hit.Position
			end
		end
	end
end)
while true do task.wait()
	rootPart = player.Character and player.Character:FindFirstChild("HumanoidRootPart") or nil
	if controlledPart and controlledPart:IsDescendantOf(workspace) then
		setPartPosition(controlledPart, partPos)
	end
end
