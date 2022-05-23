-- services
local inputService = game:GetService("UserInputService")
local players = game:GetService("Players")
local repStorage = game:GetService("ReplicatedStorage")
-- objects
local camera = workspace.CurrentCamera
local player = players.LocalPlayer
local mouse = player:GetMouse()
local remoteEvent = repStorage:FindFirstChild("Event")
-- variables
local nearPlrs = table.create(0)
local settings = {
	visibleCheck = false,
	distance = 250,
	knockdownCheck = true
}
-- functions
local function checkPlr(plrArg)
	local plrHumanoid = plrArg.Character:FindFirstChild("Humanoid")
	return plrArg ~= player and (plrArg.Neutral or plrArg.TeamColor ~= player.TeamColor) and (plrArg.Character and (plrHumanoid and plrHumanoid.Health ~= 0) and not plrArg.Character:FindFirstChildWhichIsA("ForceField")) and not (settings.knockdownCheck and plrArg.Character:FindFirstChild("Downed") or false)
end
local function inLineOfSite(originPos, ...)
	return #camera:GetPartsObscuringTarget({originPos}, {camera, player.Character, ...}) == 0
end
local function getNearestPlrByCursor()
	table.clear(nearPlrs)
	for _, plr in ipairs(players:GetPlayers()) do
		local p_dPart = (plr.Character and plr.Character:FindFirstChild("Head"))
		if not p_dPart then continue end
		local posVec3, onScreen = camera:WorldToViewportPoint(p_dPart.Position)
		local mouseVec2, posVec2 = Vector2.new(mouse.X, mouse.Y), Vector2.new(posVec3.X, posVec3.Y)
		local distance = (mouseVec2 - posVec2).Magnitude
		if checkPlr(plr) and (not settings.visibleCheck or (onScreen and inLineOfSite(p_dPart.Position, plr.Character))) and distance <= settings.distance then
			table.insert(nearPlrs, {
				aimPart = p_dPart,
				dist = distance,
			})
		end
	end
	table.sort(nearPlrs, function(x, y)
		return (x.dist < y.dist)
	end)
	return (nearPlrs and #nearPlrs ~= 0) and nearPlrs[1] or nil
end
-- main
inputService.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 and (not inputService:GetFocusedTextBox()) then
		local nearestPlr = getNearestPlrByCursor()
		if nearestPlr then
			for _ = 1, 10 do
				remoteEvent:FireServer("VR", nearestPlr.aimPart)
			end
		end
	end
end)
