-- settings
local settings = {
	fov = 175,
	noShakeCam = true,
	teamCheck = true,
	visibleCheck = true,
}
-- services
local inputService = game:GetService("UserInputService")
local players = game:GetService("Players")
local repStorage = game:GetService("ReplicatedStorage")
local runService = game:GetService("RunService")
-- objects
local camera = workspace.CurrentCamera
local player = players.LocalPlayer
local fovCircle, targetBox = Drawing.new("Circle"), Drawing.new("Square")
-- modules
local gunLocalModule, gunStats = require(repStorage.GunScripts.GunLocalModule), require(repStorage.GunScripts.GunStats)
-- variables
local nearestPlr
local refs = table.create(0)
-- functions
local function checkPlr(plrArg)
	local plrChar = plrArg.Character
	local plrHumanoid, plrTPart = (plrChar and plrChar:FindFirstChild("Humanoid")), (plrChar and plrChar:FindFirstChild("HumanoidRootPart"))
	return plrArg ~= player and (plrChar and (plrHumanoid and plrHumanoid.Health ~= 0)) and (if settings.teamCheck then (plrArg.Neutral or plrArg.TeamColor ~= player.TeamColor) else true), plrTPart
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

		if checkPlr(plr) and (not settings.visibleCheck or (onScreen and inLineOfSite(plrTPart.Position, plr.Character))) then
			if ((fovDist <= settings.fov) and (fovDist < nearestPlrData.dist)) then
				nearestPlrData.aimPart = plrTPart
				nearestPlrData.dist = fovDist
			end
		end
	end
	return (if nearestPlrData.aimPart then nearestPlrData else nil)
end
-- main
for _, gunStatData in gunStats do
	gunStatData.Spread = 0
	gunStatData.prepTime = .01
	gunStatData.equipTime = .01
	gunStatData.Damage = 100
	gunStatData.ReloadSpeed = .05
	gunStatData.BulletSpeed = 1000
	gunStatData.HipFireAccuracy = 0
	gunStatData.ZoomAccuracy = 0
end

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

	fovCircle.Radius = settings.fov
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

refs.shootBullet, refs.shakeCam = gunLocalModule.shootBullet, gunLocalModule.shakeCam
gunLocalModule.shootBullet = function(weaponData, headObj, hitPos, isHeadshot)
	if nearestPlr then
		hitPos = nearestPlr.aimPart.Position
		isHeadshot = true
	end
	return refs.shootBullet(weaponData, headObj, hitPos, isHeadshot)
end

gunLocalModule.shakeCam = function(weaponData)
	return (not settings.noShakeCam and refs.shakeCam(weaponData) or nil)
end
