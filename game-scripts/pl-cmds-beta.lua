-- services
local players = game:GetService("Players")
local repStorage = game:GetService("ReplicatedStorage")
local runService = game:GetService("RunService")
local starterGui = game:GetService("StarterGui")
-- objects
local player = players.LocalPlayer
local humanoid = player.Character:FindFirstChildWhichIsA("Humanoid")
local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
-- events
local shoot, reload, itemGive, teamChange, loadChar =
	repStorage:FindFirstChild("ShootEvent"),
	repStorage:FindFirstChild("ReloadEvent"),
	workspace.Remote:FindFirstChild("ItemHandler"),
	workspace.Remote:FindFirstChild("TeamEvent"),
	workspace.Remote:FindFirstChild("loadchar")
local chatted = Instance.new("BindableEvent")
-- variables
local config = {
	["killConf"] = {
		["hrpTarget"] = nil,
		["killWl"] = table.create(0),
	},
	["utils"] = {
		["autoCriminal"] = false,
		["fastRespawn"] = true,
	},
	["walkSpeed"] = 16,
	["jumpPower"] = 50
}
local msgOutputs = {
	["kill-bl_ADD"] = "added %s to whitelist, player wouldn't be killed anymore.",
	["kill-bl_REMOVE"] = "removed %s whitelist, player will be killed again."
}
local currentKilling = false
local diedConnection, oldNamecall
-- functions
local function autoCrim()
	if config.utils.autoCriminal and rootPart and not currentKilling then
		local oldPos, spawnPart = rootPart.CFrame, workspace:FindFirstChild("Criminals Spawn"):FindFirstChildWhichIsA("SpawnLocation")
		rootPart.CFrame = spawnPart.CFrame; task.wait()
		rootPart.CFrame = oldPos
		humanoid:ChangeState(Enum.HumanoidStateType.Running)
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
	if (config.utils.autoCriminal or not config.utils.fastRespawn) then
		currentKilling = true
		teamChange:FireServer("Medium stone grey"); currentKilling = false
		if config.utils.autoCriminal then autoCrim();return end
		task.defer(teamChange.FireServer, teamChange, "Bright orange")
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
local function respawnSelf()
	local oldPos = player.Character:GetPivot()
	loadChar:InvokeServer(player.Name, (config.utils.autoCriminal and "Really red" or "Really black"))
	player.Character:PivotTo(oldPos)
end
local function stringFindPlayer(strArg, allowSets)
	strArg = string.lower(strArg)
	local result = table.create(0)
	if allowSets and (strArg == "cops" or strArg == "guards") or (strArg == "crims" or strArg == "criminals") or (strArg == "inmates" or strArg == "prisoners") then
		for _, plr in ipairs(players:GetPlayers()) do
			if plr ~= player and plr.Character and plr.TeamColor.Name == (
				(strArg == "cops" or strArg == "guards") and "Bright blue" or
				(strArg == "crims" or strArg == "criminals") and "Really red" or
				(strArg == "inmates" or strArg == "prisoners") and "Bright orange" or nil
			) then
				table.insert(result, plr)
			end
		end
		return result
	else
		for _, plr in ipairs(players:GetPlayers()) do
			local atMatch = string.match(strArg, "^@")
			strArg = atMatch and string.gsub(strArg, atMatch, "", 1) or strArg
			if string.sub(string.lower(plr[atMatch and "Name" or "DisplayName"]), 0, string.len(strArg)) == strArg then
				return plr == player and nil or plr
			end
		end
	end
end
local function cmdParse(message)
	message = string.lower(message)
	local prefixMatch = string.match(message, "^/")

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
			local targetPlr = stringFindPlayer(args[3])
			if targetPlr then
				config.killConf.killWl[targetPlr.Name] = (args[2] == "add" and true or args[2] == "remove" and false or config.killConf.killWl[targetPlr.Name])
				msgNotify(string.format((config.killConf.killWl[targetPlr.Name] and msgOutputs["kill-bl_ADD"] or msgOutputs["kill-bl_REMOVE"]), targetPlr.Name))
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
		elseif args[1] == "autocrim" then
			config.utils.autoCriminal = not config.utils.autoCriminal
			msgNotify(string.format("auto criminal is now %s.", (config.utils.autoCriminal and "enabled" or "disabled")))
			autoCrim()
		elseif args[1] == "fast-respawn" then
			config.utils.fastRespawn = not config.utils.fastRespawn
			msgNotify(string.format("fast respawn is now %s.", (config.utils.fastRespawn and "enabled" or "disabled")))
		end
	end
end
-- main
chatted.Event:Connect(cmdParse)
player:GetPropertyChangedSignal("TeamColor"):Connect(autoCrim)
player.CharacterAdded:Connect(function(character)
	humanoid, rootPart = character:WaitForChild("Humanoid"), character:WaitForChild("HumanoidRootPart")
	if config.utils.fastRespawn then
		if diedConnection then diedConnection:Disconnect() end
		diedConnection = humanoid.Died:Connect(respawnSelf)
		humanoid:ChangeState(Enum.HumanoidStateType.Running)
	end
end)
runService.Heartbeat:Connect(function()
	if humanoid then
		humanoid.WalkSpeed, humanoid.JumpPower = config.walkSpeed, config.jumpPower
	end
end)
oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
	local message = ...
	local namecallMethod = getnamecallmethod()

	if (not checkcaller() and (self.ClassName == "RemoteEvent" and self.Name == "SayMessageRequest") and namecallMethod == "FireServer") and (message and string.match(message, "^/")) then
		chatted.Fire(chatted, message)
		return
	end
	return oldNamecall(self, ...)
end))
msgNotify("v0.1.1 loaded, enjoy!"); respawnSelf()
