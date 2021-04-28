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
local OldPos
-- // MAIN
if Humanoid.RigType == Enum.HumanoidRigType.R6 then
	for _, connection in ipairs(_G.Connections) do
		connection:Disconnect()
	end

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

    local FakeHRP = Instance.new("Part")
    FakeHRP.Name = "HumanoidRootPart"
    FakeHRP.Size = Vector3.new(2, 2, 1)
    FakeHRP.Anchored = true
    FakeHRP.Position = Vector3.new(0, 10000, 0)
    FakeHRP.Transparency = 1

    local AntiSpawnChar = Instance.new("Model") -- permadeath
    AntiSpawnChar.Name = ""

    local FakeTorso =  Instance.new("Part")
    FakeTorso.Name = "Torso"
    FakeTorso.Parent = AntiSpawnChar
    FakeTorso.Anchored = true
    FakeTorso.CanCollide = false
    FakeTorso.Position = Vector3.new(0, 9e9, 0)

    local FakeHead  = Instance.new("Part")
    FakeHead.Name = "Head"
    FakeHead.Parent = AntiSpawnChar
    FakeHead.Anchored = true
    FakeHead.CanCollide = false
    FakeHead.Position = Vector3.new(0, 9e8, 0)

    local FakeHumanoid = Instance.new("Humanoid")
    FakeHumanoid.Name = "Humanoid"
    FakeHumanoid.Parent = AntiSpawnChar

    AntiSpawnChar.Parent = Folder

    local RJointAtt = Instance.new("Attachment")
    RJointAtt.Name = "RootJoint"
    RJointAtt.CFrame = DummyChar.HumanoidRootPart.RootJoint.C0

	HRP.Anchored = true
	Character:SetPrimaryPartCFrame(CFrame.new(Vector3.new(0, 10000, 0)))
    Humanoid.Animator:Destroy()
	Humanoid.WalkSpeed = 0
	Humanoid.JumpPower = 0
    Player.Character = AntiSpawnChar
    wait(5)
    Player.Character = Character
    wait(.25)

    for _, motor6d in ipairs(Torso:GetChildren()) do
        if motor6d:IsA("Motor6D") then
            local Attachment = Instance.new("Attachment")
            Attachment.Name = motor6d.Name
            Attachment.Parent = Torso
            Attachment.CFrame = motor6d.C0
        end
    end

	HRP.Anchored = false
    HRP:Destroy()
    wait()
    Character:BreakJoints()
    HRP = FakeHRP
    HRP.Parent = Character
    RJointAtt.Parent = HRP

    Folder.Parent = Character
    DummyChar:SetPrimaryPartCFrame(OldPos)
    DummyChar.HumanoidRootPart.Anchored = false
    DummyChar.Humanoid.MaxHealth = math.huge
	DummyChar.Humanoid.Health = math.huge
	DummyChar.Head.face.Texture = ""
    Workspace.CurrentCamera.CameraSubject = DummyChar.Humanoid

    Character.Animate.Disabled = true
    local AnimateScript = Character.Animate:Clone()
    AnimateScript.Parent = DummyChar
    AnimateScript.Disabled = false
    Character.Animate:Destroy()

    for _, accessory in ipairs(Character:GetChildren()) do
        if accessory:IsA("Accessory") then
            accessory.Parent = DummyChar
        end
    end

    for _, object in ipairs(DummyChar:GetChildren()) do
		if object:IsA("BasePart") and object.Name ~= "HumanoidRootPart" then
			object.Transparency = 1
		end
	end

    _G.Connections[1] = RunService.Heartbeat:Connect(function()
        if AntiSpawnChar.Parent ~= nil then
            DummyChar.Humanoid:Move(Humanoid.MoveDirection)
        end

		for _, object in ipairs(Character:GetDescendants()) do
			if object:IsA("BasePart") then
				object.CanCollide = false
				object.LocalTransparencyModifier = DummyChar.Head.LocalTransparencyModifier
                object.Anchored = false
			end
		end

		for _, object in ipairs(DummyChar:GetDescendants()) do
			if object:IsA("BasePart") then
				object.CanCollide = false
			end
		end

		for _, motor6d in ipairs(DummyChar.Torso:GetChildren()) do
			if motor6d:IsA("Motor6D") then
				if motor6d.C0 ~= Torso[motor6d.Name].CFrame then
					motor6d.C0 = Torso[motor6d.Name].CFrame
				end
			end
		end
		
		if DummyChar.HumanoidRootPart.RootJoint.C0 ~= HRP.RootJoint.CFrame then
			DummyChar.HumanoidRootPart.RootJoint.C0 = HRP.RootJoint.CFrame
		end

		if UIS:IsKeyDown(Enum.KeyCode.Space) and UIS:GetFocusedTextBox() == nil then
			DummyChar.Humanoid.Jump = true
		end
	end)
	
	_G.Connections[2] = RunService.Heartbeat:Connect(function()
		for _, object in ipairs(Character:GetChildren()) do
			if object:IsA("BasePart") then
			    object.CFrame = DummyChar[object.Name].CFrame
			end
		end
	end)
	local ResetBEvent = Instance.new("BindableEvent")
	_G.Connections[3] = ResetBEvent.Event:Connect(function()
		Player.Character = Character
		Player.Character:Destroy()
		AntiSpawnChar:Destroy()
		for _, connection in ipairs(_G.Connections) do
			connection:Disconnect()
		end
		_G.Connections = {}
		ResetBEvent:Destroy()
	end)
	StarterGui:SetCore("ResetButtonCallback", ResetBEvent)
end
