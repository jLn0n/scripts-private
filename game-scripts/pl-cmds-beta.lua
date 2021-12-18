-- services
local players = game:GetService("Players")
local repStorage = game:GetService("ReplicatedStorage")
local runService = game:GetService("RunService")
-- objects
local player = players.LocalPlayer
local humanoid = player.Character:FindFirstChildWhichIsA("Humanoid")
local camera = workspace.CurrentCamera
-- events
local melee = repStorage:FindFirstChild("meleeEvent")
local teamChange = workspace.Remote:FindFirstChild("TeamEvent")
local itemHandler = workspace.Remote:FindFirstChild("ItemHandler")
-- variables
local killAll_hrpTarget
local killWl = table.create(0)
local walkSpeed, jumpPower = 16, 50
-- functions
local function killPlr(targetPlr)
	if not targetPlr or killWl[targetPlr.Name] then return end
	killAll_hrpTarget = targetPlr.Character:FindFirstChild("HumanoidRootPart")
	if killAll_hrpTarget and not targetPlr.Character:FindFirstChildWhichIsA("ForceField") and targetPlr.Character:FindFirstChildWhichIsA("Humanoid") then
		itemHandler:InvokeServer(workspace.Prison_ITEMS.single:FindFirstChild("Crude Knife").ITEMPICKUP)
		for _ = 1, 100 do
			if targetPlr.Character.Humanoid.Health == 0 then break end
			melee:FireServer(targetPlr)
		end
	end
	killAll_hrpTarget = nil
end
local function stringFindPlayer(str)
	for _, plr in ipairs(players:GetPlayers()) do
		local atMatch = string.match(str, "^@")
		if atMatch then
			str = string.gsub(str, atMatch, "", 1)
			if string.sub(string.lower(plr.Name), 0, string.len(str)) == string.lower(str) then
				return plr == player and nil or plr
			end
		else
			if string.sub(string.lower(plr.DisplayName), 0, string.len(str)) == string.lower(str) then
				return plr == player and nil or plr
			end
		end
	end
end
local function getPlayers()
	local plrsTable = players:GetPlayers()
	table.sort(plrsTable, function(plr1, plr2)
		local plr1Char, plr2Char = plr1.Character, plr2.Character
		local plr1Count, plr2Count = 0, 0
		plr1Count = not plr1Char:FindFirstChildWhichIsA("Humanoid") and plr1Count or plr1Count + 1
		plr2Count = not plr2Char:FindFirstChildWhichIsA("Humanoid") and plr2Count or plr2Count + 1
		plr1Count = not plr1Char:FindFirstChildWhichIsA("ForceField") and plr1Count or plr1Count + 1
		plr2Count = not plr2Char:FindFirstChildWhichIsA("ForceField") and plr2Count or plr2Count + 1
		return (plr1Count < plr2Count)
	end)
	return plrsTable
end
-- main
runService.Heartbeat:Connect(function()
	if killAll_hrpTarget and killAll_hrpTarget.Parent.Humanoid.Health ~= 0 then
		rnet.sendposition(killAll_hrpTarget.Position - Vector3.new(0, 4))
	end
	if humanoid then
		humanoid.WalkSpeed = walkSpeed
		humanoid.JumpPower = jumpPower
	end
	humanoid = player.Character and player.Character:FindFirstChildWhichIsA("Humanoid") or nil
end)
player.Chatted:Connect(function(msg)
	msg = string.lower(msg)
	local prefixMatch = string.match(msg, "^/")

	if prefixMatch then
		msg = string.gsub(msg, prefixMatch, "", 1)
		local args = table.create(0)
		for arg in string.gmatch(msg, "[^%s]+") do
			table.insert(args, arg)
		end

		if args[1] == "kill" then
			if args[2] == "all" then
				for _, plr in ipairs(getPlayers()) do
					if plr ~= player and plr.Character then
						killPlr(plr)
					end
				end
			elseif (args[2] == "cops" or args[2] == "guards") or (args[2] == "crims" or args[2] == "criminals") or (args[2] == "inmates" or args[2] == "prisoners") then
				for _, plr in ipairs(getPlayers()) do
					if plr ~= player and plr.Character and plr.TeamColor.Name == (
						(args[2] == "cops" or args[2] == "guards") and "Bright blue" or
						(args[2] == "crims" or args[2] == "criminals") and "Really red" or
						(args[2] == "inmates" or args[2] == "prisoners") and "Bright orange" or nil
					) then
						killPlr(plr)
					end
				end
			else
				local targetPlr = stringFindPlayer(args[2])
				if targetPlr then
					killPlr(targetPlr)
				end
			end
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
					player.Character.HumanoidRootPart.CFrame = targetPlr.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 4)
				end
			end
		end
	end
end)
