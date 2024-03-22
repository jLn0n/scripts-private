local move_part = Instance.new("RemoteEvent")
move_part.Name = "move_part"
move_part.Parent = owner

local part = Instance.new("Part")
part.Anchored = true
part.CFrame = owner.Character:GetPivot()
part.Parent = workspace

move_part.OnServerEvent:Connect(function(_player, mouse_pos)
    if _player.UserId ~= owner.UserId then return end
    
    part.CFrame = mouse_pos
end)

local client_script = NLS([[
local player_mouse = owner:GetMouse()
local move_part = owner:FindFirstChild("move_part")

while true do task.wait(1/30)
    move_part:FireServer(player_mouse.Hit)
end
]])

script.Destroying:Connect(function()
    move_part:Destroy()
    part:Destroy()
    client_script:Destroy()
end)