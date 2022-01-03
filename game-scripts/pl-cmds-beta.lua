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
local shoot, reload, itemGive, teamChange, loadChar =
	repStorage:FindFirstChild("ShootEvent"),
	repStorage:FindFirstChild("ReloadEvent"),
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
	["prefix"] = ";",
	["walkSpeed"] = 16,
	["jumpPower"] = 50
}
local msgOutputs = {
	["commandsOutput"] = {
		["listing"] = "commands: \n%s",
		["templateShow"] = "- %s: %s\n"
	},
	["goto"] = {
		["tpSuccess"] = "teleported to %s."
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
	["characterModsChanged"] = "changed %s to %s.",
	["teamColorChanged"] = "changed chat color to %s",
	["loadedMsg"] = "%s loaded, prefix is '%s' enjoy!",
	["resetNotify"] = "character resetted successfully."
}
local colorMappings = {
	["black"] = BrickColor.new("Really black"),
	["blue"] = BrickColor.new("Dark blue"),
	["gray"] = BrickColor.new("Dark grey metallic"),
	["green"] = BrickColor.new("Forest green"),
	["red"] = BrickColor.new("Bright red"),
	["white"] = BrickColor.new("Institutional white"),
	["yellow"] = BrickColor.new("Fire Yellow"),
}
local isKilling = false
local cmdAliases = table.create(0)
local diedConnection, oldNamecall, commands
-- functions
local function autoCrim()
	if ((config.utils.autoCriminal and not config.utils.invisibility) and rootPart and not isKilling and player.TeamColor.Name ~= "Really red") then
		local spawnPart = workspace:FindFirstChild("Criminals Spawn"):FindFirstChildWhichIsA("SpawnLocation")
		local oldSpawnPos = spawnPart.CFrame
		spawnPart.CFrame = rootPart.CFrame
		firetouchinterest(spawnPart, rootPart, 0); firetouchinterest(spawnPart, rootPart, 1)
		spawnPart.CFrame = oldSpawnPos
	end
end
local function respawnSelf(bypassToggle)
	if bypassToggle or config.utils.autoSpawn then
		local oldPos = player.Character:GetPivot()
		loadChar:InvokeServer(player.Name, (not config.utils.autoCriminal and player.TeamColor.Name or "Really red"))
		player.Character:PivotTo(oldPos)
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
			if not targetPart or config.killConf.killBlacklist[plr.Name] then continue end
			for _ = 1, 10 do
				table.insert(shootPackets, {
					["RayObject"] = Ray.new(Vector3.new(), Vector3.new()),
					["Distance"] = 0,
					["Cframe"] = CFrame.new(),
					["Hit"] = targetPart
				})
			end
		end
	else
		local targetPart = arg1.Character and arg1.Character:FindFirstChild("Head") or nil
		if not targetPart then return end
		for _ = 1, 10 do
			table.insert(shootPackets, {
				["RayObject"] = Ray.new(Vector3.new(), Vector3.new()),
				["Distance"] = 0,
				["Cframe"] = CFrame.new(),
				["Hit"] = targetPart
			})
		end
	end
	if not player.Neutral or not config.utils.autoSpawn then
		isKilling = true
		teamChange:FireServer("Medium stone grey"); isKilling = false
		task.defer((not config.utils.autoCriminal and teamChange.FireServer or autoCrim), teamChange, "Bright orange")
	end
	shoot:FireServer(shootPackets, gunObj); reload:FireServer(gunObj)
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
	["auto-reset"] = {
		["aliases"] = {"auto-re", "fast-spawn"},
		["desc"] = "makes you resets when died automatically.",
		["func"] = function()
			config.utils.autoSpawn = not config.utils.autoSpawn
			msgNotify(string.format(msgOutputs.autoToggleNotify, "auto reset", (config.utils.autoSpawn and "enabled" or "disabled")))
			respawnSelf()
		end
	},
	["teamcolor"] = {
		["aliases"] = {"tcolor"},
		["desc"] = "changes team color.",
		["func"] = function(_, args)
			local selcColor = colorMappings[args[1]]
			if selcColor then
				player.TeamColor = selcColor
				msgNotify(string.format(msgOutputs.teamColorChanged, args[1]))
			end
		end
	},
	["commands"] = {
		["aliases"] = {"cmds"},
		["desc"] = "shows commands list.",
		["func"] = function()
			local msgResult = ""
			for cmdName, cmdData in pairs(commands) do
				msgResult = msgResult .. string.format(msgOutputs.commandsOutput.templateShow, (#cmdData.aliases ~= 0 and string.format("%s/%s", cmdName, table.concat(cmdData.aliases, "/")) or cmdName), cmdData.desc)
			end
			msgNotify(string.format(msgOutputs.commandsOutput.listing, msgResult))
		end
	},
	["goto"] = {
		["aliases"] = {"to"},
		["desc"] = "teleports to player.",
		["func"] = function(_, args)
			local targetPlr = stringFindPlayer(args[1])
			local targetPlrPart = (targetPlr and targetPlr.Character) and targetPlr.Character:FindFirstChild("HumanoidRootPart") or nil
			if targetPlr and ((humanoid and humanoid.Health ~= 0) and targetPlrPart) then
				character:PivotTo(targetPlrPart.CFrame * CFrame.new(0, 0, 2))
				msgNotify(string.format(msgOutputs.goto.tpSuccess, targetPlr.Name))
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
		["aliases"] = {},
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
	["kill-blacklist"] = {
		["aliases"] = {"kill-bl"},
		["desc"] = "blacklist player from being killed with commands.",
		["func"] = function(_, args)
			local targetPlr = args[2] and stringFindPlayer(args[2]) or nil
			if targetPlr and (args[1] == "add" or args[1] == "remove") then
				config.killConf.killBlacklist[targetPlr.Name] = (args[1] == "add" and true or args[1] == "remove" and false or config.killConf.killBlacklist[targetPlr.Name])
				msgNotify(string.format(msgOutputs["kill-bl"][(config.killConf.killBlacklist[targetPlr.Name] and "plrAdd" or "plrRemove")], targetPlr.Name))
			elseif args[1] == "list" then
				local listResult = ""
				for plrName in pairs(config.killConf.killBlacklist) do
					listResult = listResult .. plrName .. "\n"
				end
				msgNotify(#config.killConf.killBlacklist ~= 0 and string.format(msgOutputs["kill-bl"].list, listResult) or msgOutputs["kill-bl"].listEmpty)
			end
		end
	},
	["prefix"] = {
		["aliases"] = {},
		["desc"] = "changes/says current prefix.",
		["func"] = function(_, args)
			if args[1] then
				config.prefix = args[1]
				msgNotify(string.format(msgOutputs.prefix.change, args[2]))
			else
				msgNotify(string.format(msgOutputs.prefix.notify, config.prefix))
			end
		end
	},
	["reset"] = {
		["aliases"] = {"re"},
		["desc"] = "respawns you in your current position.",
		["func"] = function()
			respawnSelf(true, true)
			msgNotify(msgOutputs.resetNotify)
		end
	},
	["jumppower"] = {
		["aliases"] = {"jp"},
		["desc"] = "modifies jump power.",
		["func"] = function(_, args)
			local success = pcall(tonumber, args[1])
			if success then
				config.jumpPower = args[1]
				msgNotify(string.format(msgOutputs.characterModsChanged, "jumppower", args[1]))
			else
				msgNotify(string.format(msgOutputs.argumentError, "2", "number"))
			end
		end
	},
	["walkspeed"] = {
		["aliases"] = {"ws"},
		["desc"] = "modifies walkspeed.",
		["func"] = function(_, args)
			local success = pcall(tonumber, args[1])
			if success then
				config.walkSpeed = args[1]
				msgNotify(string.format(msgOutputs.characterModsChanged, "walkspeed", args[1]))
			else
				msgNotify(string.format(msgOutputs.argumentError, "2", "number"))
			end
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
msgNotify(string.format(msgOutputs.loadedMsg, "v0.1.3", config.prefix))
