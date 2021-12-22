-- services
local players = game:GetService("Players")
local repStorage = game:GetService("ReplicatedStorage")
local runService = game:GetService("RunService")
-- objects
local player = players.LocalPlayer
local humanoid = player.Character:FindFirstChildWhichIsA("Humanoid")
-- events
local punch, shoot, reload, itemGive, teamChange, loadChar =
	repStorage:FindFirstChild("meleeEvent"),
	repStorage:FindFirstChild("ShootEvent"),
	repStorage:FindFirstChild("ReloadEvent"),
	workspace.Remote:FindFirstChild("ItemHandler"),
	workspace.Remote:FindFirstChild("TeamEvent"),
	workspace.Remote:FindFirstChild("loadchar")
-- variables
local killAll_hrpTarget
local killWl = table.create(0)
local killMethod = 1
local walkSpeed, jumpPower = 16, 50
-- functions
local function killPlr(arg1)
	if killMethod == 1 then
		if typeof(arg1) == "table" then
			for _, plr in ipairs(arg1) do
				killAll_hrpTarget = plr.Character:FindFirstChild("HumanoidRootPart")
				if killAll_hrpTarget and not plr.Character:FindFirstChildWhichIsA("ForceField") then
					for _ = 1, 100 do
						if plr.Character.Humanoid.Health == 0 then break end
						punch:FireServer(plr)
					end
				end
			end
		else
			killAll_hrpTarget = arg1.Character:FindFirstChild("HumanoidRootPart")
			if killAll_hrpTarget and not arg1.Character:FindFirstChildWhichIsA("ForceField") then
				for _ = 1, 100 do
					if arg1.Character.Humanoid.Health == 0 then break end
					punch:FireServer(arg1)
				end
			end
		end
		killAll_hrpTarget = nil
	elseif killMethod == 2 then
		if not humanoid then return end
		teamChange:FireServer("Medium stone grey")
		itemGive:InvokeServer(workspace.Prison_ITEMS.giver.M9.ITEMPICKUP)
		local gunObj = player.Backpack:FindFirstChild("M9")
		local shootings = table.create(0)
		if typeof(arg1) == "table" then
			for _, plr in ipairs(arg1) do
				local targetPart = plr.Character and plr.Character:FindFirstChild("Head") or nil
				if not targetPart or killWl[plr.Name] then continue end
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
		shoot:FireServer(shootings, gunObj)
		reload:FireServer(gunObj)
		teamChange:FireServer("Bright orange")
	end
end
local function stringFindPlayer(strArg)
	strArg = string.lower(strArg)
	local result = table.create(0)
	if (strArg == "cops" or strArg == "guards") or (strArg == "crims" or strArg == "criminals") or (strArg == "inmates" or strArg == "prisoners") then
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
			if atMatch then
				strArg = string.gsub(strArg, atMatch, "", 1)
				if string.sub(string.lower(plr.Name), 0, string.len(strArg)) == strArg then
					return plr == player and nil or plr
				end
			else
				if string.sub(string.lower(plr.DisplayName), 0, string.len(strArg)) == strArg then
					return plr == player and nil or plr
				end
			end
		end
	end
end
-- main
runService.Heartbeat:Connect(function()
	humanoid = player.Character and player.Character:FindFirstChildWhichIsA("Humanoid") or nil
	if killAll_hrpTarget and killAll_hrpTarget.Parent.Humanoid.Health ~= 0 then
		rnet.sendposition(killAll_hrpTarget.Position - Vector3.new(0, 4))
	end
	if humanoid then
		humanoid.WalkSpeed = walkSpeed
		humanoid.JumpPower = jumpPower
	end
end)
player.Chatted:Connect(function(msg)
	msg = string.lower(msg)
	local prefixMatch = string.match(msg, "^/") or string.match(msg, "^/e")

	if prefixMatch then
		msg = string.gsub(msg, prefixMatch, "", 1)
		local args = table.create(0)
		for arg in string.gmatch(msg, "[^%s]+") do
			table.insert(args, arg)
		end

		if args[1] == "kill" then
			if args[2] == "all" then
				if killMethod == 2 then
					killPlr(players:GetPlayers())
				else
					for _, plr in ipairs(players:GetPlayers()) do
						if plr ~= player and plr.Character then
							killPlr(plr)
						end
					end
				end
			else
				local targetPlr = stringFindPlayer(args[2])
				if targetPlr then
					killPlr(targetPlr)
				end
			end
		elseif args[1] == "killmethod" then
			killMethod = (args[2] == "punch" and 1 or args[2] == "gun" and 2 or 1)
		elseif args[1] == "kill-wl" then
			local targetPlr = stringFindPlayer(args[2])
			if targetPlr then
				killWl[targetPlr.Name] = true
			end
		elseif args[1] == "kill-bl" then
			local targetPlr = stringFindPlayer(args[2])
			if targetPlr then
				killWl[targetPlr.Name] = false
			end
		elseif args[1] == "goto" then
			local targetPlr = stringFindPlayer(args[2])
			if targetPlr then
				if (player.Character and player.Character:FindFirstChild("HumanoidRootPart")) and (humanoid and humanoid.Health ~= 0) and targetPlr.Character:FindFirstChild("HumanoidRootPart") then
					player.Character.HumanoidRootPart.CFrame = targetPlr.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 2)
				end
			end
		end
	end
end)
