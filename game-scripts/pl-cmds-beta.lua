--[[
	pl-cmds.lua, v0.1.8
	:shrug:
	use fluxus if ur executor doesn't support if-then-else expression
--]]
-- services
local players = game:GetService("Players")
local repStorage = game:GetService("ReplicatedStorage")
local runService = game:GetService("RunService")
local starterGui = game:GetService("StarterGui")
-- objects
local player = players.LocalPlayer
local character = player.Character
local humanoid = character:FindFirstChildWhichIsA("Humanoid")
local rootPart = character:FindFirstChild("HumanoidRootPart")
-- events
local punch, shoot, reload, itemGive, teamChange, loadChar =
	repStorage:FindFirstChild("meleeEvent"),
	repStorage:FindFirstChild("ShootEvent"),
	repStorage:FindFirstChild("ReloadEvent"),
	workspace.Remote:FindFirstChild("ItemHandler"),
	workspace.Remote:FindFirstChild("TeamEvent"),
	workspace.Remote:FindFirstChild("loadchar")
-- variables
local config = {
	["killAura"] = {
		["enabled"] = false,
		["range"] = 25,
		["killMode"] = "punch",
	},
	["killConf"] = {
		["hrpTarget"] = nil,
		["killBlacklist"] = table.create(0),
	},
	["loopKill"] = {
		["enabled"] = false,
		["list"] = table.create(0),
	},
	["utils"] = {
		["autoCriminal"] = false,
		["autoSpawn"] = false,
		["invisibility"] = false
	},
	["prefix"] = ";",
	["walkSpeed"] = 16,
	["jumpPower"] = 50
}
local msgOutputs = {
	["commandsOutput"] = {
		["templateShow"] = "- %s: %s\n",
		["usageNotify"] = "\nusage: %s",
		["unknownCommand"] = "command '%s' cannot be found."
	},
	["invisible"] = {
		["enabled"] = "invisibility is now enabled, nobody can see u now but don't seat on any seats or you will be visible again from the seat.",
		["disabled"] = "invisibility is now disabled, anyone can see u now.",
		["notify"] = "you are now invisible to other players."
	},
	["kill"] = {
		["allPlrs"] = "killed all players.",
		["targetPlr"] = "killed %s."
	},
	["kill-bl"] = {
		["plrAdd"] = "added %s to whitelist, player wouldn't be killed anymore.",
		["plrRemove"] = "removed %s whitelist, player will be killed again.",
	},
	["loop-kill"] = {
		["plrAdd"] = "added %s to loop-kill list.",
		["plrRemove"] = "removed %s to loop-kill list.",
		["allPlrs"] = "%s all players to loop-kill list."
	},
	["prefix"] = {
		["notify"] = "current prefix is '%s'.",
		["change"] = "changed prefix to '%s'.",
	},
	["argumentError"] = "argument %s should be a %s.",
	["autoToggleNotify"] = "%s is now %s.",
	["changedNotify"] = "changed %s to %s.",
	["emptyNotify"] = "%s is empty.",
	["giveNotify"] = "you now have '%s'.",
	["gotoTpSuccess"] = "teleported to %s.",
	["listNotify"] = "%s list: \n%s",
	["playerNotFound"] = "cannot find player '%s'.",
	["teamColorChanged"] = "changed team color to %s. (can only be applied when auto reset is enabled.)",
	["loadedMsg"] = "%s loaded, prefix is '%s' enjoy!",
	["respawnNotify"] = "character respawned successfully.",
}
local colorMappings = {
	["black"] = BrickColor.new("Really black"),
	["blue"] = BrickColor.new("Navy blue"),
	["gray"] = BrickColor.new("Dark grey metallic"),
	["green"] = BrickColor.new("Forest green"),
	["red"] = BrickColor.new("Bright red"),
	["white"] = BrickColor.new("Institutional white"),
	["yellow"] = BrickColor.new("Fire Yellow"),
}
local cframePlaces = {
	["armory"] = CFrame.new(835, 99, 2270),
	["cafeteria"] = CFrame.new(877, 100, 2256),
	["crimbase"] = CFrame.new(-942, 94, 2055),
	["gatetower"] = CFrame.new(502, 126, 2306),
	["nexus"] = CFrame.new(888, 100, 2388),
	["policeroom"] = CFrame.new(789, 100, 2260),
	["tower"] = CFrame.new(822, 131, 2588),
	["yard"] = CFrame.new(791, 98, 2498),
}
local itemPickups = {
	["ak47"] = workspace.Prison_ITEMS.giver["AK-47"].ITEMPICKUP,
	["knife"] = workspace.Prison_ITEMS.single["Crude Knife"].ITEMPICKUP,
	["m4a1"] = workspace.Prison_ITEMS.giver.M4A1.ITEMPICKUP,
	["m9"] = workspace.Prison_ITEMS.giver.M9.ITEMPICKUP,
	["shotgun"] = workspace.Prison_ITEMS.giver["Remington 870"].ITEMPICKUP,
}
local isKilling, isInvis = false, false
local currentOrigRootPart = rootPart
local cmdAliases = table.create(0)
local currentTeamColor, commands, diedConnection, oldNamecall
-- functions
local function isSelfNeutral()
	local plrTeamName = player.TeamColor.Name
	return not (plrTeamName == "Bright blue" or plrTeamName == "Really red" or plrTeamName == "Bright orange")
end
local function autoCrim()
	if ((config.utils.autoCriminal and not config.utils.invisibility) and rootPart and not isKilling and player.TeamColor.Name ~= "Really red") then
		local spawnPart = workspace:FindFirstChild("Criminals Spawn"):FindFirstChildWhichIsA("SpawnLocation")
		local oldSpawnPos = spawnPart.CFrame
		spawnPart.CFrame = rootPart.CFrame
		firetouchinterest(spawnPart, rootPart, 0)
		firetouchinterest(spawnPart, rootPart, 1)
		spawnPart.CFrame = oldSpawnPos
	end
end
local function respawnSelf(bypassToggle, dontUseCustomTeamColor)
	if (bypassToggle or config.utils.autoSpawn) and rootPart then
		local oldPos = rootPart.CFrame
		loadChar:InvokeServer(player, (config.utils.autoCriminal and "Really red" or ((not dontUseCustomTeamColor and currentTeamColor) and currentTeamColor.Name or player.TeamColor.Name)))
		rootPart.CFrame = oldPos
	end
end
local function toggleInvisSelf(bypassToggle) -- TODO: make this work
	if (bypassToggle or config.utils.invisibility) and (character and rootPart) then
		if isInvis then
			character.Parent = nil
			currentOrigRootPart.CFrame = rootPart.CFrame
			rootPart:Destroy()
			rootPart = currentOrigRootPart
			rootPart.Name = "HumanoidRootPart"
			rootPart.Anchored = false
		else
			local cloneRootPart, oldPos = rootPart:Clone(), character:GetPivot()
			character:PivotTo(CFrame.new(Vector3.one * 1e10))
			task.wait(.25)
			rootPart.Anchored = true
			character.Parent = nil
			rootPart.Name, rootPart.Parent = "OrigRootPart", workspace
			rootPart:BreakJoints()
			rootPart, cloneRootPart.Parent = cloneRootPart, character
			character.Parent = workspace
			currentOrigRootPart.Parent = character
			character:PivotTo(oldPos)
		end
		isInvis = not isInvis
	end
end
local function makeShootPackets(shootPackets, targetPart)
	for _ = 1, 10 do
		table.insert(shootPackets, {
			["RayObject"] = Ray.new(Vector3.zero, Vector3.zero),
			["Distance"] = 0,
			["Cframe"] = CFrame.identity,
			["Hit"] = targetPart
		})
	end
	return shootPackets
end
local function killPlr(arg1)
	local gunObj = player.Backpack:FindFirstChild("M9") or (player.Character and character:FindFirstChild("M9"))
	local shootPackets = table.create(0)
	if not gunObj then
		itemGive:InvokeServer(workspace.Prison_ITEMS.giver.M9.ITEMPICKUP)
		gunObj = player.Backpack:FindFirstChild("M9")
		humanoid:EquipTool(gunObj)
		gunObj:FindFirstChild("Handle"):BreakJoints()
		humanoid:UnequipTools()
	end
	if typeof(arg1) == "table" then
		for _, plr in ipairs(arg1) do
			local targetPart = plr.Character and plr.Character:FindFirstChild("Head") or nil
			if not (targetPart and not config.killConf.killBlacklist[plr.Name]) then continue end
			makeShootPackets(shootPackets, targetPart)
		end
	else
		local targetPart = arg1.Character and arg1.Character:FindFirstChild("Head") or nil
		if not targetPart then return end
		makeShootPackets(shootPackets, targetPart)
	end
	if not isSelfNeutral() then
		isKilling = true
		teamChange:FireServer("Medium stone grey"); isKilling = false
		task.defer((not config.utils.autoCriminal and teamChange.FireServer or autoCrim), teamChange, "Bright orange")
	end
	shoot:FireServer(shootPackets, gunObj)
	reload:FireServer(gunObj)
end
local function countDictionary(tableArg)
	local count = 0
	for _ in pairs(tableArg) do
		count += 1
	end
	return count
end
local function msgNotify(msg)
	starterGui:SetCore("ChatMakeSystemMessage", {
		Text = string.format("[pl-cmds.lua]: %s", msg),
		Color = Color3.fromRGB(255, 255, 255),
		Font = Enum.Font.SourceSansBold,
		FontSize = Enum.FontSize.Size32,
	})
end
local function teamSetsMatched(strArg)
	return (
		if (strArg == "cops" or strArg == "guards") then "Bright blue"
		elseif (strArg == "crims" or strArg == "criminals") then "Really red"
		elseif (strArg == "inmates" or strArg == "prisoners") then "Bright orange" else false
	)
end
local function stringFindPlayer(strArg, allowSets)
	strArg = string.lower(strArg)
	local result, playersList = table.create(0), players:GetPlayers()
	local teamColorMatched = teamSetsMatched(strArg)
	if allowSets and teamColorMatched then
		for _, plr in ipairs(playersList) do
			if plr ~= player and plr.Character and plr.TeamColor.Name == teamColorMatched then
				table.insert(result, plr)
			end
		end
		return result
	elseif strArg == "random" and #playersList >= 1 then
		local chosenPlr = playersList[math.random(1, #playersList)]
		return chosenPlr ~= player and chosenPlr or stringFindPlayer(strArg)
	else
		for _, plr in ipairs(playersList) do
			local atMatch = string.match(strArg, "^@")
			local nameDetect = atMatch and string.gsub(strArg, atMatch, "", 1) or strArg
			if string.sub(string.lower(plr[atMatch and "Name" or "DisplayName"]), 0, string.len(nameDetect)) == nameDetect then
				return plr ~= player and plr or nil
			end
		end
		msgNotify(string.format(msgOutputs.playerNotFound, strArg))
	end
end
local function msgPrefixMatch(message)
	return message and string.match(message, string.format("^%s", config.prefix)) or nil
end
local function getCommandParentName(cmdName)
	local result do
		result = commands[cmdName] and cmdName or nil
		if not result then
			for cmdAliasParent, cmdAliasList in pairs(cmdAliases) do
				if typeof(cmdAliasList) ~= "table" then continue end
				if table.find(cmdAliasList, cmdName) then
					result = cmdAliasParent
					break
				end
			end
		end
	end
	return result
end
local function cmdMsgParse(_player, message)
	message = string.lower(message)
	local prefixMatch = msgPrefixMatch(message)

	if prefixMatch then
		message = string.gsub(message, prefixMatch, "", 1)
		local args = string.split(message, " ")
		local cmdName = getCommandParentName(args[1]) or args[1]
		table.remove(args, 1)
		if commands[cmdName] then
			local cmdData = commands[cmdName]
			if (#args == 0 and cmdData.usage) then
				msgNotify(string.format(msgOutputs.commandsOutput.usageNotify, config.prefix .. cmdName .. " " .. cmdData.usage))
			else
				cmdData.callback(_player, args)
			end
		else
			msgNotify(string.format(msgOutputs.commandsOutput.unknownCommand, cmdName))
		end
	end
end
--[==[[ commands
	command template:
	["example"] = {
		["aliases"] = {}, -- nil is acceptable
		["desc"] = "",
		["usage"] = "<arg1: string | [sarg1 | sarg2]: string | arg2: number (if sarg2)>", -- optional
		["callback"] = function(speaker, args)
		end
	},
--]]==]
commands = {
	["auto-criminal"] = {
		["aliases"] = {"auto-crim"},
		["desc"] = "makes you criminal automatically.",
		["callback"] = function()
			config.utils.autoCriminal = not config.utils.autoCriminal
			msgNotify(string.format(msgOutputs.autoToggleNotify, "auto criminal", (config.utils.autoCriminal and "enabled" or "disabled")))
			autoCrim()
		end
	},
	["auto-invisible"] = {
		["aliases"] = {"auto-invis"},
		["desc"] = "makes you invisible automatically.",
		["callback"] = function()
			config.utils.invisibility = not config.utils.invisibility
			msgNotify(config.utils.invisibility and msgOutputs.invisible.enabled or msgOutputs.invisible.disabled)
			toggleInvisSelf()
		end
	},
	["auto-respawn"] = {
		["aliases"] = {"auto-re", "auto-reset"},
		["desc"] = "makes you respawn quickly if dead.",
		["callback"] = function()
			config.utils.autoSpawn = not config.utils.autoSpawn
			msgNotify(string.format(msgOutputs.autoToggleNotify, "auto respawn", (config.utils.autoSpawn and "enabled" or "disabled")))
			respawnSelf()
		end
	},
	["commands"] = {
		["aliases"] = {"cmds"},
		["desc"] = "shows commands list.",
		["callback"] = function()
			local msgResult = ""
			for cmdName, cmdData in pairs(commands) do
				cmdName = config.prefix .. cmdName
				msgResult = msgResult .. string.format(msgOutputs.commandsOutput.templateShow, (if not cmdData.aliases or countDictionary(cmdData.aliases) == 0 then cmdName else string.format("%s/%s", cmdName, table.concat(cmdData.aliases, "/"))), cmdData.desc)
			end
			msgNotify(string.format(msgOutputs.listNotify, "commands", msgResult))
		end
	},
	["giveitem"] = {
		["aliases"] = {"give", "getitem"},
		["desc"] = "gives you the item that you want.",
		["usage"] = "<[m9 | ak47 | shotgun | m4a1]: string>",
		["callback"] = function(_, args)
			local itemPickupPart = args[1] and itemPickups[args[1]] or nil
			if itemPickupPart then
				itemGive:InvokeServer(itemPickupPart)
				msgNotify(string.format(msgOutputs.giveNotify, itemPickupPart.Parent.Name))
			end
		end
	},
	["goto"] = {
		["aliases"] = {"to"},
		["desc"] = "teleports to place/player.",
		["usage"] = " <[player or place]: string> <[player/place target]: string>",
		["callback"] = function(_, args)
			local _v1
			if args[1] == "place" then
				local placeCFrame = cframePlaces[args[2]]
				if placeCFrame then
					character:PivotTo(placeCFrame * CFrame.new(Vector3.zAxis * 4))
					_v1 = args[2]
				end
			elseif args[1] == "player" or args[1] == "plr" then
				local plrRootPart = stringFindPlayer(args[1])
				plrRootPart = ((plrRootPart and plrRootPart.Character) and plrRootPart.Character:FindFirstChild("HumanoidRootPart") or nil)
				if plrRootPart then
					character:PivotTo(plrRootPart.CFrame * CFrame.new(Vector3.zAxis * 4))
					_v1 = plrRootPart.Parent.Name
				end
			end
			msgNotify(string.format(msgOutputs.gotoTpSuccess, _v1))
		end
	},
	["jump-power"] = {
		["aliases"] = {"jp", "jumppower"},
		["desc"] = "modifies jump power.",
		["usage"] = "<jumppower: number>",
		["callback"] = function(_, args)
			local _, result = pcall(tonumber, args[1])
			config.jumpPower = result or config.jumpPower
			msgNotify((not result and string.format(msgOutputs.argumentError, "1", "number") or string.format(msgOutputs.changedNotify, "jumppower", config.jumpPower)))
		end
	},
	["kill"] = {
		["aliases"] = {"begone"},
		["desc"] = "kills player(s).",
		["usage"] = "<[player | all]: string>",
		["callback"] = function(_, args)
			if args[1] == "all" then
				killPlr(players:GetPlayers())
				msgNotify(msgOutputs.kill.allPlrs)
			else
				local targetPlr = stringFindPlayer(args[1], true)
				if targetPlr then
					killPlr(targetPlr)
					msgNotify(string.format(msgOutputs.kill.targetPlr, (if typeof(targetPlr) == "table" then args[2] else targetPlr.Name)))
				end
			end
		end
	},
	["kill-aura"] = {
		["aliases"] = {"kaura"},
		["desc"] = "kills player(s) near your character.",
		["usage"] = "<[toggle | range | killmode]: string> <range: number (if range) or [punch | gun]: string (if killmode)>",
		["callback"] = function(_, args)
			if args[1] == "range" then
				local _, result = pcall(tonumber, args[2])
				config.killAura.range = (if result and result <= 25 then result else (if typeof(result) == "number" then 25 else config.killAura.range))
				msgNotify((not result and string.format(msgOutputs.argumentError, "1", "number") or string.format(msgOutputs.changedNotify, "range", config.killAura.range)))
			elseif args[1] == "toggle" then
				config.killAura.enabled = not config.killAura.enabled
				msgNotify(string.format(msgOutputs.autoToggleNotify, "kill-aura", (config.killAura.enabled and "enabled" or "disabled")))
			elseif args[1] == "mode" then
				config.killAura.killMode = args[2] and ((args[2] == "gun" and "gun") or ((args[2] == "default" or args[2] == "punch") and "punch")) or config.killAura.killMode
				msgNotify(string.format(msgOutputs.changedNotify, "kill-aura kill mode", config.killAura.killMode))
			end
		end
	},
	["kill-blacklist"] = {
		["aliases"] = {"kill-bl"},
		["desc"] = "blacklist player from being killed with commands.",
		["usage"] = "<[add | remove | list]: string> <player: string (if add or remove)>",
		["callback"] = function(_, args)
			if (args[1] == "add" or args[1] == "remove") then
				local targetPlr = args[2] and stringFindPlayer(args[2]) or nil
				if targetPlr then
					config.killConf.killBlacklist[targetPlr.Name] = (args[1] == "add" and true or args[1] == "remove" and false)
					msgNotify(string.format(msgOutputs["kill-bl"][(config.killConf.killBlacklist[targetPlr.Name] and "plrAdd" or "plrRemove")], targetPlr.Name))
				end
			elseif args[1] == "list" then
				local listResult = ""
				for plrName, blValue in pairs(config.killConf.killBlacklist) do
					listResult = listResult .. string.format("%s: %s\n", plrName, blValue)
				end
				msgNotify(countDictionary(config.killConf.killBlacklist) ~= 0 and string.format(msgOutputs.listNotify, "blacklisted player(s)", listResult) or msgOutputs.emptyNotify)
			end
		end
	},
	["loop-kill"] = {
		["aliases"] = {"lkill"},
		["desc"] = "loopkills player(s)",
		["usage"] = "<[toggle | add | remove | list]: string> <player: string (if add or remove)>",
		["callback"] = function(_, args)
			if (args[1] == "add" or args[1] == "remove") then
				if args[2] == "all" then
					for _, plr in ipairs(players:GetPlayers()) do
						if plr == player then continue end
						config.loopKill.list[plr.Name] = (if args[1] == "add" then true elseif args[1] == "remove" then false else config.loopKill.list[plr.Name])
					end
					msgNotify(string.format(msgOutputs["loop-kill"].allPlrs, (if args[1] == "add" then "added" elseif args[1] == "remove" then "remove" else false)))
				else
					local targetPlr = args[2] and stringFindPlayer(args[2], true) or nil
					if targetPlr then
						if typeof(targetPlr) == "table" then
							for _, plr in ipairs(targetPlr) do
								config.loopKill.list[plr.Name] = (if args[1] == "add" then true elseif args[1] == "remove" then false else config.loopKill.list[plr.Name])
							end
						else
							config.loopKill.list[targetPlr.Name] = (if args[1] == "add" then true elseif args[1] == "remove" then false else config.loopKill.list[targetPlr.Name])
						end
						msgNotify(string.format(msgOutputs["loop-kill"][(if args[1] == "add" then "plrAdd" elseif args[1] == "remove" then "plrRemove" else false)], (if typeof(targetPlr) == "table" then args[2] else targetPlr.Name)))
					end
				end
			elseif args[1] == "toggle" then
				config.loopKill.enabled = not config.loopKill.enabled
				msgNotify(string.format(msgOutputs.autoToggleNotify, "loop-kill", (config.loopKill.enabled and "enabled" or "disabled")))
			elseif args[1] == "list" then
				local listResult = ""
				for plrName, blValue in pairs(config.loopKill.list) do
					listResult = listResult .. string.format("%s: %s\n", plrName, blValue)
				end
				msgNotify(countDictionary(config.loopKill.list) ~= 0 and string.format(msgOutputs.listNotify, "loopkilled player(s)", listResult) or msgOutputs.emptyNotify)
			end
		end
	},
	["prefix"] = {
		["aliases"] = nil,
		["desc"] = "changes/says current prefix.",
		["callback"] = function(_, args)
			if args[1] then
				config.prefix = args[1]
				msgNotify(string.format(msgOutputs.prefix.change, args[1]))
			else
				msgNotify(string.format(msgOutputs.prefix.notify, config.prefix))
			end
		end
	},
	["respawn"] = {
		["aliases"] = {"re", "reset"},
		["desc"] = "respawns you in your current position.",
		["callback"] = function()
			respawnSelf(true, true)
			msgNotify(msgOutputs.respawnNotify)
		end
	},
	["team-color"] = {
		["aliases"] = {"tcolor"},
		["desc"] = "changes team color.",
		["callback"] = function(_, args)
			local selcColor = colorMappings[args[1]] or "default"
			if selcColor then
				currentTeamColor = (selcColor ~= "default" and selcColor or nil)
				respawnSelf()
				msgNotify(string.format(msgOutputs.teamColorChanged, args[1]))
			end
		end
	},
	["toggle-invisible"] = {
		["aliases"] = {"toggle-invis"},
		["desc"] = "makes your character invisible.",
		["callback"] = function()
			toggleInvisSelf(true)
			msgNotify(msgOutputs.invisible.notify)
		end
	},
	["walk-speed"] = {
		["aliases"] = {"ws", "walkspeed"},
		["desc"] = "modifies walkspeed.",
		["usage"] = "<walkspeed: number>",
		["callback"] = function(_, args)
			local _, result = pcall(tonumber, args[1])
			config.walkSpeed = result or config.walkSpeed
			msgNotify((not result and string.format(msgOutputs.argumentError, "1", "number") or string.format(msgOutputs.changedNotify, "walkspeed", config.walkSpeed)))
		end
	},
}
-- main
for cmdName, cmdData in pairs(commands) do
	cmdAliases[cmdName] = cmdData.aliases
end
player:GetPropertyChangedSignal("TeamColor"):Connect(autoCrim)
player.CharacterAdded:Connect(function(spawnedCharacter)
	character = spawnedCharacter
	humanoid, rootPart = character:WaitForChild("Humanoid"), character:WaitForChild("HumanoidRootPart")
	isInvis, currentOrigRootPart = false, rootPart
	if diedConnection then diedConnection:Disconnect() end
	if config.utils.autoSpawn then
		diedConnection = humanoid.Died:Connect(respawnSelf)
	end
	task.defer(toggleInvisSelf)
	task.delay(1, autoCrim)
end)
runService.Heartbeat:Connect(function()
	if humanoid then
		humanoid.WalkSpeed, humanoid.JumpPower = config.walkSpeed, config.jumpPower
	end
end)
task.spawn(function() -- kill-aura
	local killingPlayers = table.create(0)
	while true do task.wait()
		if config.killAura.enabled then
			for _, plr in ipairs(players:GetPlayers()) do
				if not config.killConf.killBlacklist[plr.Name] or plr ~= player then
					local plrChar = plr.Character
					local _rootPart, _humanoid = plrChar and plrChar:FindFirstChild("HumanoidRootPart") or nil, plrChar and plrChar:FindFirstChildWhichIsA("Humanoid") or nil
					if ((plrChar and not plrChar:FindFirstChildWhichIsA("ForceField")) and (_humanoid and _humanoid.Health ~= 0) and (_rootPart and player:DistanceFromCharacter(_rootPart.Position) < config.killAura.range)) then
						table.insert(killingPlayers, plr)
					end
				end
			end
			if #killingPlayers ~= 0 then
				if config.killAura.killMode == "gun" then
					killPlr(killingPlayers)
					table.clear(killingPlayers)
					task.wait(.5)
				elseif config.killAura.killMode == "punch" then
					for _, plr in ipairs(killingPlayers) do
						for _ = 1, 25 do punch:FireServer(plr) end
					end
				end
			end
		end
	end
end)
task.spawn(function() -- loop-kill
	local killingPlayers = table.create(0)
	while true do task.wait()
		if config.loopKill.enabled then
			for _, plr in ipairs(players:GetPlayers()) do
				local _humanoid = plr.Character and plr.Character:FindFirstChild("Humanoid") or nil
				if config.loopKill.list[plr.Name] and ((plr.Character and not plr.Character:FindFirstChildWhichIsA("ForceField")) and (_humanoid and _humanoid.Health ~= 0)) then
					table.insert(killingPlayers, plr)
				end
			end
			if #killingPlayers ~= 0 then
				killPlr(killingPlayers)
				table.clear(killingPlayers)
			end
			task.wait(.75)
		end
	end
end)
oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(...)
	local self, message = ...
	local namecallMethod = getnamecallmethod()

	if (not checkcaller() and (self.ClassName == "RemoteEvent" and self.Name == "SayMessageRequest") and namecallMethod == "FireServer") and msgPrefixMatch(message) then
		task.spawn(cmdMsgParse, player, message)
		return
	end
	return oldNamecall(...)
end))
msgNotify(string.format(msgOutputs.loadedMsg, "v0.1.8", config.prefix))
