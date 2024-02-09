-- services
local players = game:GetService("Players")
local runService = game:GetService("RunService")
local inputService = game:GetService("UserInputService")
-- objects
local player = players.LocalPlayer
local camera = workspace.CurrentCamera
local character = player.Character or player.CharacterAdded:Wait()
local humanoid, rootPart
-- variables
local flyConfig = {
	enabled = false,
	noclip = true,
	keyInput = Enum.KeyCode.F1,
	flySpeed = 2,
	qeFly = true,
}
local flyData = {
	currentCFrame = CFrame.identity,
	navigation = {
		upward = false,
		downward = false,
		forward = false,
		backward = false,
		rightward = false,
		leftward = false,
	}
}
-- functions
local function onCharacterAdded(newCharacter)
	task.wait(.5)
	character = newCharacter
	humanoid, rootPart = character:FindFirstChildWhichIsA("Humanoid"), character:WaitForChild("HumanoidRootPart")
end
-- main
onCharacterAdded(character)
player.CharacterAdded:Connect(onCharacterAdded)

inputService.InputBegan:Connect(function(input, gameProcessedEvent)
	if input.UserInputType == Enum.UserInputType.Keyboard and not (inputService:GetFocusedTextBox() and gameProcessedEvent) then
		if input.KeyCode == flyConfig.keyInput then
			flyConfig.enabled = not flyConfig.enabled
			flyData.currentCFrame = rootPart.CFrame
		end
	end
end)

runService.RenderStepped:Connect(function()
	if not inputService:GetFocusedTextBox() and flyConfig.enabled then
		flyData.navigation.upward = flyConfig.qeFly and inputService:IsKeyDown(Enum.KeyCode.Q)
		flyData.navigation.downward = flyConfig.qeFly and inputService:IsKeyDown(Enum.KeyCode.E)
		flyData.navigation.forward = inputService:IsKeyDown(Enum.KeyCode.W)
		flyData.navigation.backward = inputService:IsKeyDown(Enum.KeyCode.S)
		flyData.navigation.leftward = inputService:IsKeyDown(Enum.KeyCode.A)
		flyData.navigation.rightward = inputService:IsKeyDown(Enum.KeyCode.D)
	end
end)

runService.Heartbeat:Connect(function(deltaTime)
	if flyConfig.enabled and (humanoid and rootPart) then
		for _, animObj in humanoid:GetPlayingAnimationTracks() do animObj:Stop(0) end
		local cameraOrientation = CFrame.fromOrientation(camera.CFrame:ToOrientation())
		local calcFront, calcRight, calcTop = (cameraOrientation.LookVector), (cameraOrientation.RightVector), (cameraOrientation.UpVector)
		local pressedDirection do
			pressedDirection = Vector3.zero
			for name, value in flyData.navigation do
				pressedDirection += (
					if not value then Vector3.zero
					elseif (name == "upward") then calcTop
					elseif (name == "downward") then -calcTop
					elseif (name == "forward") then calcFront
					elseif (name == "backward") then -calcFront
					elseif (name == "rightward") then calcRight
					elseif (name == "leftward") then -calcRight
					else Vector3.zero
				)
			end
			pressedDirection *= ((flyConfig.flySpeed / 0.0305) * deltaTime)
		end

		rootPart.Anchored = false
		humanoid:ChangeState(Enum.HumanoidStateType.Climbing)
		if flyConfig.noclip then
			local difference = (flyData.currentCFrame.Position - rootPart.Position)

			character:TranslateBy(pressedDirection)
			--rootPart.CFrame = ((CFrame.identity + (rootPart.Position + difference)) * cameraOrientation)
		else
			rootPart.CFrame = (
				if pressedDirection.Magnitude > 0 then
					((CFrame.identity + (rootPart.Position + pressedDirection)) * cameraOrientation)
				else ((CFrame.identity + flyData.currentCFrame.Position) * cameraOrientation)
			)
		end
		flyData.currentCFrame = rootPart.CFrame
		rootPart.AssemblyLinearVelocity, rootPart.AssemblyAngularVelocity = Vector3.zero, Vector3.zero
	end
end)
