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
local HRP, Head, Torso, LeftArm, RightArm, LeftLeg, RightLeg
-- // VARIABLES
_G.Connections = _G.Connections or {}
_G.Settings = _G.Settings or {}
local OldPos
-- // MAIN
if Humanoid.RigType == Enum.HumanoidRigType.R6 then
	for _, connection in ipairs(_G.Connections) do
		connection:Disconnect()
	end
	_G.Settings = {
		DisableAnimation = _G.Settings.DisableAnimation or false,
		WaitTime = _G.Settings.WaitTime or 1
	}

	HRP = Character.HumanoidRootPart
	Head = Character.Head
	Torso = Character.Torso
	LeftArm = Character["Left Arm"]
	RightArm = Character["Right Arm"]
	LeftLeg = Character["Left Leg"]
	RightLeg = Character["Right Leg"]

    OldPos = Character:GetPrimaryPartCFrame()
	Workspace.FallenPartsDestroyHeight = 0 / 1 / 0

	if game.PlaceId == 2041312716 then
		Character:FindFirstChild("FirstPerson"):Destroy()
		Character:FindFirstChild("Local Ragdoll"):Destroy()
		Character:FindFirstChild("Controls"):Destroy()
		Character:FindFirstChild("State Handler"):Destroy()

		for _, RagdollConstraint in pairs(Character:GetChildren()) do
			if RagdollConstraint:IsA("BallSocketConstraint") or RagdollConstraint:IsA("HingeConstraint") then
				RagdollConstraint:Destroy()
			end
		end
	end

    local Folder = Instance.new("Folder")
    Folder.Name = "Dummy"
	local DummyChar = game:GetObjects("rbxassetid://5904819435")[1]
	DummyChar.Name = "Dummy"
    DummyChar.Parent = Folder

	local AntiSpawnChar = Instance.new("Model")
	local FakeHead  = Instance.new("Part")
	local FakeTorso =  Instance.new("Part")

    FakeHead.Name = "Head"
    FakeHead.Parent = AntiSpawnChar
    FakeHead.Anchored = true
    FakeHead.CanCollide = false
    FakeHead.Position = Vector3.new(0, 9e9, 0)

    FakeTorso.Name = "Torso"
    FakeTorso.Parent = AntiSpawnChar
    FakeTorso.Anchored = true
    FakeTorso.CanCollide = false
    FakeTorso.Position = Vector3.new(0, 9e9, 0)

    local FakeHumanoid = Instance.new("Humanoid")
    FakeHumanoid.Name = "Humanoid"
    FakeHumanoid.Parent = AntiSpawnChar

    AntiSpawnChar.Parent = Folder

    local RJointAtt = Instance.new("Attachment")
    RJointAtt.Name = "RootJoint"
    RJointAtt.CFrame = DummyChar.HumanoidRootPart.RootJoint.C0

	HRP.Anchored = true
	HRP.Parent = nil
	Humanoid.Animator:Destroy()
    Player.Character = AntiSpawnChar
	wait(5)
	Player.Character = Character
	wait(_G.Settings.WaitTime)

	Character:BreakJoints()
	HRP.Parent = Character
	HRP.RootJoint:Destroy()
    RJointAtt.Parent = HRP

	Folder.Parent = Character
    DummyChar:SetPrimaryPartCFrame(OldPos)
    DummyChar.HumanoidRootPart.Anchored = false
    DummyChar.Humanoid.MaxHealth = math.huge
	DummyChar.Humanoid.Health = math.huge
	DummyChar.Head.face.Texture = ""
    Workspace.CurrentCamera.CameraSubject = DummyChar.Humanoid

	Character.Animate.Disabled = true
	if not _G.Settings.DisableAnimation then
		local AnimateScript = Character.Animate:Clone()
		AnimateScript.Parent = DummyChar
		AnimateScript.Disabled = false
	end
    Character.Animate:Destroy()

	for _, object in ipairs(Character:GetChildren()) do
		if object:IsA("BasePart") and object.Name ~= "HumanoidRootPart" then
			local Attachment = Instance.new("Attachment")
			Attachment.Name = "Joint"
			Attachment.Parent = object
		end
	end

    for _, object in ipairs(DummyChar:GetChildren()) do
		if object:IsA("BasePart") and object.Name ~= "HumanoidRootPart" then
			object.Transparency = 1
		end
	end

    _G.Connections[1] = RunService.Heartbeat:Connect(function()
        DummyChar.Humanoid:Move(Humanoid.MoveDirection)

		for _, object in ipairs(Character:GetChildren()) do
			if object:IsA("BasePart") then
				object.LocalTransparencyModifier = DummyChar.Head.LocalTransparencyModifier
			end
		end

		if DummyChar.HumanoidRootPart.RootJoint.C0 ~= HRP.RootJoint.CFrame then
			DummyChar.HumanoidRootPart.RootJoint.C0 = HRP.RootJoint.CFrame
		end

		if UIS:IsKeyDown(Enum.KeyCode.Space) and UIS:GetFocusedTextBox() == nil then
			DummyChar.Humanoid.Jump = true
		end
	end)
	
	_G.Connections[2] = RunService.Stepped:Connect(function()
		for _, object in ipairs(Character:GetDescendants()) do
			if object:IsA("BasePart") and object.CanCollide == true then
				object.CanCollide = false
			end
		end
	end)

	_G.Connections[3] = RunService.Heartbeat:Connect(function()
		for _, object in ipairs(Character:GetChildren()) do
			if object:IsA("BasePart") and object.Name ~= "HumanoidRootPart" then
			    object.CFrame = DummyChar[object.Name].CFrame * object.Joint.CFrame
			end
		end
	end)

	local ResetBEvent = Instance.new("BindableEvent")
	_G.Connections[4] = ResetBEvent.Event:Connect(function()
		Humanoid:Destroy()
		for _, connection in ipairs(_G.Connections) do
			connection:Disconnect()
		end
		_G.Connections = {}
		ResetBEvent:Destroy()
	end)
	StarterGui:SetCore("ResetButtonCallback", ResetBEvent)
end