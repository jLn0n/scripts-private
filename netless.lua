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
local IsNetworkOwner = loadstring(game:HttpGet("https://raw.githubusercontent.com/OpenGamerTips/Roblox-Scripts/main/NetworkScripts/ownership.lua"))()
if Humanoid.RigType == Enum.HumanoidRigType.R6 and IsNetworkOwner then
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
		
		for _, RagdollConstraint in pairs(Character:GetChildren()) do
			if RagdollConstraint:IsA("BallSocketConstraint") or RagdollConstraint:IsA("HingeConstraint") then
				RagdollConstraint:Destroy()
			end
		end
	end

	Character:SetPrimaryPartCFrame(CFrame.new(Vector3.new(0, 10000, 0)))
	wait(.5)
	HRP:Destroy()
	Humanoid.WalkSpeed = 0
	Humanoid.JumpPower = 0
	Humanoid.Animator:Destroy()

	local AntiSpawnChar = Instance.new("Model")
	local FHumanoid = Instance.new("Humanoid")

	FHumanoid.Parent = AntiSpawnChar
	AntiSpawnChar.Parent = Workspace.Terrain
	Player.Character = AntiSpawnChar

	local Folder = Instance.new("Folder")
	Folder.Name = "FakeChar"
	Folder.Parent = Character
	local FakeChar = game:GetObjects("rbxassetid://5904819435")[1]
	FakeChar.Name = "FakeChar"
	FakeChar.Parent = Folder

	for _, object in ipairs(Torso:GetChildren()) do
		if object:IsA("Motor6D") then
			local Attachment = Instance.new("Attachment")
			Attachment.Name = object.Name
			Attachment.Parent = Torso
			Attachment.CFrame = object.C0
			object:Destroy()
		end
	end

	local RJointAtt = Instance.new("Attachment")
	RJointAtt.Name = "RootJoint"
	RJointAtt.Parent = Torso
	RJointAtt.CFrame = FakeChar.HumanoidRootPart.RootJoint.C0

	FakeChar.HumanoidRootPart.Anchored = false
	FakeChar:SetPrimaryPartCFrame(OldPos)
	FakeChar.Humanoid.HipHeight += .1
	Workspace.CurrentCamera.CameraSubject = FakeChar.Humanoid
	Humanoid.Health = 0

	FakeChar.Humanoid.MaxHealth = math.huge
	FakeChar.Humanoid.Health = math.huge
	FakeChar.Head.face.Texture = ""
	
	for _, object in ipairs(FakeChar:GetChildren()) do
		if object:IsA("BasePart") then
			object.Transparency = 1
		end
	end

    for _, object in ipairs(Character:GetChildren()) do
        if object:IsA("Accessory") then
            object.Parent = FakeChar
		elseif object:IsA("BodyColors") or object:IsA("CharacterMesh") then
			object = object:Clone()
			object.Parent = FakeChar
        end
    end

	_G.Connections[1] = RunService.RenderStepped:Connect(function()
		FakeChar.Humanoid:Move(FHumanoid.MoveDirection)

		for _, object in ipairs(Character:GetDescendants()) do
			if object:IsA("BasePart") then
				object.CanCollide = false
				object.LocalTransparencyModifier = FakeChar.Head.LocalTransparencyModifier
			end
		end

		for _, object in ipairs(FakeChar:GetDescendants()) do
			if object:IsA("BasePart") then
				object.CanCollide = false
			end
		end

		for _, motor6d in ipairs(FakeChar.Torso:GetChildren()) do
			if motor6d:IsA("Motor6D") then
				if motor6d.C0 ~= Torso[motor6d.Name].CFrame then
					motor6d.C0 = Torso[motor6d.Name].CFrame
				end
			end
		end
		
		if FakeChar.HumanoidRootPart.RootJoint.C0 ~= Character.Torso.RootJoint.CFrame then
			FakeChar.HumanoidRootPart.RootJoint.C0 = Character.Torso.RootJoint.CFrame
		end

		if UIS:IsKeyDown(Enum.KeyCode.Space) and UIS:GetFocusedTextBox() == nil then
			FakeChar.Humanoid.Jump = true
		end
	end)
	
	_G.Connections[2] = RunService.Heartbeat:Connect(function()
		for _, object in ipairs(Character:GetChildren()) do
			if object:IsA("BasePart") then
				object.CFrame = FakeChar[object.Name].CFrame
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