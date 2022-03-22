-- services
local inputService = game:GetService("UserInputService")
local players = game:GetService("Players")
local runService = game:GetService("RunService")
-- objects
local player = players.LocalPlayer
local character = player.Character
local rootPart, torso = character:FindFirstChild("HumanoidRootPart"), character:FindFirstChild("Torso")
-- variables
local states = {
	["animPlaying"] = "idle",
}
local motorsList
-- functions
local function createMotorObj(motorObj)
	return {
		["Object"] = motorObj,
		["CFrame"] = motorObj.Transform,
		["Cache"] = motorObj.Transform
	}
end
local function changeMotorCFrame(motorName, cframe)
	if not (motorName and motorsList[motorName]) or cframe then return end
	motorsList[motorName].Object = motorsList.Cache * cframe
end
-- main
motorsList = {
	["Neck"] = createMotorObj(torso:FindFirstChild("Neck")),
	["LShoulder"] = createMotorObj(torso:FindFirstChild("Left Shoulder")),
	["RShoulder"] = createMotorObj(torso:FindFirstChild("Right Shoulder")),
	["LHip"] = createMotorObj(torso:FindFirstChild("Left Hip")),
	["RHip"] = createMotorObj(torso:FindFirstChild("Right Hip")),
	["RootJoint"] = createMotorObj(rootPart:FindFirstChild("RootJoint")),
}

_G.Connections[#_G.Connections + 1] = inputService.InputBegan:Connect(function(input, gameProcessed)
	if (not inputService:GetFocusedTextBox() and gameProcessed) then
		if input.UserInputType == Enum.UserInputType.Keyboard then
			
		elseif input.UserInputType == Enum.UserInputType.MouseButton1 then

		end
	end
end)

_G.Connections[#_G.Connections + 1] = runService.Heartbeat:Connect(function()
	for _, motorObj in pairs(motorsList) do
		motorObj.Object.Transform = motorObj.Object.Transform:Lerp(motorObj.CFrame, .25)
	end
end)
