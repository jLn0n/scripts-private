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
local WaitTime = .15
local MotorNames = {
	["Head"] = "Neck",
	["Left Arm"] = "Left Shoulder",
	["Right Arm"] = "Right Shoulder",
	["Left Leg"] = "Left Hip",
	["Right Leg"] = "Right Hip",
	["HumanoidRootPart"] = "RootJoint",
}
local random = math.random
-- // MAIN
_G.Settings = {
	PlayerCanCollide = _G.Settings.PlayerCanCollide or true,
	RemoveAccessories = _G.Settings.RemoveAccessories or false,
	HRPFling = _G.Settings.HRPFling or false,
}
if Humanoid.RigType == Enum.HumanoidRigType.R6 and not Character:FindFirstChild("REANIMATE") then
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
		for _, ClickDetector in ipairs(Workspace.NewerMap:GetDescendants()) do
			if ClickDetector:IsA("ClickDetector") and ClickDetector.Parent.Name == "Cannon" then
				ClickDetector:Destroy()
			end
		end
		WaitTime = 5
	end

	OldPos = Character:GetPrimaryPartCFrame()
	Workspace.FallenPartsDestroyHeight = 0 / 1 / 0

	local Folder = Instance.new("Folder")
	Folder.Name = "REANIMATE"
	local DummyChar = game:GetObjects("rbxassetid://6843243348")[1]
	DummyChar.Name = "Dummy"; DummyChar.Parent = Folder
	local FakeChar = DummyChar:Clone()
	local Torso = Character.Torso
	local RArm = Character["Right Arm"]

	for _, gui in ipairs(Player.PlayerGui:GetChildren()) do if gui:IsA("ScreenGui") then gui.ResetOnSpawn = false end end
	Player.Character = FakeChar
	wait(WaitTime)
	Player.Character = Character
	wait(5)
	Character:BreakJoints()
	Folder.Parent = Character
	Character.PrimaryPart = DummyChar.PrimaryPart
	Character:SetPrimaryPartCFrame(OldPos)
	Workspace.CurrentCamera.CameraSubject = DummyChar.Humanoid

	for _, sound in ipairs(HRP:GetChildren()) do if sound:IsA("Sound") then sound:Destroy() end end
	for _, object in ipairs(Character:GetChildren()) do
		if object:IsA("BasePart") then
			if MotorNames[object.Name] then
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
			local OffsetAtt = Instance.new("Attachment")
			OffsetAtt.Name = "Offset"
			OffsetAtt.Parent = object
		elseif object:IsA("Accessory") then
			if not _G.Settings.RemoveAccessories then
				local Clone = object:Clone()
				Clone.Handle.Transparency = 1
				Clone.Parent = DummyChar
				local OffsetAtt = Instance.new("Attachment")
				OffsetAtt.Name = "Offset"
				OffsetAtt.Parent = object.Handle
			else
				object:Destroy()
			end
		end
	end

	for _, object in ipairs(DummyChar:GetChildren()) do
		if object:IsA("BasePart") then
			object.Transparency = 1
		end
	end

	_G.Connections[1] = RunService.Stepped:Connect(function()
		for _, object in ipairs(Character:GetDescendants()) do
			if object:IsA("BasePart") and not object.Parent:IsA("Tool") then
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

		DummyChar.Humanoid:Move(Humanoid.MoveDirection, false)
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
		for _, object in ipairs(Character:GetChildren()) do
			if object:IsA("BasePart") and object.Name ~= "HumanoidRootPart" then
				object.Velocity = Vector3.new(0, 40, 0)
				object.RotVelocity = Vector3.new()
			elseif object:IsA("Accessory") or object:IsA("Tool") and object.Handle then
				object.Handle.Massless = true
				object.Handle.Velocity = Vector3.new(0, 40, 0)
				object.Handle.RotVelocity = Vector3.new()
			end
		end
	end)

	_G.Connections[3] = RunService.Heartbeat:Connect(function()
		for _, object in ipairs(Character:GetChildren()) do
			if DummyChar:FindFirstChild(object.Name) then
				if object:IsA("BasePart") then
					if object.Name ~= "HumanoidRootPart" then
						object.CFrame = DummyChar[object.Name].CFrame * object.Offset.CFrame
					else
						if _G.Settings.HRPFling then
							object.Transparency = .5
							object.CFrame = CFrame.new(object.Offset.Position)
							object.Orientation = Vector3.new(random(-180, 180), random(-180, 180), random(-180, 180))
							object.Velocity = Vector3.new(0, -10e8, 0)
						else
							object.Transparency = 1
							object.CFrame = DummyChar[object.Name].CFrame * object.Offset.CFrame
							object.Velocity = Vector3.new(0, 40, 0)
						end
					end
				elseif object:IsA("Accessory") and Character:FindFirstChild(object.Name) then
					object.Handle.CFrame = DummyChar[object.Name].Handle.CFrame * object.Handle.Offset.CFrame
				end
			end
			if object:IsA("Tool") and object.Handle then
				object.Handle.CFrame = RArm.CFrame * CFrame.new(0, -1, 0, 1, 0, 0, 0, 0, 1, 0, -1, 0) * object.Grip:inverse()
			end
		end
	end)

	if not _G.PlayerResetConnection then
		local ResetBindable = Instance.new("BindableEvent")
		_G.PlayerResetConnection = ResetBindable.Event:Connect(function()
			for _, connection in ipairs(_G.Connections) do connection:Disconnect() end _G.Connections = {}
			if Player.Character:FindFirstChild("REANIMATE") then
				Player.Character:Destroy()
				Player.Character = FakeChar
				Player.CharacterAdded:Wait()
				FakeChar:Destroy()
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
