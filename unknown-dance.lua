-- // SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
-- // OBJECTS
local Player = Players.LocalPlayer
local Character = Player.Character
local HRP = Character.HumanoidRootPart
local Torso = Character.Torso
local Neck = Torso.Neck
local LeftShoulder = Torso["Left Shoulder"]
local RightShoulder = Torso["Right Shoulder"]
local LeftHip = Torso["Left Hip"]
local RightHip = Torso["Right Hip"]
local RootJoint = HRP.RootJoint
-- // VARIABLES
local anglespeed, angle, anim, yeet = 1, 0, true, 0
local danceState = 0
local sound
local rad, sin, abs, cos, random = math.rad, math.sin, math.abs, math.cos, math.random
-- // MAIN
Neck.C0 = CFrame.new(0,1,0)
Neck.C1 = CFrame.new(0,-0.5,0)
LeftShoulder.C0 = CFrame.new(-1,0.5,0)
LeftShoulder.C1 = CFrame.new(0.5,0.5,0)
RightShoulder.C0 = CFrame.new(1,0.5,0)
RightShoulder.C1 = CFrame.new(-0.5,0.5,0)
LeftHip.C0 = CFrame.new(-1,-1,0)
LeftHip.C1 = CFrame.new(-0.5,1,0)
RightHip.C0 = CFrame.new(1,-1,0)
RightHip.C1 = CFrame.new(0.5,1,0)
RootJoint.C0 = CFrame.new(0,0,0) * CFrame.Angles(-math.pi/2,0,math.pi)
RootJoint.C1 = CFrame.new(0,0,0) * CFrame.Angles(-math.pi/2,0,math.pi)

local newLerpTo = function(motor)
	return {
			Motor = motor; -- The weld that will lerp
			To = motor.C0; -- Where it will lerp to; a CFrame
			Cache = motor.C0; -- Cache of original position; it helps when making anim keyframes
			Speed = 0.2; -- Speed of lerp. 0.1 or 0.2 is best
	}
end

local PlaySong = function(id)
	if Torso:FindFirstChild("Sound") then Torso.Sound:Destroy() end
	sound = Instance.new("Sound")
	sound.Parent = Torso
	sound.Volume = math.huge
	sound.Looped = true
	sound.SoundId = "rbxassetid://" .. id
	sound:Play()
end

local LerpTo = {
	Neck = newLerpTo(Neck);
	LeftArm = newLerpTo(LeftShoulder);
	RightArm = newLerpTo(RightShoulder);
	LeftLeg = newLerpTo(LeftHip);
	RightLeg = newLerpTo(RightHip);
	RootJoint = newLerpTo(RootJoint);
}

local OnNewInput = function(key)
	if key == "q" and danceState == 0 then
		PlaySong("353562314")
		anim = false
		danceState = 1
	elseif key == "e" and danceState == 0 then
		PlaySong('130795320')
		anim = false
		danceState = 2
	elseif key == "r" and danceState == 0 then
		PlaySong('145763936')
		anim = false
		danceState = 3
	elseif key == "t" and danceState == 0 then
		PlaySong('156906204')
		anim = false
		danceState = 4
	elseif key == "y" and danceState == 0 then
		PlaySong("186713206")
		anim = false
		danceState = 5
	elseif key == "f" and danceState == 0 then
		PlaySong("915875843")
		anim = false
		danceState = 6
	elseif key == "g" and danceState == 0 then
		PlaySong("151305600")
		anim = false
		danceState = 7
	elseif key == "h" and danceState == 0 then -- roleo danceState :D
		PlaySong("178856837")--insert ur soundid here plz
		anim = false
		danceState = 8-- ill make this in second
	elseif key == "j" and danceState == 0 then
		PlaySong("156461074")
		anim = false
		danceState = 9
	elseif key == "z" and danceState == 0 then
		PlaySong("140853918")
		anim = false
		danceState = 10
	elseif key == "x" and danceState == 0 then
		PlaySong("162893085")
		anim = false
		danceState = 11
	elseif key == "c" and danceState == 0 then
		PlaySong("379503677")
		anim = false
		danceState = 12
	elseif key == "v" and danceState == 0 then
		PlaySong("147464680")
		anim = false
		danceState = 13
	elseif key == "b" and danceState == 0 then
		PlaySong("172895447")
		anim = false
		danceState = 2
	elseif key == "n" and danceState == 0 then
		PlaySong("221710008")
		anim = false
		danceState = 14
	elseif key == "m" and danceState == 0 then
		PlaySong("203426516")
		anim = false
		danceState = 15
	elseif key == "u" and danceState == 0 then
		PlaySong("160442087")
		anim = false
		danceState = 16
	elseif key == "k" and danceState == 0 then
		PlaySong("146048136")
		anim = false
		danceState = 17
	elseif key == "p" and danceState == 0 then
		PlaySong("183596502")
		anim = false
		danceState = 18
	elseif key == "l" and danceState == 0 then
		PlaySong("162853958")
		anim = false
		danceState = 19
	elseif key == ";" and danceState == 0 then
		PlaySong("229824592")
		anim = false
		danceState = 20
	elseif key == "[" and danceState == 0 then
		PlaySong("147876501")
		anim = false
		danceState = 21
	elseif key == "]" and danceState == 0 then
		PlaySong("329600722")
		anim = false
		danceState = 22
	elseif key == "0" and danceState == 0 then
		PlaySong("182409344")
		anim = false
		danceState = 23
	elseif key == "q" or key == "e" or key == "r" or key == "t" or key == "y" or key == "f" or key == "g" or key == "h" or key == "j" or key == "z" or key == "x" or key == "c" or key == "v" or key == "b" or key == "n" or key == "m" or key == "u" or key == "k" or key == "p" or key == "l" or key == ";" or key == "[" or key == "]" or key == "0" and danceState > 0 then
		sound:Stop()
		danceState = 0
		anim = true
	end
end

_G.Connections[#_G.Connections] = UIS.InputBegan:Connect(function(input)
	if not UIS:GetFocusedTextBox() then
		OnNewInput(string.lower(input.KeyCode.Name))
	end
end)

_G.Connections[#_G.Connections] = RunService.Stepped:Connect(function()
	angle = (angle % 100) + anglespeed/10
	for _, object in pairs(LerpTo) do
		object.Motor.C0 = object.Motor.C0:Lerp(object.To, object.Speed)
	end
	if anim then
		if Vector3.new(Torso.Velocity.x, 0, Torso.Velocity.z).magnitude < 2 and danceState == 0 then
			anglespeed = 1/3
			LerpTo.Neck.To = LerpTo.Neck.Cache * CFrame.Angles(sin(angle)*0.05,0,0)
			LerpTo.RightArm.To = LerpTo.RightArm.Cache * CFrame.Angles(abs(sin(angle))*.2,rad(0),rad(0))
			LerpTo.LeftArm.To = LerpTo.LeftArm.Cache * CFrame.Angles(-abs(sin(angle))*.2,0,0)
			LerpTo.RightLeg.To = LerpTo.RightLeg.Cache * CFrame.Angles(0,0,abs(sin(angle))*0.2)
			LerpTo.LeftLeg.To = LerpTo.LeftLeg.Cache * CFrame.Angles(0,0,-abs(sin(angle))*0.2) 
			LerpTo.RootJoint.To=LerpTo.RootJoint.Cache * CFrame.new(0,0,0)*CFrame.Angles(0,0,0)
		end
		if Vector3.new(Torso.Velocity.x, 0, Torso.Velocity.z).magnitude > 2 and danceState == 0 then
			anglespeed = 1.5
			LerpTo.Neck.To = LerpTo.Neck.Cache * CFrame.Angles(0,0,sin(angle)*0.05)
			LerpTo.RightArm.To = LerpTo.RightArm.Cache * CFrame.Angles(sin(angle)*.8,0,0)
			LerpTo.LeftArm.To = LerpTo.LeftArm.Cache * CFrame.Angles(-sin(angle)*.8,0,0)
			LerpTo.RightLeg.To = LerpTo.RightLeg.Cache * CFrame.Angles(-sin(angle)*.8,0,0)
			LerpTo.LeftLeg.To = LerpTo.LeftLeg.Cache * CFrame.Angles(sin(angle)*.8,0,0) 
			LerpTo.RootJoint.To=LerpTo.RootJoint.Cache * CFrame.new(0,0,0)*CFrame.Angles(0,0,0)
		end
	elseif not anim then
		if danceState == 1 then
			anglespeed = 3
			LerpTo.Neck.To = LerpTo.Neck.Cache * CFrame.Angles(rad(10),0,sin(yeet)*0.1)
			LerpTo.RootJoint.To = LerpTo.RootJoint.Cache * CFrame.Angles(rad(20),sin(angle)*0.2,sin(angle)*0.5) * CFrame.new(0,-abs(sin(angle))*0.5,0)
			LerpTo.RightArm.To = LerpTo.RightArm.Cache * CFrame.Angles(rad(90)-sin(angle)*1,0,-rad(10))
			LerpTo.LeftArm.To = LerpTo.LeftArm.Cache * CFrame.Angles(rad(90)-sin(angle)*1,0,rad(10))
			LerpTo.RightLeg.To = LerpTo.RightLeg.Cache * CFrame.Angles(rad(20),0,abs(sin(yeet))*0.1)
			LerpTo.LeftLeg.To = LerpTo.LeftLeg.Cache * CFrame.Angles(rad(20),0,-abs(sin(yeet))*0.1) 
		elseif danceState == 2 then
			anglespeed = 3
			LerpTo.Neck.To = LerpTo.Neck.Cache*CFrame.Angles(0,0,sin(angle)*.1)
			LerpTo.RootJoint.To = LerpTo.RootJoint.Cache * CFrame.new(0,0,2+sin(angle)*.25)
			LerpTo.RightArm.To = LerpTo.RightArm.Cache * CFrame.Angles(rad(90)+sin(angle)*1,0,rad(5)+sin(angle)*-.5)
			LerpTo.LeftArm.To = LerpTo.LeftArm.Cache * CFrame.Angles(rad(90)+sin(angle)*1,0,rad(5)-sin(angle)*-.5)
			LerpTo.RightLeg.To = LerpTo.RightLeg.Cache * CFrame.Angles(rad(0),rad(0),sin(angle)*.25)
			LerpTo.LeftLeg.To = LerpTo.LeftLeg.Cache * CFrame.Angles(rad(0),rad(0),sin(angle)*-.25)
		elseif danceState == 3 then
			anglespeed = 1.5
			LerpTo.Neck.To = LerpTo.Neck.Cache*CFrame.Angles(0,0,0)
			LerpTo.RootJoint.To = LerpTo.RootJoint.Cache * CFrame.Angles(0,0,0)*CFrame.new(sin(angle)*5,0,0)
			LerpTo.RightArm.To=LerpTo.RightArm.Cache*CFrame.Angles(rad(90)-sin(angle)*1,0,rad(0)-sin(angle)*.25)
			LerpTo.LeftArm.To = LerpTo.LeftArm.Cache*CFrame.Angles(rad(0),rad(0),sin(angle)*.25)
			LerpTo.RightLeg.To = LerpTo.RightLeg.Cache*CFrame.Angles(0,0,sin(angle)*.1)
			LerpTo.LeftLeg.To = LerpTo.LeftLeg.Cache*CFrame.Angles(0,0,-sin(angle)*.1)
		elseif danceState == 4 then
			anglespeed = 1.5
			LerpTo.Neck.To = LerpTo.Neck.Cache * CFrame.Angles(0,0,0)
			LerpTo.RootJoint.To = LerpTo.RootJoint.Cache * CFrame.new(0,sin(angle)*5,0)
			LerpTo.RightArm.To = LerpTo.RightArm.Cache * CFrame.Angles(rad(0),rad(0),sin(angle)*.25)
			LerpTo.LeftArm.To = LerpTo.LeftArm.Cache * CFrame.Angles(rad(0),rad(0),sin(angle)*.25)
			LerpTo.RightLeg.To = LerpTo.RightLeg.Cache * CFrame.Angles(sin(angle)*.25,0,0)
			LerpTo.LeftLeg.To = LerpTo.LeftLeg.Cache * CFrame.Angles(sin(angle)*-.25,0,0)
		elseif danceState == 5 then
			anglespeed = 3
			LerpTo.RootJoint.To = LerpTo.RootJoint.Cache * CFrame.new(sin(angle)*.5,0,0)
			LerpTo.RightArm.To = LerpTo.RightArm.Cache * CFrame.Angles(0,0,sin(angle)*.25)*CFrame.new(0,sin(angle)*.1,0)
			LerpTo.LeftArm.To = LerpTo.LeftArm.Cache * CFrame.Angles(0,0,sin(angle)*.25)*CFrame.new(0,sin(angle)*.1,0)
			LerpTo.RightLeg.To = LerpTo.RightLeg.Cache * CFrame.Angles(0,0,sin(angle)*.25)*CFrame.new(0,sin(angle)*.1,0)
			LerpTo.LeftLeg.To = LerpTo.LeftLeg.Cache * CFrame.Angles(0,0,sin(angle)*.25)*CFrame.new(0,sin(angle)*.1,0)
		elseif danceState == 6 then
			anglespeed = 2
			LerpTo.Neck.To = LerpTo.Neck.Cache * CFrame.Angles(math.pi/10-math.abs(sin(angle))*0.3,0, 0)
			LerpTo.RootJoint.To = LerpTo.RootJoint.Cache * CFrame.new(0, 0, 0) * CFrame.Angles(0, 0,sin(angle)*.2)
			LerpTo.RightArm.To = LerpTo.RightArm.Cache * CFrame.Angles(math.pi/3+math.abs(sin(angle)*1), 0,  sin(angle*1)*.5)
			LerpTo.LeftArm.To = LerpTo.LeftArm.Cache * CFrame.Angles(math.pi/3+math.abs(sin(angle)*1), 0,  sin(angle*1)*.5)
			LerpTo.RightLeg.To = LerpTo.RightLeg.Cache * CFrame.Angles(0, sin(angle)*.2, rad(2.5))
			LerpTo.LeftLeg.To = LerpTo.LeftLeg.Cache * CFrame.Angles(0, -sin(angle)*.2, -rad(2.5))
		elseif danceState == 7 then -- insane spaz out l0l
			anglespeed = 1
			LerpTo.Neck.To = LerpTo.Neck.Cache * CFrame.new(random(-5,5),random(-5,5),random(-5,5))*CFrame.Angles(random(-5,5),random(-5,5),random(-5,5))
			LerpTo.RootJoint.To = LerpTo.RootJoint.Cache * CFrame.new(random(-5,5),random(-5,5),0)*CFrame.Angles(random(-5,5),random(-5,5),random(-5,5))
			LerpTo.RightArm.To = LerpTo.RightArm.Cache * CFrame.new(random(-5,5),random(-5,5),random(-5,5))*CFrame.Angles(random(-5,5),random(-5,5),random(-5,5))
			LerpTo.LeftArm.To = LerpTo.LeftArm.Cache * CFrame.new(random(-5,5),random(-5,5),random(-5,5))*CFrame.Angles(random(-5,5),random(-5,5),random(-5,5))
			LerpTo.RightLeg.To = LerpTo.RightLeg.Cache * CFrame.new(random(-5,5),random(-5,5),random(-5,5))*CFrame.Angles(random(-5,5),random(-5,5),random(-5,5))
			LerpTo.LeftLeg.To = LerpTo.LeftLeg.Cache * CFrame.new(random(-5,5),random(-5,5),random(-5,5))*CFrame.Angles(random(-5,5),random(-5,5),random(-5,5))
		elseif danceState == 8 then -- roleo dance :D
			anglespeed = 4
			LerpTo.RightArm.To = LerpTo.RightArm.Cache*CFrame.Angles(rad(180),0,sin(angle)*.3)
			LerpTo.LeftArm.To = LerpTo.LeftArm.Cache*CFrame.Angles(rad(180),0,sin(angle)*.3)
		elseif danceState == 9 then -- XD lol mast3r ba!t!ng dance :)
			anglespeed = 6
			LerpTo.RightArm.To = LerpTo.RightArm.Cache*CFrame.Angles(rad(90)+sin(angle)*1,0,rad(-45))
			LerpTo.LeftArm.To = LerpTo.LeftArm.Cache*CFrame.Angles(rad(90)+sin(angle)*1,0,rad(45))
		elseif danceState == 10 then --but scratch :D
			anglespeed = 5
			LerpTo.RightArm.To = LerpTo.RightArm.Cache*CFrame.Angles(rad(-25),0,rad(-25))*CFrame.new(0,sin(angle)*.5,0)
			LerpTo.LeftArm.To = LerpTo.LeftArm.Cache*CFrame.Angles(rad(-25),0,rad(25))*CFrame.new(0,sin(angle)*.5,0)
		elseif danceState == 11 then -- CARTWHEELS LOLW0T!?
			anglespeed = 2
			LerpTo.RootJoint.To=LerpTo.RootJoint.Cache*CFrame.Angles(sin(angle)*2,0,0)*CFrame.new(0,sin(angle)*2,0)
		elseif danceState == 12 then -- EPICO :)
			anglespeed = 5
			LerpTo.Neck.To=LerpTo.Neck.Cache*CFrame.Angles(0,0,sin(angle)*2)
			LerpTo.RootJoint.To=LerpTo.RootJoint.Cache*CFrame.Angles(0,0,sin(angle)*2)
			LerpTo.RightArm.To=LerpTo.RightArm.Cache*CFrame.Angles(rad(90),rad(0),sin(angle)*2)
			LerpTo.LeftArm.To=LerpTo.LeftArm.Cache*CFrame.Angles(rad(90),rad(0),sin(angle)*2)
		elseif danceState == 13 then -- EPICO2 :)
			anglespeed = 5
			LerpTo.Neck.To=LerpTo.Neck.Cache*CFrame.Angles(rad(-25)+sin(angle)*.5,0,0)
			LerpTo.RightArm.To=LerpTo.RightArm.Cache*CFrame.Angles(rad(90)+sin(angle)*.2,rad(0),rad(-15))
			LerpTo.LeftArm.To=LerpTo.LeftArm.Cache*CFrame.Angles(rad(90)+sin(angle)*.2,rad(0),rad(15))
		elseif danceState == 14 then -- FLIPS :)
			anglespeed = 6
			LerpTo.RootJoint.To=LerpTo.RootJoint.Cache*CFrame.Angles(cos(1,360)*angle,0,0)
			LerpTo.RightArm.To=LerpTo.RightArm.Cache*CFrame.Angles(rad(45),rad(0),rad(0))
			LerpTo.LeftArm.To=LerpTo.LeftArm.Cache*CFrame.Angles(rad(45),rad(0),rad(0))
			LerpTo.RightLeg.To=LerpTo.RightLeg.Cache*CFrame.new(0,1,-.75)
			LerpTo.LeftLeg.To=LerpTo.LeftLeg.Cache*CFrame.new(0,1,-.75)
		elseif danceState == 15 then
			anglespeed = 3
			LerpTo.Neck.To = LerpTo.Neck.Cache * CFrame.Angles(rad(10),0,sin(yeet)*0.1)
			LerpTo.RootJoint.To = LerpTo.RootJoint.Cache * CFrame.Angles(rad(20),sin(angle)*0.2,sin(angle)*0.5) * CFrame.new(0,-abs(sin(angle))*2,0)
			LerpTo.RightArm.To = LerpTo.RightArm.Cache * CFrame.Angles(rad(90)-sin(angle)*1,0,-rad(10))
			LerpTo.LeftArm.To = LerpTo.LeftArm.Cache * CFrame.Angles(rad(90)-sin(angle)*1,0,rad(10))
			LerpTo.RightLeg.To = LerpTo.RightLeg.Cache * CFrame.Angles(rad(20),0,abs(sin(yeet))*0.1)
			LerpTo.LeftLeg.To = LerpTo.LeftLeg.Cache * CFrame.Angles(rad(20),0,-abs(sin(yeet))*0.1) 
		elseif danceState == 16 then
			anglespeed = 3
			LerpTo.Neck.To=LerpTo.Neck.Cache*CFrame.Angles(rad(0),rad(90),rad(0))
			LerpTo.RootJoint.To=LerpTo.RootJoint.Cache*CFrame.Angles(rad(90),rad(0),rad(0))*CFrame.new(0,-2.5,0)
			LerpTo.RightArm.To=LerpTo.RightArm.Cache*CFrame.Angles(rad(170),rad(0),rad(15))
			LerpTo.LeftArm.To=LerpTo.LeftArm.Cache*CFrame.Angles(rad(0),rad(0),rad(-75))
			LerpTo.RightLeg.To=LerpTo.RightLeg.Cache*CFrame.Angles(rad(0),rad(0),rad(0))
			LerpTo.LeftLeg.To=LerpTo.LeftLeg.Cache*CFrame.Angles(rad(0),rad(0),rad(0))
		elseif danceState == 17 then
			anglespeed = 2
			LerpTo.Neck.To = LerpTo.Neck.Cache * CFrame.Angles(math.pi/10-math.abs(sin(angle))*0.3,0, 0)
			LerpTo.RootJoint.To = LerpTo.RootJoint.Cache*CFrame.new(sin(angle)*2,0,0) * CFrame.Angles(math.pi/20,0,-sin(angle)*.5)
			LerpTo.RightArm.To = LerpTo.RightArm.Cache * CFrame.Angles(math.pi/3+math.abs(sin(angle)*.5), math.pi/20,  -math.pi/20)
			LerpTo.LeftArm.To = LerpTo.LeftArm.Cache * CFrame.Angles(math.pi/3+math.abs(sin(angle)*.5), -math.pi/20,  math.pi/20)
			LerpTo.RightLeg.To = LerpTo.RightLeg.Cache * CFrame.Angles(math.pi/20+sin(angle)*0.2, sin(angle)*0.08, rad(2.5))
			LerpTo.LeftLeg.To = LerpTo.LeftLeg.Cache * CFrame.Angles(math.pi/20-sin(angle)*0.2, -sin(angle)*0.08, -rad(2.5))
		elseif danceState == 18 then
			anglespeed = 4
			LerpTo.Neck.To = LerpTo.Neck.Cache * CFrame.Angles(0,sin(angle)*2,0)       
			LerpTo.RightArm.To = LerpTo.RightArm.Cache * CFrame.Angles(0, 0,  rad(90)-sin(angle)*1)
			LerpTo.LeftArm.To = LerpTo.LeftArm.Cache * CFrame.Angles(0,0,  rad(-90)+sin(angle)*1)
			LerpTo.RightLeg.To = LerpTo.RightLeg.Cache * CFrame.Angles(rad(0),rad(0),rad(0))
			LerpTo.LeftLeg.To = LerpTo.LeftLeg.Cache * CFrame.Angles(rad(0),rad(0),rad(0))
		elseif danceState == 19 then
			anglespeed = 4
			LerpTo.Neck.To = LerpTo.Neck.Cache * CFrame.Angles(rad(30),0,0)  
			LerpTo.RootJoint.To=LerpTo.RootJoint.Cache*CFrame.Angles(math.pi/5,0,0)     
			LerpTo.RightArm.To = LerpTo.RightArm.Cache * CFrame.Angles(rad(180)-sin(angle)*1,0,0)
			LerpTo.LeftArm.To = LerpTo.LeftArm.Cache * CFrame.Angles(rad(180)-sin(angle)*1,0,0)
			LerpTo.RightLeg.To = LerpTo.RightLeg.Cache * CFrame.Angles(rad(30),rad(0),rad(0))
			LerpTo.LeftLeg.To = LerpTo.LeftLeg.Cache * CFrame.Angles(rad(30),rad(0),rad(0))
		elseif danceState == 20 then
			anglespeed = 5
			LerpTo.RootJoint.To=LerpTo.RootJoint.Cache*CFrame.Angles(cos(1, 360)*angle,0,0)
			LerpTo.RightArm.To = LerpTo.RightArm.Cache * CFrame.Angles(rad(180),0,0)
			LerpTo.LeftArm.To = LerpTo.LeftArm.Cache * CFrame.Angles(rad(180),0,0)
		elseif danceState == 21 then
			anglespeed = 5
			LerpTo.RootJoint.To=LerpTo.RootJoint.Cache*CFrame.Angles(0,0,sin(angle)*1)
			LerpTo.RightArm.To=LerpTo.RightArm.Cache*CFrame.Angles(-sin(angle)*1,0,0)
			LerpTo.LeftArm.To=LerpTo.LeftArm.Cache*CFrame.Angles(sin(angle)*1,0,0)
			LerpTo.RightLeg.To=LerpTo.RightLeg.Cache*CFrame.Angles(sin(angle)*1,0,0)
			LerpTo.LeftLeg.To=LerpTo.LeftLeg.Cache*CFrame.Angles(-sin(angle)*1,0,0)
		elseif danceState == 22 then
			anglespeed = 5
			LerpTo.RootJoint.To=LerpTo.RootJoint.Cache*CFrame.Angles(0,cos(1, 360)*angle,0)
			LerpTo.RightArm.To = LerpTo.RightArm.Cache * CFrame.Angles(rad(180),0,0)
			LerpTo.LeftArm.To = LerpTo.LeftArm.Cache * CFrame.Angles(rad(180),0,0)
		elseif danceState == 23 then
			anglespeed = 3
			LerpTo.Neck.To=LerpTo.Neck.Cache*CFrame.Angles(rad(25),0,0)
			LerpTo.RootJoint.To=LerpTo.RootJoint.Cache*CFrame.Angles(0,0,sin(angle)*1)
			LerpTo.RightArm.To = LerpTo.RightArm.Cache * CFrame.Angles(0,0,rad(90)+sin(angle)*2)
			LerpTo.LeftArm.To = LerpTo.LeftArm.Cache * CFrame.Angles(0,0,-rad(90)-sin(angle)*2)
		end
	end
end)