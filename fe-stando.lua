--[[
	Info:
	Hey im jLn0n aka. JohnLennonPlayz im not the original creator of the all known leaked fe script, I made this
	script on 6/2/2021 because the leaked FE stand script is patched by roblox and decided to write it from scratch,
	it has simple functions and still improving it. Read things that I've writted below to guide you using the script.

	Hats Needed:
	https://www.roblox.com/catalog/617605556 (you can use any hats and offset the head with _G.HeadOffset)
	https://www.roblox.com/catalog/451220849
	https://www.roblox.com/catalog/63690008
	https://www.roblox.com/catalog/48474294 (bundle: https://www.roblox.com/bundles/282)
	https://www.roblox.com/catalog/48474313
	https://www.roblox.com/catalog/62234425
	https://www.roblox.com/catalog/62724852 (bundle: https://www.roblox.com/bundles/239)

	Controls:
	Q - Summon / Unsummon stand
	E - Barrage
	R - HeavyPunch
	F - Time Stop
	G - Stand Idle Menance thingy
--]]
-- // SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
-- // OBJECTS
local Player = Players.LocalPlayer
local Character = Player.Character
local Humanoid = Character.Humanoid
local HRP = Character.HumanoidRootPart
-- // VARIABLES
_G.Connections = _G.Connections or {}
_G.HeadOffset = CFrame.new(Vector3.new(0, .1, .25))
local HatParts = {
	["Head"] = Character:FindFirstChild("MediHood"),
	["Left Arm"] = Character:FindFirstChild("Pal Hair"),
	["Left Leg"] = Character:FindFirstChild("Pink Hair"),
	["Right Arm"] = Character:FindFirstChild("Hat1"),
	["Right Leg"] = Character:FindFirstChild("LavanderHair"),
	["Torso1"] = Character:FindFirstChild("Robloxclassicred"),
	["Torso2"] = Character:FindFirstChild("Kate Hair")
}
local StandoStates = {
	["Enabled"] = true,
	["AnimState"] = "Idle",
	["IsTimeStopMode"] = false,
	["CanUpdateStates"] = true,
}
local StandoAnimKeybinds = {
	[Enum.KeyCode.E] = "Barrage",
	[Enum.KeyCode.F] = "TimeStop",
	[Enum.KeyCode.G] = "Menancing",
	[Enum.KeyCode.R] = "HeavyPunch",
}
local rad, sin, random = math.rad, math.sin, math.random
local anim, animSpeed = 0, 0
local StandoCFrame = CFrame.new(Vector3.new(-1.25, 1.5, 2.5))
-- // MAIN
if not Character:FindFirstChild("StandoCharacter") then
	for _, connection in ipairs(_G.Connections) do connection:Disconnect() end _G.Connections = {}
	local initMotor = function(motor)
		return {
			Object = motor, -- The weld that will lerp
			CFrame = motor.Transform, -- Where it will lerp to; a CFrame
			Cache = motor.Transform, -- Cache of original position; it helps when making anim keyframes
		}
	end

	local StandoChar = game:GetObjects("rbxassetid://6843243348")[1]
	StandoChar.Name = "StandoCharacter"
	StandoChar.Parent = Character

	local Motors = {
		Neck = initMotor(StandoChar.Torso.Neck),
		RS = initMotor(StandoChar.Torso["Right Shoulder"]),
		LS = initMotor(StandoChar.Torso["Left Shoulder"]),
		RH = initMotor(StandoChar.Torso["Right Hip"]),
		LH = initMotor(StandoChar.Torso["Left Hip"]),
		RJoint = initMotor(StandoChar.HumanoidRootPart.RootJoint),
	}

	for _, object in ipairs(StandoChar:GetChildren()) do if object:IsA("BasePart") then object.Transparency = 1 end end
	for PartName, object in pairs(HatParts) do
		if object.Handle:FindFirstChildWhichIsA("Weld") then object.Handle:FindFirstChildWhichIsA("Weld"):Destroy() end
		if PartName ~= "Head" then
			object.Handle:FindFirstChildWhichIsA("SpecialMesh"):Destroy()
		end
	end

	local Barrage = function()
		StandoStates.AnimState = "Barrage"
		StandoStates.CanUpdateStates = false
		StandoCFrame = CFrame.new(Vector3.new(0, .25, -1.75))
		Humanoid.WalkSpeed = 2.5
		Motors.Neck.CFrame = Motors.Neck.Cache * CFrame.Angles(rad(7.5), 0, 0)
		Motors.LS.CFrame = Motors.LS.Cache * CFrame.new(Vector3.new(0, .5, .5)) * CFrame.Angles(rad(90), 0, -rad(90))
		Motors.RS.CFrame = Motors.RS.Cache * CFrame.new(Vector3.new(0, .5, .5)) * CFrame.Angles(rad(90), 0, rad(90))
		Motors.RJoint.CFrame = Motors.RJoint.Cache
		wait()
		for _ = 1, 12 do
			Motors.LS.CFrame = Motors.LS.Cache * CFrame.new(Vector3.new(-3.5, .5, 0)) * CFrame.Angles(rad(90), 0, -rad(40))
			wait(.075)
			Motors.RS.CFrame = Motors.RS.Cache * CFrame.new(Vector3.new(3.5, .5, 0)) * CFrame.Angles(rad(90), 0, rad(40))
			Motors.LS.CFrame = Motors.LS.Cache * CFrame.new(Vector3.new(0, .5, .5)) * CFrame.Angles(rad(90), 0, -rad(90))
			wait(.075)
			Motors.RS.CFrame = Motors.RS.Cache * CFrame.new(Vector3.new(0, .5, .5)) * CFrame.Angles(rad(90), 0, rad(90))
			wait(.025)
		end
		StandoStates.AnimState = "Idle"
		StandoStates.CanUpdateStates = true
		StandoCFrame = CFrame.new(Vector3.new(-1.25, 1.5, 2.5))
		Humanoid.WalkSpeed = 16
	end

	local HeavyPunch = function()
		StandoStates.AnimState = "HeavyPunch"
		StandoStates.CanUpdateStates = false
		StandoCFrame = CFrame.new(Vector3.new(0, .25, -2.5))
		Humanoid.WalkSpeed = 2.25
		Motors.Neck.CFrame = Motors.Neck.Cache * CFrame.Angles(0, 0, -rad(20))
		Motors.LS.CFrame = Motors.LS.Cache * CFrame.Angles(-rad(3.5), 0, 0)
		Motors.RS.CFrame = Motors.RS.Cache * CFrame.Angles(-rad(25), 0, rad(15))
		Motors.RJoint.CFrame = Motors.RJoint.Cache * CFrame.Angles(0, 0, -rad(30))
		wait(.4)
		Motors.Neck.CFrame = Motors.Neck.Cache * CFrame.Angles(0, 0, rad(20))
		Motors.LS.CFrame = Motors.LS.Cache * CFrame.Angles(-rad(3.5), 0, 0)
		Motors.RS.CFrame = Motors.RS.Cache * CFrame.Angles(-rad(10), rad(25), rad(115))
		Motors.RJoint.CFrame = Motors.RJoint.Cache * CFrame.Angles(0, 0, rad(25))
		wait(.5)
		StandoStates.AnimState = "Idle"
		StandoStates.CanUpdateStates = true
		StandoCFrame = CFrame.new(Vector3.new(-1.25, 1.5, 2.5))
		Humanoid.WalkSpeed = 16
	end

	local TimeStop = function()
		StandoStates.AnimState = "TimeStop"
		StandoStates.CanUpdateStates = false
		StandoCFrame = CFrame.new(Vector3.new(0, .25, -1.75))
		for _, animObj in pairs(Humanoid:GetPlayingAnimationTracks()) do animObj:Stop() end
		HRP.Anchored = true
		Motors.Neck.CFrame = Motors.Neck.Cache * CFrame.Angles(rad(40), 0, 0)
		Motors.LS.CFrame = Motors.LS.Cache * CFrame.new(Vector3.new(0, .5, .5)) * CFrame.Angles(rad(90), 0, -rad(45))
		Motors.RS.CFrame = Motors.RS.Cache * CFrame.new(Vector3.new(0, .5, .5)) * CFrame.Angles(rad(90), 0, rad(45))
		Motors.RJoint.CFrame = Motors.RJoint.Cache
		wait(.55)
		Motors.Neck.CFrame = Motors.Neck.Cache * CFrame.Angles(-rad(40), 0, 0)
		Motors.LS.CFrame = Motors.LS.Cache * CFrame.new(Vector3.new(0, .5, .5)) * CFrame.Angles(rad(90), 0, -rad(135))
		Motors.RS.CFrame = Motors.RS.Cache * CFrame.new(Vector3.new(0, .5, .5)) * CFrame.Angles(rad(90), 0, rad(135))
		Motors.RJoint.CFrame = Motors.RJoint.Cache
		wait(.5)
		StandoStates.IsTimeStopMode = true
		HRP.Anchored = false
		settings():GetService("NetworkSettings").IncomingReplicationLag = 1500
		StandoCFrame = CFrame.new(Vector3.new(-1.25, 1.5, 2.5))
		StandoStates.AnimState = "Idle"
		wait(7.75)
		StandoStates.CanUpdateStates = true
		StandoStates.IsTimeStopMode = false
		settings():GetService("NetworkSettings").IncomingReplicationLag = 0
	end

	local MenanceAnim = function()
		for _, animObj in pairs(Humanoid:GetPlayingAnimationTracks()) do animObj:Stop() end
		StandoStates.AnimState = "Menancing"
		HRP.Anchored = true
		StandoCFrame = CFrame.new(Vector3.new(0, 0, 1.25)) * CFrame.Angles(0, rad(180), 0)
		Motors.Neck.CFrame = Motors.Neck.Cache * CFrame.Angles(rad(15), 0, rad(22.5))
	end

	_G.Connections[#_G.Connections + 1] = UIS.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Keyboard and not UIS:GetFocusedTextBox() then
			if input.KeyCode == Enum.KeyCode.Q and StandoStates.CanUpdateStates and StandoStates.AnimState == "Idle" then
				StandoStates.Enabled = not StandoStates.Enabled
				if StandoStates.Enabled then
					StandoStates.AnimState = "Idle"
					StandoCFrame = CFrame.new(Vector3.new(-1.25, 1.5, 2.5))
				end
			end
			if StandoStates.Enabled and (StandoStates.CanUpdateStates or StandoStates.IsTimeStopMode) then
				if StandoStates.AnimState == "Idle" and StandoAnimKeybinds[input.KeyCode] and StandoStates.AnimState ~= StandoAnimKeybinds[input.KeyCode] then
					if StandoAnimKeybinds[input.KeyCode] == "Barrage" then
						Barrage()
					elseif StandoAnimKeybinds[input.KeyCode] == "HeavyPunch" then
						HeavyPunch()
					elseif StandoAnimKeybinds[input.KeyCode] == "Menancing" then
						MenanceAnim()
					elseif StandoAnimKeybinds[input.KeyCode] == "TimeStop" and not StandoStates.IsTimeStopMode then
						TimeStop()
					end
				elseif StandoStates.AnimState ~= "Idle" and StandoAnimKeybinds[input.KeyCode] then
					StandoStates.AnimState = "Idle"
					Humanoid.WalkSpeed = 16
					HRP.Anchored = false
					animSpeed = 1
					StandoCFrame = CFrame.new(Vector3.new(-1.25, 1.5, 2.5))
				end
			end
		end
	end)

	_G.Connections[#_G.Connections + 1] = RunService.Stepped:Connect(function()
		settings().Physics.AllowSleep = false
		settings().Physics.PhysicsEnvironmentalThrottle = Enum.EnviromentalPhysicsThrottle.DefaultAuto
		settings().Physics.ThrottleAdjustTime = -math.huge

		for _, object in ipairs(Character:GetChildren()) do
			if object:IsA("Accessory") and object:FindFirstChild("Handle") then
				object.Handle.CanCollide = false
				object.Handle.Massless = true
				object.Handle.Velocity = Vector3.new(0, 40, 0)
				object.Handle.RotVelocity = Vector3.new()
			end
		end

		for _, object in ipairs(StandoChar:GetDescendants()) do
			if object:IsA("BasePart") then
				object.CanCollide = false
			end
		end
	end)

	_G.Connections[#_G.Connections + 1] = RunService.Heartbeat:Connect(function()
		StandoChar.HumanoidRootPart.CFrame = HRP.CFrame * StandoCFrame
		for PartName, object in pairs(HatParts) do
			if object:FindFirstChild("Handle") then
				if PartName == "Torso1" then
					object.Handle.CFrame = StandoChar.Torso.CFrame * CFrame.new(Vector3.new(.5, 0, 0)) * CFrame.Angles(rad(90), 0, 0)
				elseif PartName == "Torso2" then
					object.Handle.CFrame = StandoChar.Torso.CFrame * CFrame.new(Vector3.new(-.5, 0, 0)) * CFrame.Angles(rad(90), 0, 0)
				elseif PartName == "Head" then
					object.Handle.CFrame = StandoChar.Head.CFrame * _G.HeadOffset
				else
					object.Handle.CFrame = StandoChar[PartName].CFrame * CFrame.Angles(rad(90), 0, 0)
				end
			end
		end
	end)

	_G.Connections[#_G.Connections + 1] = RunService.Stepped:Connect(function()
		anim = (anim % 100) + animSpeed / 10
		for _, motor in pairs(Motors) do
			motor.Object.Transform = motor.Object.Transform:Lerp(motor.CFrame, .2)
		end
		if StandoStates.Enabled then
			if StandoStates.AnimState == "Idle" then
				animSpeed = .5
				Motors.Neck.CFrame = Motors.Neck.Cache * CFrame.Angles(rad(7.5), 0, 0)
				Motors.LS.CFrame = Motors.LS.Cache * CFrame.Angles(rad(6), -rad(12), -rad(4))
				Motors.LH.CFrame = Motors.LH.Cache * CFrame.Angles(0, 0, -rad(3.5))
				Motors.RS.CFrame = Motors.RS.Cache * CFrame.Angles(-rad(3.5), 0, 0)
				Motors.RH.CFrame = Motors.RH.Cache * CFrame.Angles(0, 0, -rad(10))
				Motors.RJoint.CFrame = Motors.RJoint.Cache * CFrame.new(Vector3.new(0, 0, -sin(anim) * .05)) * CFrame.Angles(0, 0, rad(7.5))
			end
		else
			StandoCFrame = CFrame.new(Vector3.new(0, 1000 + random(1, 10), 0))
			for _, motor in pairs(Motors) do
				motor.CFrame = motor.Cache
			end
		end
	end)

	_G.Connections[#_G.Connections + 1] = Humanoid.Died:Connect(function()
		for _, connection in ipairs(_G.Connections) do
			connection:Disconnect()
		end _G.Connections = {}
	end)
end
