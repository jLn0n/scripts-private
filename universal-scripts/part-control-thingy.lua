-- services
local coreGui = game:GetService("CoreGui")
local inputService = game:GetService("UserInputService")
local players = game:GetService("Players")
local runService = game:GetService("RunService")
local starterGui = game:GetService("StarterGui")
-- objects
local player = players.LocalPlayer
local mouse = player:GetMouse()
local character = player.Character
local resetBindable = Instance.new("BindableEvent")
-- variables
local destroyFunc, resetBindableConnection = character.Destroy, nil
local partControllers = table.create(0)
local controlMode = "move" -- move | rotate
local controllingPart
-- functions
local function initPartController(accessory)
	local accHandle = accessory:FindFirstChild("Handle")
	local alignPos, alignOrt = Instance.new("AlignPosition"), Instance.new("AlignOrientation")
	local attachment, _attachment = Instance.new("Attachment"), Instance.new("Attachment")
	alignPos.ApplyAtCenterOfMass = true
	alignPos.Mode, alignOrt.Mode = Enum.PositionAlignmentMode.OneAttachment, Enum.OrientationAlignmentMode.OneAttachment
	alignPos.MaxForce, alignOrt.MaxTorque = 9e9, math.huge
	alignPos.MaxVelocity, alignOrt.MaxAngularVelocity = math.huge, math.huge
	alignPos.ReactionForceEnabled, alignOrt.ReactionTorqueEnabled = false, false
	alignPos.Responsiveness, alignOrt.Responsiveness = 200, 200
	alignPos.RigidityEnabled, alignOrt.RigidityEnabled = false, false
	alignPos.Attachment0, alignOrt.Attachment0 = _attachment, _attachment
	alignPos.Attachment1, alignOrt.Attachment1 = attachment, attachment
	alignPos.Parent, alignOrt.Parent = accHandle, accHandle
	attachment.Parent, _attachment.Parent = character.Head, accHandle
	partControllers[accessory] = {
		attachment = attachment,
		cframe = accHandle.CFrame,
		part = accHandle
	}
end
-- main
_G.Connections = _G.Connections or table.create(0)
local partHandles, partArcHandles = Instance.new("Handles"), Instance.new("ArcHandles")
partHandles.Parent, partArcHandles.Parent = coreGui, coreGui

task.defer(function()
	player.Character = nil
	player.Character = character
	task.wait(players.RespawnTime + .05)
	destroyFunc(character.HumanoidRootPart)

	for _, object in ipairs(character:GetChildren()) do
		if object:IsA("Accoutrement") then
			sethiddenproperty(object, "BackendAccoutrementState", 0)
			destroyFunc(object.Handle:FindFirstChildWhichIsA("Weld"))
			destroyFunc(object:FindFirstChildWhichIsA("MeshPart", true) or object:FindFirstChildWhichIsA("SpecialMesh", true))
			if object.CanCollide then initPartController(object) end
		elseif object:IsA("BasePart") and object.Name ~= "Head" then
			destroyFunc(object)
		end
	end
end)

_G.Connections[#_G.Connections + 1] = runService.Heartbeat:Connect(function()
	for _, object in ipairs(character:GetChildren()) do
		local accData = partControllers[object]
		accData.attachment.CFrame = accData.cframe
		accData.part.CanCollide, accData.part.Massless, accData.part.RootPriority = false, false, 127
		accData.part.Velocity, accData.part.RotVelocity = Vector3.yAxis * 30, Vector3.zero
		sethiddenproperty(accData.part, "NetworkIsSleeping", false)
		sethiddenproperty(accData.part, "NetworkOwnershipRule", Enum.NetworkOwnership.Manual)
	end
	partHandles.Visible = (partHandles.Adornee and controlMode == "move") and true or false
	partArcHandles.Visible = (partArcHandles.Adornee and controlMode == "rotate") and true or false
end)

_G.Connections[#_G.Connections + 1] = inputService.InputBegan:Connect(function(input)
	if not inputService:GetFocusedTextBox() then
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			local targetPart = mouse.Target
			controllingPart = (targetPart and targetPart:IsDescendantOf(character)) and targetPart or nil
		elseif input.UserInputType == Enum.UserInputType.Keyboard then
			
		end
	end
end)

resetBindableConnection = resetBindable.Event:Connect(function()
	starterGui:SetCore("ResetButtonCallback", true)
	resetBindableConnection:Disconnect()
	local daModel = Instance.new("Model")
	local _daModelHumanoid = Instance.new("Humanoid")
	_daModelHumanoid.Parent = daModel
	player.Character = daModel
end)
starterGui:SetCore("ResetButtonCallback", resetBindable)
