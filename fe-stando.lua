--[[
	Info:
	Hey im jLn0n, not the original creator of the all known leaked fe script, I made this script on 6/2/2021 because
	the leaked FE stand script is patched by roblox and decided to write it from scratch, it has simple functions and
	still improving it. Read things that I've writted below to guide you using the script.

	Hats Needed:
	https://www.roblox.com/catalog/617605556 (you can use any hats and offset the head with HeadOffset variable)
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
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local RepStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
-- // OBJECTS
local Player = Players.LocalPlayer
local Character = Player.Character
local Humanoid = Character.Humanoid
local HRP = Character.HumanoidRootPart
local ChatMakeMsg = RepStorage.DefaultChatSystemChatEvents.SayMessageRequest
-- // VARIABLES
_G.Connections = _G.Connections or {}
local HeadName = "MediHood" -- you can find the name of ur desired head by using dex or viewing it with btroblox (chrome extension)
local HeadOffset = CFrame.new(Vector3.new(0, .1, .25))
local HatParts = {
	["Head"] = Character:FindFirstChild(HeadName),
	["Left Arm"] = Character:FindFirstChild("Pal Hair"),
	["Left Leg"] = Character:FindFirstChild("Pink Hair"),
	["Right Arm"] = Character:FindFirstChild("Hat1"),
	["Right Leg"] = Character:FindFirstChild("LavanderHair"),
	["Torso1"] = Character:FindFirstChild("Robloxclassicred"),
	["Torso2"] = Character:FindFirstChild("Kate Hair")
}
local StandoStates = {
	["Enabled"] = true,
	["ModeState"] = "Idle",
	["IsTimeStopMode"] = false,
	["CanUpdateStates"] = true,
	["CanUpdateStates2"] = true,
}
local StandoKeybinds = {
	[Enum.KeyCode.E] = "Barrage",
	[Enum.KeyCode.F] = "TimeStop",
	[Enum.KeyCode.G] = "Menancing",
	[Enum.KeyCode.R] = "HeavyPunch",
}
local StandoCFrame = CFrame.new(Vector3.new(-1.25, 1.5, 2.5))
local rad, sin, random = math.rad, math.sin, math.random
local anim, animSpeed = 0, 0
-- // MAIN
if not Character:FindFirstChild("StandoCharacter") then
	for _, connection in ipairs(_G.Connections) do connection:Disconnect() end _G.Connections = {}

	local StandoCharacter = game:GetObjects("rbxassetid://6843243348")[1]
	local StandoHRP = StandoCharacter.HumanoidRootPart
	local ColorCE = Lighting:FindFirstChild("TimeStopCCE") or Instance.new("ColorCorrectionEffect")
	StandoCharacter.Name = "StandoCharacter"
	StandoCharacter.Parent = Character
	ColorCE.Name, ColorCE.Parent = "TimeStopCCE", Lighting

	local initMotor = function(motor)
		return {
			Object = motor,
			CFrame = motor.Transform,
			Cache = motor.Transform
		}
	end

	local Motors = {
		Neck = initMotor(StandoCharacter.Torso.Neck),
		RS = initMotor(StandoCharacter.Torso["Right Shoulder"]),
		LS = initMotor(StandoCharacter.Torso["Left Shoulder"]),
		RH = initMotor(StandoCharacter.Torso["Right Hip"]),
		LH = initMotor(StandoCharacter.Torso["Left Hip"]),
		RJoint = initMotor(StandoHRP.RootJoint),
	}

	for _, object in ipairs(StandoCharacter:GetChildren()) do if object:IsA("BasePart") then object.Transparency = 1 end end
	for PartName, object in pairs(HatParts) do
		if object.Handle:FindFirstChildWhichIsA("Weld") then object.Handle:FindFirstChildWhichIsA("Weld"):Destroy() end
		if PartName ~= "Head" then object.Handle:FindFirstChildWhichIsA("SpecialMesh"):Destroy() end
	end

	local onCharacterRemoved = function()
		for _, connection in ipairs(_G.Connections) do
			connection:Disconnect()
		end _G.Connections = {}
	end

	local createMessage = function(msg) ChatMakeMsg:FireServer(msg, "All") end
	local setUpdateState = function(boolean) StandoStates.CanUpdateStates, StandoStates.CanUpdateStates2 = boolean, boolean end

	local Barrage = function()
		StandoStates.ModeState = "Barrage"
		setUpdateState(false)
		StandoCFrame = CFrame.new(Vector3.new(0, .25, -1.75))
		Humanoid.WalkSpeed = 3.25
		Motors.Neck.CFrame = Motors.Neck.Cache * CFrame.Angles(rad(7.5), 0, 0)
		Motors.LS.CFrame = Motors.LS.Cache * CFrame.new(Vector3.new(0, .5, .5)) * CFrame.Angles(rad(90), 0, -rad(90))
		Motors.RS.CFrame = Motors.RS.Cache * CFrame.new(Vector3.new(0, .5, .5)) * CFrame.Angles(rad(90), 0, rad(90))
		Motors.RJoint.CFrame = Motors.RJoint.Cache
		wait()
		createMessage("ORA! (x12)")
		for _ = 1, 14 do
			Motors.LS.CFrame = Motors.LS.Cache * CFrame.new(Vector3.new(-3.5, .5, 0)) * CFrame.Angles(rad(90), 0, -rad(40))
			wait(.075)
			Motors.RS.CFrame = Motors.RS.Cache * CFrame.new(Vector3.new(3.5, .5, 0)) * CFrame.Angles(rad(90), 0, rad(40))
			Motors.LS.CFrame = Motors.LS.Cache * CFrame.new(Vector3.new(0, .5, .5)) * CFrame.Angles(rad(90), 0, -rad(90))
			wait(.075)
			Motors.RS.CFrame = Motors.RS.Cache * CFrame.new(Vector3.new(0, .5, .5)) * CFrame.Angles(rad(90), 0, rad(90))
			wait(.025)
		end
		StandoStates.ModeState = "Idle"
		setUpdateState(true)
		StandoCFrame = CFrame.new(Vector3.new(-1.25, 1.5, 2.5))
		Humanoid.WalkSpeed = 16
	end

	local HeavyPunch = function()
		StandoStates.ModeState = "HeavyPunch"
		setUpdateState(false)
		StandoCFrame = CFrame.new(Vector3.new(0, .25, -2.5))
		Humanoid.WalkSpeed = 2.75
		createMessage("OORAAA!!")
		Motors.Neck.CFrame = Motors.Neck.Cache * CFrame.Angles(0, 0, -rad(20))
		Motors.LS.CFrame = Motors.LS.Cache * CFrame.Angles(-rad(3.5), 0, 0)
		Motors.RS.CFrame = Motors.RS.Cache * CFrame.Angles(-rad(25), 0, rad(15))
		Motors.RJoint.CFrame = Motors.RJoint.Cache * CFrame.Angles(0, 0, -rad(30))
		wait(.4)
		Motors.Neck.CFrame = Motors.Neck.Cache * CFrame.Angles(-rad(12), 0, rad(10))
		Motors.LS.CFrame = Motors.LS.Cache * CFrame.Angles(-rad(3.5), 0, 0)
		Motors.RS.CFrame = Motors.RS.Cache * CFrame.new(Vector3.new(.95, 0, -.25)) * CFrame.Angles(-rad(10), rad(25), rad(115))
		Motors.RJoint.CFrame = Motors.RJoint.Cache * CFrame.Angles(0, 0, rad(25))
		wait(.5)
		StandoStates.ModeState = "Idle"
		setUpdateState(true)
		StandoCFrame = CFrame.new(Vector3.new(-1.25, 1.5, 2.5))
		Humanoid.WalkSpeed = 16
	end

	local TimeStop = function()
		StandoStates.ModeState = "TimeStop"
		StandoStates.CanUpdateStates = false
		StandoCFrame = CFrame.new(Vector3.new(0, .25, -1.75))
		HRP.Anchored = true
		ColorCE.Enabled = true
		createMessage("ZA WARUDOOOOO!")
		for _, animObj in pairs(Humanoid:GetPlayingAnimationTracks()) do animObj:Stop() end
		Motors.Neck.CFrame = Motors.Neck.Cache * CFrame.Angles(rad(40), 0, 0)
		Motors.LS.CFrame = Motors.LS.Cache * CFrame.new(Vector3.new(0, .5, .5)) * CFrame.Angles(rad(90), 0, -rad(45))
		Motors.RS.CFrame = Motors.RS.Cache * CFrame.new(Vector3.new(0, .5, .5)) * CFrame.Angles(rad(90), 0, rad(45))
		Motors.RJoint.CFrame = Motors.RJoint.Cache
		wait(.55)
		Motors.Neck.CFrame = Motors.Neck.Cache * CFrame.Angles(-rad(15), 0, 0)
		Motors.LS.CFrame = Motors.LS.Cache * CFrame.new(Vector3.new(0, .5, .5)) * CFrame.Angles(rad(90), 0, -rad(140))
		Motors.RS.CFrame = Motors.RS.Cache * CFrame.new(Vector3.new(0, .5, .5)) * CFrame.Angles(rad(90), 0, rad(140))
		Motors.RJoint.CFrame = Motors.RJoint.Cache
		for _ = 1, 10 do
			ColorCE.Saturation -= .1
			ColorCE.Contrast += .1
			wait(.025)
		end
		wait(.15)
		StandoStates.IsTimeStopMode = true
		settings():GetService("NetworkSettings").IncomingReplicationLag = math.huge
		HRP.Anchored = false
		Humanoid:ChangeState("Freefall")
		StandoCFrame = CFrame.new(Vector3.new(-1.25, 1.5, 2.5))
		StandoStates.ModeState = "Idle"
		wait(8)
		for _ = 1, 10 do
			ColorCE.Saturation += .1
			ColorCE.Contrast -= .1
			wait(.025)
		end
		ColorCE.Enabled = false
		StandoStates.CanUpdateStates = true
		StandoStates.IsTimeStopMode = false
		settings():GetService("NetworkSettings").IncomingReplicationLag = 0
	end

	local MenanceAnim = function()
		for _, animObj in pairs(Humanoid:GetPlayingAnimationTracks()) do animObj:Stop() end
		StandoStates.ModeState = "Menancing"
		setUpdateState(false)
		HRP.Anchored = true
		StandoCFrame = CFrame.new(Vector3.new(0, 0, 1.25)) * CFrame.Angles(0, rad(180), 0)
		Motors.Neck.CFrame = Motors.Neck.Cache * CFrame.Angles(rad(15), 0, rad(22.5))
		wait(.5)
		setUpdateState(true)
	end

	_G.Connections[#_G.Connections + 1] = UIS.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Keyboard and not UIS:GetFocusedTextBox() then
			if input.KeyCode == Enum.KeyCode.Q and StandoStates.CanUpdateStates and StandoStates.ModeState == "Idle" then
				StandoStates.Enabled = not StandoStates.Enabled
				if StandoStates.Enabled then
					StandoStates.ModeState = "Idle"
					StandoCFrame = CFrame.new(Vector3.new(-1.25, 1.5, 2.5))
				end
			end
			if StandoStates.Enabled and (StandoStates.CanUpdateStates or (StandoStates.CanUpdateStates2 and StandoStates.IsTimeStopMode)) then
				if StandoStates.ModeState == "Idle" and StandoKeybinds[input.KeyCode] and StandoStates.ModeState ~= StandoKeybinds[input.KeyCode] then
					if StandoKeybinds[input.KeyCode] == "Barrage" then
						Barrage()
					elseif StandoKeybinds[input.KeyCode] == "HeavyPunch" then
						HeavyPunch()
					elseif StandoKeybinds[input.KeyCode] == "Menancing" then
						MenanceAnim()
					elseif StandoKeybinds[input.KeyCode] == "TimeStop" and not StandoStates.IsTimeStopMode then
						TimeStop()
					end
				elseif StandoStates.ModeState ~= "Idle" and StandoKeybinds[input.KeyCode] then
					StandoStates.ModeState = "Idle"
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

		for _, object in ipairs(StandoCharacter:GetDescendants()) do
			if object:IsA("BasePart") then
				object.CanCollide = false
			end
		end
	end)

	_G.Connections[#_G.Connections + 1] = RunService.Heartbeat:Connect(function()
		StandoHRP.CFrame = HRP.CFrame * StandoCFrame
		for PartName, object in pairs(HatParts) do
			if object:FindFirstChild("Handle") then
				if PartName == "Torso1" then
					object.Handle.CFrame = StandoCharacter.Torso.CFrame * CFrame.new(Vector3.new(.5, 0, 0)) * CFrame.Angles(rad(90), 0, 0)
				elseif PartName == "Torso2" then
					object.Handle.CFrame = StandoCharacter.Torso.CFrame * CFrame.new(Vector3.new(-.5, 0, 0)) * CFrame.Angles(rad(90), 0, 0)
				elseif PartName == "Head" then
					object.Handle.CFrame = StandoCharacter.Head.CFrame * HeadOffset
				else
					object.Handle.CFrame = StandoCharacter[PartName].CFrame * CFrame.Angles(rad(90), 0, 0)
				end
			end
		end
	end)

	_G.Connections[#_G.Connections + 1] = RunService.Stepped:Connect(function()
		anim = (anim % 100) + animSpeed / 10
		for _, motor in pairs(Motors) do
			motor.Object.Transform = motor.Object.Transform:lerp(motor.CFrame, .2)
		end
		if StandoStates.Enabled then
			if StandoStates.ModeState == "Idle" then
				animSpeed = .5
				Motors.Neck.CFrame = Motors.Neck.Cache * CFrame.Angles(rad(7.5), 0, 0)
				Motors.LS.CFrame = Motors.LS.Cache * CFrame.Angles(rad(6), -rad(12), -rad(4))
				Motors.LH.CFrame = Motors.LH.Cache * CFrame.Angles(0, 0, -rad(3.5))
				Motors.RS.CFrame = Motors.RS.Cache * CFrame.Angles(-rad(3.5), 0, 0)
				Motors.RH.CFrame = Motors.RH.Cache * CFrame.Angles(0, 0, -rad(10))
				Motors.RJoint.CFrame = Motors.RJoint.Cache * CFrame.new(Vector3.new(0, 0, -sin(anim) * .05)) * CFrame.Angles(0, 0, rad(7.5))
			end
		else
			StandoCFrame = CFrame.new(Vector3.new(1000, 1000 + random(1, 100), 1000))
			for _, motor in pairs(Motors) do motor.CFrame = motor.Cache end
		end
	end)

	_G.Connections[#_G.Connections + 1] = Humanoid.Died:Connect(onCharacterRemoved)
	_G.Connections[#_G.Connections + 1] = Player.CharacterRemoving:Connect(onCharacterRemoved)
end
