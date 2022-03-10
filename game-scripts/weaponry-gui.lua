-- config
local config = {
	["WeaponMods"] = {
		["AlwaysAuto"] = false,
		["InfAmmo"] = false,
		["NoRecoil"] = false,
		["NoSpread"] = false,
		["MultipliedBullets"] = 1
	},
	["SilentAim"] = {
		["Toggle"] = false,
		["AimPart"] = "Head",
		["Distance"] = 250,
		["VisibleCheck"] = false,
	},
	["Esp"] = {
		["Toggle"] = false,
		["Names"] = true,
		["Boxes"] = true,
		["Tracers"] = true,
		["TeamCheck"] = true,
		["Colors"] = {
			["Team"] = Color3.new(0, 255, 0),
			["Enemy"] = Color3.new(255, 0, 0),
		}
	}
}
-- services
local players = game:GetService("Players")
local runService = game:GetService("RunService")
local repStorage = game:GetService("ReplicatedStorage")
-- objects
local camera = workspace.CurrentCamera
local hitboxes = workspace.Hitboxes
local player = players.LocalPlayer
local mouse = player:GetMouse()
-- modules
local rayCastClient, recoilHandler = require(repStorage.ClientModules.RayCastClient), require(repStorage.ClientModules.CamRecoilHandler)
-- variables
local frameworkUpvals do
	for _, plrScript in ipairs(player.PlayerScripts:GetChildren()) do
		local scriptRunning, scriptEnv = pcall(getsenv, plrScript)
		if (scriptRunning and scriptEnv) and (scriptEnv.InspectWeapon and scriptEnv.CheckIsToolValid) then
			frameworkUpvals = scriptEnv.CheckIsToolValid
			break
		end
	end
end
local uiLibrary = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/jLn0n/scripts/main/libraries/linoria-lib-ui.lua"))()
local espLibrary = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/jLn0n/scripts/main/libraries/kiriot22-esp-library.lua"))()
local nearPlrs = table.create(0)
-- functions
local function checkPlr(plrArg)
	local plrHumanoid = plrArg.Character:FindFirstChild("Humanoid")
	return plrArg ~= player and (plrArg.Neutral or plrArg.TeamColor ~= player.TeamColor) and hitboxes:FindFirstChild(plrArg.UserId) and (plrArg.Character and (plrHumanoid and plrHumanoid.Health ~= 0) and not plrArg.Character:FindFirstChildWhichIsA("ForceField"))
end
local function inLineOfSite(originPos, ...)
	return #camera:GetPartsObscuringTarget({originPos}, {camera, player.Character, hitboxes, ...}) == 0
end
local function getAimPart(hitboxFolder)
	if not hitboxFolder then return nil end
	if config.SilentAim.AimPart == "Random" then return hitboxFolder:GetChildren()[math.random(1, 3)] end
	for _, hitbox in ipairs(hitboxFolder:GetChildren()) do
		if string.match(hitbox.Name, config.SilentAim.AimPart) then
			return hitbox
		end
	end
end
local function getNearestPlrByCursor()
	table.clear(nearPlrs)
	for _, plr in ipairs(players:GetPlayers()) do
		local p_dPart = getAimPart(hitboxes:FindFirstChild(plr.UserId))
		if not p_dPart then continue end
		local posVec3, onScreen = camera:WorldToViewportPoint(p_dPart.Position)
		local mouseVec2, posVec2 = Vector2.new(mouse.X, mouse.Y), Vector2.new(posVec3.X, posVec3.Y)
		local distance = (mouseVec2 - posVec2).Magnitude
		if checkPlr(plr) and (config.SilentAim.VisibleCheck and (onScreen and inLineOfSite(p_dPart.Position, plr.Character))) and distance <= config.SilentAim.Distance then
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
local function getRayDirection(originPos, posVec3)
	return (posVec3 - originPos).Unit * 1000
end
local function mergeTable(table1, table2)
	for key, value in pairs(table2) do
		if typeof(value) == "table" and typeof(table1[key] or false) == "table" then
			mergeTable(table1[key], value)
		else
			table1[key] = value
		end
	end
	return table1
end
local function initValueUpdater(objName, func)
	local objThingy = uiLibrary.Toggles[objName] or uiLibrary.Options[objName]
	local tableParent, tableName do
		local configPaths = string.split(objName, ".")
		local currentTable = config
		tableName = configPaths[#configPaths]
		for index = 1, #configPaths do
			currentTable = currentTable[configPaths[index]]
			if index == #configPaths - 1 then
				tableParent = currentTable
				break
			end
		end
	end
	objThingy:SetValue(tableParent[tableName])
	objThingy:OnChanged(function()
		tableParent[tableName] = objThingy.Value
		if func then return func(tableParent[tableName]) end
	end)
end
-- ui init
local mainWindow = uiLibrary:CreateWindow("weaponry-gui.lua")
local mainTab = mainWindow:AddTab("Main")

local tabbox1 = mainTab:AddLeftTabbox("sAimTabbox")
local tabbox2 = mainTab:AddLeftTabbox("weaponModsTabbox")
local tabbox3 = mainTab:AddRightTabbox("espTabbox")
local tabbox4 = mainTab:AddRightTabbox("creditsTabbox")

local silentAimTab = tabbox1:AddTab("Silent Aim")
local weaponModsTab = tabbox2:AddTab("Weapon Mods")
local espTab = tabbox3:AddTab("ESP Settings")
local creditsTab = tabbox4:AddTab("Credits")

silentAimTab:AddToggle("SilentAim.Toggle", {Text = "Toggle"})
silentAimTab:AddToggle("SilentAim.VisibleCheck", {Text = "Visibility Check"})
silentAimTab:AddDropdown("SilentAim.AimPart", {Text = "Aim Part", Values = {"Head", "Body", "Legs", "Random"}})
silentAimTab:AddSlider("SilentAim.Distance", {Text = "Distance", Default = 1, Min = 1, Max = 1000, Rounding = 0})

weaponModsTab:AddToggle("WeaponMods.AlwaysAuto", {Text = "Always Auto"})
weaponModsTab:AddToggle("WeaponMods.InfAmmo", {Text = "Infinite Ammo"})
weaponModsTab:AddToggle("WeaponMods.NoRecoil", {Text = "No Recoil"})
weaponModsTab:AddToggle("WeaponMods.NoSpread", {Text = "No Spread"})
weaponModsTab:AddSlider("WeaponMods.MultipliedBullets", {Text = "Multiplied Bullets", Default = 0, Min = 0, Max = 50, Rounding = 0})

espTab:AddToggle("Esp.Toggle", {Text = "Toggle"})
espTab:AddToggle("Esp.Boxes", {Text = "Boxes"})
espTab:AddToggle("Esp.Names", {Text = "Names"})
espTab:AddToggle("Esp.Tracers", {Text = "Tracers"})
espTab:AddToggle("Esp.TeamCheck", {Text = "Team Check"})
espTab:AddLabel("Team Color"):AddColorPicker("Esp.Colors.Team", {Default = Color3.new()})
espTab:AddLabel("Enemy Color"):AddColorPicker("Esp.Colors.Enemy", {Default = Color3.new()})

creditsTab:AddLabel("Linoria Hub for Linoria UI Library")
creditsTab:AddLabel("Kiriot22 for the ESP Library")

for objThingyName in pairs(mergeTable(uiLibrary.Toggles, uiLibrary.Options)) do
	initValueUpdater(objThingyName, (objThingyName == "Esp.Toggle" and function(value)
		espLibrary:Toggle(value)
	end or nil))
end
-- esp init
espLibrary.TeamColor = false
espLibrary.Overrides.GetColor = function(_character)
	local _plr = game:GetService("Players"):GetPlayerFromCharacter(_character)
	if _plr then
		return (_plr.Neutral or player.TeamColor ~= _plr.TeamColor) and config.Esp.Colors.Enemy or config.Esp.Colors.Team
	end
end
-- main
runService.Heartbeat:Connect(function()
	local weaponsData = debug.getupvalue(frameworkUpvals, 1)
	for _, weaponData in pairs(weaponsData) do
		if weaponData.FriendlyName == "Knife" then continue end
		if config.WeaponMods.InfAmmo then weaponData.CurrentAmmo = weaponData.WeaponStats.MaxAmmo end -- infinite ammo
		if config.WeaponMods.NoSpread then weaponData.CurrentAccuracy = 0 end -- no spread
		if config.WeaponMods.AlwaysAuto then weaponData.WeaponStats.FireMode.Name = "Auto" end -- always auto
		weaponData.WeaponStats.FireMode.Round = config.WeaponMods.MultipliedBullets > 0 and config.WeaponMods.MultipliedBullets or 1 -- multiple bullets
	end
	espLibrary.Boxes, espLibrary.Names, espLibrary.TeamMates = config.Esp.Boxes, config.Esp.Names, config.Esp.TeamCheck
end)
local oldRaycastFunc, oldRecoilFunc = rayCastClient.RayCast, recoilHandler.accelerate
rayCastClient.RayCast = function(rayObj)
	if config.SilentAim.Toggle then -- silent aim
		local nearestPlr = getNearestPlrByCursor()
		rayObj = not nearestPlr and rayObj or Ray.new(rayObj.Origin, getRayDirection(rayObj.Origin, nearestPlr.aimPart.Position))
	end
	return oldRaycastFunc(rayObj)
end
recoilHandler.accelerate = function(...)
	return not config.WeaponMods.NoRecoil and oldRecoilFunc(...) or nil -- no recoil
end
