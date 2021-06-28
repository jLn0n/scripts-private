-- // SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
-- // OBJECTS
local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()
local AttHolder = Instance.new("Part", Workspace)
local Attachment1 = Instance.new("Attachment", AttHolder)
-- // VARIABLES
local BlackholePos = Mouse.Hit.Position + Vector3.new(0, 2.5, 0)
-- // MAIN
AttHolder.Anchored, AttHolder.CanCollide, AttHolder.Transparency = true, false, .5
local ForcePart = function(object)
	if object:IsA("BasePart") and (object.Anchored and object:IsDescendantOf(Workspace.Structure) or not object.Anchored) and not object:IsDescendantOf(Player.Character) then
		for _, sobject in ipairs(object:GetChildren()) do
			if sobject:IsA("Attachment") and sobject:IsA("AlignPosition") and sobject:IsA("Torque") and sobject:IsA("BodyMover") or sobject:IsA("RocketPropulsion") then
				sobject:Destroy()
			end
		end
		local Torque, APos, Attachment0 = Instance.new("Torque", object), Instance.new("AlignPosition", object), Instance.new("Attachment", object)
		Torque.Attachment0 = Attachment0
		Torque.Torque = Vector3.new(10e10, 10e10, 10e10)
		APos.Attachment0, APos.Attachment1 = Attachment0, Attachment1
		APos.MaxForce = 10e10
		APos.MaxVelocity = math.huge
		APos.Responsiveness = 200
	end
end

for _, object in ipairs(Workspace:GetDescendants()) do
	ForcePart(object)
end

Workspace.DescendantAdded:Connect(function(object)
	ForcePart(object)
end)

UIS.InputBegan:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.E and not UIS:GetFocusedTextBox() then
		BlackholePos = Mouse.Hit.Position + Vector3.new(0, 2.5, 0)
	end
end)

RunService.RenderStepped:Connect(function()
	settings().Physics.AllowSleep = false
	settings().Physics.PhysicsEnvironmentalThrottle = Enum.EnviromentalPhysicsThrottle.Disabled
	setsimulationradius(1e10, 1e10)
	AttHolder.Position = BlackholePos
end)
