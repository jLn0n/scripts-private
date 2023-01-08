-- services
local players = game:GetService("Players")
local runService = game:GetService("RunService")
local inputService = game:GetService("UserInputService")
-- objects
local player = players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:FindFirstChildWhichIsA("Humanoid")
local rootPart = character:FindFirstChild("HumanoidRootPart")
local camera = workspace.CurrentCamera
-- variables
local rootPartCFrame
local flyObj = {
	enabled = false,
	keyInput = Enum.KeyCode.F1,
	flySpeed = 1,
	qeFly = true,

	_navigation = {
		upward = false,
		downward = false,
		forward = false,
		backward = false,
		rightward = false,
		leftward = false,
	}
}
-- main
player.CharacterAdded:Connect(function(newCharacter)
	character = newCharacter
	humanoid, rootPart = character:FindFirstChildWhichIsA("Humanoid"), character:WaitForChild("HumanoidRootPart")
end)

inputService.InputBegan:Connect(function(input, gameProcessedEvent)
	if input.UserInputType == Enum.UserInputType.Keyboard and not (inputService:GetFocusedTextBox() and gameProcessedEvent) then
		if input.KeyCode == flyObj.keyInput then
			flyObj.enabled = not flyObj.enabled
		end
	end
end)

runService.RenderStepped:Connect(function()
	if not inputService:GetFocusedTextBox() and flyObj.enabled then
		flyObj._navigation.upward = flyObj.qeFly and inputService:IsKeyDown(Enum.KeyCode.Q)
		flyObj._navigation.downward = flyObj.qeFly and inputService:IsKeyDown(Enum.KeyCode.E)
		flyObj._navigation.forward = inputService:IsKeyDown(Enum.KeyCode.W)
		flyObj._navigation.backward = inputService:IsKeyDown(Enum.KeyCode.S)
		flyObj._navigation.leftward = inputService:IsKeyDown(Enum.KeyCode.A)
		flyObj._navigation.rightward = inputService:IsKeyDown(Enum.KeyCode.D)
	end
end)

runService.Heartbeat:Connect(function(deltaTime)
	if flyObj.enabled and (humanoid and rootPart) then
		for _, animObj in humanoid:GetPlayingAnimationTracks() do animObj:Stop(-1) end
		local cameraOrientation = CFrame.fromOrientation(camera.CFrame:ToOrientation())
		local calcFront, calcRight, calcTop = (cameraOrientation.LookVector), (cameraOrientation.RightVector), (cameraOrientation.UpVector)
		local pressedDirection do
			pressedDirection = Vector3.zero
			for name, value in flyObj._navigation do
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
			pressedDirection *= ((flyObj.flySpeed * 16) * deltaTime)
		end
		local difference = (rootPartCFrame.Position - rootPart.Position)

		rootPart.Anchored = false
		character:TranslateBy(pressedDirection)
		rootPart.CFrame = ((CFrame.identity + (rootPart.Position + difference)) * cameraOrientation)
		rootPartCFrame = rootPart.CFrame
		rootPart.AssemblyLinearVelocity, rootPart.AssemblyAngularVelocity = Vector3.zero, Vector3.zero
	end
end)
