-- services
local players = game:GetService("Players")
local runService = game:GetService("RunService")
local inputService = game:GetService("UserInputService")
-- objects
local player = players.LocalPlayer
local character = player.Character
local humanoid = character:FindFirstChildWhichIsA("Humanoid")
local rootPart = character:FindFirstChild("HumanoidRootPart")
local camera = workspace.CurrentCamera
-- variables
local currentCFrame
local yStabilizer = (Vector3.yAxis * rootPart:GetMass())
local flyObj = {
	enabled = false,
	flySpeed = 16,
	keyInput = Enum.KeyCode.F1,
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
-- functions
local function applyThingys()
	if not (humanoid and rootPart) then return end

	currentCFrame = rootPart.CFrame
	humanoid.PlatformStand = (flyObj.enabled)
end

-- main
player.CharacterAdded:Connect(function(newCharacter)
	task.wait(.1)
	character = newCharacter
	humanoid, rootPart = newCharacter:FindFirstChildWhichIsA("Humanoid"), newCharacter:FindFirstChild("HumanoidRootPart")

	task.spawn(applyThingys)
end)

inputService.InputBegan:Connect(function(input, gameProcessedEvent)
	if input.UserInputType == Enum.UserInputType.Keyboard and not (inputService:GetFocusedTextBox() and gameProcessedEvent) then
		if input.KeyCode == flyObj.keyInput then
			flyObj.enabled = not flyObj.enabled
			applyThingys()
		end
	end
end)

runService.RenderStepped:Connect(function()
	if not inputService:GetFocusedTextBox() and flyObj.enabled then
		flyObj._navigation.upward = flyObj.qeFly and (inputService:IsKeyDown(Enum.KeyCode.Q) and true or false)
		flyObj._navigation.downward = flyObj.qeFly and (inputService:IsKeyDown(Enum.KeyCode.E) and true or false)
		flyObj._navigation.forward = inputService:IsKeyDown(Enum.KeyCode.W) and true or false
		flyObj._navigation.backward = inputService:IsKeyDown(Enum.KeyCode.S) and true or false
		flyObj._navigation.leftward = inputService:IsKeyDown(Enum.KeyCode.A) and true or false
		flyObj._navigation.rightward = inputService:IsKeyDown(Enum.KeyCode.D) and true or false
	end
end)

runService.Heartbeat:Connect(function(deltaTime)
	if flyObj.enabled and (humanoid and rootPart) then
		local cameraOrientation = CFrame.fromOrientation(camera.CFrame:ToOrientation())
		local calcFront, calcRight, calcTop = (cameraOrientation.LookVector * (deltaTime * flyObj.flySpeed)), (cameraOrientation.RightVector * (deltaTime * flyObj.flySpeed)), (cameraOrientation.UpVector * (deltaTime * flyObj.flySpeed))
		local pressResult do
			pressResult = Vector3.zero

			for name, value in flyObj._navigation do
				pressResult += (
					if not value then Vector3.zero
					elseif (name == "upward") then calcTop
					elseif (name == "downward") then -calcTop
					elseif (name == "forward") then calcFront
					elseif (name == "backward") then -calcFront
					elseif (name == "rightward") then calcRight
					elseif (name == "leftward") then -calcRight else nil
				)
			end
		end

		for _, animObj in humanoid:GetPlayingAnimationTracks() do animObj:Stop() end
		if pressResult.Magnitude > 0 then
			rootPart.CFrame = ((CFrame.identity + (currentCFrame.Position + (pressResult * 2))) * cameraOrientation)
		else
			rootPart.CFrame = ((CFrame.identity + currentCFrame.Position) * cameraOrientation)
		end
		rootPart.AssemblyLinearVelocity, rootPart.AssemblyAngularVelocity = Vector3.zero, Vector3.zero
		currentCFrame = rootPart.CFrame
	end
end)
