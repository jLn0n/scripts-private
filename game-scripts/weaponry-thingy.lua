-- services
local guiService = game:GetService("GuiService")
local players = game:GetService("Players")
local runService = game:GetService("RunService")
local repStorage = game:GetService("ReplicatedStorage")
-- objects
local camera = workspace.CurrentCamera
local player = players.LocalPlayer
local mouse = player:GetMouse()
-- modules
local clientFwUpvals
local rayCastClient, recoilHandler = require(repStorage.ClientModules.RayCastClient), require(repStorage.ClientModules.RecoilCamHandler)
-- functions
local function getClientFramework()
	for _, plrscript in ipairs(player.PlayerScripts:GetChildren()) do
		local scriptRunning, scriptEnv = pcall(getsenv, plrscript)
		if (scriptRunning and scriptEnv) and scriptEnv.InspectWeapon then
			return plrscript
		end
	end
end
local function getNearestPlrByCursor()
	local nearPlrs = table.create(0)
	for _, plr in ipairs(players:GetPlayers()) do
		if plr == player and plr.TeamColor == player.TeamColor and not (plr.Character and plr.Character:FindFirstChild("Head")) then continue end
		local p_char = plr.Character
		if p_char then
			local p_head = p_char:FindFirstChild("Head")
			local posVec3, isVisible = camera:WorldToScreenPoint(p_head.Position)
			if isVisible then
				local mouseVec2, p_Vec2 = Vector2.new(mouse.X, mouse.Y), Vector2.new(posVec3.X, posVec3.Y)
				local distance = (mouseVec2 - p_Vec2).Magnitude
				if distance < math.huge then
					table.insert(nearPlrs, {
						plr = plr,
						dist = distance
					})
				end
			end
		end
	end
	table.sort(nearPlrs, function(x, y)
		return (x.dist < y.dist)
	end)
	return (nearPlrs and #nearPlrs ~= 0) and nearPlrs[1].plr or nil
end
-- main
clientFwUpvals = getsenv(getClientFramework()).CheckIsToolValid
runService.RenderStepped:Connect(function()
	pcall(function() -- inf ammo and no spread
		for weapon = 1, 2 do
			local weaponData = debug.getupvalue(clientFwUpvals, 1)[weapon]
			weaponData.CurrentAmmo = weaponData.WeaponStats.MaxAmmo
			weaponData.CurrentAccuracy = 0
		end
	end)
end)
local oldCastMouse = rayCastClient.CastRayMouse
rayCastClient.CastRayMouse = function(_camera, x, y) -- silent aim
	local nearestPlr = getNearestPlrByCursor()
	if nearestPlr then
		local p_char = nearestPlr.Character
		local p_head = p_char:FindFirstChild("Head")
		local newVec2 = camera:WorldToScreenPoint(p_head.Position)
		x, y = newVec2.X, newVec2.Y + guiService:GetGuiInset().Y
	end
	return oldCastMouse(_camera, x, y)
end
recoilHandler.accelerate = function()end -- no recoil
