-- settings
local settings = {
	fov = 175,
	noRecoil = true,
	teamCheck = false,
	visibleCheck = true,
}
-- services
local players = game:GetService("Players")
local repStorage = game:GetService("ReplicatedStorage")
local runService = game:GetService("RunService")
-- objects
local camera = workspace.CurrentCamera
local player = players.LocalPlayer
local mouse = player:GetMouse()
-- modules
local gunLocalModule, gunStats = require(repStorage.GunScripts.GunLocalModule), require(repStorage.GunScripts.GunStats)
-- functions
local function checkPlr(plrArg)
	local plrHumanoid = (plrArg.Character and plrArg.Character:FindFirstChild("Humanoid"))
	return plrArg ~= player and (settings.teamCheck and (plrArg.Neutral or plrArg.TeamColor ~= player.TeamColor) or true) and (plrArg.Character and (plrHumanoid and plrHumanoid.Health ~= 0) and not plrArg.Character:FindFirstChildWhichIsA("ForceField"))
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
for _gunName, gunStatData in gunStats do
	gunStatData.Spread = 0
	gunStatData.prepTime = .01
	gunStatData.equipTime = .01
	gunStatData.Damage = 100
	gunStatData.ReloadSpeed = .05
	gunStatData.BulletSpeed = 500
	gunStatData.HipFireAccuracy = 0
	gunStatData.ZoomAccuracy = 0
end
local oldShootBullet, oldShakeCam = gunLocalModule.shootBullet, gunLocalModule.shakeCam
gunLocalModule.shootBullet = function(weaponData, headObj, hitPos, isHeadshot)
	local nearestPlr = getNearestPlrByCursor()
	if nearestPlr then
		hitPos = nearestPlr.aimPart.Position
		isHeadshot = true
	end
	return oldShootBullet(weaponData, headObj, hitPos, isHeadshot)
end
gunLocalModule.shakeCam = function(weaponData)
	return (not settings.noRecoil and oldShakeCam(weaponData) or nil)
end
