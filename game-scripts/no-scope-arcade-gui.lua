-- config
local config = {
	["WeaponMods"] = {
		["AlwaysHit"] = false,
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
		["EnemyColor"] = Color3.new(255, 0, 0),
	}
}
-- services
local players = game:GetService("Players")
local runService = game:GetService("RunService")
local repStorage = game:GetService("ReplicatedStorage")
-- objects
local camera = workspace.CurrentCamera
local player = players.LocalPlayer
local mouse = player:GetMouse()
local character = player.Character or player.CharacterAdded:Wait()
-- modules
local clientRayCast = require(repStorage.GunSystem.Raycast)
-- variables
local uiLibrary = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/jLn0n/scripts/main/libraries/linoria-lib-ui.lua"))()
local espLibrary = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/jLn0n/scripts/main/libraries/kiriot22-esp-library.lua"))()
local nearPlrs, plrPartsList = table.create(0), (function()
	local plrParts = table.create(0)
	for _, object in ipairs(character:GetChildren()) do
		if object:IsA("BasePart") and character.PrimaryPart ~= object then
			table.insert(plrParts, object.Name)
		end
	end
	return plrParts
end)()
-- functions
local function checkPlr(plrArg)
	local plrHumanoid = plrArg.Character:FindFirstChild("Humanoid")
	return plrArg ~= player and (plrArg.Neutral or plrArg.TeamColor ~= player.TeamColor) and (plrArg.Character and (plrHumanoid and plrHumanoid.Health ~= 0) and not plrArg.Character:FindFirstChildWhichIsA("ForceField"))
end
local function inLineOfSite(originPos, ...)
	return #camera:GetPartsObscuringTarget({originPos}, {camera, player.Character, ...}) == 0
end
local function getAimPart(plrChar)
	if not plrChar then return end
	return plrChar:FindFirstChild((config.SilentAim.AimPart == "Random" and plrPartsList[math.random(1, #plrPartsList)] or config.SilentAim.AimPart))
end
local function getNearestPlrByCursor()
	table.clear(nearPlrs)
	for _, plr in ipairs(players:GetPlayers()) do
		local p_dPart = getAimPart(plr.Character)
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
local function hookRayResult(rayResult, hookingProperties)
	if not (rayResult and hookingProperties) then return end
	local metatable = getrawmetatable(rayResult)
	local oldIndex = metatable.__index
	setreadonly(metatable, false)

	metatable.__index = newcclosure(function(self, index)
		return hookingProperties[index] or oldIndex(self, index)
	end)
	setreadonly(metatable, true)
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
	objThingy:SetValue(tableParent[tableName]);
	objThingy:OnChanged(function()
		tableParent[tableName] = objThingy.Value
		if func then return func(tableParent[tableName]) end
	end)
end
-- ui init
local mainWindow = uiLibrary:CreateWindow("no-scope-arcade-gui.lua | Made by: jLn0n")
local mainTab = mainWindow:AddTab("Main")

local tabbox1 = mainTab:AddLeftTabbox("sAimTabbox")
local tabbox2 = mainTab:AddLeftTabbox("weaponModsTabbox")
local tabbox3 = mainTab:AddRightTabbox("espTabbox")
local tabbox4 = mainTab:AddRightTabbox("creditsTabbox")

local silentAimTab = tabbox1:AddTab("Silent Aim")
local weaponModsTab = tabbox2:AddTab("Weapon Mods")
local espTab = tabbox3:AddTab("ESP Settings")
local creditsTab = tabbox4:AddTab("Credits")

weaponModsTab:AddToggle("WeaponMods.AlwaysHit", {Text = "Always Hit"})

silentAimTab:AddToggle("SilentAim.Toggle", {Text = "Toggle"})
silentAimTab:AddToggle("SilentAim.VisibleCheck", {Text = "Visibility Check"})
silentAimTab:AddDropdown("SilentAim.AimPart", {Text = "Aim Part", Values = (function()
	table.insert(plrPartsList, 1, "Random")
	task.defer(table.remove, plrPartsList, 1)
	return plrPartsList
end)()})
silentAimTab:AddSlider("SilentAim.Distance", {Text = "Distance", Default = 1, Min = 1, Max = 5000, Rounding = 0})

espTab:AddToggle("Esp.Toggle", {Text = "Toggle"})
espTab:AddToggle("Esp.Boxes", {Text = "Boxes"})
espTab:AddToggle("Esp.Names", {Text = "Names"})
espTab:AddToggle("Esp.Tracers", {Text = "Tracers"})
espTab:AddLabel("Enemy Color"):AddColorPicker("Esp.EnemyColor", {Default = Color3.new()})

creditsTab:AddLabel("Linoria Hub for Linoria UI Library")
creditsTab:AddLabel("Kiriot22 for the ESP Library")
for objThingyName in pairs(mergeTable(uiLibrary.Toggles, uiLibrary.Options)) do
	initValueUpdater(objThingyName, (objThingyName == "Esp.Toggle" and function(value)
		espLibrary:Toggle(value)
	end or nil))
end
-- esp init
espLibrary.TeamColor = false
espLibrary.Overrides.GetColor = function()
	return config.Esp.EnemyColor
end
-- main
runService.Heartbeat:Connect(function()
	espLibrary.Boxes, espLibrary.Names = config.Esp.Boxes, config.Esp.Names
end)
local oldRaycastFunc = clientRayCast.Raycast
clientRayCast.Raycast = function(rayParams, rayOrigin, rayDirection)
	local nearestPlr, rayResult = getNearestPlrByCursor()
	if nearestPlr then
		local plrAimPart = nearestPlr.aimPart
		rayResult = oldRaycastFunc(rayParams, rayOrigin, config.SilentAim.Toggle and ((plrAimPart.Position - rayOrigin).Unit * 1000) or rayDirection)
		if config.WeaponMods.AlwaysHit then
			hookRayResult(rayResult, {
				Instance = plrAimPart,
				Material = plrAimPart,
				Position = plrAimPart.Position
			})
		end
	end
	return rayResult or oldRaycastFunc(rayParams, rayOrigin, rayDirection)
end
task.defer(uiLibrary.Notify, uiLibrary, "no-scope-arcade-gui.lua is now loaded!", 2.5)
