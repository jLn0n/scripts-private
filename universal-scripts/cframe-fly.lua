-- services
local players = game:GetService("Players")
local runService = game:GetService("RunService")
local inputService = game:GetService("UserInputService")
-- objects
local player = players.LocalPlayer
local character = player.Character
local rootPart = character:FindFirstChild("HumanoidRootPart")
local camera = workspace.CurrentCamera
-- variables
local flyObj = {
	enabled = false,
	flySpeed = 50,
	keyInput = Enum.KeyCode.E,
	navigation = {
		forward = false,
		backward = false,
		leftward = false,
		rightward = false
	}
}
-- main
inputService.InputBegan:Connect(function(input, gameProcessedEvent)
	if input.UserInputType == Enum.UserInputType.Keyboard and not (inputService:GetFocusedTextBox() and gameProcessedEvent) then
		if input.KeyCode == flyObj.keyInput then
			flyObj.enabled = not flyObj.enabled
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
		local pressResult = ((flyObj.navigation.forward and calcFront) or (flyObj.navigation.backward and -calcFront) or (flyObj.navigation.rightward and calcRight) or (flyObj.navigation.leftward and -calcRight))
		rootPart.CFrame = (rootPart.CFrame + (pressResult or Vector3.zero))
		-- TODO: the character should be in air still while not controlling the fly thingy
		rootPart:ApplyImpulse((pressResult or camera.CFrame.LookVector) * rootPart:GetMass())
	end
end)
