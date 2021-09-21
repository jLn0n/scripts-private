-- // SERVICES
local Players = game:GetService("Players")
local RepStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local Workspace = game.Workspace
-- // OBJECTS
local Camera = Workspace.CurrentCamera
local Player = Players.LocalPlayer
local HRP = Player.Character.HumanoidRootPart
local Humanoid = Player.Character.Humanoid
local ShootEvent, ReloadEvent, ItemHandler, TeamEvent =
	RepStorage.ShootEvent,
	RepStorage.ReloadEvent,
	Workspace.Remote.ItemHandler,
	Workspace.Remote.TeamEvent
-- // VARIABLES
local TargetPlr
local sformat = string.format
local WalkSpeed, JumpPower = 16, 50
-- // MAIN
ItemHandler:InvokeServer(workspace.Prison_ITEMS.giver["Remington 870"].ITEMPICKUP)
for _, module in next, getloadedmodules() do
	if module.Name == "GunStates" and module.Parent == Player.Backpack then
		module = require(module)
		module.MaxAmmo = math.huge
		module.CurrentAmmo = math.huge
	end
end
local KillPlr = function(targetPlr)
	if targetPlr and targetPlr.Character then
		local aFuckingGun = Player.Backpack:FindFirstChild("Remington 870")
		local remote_args = {
			[1] = {
				[1] = {
					["RayObject"] = Ray.new(aFuckingGun.Muzzle.Position, targetPlr.Character.Head.Position + Vector3.new(0, math.random(.1, 1))),
					["Distance"] = (HRP.Position - targetPlr.Character.HumanoidRootPart.Position).Magnitude,
					["Cframe"] = targetPlr.Character.Head.CFrame,
					["Hit"] = targetPlr.Character.Head
				},
				[2] = {
					["RayObject"] = Ray.new(aFuckingGun.Muzzle.Position, targetPlr.Character.Head.Position + Vector3.new(0, math.random(.1, 1))),
					["Distance"] = (HRP.Position - targetPlr.Character.HumanoidRootPart.Position).Magnitude,
					["Cframe"] = targetPlr.Character.Head.CFrame,
					["Hit"] = targetPlr.Character.Head
				},
				[3] = {
					["RayObject"] = Ray.new(aFuckingGun.Muzzle.Position, targetPlr.Character.Head.Position + Vector3.new(0, math.random(.1, 1))),
					["Distance"] = (HRP.Position - targetPlr.Character.HumanoidRootPart.Position).Magnitude,
					["Cframe"] = targetPlr.Character.Head.CFrame,
					["Hit"] = targetPlr.Character.Head
				},
				[4] = {
					["RayObject"] = Ray.new(aFuckingGun.Muzzle.Position, targetPlr.Character.Head.Position + Vector3.new(0, math.random(.1, 1))),
					["Distance"] = (HRP.Position - targetPlr.Character.HumanoidRootPart.Position).Magnitude,
					["Cframe"] = targetPlr.Character.Head.CFrame,
					["Hit"] = targetPlr.Character.Head
				},
				[5] = {
					["RayObject"] = Ray.new(aFuckingGun.Muzzle.Position, targetPlr.Character.Head.Position + Vector3.new(0, math.random(.1, 1))),
					["Distance"] = (HRP.Position - targetPlr.Character.HumanoidRootPart.Position).Magnitude,
					["Cframe"] = targetPlr.Character.Head.CFrame,
					["Hit"] = targetPlr.Character.Head
				},
			},
			[2] = aFuckingGun
		}
		ShootEvent:FireServer(table.unpack(remote_args))
		ReloadEvent:FireServer(aFuckingGun)
	end
	wait()
end
local FindPlyrFromString = function(str)
	for _, player in pairs(game:GetService("Players"):GetPlayers()) do
		if string.sub(string.lower(player.Name), 0, string.len(str)) == string.lower(str) then
			if player:IsA("Player") and player.Name ~= Player.Name and player ~= nil then
				return player
			end
		end
	end
end
local CreateMessage = function(text)
	StarterGui:SetCore("ChatMakeSystemMessage", {
		Text = text,
		Color = Color3.fromRGB(255, 255, 255),
		Font = Enum.Font.SourceSansBold,
		FontSize = Enum.FontSize.Size32,
	})
end
Player.CharacterAdded:Connect(function(char)
	wait()
	ItemHandler:InvokeServer(workspace.Prison_ITEMS.giver.M9.ITEMPICKUP)
	for _, module in next, getloadedmodules() do
		if module.Name == "GunStates" and module.Parent == Player.Backpack then
			module = require(module)
			module.MaxAmmo = math.huge
			module.CurrentAmmo = math.huge
		end
	end
	HRP = char.HumanoidRootPart
	Humanoid = char.Humanoid
	Camera.CameraSubject = char.Humanoid
end)
RunService:BindToRenderStep("Naem_GOTYABEBEKOH", math.huge, function()
	if Humanoid then
		Humanoid.WalkSpeed = WalkSpeed
		Humanoid.JumpPower = JumpPower
	end
end)
Player.Chatted:Connect(function(chat)
	local chatBody = string.split(chat, " ")
	if chatBody[1] == "/e" then
		if chatBody[2] == "kill" then
			if chatBody[3] == "all" then
				TeamEvent:FireServer("Medium stone grey")
				for _, player in pairs(Players:GetPlayers()) do
					if player.Name ~= Player.Name then
						if player and player.Character and player.Character:FindFirstChild("Humanoid") then
							KillPlr(player)
						end
					end
				end
				TeamEvent:FireServer("Bright orange")
				CreateMessage("All players has been killed.")
			elseif chatBody[3] == "cops" or chatBody[3] == "guards" then
				TeamEvent:FireServer("Medium stone grey")
				for _, player in pairs(Players:GetPlayers()) do
					if player.Name ~= Player.Name then
						if player and player.Character and player.Character:FindFirstChild("Humanoid") and  player.TeamColor.Name == "Bright blue" then
							KillPlr(player)
						end
					end
				end
				TeamEvent:FireServer("Bright orange")
				CreateMessage("All cops/guards has been killed.")
			elseif chatBody[3] == "crims" or chatBody[3] == "criminals" then
				TeamEvent:FireServer("Medium stone grey")
				for _, player in pairs(Players:GetPlayers()) do
					if player.Name ~= Player.Name then
						if player and player.Character and player.Character:FindFirstChild("Humanoid") and  player.TeamColor.Name == "Really red" then
							KillPlr(player)
						end
					end
				end
				TeamEvent:FireServer("Bright orange")
				CreateMessage("All criminals has been killed.")
			elseif chatBody[3] == "inmates" or chatBody[3] == "prisoners" then
				TeamEvent:FireServer("Medium stone grey")
				for _, player in pairs(Players:GetPlayers()) do
					if player.Name ~= Player.Name then
						if player and player.Character and player.Character:FindFirstChild("Humanoid") and  player.TeamColor.Name == "Bright orange"  then
							KillPlr(player)
						end
					end
				end
				TeamEvent:FireServer("Bright orange")
				CreateMessage("All inmates/prisoners has been killed.")
			else
				TargetPlr = FindPlyrFromString(chatBody[3])
				if TargetPlr and TargetPlr.Name ~= Player.Name then
					TeamEvent:FireServer("Medium stone grey")
					pcall(KillPlr, TargetPlr)
					TeamEvent:FireServer("Bright orange")
					CreateMessage(sformat("Successfully killed %s.", TargetPlr.Name))
				else
					CreateMessage("Cannot find player.")
				end
			end
		elseif chatBody[2] == "ws" or chatBody[2] == "walkspeed" then
			local succ, _ = pcall(function() chatBody[3] = tonumber(chatBody[3]) end)
			if succ then
				WalkSpeed = chatBody[3]
				CreateMessage(sformat("Successfully changed walkspeed to %s", tostring(chatBody[3])))
			else
				CreateMessage("Argument 2 should be a number.")
			end
		elseif chatBody[2] == "jp" or chatBody[2] == "jumppower" then
			local succ, _ = pcall(function() chatBody[3] = tonumber(chatBody[3]) end)
			if succ then
				JumpPower = chatBody[3]
				CreateMessage(sformat("Successfully changed jumppower to %s", tostring(chatBody[3])))
			else
				CreateMessage("Argument 2 should be a number.")
			end
		elseif chatBody[2] == "goto" then
			TargetPlr = FindPlyrFromString(chatBody[3])
			if TargetPlr and TargetPlr ~= Player.Name then
				if HRP and Humanoid.Health ~= 0 and TargetPlr.Character:FindFirstChild("HumanoidRootPart") then
					HRP.CFrame = TargetPlr.Character.HumanoidRootPart.CFrame * CFrame.new(Vector3.new(0, 0, 4))
				end
				CreateMessage(sformat("Teleported to %s", TargetPlr.Name))
			else
				CreateMessage("Can't find player.")
			end
		end
	end
	TargetPlr = nil
end)
CreateMessage("Crappy commands has been loaded! \nThanks for using crappy commands!")
