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
local MotorNames = {
	["Head"] = "Neck",
	["Left Arm"] = "Left Shoulder",
	["Right Arm"] = "Right Shoulder",
	["Left Leg"] = "Left Hip",
	["Right Leg"] = "Right Hip",
	["HumanoidRootPart"] = "RootJoint",
}
-- // MAIN
local CreateAntiGrav = function(object, multiplier)
	multiplier = multiplier or .1
	local BodyForce = Instance.new("BodyForce")
	BodyForce.Force = Vector3.new(0, Workspace.Gravity * object:GetMass() * multiplier, 0)
	BodyForce.Parent = object
end
if Humanoid.RigType == Enum.HumanoidRigType.R6 then
	settings().Physics.AllowSleep = false

	for _, connection in ipairs(_G.Connections) do
		connection:Disconnect()
	end

	_G.Settings = {
		PlayerCanCollide = _G.Settings.PlayerCanCollide or true,
		RemoveAccessories = _G.Settings.RemoveAccessories or false,
		HRPFling = _G.Settings.HRPFling or false,
	}

	OldPos = Character:GetPrimaryPartCFrame()
	Workspace.FallenPartsDestroyHeight = 0 / 1 / 0

	local Torso = Character.Torso

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

		for _, ClickDetector in ipairs(Workspace.NewerMap.Obstacles.Cannons:GetDescendants()) do
			if ClickDetector:IsA("ClickDetector") then
				ClickDetector:Destroy()
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

	Character.Animate:Destroy()
	Humanoid.Animator:Destroy()
	Player.Character = AntiSpawnChar
	wait(WaitTime)
	Player.Character = Character
	wait(5)
	Character:BreakJoints()
	AntiSpawnChar:Destroy()

	Folder.Parent = Character
	DummyChar:SetPrimaryPartCFrame(OldPos)
	DummyChar.HumanoidRootPart.Anchored = false
	DummyChar.Humanoid.MaxHealth = math.huge
	DummyChar.Humanoid.Health = math.huge
	DummyChar.Head.face.Texture = ""
	Workspace.CurrentCamera.CameraSubject = DummyChar.Humanoid

	for _, object in ipairs(HRP:GetChildren()) do
		object:Destroy()
	end

	for _, object in ipairs(Character:GetChildren()) do
		if object:IsA("BasePart") then
			if object.Name ~= "Torso" then
				local motor = Instance.new("Motor6D")
				motor.Name = MotorNames[object.Name]
				if object.Name ~= "HumanoidRootPart" then
					motor.C0 = DummyChar.Torso[motor.Name].C0
					motor.C1 = DummyChar.Torso[motor.Name].C1
					motor.Parent = Torso
				else
					motor.C0 = DummyChar.HumanoidRootPart[motor.Name].C0
					motor.C1 = DummyChar.HumanoidRootPart[motor.Name].C1
					motor.Parent = HRP
				end
			end
			if object.Name ~= "HumanoidRootPart" then
				local OffsetAtt = Instance.new("Attachment")
				OffsetAtt.Name = "Offset"
				OffsetAtt.Parent = object
			end

			CreateAntiGrav(object)
		elseif object:IsA("Accessory") then
			if not _G.Settings.RemoveAccessories then
				local Clone = object:Clone()
				Clone.Handle.Transparency = 1
				Clone.Parent = DummyChar

				CreateAntiGrav(object.Handle, 5)
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

		for _, motor in ipairs(Torso:GetChildren()) do
			if motor:IsA("Motor6D") then
				DummyChar.Torso[motor.Name].C0 = motor.C0
				DummyChar.Torso[motor.Name].C1 = motor.C1
			end
		end

		DummyChar.HumanoidRootPart.RootJoint.C0 = HRP.RootJoint.C0
		DummyChar.HumanoidRootPart.RootJoint.C1 = HRP.RootJoint.C1

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
		elseif not _G.Settings.PlayerCanCollide then
			for _, object in ipairs(Character:GetDescendants()) do
				if object:IsA("BasePart") and object.CanCollide == true then
					object.CanCollide = false
				end
			end
		end
	end)

	_G.Connections[3] = RunService.Heartbeat:Connect(function()
		for _, object in ipairs(Character:GetChildren()) do
			if DummyChar:FindFirstChild(object.Name) then
				if object:IsA("BasePart") then
					if object.Name == "HumanoidRootPart" then
						object.CFrame = DummyChar[object.Name].CFrame
					else
						object.CFrame = DummyChar[object.Name].CFrame * object["Offset"].CFrame
					end
					object.Velocity = Vector3.new(0, 40, 0)
				elseif object:IsA("Accessory") and Character:FindFirstChild(object.Name) then
					object.Handle.CFrame = DummyChar[object.Name].Handle.CFrame
					object.Handle.Velocity = Vector3.new(0, 40, 0)
				end
			end
		end
	end)

	local ResetBindable = Instance.new("BindableEvent")
	if _G.PlayerResetConnection then _G.PlayerResetConnection:Disconnect() end
	_G.PlayerResetConnection = ResetBindable.Event:Connect(function()
		if Character.Parent ~= nil then
			Player.Character = Character
			Character:Destroy()
		else
			Player.Character:BreakJoints()
		end

		for _, connection in ipairs(_G.Connections) do
			connection:Disconnect()
		end
		_G.Connections = {}
	end)
	StarterGui:SetCore("ResetButtonCallback", ResetBindable)
end