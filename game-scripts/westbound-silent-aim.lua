-- config
local config = {
	visCheck = false,
	distance = 250,
	noRecoil = true,
	teamCheck = false
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
local gunLocalModule = require(repStorage.GunScripts.GunLocalModule)
-- variables
local nearPlrs = table.create(0)
-- functions
local function checkPlr(plrArg)
	local plrHumanoid = (plrArg.Character and plrArg.Character:FindFirstChild("Humanoid"))
	return plrArg ~= player and (config.teamCheck and (plrArg.Neutral or plrArg.TeamColor ~= player.TeamColor) or true) and (plrArg.Character and (plrHumanoid and plrHumanoid.Health ~= 0) and not plrArg.Character:FindFirstChildWhichIsA("ForceField"))
end
local function inLineOfSite(originPos, ...)
	return #camera.GetPartsObscuringTarget(camera, {originPos}, {camera, player.Character, ...}) == 0
end
local function getNearestPlrByCursor()
	table.clear(nearPlrs)
	for _, plr in ipairs(players:GetPlayers()) do
		local p_dPart = (plr.Character and plr.Character:FindFirstChild("Head"))
		if plr == player or not (checkPlr(plr) and p_dPart) then continue end
		local posVec3, onScreen = camera:WorldToViewportPoint(p_dPart.Position)
		local mouseVec2, posVec2 = Vector2.new(mouse.X, mouse.Y), Vector2.new(posVec3.X, posVec3.Y)
		local distance = (mouseVec2 - posVec2).Magnitude
		if (not config.visCheck or (onScreen and inLineOfSite(p_dPart.Position, plr.Character))) and distance <= config.distance then
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
local oldShootBullet, oldShakeCam = gunLocalModule.shootBullet, gunLocalModule.shakeCam
gunLocalModule.shootBullet = function(weaponData, head, hitPos, bool)
	local nearestPlr = getNearestPlrByCursor()
	if nearestPlr then
		hitPos = nearestPlr.aimPart.Position
	end
	return oldShootBullet(weaponData, head, hitPos, bool)
end
gunLocalModule.shakeCam = function(weaponData)
	return (not config.noRecoil and oldShakeCam(weaponData) or nil)
end