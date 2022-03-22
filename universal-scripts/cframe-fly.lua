-- services
local players = game:GetService("Players")
local runService = game:GetService("RunService")
local inputService = game:GetService("UserInputService")
-- objects
local player = players.LocalPlayer
local character = player.Character
local humanoid = character:FindFirstChild("Humanoid")
local rootPart = character:FindFirstChild("HumanoidRootPart")
local camera = workspace.CurrentCamera
-- variables
local flyObj = {
	enabled = false,
	flySpeed = 15,
	keyInput = Enum.KeyCode.E,
	navigation = {
		forward = false,
		backward = false,
		rightward = false,
		leftward = false,
	}
}
-- main
inputService.InputBegan:Connect(function(input, gameProcessedEvent)
	if input.UserInputType == Enum.UserInputType.Keyboard and not (inputService:GetFocusedTextBox() and gameProcessedEvent) then
		if input.KeyCode == flyObj.keyInput then
			flyObj.enabled = not flyObj.enabled
			humanoid:SetStateEnabled(Enum.HumanoidStateType.StrafingNoPhysics, flyObj.enabled)
			humanoid:ChangeState(flyObj.enabled and Enum.HumanoidStateType.StrafingNoPhysics or Enum.HumanoidStateType.Running)
		end
	end
end)
runService.RenderStepped:Connect(function()
	if not inputService:GetFocusedTextBox() and flyObj.enabled then
		flyObj.navigation.forward = inputService:IsKeyDown(Enum.KeyCode.W) and true or nil
		flyObj.navigation.backward = inputService:IsKeyDown(Enum.KeyCode.S) and true or nil
		flyObj.navigation.leftward = inputService:IsKeyDown(Enum.KeyCode.A) and true or nil
		flyObj.navigation.rightward = inputService:IsKeyDown(Enum.KeyCode.D) and true or nil
	end
end)
camera:GetPropertyChangedSignal("CFrame"):Connect(function()
	if flyObj.enabled then
		rootPart.CFrame = CFrame.new(rootPart.CFrame.Position, (rootPart.CFrame.Position + camera.CFrame.LookVector))
	end
end)
runService.Heartbeat:Connect(function(deltaTime)
	if flyObj.enabled then
		local calcFront, calcRight = (camera.CFrame.LookVector * (deltaTime * flyObj.flySpeed)), (camera.CFrame.RightVector * (deltaTime * flyObj.flySpeed))
		local pressResult do
			pressResult = Vector3.zero
			for name, value in pairs(flyObj.navigation) do
				pressResult += (
					if not value then Vector3.zero
					elseif (name == "forward" and value) then calcFront
					elseif (name == "backward" and value) then -calcFront
					elseif (name == "rightward" and value) then calcRight
					elseif (name == "leftward" and value) then -calcRight else nil
				)
			end
		end
		rootPart.CFrame += pressResult or Vector3.zero
		rootPart.AssemblyLinearVelocity = (if pressResult then pressResult * workspace.Gravity else -calcFront)
		for _, animObj in pairs(humanoid:GetPlayingAnimationTracks()) do animObj:Stop() end
	end
end)