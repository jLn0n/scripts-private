-- services
local runService = game:GetService("RunService")
local players = game:GetService("Players")
-- objects
local camera = workspace.CurrentCamera
local player = players.LocalPlayer
local mouse = player:GetMouse()
local fovCircle, targetBox = Drawing.new("Circle"), Drawing.new("Square")
-- variables
local oldNamecall, nearestPlr
local settings = {
	visibleCheck = false,
	fov = 175,
	knockdownCheck = true
}
-- functions
local function checkPlr(plrArg)
	local plrHumanoid = plrArg.Character:FindFirstChild("Humanoid")
	return plrArg ~= player and (plrArg.Neutral or plrArg.TeamColor ~= player.TeamColor) and (plrArg.Character and (plrHumanoid and plrHumanoid.Health ~= 0) and not plrArg.Character:FindFirstChildWhichIsA("ForceField")) and not (settings.knockdownCheck and plrArg.Character:FindFirstChild("Downed") or false)
end
local function inLineOfSite(originPos, ...)
	return #camera:GetPartsObscuringTarget({originPos}, {camera, player.Character, ...}) == 0
end
local function getNearestPlrByCursor()
	local nearestPlrData = {aimPart = nil, dist = math.huge}

	for _, plr in ipairs(players:GetPlayers()) do
		local p_dPart = (plr.Character and plr.Character:FindFirstChild("Head"))
		if not p_dPart then continue end
		local posVec3, onScreen = camera:WorldToViewportPoint(p_dPart.Position)
		local mouseVec2, posVec2 = Vector2.new(mouse.X, mouse.Y + 36), Vector2.new(posVec3.X, posVec3.Y)
		local fovDist = (mouseVec2 - posVec2).Magnitude

		if checkPlr(plr) and (not settings.visibleCheck or (onScreen and inLineOfSite(p_dPart.Position, plr.Character))) then
			if (fovDist <= settings.fov) and (fovDist < nearestPlrData.dist) then
				nearestPlrData.aimPart = p_dPart
				nearestPlrData.dist = fovDist
			end
		end
	end
	return (if nearestPlrData.aimPart then nearestPlrData else nil)
end
-- main
targetBox.Color = Color3.fromRGB(0, 185, 35)
targetBox.Filled = true
targetBox.Size = Vector2.new(20, 20)
targetBox.Thickness = 20
targetBox.Transparency = .6

fovCircle.Color = Color3.fromRGB(0, 185, 35)
fovCircle.Thickness = 2
fovCircle.Transparency = .6
fovCircle.Visible = true

runService.Heartbeat:Connect(function()
	nearestPlr = getNearestPlrByCursor()

	fovCircle.Radius = settings.fov
	fovCircle.Position = Vector2.new(mouse.X, mouse.Y + 36)

	if nearestPlr then
		local posVec3, onScreen = camera:WorldToViewportPoint(nearestPlr.aimPart.Position)

		targetBox.Visible = onScreen
		targetBox.Position = (Vector2.new(posVec3.X, posVec3.Y) - (targetBox.Size / 2))
	else
		targetBox.Visible = false
		targetBox.Position = Vector3.zero
	end
end)

oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
	local args = {...}
	local namecallMethod = getnamecallmethod()

	if not checkcaller() then
		if (namecallMethod == "FireServer" and self.Name == "RemoteEvent") and nearestPlr then
			if args[1] == "BulletHit" then
				args[2] = nearestPlr.aimPart.Position
				args[5] = nearestPlr.aimPart
			elseif args[1] == "FireGun" then -- idk why i added this
				args[2] = nearestPlr.aimPart.Position
			end
		end
	end
	return oldNamecall(self, unpack(args))
end))
