-- settings
local aimPart = "head" -- [HRP, HEAD] (can be cAsE sENsItIvE)
local fireCount = 7 -- multiplies bullets
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
local function checkPlr(plr)
	return plr == player and (plr.TeamColor == player.TeamColor) and not (plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") and not plr.Character:FindFirstChildWhichIsA("ForceField"))
end
local function getNearestPlrByCursor()
	local nearPlrs = table.create(0)
	for _, plr in ipairs(players:GetPlayers()) do
		local p_char = plr.Character
		if not checkPlr(plr) and p_char then
			local p_dPart = p_char:FindFirstChild("HumanoidRootPart")
			local posVec3, _unused = camera:WorldToScreenPoint(p_dPart.Position)
			local mouseVec2, posVec2 = Vector2.new(mouse.X, mouse.Y), Vector2.new(posVec3.X, posVec3.Y)
			local distance = (mouseVec2 - posVec2).Magnitude
			table.insert(nearPlrs, {
				plr = plr,
				dist = distance
			})
		end
	end
	table.sort(nearPlrs, function(x, y)
		return (x.dist < y.dist)
	end)
	return (nearPlrs and #nearPlrs ~= 0) and nearPlrs[1].plr or nil
end
-- variables
local clientFwUpvals = getsenv(getClientFramework()).CheckIsToolValid
-- main
runService.RenderStepped:Connect(function()
	local weaponsData = debug.getupvalue(clientFwUpvals, 1)
	for _, weaponData in pairs(weaponsData) do
		if weaponData.FriendlyName ~= "Knife" then
			weaponData.CurrentAmmo = weaponData.WeaponStats.MaxAmmo -- infinite ammo
			weaponData.CurrentAccuracy = 0 -- no spread
			weaponData.WeaponStats.FireMode = {
				["Name"] = "Auto", -- always auto
				["Round"] = fireCount or 1 -- modifiable bullets
			}
		end
	end
end)
local oldCastMouse = rayCastClient.CastRayMouse
rayCastClient.CastRayMouse = function(_camera, x, y) -- silent aim
	local nearestPlr = getNearestPlrByCursor()
	if nearestPlr then
		aimPart = string.lower(aimPart)
		local p_char = nearestPlr.Character
		local p_targetPart = p_char:FindFirstChild(aimPart == "hrp" and "HumanoidRootPart" or aimPart == "head" and "Head" or nil)
		local newVec2 = camera:WorldToScreenPoint(p_targetPart.Position)
		x, y = newVec2.X, newVec2.Y + guiService:GetGuiInset().Y
	end
	return oldCastMouse(_camera, x, y)
end
recoilHandler.accelerate = function()end -- no recoil
