-- settings
local settings = {
	fov = 175,
	visibleCheck = false,
	customHitPart = "Torso",
}
-- services
local inputService = game:GetService("UserInputService")
local repFirst = game:GetService("ReplicatedFirst")
local runService = game:GetService("RunService")
local players = game:GetService("Players")
-- imports
local pfRequire = getrenv().shared.require
local pfImports = {
	network = pfRequire("network"),
	values = pfRequire("PublicSettings"),
	replication = pfRequire("replication"),
	physics = require(repFirst.SharedModules.Old.Utilities.Math.physics:Clone())
}
-- objects
local camera = workspace.CurrentCamera
local player = players.LocalPlayer
local fovCircle, targetBox = Drawing.new("Circle"), Drawing.new("Square")
-- variables
local nearestPlr
local refs = table.create(0)
-- functions
local function checkPlr(plr)
	local plrChar = pfImports.replication.getbodyparts(plr)
	local plrTPart = (plrChar and plrChar.head)
	return plr ~= player and (plr.Neutral or plr.TeamColor ~= player.TeamColor), plrTPart
end
local function inLineOfSite(originPos, ...)
	return #camera:GetPartsObscuringTarget({originPos}, {camera, player.Character, ...}) == 0
end
local function getNearestPlrByCursor()
	local nearestPlrData = {aimPart = nil, dist = math.huge}

	for _, plr in players:GetPlayers() do
		local passed, plrTPart = checkPlr(plr)
		if not (passed and plrTPart) then continue end
		local posVec3, onScreen = camera:WorldToViewportPoint(plrTPart.Position)
		local fovDist = (inputService:GetMouseLocation() - Vector2.new(posVec3.X, posVec3.Y)).Magnitude

		if checkPlr(plr) and (not settings.visibleCheck or (onScreen and inLineOfSite(plrTPart.Position, plr.Character))) then
			if ((fovDist <= settings.fov) and (fovDist < nearestPlrData.dist)) then
				nearestPlrData.plr = plr
				nearestPlrData.aimPart = plrTPart
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
	nearestPlr = (if inputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then getNearestPlrByCursor() else nil)

	fovCircle.Radius = settings.fov
	fovCircle.Position = inputService:GetMouseLocation()

	if nearestPlr then
		local posVec3, onScreen = camera:WorldToViewportPoint(nearestPlr.aimPart.Position)

		targetBox.Visible = onScreen
		targetBox.Position = (Vector2.new(posVec3.X, posVec3.Y) - (targetBox.Size / 2))
	else
		targetBox.Visible = false
		targetBox.Position = Vector3.zero
	end
end)

refs.netSend = pfImports.network.send
function pfImports.network:send(name, ...)
	local args = {...}

	if nearestPlr and nearestPlr.aimPart then
		if name == "newbullets" then
			for _, bullet in next, args[1].bullets do
				bullet[1] = pfImports.physics.trajectory(
					args[1].firepos,
					pfImports.values.bulletAcceleration,
					nearestPlr.aimPart.Position,
					bullet[1].Magnitude
				)
			end

			refs.netSend(self, name, unpack(args))
			for _, bullet in next, args[1].bullets do
				refs.netSend(self,
					"bullethit",
					nearestPlr.plr,
					nearestPlr.aimPart.Position,
					settings.customHitPart or nearestPlr.aimPart.Name,
					bullet[2]
				)
			end
			return
		elseif name == "bullethit" then
			return
		end
	end

	return refs.netSend(self, name, unpack(args))
end
