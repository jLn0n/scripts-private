-- config
local config = {
	["WeaponMods"] = {
		["AlwaysAuto"] = false,
		["NoEqDelay"] = false,
		["NoRecoil"] = false,
		["NoSpread"] = false,
		["NoReload"] = false,
		["GunFirerate"] = false,
		["KnifeFirerate"] = false,
		["GunFirerateValue"] = .15,
		["KnifeFirerateValue"] = .1,
	},
	["SilentAim"] = {
		["Toggle"] = false,
		["AlwaysHit"] = false,
		["VisibleCheck"] = true,
		["AimPart"] = "Head",
		["Distance"] = 250,
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
local logService = game:GetService("LogService")
local players = game:GetService("Players")
local runService = game:GetService("RunService")
local repStorage = game:GetService("ReplicatedStorage")
-- objects
local camera = workspace.CurrentCamera
local player = players.LocalPlayer
local mouse = player:GetMouse()
-- gVariables
local nearestPlr
local uiLibrary = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/jLn0n/scripts/main/libraries/linoria-lib-ui.lua"))()
local espLibrary = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/jLn0n/scripts/main/libraries/kiriot22-esp-library.lua"))()
local oldLogCache = logService:GetLogHistory()
local funcsList, nearPlrs, plrPartsList = table.create(0), table.create(0), (function()
	local plrParts = table.create(0)
	for _, object in ipairs(player.Character:GetChildren()) do
		if (player.Character.PrimaryPart == object and not object:IsA("BasePart")) then continue end
		table.insert(plrParts, object.Name)
	end
	return plrParts
end)()
-- functions
local function checkPlr(plrArg)
	local plrHumanoid = plrArg.Character:FindFirstChild("Humanoid")
	return plrArg ~= player and (plrArg.Neutral or plrArg.TeamColor ~= player.TeamColor) and (plrArg.Character and (plrHumanoid and plrHumanoid.Health ~= 0) and not plrArg.Character:FindFirstChildWhichIsA("ForceField"))
end
local function inLineOfSite(originPos, ...)
	return #camera.GetPartsObscuringTarget(camera, {originPos}, {camera, player.Character, ...}) == 0
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
		if checkPlr(plr) and (not config.SilentAim.VisibleCheck or (onScreen and inLineOfSite(p_dPart.Position, plr.Character))) and distance <= config.SilentAim.Distance then
			table.insert(nearPlrs, {
				aimPart = p_dPart,
				character = plr.Character,
				dist = distance,
			})
		end
	end
	table.sort(nearPlrs, function(x, y)
		return (x.dist < y.dist)
	end)
	return (nearPlrs and #nearPlrs ~= 0) and nearPlrs[1] or nil
end
local function shallowCopy(_table)
	local copy = table.create(0)
	for name, value in pairs(_table) do
		copy[name] = value
	end
	return copy
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
-- pre init
for _, connection in ipairs(getconnections(logService.MessageOut)) do
	connection:Disable()
end
local oldNamecall do
	oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
		local args = {...}
		local namecallMethod = getnamecallmethod()

		if not checkcaller() then
			if (self == logService and namecallMethod == "GetLogHistory") then
				return oldLogCache
			elseif (self == player and namecallMethod == "Kick") then
				return task.wait(9e9)
			end
		end
		return oldNamecall(self, unpack(args))
	end))
end
-- ui
local mainWindow = uiLibrary:CreateWindow("no-scope-gui.lua | Made by: jLn0n")
local mainTab = mainWindow:AddTab("Main")

local tabbox1 = mainTab:AddLeftTabbox("sAimTabbox")
local tabbox2 = mainTab:AddLeftTabbox("weaponModsTabbox")
local tabbox3 = mainTab:AddRightTabbox("espTabbox")
local tabbox4 = mainTab:AddRightTabbox("creditsTabbox")

local silentAimTab = tabbox1:AddTab("Silent Aim")
local weaponModsTab = tabbox2:AddTab("Weapon Mods")
local espTab = tabbox3:AddTab("ESP Settings")
local creditsTab = tabbox4:AddTab("Credits")
-- esp
espLibrary.TeamColor = false
-- main
if game.PlaceId == 6407649031 then -- No Scope Arcade
    funcsList.getColorFunc = function()
        return config.Esp.EnemyColor
    end
elseif game.PlaceId == 5081773298 then -- No Scope Sniping
    funcsList.getColorFunc = function(_character)
        local _plr = game:GetService("Players"):GetPlayerFromCharacter(_character)
        if _plr then
            return (_plr.Neutral or player.TeamColor ~= _plr.TeamColor) and config.Esp.Colors.Enemy or config.Esp.Colors.Team
        end
    end
end
-- post init
rawset(espLibrary.Overrides, "GetColor", funcsList.getColorFunc)
for objThingyName in pairs(mergeTable(uiLibrary.Toggles, uiLibrary.Options)) do
	initValueUpdater(objThingyName, (objThingyName == "Esp.Toggle" and function(value)
		espLibrary:Toggle(value)
	end or nil))
end
task.defer(uiLibrary.Notify, uiLibrary, "no-scope-arcade-gui.lua is now loaded!", 2.5)
