-- services
local players = game:GetService("Players")
local runService = game:GetService("RunService")
-- objects
local player = players.LocalPlayer
-- variables
local scanRange = 25
-- main
if _G.CHAOS_killAura then _G.CHAOS_killAura:Disconnect() end
local function getNearestPlr(hrp)
	if not hrp then return end
	local nearPlrs = table.create(0)
	for _, plr in ipairs(players:GetPlayers()) do
		if plr == player then continue end
		local p_hrp = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") or nil
		if not p_hrp then continue end
		local distance = (hrp.Position - p_hrp.Position).Magnitude
		if distance < scanRange then
			table.insert(nearPlrs, {
				plr = plr,
				dist = distance
			})
		end
	end
	table.sort(nearPlrs, function(x, y)
		return (x.dist < y.dist)
	end)
	return (nearPlrs and #nearPlrs ~= 0) and nearPlrs[1].plr or nil
end
local function killAura()
	local character = player.Character
	local hrp = character and character:FindFirstChild("HumanoidRootPart") or nil
	local nearestPlr = getNearestPlr(hrp)
	if (not nearestPlr and character) then return end
	local toolEquipped = character:FindFirstChildWhichIsA("Tool")
	local dmgEvent = toolEquipped and toolEquipped:FindFirstChild("DamageRemote")
	local nearestPlrHum = nearestPlr.Character:FindFirstChildWhichIsA("Humanoid")
	if nearestPlrHum and toolEquipped and dmgEvent then
		dmgEvent:FireServer(nearestPlrHum)
	end
end
_G.CHAOS_killAura = runService.Heartbeat:Connect(killAura)
