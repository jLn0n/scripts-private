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
local function checkPlr(plrArg)
	local plrHrp, plrHumanoid = plrArg.Character:FindFirstChild("HumanoidRootPart"), plrArg.Character:FindFirstChildWhichIsA("Humanoid")
	return plrArg ~= player and (plrArg.Team ~= player.Team) and (plrArg.Character and plrHrp and (plrHumanoid and plrHumanoid.Health ~= 0) and not plrArg.Character:FindFirstChildWhichIsA("ForceField"))
end
local function getNearestPlrByCursor()
	local nearPlrs = table.create(0)
	for _, plr in ipairs(players:GetPlayers()) do
		local p_char = plr.Character
		if checkPlr(plr) and p_char then
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
local ui_library = loadstring(game:GetObjects("rbxassetid://7657867786")[1].Source)()
-- config
local config = {
	["AlwaysAuto"] = false,
	["InfAmmo"] = false,
	["NoRecoil"] = false,
	["NoSpread"] = false,
	["MultipleBullets"] = {
		["Enabled"] = false,
		["AmmoCount"] = 1
	},
	["SilentAim"] = {
		["Enabled"] = false,
		["AimPart"] = "head"
	},
}
-- ui init
local mainUI = ui_library:CreateWindow({
	["Name"] = "Weaponry Fucker",
	["DefaultTheme"] = [[{"__Designer.Background.UseBackgroundImage":true,"__Designer.Colors.unhoveredOptionBottom":"232323","__Designer.Colors.otherElementText":"817F81","__Designer.Colors.elementText":"939193","__Designer.Colors.hoveredOptionBottom":"2D2D2D","__Designer.Colors.hoveredOptionTop":"414141","__Designer.Colors.section":"B0AFB0","__Designer.Colors.bottomGradient":"1D1D1D","__Designer.Background.ImageTransparency":100,"__Designer.Colors.innerBorder":"493F49","__Designer.Colors.outerBorder":"0F0F0F","__Designer.Colors.sectionBackground":"232222","__Designer.Settings.ShowHideKey":"Enum.KeyCode.RightShift","__Designer.Colors.unhoveredOptionTop":"323232","__Designer.Colors.selectedOption":"373737","__Designer.Colors.background":"282828","__Designer.Background.ImageAssetID":"rbxassetid://4427304036","__Designer.Files.WorkspaceFile":"Weaponry Fucker","__Designer.Colors.unselectedOption":"282828","__Designer.Colors.main":"rainbow","__Designer.Colors.elementBorder":"141414","__Designer.Background.ImageColor":"FFFFFF","__Designer.Colors.topGradient":"232323"}]],
	["Themeable"] = {
		["Credit"] = true,
		["Info"] = "Script made by jLn0n#1464"
	}
})

local mainTab = mainUI:CreateTab({
	["Name"] = "Main Tab"
})

local weaponMods = mainTab:CreateSection({
	["Name"] = "Weapon Mods"
})
weaponMods:AddToggle({
	["Name"] = "Always Auto",
	["Flag"] = "wMods_alwaysAuto",
	["Callback"] = function(boolToggle)
		config.AlwaysAuto = boolToggle
	end
})
weaponMods:AddToggle({
	["Name"] = "Infinite Ammo",
	["Flag"] = "wMods_infAmmo",
	["Callback"] = function(boolToggle)
		config.InfAmmo = boolToggle
	end
})
weaponMods:AddToggle({
	["Name"] = "No Recoil",
	["Flag"] = "wMods_noRecoil",
	["Callback"] = function(boolToggle)
		config.NoRecoil = boolToggle
	end
})
weaponMods:AddToggle({
	["Name"] = "No Spread",
	["Flag"] = "wMods_noSpread",
	["Callback"] = function(boolToggle)
		config.NoSpread = boolToggle
	end
})
weaponMods:AddToggle({
	["Name"] = "Multiple Bullets",
	["Flag"] = "wMods_mulBulletsToggle",
	["Callback"] = function(boolToggle)
		config.MultipleBullets.Enabled = boolToggle
	end
})
weaponMods:AddSlider({
	["Name"] = "Bullets Count",
	["Flag"] = "wMods_mulBulletsSlider",
	["Percision"] = 1,
	["Min"] = 1,
	["Max"] = 25,
	["Callback"] = function(value)
		config.MultipleBullets.AmmoCount = value
	end
})

local silentAim = mainTab:CreateSection({
	["Name"] = "Aim Settings"
})
silentAim:AddToggle({
	["Name"] = "Silent Aim",
	["Flag"] = "silentAimToggle",
	["Callback"] = function(boolToggle)
		config.SilentAim.Enabled = boolToggle
	end
})
silentAim:AddDropdown({
	["Name"] = "Aim Part",
	["Flag"] = "silentAimDropdown",
	["List"] = {
		"Head",
		"HumanoidRootPart"
	},
	["Filter"] = {[0] = true},
	["Value"] = "Head",
	["Callback"] = function(value)
		config.SilentAim.AimPart = value
	end
})
-- main
runService.RenderStepped:Connect(function()
	local weaponsData = debug.getupvalue(clientFwUpvals, 1)
	for _, weaponData in pairs(weaponsData) do
		if weaponData.FriendlyName ~= "Knife" then
			if config.InfAmmo then weaponData.CurrentAmmo = weaponData.WeaponStats.MaxAmmo end -- infinite ammo
			if config.NoSpread then weaponData.CurrentAccuracy = 0 end -- no spread
			if config.AlwaysAuto then weaponData.WeaponStats.FireMode.Name = "Auto" end -- always auto
			if config.MultipleBullets.Enabled then weaponData.WeaponStats.FireMode.Round = config.MultipleBullets.AmmoCount end -- multiple bullets
		end
	end
end)
local oldCastMouse, oldRecoilFunc = rayCastClient.CastRayMouse, recoilHandler.accelerate
rayCastClient.CastRayMouse = function(_camera, x, y)
	if config.SilentAim.Enabled then -- silent aim
		local nearestPlr = getNearestPlrByCursor()
		if nearestPlr and checkPlr(nearestPlr) then
			local p_char = nearestPlr.Character
			local p_targetPart = p_char:FindFirstChild(config.SilentAim.AimPart)
			local newVec2 = camera:WorldToScreenPoint(p_targetPart.Position)
			x, y = newVec2.X, newVec2.Y + guiService:GetGuiInset().Y
		end
	end
	return oldCastMouse(_camera, x, y)
end
recoilHandler.accelerate = function(...)
	return not config.NoRecoil and oldRecoilFunc(...) or nil -- no recoil
end
