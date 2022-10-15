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
local yStabilizer = (Vector3.yAxis * rootPart:GetMass())
local flyObj = {
	enabled = false,
	flySpeed = 16,
	keyInput = Enum.KeyCode.F1,
	qeFly = false,
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
local function unpackOrientation(vectRot, dontUseRadians)
	vectRot = (if not dontUseRadians then vectRot * (math.pi / 180) else vectRot)
	return vectRot.X, vectRot.Y, (if typeof(vectRot) == "Vector2" then 0 else vectRot.Z)
end
-- main
player.CharacterAdded:Connect(function(newCharacter)
	task.wait(.1)
	character = newCharacter
	humanoid, rootPart = newCharacter:FindFirstChild("Humanoid"), newCharacter:FindFirstChild("HumanoidRootPart")
end)

inputService.InputBegan:Connect(function(input, gameProcessedEvent)
	if input.UserInputType == Enum.UserInputType.Keyboard and not (inputService:GetFocusedTextBox() and gameProcessedEvent) then
		if input.KeyCode == flyObj.keyInput then
			flyObj.enabled = not flyObj.enabled
			rootPart.Anchored, rootPart.Velocity = (flyObj.enabled), (not flyObj.enabled and Vector3.zero or nil)
			humanoid:ChangeState(flyObj.enabled and Enum.HumanoidStateType.StrafingNoPhysics or Enum.HumanoidStateType.Running)
		end
	end
end)

runService.RenderStepped:Connect(function()
	if not inputService:GetFocusedTextBox() and flyObj.enabled then
		flyObj.navigation.upward = flyObj.qeFly and (inputService:IsKeyDown(Enum.KeyCode.Q) and true or false)
		flyObj.navigation.downward = flyObj.qeFly and (inputService:IsKeyDown(Enum.KeyCode.E) and true or false)
		flyObj.navigation.forward = inputService:IsKeyDown(Enum.KeyCode.W) and true or false
		flyObj.navigation.backward = inputService:IsKeyDown(Enum.KeyCode.S) and true or false
		flyObj.navigation.leftward = inputService:IsKeyDown(Enum.KeyCode.A) and true or false
		flyObj.navigation.rightward = inputService:IsKeyDown(Enum.KeyCode.D) and true or false
	end
end)

runService.Heartbeat:Connect(function(deltaTime)
	if flyObj.enabled and (humanoid and rootPart) then
		local calcFront, calcRight, calcTop = (camera.CFrame.LookVector * (deltaTime * flyObj.flySpeed)), (camera.CFrame.RightVector * (deltaTime * flyObj.flySpeed)), (camera.CFrame.UpVector * (deltaTime * flyObj.flySpeed))
		local cameraOrientation = CFrame.fromOrientation(camera.CFrame:ToOrientation())
		local pressResult do
			pressResult = Vector3.zero
			for name, value in flyObj.navigation do
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

		if pressResult.Magnitude > 0 then
			rootPart.Anchored = false
			rootPart.CFrame = (CFrame.new(rootPart.Position + pressResult) * cameraOrientation)
			rootPart.Velocity, rootPart.RotVelocity = (pressResult * workspace.Gravity) + yStabilizer, Vector3.zero
		else
			rootPart.Anchored = true
			rootPart.CFrame = ((CFrame.identity + rootPart.Position) * cameraOrientation)
		end
		for _, animObj in pairs(humanoid:GetPlayingAnimationTracks()) do animObj:Stop() end
	end
end)
