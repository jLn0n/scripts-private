-- // SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
-- // OBJECTS
local Player = Players.LocalPlayer
local Character = Player.Character
local Torso = Character.Torso
local HRP = Character.HumanoidRootPart
local Keyboard = Character.Keyboard
-- // VARIABLES
local rad, sin, cos, floor = math.rad, math.sin, math.cos, math.floor
local anim, animSpeed = 0, 0
-- // MAIN
Character.Animate.Disabled = true
local initMotor = function(motor, notSetOffsets)
	local motor6d = Instance.new("Motor6D")
	motor6d.Part0, motor6d.Part1 = motor.Part0, motor.Part1
	motor6d.C0, motor6d.C1 = not notSetOffsets and motor.C0 or CFrame.new(), not notSetOffsets and motor.C1 or CFrame.new()
	motor6d.Name, motor6d.Parent = motor.Name, motor.Parent
	motor:Destroy()
	return {
		Object = motor6d,
		CFrame = motor6d.Transform,
		Cache = motor6d.Transform
	}
end

local Motors = {
	["Neck"] = initMotor(Torso.Neck),
	["RS"] = initMotor(Torso["Right Shoulder"]),
	["LS"] = initMotor(Torso["Left Shoulder"]),
	["RH"] = initMotor(Torso["Right Hip"]),
	["LH"] = initMotor(Torso["Left Hip"]),
	["RJoint"] = initMotor(HRP.RootJoint),
	["GunWeld"] = initMotor(Keyboard.Handle:FindFirstChildWhichIsA("Weld"), true),
}

_G.Connections[#_G.Connections + 1] = RunService.Stepped:Connect(function()
	anim = (anim % 100) + animSpeed / 10
	for _, motor in pairs(Motors) do
		motor.Object.Transform = motor.CFrame
	end

	Motors.GunWeld.CFrame = Motors.RS.CFrame * CFrame.new(Vector3.new(0, 1, 1.25)) * CFrame.Angles(rad(), 0, rad(39.175))
end)
