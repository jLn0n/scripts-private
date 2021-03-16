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
local MeleeEvent = RepStorage:FindFirstChild("meleeEvent")
local TeamEvent = Workspace.Remote:FindFirstChild("TeamEvent")
-- // VARIABLES
local rad = math.rad
local TargetHRP
local killWL = {}
local oldCharPos, Tplr
local isPlrWl = false
local sformat = string.format
local zRot = -360
local WalkSpeed, JumpPower = 16, 50
-- // MAIN
HRP.Transparency = .5
local KillPlr = function(plr)
    if plr then
        TargetHRP = plr.Character:FindFirstChild("HumanoidRootPart")
        for wlName, isWl in pairs(killWL) do
            if plr.Name == wlName and isWl then
                TargetHRP = nil
                isPlrWl = true
                break
            end
        end
        if not TargetHRP.Parent:FindFirstChildWhichIsA("ForceField") and TargetHRP then
            Camera.CameraSubject = plr.Character.Humanoid
            for _ = 1, 100 do wait()
                if plr.Character.Humanoid.Health == 0 or isPlrWl then
                    break
                else
                    MeleeEvent:FireServer(plr)
                end
            end
            TargetHRP = nil
        else
            TargetHRP = nil
        end
    end
    isPlrWl = false
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
local KillFinished = function()
    HRP.CFrame = oldCharPos or CFrame.new(0, 150, 0)
    Humanoid:ChangeState(Enum.HumanoidStateType.Running)
    Camera.CameraSubject = Humanoid
    TeamEvent:FireServer("Bright orange")
end
Player.CharacterAdded:Connect(function(char)
    HRP, Humanoid, TargetHRP = nil, nil, nil
    wait(1)
    HRP = char.HumanoidRootPart
    HRP.Transparency = .5
    Humanoid = char.Humanoid
    Camera.CameraSubject = char.Humanoid
end)
RunService:BindToRenderStep("Naem_GOTYABEBEKOH", math.huge, function()
    if HRP and TargetHRP and TargetHRP.CFrame and TargetHRP.Parent.Humanoid.Health ~= 0 then
        HRP.CFrame = TargetHRP.CFrame * CFrame.new(Vector3.new(0, -4, 0)) * CFrame.Angles(rad(90), 0, rad(zRot))
        Humanoid:ChangeState(Enum.HumanoidStateType.Ragdoll)
        if zRot == 360 then
            zRot = -360
        else
            zRot += 5
        end
    else
        TargetHRP = nil
    end
    if Humanoid then
        Humanoid.WalkSpeed = WalkSpeed
        Humanoid.JumpPower = JumpPower
    end
end)
Player.Chatted:Connect(function(chat)
    local chatBody = string.split(chat, " ")
    if chatBody[1] == "/e" then
        if chatBody[2] == "wl" or chatBody[2] == "whitelist" then
            Tplr = FindPlyrFromString(chatBody[3])
            if Tplr then
                killWL[Tplr.Name] = true
                CreateMessage(sformat("Added %s to the kill whitelist.", Tplr.Name))
            else
                CreateMessage("Cannot find player.")
            end
        elseif chatBody[2] == "bl" or chatBody[2] == "blacklist" then
            Tplr = FindPlyrFromString(chatBody[3])
            if Tplr then
                killWL[Tplr.Name] = false
                CreateMessage(sformat("Removed %s to the kill whitelist.", Tplr.Name))
            else
                CreateMessage("Cannot find player.")
            end
        elseif chatBody[2] == "kill" then
            for _ = 1, 3 do oldCharPos = HRP.CFrame end
            if chatBody[3] == "all" then
                for _, player in pairs(Players:GetPlayers()) do
                    if player.Name ~= Player.Name then
                        if player and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health ~= 0 then
                            pcall(KillPlr, player)
                        end
                    end
                end
                KillFinished()
                CreateMessage("All players has been killed.")
            elseif chatBody[3] == "cops" or chatBody[3] == "guards" then
                for _, player in pairs(Players:GetPlayers()) do
                    if player.Name ~= Player.Name then
                        if player and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health ~= 0 and player.TeamColor.Name == "Bright blue" then
                            pcall(KillPlr, player)
                        end
                    end
                end
                KillFinished()
                CreateMessage("All cops/guards has been killed.")
            elseif chatBody[3] == "crims" or chatBody[3] == "criminals" then
                for _, player in pairs(Players:GetPlayers()) do
                    if player.Name ~= Player.Name then
                        if player and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health ~= 0 and player.TeamColor.Name == "Really red" then
                            pcall(KillPlr, player)
                        end
                    end
                end
                KillFinished()
                CreateMessage("All criminals has been killed.")
            elseif chatBody[3] == "inmates" or chatBody[3] == "prisoners" then
                for _, player in pairs(Players:GetPlayers()) do
                    if player.Name ~= Player.Name then
                        if player and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health ~= 0 and player.TeamColor.Name == "Bright orange"  then
                            pcall(KillPlr, player)
                        end
                    end
                end
                KillFinished()
                CreateMessage("")
            else
                Tplr = FindPlyrFromString(chatBody[3])
                if Tplr and Tplr.Name ~= Player.Name then
                    pcall(KillPlr, Tplr)
                    KillFinished()
                    CreateMessage(sformat("Successfully killed %s.", Tplr.Name))
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
        elseif chatBody[2] == "tp" or chatBody[2] == "teleport" then
            Tplr = FindPlyrFromString(chatBody[3])
            if Tplr and Tplr ~= Player.Name then
                if HRP and Humanoid.Health ~= 0 and Tplr.Character:FindFirstChild("HumanoidRootPart") then
                    HRP.CFrame = Tplr.Character.HumanoidRootPart.CFrame * CFrame.new(Vector3.new(0, 0, 4))
                end
                CreateMessage("Teleported to %s.", Tplr.Name)
            else
                CreateMessage("Can't find player.")
            end
        end
    end
    oldCharPos, Tplr = nil, nil
end)
CreateMessage("Crappy commands has been loaded! \nThanks for using crappy commands!")
