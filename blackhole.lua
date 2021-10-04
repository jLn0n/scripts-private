-- // SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
-- // OBJECTS
local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()
local attHolder = Instance.new("Part")
local Attachment1 = Instance.new("Attachment")
-- // VARIABLES
local BlackholePos = Mouse.Hit.Position + Vector3.new(0, 2.5, 0)
-- // MAIN
attHolder.Anchored, attHolder.CanCollide, attHolder.Transparency = true, false, .5
attHolder.Parent, Attachment1.Parent = workspace, attHolder
local function controlPart(object)
	if object:IsA("BasePart") and ((game.PlaceId == 189707 and object.Anchored and object:IsDescendantOf(workspace.Structure)) or not object.Anchored) and not object:IsDescendantOf(Player.Character) then
		for _, sobject in ipairs(object:GetChildren()) do
			if sobject:IsA("Attachment") and sobject:IsA("AlignPosition") and sobject:IsA("Torque") and sobject:IsA("BodyMover") or sobject:IsA("RocketPropulsion") then
				sobject:Destroy()
			end
		end
		object.CanCollide = false
		local Torque, APos, Attachment0 = Instance.new("Torque", object), Instance.new("AlignPosition", object), Instance.new("Attachment", object)
		Torque.Attachment0 = Attachment0
		Torque.Torque = Vector3.new(1e10, 1e10, 1e10)
		APos.Attachment0, APos.Attachment1 = Attachment0, Attachment1
		APos.MaxForce = 9999999999
		APos.MaxVelocity = math.huge
		APos.Responsiveness = 200
	end
end

local function setsimulationradius(simRad, maxSimRad)
	sethiddenproperty(Player, "MaxSimulationRadius", maxSimRad)
	sethiddenproperty(Player, "SimulationRadius", simRad)
end

for _, object in ipairs(workspace:GetDescendants()) do
	controlPart(object)
end

workspace.DescendantAdded:Connect(function(object)
	controlPart(object)
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
	Player.ReplicationFocus = workspace
	attHolder.Position = BlackholePos
end)
