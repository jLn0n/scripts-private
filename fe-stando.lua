-- // SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UIS = game:GetService("UserInputService")
-- // OBJECTS
local Player = Players.LocalPlayer
local Character = Player.Character
local Humanoid = Character.Humanoid
-- // VARIABLES
_G.Connections = _G.Connections or {}
local HatParts = {
	["Head"] = Character:FindFirstChild("MeshPartAccessory"),
	["Left Arm"] = Character:FindFirstChild("Pal Hair"),
	["Left Leg"] = Character:FindFirstChild("Pink Hair"),
	["Right Arm"] = Character:FindFirstChild("Hat1"),
	["Right Leg"] = Character:FindFirstChild("LavanderHair"),
	["Torso1"] = Character:FindFirstChild("Robloxclassicred"),
	["Torso2"] = Character:FindFirstChild("Kate Hair")
}
local StandoStates = {
	["Enabled"] = true,
	["AnimState"] = "Idle"
}
local rad, sin = math.rad, math.sin
local anim, animSpeed = 0, 0
local StandoCFrame = CFrame.new(Vector3.new(.75, 1.85, 2.5))
-- // MAIN
local initMotor = function(motor)
	return {
		Object = motor, -- The weld that will lerp
		CFrame = motor.C0, -- Where it will lerp to; a CFrame
		Cache = motor.C0, -- Cache of original position; it helps when making anim keyframes
	}
end

for _, connection in ipairs(_G.Connections) do connection:Disconnect() end _G.Connections = {}
Workspace.FallenPartsDestroyHeight = 0 / 1 / 0

local StandoChar = game:GetObjects("rbxassetid://6843243348")[1]
StandoChar.Name = "StandoCharacter"
StandoChar.Parent = Character

local Motors = {
	Neck = initMotor(StandoChar.Torso.Neck),
	RS = initMotor(StandoChar.Torso["Right Shoulder"]),
	LS = initMotor(StandoChar.Torso["Left Shoulder"]),
	RH = initMotor(StandoChar.Torso["Right Hip"]),
	LH = initMotor(StandoChar.Torso["Left Hip"]),
	RJoint = initMotor(StandoChar.HumanoidRootPart.RootJoint),
}

for _, object in ipairs(StandoChar:GetChildren()) do if object:IsA("BasePart") then object.Transparency = 1 end end
for PartName, object in pairs(HatParts) do
	object.Handle:FindFirstChildWhichIsA("Weld"):Destroy()
	if PartName ~= "Head" then
		object.Handle:FindFirstChildWhichIsA("SpecialMesh"):Destroy()
	end
end

_G.Connections[#_G.Connections + 1] = UIS.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Keyboard and not UIS:GetFocusedTextBox() then
		if input.KeyCode == Enum.KeyCode.Q then
			StandoStates.Enabled = not StandoStates.Enabled
			if StandoStates.Enabled then
				StandoCFrame = CFrame.new(Vector3.new(.75, 1.85, 2.5))
			else
				StandoCFrame = CFrame.new(Vector3.new(0, 100, 0))
			end
		end
	end
end)

_G.Connections[#_G.Connections + 1] = RunService.Stepped:Connect(function()
	for _, object in ipairs(Character:GetChildren()) do
		if object:IsA("Accessory") and object:FindFirstChild("Handle") then
			object.Handle.CanCollide = false
			object.Handle.Massless = true
			object.Handle.Velocity = Vector3.new(0, 40, 0)
			object.Handle.RotVelocity = Vector3.new()
		end
	end

	for _, object in ipairs(StandoChar:GetDescendants()) do
		if object:IsA("BasePart") then
			object.CanCollide = false
		end
	end
end)

_G.Connections[#_G.Connections + 1] = RunService.Heartbeat:Connect(function()
	StandoChar.HumanoidRootPart.CFrame = Character.HumanoidRootPart.CFrame * StandoCFrame
	HatParts.Head.Handle.CFrame = StandoChar.Head.CFrame * CFrame.new(Vector3.new(0, .325, 0))
	HatParts.Torso1.Handle.CFrame = StandoChar.Torso.CFrame * CFrame.new(Vector3.new(.5, 0, 0)) * CFrame.Angles(rad(90), 0, 0)
	HatParts.Torso2.Handle.CFrame = StandoChar.Torso.CFrame * CFrame.new(Vector3.new(-.5, 0, 0)) * CFrame.Angles(rad(90), 0, 0)
	HatParts["Left Arm"].Handle.CFrame = StandoChar["Left Arm"].CFrame * CFrame.Angles(rad(90), 0, 0)
	HatParts["Left Leg"].Handle.CFrame = StandoChar["Left Leg"].CFrame * CFrame.Angles(rad(90), 0, 0)
	HatParts["Right Arm"].Handle.CFrame = StandoChar["Right Arm"].CFrame * CFrame.Angles(rad(90), 0, 0)
	HatParts["Right Leg"].Handle.CFrame = StandoChar["Right Leg"].CFrame * CFrame.Angles(rad(90), 0, 0)
end)

_G.Connections[#_G.Connections + 1] = RunService.Stepped:Connect(function()
	anim = (anim % 100) + animSpeed / 10
	for _, motor in pairs(Motors) do
		motor.Object.C0 = motor.CFrame
	end
	if StandoStates.Enabled then
		if StandoStates.AnimState == "Idle" then
			Motors.RJoint.CFrame = Motors.RJoint.Cache * CFrame.Angles(0, 0, rad(7.5))
		elseif StandoStates.AnimState == "Barrage" then
			
		end
	else
		for _, motor in pairs(Motors) do
			motor.CFrame = motor.Cache
		end
	end
end)

_G.Connections[#_G.Connections + 1] = Humanoid.Died:Connect(function()
	for _, connection in ipairs(_G.Connections) do
		connection:Disconnect()
	end
	_G.Connections = {}
end)
