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
		["killWl"] = table.create(0),
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
	["kill-bl_ADD"] = "added %s to whitelist, player wouldn't be killed anymore.",
	["kill-bl_REMOVE"] = "removed %s whitelist, player will be killed again.",
	["invisible_enabled"] = "invisibility is now enabled, nobody can see u now.",
	["invisible_disabled"] = "invisibility is now disabled, anyone can see u now."
}
local isKilling = false
local diedConnection, oldNamecall
-- functions
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
local function respawnSelf(useCurrentTeam)
	if config.utils.autoSpawn then
		local oldPos = player.Character:GetPivot()
		loadChar:InvokeServer(player.Name, (useCurrentTeam and player.TeamColor.Name or (config.utils.autoCriminal and "Really red" or "Really black")))
		player.Character:PivotTo(oldPos)
	end
end
local function invisSelf()
	if config.utils.invisibility and (character and rootPart) then
		local cloneRootPart, oldPos = rootPart:Clone(), character:GetPivot()
		character:PivotTo(CFrame.new(Vector3.one * 1e10))
		task.wait(.25)
		character.Parent = nil
		rootPart:Destroy()
		cloneRootPart.Parent = character
		character.Parent = workspace
		character:PivotTo(oldPos)
		rootPart = cloneRootPart
	elseif not config.utils.invisibility then
		character:BreakJoints()
	end
end
local function killPlr(arg1)
	local gunObj = player.Backpack:FindFirstChild("M9")
	if not gunObj then
		itemGive:InvokeServer(workspace.Prison_ITEMS.giver.M9.ITEMPICKUP)
		gunObj = player.Backpack:FindFirstChild("M9")
	end
	local shootings = table.create(0)
	if typeof(arg1) == "table" then
		for _, plr in ipairs(arg1) do
			local targetPart = plr.Character and plr.Character:FindFirstChild("Head") or nil
			if not targetPart or config.killConf.killWl[plr.Name] then continue end
			for _ = 1, 10 do
				table.insert(shootings, {
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
			table.insert(shootings, {
				["RayObject"] = Ray.new(Vector3.new(), Vector3.new()),
				["Distance"] = 0,
				["Cframe"] = CFrame.new(),
				["Hit"] = targetPart
			})
		end
	end
	if not config.utils.autoSpawn then
		isKilling = not isKilling
		teamChange:FireServer("Medium stone grey"); isKilling = not isKilling
		task.defer((not config.utils.autoCriminal and teamChange.FireServer or autoCrim), teamChange, "Bright orange")
	end
	shoot:FireServer(shootings, gunObj)
	reload:FireServer(gunObj)
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
local function msgHasPrefix(message)
	return message and string.match(message, string.format("^%s", config.prefix)) or nil
end
local function commandRun(message)
	message = string.lower(message)
	local prefixMatch = string.match(message, string.format("^%s", config.prefix))

	if prefixMatch then
		message = string.gsub(message, prefixMatch, "", 1)
		local args = table.create(0)
		for arg in string.gmatch(message, "[^%s]+") do
			table.insert(args, arg)
		end

		if args[1] == "kill" then
			if args[2] == "all" then
				killPlr(players:GetPlayers())
				msgNotify("killed all players.")
			else
				local targetPlr = stringFindPlayer(args[2], true)
				if targetPlr then
					killPlr(targetPlr)
					msgNotify(string.format("killed %s.", (type(targetPlr) ~= "table" and targetPlr.Name or args[2])))
				end
			end
		elseif args[1] == "kill-bl" then
			local targetPlr = args[3] and stringFindPlayer(args[3]) or nil
			if targetPlr then
				config.killConf.killWl[targetPlr.Name] = (args[2] == "add" and true or args[2] == "remove" and false or config.killConf.killWl[targetPlr.Name])
				msgNotify(string.format((config.killConf.killWl[targetPlr.Name] and msgOutputs["kill-bl_ADD"] or msgOutputs["kill-bl_REMOVE"]), targetPlr.Name))
			end
			if args[2] == "list" then
				local listResult = ""
				for plrName in pairs(config.killConf.killWl) do
					listResult = listResult .. plrName .. "\n"
				end
				msgNotify(string.format("blacklisted players list: \n%s", listResult))
			end
		elseif args[1] == "goto" then
			local targetPlr = stringFindPlayer(args[2])
			if targetPlr and (rootPart and (humanoid and humanoid.Health ~= 0) and targetPlr.Character:FindFirstChild("HumanoidRootPart")) then
				rootPart.CFrame = targetPlr.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 2)
				msgNotify(string.format("teleported to %s.", targetPlr.Name))
			end
		elseif args[1] == "ws" or args[1] == "walkspeed" then
			local success = pcall(tonumber, args[2])
			if success then
				config.walkSpeed = args[2]
				msgNotify(string.format("changed walkspeed to %s.", args[2]))
			else
				msgNotify("argument 2 should be a number.")
			end
		elseif args[1] == "jp" or args[1] == "jumppower" then
			local success = pcall(tonumber, args[2])
			if success then
				config.jumpPower = args[2]
				msgNotify(string.format("changed jumppower to %s.", args[2]))
			else
				msgNotify("argument 2 should be a number.")
			end
		elseif args[1] == "auto-crim" then
			config.utils.autoCriminal = not config.utils.autoCriminal
			msgNotify(string.format("auto criminal is now %s.", (config.utils.autoCriminal and "enabled" or "disabled")))
			autoCrim()
		elseif args[1] == "auto-spawn" then
			config.utils.autoSpawn = not config.utils.autoSpawn
			msgNotify(string.format("auto spawn is now %s.", (config.utils.autoSpawn and "enabled" or "disabled")))
			respawnSelf()
		elseif args[1] == "invisible" then
			config.utils.invisibility = not config.utils.invisibility
			msgNotify(config.utils.invisibility and msgOutputs.invisible_enabled or msgOutputs.invisible_disabled)
			invisSelf()
		end
	end
end
-- main
player:GetPropertyChangedSignal("TeamColor"):Connect(autoCrim)
player.CharacterAdded:Connect(function(spawnedCharacter)
	character = spawnedCharacter
	humanoid, rootPart = character:WaitForChild("Humanoid"), character:WaitForChild("HumanoidRootPart")
	if config.utils.autoSpawn then
		if diedConnection then diedConnection:Disconnect() end
		diedConnection = humanoid.Died:Connect(respawnSelf)
		humanoid:ChangeState(Enum.HumanoidStateType.Running)
	end
	task.defer(invisSelf)
end)
runService.Heartbeat:Connect(function()
	if humanoid then
		humanoid.WalkSpeed, humanoid.JumpPower = config.walkSpeed, config.jumpPower
	end
end)
oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
	local message = ...
	local namecallMethod = getnamecallmethod()

	if (not checkcaller() and (self.ClassName == "RemoteEvent" and self.Name == "SayMessageRequest") and namecallMethod == "FireServer") and msgHasPrefix(message) then
		task.spawn(commandRun, message)
		return
	end
	return oldNamecall(self, ...)
end))
msgNotify(string.format("v0.1.2 loaded, prefix is '%s' enjoy!", config.prefix))
