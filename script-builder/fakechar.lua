-- TODO: combine all runservice loops for "refitter"
-- TODO: reallocate char_models when models are destroyed or lacking

local players = game:GetService("Players")
local runService = game:GetService("RunService")

local void_cframe = CFrame.identity + (Vector3.xAxis * 9e10)

local remotes = {
    send_position = Instance.new("UnreliableRemoteEvent")
}
local character_data = {
    current_pos = CFrame.identity + (Vector3.yAxis * 20),
    current_char = nil
}

-- functions

-- init
owner.Character.Parent = nil
local part_char = Instance.new("Part")
part_char.Anchored = true
part_char.CanCollide = false
part_char.Size = Vector3.new(2, 2, 1)
print("character initialized")

local client_script = NLS([[
print("client waiting")
repeat task.wait() until script:GetAttribute("initialized")
local runService = game:GetService("RunService")

local remotes = {}
for _, remote in ipairs(script:GetChildren()) do
    remotes[remote.Name] = remote
end

local root_part = owner.Character.HumanoidRootPart
root_part.Transparency = 0.5
root_part.CanCollide = true
root_part.RootJoint:Destroy()
owner.Character.Parent = workspace
owner.Character.Torso.CFrame = CFrame.identity + (Vector3.one * 9e9)

local accumulated_time = 0
runService.Stepped:Connect(function(delta)
    if accumulated_time < 1/15 then
        accumulated_time = accumulated_time + delta
        return
    end
    accumulated_time = 0
    remotes.send_position:FireServer(root_part.CFrame)
end)

script.Destroying:Connect(function()
    owner.Character:Destroy()
end)
print("client initialized")
]])
print("client ran")

for remote_name, remote_obj in remotes do
    remote_obj.Name = remote_name
    remote_obj.Parent = client_script
end
client_script:SetAttribute("initialized", true)
print("remote initialized")

-- main
remotes.send_position.OnServerEvent:Connect(function(_player, new_pos)
    if _player.UserId ~= owner.UserId then return end

    character_data.current_pos = new_pos
end)

runService.Stepped:Connect(function(delta_time)
    if character_data.current_char then
        character_data.current_char:Destroy()
    end

    local old_part_CFrame = (if character_data.current_char then character_data.current_char.CFrame else character_data.current_pos)
    local current_part = part_char:Clone()
    current_part.CFrame = old_part_CFrame:Lerp(character_data.current_pos, math.min(delta_time / (240 / 60), 1))
    current_part.Parent = script
    character_data.current_char = current_part
end)