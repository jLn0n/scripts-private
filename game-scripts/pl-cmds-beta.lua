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
local shoot, reload, itemGive, teamChange =
	repStorage:FindFirstChild("ShootEvent"),
	repStorage:FindFirstChild("ReloadEvent"),
	workspace.Remote:FindFirstChild("ItemHandler"),
	workspace.Remote:FindFirstChild("TeamEvent")
-- variables
local config = {
	["killConf"] = {
		["hrpTarget"] = nil,
		["killWl"] = table.create(0),
	},
	["utils"] = {
		["autoCriminal"] = false
	},
	["walkSpeed"] = 16,
	["jumpPower"] = 50
}
local currentKilling = false
-- functions
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
	currentKilling = true
	teamChange:FireServer("Medium stone grey")
	currentKilling = false
	shoot:FireServer(shootings, gunObj)
	reload:FireServer(gunObj)
	teamChange:FireServer("Bright orange")
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
local function autoCrim()
	if config.utils.autoCriminal and (player.Character and player.Character:FindFirstChild("HumanoidRootPart")) and not currentKilling then
		local spawnPart = workspace:FindFirstChild("Criminals Spawn"):FindFirstChildWhichIsA("SpawnLocation")
		firetouchinterest(player.Character.HumanoidRootPart, spawnPart, 0)
		firetouchinterest(player.Character.HumanoidRootPart, spawnPart, 1)
	end
end
local function cmdParse(msgString)
	msgString = string.lower(msgString)
	local prefixMatch = string.match(msgString, "^/e ") or string.match(msgString, "^/")

	if prefixMatch then
		msgString = string.gsub(msgString, prefixMatch, "", 1)
		local args = table.create(0)
		for arg in string.gmatch(msgString, "[^%s]+") do
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
		elseif args[1] == "kill-wl" then
			local targetPlr = stringFindPlayer(args[2])
			if targetPlr then
				config.killConf.killWl[targetPlr.Name] = true
				msgNotify(string.format("added %s to whitelist, he/she will not be killed anymore.", targetPlr.Name))
			end
		elseif args[1] == "kill-bl" then
			local targetPlr = stringFindPlayer(args[2])
			if targetPlr then
				config.killConf.killWl[targetPlr.Name] = false
				msgNotify(string.format("removed %s whitelist, player will be killed again.", targetPlr.Name))
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
			msgNotify(string.format("auto criminal is now %s.", (config.utils.autoCriminal and "on/enabled" or "off/disabled")))
			autoCrim()
		end
	end
end
-- main
player:GetPropertyChangedSignal("TeamColor"):Connect(autoCrim)
player.Chatted:Connect(cmdParse)
runService.Heartbeat:Connect(function()
	humanoid = player.Character and player.Character:FindFirstChildWhichIsA("Humanoid") or nil
	rootPart = player.Character and player.Character:FindFirstChild("HumanoidRootPart") or nil
	if humanoid then
		humanoid.WalkSpeed = config.walkSpeed
		humanoid.JumpPower = config.jumpPower
	end
end)
msgNotify("v0.1.1 loaded, enjoy!")
