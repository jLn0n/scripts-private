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
local shoot, reload, punch, itemGive, teamChange, loadChar =
	repStorage:FindFirstChild("ShootEvent"),
	repStorage:FindFirstChild("ReloadEvent"),
	repStorage:FindFirstChild("meleeEvent"),
	workspace.Remote:FindFirstChild("ItemHandler"),
	workspace.Remote:FindFirstChild("TeamEvent"),
	workspace.Remote:FindFirstChild("loadchar")
-- variables
local config = {
	["killConf"] = {
		["hrpTarget"] = nil,
		["killBlacklist"] = table.create(0),
	},
	["utils"] = {
		["autoCriminal"] = false,
		["autoSpawn"] = false,
		["invisibility"] = false
	},
	["killAura"] = {
		["enabled"] = false,
		["range"] = 25,
	},
	["prefix"] = ";",
	["walkSpeed"] = 16,
	["jumpPower"] = 50
}
local msgOutputs = {
	["commandsOutput"] = {
		["listing"] = "commands: \n%s",
		["templateShow"] = "- %s: %s\n"
	},
	["invisible"] = {
		["enabled"] = "invisibility is now enabled, nobody can see u now.",
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
		["list"] = "blacklisted players list: \n%s",
		["listEmpty"] = "blacklisted player(s) is empty.",
	},
	["prefix"] = {
		["notify"] = "current prefix is '%s'.",
		["change"] = "changed prefix to '%s'.",
	},
	["argumentError"] = "argument %s should be a %s.",
	["autoToggleNotify"] = "%s is now %s.",
	["changedNotify"] = "changed %s to %s.",
	["giveNotify"] = "you now have '%s'.",
	["gotoTpSuccess"] = "teleported to %s.",
	["playerNotFound"] = "cannot find player '%s'.",
	["teamColorChanged"] = "changed team color to %s. (can only be applied when auto reset is enabled.)",
	["loadedMsg"] = "%s loaded, prefix is '%s' enjoy!",
	["respawnNotify"] = "character respawned successfully.",
	["unknownCommand"] = "command '%s' cannot be found."
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
	["nexus"] = CFrame.new(920, 98, 2450),
	["policeroom"] = CFrame.new(835, 99, 2270),
	["crimbase"] = CFrame.new(-945, 95, 2055)
}
local itemPickups = {
	["ak47"] = workspace.Prison_ITEMS.giver["AK-47"].ITEMPICKUP,
	["knife"] = workspace.Prison_ITEMS.single["Crude Knife"].ITEMPICKUP,
	["m4a1"] = workspace.Prison_ITEMS.giver.M4A1.ITEMPICKUP,
	["m9"] = workspace.Prison_ITEMS.giver.M9.ITEMPICKUP,
	["shotgun"] = workspace.Prison_ITEMS.giver["Remington 870"].ITEMPICKUP,
}
local isKilling = false
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
		firetouchinterest(spawnPart, rootPart, 0); firetouchinterest(spawnPart, rootPart, 1)
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
local function invisSelf(bypassToggle)
	if (bypassToggle or config.utils.invisibility) and (character and rootPart) then
		local cloneRootPart, oldPos = rootPart:Clone(), character:GetPivot()
		character:PivotTo(CFrame.new(Vector3.one * 1e10)); task.wait(.25)
		rootPart.Anchored = true
		character.Parent = nil
		rootPart:Destroy()
		rootPart, cloneRootPart.Parent = cloneRootPart, character
		character.Parent = workspace
		character:PivotTo(oldPos)
	end
end
local function killPlr(arg1)
	local gunObj = player.Backpack:FindFirstChild("M9")
	local shootPackets = table.create(0)
	if not gunObj then
		itemGive:InvokeServer(workspace.Prison_ITEMS.giver.M9.ITEMPICKUP)
		gunObj = player.Backpack:FindFirstChild("M9")
	end
	if typeof(arg1) == "table" then
		for _, plr in ipairs(arg1) do
			local targetPart = plr.Character and plr.Character:FindFirstChild("Head") or nil
			if targetPart and not config.killConf.killBlacklist[plr.Name] then
				for _ = 1, 10 do
					table.insert(shootPackets, {
						["RayObject"] = Ray.new(Vector3.zero, Vector3.zero),
						["Distance"] = 0,
						["Cframe"] = CFrame.new(),
						["Hit"] = targetPart
					})
				end
			end
		end
	else
		local targetPart = arg1.Character and arg1.Character:FindFirstChild("Head") or nil
		if not targetPart then return end
		for _ = 1, 10 do
			table.insert(shootPackets, {
				["RayObject"] = Ray.new(Vector3.zero, Vector3.zero),
				["Distance"] = 0,
				["Cframe"] = CFrame.new(),
				["Hit"] = targetPart
			})
		end
	end
	if not isSelfNeutral() then
		isKilling = true
		teamChange:FireServer("Medium stone grey"); isKilling = false
		task.defer((not config.utils.autoCriminal and teamChange.FireServer or autoCrim), teamChange, "Bright orange")
	end
	shoot:FireServer(shootPackets, gunObj)
	reload:FireServer(gunObj)
end
local function countTable(tableArg)
	local count = 0
	for _ in pairs(tableArg) do
		count = count + 1
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
local function stringFindPlayer(strArg, allowSets)
	strArg = string.lower(strArg)
	local result, playersList = table.create(0), players:GetPlayers()
	if allowSets and (strArg == "cops" or strArg == "guards") or (strArg == "crims" or strArg == "criminals") or (strArg == "inmates" or strArg == "prisoners") then
		for _, plr in ipairs(playersList) do
			if plr ~= player and plr.Character and plr.TeamColor.Name == (
				(strArg == "cops" or strArg == "guards") and "Bright blue" or
				(strArg == "crims" or strArg == "criminals") and "Really red" or
				(strArg == "inmates" or strArg == "prisoners") and "Bright orange" or nil
			) then
				table.insert(result, plr)
			end
		end
		return result
	elseif strArg == "random" then
		return playersList[math.random(1, #playersList)]
	else
		for _, plr in ipairs(playersList) do
			local atMatch = string.match(strArg, "^@")
			strArg = atMatch and string.gsub(strArg, atMatch, "", 1) or strArg
			if string.sub(string.lower(plr[atMatch and "Name" or "DisplayName"]), 0, string.len(strArg)) == strArg then
				return plr == player and nil or plr
			end
		end
		msgNotify(string.format(msgOutputs.playerNotFound, strArg))
	end
end
local function msgPrefixMatch(message)
	return message and string.match(message, string.format("^%s", config.prefix)) or nil
end
local function getCommandFunction(cmdName)
	local funcResult do
		funcResult = commands[cmdName] and commands[cmdName].func or nil
		if not funcResult then
			for cmdAliasParent, cmdAliasList in pairs(cmdAliases) do
				if table.find(cmdAliasList, cmdName) then
					funcResult = commands[cmdAliasParent].func
					break
				end
			end
		end
	end
	return funcResult
end
local function cmdMsgParse(_player, message)
	message = string.lower(message)
	local prefixMatch = msgPrefixMatch(message)

	if prefixMatch then
		message = string.gsub(message, prefixMatch, "", 1)
		local args = table.create(0)
		for argument in string.gmatch(message, "[^%s]+") do
			table.insert(args, argument)
		end

		local cmdName = args[1]
		table.remove(args, 1)
		local cmdFunction = getCommandFunction(cmdName)
		if cmdFunction then
			cmdFunction(_player, args)
		else
			msgNotify(string.format(msgOutputs.unknownCommand, cmdName))
		end
	end
end
--[==[[ commands
	command template:
	["example"] = {
		["aliases"] = {},
		["desc"] = "",
		["func"] = function(speaker, args)
		end
	},
--]]==]
commands = {
	["auto-criminal"] = {
		["aliases"] = {"auto-crim"},
		["desc"] = "makes you criminal automatically.",
		["func"] = function()
			config.utils.autoCriminal = not config.utils.autoCriminal
			msgNotify(string.format(msgOutputs.autoToggleNotify, "auto criminal", (config.utils.autoCriminal and "enabled" or "disabled")))
			autoCrim()
		end
	},
	["auto-invisible"] = {
		["aliases"] = {"auto-invis"},
		["desc"] = "makes you invisible automatically.",
		["func"] = function()
			config.utils.invisibility = not config.utils.invisibility
			msgNotify(config.utils.invisibility and msgOutputs.invisible.enabled or msgOutputs.invisible.disabled)
			invisSelf()
		end
	},
	["auto-respawn"] = {
		["aliases"] = {"auto-re", "auto-reset"},
		["desc"] = "makes you respawn quickly if dead.",
		["func"] = function()
			config.utils.autoSpawn = not config.utils.autoSpawn
			msgNotify(string.format(msgOutputs.autoToggleNotify, "auto respawn", (config.utils.autoSpawn and "enabled" or "disabled")))
			respawnSelf()
		end
	},
	["commands"] = {
		["aliases"] = {"cmds"},
		["desc"] = "shows commands list.",
		["func"] = function()
			local msgResult = ""
			for cmdName, cmdData in pairs(commands) do
				cmdName = config.prefix .. cmdName
				msgResult = msgResult .. string.format(msgOutputs.commandsOutput.templateShow, (countTable(cmdData.aliases) ~= 0 and string.format("%s/%s", cmdName, table.concat(cmdData.aliases, "/")) or cmdName), cmdData.desc)
			end
			msgNotify(string.format(msgOutputs.commandsOutput.listing, msgResult))
		end
	},
	["giveitem"] = {
		["aliases"] = {"give", "getitem"},
		["desc"] = "gives you the item that you want.",
		["func"] = function(_, args)
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
		["func"] = function(_, args)
			local localStoredVar = cframePlaces[args[1]] or stringFindPlayer(args[1])
			localStoredVar = (typeof(localStoredVar) == "Instance") and ((localStoredVar and localStoredVar.Character) and localStoredVar.Character:FindFirstChild("HumanoidRootPart")) or localStoredVar
			if localStoredVar then
				character:PivotTo((typeof(localStoredVar) == "Instance") and localStoredVar.CFrame or localStoredVar)
				msgNotify(string.format(msgOutputs.gotoTpSuccess, ((typeof(localStoredVar) == "Instance") and localStoredVar.Name or args[1])))
			end
		end
	},
	["invisible"] = {
		["aliases"] = {"invis"},
		["desc"] = "makes your character invisible.",
		["func"] = function()
			invisSelf(true)
			msgNotify(msgOutputs.invisible.notify)
		end
	},
	["kill"] = {
		["aliases"] = {"begone"},
		["desc"] = "kills player(s).",
		["func"] = function(_, args)
			if args[1] == "all" then
				killPlr(players:GetPlayers())
				msgNotify(msgOutputs.kill.allPlrs)
			else
				local targetPlr = stringFindPlayer(args[1], true)
				if targetPlr then
					killPlr(targetPlr)
					msgNotify(string.format(msgOutputs.kill.targetPlr, (type(targetPlr) ~= "table" and targetPlr.Name or args[1])))
				end
			end
		end
	},
	["kill-aura"] = {
		["aliases"] = {"kaura"},
		["desc"] = "kills player(s) near your character.",
		["func"] = function(_, args)
			if args[1] == "range" then
				local _, result = pcall(tonumber, args[2])
				config.killAura.range = ((result and result <= 25) and result or config.killAura.range)
				msgNotify((not result and string.format(msgOutputs.argumentError, "1", "number") or string.format(msgOutputs.changedNotify, "range", config.killAura.range)))
			elseif args[1] == "toggle" then
				config.killAura.enabled = not config.killAura.enabled
				msgNotify(string.format(msgOutputs.autoToggleNotify, "kill aura", (config.killAura.enabled and "enabled" or "disabled")))
			end
		end
	},
	["kill-blacklist"] = {
		["aliases"] = {"kill-bl"},
		["desc"] = "blacklist player from being killed with commands.",
		["func"] = function(_, args)
			local targetPlr = args[2] and stringFindPlayer(args[2]) or nil
			if targetPlr and (args[1] == "add" or args[1] == "remove") then
				config.killConf.killBlacklist[targetPlr.Name] = (args[1] == "add" and true or args[1] == "remove" and false)
				msgNotify(string.format(msgOutputs["kill-bl"][(config.killConf.killBlacklist[targetPlr.Name] and "plrAdd" or "plrRemove")], targetPlr.Name))
			elseif args[1] == "list" then
				local listResult = ""
				for plrName, blValue in pairs(config.killConf.killBlacklist) do
					listResult = listResult .. string.format("%s: %s\n", plrName, blValue)
				end
				msgNotify(countTable(config.killConf.killBlacklist) ~= 0 and string.format(msgOutputs["kill-bl"].list, listResult) or msgOutputs["kill-bl"].listEmpty)
			end
		end
	},
	["prefix"] = {
		["aliases"] = {},
		["desc"] = "changes/says current prefix.",
		["func"] = function(_, args)
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
		["func"] = function()
			respawnSelf(true, true)
			msgNotify(msgOutputs.respawnNotify)
		end
	},
	["team-color"] = {
		["aliases"] = {"tcolor"},
		["desc"] = "changes team color.",
		["func"] = function(_, args)
			local selcColor = colorMappings[args[1]] or "default"
			if selcColor then
				currentTeamColor = (selcColor ~= "default" and selcColor or nil)
				respawnSelf()
				msgNotify(string.format(msgOutputs.teamColorChanged, args[1]))
			end
		end
	},
	["jump-power"] = {
		["aliases"] = {"jp", "jumppower"},
		["desc"] = "modifies jump power.",
		["func"] = function(_, args)
			local _, result = pcall(tonumber, args[1])
			config.jumpPower = result or config.jumpPower
			msgNotify((not result and string.format(msgOutputs.argumentError, "1", "number") or string.format(msgOutputs.changedNotify, "jumppower", config.jumpPower)))
		end
	},
	["walk-speed"] = {
		["aliases"] = {"ws", "walkspeed"},
		["desc"] = "modifies walkspeed.",
		["func"] = function(_, args)
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
	if config.utils.autoSpawn then
		if diedConnection then diedConnection:Disconnect() end
		diedConnection = humanoid.Died:Connect(respawnSelf)
	end
	task.defer(invisSelf); task.defer(autoCrim)
end)
runService.Heartbeat:Connect(function()
	if humanoid then
		humanoid.WalkSpeed, humanoid.JumpPower = config.walkSpeed, config.jumpPower
	end
	if config.killAura.enabled and rootPart then
		for _, plr in ipairs(players:GetPlayers()) do
			if plr ~= player then
				local plrChar = plr.Character
				local _rootPart, _humanoid = plrChar and character:FindFirstChild("HumanoidRootPart") or nil, plrChar and character:FindFirstChildWhichIsA("Humanoid")
				if not config.killConf.killBlacklist[plr.Name] and ((_humanoid and _humanoid.Health ~= 0) and (_rootPart and player:DistanceFromCharacter(_rootPart.Position) < config.killAura.range)) then
					punch:FireServer(plr)
				end
			end
		end
	end
end)
oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
	local message = ...
	local namecallMethod = getnamecallmethod()

	if (not checkcaller() and (self.ClassName == "RemoteEvent" and self.Name == "SayMessageRequest") and namecallMethod == "FireServer") and msgPrefixMatch(message) then
		task.spawn(cmdMsgParse, player, message)
		return
	end
	return oldNamecall(self, ...)
end))
msgNotify(string.format(msgOutputs.loadedMsg, "v0.1.4", config.prefix))
