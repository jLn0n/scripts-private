-- https://www.roblox.com/games/6604417568
-- services
local inputService = game:GetService("UserInputService")
local players = game:GetService("Players")
local repStorage = game:GetService("ReplicatedStorage")
local runService = game:GetService("RunService")
-- objects
local player = players.LocalPlayer
local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
-- remotes
local attack = repStorage.GameRemotes:FindFirstChild("Attack")
local neckCFrame = repStorage.VisualRemotes:FindFirstChild("ChangeNeckWeld")
-- variables
local killAuraEnabled = false
local currentTargetRootPart
local vect3XZ = Vector3.new(1, 0, 1)
-- functions
local function checkPlr(plrArg)
	local plrHrp, plrHumanoid = plrArg.Character and plrArg.Character:FindFirstChild("HumanoidRootPart") or nil, plrArg.Character and plrArg.Character:FindFirstChildWhichIsA("Humanoid") or nil
	return plrArg ~= player and (plrArg.Character and plrHrp and (plrHumanoid and plrHumanoid.Health ~= 0) and not plrArg.Character:FindFirstChildWhichIsA("ForceField"))
end
-- main
player.CameraMaxZoomDistance = 120
inputService.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Keyboard and not inputService:GetFocusedTextBox() then
		if input.KeyCode == Enum.KeyCode.KeypadZero then
			killAuraEnabled = not killAuraEnabled
		end
	end
end)
runService.Heartbeat:Connect(function()
	if currentTargetRootPart and not currentTargetRootPart:IsDescendantOf(nil) then
		neckCFrame:FireServer(CFrame.lookAt(Vector3.yAxis * currentTargetRootPart.Position.Y, rootPart.Position))
		rootPart.CFrame = (CFrame.new(rootPart.Position) * CFrame.lookAt(currentTargetRootPart.Position * vect3XZ, rootPart.Position))
	end
end)
while true do task.wait()
	if killAuraEnabled then
		for _, plr in ipairs(players:GetPlayers()) do
			if not (checkPlr(plr) and player.Character) then continue end
			local plrChar = plr.Character
			local plrHrp = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") or nil

			if plrChar and plrHrp and player:DistanceFromCharacter(plrHrp.Position) < 12.5 then
				currentTargetRootPart = plrHrp
				coroutine.wrap(attack.InvokeServer)(attack, plrChar)
			end
		end
		task.wait(.15)
	end
end
