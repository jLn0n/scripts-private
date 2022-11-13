-- config
local config = {
	fov = 175,
	visibleCheck = true,
}
-- services
local inputService = game:GetService("UserInputService")
local players = game:GetService("Players")
local runService = game:GetService("RunService")
local repStorage = game:GetService("ReplicatedStorage")
-- objects
local camera = workspace.CurrentCamera
local player = players.LocalPlayer
local character = player.Character
local fovCircle, targetBox = Drawing.new("Circle"), Drawing.new("Square")
-- imports
local clientResources = require(repStorage:FindFirstChild("ClientResources"))
-- variables
local nearestPlr
local refs = table.create(0)
-- functions
local function checkPlr(plrArg)
	local plrChar = plrArg.Character
	local plrHumanoid, plrTPart = (plrChar and plrChar:FindFirstChild("Humanoid")), (plrChar and plrChar:FindFirstChild("HumanoidRootPart"))
	return plrArg ~= player and (plrChar and (plrHumanoid and plrHumanoid.Health ~= 0)) and (plrArg.Neutral or (plrArg.TeamColor ~= player.TeamColor)), plrTPart
end
local function inLineOfSite(originPos, ...)
	return #camera.GetPartsObscuringTarget(camera, {originPos}, {camera, player.Character, ...}) == 0
end
local function getNearestPlrByCursor()
	local nearestPlrData = {aimPart = nil, fovDist = math.huge, charDist = math.huge}

	for _, plr in players:GetPlayers() do
		local passed, plrTPart = checkPlr(plr)
		if not (passed and plrTPart) then continue end
		local posVec3, onScreen = camera:WorldToViewportPoint(plrTPart.Position)
		local fovDist = (inputService:GetMouseLocation() - Vector2.new(posVec3.X, posVec3.Y)).Magnitude
		local charDist = (if (character and character:FindFirstChild("HumanoidRootPart")) then (character.HumanoidRootPart.Position - plrTPart.Position).Magnitude else nil)

		if checkPlr(plr) and (not config.visibleCheck or (onScreen and inLineOfSite(plrTPart.Position, plr.Character))) then
			if ((fovDist <= config.fov) and (fovDist < nearestPlrData.fovDist)) and (charDist <= nearestPlrData.charDist) then
				nearestPlrData.aimPart = plrTPart
				nearestPlrData.fovDist = fovDist
			end
		end
	end
	return (nearestPlrData.aimPart and nearestPlrData or nil)
end
-- main
targetBox.Color = Color3.fromRGB(0, 185, 35)
targetBox.Filled = true
targetBox.Size = Vector2.new(20, 20)
targetBox.Thickness = 20
targetBox.Transparency = .6

fovCircle.Color = Color3.fromRGB(0, 185, 35)
fovCircle.Thickness = 2
fovCircle.Transparency = .6
fovCircle.Visible = true

runService.Heartbeat:Connect(function(deltaTime)
	nearestPlr = getNearestPlrByCursor()

	fovCircle.Radius = config.fov
	fovCircle.Position = inputService:GetMouseLocation()

	if nearestPlr then
		local posVec3, onScreen = camera:WorldToViewportPoint(nearestPlr.aimPart.Position)

		targetBox.Visible = onScreen
		targetBox.Position = (Vector2.new(posVec3.X, posVec3.Y) - (targetBox.Size / 2))
	else
		targetBox.Visible = false
		targetBox.Position = Vector3.zero
	end
end)

refs.vect2ToVect3 = clientResources.vector2ToVector3
clientResources.vector2ToVector3 = function(vect2)
	return (if nearestPlr then nearestPlr.aimPart.Position else refs.vect2ToVect3(vect2))
end
