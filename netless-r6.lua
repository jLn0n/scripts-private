-- // SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local Workspace = game.Workspace
local UIS = game:GetService("UserInputService")
-- // OBJECTS
local Player = Players.LocalPlayer
local Character = Player.Character
local Humanoid = Character.Humanoid
local HRP = Character.HumanoidRootPart
-- // VARIABLES
_G.Settings = _G.Settings or {}
_G.Connections = _G.Connections or {}
local OldPos
local WaitTime = .15
-- // MAIN
_G.Settings = {
	PlayerCanCollide = _G.Settings.PlayerCanCollide or true
}
if Workspace:FindFirstChild(tostring(Player.UserId)) then Workspace[Player.UserId]:Destroy() end
if Humanoid.RigType == Enum.HumanoidRigType.R6 and not Workspace:FindFirstChild(Player.UserId) then
	settings().Physics.AllowSleep = false
	settings().Physics.PhysicsEnvironmentalThrottle = Enum.EnviromentalPhysicsThrottle.Disabled

	for _, connection in ipairs(_G.Connections) do connection:Disconnect() end _G.Connections = {}
	if game.PlaceId == 2041312716 then
		Character:FindFirstChild("FirstPerson"):Destroy()
		Character:FindFirstChild("Local Ragdoll"):Destroy()
		Character:FindFirstChild("Controls"):Destroy()
		Character:FindFirstChild("State Handler"):Destroy()
		for _, RagdollConstraint in ipairs(Character:GetChildren()) do
			if RagdollConstraint:IsA("BallSocketConstraint") or RagdollConstraint:IsA("HingeConstraint") then
				RagdollConstraint:Destroy()
			end
		end
		WaitTime = 5
	end

	OldPos = Character:GetPrimaryPartCFrame()
	Workspace.FallenPartsDestroyHeight = 0 / 1 / 0

	local RArm = Character["Right Arm"]
	local DummyChar = game:GetObjects("rbxassetid://6843243348")[1]
	local FakeChar = DummyChar:Clone()
	local Humanoid2 = DummyChar.Humanoid
	DummyChar.Name = Player.UserId

	for _, gui in ipairs(Player.PlayerGui:GetChildren()) do if gui:IsA("ScreenGui") then gui.ResetOnSpawn = false end end
	HRP.Anchored = true
	Player.Character = FakeChar
	wait(WaitTime)
	Player.Character = Character
	wait(5)
	Character:BreakJoints()
	Character.Animate.Disabled = true
	Character.Animate.Parent = DummyChar
	Humanoid.Animator:Clone().Parent = DummyChar.Humanoid
	DummyChar.Parent = Workspace
	Character.Head.face.Parent = DummyChar.Head
	DummyChar:SetPrimaryPartCFrame(OldPos)
	Workspace.CurrentCamera.CameraSubject = DummyChar.Humanoid
	HRP.Anchored = false

	for _, object in ipairs(DummyChar:GetChildren()) do if object:IsA("BasePart") then object.Transparency = 1 end end
	for _, object in ipairs(Character:GetChildren()) do
		if object:IsA("BasePart") then
			local OffsetAtt = Instance.new("Attachment")
			OffsetAtt.Name = "Offset"
			OffsetAtt.Parent = DummyChar[object.Name]
		elseif object:IsA("Accessory") and object.Handle then
			local Clone = object:Clone()
			Clone.Handle.Transparency = 1
			Clone.Parent = DummyChar
			local OffsetAtt = Instance.new("Attachment")
			OffsetAtt.Name = "Offset"
			OffsetAtt.Parent = Clone.Handle
		end
	end

	_G.Connections[1] = RunService.Stepped:Connect(function()
		for _, object in ipairs(Character:GetDescendants()) do
			if object:IsA("BasePart") and not object.Parent:IsA("Tool") then
				object.LocalTransparencyModifier = DummyChar.Head.LocalTransparencyModifier
			end
		end

		for _, object in ipairs(Character:GetDescendants()) do
			if object:IsA("BasePart") then
				object.CanCollide = false
			end
		end

		if not _G.Settings.PlayerCanCollide then
			for _, object in ipairs(DummyChar:GetDescendants()) do
				if object:IsA("BasePart") then
					object.CanCollide = false
				end
			end
		end

		for _, object in ipairs(Character:GetChildren()) do
			if object:IsA("BasePart") then
				object.Massless = true
				object.Velocity = Vector3.new(0, 40, 0)
				object.RotVelocity = Vector3.new(0, 25, 0)
			elseif object:IsA("Accessory") or object:IsA("Tool") and object:FindFirstChild("Handle") then
				object.Handle.Massless = true
				object.Handle.Velocity = Vector3.new(0, 40, 0)
				object.Handle.RotVelocity = Vector3.new(0, 25, 0)
			end
		end

		Humanoid2:Move(Humanoid.MoveDirection, false)
		if UIS:IsKeyDown(Enum.KeyCode.Space) and UIS:GetFocusedTextBox() == nil then
			Humanoid2.Jump = true
		end
	end)

	_G.Connections[2] = RunService.Heartbeat:Connect(function()
		for _, object in ipairs(Character:GetChildren()) do
			if DummyChar:FindFirstChild(object.Name) then
				if object:IsA("BasePart") then
					object.CFrame = DummyChar[object.Name].CFrame * DummyChar[object.Name].Offset.CFrame
				elseif object:IsA("Accessory") and object.Handle then
					object.Handle.CFrame = DummyChar[object.Name].Handle.CFrame * CFrame.new(DummyChar.Head.Offset.Position) * DummyChar[object.Name].Handle.Offset.CFrame
				end
			end
			if object:IsA("Tool") and object:FindFirstChild("Handle") then
				object.Handle.CFrame = RArm.CFrame * CFrame.new(0, -1, 0, 1, 0, 0, 0, 0, 1, 0, -1, 0) * object.Grip:inverse()
			end
		end
	end)

	if not _G.PlayerResetConnection then
		local ResetBindable = Instance.new("BindableEvent")
		_G.PlayerResetConnection = ResetBindable.Event:Connect(function()
			for _, connection in ipairs(_G.Connections) do connection:Disconnect() end _G.Connections = {}
			if Workspace:FindFirstChild(Player.UserId) then
				Workspace[Player.UserId]:Destroy()
				Player.Character:BreakJoints()
				Player.Character = FakeChar
			else
				Player.Character:BreakJoints()
			end
		end)
		StarterGui:SetCore("ResetButtonCallback", ResetBindable)
	end

	StarterGui:SetCore("SendNotification", {
		Title = "REANIMATE",
		Text = "Loaded!\nYou can now use FE scripts.\n",
		Cooldown = 1
	})
end
