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
_G.Settings = _G.Settings or {}
local OldPos
local WaitTime = .1
-- // MAIN
local CreateAntiGrav = function(object, multiplier)
	multiplier = multiplier or .1
	local BodyForce = Instance.new("BodyForce")
	BodyForce.Force = Vector3.new(0, Workspace.Gravity * object:GetMass() * multiplier, 0)
	BodyForce.Parent = object
end
if Humanoid.RigType == Enum.HumanoidRigType.R6 and not _G.REANIMATE_RUNNING then
	for _, connection in ipairs(_G.Connections) do
		connection:Disconnect()
	end

	_G.Settings = {
		WaitTime = _G.Settings.WaitTime or 5,
		DisableAnimations = _G.Settings.DisableAnimations or false,
		PlayerCanCollide = _G.Settings.PlayerCanCollide or true,
		RemoveAccessories = _G.Settings.RemoveAccessories or false,
		HRPFling = _G.Settings.HRPFling or false,
	}

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

	Character.Animate.Disabled = true
	Humanoid.Animator:Destroy()
	Player.Character = AntiSpawnChar
	wait(WaitTime)
	Player.Character = Character
	wait(_G.Settings.WaitTime)
	Character:BreakJoints()
	RJointAtt.Parent = HRP

	for _, object in ipairs(HRP:GetChildren()) do
		if not object:IsA("Attachment") then
			object:Destroy()
		end
	end

	Folder.Parent = Character
	DummyChar:SetPrimaryPartCFrame(OldPos)
	DummyChar.HumanoidRootPart.Anchored = false
	DummyChar.Humanoid.MaxHealth = math.huge
	DummyChar.Humanoid.Health = math.huge
	DummyChar.Head.face.Texture = ""
	Workspace.CurrentCamera.CameraSubject = DummyChar.Humanoid

	if not _G.Settings.DisableAnimations then
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

			CreateAntiGrav(object)
		elseif object:IsA("Accessory") then
			if not _G.Settings.RemoveAccessories then
				local Clone = object:Clone()
				Clone.Handle.Transparency = 1
				Clone.Parent = DummyChar

				local Attachment = Instance.new("Attachment")
				Attachment.Parent = object.Handle

				CreateAntiGrav(object.Handle, 2)
			else
				object:Destroy()
			end
		end
	end

	for _, object in ipairs(DummyChar:GetChildren()) do
		if object:IsA("BasePart") and object.Name ~= "HumanoidRootPart" then
			object.Transparency = 1
		end
	end

	_G.Connections[1] = RunService.Heartbeat:Connect(function()
        DummyChar.Humanoid:Move(Humanoid.MoveDirection)

		for _, object in ipairs(Character:GetDescendants()) do
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
		if _G.Settings.PlayerCanCollide == true then
			for _, object in ipairs(Character:GetChildren()) do
				if object:IsA("BasePart") and object.CanCollide == true then
					object.CanCollide = false
				end
			end
		elseif _G.Settings.PlayerCanCollide == false then
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
					object.CFrame = DummyChar[object.Name].CFrame * CFrame.new(object.Joint.Position)
					if _G.Settings.HRPFling then
						object.Velocity = Vector3.new(-10e8, -10e8, -10e8)
					else
						object.Velocity = Vector3.new(0, 40, 0)
					end
				else
					object.CFrame = DummyChar[object.Name].CFrame * object.Joint.CFrame
					object.Velocity = Vector3.new(0, 40, 0)
				end
			elseif object:IsA("Accessory") then
				object.Handle.CFrame = DummyChar[object.Name].Handle.CFrame * object.Handle.Attachment.CFrame
				object.Handle.Velocity = Vector3.new(0, 40, 0)
			end
		end
	end)

	local ResetBindable = Instance.new("BindableEvent")
	if _G.PlayerResetConnection then _G.PlayerResetConnection:Disconnect() end
	_G.PlayerResetConnection = ResetBindable.Event:Connect(function()
		if not Player.Character:FindFirstChild("NETLESS-REANIMATE") then
			Player.Character:BreakJoints()
		else
			Character:Destroy()
			for _, connection in ipairs(_G.Connections) do
				connection:Disconnect()
			end
			_G.Connections = {}
            _G.REANIMATE_RUNNING = false
		end
	end)
	StarterGui:SetCore("ResetButtonCallback", ResetBindable)
    _G.REANIMATE_RUNNING = true
end
