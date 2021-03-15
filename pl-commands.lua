-- // SERVICES
local Players = game:GetService("Players")
local RepStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local Workspace = game.Workspace
-- // OBJECTS
local Player = Players.LocalPlayer
local HRP = Player.Character.HumanoidRootPart
local Humanoid = Player.Character.Humanoid
local MeleeEvent = RepStorage:FindFirstChild("meleeEvent")
local TeamEvent = Workspace.Remote:FindFirstChild("TeamEvent")
-- // VARIABLES
local rad = math.rad
local TargetHRP
local killWL = {}
local oldCharPos
local isPlrWl = false
local WalkSpeed, JumpPower = 16, 50
local sformat = string.format
local Tplr, LoopkillTarget
local zRot = 0
-- // MAIN
HRP.Transparency = .75
local KillPlr = function(plr)
    TargetHRP = plr.Character.HumanoidRootPart
    for wlName, isWl in pairs(killWL) do
        if plr.Name == wlName and isWl then
            TargetHRP = nil
            isPlrWl = true
            break
        end
    end
    if not TargetHRP.Parent:FindFirstChildWhichIsA("ForceField") then
        for _ = 1, 100 do coroutine.yield()
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
    isPlrWl = false
end
local FindPlyrFromString = function(str)
    for _, player in pairs(game:GetService("Players"):GetPlayers()) do
		if string.sub(string.lower(player.Name), 0, string.len(str)) == string.lower(str) then
			if player:IsA("Player") and player ~= nil then
				return player
			end
		end
	end
end
local KilledFinished = function()
    if HRP and Humanoid then
        HRP.CFrame = oldCharPos
        Humanoid:ChangeState(Enum.HumanoidStateType.Running)
    end
    TeamEvent:FireServer("Bright orange")
end
local MakeFakeMsg = function(text, color)
    StarterGui:SetCore("ChatMakeSystemMessage", {
        Text = text,
        Color = color,
        Font = Enum.Font.SourceSansBold,
        FontSize = Enum.FontSize.Size32
    })
end
Player.CharacterAdded:Connect(function(char)
    HRP, Humanoid, TargetHRP = nil, nil, nil
    wait(1)
    HRP = char.HumanoidRootPart
    HRP.Transparency = .75
    Humanoid = char.Humanoid
end)
RunService:BindToRenderStep("Naem_GOTYABEBEKOH", math.huge, function()
    if HRP and TargetHRP and TargetHRP.Parent.Humanoid.Health ~= 0 then
        HRP.CFrame = TargetHRP.CFrame * CFrame.new(Vector3.new(0, -3.95, 0)) * CFrame.Angles(rad(90), 0, rad(zRot))
    else
        TargetHRP = nil
    end
    if Humanoid then
        Humanoid.WalkSpeed = WalkSpeed
        Humanoid.JumpPower = JumpPower
    end
    if zRot ~= 360 then
        zRot += 5
    else
        zRot = -360
    end
end)
Player.Chatted:Connect(function(chat)
    local chatBody = string.split(chat, " ")
    if chatBody[1] == "/e" then
        if chatBody[2] == "wl" then
            Tplr = FindPlyrFromString(chatBody[3])
            if Tplr then
                killWL[Tplr.Name] = true
                MakeFakeMsg(sformat("Added %s to whitelist.", Tplr.Name))
            else
                MakeFakeMsg("Can't find player.")
            end
        elseif chatBody[2] == "bl" then
            Tplr = FindPlyrFromString(chatBody[3])
            if Tplr then
                killWL[Tplr.Name] = false
                MakeFakeMsg(sformat("Removed %s to whitelist.", Tplr.Name))
            else
                MakeFakeMsg("Can't find player.")
            end
        elseif chatBody[2] == "kill" then
            oldCharPos = HRP.CFrame
            if chatBody[3] == "all" then
                for _, player in pairs(Players:GetPlayers()) do
                    if player.Name ~= Player.Name then
                        if player and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health ~= 0 then
                            pcall(KillPlr, player)
                        end
                    end
                end
                KilledFinished()
                MakeFakeMsg("All players has been killed.")
            elseif chatBody[3] == "cops" or chatBody[3] == "guards" then
                for _, player in pairs(Players:GetPlayers()) do
                    if player.Name ~= Player.Name then
                        if player and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health ~= 0 and player.TeamColor.Name == "Bright blue" then
                            pcall(KillPlr, player)
                        end
                    end
                end
                KilledFinished()
                MakeFakeMsg("All cops/guards has been killed.")
            elseif chatBody[3] == "crims" or chatBody[3] == "criminal" then
                for _, player in pairs(Players:GetPlayers()) do
                    if player.Name ~= Player.Name then
                        if player and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health ~= 0 and player.TeamColor.Name == "Really red" then
                            pcall(KillPlr, player)
                        end
                    end
                end
                KilledFinished()
                MakeFakeMsg("All criminals has been killed.")
            elseif chatBody[3] == "inmate" or chatBody[3] == "prisoner" then
                for _, player in pairs(Players:GetPlayers()) do
                    if player.Name ~= Player.Name then
                        if player and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health ~= 0 and player.TeamColor.Name == "Bright orange"  then
                            pcall(KillPlr, player)
                        end
                    end
                end
                KilledFinished()
                MakeFakeMsg("All inmates/prisoners has been killed.")
            else
                pcall(KillPlr, FindPlyrFromString(chatBody[3]))
                KilledFinished()
            end
        elseif chatBody[2] == "ws" then
            pcall(function() chatBody[3] = tonumber(chatBody[3]) end)
            if type(chatBody[3]) == "number" then
                WalkSpeed = chatBody[3]
                MakeFakeMsg(sformat("Walkspeed has been changed to %s."), tostring(chatBody[3]))
            else
                MakeFakeMsg("Arg 2 should be a number.")
            end
        elseif chatBody[2] == "jp" then
            pcall(function() chatBody[3] = tonumber(chatBody[3]) end)
            if type(chatBody[3]) == "number" then
                JumpPower = chatBody[3]
                MakeFakeMsg(sformat("JumpPower has been changed to %s."), tostring(chatBody[3]))
            else
                MakeFakeMsg("Arg 2 should be a number.")
            end
        elseif chatBody[2] == "tpto" then
            Tplr = FindPlyrFromString(chatBody[3])
            if Tplr then
                if HRP and Humanoid.Health ~= 0 and Tplr.Character:FindFirstChild("HumanoidRootPart") then
                    HRP.CFrame = Tplr.Character.HumanoidRootPart.CFrame * CFrame.new(Vector3.new(0, 0, 4))
                end
                MakeFakeMsg("Teleported succesfully.")
            else
                MakeFakeMsg("Can't find player.")
            end
        end
    end
end)