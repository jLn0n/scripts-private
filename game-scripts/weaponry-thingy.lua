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
		["AimPart"] = "Head",
		["Distance"] = 250,
		["VisibleCheck"] = false,
	},
	["Esp"] = {
		["Enabled"] = false,
		["Name"] = true,
		["Health"] = true,
		["Distance"] = true,
		["Tracers"] = true,
		["TeamCheck"] = true,
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
local frameworkUpvals, weaponryFramework do
	for _, plrScript in ipairs(player.PlayerScripts:GetChildren()) do
		local scriptRunning, scriptEnv = pcall(getsenv, plrScript)
		if (scriptRunning and scriptEnv) and (scriptEnv.InspectWeapon and scriptEnv.CheckIsToolValid) then
			frameworkUpvals, weaponryFramework = scriptEnv.CheckIsToolValid, plrScript
			break
		end
	end
end
local ui_library = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/zxciaz/VenyxUI/main/Reuploaded"))()
local espUtil = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/jLn0n/scripts/main/libraries/esp-util.lua"))()
local nearPlrs = table.create(0)
local plrEspList = table.create(0)
local espTextFormat = "Name: %s|Health: %s / %s|Distance: %s"
local espTextCount = 0
-- functions
local function checkPlr(plrArg)
	local plrHumanoid = plrArg.Character:FindFirstChild("Humanoid")
	return plrArg ~= player and (plrArg.Neutral and true or plrArg.TeamColor ~= player.TeamColor) and hitboxes:FindFirstChild(plrArg.UserId) and (plrArg.Character and (plrHumanoid and plrHumanoid.Health ~= 0) and not plrArg.Character:FindFirstChildWhichIsA("ForceField"))
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
local function getEnabledEspTextFormatResult() -- very long function name lol
	local result = ""
	for value in string.gmatch(espTextFormat, "[^|]+") do
		--value = string.gsub(value, "|", "\0")
		local _toggleName = string.split(value, ":")[1]
		local _enabled = config.Esp[_toggleName]
		espTextCount = _enabled and espTextCount + 1 or espTextCount
		result = result .. (_enabled and "\n" or "")
	end
	return result
end
local function getNearestPlrByCursor()
	table.clear(nearPlrs)
	for _, plr in ipairs(players:GetPlayers()) do
		local p_dPart = getAimPart(hitboxes:FindFirstChild(plr.UserId))
		if not p_dPart then continue end
		local posVec3, onScreen = camera:WorldToViewportPoint(p_dPart.Position)
		local mouseVec2, posVec2 = Vector2.new(mouse.X, mouse.Y), Vector2.new(posVec3.X, posVec3.Y)
		local distance = (mouseVec2 - posVec2).Magnitude
		if checkPlr(plr) and (config.SilentAim.VisibleCheck and (onScreen and inLineOfSite(p_dPart.Position, plr.Character)) or true) and distance <= config.SilentAim.Distance then
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
-- ui init
local mainWindow = ui_library.new("Weaponry Fucker")

local main_page = mainWindow:addPage("Main Page")
local misc_page = mainWindow:addPage("Misc")

local weaponMods_sect = main_page:addSection("Weapon Mods")
local aiming_sect = main_page:addSection("Aim Settings")
local esp_sect = main_page:addSection("ESP Settings")
local settings_sect = misc_page:addSection("Settings")
local credits_sect = misc_page:addSection("Credits")

weaponMods_sect:addToggle("Always Auto", config.AlwaysAuto, function(value)
	config.AlwaysAuto = value
end)
weaponMods_sect:addToggle("Infinite Ammo", config.InfAmmo, function(value)
	config.InfAmmo = value
end)
weaponMods_sect:addToggle("No Recoil", config.NoRecoil, function(value)
	config.NoRecoil = value
end)
weaponMods_sect:addToggle("No Spread", config.NoSpread, function(value)
	config.NoSpread = value
end)
weaponMods_sect:addToggle("Multiple Bullets", config.MultipleBullets.Enabled, function(value)
	config.MultipleBullets.Enabled = value
end)
weaponMods_sect:addSlider("Bullets Count", config.MultipleBullets.AmmoCount, 0, 50, function(value)
	config.MultipleBullets.AmmoCount = value
end)

aiming_sect:addToggle("Silent Aim", config.SilentAim.Enabled, function(value)
	config.SilentAim.Enabled = value
end)
aiming_sect:addDropdown("Aim Part", {
	"Head",
	"Body",
	"Legs",
	"Random"
}, function(value)
	config.SilentAim.AimPart = value
end)
aiming_sect:addToggle("Visibility Check", config.SilentAim.VisibleCheck, function(value)
	config.SilentAim.VisibleCheck = value
end)
aiming_sect:addSlider("Distance", config.SilentAim.Distance, 0, 500, function(value)
	config.SilentAim.Distance = value
end)

esp_sect:addToggle("Enable", config.Esp.Enabled, function(value)
	config.Esp.Enabled = value
end)
esp_sect:addToggle("Tracers", config.Esp.Tracers, function(value)
	config.Esp.Tracers = value
end)
esp_sect:addToggle("Name", config.Esp.Name, function(value)
	config.Esp.Name = value
end)
esp_sect:addToggle("Health", config.Esp.Health, function(value)
	config.Esp.Health = value
end)
esp_sect:addToggle("Distance", config.Esp.Distance, function(value)
	config.Esp.Distance = value
end)
esp_sect:addToggle("Team Check", config.Esp.TeamCheck, function(value)
	config.Esp.TeamCheck = value
end)

settings_sect:addKeybind("UI Toggle", Enum.KeyCode.RightControl, function()
	mainWindow:toggle()
end)
credits_sect:addButton("Owlhub for OwlESP(but modified)")
credits_sect:addButton("GreenDeno for VenyxUI")
mainWindow:SelectPage(mainWindow.pages[1], true)
-- main
runService.Heartbeat:Connect(function()
	local weaponsData = debug.getupvalue(frameworkUpvals, 1)
	for _, weaponData in pairs(weaponsData) do
		if weaponData.FriendlyName == "Knife" then continue end
		if config.InfAmmo then weaponData.CurrentAmmo = weaponData.WeaponStats.MaxAmmo end -- infinite ammo
		if config.NoSpread then weaponData.CurrentAccuracy = 0 end -- no spread
		if config.AlwaysAuto then weaponData.WeaponStats.FireMode.Name = "Auto" end -- always auto
		weaponData.WeaponStats.FireMode.Round = config.MultipleBullets.Enabled and config.MultipleBullets.AmmoCount or 1 -- multiple bullets
	end
end)
runService.RenderStepped:Connect(function()
	local textFormat = getEnabledEspTextFormatResult()
	for _, plr in ipairs(players:GetPlayers()) do
		if plr == player then continue end
		if not plrEspList[plr.Name] then
			plrEspList[plr.Name] = espUtil.new(plr, {
				color = Color3.new(255, 255, 255),
				teamCheck = config.Esp.TeamCheck,
				visibility = {
					box = config.Esp.Enabled,
					tracer = config.Esp.Enabled and config.Esp.Tracers,
					text = config.Esp.Enabled
				}
			})
		end
	end
	for plrName, espData in pairs(plrEspList) do
		local plrObj = players:FindFirstChild(plrName)
		if plrObj then
			local plrChar = plrObj.Character
			local humanoid, rootPart = plrChar and plrChar:FindFirstChildWhichIsA("Humanoid"), plrChar and plrChar:FindFirstChild("HumanoidRootPart")
			espData:updateConfig({
				character = plrChar,
				color = Color3.new(255, 255, 255),
				text = string.format(textFormat,
					plrObj.Name,
					humanoid and humanoid.Health or "NaN",
					humanoid and humanoid.MaxHealth or "NaN",
					rootPart and math.floor(player:DistanceFromCharacter(rootPart.Position)) or "NaN"
				),
				textOffset = 16 * (espTextCount == 0 and 1 or espTextCount),
				teamCheck = config.Esp.TeamCheck,
				visibility = {
					box = config.Esp.Enabled,
					tracer = config.Esp.Enabled and config.Esp.Tracers,
					text = config.Esp.Enabled and config.Esp.Name
				}
			})
			espData:updateRender()
			espTextCount = 0
		else
			espData:remove()
			plrEspList[plrName] = nil
		end
	end
end)
local oldRecoilFunc = recoilHandler.accelerate
local oldNamecall do
	oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(...)
		local namecallMethod, callingScript = getnamecallmethod(), getcallingscript()
		if not checkcaller() and (config.SilentAim.Enabled and namecallMethod == "Raycast" and callingScript == weaponryFramework) then
			local nearestPlr = getNearestPlrByCursor()
			if nearestPlr then
				local args = {...}
				args[3] = getRayDirection(args[2], nearestPlr.aimPart.Position)
				return oldNamecall(unpack(args))
			end
		end
		return oldNamecall(...)
	end))
end
recoilHandler.accelerate = function(...)
	return not config.NoRecoil and oldRecoilFunc(...) or nil -- no recoil
end
