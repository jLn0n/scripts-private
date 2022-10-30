-- config
shared.fov = 175 -- mouse fov
shared.distance = 12.5 -- plrchar distance to targetchar
shared.visibleCheck = true
-- services
local inputService = game:GetService("UserInputService")
local players = game:GetService("Players")
local runService = game:GetService("RunService")
-- objects
local camera = workspace.CurrentCamera
local player = players.LocalPlayer
local plrChar = player.Character
local sword
-- functions
local function checkPlr(plrArg)
	local plrChar = plrArg.Character
	local plrHumanoid, plrTPart = (plrChar and plrChar:FindFirstChild("Humanoid")), (plrChar and plrChar:FindFirstChild("Head"))
	return plrArg ~= player and (plrChar and (plrHumanoid and plrHumanoid.Health ~= 0)), plrTPart
end
local function inLineOfSite(originPos, ...)
	return #camera:GetPartsObscuringTarget({originPos}, {camera, player.Character, ...}) == 0
end
local function getNearestPlrByCursor()
	local nearestPlrData = {aimPart = nil, dist = math.huge}

	for _, plr in players:GetPlayers() do
		local passed, plrTPart = checkPlr(plr)
		if not (passed and plrTPart) then continue end
		local posVec3, onScreen = camera:WorldToViewportPoint(plrTPart.Position)
		local fovDist = (inputService:GetMouseLocation() - Vector2.new(posVec3.X, posVec3.Y)).Magnitude
		local charDist = if (plr.Character and plr.Character.PrimaryPart) then (plrChar.PrimaryPart.Position - plr.Character.PrimaryPart.Position).Magnitude else nil

		if checkPlr(plr) and (not shared.visibleCheck or (onScreen and inLineOfSite(plrTPart.Position, plr.Character))) then
			if ((fovDist <= shared.fov) and (fovDist < nearestPlrData.dist)) and (charDist and charDist <= shared.distance) then
				nearestPlrData.aimPart = plrTPart
				nearestPlrData.dist = fovDist
			end
		end
	end
	return (if nearestPlrData.aimPart then nearestPlrData else nil)
end
-- main
runService.Heartbeat:Connect(function()
	plrChar = player.Character
	sword = (if plrChar then plrChar:FindFirstChildWhichIsA("Tool") else nil)
	if not (plrChar and sword) then return end
	local nearestPlr = getNearestPlrByCursor()

	if nearestPlr then
		sword.Handle.Position = nearestPlr.aimPart.Position
	end
end)
