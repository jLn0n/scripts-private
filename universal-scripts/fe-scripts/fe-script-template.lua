-- services
local inputService = game:GetService("UserInputService")
local players = game:GetService("Players")
local runService = game:GetService("RunService")
-- objects
local player = players.LocalPlayer
local character = player.Character
local humanoid = character:FindFirstChild("Humanoid")
local rootPart, torso = character:FindFirstChild("HumanoidRootPart"), character:FindFirstChild("Torso")
local capeObj = character:FindFirstChild("WDW_FoamFinger")
local swordObj = character:FindFirstChild("Back_AccAccessory")
-- variables
local states = {
	["animPlaying"] = "idle",
	["isAttacking"] = false,
	["mode"] = 1,
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
local function changeMotorCFrame(motorName, addCache, cframe)
	if not ((motorName and motorsList[motorName]) or cframe) then return end
	motorsList[motorName].Object.Transform = ((addCache and motorsList[motorName].Cache or CFrame.identity) * cframe)
end
local function weldToMotor6D(weldObj, blankCFrame)
	local motorObj = Instance.new("Motor6D")
	motorObj.Part0, motorObj.Part1 = weldObj.Part0, weldObj.Part1
	motorObj.C0, motorObj.C1 = (not blankCFrame and weldObj.C0 or CFrame.identity), (not blankCFrame and weldObj.C1 or CFrame.identity)
	motorObj.Parent = weldObj.Parent
	weldObj:Destroy()
	return motorObj
end
-- main
humanoid.Animator:Destroy()
character.Animate.Disabled = true

motorsList = {
	["Neck"] = createMotorObj(torso:FindFirstChild("Neck")),
	["LShoulder"] = createMotorObj(torso:FindFirstChild("Left Shoulder")),
	["RShoulder"] = createMotorObj(torso:FindFirstChild("Right Shoulder")),
	["LHip"] = createMotorObj(torso:FindFirstChild("Left Hip")),
	["RHip"] = createMotorObj(torso:FindFirstChild("Right Hip")),
	["RootJoint"] = createMotorObj(rootPart:FindFirstChild("RootJoint")),
	["Cape"] = createMotorObj(weldToMotor6D(capeObj.Handle:FindFirstChildWhichIsA("Weld"))),
	["Sword"] = createMotorObj(weldToMotor6D(swordObj.Handle:FindFirstChildWhichIsA("Weld")))
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
		motorObj.Object.Transform = motorObj.Object.Transform:Lerp(motorObj.CFrame, motorObj.Speed or .25)
	end

	local currentState = string.lower(humanoid:GetState().Name)
	if states.mode == 1 then
		if (currentState == "running" and humanoid.MoveDirection == Vector3.zero) then -- idle

		end
	end
end)
