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
local WaitTime = .1
-- // MAIN
if Humanoid.RigType == Enum.HumanoidRigType.R6 then
	for _, connection in ipairs(_G.Connections) do
		connection:Disconnect()
	end
	
	_G.Settings = {
		WaitTime = _G.Settings.WaitTime or 5,
		DisableAnimation = _G.Settings.DisableAnimation or false,
		PlayerCanCollide = _G.Settings.PlayerCanCollide or true,
		CanFlingPlayers = _G.Settings.CanFlingPlayers or false
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
		WaitTime = 5
	end
	
	local Folder = Instance.new("Folder")
	Folder.Name = "NETLESS-REANIMATE"
	local DummyChar = game:GetObjects("rbxassetid://5904819435")[1]
	DummyChar.Name = "Dummy"
	DummyChar.Parent = Folder
	
	local AntiSpawnChar = Instance.new("Model")
	local FakeHumanoid = Instance.new("Humanoid")
	FakeHumanoid.Name = "Humanoid"
	FakeHumanoid.Parent = AntiSpawnChar
	AntiSpawnChar.Parent = Folder
	
	local RJointAtt = Instance.new("Attachment")
	RJointAtt.Name = "RootJoint"
	RJointAtt.CFrame = DummyChar.HumanoidRootPart.RootJoint.C0
	
	local AngularVel = Instance.new("BodyAngularVelocity")
	AngularVel.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
	AngularVel.AngularVelocity = Vector3.new(2500, 2500, 2500)
	
	Character.Animate.Disabled = true
	Humanoid.Animator:Destroy()
	HRP.Anchored = true
	Player.Character = AntiSpawnChar
	wait(WaitTime)
	Player.Character = Character
	wait(_G.Settings.WaitTime)
	Character:BreakJoints()
	HRP.Anchored = false
	RJointAtt.Parent = HRP
	AngularVel.Parent = HRP

	Folder.Parent = Character
	DummyChar:SetPrimaryPartCFrame(OldPos)
	DummyChar.HumanoidRootPart.Anchored = false
	DummyChar.Humanoid.MaxHealth = math.huge
	DummyChar.Humanoid.Health = math.huge
	DummyChar.Head.face.Texture = ""
	Workspace.CurrentCamera.CameraSubject = DummyChar.Humanoid

	if not _G.Settings.DisableAnimation then
		local AnimateScript = Character.Animate:Clone()
		AnimateScript.Parent = DummyChar
		AnimateScript.Disabled = false
	end
	Character.Animate:Destroy()

	for _, object in ipairs(Character:GetChildren()) do
		if object:IsA("BasePart") then
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
		if _G.Settings.PlayerCanCollide then
			for _, object in ipairs(Character:GetChildren()) do
				if object:IsA("BasePart") and object.CanCollide == true then
					object.CanCollide = false
				end
			end
		else
			for _, object in ipairs(Character:GetDescendants()) do
				if object:IsA("BasePart") and object.CanCollide == true then
					object.CanCollide = false
				end
			end
		end
	end)

	_G.Connections[3] = RunService.Heartbeat:Connect(function()
		for _, object in ipairs(Character:GetChildren()) do
			if object:IsA("BasePart") then
				if object.Name == "HumanoidRootPart" then
					object.CFrame = CFrame.new(object.Joint.Position)
				else
					object.CFrame = DummyChar[object.Name].CFrame * object.Joint.CFrame
					if not _G.Settings.CanFlingPlayers then object.Velocity = Vector3.new(50, 50, 50) end
				end
			end
		end
	end)

	local ResetBindable = Instance.new("BindableEvent")
	_G.Connections[4] = ResetBindable.Event:Connect(function()
		if not game:GetService("Players").LocalPlayer.Character:FindFirstChild("NETLESS-REANIMATE") then
		    game:GetService("Players").LocalPlayer.Character:BreakJoints()
		else
            Character:Destroy()
            for _, connection in ipairs(_G.Connections) do
                connection:Disconnect()
            end
            _G.Connections = {}
		end
	end)
	StarterGui:SetCore("ResetButtonCallback", ResetBindable)
end
