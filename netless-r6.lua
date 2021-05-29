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
_G.Connections = _G.Connections or {}
local OldPos
local WaitTime = .15
local random = math.random
-- // MAIN
if Humanoid.RigType == Enum.HumanoidRigType.R6 and not Character:FindFirstChild("REANIMATE") then
	settings().Physics.AllowSleep = false
	settings().Physics.PhysicsEnvironmentalThrottle = Enum.EnviromentalPhysicsThrottle.Disabled

	if Workspace:FindFirstChild(Player.UserId) then Workspace[Player.UserId]:Destroy() end
	for _, connection in ipairs(_G.Connections) do connection:Disconnect() end
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
	DummyChar.Name = Player.UserId

	for _, gui in ipairs(Player.PlayerGui:GetChildren()) do if gui:IsA("ScreenGui") then gui.ResetOnSpawn = false end end
	Player.Character = FakeChar
	wait(WaitTime)
	Player.Character = Character
	wait(5)
	Character:BreakJoints()
	DummyChar.Parent = Workspace
	Character.Animate.Parent = DummyChar
	Humanoid.Animator.Parent = DummyChar.Humanoid
	Character.Head.face:Clone().Parent = DummyChar.Head; Character.Head.face:Destroy()
	DummyChar:SetPrimaryPartCFrame(OldPos)
	Workspace.CurrentCamera.CameraSubject = DummyChar.Humanoid

	for _, object in ipairs(DummyChar:GetChildren()) do if object:IsA("BasePart") then object.Transparency = 1 end end
	for _, sound in ipairs(HRP:GetChildren()) do if sound:IsA("Sound") then sound:Destroy() end end
	for _, object in ipairs(Character:GetChildren()) do
		if object:IsA("BasePart") then
			local OffsetAtt = Instance.new("Attachment")
			OffsetAtt.Name = "Offset"
			OffsetAtt.Parent = DummyChar[object.Name]
		elseif object:IsA("Accessory") then
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

		for _, object in ipairs(Character:GetChildren()) do
			if object:IsA("BasePart") then
				object.Massless = true
				object.Velocity = Vector3.new(0, -30, 0)
				object.RotVelocity = Vector3.new()
			elseif object:IsA("Accessory") or object:IsA("Tool") and object.Handle then
				object.Handle.Massless = true
				object.Handle.Velocity = Vector3.new(0, 40, 0)
				object.Handle.RotVelocity = Vector3.new()
			end
		end

		DummyChar.Humanoid:Move(Humanoid.MoveDirection, false)
		if UIS:IsKeyDown(Enum.KeyCode.Space) and UIS:GetFocusedTextBox() == nil then
			DummyChar.Humanoid.Jump = true
		end
	end)

	_G.Connections[2] = RunService.Heartbeat:Connect(function()
		for _, object in ipairs(Character:GetChildren()) do
			if DummyChar:FindFirstChild(object.Name) then
				if object:IsA("BasePart") then
					object.CFrame = DummyChar[object.Name].CFrame * DummyChar[object.Name].Offset.CFrame
				elseif object:IsA("Accessory") and Character:FindFirstChild(object.Name) then
					object.Handle.CFrame = DummyChar[object.Name].Handle.CFrame * CFrame.new(DummyChar.Head.Offset.Position) * DummyChar[object.Name].Handle.Offset.CFrame
				end
			end
			if object:IsA("Tool") and object.Handle then
				if RArm:FindFirstChild("RightGrip") then RArm.RightGrip:Destroy() end
				object.Handle.CFrame = RArm.CFrame * CFrame.new(0, -1, 0, 1, 0, 0, 0, 0, 1, 0, -1, 0) * object.Grip:inverse()
			end
		end
	end)

	if not _G.PlayerResetConnection then
		local ResetBindable = Instance.new("BindableEvent")
		_G.PlayerResetConnection = ResetBindable.Event:Connect(function()
			for _, connection in ipairs(_G.Connections) do connection:Disconnect() end
			if Workspace:FindFirstChild(Player.UserId) then
				Player.Character = Workspace[Player.Name]
				Workspace[Player.Name]:Destroy()
				Workspace[Player.UserId]:Destroy()
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
