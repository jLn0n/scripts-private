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
local WaitTime = .25
local rad, random = math.rad, math.random
-- // MAIN
_G.Settings = _G.Settings or {
	PlrCanCollide = _G.Settings.PlrCanCollide or true,
	EnableFling = _G.Settings.EnableFling or false
}
if Humanoid.RigType == Enum.HumanoidRigType.R6 and not Character:FindFirstChild(Player.UserId) then
	for _, connection in ipairs(_G.Connections) do connection:Disconnect() end _G.Connections = {}
	if game.PlaceId == 2041312716 then
		Character:FindFirstChild("FirstPerson"):Destroy()
		Character:FindFirstChild("Local Ragdoll"):Destroy()
		Character:FindFirstChild("Controls"):Destroy()
		Character:FindFirstChild("State Handler"):Destroy()
		for _, constraint in ipairs(Character:GetChildren()) do if constraint:IsA("BallSocketConstraint") or constraint:IsA("HingeConstraint") then constraint:Destroy() end end
		for _, cannonBtn in ipairs(Workspace.NewerMap:GetDescendants()) do if cannonBtn:IsA("ClickDetector") and cannonBtn.Parent.Name == "Cannon" then cannonBtn:Destroy() end end
		WaitTime += 5
	end

	OldPos = Character:GetPrimaryPartCFrame()
	Workspace.FallenPartsDestroyHeight = 0 / 1 / 0

	local DummyChar = game:GetObjects("rbxassetid://6843243348")[1]
	local Humanoid2 = DummyChar.Humanoid
	DummyChar.Name = Player.UserId

	for _, gui in ipairs(Player.PlayerGui:GetChildren()) do if gui:IsA("ScreenGui") then gui.ResetOnSpawn = false end end
	HRP.Anchored = true
	Player.Character = DummyChar
	wait(WaitTime)
	Player.Character = Character
	wait(5)
	Character:BreakJoints()
	Humanoid.BreakJointsOnDeath = false
	Character.Animate.Disabled = true
	Character.Animate.Parent = DummyChar
	Humanoid.Animator:Clone().Parent = DummyChar.Humanoid
	DummyChar.Parent = Character
	Character.Head.face.Parent = DummyChar.Head
	Character.PrimaryPart = DummyChar.PrimaryPart
	Character:SetPrimaryPartCFrame(OldPos)
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
		settings().Physics.AllowSleep = false
		settings().Physics.PhysicsEnvironmentalThrottle = Enum.EnviromentalPhysicsThrottle.DefaultAuto
		settings().Physics.ThrottleAdjustTime = -math.huge

		for _, object in ipairs(Character:GetChildren()) do
			if object:IsA("BasePart") then
				object.Massless = true
				if object.Name ~= "HumanoidRootPart" then
					object.Velocity = Vector3.new(0, 40, 0)
					object.RotVelocity = Vector3.new()
				else
					if _G.Settings.EnableFling then
						object.Velocity = Vector3.new(0, 10e10, 0)
						object.RotVelocity = Vector3.new()
					else
						object.Velocity = Vector3.new(0, 40, 0)
						object.RotVelocity = Vector3.new()
					end
				end
			elseif object:IsA("Accessory") and object:FindFirstChild("Handle") then
				object.Handle.Massless = true
				object.Handle.Velocity = Vector3.new(0, 40, 0)
				object.Handle.RotVelocity = Vector3.new()
			end
		end

		for _, object in ipairs(Character:GetDescendants()) do
			if object:IsA("BasePart") and not object.Parent:IsA("Tool") then
				object.LocalTransparencyModifier = DummyChar.Head.LocalTransparencyModifier
			end
		end

		for _, object in ipairs(Character:GetChildren()) do
			if object:IsA("BasePart") then
				object.CanCollide = false
			end
		end

		if not _G.Settings.PlrCanCollide then
			for _, object in ipairs(DummyChar:GetDescendants()) do
				if object:IsA("BasePart") then
					object.CanCollide = false
				end
			end
		end

		Workspace.CurrentCamera.CameraSubject = DummyChar.Humanoid
		Humanoid2:Move(Humanoid.MoveDirection, false)
		if UIS:IsKeyDown(Enum.KeyCode.Space) and UIS:GetFocusedTextBox() == nil then
			Humanoid2.Jump = true
		end
	end)

	_G.Connections[2] = RunService.Heartbeat:Connect(function()
		for _, object in ipairs(Character:GetChildren()) do
			if DummyChar:FindFirstChild(object.Name) then
				if object:IsA("BasePart") then
					if object.Name ~= "HumanoidRootPart" then
						object.CFrame = DummyChar[object.Name].CFrame * DummyChar[object.Name].Offset.CFrame
					else
						if _G.Settings.EnableFling then
							object.CFrame = CFrame.new(DummyChar[object.Name].Offset.Position) * CFrame.Angles(rad(random(-180, 180)), rad(random(-180, 180)), rad(random(-180, 180)))
						else
							object.CFrame = DummyChar[object.Name].CFrame * DummyChar[object.Name].Offset.CFrame
						end
					end
				elseif object:IsA("Accessory") and object:FindFirstChild("Handle") then
					object.Handle.CFrame = DummyChar[object.Name].Handle.CFrame * CFrame.new(DummyChar.Head.Offset.Position) * DummyChar[object.Name].Handle.Offset.CFrame
				end
			end
		end
	end)

	if not _G.PlayerResetConnection then local faekChar, humFaek
		local ResetBindable = Instance.new("BindableEvent")
		faekChar = Instance.new("Model"); humFaek = Instance.new("Humanoid"); humFaek.Parent = faekChar
		_G.PlayerResetConnection = ResetBindable.Event:Connect(function()
			for _, connection in ipairs(_G.Connections) do connection:Disconnect() end _G.Connections = {}
			if Player.Character:FindFirstChild(Player.UserId) then
				Player.Character[Player.UserId]:Destroy()
				Player.Character = faekChar
			else
				Player.Character:BreakJoints()
			end
		end)
		StarterGui:SetCore("ResetButtonCallback", ResetBindable)
	end

	StarterGui:SetCore("SendNotification", {
		Title = "REANIMATE",
		Text = "REANIMATE is now ready!\nThanks for using the script!\n",
		Cooldown = 1
	})
end
