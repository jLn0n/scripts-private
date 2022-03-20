-----------------------
--[[ Name : Chips ]]--
--[[ Description : I think I found my specialty in scripts ]]--
--[[ \ None / ]]--
-------------------------------------------------------
--A script By Creterisk/makhail07
--Discord Creterisk#2958
-------------------------------------------------------
--Everything is Meaningless.....

local Player = game:GetService("Players").LocalPlayer
local RunService = game:GetService("RunService")
local mouse = Player:GetMouse()
local Character = Player.Character[Player.UserId]
local Humanoid = Character.Humanoid
local hed = Character.Head
local root = Character:FindFirstChild'HumanoidRootPart'
local rootj = root.RootJoint
local tors = Character.Torso
local ra = Character["Right Arm"]
local la = Character["Left Arm"]
local rl = Character["Right Leg"]
local ll = Character["Left Leg"]
local neck = tors["Neck"]
local RootCF = CFrame.fromEulerAnglesXYZ(-1.57, 0, 3.14)
-------------------------------------------------------
--Start Good Stuff--
-------------------------------------------------------
local CF = CFrame.new
local angles = CFrame.Angles
local attack = false
local Rad = math.rad
local IT = Instance.new
local Cos = math.cos
local Sin = math.sin
-------------------------------------------------------
--End Good Stuff--
-------------------------------------------------------
local necko = CF(0, 1, 0, -1, -0, -0, 0, 0, 1, 0, 1, 0)
local RW = Instance.new("Weld")
local LW = Instance.new("Weld")
local RSH = tors["Right Shoulder"]
local LSH = tors["Left Shoulder"]
RSH.Parent = nil
LSH.Parent = nil
RW.Name = "RW"
RW.Part0 = tors
RW.C0 = CF(1.5, 0.5, 0)
RW.C1 = CF(0, 0.5, 0)
RW.Part1 = ra
RW.Parent = tors
LW.Name = "LW"
LW.Part0 = tors
LW.C0 = CF(-1.5, 0.5, 0)
LW.C1 = CF(0, 0.5, 0)
LW.Part1 = la
LW.Parent = tors
local newWeld = function(wp0, wp1, wc0x, wc0y, wc0z)
	local wld = Instance.new("Weld", wp1)
	wld.Part0 = wp0
	wld.Part1 = wp1
	wld.C0 = CFrame.new(wc0x, wc0y, wc0z)
end
newWeld(tors, ll, -0.5, -1, 0)
ll.Weld.C1 = CFrame.new(0, 1, 0)
newWeld(tors, rl, 0.5, -1, 0)
rl.Weld.C1 = CFrame.new(0, 1, 0)
-------------------------------------------------------
--Start Important Functions--
-------------------------------------------------------
local function swait(time)
	time = time or 1
	for _ = 1, time do
		RunService.Stepped:Wait()
	end
end
local function clerp(a, b, t)
	return a:lerp(b, t)
end
-------------------------------------------------------
--End Important Functions--
-------------------------------------------------------
local function Cso(ID, PARENT, VOLUME, PITCH)
	local NSound = nil
	coroutine.resume(coroutine.create(function()
		NSound = IT("Sound", PARENT)
		NSound.Volume = VOLUME
		NSound.Pitch = PITCH
		NSound.SoundId = "http://www.roblox.com/asset/?id="..ID
		wait()
		NSound:play()
		game:GetService("Debris"):AddItem(NSound, 10)
	end))
	return NSound
end
-------------------------------------------------------
--End Important Functions--
-------------------------------------------------------
-------------------------------------------------------
--Start Customization--
-------------------------------------------------------
local Player_Size = 1
local SONG = 525565668
local SONG2 = 0
local Music = Instance.new("Sound")
Music.Volume = 2.5
Music.Looped = true
Music.Pitch = 1 --Pitcher
Music.Parent = tors
----------------------------------------------------------------------------------
local equipped = false
local idle = 0
local change = 1
local sine = 0
local movelegs = false
local Speed = 56
local Chips = "onebearnakedwoman"
----------------------------------------------------------------------------------
Humanoid.JumpPower = 55
Humanoid.Animator.Parent = nil
----------------------------------------------------------------------------------
Chips = IT("Model")
Chips.Parent = Character
Chips.Name = "Chips"
local RHe = IT("Part")
RHe.Parent = Chips
RHe.BrickColor = BrickColor.new("Really black")
RHe.Locked = true
RHe.CanCollide = false
RHe.Transparency = 0
local PMesh = IT("SpecialMesh")
RHe.formFactor =  "Symmetric"
PMesh.MeshType = "FileMesh"
PMesh.MeshId = "rbxassetid://19106014"
PMesh.TextureId = "rbxassetid://342435650"
PMesh.Scale = Vector3.new(1, 1.4, 0.8)
PMesh.Parent = RHe
local RWeld = IT("Weld")
RWeld.Parent = RHe
RWeld.Part0 = RHe
RWeld.Part1 = ra
RWeld.C0 = CF(-1.2, -0.5, 0) * angles(Rad(90), Rad(0), Rad(90))
-------------------------------------------------------
--End Customization--
-------------------------------------------------------
-------------------------------------------------------
--Start Attacks N Stuff--
-------------------------------------------------------
local wait2 = false
local combo = 1
mouse.Button1Down:Connect(function(key)
	if attack == false then
		attack = true
		Speed = 3.01
		if combo == 1 and wait2 == false then
			wait2 = true
			for i = 0, 1.6, 0.1 do
				swait()
				rootj.C0 = clerp(rootj.C0, RootCF * CF(0* Player_Size, 0* Player_Size, -0.1 + 0.1* Player_Size * Cos(sine / 20)) * angles(Rad(0), Rad(0), Rad(-45)), 0.2)
				neck.C0 = clerp(neck.C0, necko* CF(0, 0, 0 + ((1* Player_Size) - 1)) * angles(Rad(0 - 5 * Sin(sine / 20)), Rad(0), Rad(45)), 0.2)
				rl.Weld.C0 = clerp(rl.Weld.C0, CF(0.5* Player_Size, -0.9 - 0.1 * Cos(sine / 20)* Player_Size, 0* Player_Size) * angles(Rad(0), Rad(-45), Rad(0)) * angles(Rad(0), Rad(0), Rad(15)), 0.2)
				ll.Weld.C0 = clerp(ll.Weld.C0, CF(-0.5* Player_Size, -0.9 - 0.1 * Cos(sine / 20)* Player_Size, 0* Player_Size) * angles(Rad(0), Rad(10), Rad(0)) * angles(Rad(0), Rad(0), Rad(-15)), 0.2)
				RW.C0 = clerp(RW.C0, CF(1.5* Player_Size, 0.5 + 0.1 * Sin(sine / 20)* Player_Size, 0* Player_Size) * angles(Rad(180), Rad(0 + 5 * Sin(sine / 20)), Rad(25 + 5 * Sin(sine / 20))), 0.2)
				LW.C0 = clerp(LW.C0, CF(-1.5* Player_Size, 0.5 + 0.1 * Sin(sine / 20)* Player_Size, 0* Player_Size) * angles(Rad(-20), Rad(0 - 5 * Sin(sine / 20)), Rad(-10 - 5 * Sin(sine / 20))), 0.2)
			end
			Cso("138097048", ra, 1.2, 0.8)
			for i = 0, 1.2, 0.1 do
				swait()
				rootj.C0 = clerp(rootj.C0, RootCF * CF(0* Player_Size, 0* Player_Size, -0.1 + 0.1* Player_Size * Cos(sine / 20)) * angles(Rad(20), Rad(0), Rad(45)), 0.3)
				neck.C0 = clerp(neck.C0, necko* CF(0, 0, 0 + ((1* Player_Size) - 1)) * angles(Rad(20 - 5 * Sin(sine / 20)), Rad(0), Rad(-45)), 0.3)
				rl.Weld.C0 = clerp(rl.Weld.C0, CF(0.5* Player_Size, -0.9 - 0.1 * Cos(sine / 20)* Player_Size, 0* Player_Size) * angles(Rad(20), Rad(-10), Rad(0)) * angles(Rad(0), Rad(0), Rad(15)), 0.3)
				ll.Weld.C0 = clerp(ll.Weld.C0, CF(-0.5* Player_Size, -0.9 - 0.1 * Cos(sine / 20)* Player_Size, 0* Player_Size) * angles(Rad(-20), Rad(45), Rad(0)) * angles(Rad(0), Rad(0), Rad(-15)), 0.3)
				RW.C0 = clerp(RW.C0, CF(1.5* Player_Size, 0.5 + 0.1 * Sin(sine / 20)* Player_Size, 0* Player_Size) * angles(Rad(85), Rad(0 + 5 * Sin(sine / 20)), Rad(45 + 5 * Sin(sine / 20))), 0.3)
				LW.C0 = clerp(LW.C0, CF(-1.5* Player_Size, 0.5 + 0.1 * Sin(sine / 20)* Player_Size, 0* Player_Size) * angles(Rad(-45), Rad(0 - 5 * Sin(sine / 20)), Rad(-25 - 5 * Sin(sine / 20))), 0.3)
			end
			combo = 1
		end
		Speed = 56
		wait2 = false
		attack = false
	end
end)
local function Taunt()
	attack = true
	Speed = 3
	if Chips == "onebearnakedwoman" then
		local Munch = Cso("1575472350", hed, 5, 1)
		swait(2)
		repeat
			swait()
			rootj.C0 = clerp(rootj.C0, RootCF * CF(0* Player_Size, 0* Player_Size, -0.2 + 0.1* Player_Size * Cos(sine / 20)) * angles(Rad(-20), Rad(0), Rad(0)), 0.3)
			neck.C0 = clerp(neck.C0, necko* CF(0, 0, 0 + ((1* Player_Size) - 1)) * angles(Rad(-35 - 5 * Sin(sine / 20)), Rad(0), Rad(0)), 0.3)
			rl.Weld.C0 = clerp(rl.Weld.C0, CF(0.5* Player_Size, -0.9 - 0.1 * Cos(sine / 20)* Player_Size, 0* Player_Size) * angles(Rad(-20), Rad(-10), Rad(0)) * angles(Rad(0), Rad(0), Rad(5)), 0.3)
			ll.Weld.C0 = clerp(ll.Weld.C0, CF(-0.5* Player_Size, -0.9 - 0.1 * Cos(sine / 20)* Player_Size, 0* Player_Size) * angles(Rad(-20), Rad(10), Rad(0)) * angles(Rad(0), Rad(0), Rad(-5)), 0.3)
			RW.C0 = clerp(RW.C0, CF(1* Player_Size, 0.1 + 0.1 * Sin(sine / 20)* Player_Size, -0.6* Player_Size) * angles(Rad(160), Rad(0), Rad(-35)), 0.1)
			LW.C0 = clerp(LW.C0, CF(-1.5* Player_Size, 0.5 + 0.1 * Sin(sine / 20)* Player_Size, 0* Player_Size) * angles(Rad(-20), Rad(0 - 5 * Sin(sine / 20)), Rad(-10 - 5 * Sin(sine / 20))), 0.3)
		until Munch.Playing == false
	elseif Chips == "layonme" then
		for i = 0, 6, 0.1 do
			swait()
			rootj.C0 = clerp(rootj.C0, RootCF * CF(0* Player_Size, 0* Player_Size, -0.1 + 0.1* Player_Size * Cos(sine / 20)) * angles(Rad(0), Rad(0), Rad(0)), 0.1)
			neck.C0 = clerp(neck.C0, necko* CF(0, 0, 0 + ((1* Player_Size) - 1)) * angles(Rad(0), Rad(0), Rad(0 - 255.45 * i)), 0.15)
			rl.Weld.C0 = clerp(rl.Weld.C0, CF(0.5* Player_Size, -0.9 - 0.1 * Cos(sine / 20)* Player_Size, 0* Player_Size) * angles(Rad(0), Rad(-10), Rad(0)) * angles(Rad(0), Rad(0), Rad(5)), 0.1)
			ll.Weld.C0 = clerp(ll.Weld.C0, CF(-0.5* Player_Size, -0.9 - 0.1 * Cos(sine / 20)* Player_Size, 0* Player_Size) * angles(Rad(0), Rad(10), Rad(0)) * angles(Rad(0), Rad(0), Rad(-5)), 0.1)
			RW.C0 = clerp(RW.C0, CF(1.5* Player_Size, 0.5 + 0.1 * Sin(sine / 20)* Player_Size, 0* Player_Size) * angles(Rad(10), Rad(30 + 5 * Sin(sine / 20)), Rad(45 + 5 * Sin(sine / 20))), 0.1)
			LW.C0 = clerp(LW.C0, CF(-1.5* Player_Size, 0.5 + 0.1 * Sin(sine / 20)* Player_Size, 0* Player_Size) * angles(Rad(10), Rad(-30 - 5 * Sin(sine / 20)), Rad(-45 - 5 * Sin(sine / 20))), 0.1)
		end
	elseif Chips == "howitfeelstochew5gum" then
		local Munch = Cso("1575472350", hed, 5, 1)
		swait(2)
		repeat
			swait()
			rootj.C0 = clerp(rootj.C0, RootCF * CF(0* Player_Size, 0* Player_Size, -0.2 + 0.1* Player_Size * Cos(sine / 20)) * angles(Rad(-20), Rad(0), Rad(0)), 0.3)
			neck.C0 = clerp(neck.C0, necko* CF(0, 0, 0 + ((1* Player_Size) - 1)) * angles(Rad(-35 - 5 * Sin(sine / 20)), Rad(0), Rad(0)), 0.3)
			rl.Weld.C0 = clerp(rl.Weld.C0, CF(0.5* Player_Size, -0.9 - 0.1 * Cos(sine / 20)* Player_Size, 0* Player_Size) * angles(Rad(-20), Rad(-10), Rad(0)) * angles(Rad(0), Rad(0), Rad(5)), 0.3)
			ll.Weld.C0 = clerp(ll.Weld.C0, CF(-0.5* Player_Size, -0.9 - 0.1 * Cos(sine / 20)* Player_Size, 0* Player_Size) * angles(Rad(-20), Rad(10), Rad(0)) * angles(Rad(0), Rad(0), Rad(-5)), 0.3)
			RW.C0 = clerp(RW.C0, CF(1* Player_Size, 0.1 + 0.1 * Sin(sine / 20)* Player_Size, -0.6* Player_Size) * angles(Rad(160), Rad(0), Rad(-35)), 0.1)
			LW.C0 = clerp(LW.C0, CF(-1.5* Player_Size, 0.5 + 0.1 * Sin(sine / 20)* Player_Size, 0* Player_Size) * angles(Rad(-20), Rad(0 - 5 * Sin(sine / 20)), Rad(-10 - 5 * Sin(sine / 20))), 0.3)
		until Munch.Playing == false
		Cso("172324194", hed, 5, 1)
		for i = 0, 5, 0.1 do
			swait()
			rootj.C0 = clerp(rootj.C0, RootCF * CF(0* Player_Size, 0* Player_Size, -0.2 * Player_Size) * angles(Rad(-20), Rad(0), Rad(0)), 0.3)
			neck.C0 = clerp(neck.C0, necko* CF(0, 0, 0 + ((1* Player_Size) - 1)) * angles(Rad(-35), Rad(0), Rad(0)), 0.3)
			rl.Weld.C0 = clerp(rl.Weld.C0, CF(0.5* Player_Size, -0.9 * Player_Size, 0* Player_Size) * angles(Rad(-20), Rad(-10), Rad(0)) * angles(Rad(0), Rad(0), Rad(5)), 0.3)
			ll.Weld.C0 = clerp(ll.Weld.C0, CF(-0.5* Player_Size, -0.9 * Player_Size, 0* Player_Size) * angles(Rad(-20), Rad(10), Rad(0)) * angles(Rad(0), Rad(0), Rad(-5)), 0.3)
			RW.C0 = clerp(RW.C0, CF(1* Player_Size, 0.1* Player_Size, -0.6* Player_Size) * angles(Rad(160), Rad(0), Rad(-35)), 0.1)
			LW.C0 = clerp(LW.C0, CF(-1.5* Player_Size, 0.5* Player_Size, 0* Player_Size) * angles(Rad(-20), Rad(0), Rad(-10)), 0.3)
		end
		local RUN = Cso("957655044", hed, 5, 1)
		swait(2)
		repeat
			swait()
			Speed = 56
			local WALKSPEEDVALUE = 6 / (Humanoid.WalkSpeed / 16)
			root.Velocity = root.CFrame.lookVector * 75
			rootj.C0 = clerp(rootj.C0, RootCF * CF(0* Player_Size, 0* Player_Size, -0.3 - 0.65 * Cos(sine / ( WALKSPEEDVALUE / 2 ))) * angles(Rad(-25), Rad(0), Rad(0 - 1.75 * Cos(sine / ( WALKSPEEDVALUE / 2))) + root.RotVelocity.Y / 75), 0.1)
			neck.C0 = clerp(neck.C0, necko* CF(0, 0, 0 + ((1* Player_Size) - 1)) * angles(Rad(-20 + 5 * Sin(sine / (WALKSPEEDVALUE / 2))), Rad(0), Rad(0) + root.RotVelocity.Y / 13), 0.1)
			rl.Weld.C0 = clerp(rl.Weld.C0, CF(0.5* Player_Size, -0.8 - 0.5 * Cos(sine / WALKSPEEDVALUE) / 2* Player_Size, 0.6 * Cos(sine / WALKSPEEDVALUE) / 2* Player_Size)  * angles(Rad(-15 - 95 * Cos(sine / WALKSPEEDVALUE)) - root.RotVelocity.Y / 75 + -Sin(sine / WALKSPEEDVALUE) / 2.5, Rad(0 - 10 * Cos(sine / WALKSPEEDVALUE)), Rad(0)) * angles(Rad(0 + 2 * Cos(sine / WALKSPEEDVALUE)), Rad(0), Rad(0)), 0.3)
		 	ll.Weld.C0 = clerp(ll.Weld.C0, CF(-0.5* Player_Size, -0.8 + 0.5 * Cos(sine / WALKSPEEDVALUE) / 2* Player_Size, -0.6 * Cos(sine / WALKSPEEDVALUE) / 2* Player_Size) * angles(Rad(-15 + 95 * Cos(sine / WALKSPEEDVALUE)) + root.RotVelocity.Y / -75 + Sin(sine / WALKSPEEDVALUE) / 2.5, Rad(0 - 10 * Cos(sine / WALKSPEEDVALUE)), Rad(0)) * angles(Rad(0 - 2 * Cos(sine / WALKSPEEDVALUE)), Rad(0), Rad(0)), 0.3)
			RW.C0 = clerp(RW.C0, CF(1.5* Player_Size, 0.5 + 0.1 * Sin(sine / WALKSPEEDVALUE)* Player_Size, 0* Player_Size) * angles(Rad(215), Rad(0), Rad(45)), 0.1)
			LW.C0 = clerp(LW.C0, CF(-1.5* Player_Size, 0.5 + 0.1 * Sin(sine / WALKSPEEDVALUE)* Player_Size, 0* Player_Size) * angles(Rad(215), Rad(0), Rad(-45)), 0.1)
		until RUN.Playing == false
	elseif Chips == "5gumdowngrade" then
		Cso("1826625760", hed, 5, 1)
		for i = 0, 5, 0.1 do
			swait()
			rootj.C0 = clerp(rootj.C0, RootCF * CF(0* Player_Size, 0* Player_Size, -0.1 + 0.1* Player_Size * Cos(sine / 20)) * angles(Rad(0), Rad(0), Rad(0)), 0.1)
			neck.C0 = clerp(neck.C0, necko* CF(0, 0, 0 + ((1* Player_Size) - 1)) * angles(Rad(20 - 5 * Sin(sine / 20)), Rad(0), Rad(0)), 0.1)
			rl.Weld.C0 = clerp(rl.Weld.C0, CF(0.5* Player_Size, -0.9 - 0.1 * Cos(sine / 20)* Player_Size, 0* Player_Size) * angles(Rad(0), Rad(-10), Rad(0)) * angles(Rad(0), Rad(0), Rad(5)), 0.1)
			ll.Weld.C0 = clerp(ll.Weld.C0, CF(-0.5* Player_Size, -0.9 - 0.1 * Cos(sine / 20)* Player_Size, 0* Player_Size) * angles(Rad(0), Rad(10), Rad(0)) * angles(Rad(0), Rad(0), Rad(-5)), 0.1)
			RW.C0 = clerp(RW.C0, CF(1.5* Player_Size, 0.5 + 0.1 * Sin(sine / 20)* Player_Size, 0* Player_Size) * angles(Rad(0), Rad(0 + 5 * Sin(sine / 20)), Rad(10 + 5 * Sin(sine / 20))), 0.1)
			LW.C0 = clerp(LW.C0, CF(-1.5* Player_Size, 0.5 + 0.1 * Sin(sine / 20)* Player_Size, 0* Player_Size) * angles(Rad(0), Rad(0 - 5 * Sin(sine / 20)), Rad(-10 - 5 * Sin(sine / 20))), 0.1)
		end
	end
	Speed = 56
	movelegs = false
	attack = false
end
local function Gum()
	attack = true
	Speed = 0
	local Senses = Cso("605297168", hed, 6, 1)
	swait(2)
	repeat
		swait()
		rootj.C0 = clerp(rootj.C0, RootCF * CF(0* Player_Size, 0* Player_Size, -0.1 + 0.1* Player_Size * Cos(sine / 20)) * angles(Rad(0), Rad(0), Rad(20)), 0.2)
		neck.C0 = clerp(neck.C0, necko* CF(0, 0, 0 + ((1* Player_Size) - 1)) * angles(Rad(0 - 5 * Sin(sine / 20)), Rad(0), Rad(-20)), 0.2)
		rl.Weld.C0 = clerp(rl.Weld.C0, CF(0.5* Player_Size, -0.9 - 0.1 * Cos(sine / 20)* Player_Size, 0* Player_Size) * angles(Rad(0), Rad(-10), Rad(0)) * angles(Rad(0), Rad(0), Rad(5)), 0.2)
		ll.Weld.C0 = clerp(ll.Weld.C0, CF(-0.5* Player_Size, -0.9 - 0.1 * Cos(sine / 20)* Player_Size, 0* Player_Size) * angles(Rad(0), Rad(10), Rad(0)) * angles(Rad(0), Rad(0), Rad(-5)), 0.2)
		RW.C0 = clerp(RW.C0, CF(1.5* Player_Size, 0.5 + 0.1 * Sin(sine / 20)* Player_Size, 0* Player_Size) * angles(Rad(0), Rad(0 + 5 * Sin(sine / 20)), Rad(10 + 5 * Sin(sine / 20))), 0.2)
		LW.C0 = clerp(LW.C0, CF(-1.5* Player_Size, 0.5 + 0.1 * Sin(sine / 20)* Player_Size, 0* Player_Size) * angles(Rad(0), Rad(0), Rad(-90)), 0.2)
	until Senses.TimePosition > 2.7
	for i = 0, 3, 0.1 do
		swait()
		rootj.C0 = clerp(rootj.C0, RootCF * CF(0* Player_Size, 0* Player_Size, -0.1 + 0.1* Player_Size) * angles(Rad(-30), Rad(0), Rad(0)), 0.5)
		neck.C0 = clerp(neck.C0, necko* CF(0, 0, 0 + ((1* Player_Size) - 1)) * angles(Rad(0), Rad(0), Rad(0)), 0.5)
		rl.Weld.C0 = clerp(rl.Weld.C0, CF(0.5* Player_Size, -0.9* Player_Size, 0* Player_Size) * angles(Rad(0), Rad(-10), Rad(0)) * angles(Rad(0), Rad(0), Rad(5)), 0.5)
		ll.Weld.C0 = clerp(ll.Weld.C0, CF(-0.5* Player_Size, -0.9* Player_Size, 0* Player_Size) * angles(Rad(0), Rad(10), Rad(0)) * angles(Rad(0), Rad(0), Rad(-5)), 0.5)
		RW.C0 = clerp(RW.C0, CF(1.5* Player_Size, 0.5* Player_Size, 0* Player_Size) * angles(Rad(0), Rad(0), Rad(10)), 0.5)
		LW.C0 = clerp(LW.C0, CF(-1.5* Player_Size, 0.5* Player_Size, 0* Player_Size) * angles(Rad(0), Rad(0), Rad(-90)), 0.5)
	end
	root.Anchored = true
	repeat
		swait()
		rootj.C0 = clerp(rootj.C0, RootCF * CF(0* Player_Size, 0* Player_Size, -2.7 + 0.1* Player_Size) * angles(Rad(90), Rad(0), Rad(0)), 0.5)
		neck.C0 = clerp(neck.C0, necko* CF(0, 0, 0 + ((1* Player_Size) - 1)) * angles(Rad(0), Rad(0), Rad(0)), 0.5)
		rl.Weld.C0 = clerp(rl.Weld.C0, CF(0.5* Player_Size, -0.9* Player_Size, 0* Player_Size) * angles(Rad(0), Rad(-10), Rad(0)) * angles(Rad(0), Rad(0), Rad(5)), 0.5)
		ll.Weld.C0 = clerp(ll.Weld.C0, CF(-0.5* Player_Size, -0.9* Player_Size, 0* Player_Size) * angles(Rad(0), Rad(10), Rad(0)) * angles(Rad(0), Rad(0), Rad(-5)), 0.5)
		RW.C0 = clerp(RW.C0, CF(1.5* Player_Size, 0.5* Player_Size, 0* Player_Size) * angles(Rad(0), Rad(0), Rad(10)), 0.5)
		LW.C0 = clerp(LW.C0, CF(-1.5* Player_Size, 0.5* Player_Size, 0* Player_Size) * angles(Rad(0), Rad(0), Rad(-90)), 0.5)
	until Senses.Playing == false
	Speed = 56
	attack = false
	root.Anchored = false
end
local function OHHHHHHH()
	root.Anchored = true
	attack = true
	Speed = 0
	Cso("663306786", tors, 3, 1)
	for i = 0, 12, 0.1 do
		swait()
		rootj.C0 = clerp(rootj.C0, RootCF * CF(0* Player_Size, 0 + 1 * i * Player_Size, -0.1 + 0.1* Player_Size * Cos(sine / 20)) * angles(Rad(-20), Rad(0), Rad(0)), 0.1)
		neck.C0 = clerp(neck.C0, necko* CF(0, 0, 0 + ((1* Player_Size) - 1)) * angles(Rad(20 - 5 * Sin(sine / 20)), Rad(0), Rad(0)), 0.1)
		rl.Weld.C0 = clerp(rl.Weld.C0, CF(0.5* Player_Size, -0.9 - 0.1 * Cos(sine / 20)* Player_Size, 0* Player_Size) * angles(Rad(47), Rad(-10), Rad(0)) * angles(Rad(0), Rad(0), Rad(5)), 0.1)
		ll.Weld.C0 = clerp(ll.Weld.C0, CF(-0.5* Player_Size, -0.9 - 0.1 * Cos(sine / 20)* Player_Size, 0* Player_Size) * angles(Rad(65), Rad(10), Rad(0)) * angles(Rad(0), Rad(0), Rad(-5)), 0.1)
		RW.C0 = clerp(RW.C0, CF(1.5* Player_Size, 0.5 + 0.1 * Sin(sine / 20)* Player_Size, 0* Player_Size) * angles(Rad(75), Rad(0 + 5 * Sin(sine / 20)), Rad(10 + 5 * Sin(sine / 20))), 0.1)
		LW.C0 = clerp(LW.C0, CF(-1.5* Player_Size, 0.5 + 0.1 * Sin(sine / 20)* Player_Size, 0* Player_Size) * angles(Rad(143), Rad(0 - 5 * Sin(sine / 20)), Rad(-10 - 5 * Sin(sine / 20))), 0.1)
	end
	Cso("663307468", tors, 6, 1)
	for i = 0, 6, 0.1 do
		swait()
		rootj.C0 = clerp(rootj.C0, RootCF * CF(0* Player_Size, 4500 * Player_Size, -0.1 + 0.1* Player_Size * Cos(sine / 20)) * angles(Rad(-20), Rad(0), Rad(0)), 0.15)
		neck.C0 = clerp(neck.C0, necko* CF(0, 0, 0 + ((1* Player_Size) - 1)) * angles(Rad(20 - 5 * Sin(sine / 20)), Rad(0), Rad(0)), 0.1)
		rl.Weld.C0 = clerp(rl.Weld.C0, CF(0.5* Player_Size, -0.9 - 0.1 * Cos(sine / 20)* Player_Size, 0* Player_Size) * angles(Rad(47), Rad(-10), Rad(0)) * angles(Rad(0), Rad(0), Rad(5)), 0.1)
		ll.Weld.C0 = clerp(ll.Weld.C0, CF(-0.5* Player_Size, -0.9 - 0.1 * Cos(sine / 20)* Player_Size, 0* Player_Size) * angles(Rad(65), Rad(10), Rad(0)) * angles(Rad(0), Rad(0), Rad(-5)), 0.1)
		RW.C0 = clerp(RW.C0, CF(1.5* Player_Size, 0.5 + 0.1 * Sin(sine / 20)* Player_Size, 0* Player_Size) * angles(Rad(75), Rad(0 + 5 * Sin(sine / 20)), Rad(10 + 5 * Sin(sine / 20))), 0.1)
		LW.C0 = clerp(LW.C0, CF(-1.5* Player_Size, 0.5 + 0.1 * Sin(sine / 20)* Player_Size, 0* Player_Size) * angles(Rad(156), Rad(0 - 5 * Sin(sine / 20)), Rad(-10 - 5 * Sin(sine / 20))), 0.1)
	end
	Speed = 56
	attack = false
	wait(1.15)
	root.Anchored = false
end
local function WoodyGotWood()
	attack = true
	Speed = 0
	local Woodlenny = Cso("1764642350", hed, 6, 1)
	swait(2)
	repeat
		swait()
		rootj.C0 = clerp(rootj.C0, RootCF * CF(0* Player_Size, 0* Player_Size, -0.1 + 0.1* Player_Size * Cos(sine / 5)) * angles(Rad(20), Rad(0), Rad(5)), 0.2)
		neck.C0 = clerp(neck.C0, necko* CF(0, 0, 0 + ((1* Player_Size) - 1)) * angles(Rad(20), Rad(0), Rad(-5 - 15 * Sin(sine / 20))), 0.2)
		rl.Weld.C0 = clerp(rl.Weld.C0, CF(0.5* Player_Size, -0.9 - 0.1 * Cos(sine / 5)* Player_Size, 0* Player_Size) * angles(Rad(20), Rad(-10), Rad(0)) * angles(Rad(0), Rad(0), Rad(5)), 0.2)
		ll.Weld.C0 = clerp(ll.Weld.C0, CF(-0.5* Player_Size, -0.9 - 0.1 * Cos(sine / 5)* Player_Size, 0* Player_Size) * angles(Rad(20), Rad(10), Rad(0)) * angles(Rad(0), Rad(0), Rad(-5)), 0.2)
		RW.C0 = clerp(RW.C0, CF(1.5* Player_Size, 0.5 + 0.1 * Sin(sine / 5)* Player_Size, 0* Player_Size) * angles(Rad(0), Rad(0), Rad(10)), 0.2)
		LW.C0 = clerp(LW.C0, CF(-1.5* Player_Size, 0.5 + 0.1 * Sin(sine / 5)* Player_Size, 0* Player_Size) * angles(Rad(20), Rad(0), Rad(-10)), 0.2)
	until Woodlenny.TimePosition > 3.6
	root.Anchored = true
	repeat
		swait()
		for _ = 0, 2, 0.1 do
			swait()
			rootj.C0 = clerp(rootj.C0, RootCF * CF(0* Player_Size, 0* Player_Size, -2.7 + 0.1* Player_Size) * angles(Rad(-90), Rad(0), Rad(0)), 0.5)
			neck.C0 = clerp(neck.C0, necko* CF(0, 0, 0 + ((1* Player_Size) - 1)) * angles(Rad(0), Rad(0), Rad(0)), 0.5)
			rl.Weld.C0 = clerp(rl.Weld.C0, CF(0.5* Player_Size, -0.9* Player_Size, 0* Player_Size) * angles(Rad(0), Rad(-10), Rad(0)) * angles(Rad(0), Rad(0), Rad(5)), 0.5)
			ll.Weld.C0 = clerp(ll.Weld.C0, CF(-0.5* Player_Size, -0.9* Player_Size, 0* Player_Size) * angles(Rad(0), Rad(10), Rad(0)) * angles(Rad(0), Rad(0), Rad(-5)), 0.5)
			RW.C0 = clerp(RW.C0, CF(1.5* Player_Size, 0.5* Player_Size, 0* Player_Size) * angles(Rad(0), Rad(0), Rad(90)), 0.5)
			LW.C0 = clerp(LW.C0, CF(-1.5* Player_Size, 0.5* Player_Size, 0* Player_Size) * angles(Rad(0), Rad(0), Rad(-90)), 0.5)
		end
		for i = 0, 1.6, 0.1 do
			swait()
			rootj.C0 = clerp(rootj.C0, RootCF * CF(0* Player_Size, 0* Player_Size, -2.4 + 0.1* Player_Size) * angles(Rad(-90), Rad(0), Rad(0)), 0.5)
			neck.C0 = clerp(neck.C0, necko* CF(0, 0, 0 + ((1* Player_Size) - 1)) * angles(Rad(0), Rad(0), Rad(0)), 0.5)
			rl.Weld.C0 = clerp(rl.Weld.C0, CF(0.5* Player_Size, -0.9* Player_Size, 0* Player_Size) * angles(Rad(0), Rad(-10), Rad(0)) * angles(Rad(0), Rad(0), Rad(5)), 0.5)
			ll.Weld.C0 = clerp(ll.Weld.C0, CF(-0.5* Player_Size, -0.9* Player_Size, 0* Player_Size) * angles(Rad(0), Rad(10), Rad(0)) * angles(Rad(0), Rad(0), Rad(-5)), 0.5)
			RW.C0 = clerp(RW.C0, CF(1.5* Player_Size, 0.5* Player_Size, 0* Player_Size) * angles(Rad(0), Rad(0), Rad(75)), 0.5)
			LW.C0 = clerp(LW.C0, CF(-1.5* Player_Size, 0.5* Player_Size, 0* Player_Size) * angles(Rad(0), Rad(0), Rad(-75)), 0.5)
		end
	until Woodlenny.Playing == false
	Speed = 56
	attack = false
	root.Anchored = false
end
-------------------------------------------------------
--End Attacks N Stuff--
-------------------------------------------------------
mouse.KeyDown:Connect(function(key)
	if attack == false then
		if key == "t" then
			Taunt()
		elseif key == "z" then
			Gum()
		elseif key == "x" then
			OHHHHHHH()
		elseif key == "c" then
			WoodyGotWood()
		elseif key == "f" then
			SONG = 690663957
			Music.TimePosition = 0
			PMesh.TextureId = "rbxassetid://206977326"
			Chips = "cheesexd"
		elseif key == "m" then
			SONG = 525565668
			Music.TimePosition = 0
			PMesh.TextureId = "rbxassetid://342435650"
			Chips = "onebearnakedwoman"
		elseif key == "n" then
			SONG = 937445925
			Music.TimePosition = 0
			PMesh.TextureId = "rbxassetid://342436716"
			Chips = "layonme"
		elseif key == "b" then
			SONG = 1386299751
			Music.TimePosition = 0
			PMesh.TextureId = "rbxassetid://341999291"
			Chips = "howitfeelstochew5gum"
		elseif key == "v" then
			SONG = 554967156
			Music.TimePosition = 0
			PMesh.TextureId = "rbxassetid://341999245"
			Chips = "5gumdowngrade"
		end
	end
end)
-------------------------------------------------------
--Start Animations--
-------------------------------------------------------
while true and Character.Parent ~= nil do
	swait()
	sine = sine + change
	local humState = string.lower(Humanoid:GetState().Name)
	if equipped == true or equipped == false then
		if attack == false then
			idle = idle + 1
		else
			idle = 0
		end
		local WALKSPEEDVALUE = 6 / (Humanoid.WalkSpeed / 16)
		local State = (
			((humState == "running" or humState == "runningnophysics") and Humanoid.MoveDirection == Vector3.new()) and "Idle" or
			(humState == "running" or humState == "runningnophysics") and "Walk" or
			(humState == "jumping" and Humanoid.Jump) and "Jump" or
			humState == "freefall" and "Fall" or
			humState == "landed" and "Land"
		)
		if (State == 'Jump') then
			Humanoid.JumpPower = 55
			if attack == false then
				rootj.C0 = clerp(rootj.C0, RootCF * CF(0* Player_Size, 0* Player_Size, -0.1 + 0.1 * Cos(sine / 20)* Player_Size) * angles(Rad(-16), Rad(0), Rad(0)), 0.1)
				neck.C0 = clerp(neck.C0, necko* CF(0, 0, 0 + ((1* Player_Size) - 1)) * angles(Rad(10 - 2.5 * Sin(sine / 30)), Rad(0), Rad(0)), 0.3)
				rl.Weld.C0 = clerp(rl.Weld.C0, CF(0.5* Player_Size, -.2 - 0.1 * Cos(sine / 20), -.3* Player_Size) * angles(Rad(0), Rad(-10), Rad(0)) * angles(Rad(-2.5), Rad(0), Rad(0)), 0.1)
				ll.Weld.C0 = clerp(ll.Weld.C0, CF(-0.5* Player_Size, -.9 - 0.1 * Cos(sine / 20), -.5* Player_Size) * angles(Rad(0), Rad(10), Rad(0)) * angles(Rad(-2.5), Rad(0), Rad(0)), 0.1)
				RW.C0 = clerp(RW.C0, CF(1.5* Player_Size, 0.5 + 0.02 * Sin(sine / 20)* Player_Size, 0* Player_Size) * angles(Rad(25), Rad(-.6), Rad(13 + 4.5 * Sin(sine / 20))), 0.1)
				LW.C0 = clerp(LW.C0, CF(-1.5* Player_Size, 0.5 + 0.02 * Sin(sine / 20)* Player_Size, 0* Player_Size) * angles(Rad(25), Rad(-.6), Rad(-13 - 4.5 * Sin(sine / 20))), 0.1)
			end
		elseif(State == 'Fall')then
			if attack == false then
				rootj.C0 = clerp(rootj.C0, RootCF * CF(0* Player_Size, 0* Player_Size, -0.1 + 0.1 * Cos(sine / 20)* Player_Size) * angles(Rad(25), Rad(0), Rad(0)), 0.1)
				neck.C0 = clerp(neck.C0, necko* CF(0, 0, 0 + ((1* Player_Size) - 1)) * angles(Rad(10 - 2.5 * Sin(sine / 30)), Rad(0), Rad(0)), 0.3)
				rl.Weld.C0 = clerp(rl.Weld.C0, CF(0.5* Player_Size, -1 - 0.1 * Cos(sine / 20)* Player_Size, -.3* Player_Size) * angles(Rad(0), Rad(-10), Rad(0)) * angles(Rad(25), Rad(0), Rad(0)), 0.1)
				ll.Weld.C0 = clerp(ll.Weld.C0, CF(-0.5* Player_Size, -.8 - 0.1 * Cos(sine / 20)* Player_Size, -.3* Player_Size) * angles(Rad(0), Rad(10), Rad(0)) * angles(Rad(25), Rad(0), Rad(0)), 0.1)
				RW.C0 = clerp(RW.C0, CF(1.5* Player_Size, 0.5 + 0.02 * Sin(sine / 20)* Player_Size, 0* Player_Size) * angles(Rad(165), Rad(-.6), Rad(45 + 4.5 * Sin(sine / 20))), 0.1)
				LW.C0 = clerp(LW.C0, CF(-1.5* Player_Size, 0.5 + 0.02 * Sin(sine / 20)* Player_Size, 0* Player_Size) * angles(Rad(165), Rad(-.6), Rad(-45 - 4.5 * Sin(sine / 20))), 0.1)
			end
		elseif(State == 'Land')then
			Humanoid.JumpPower = 0
			if attack == false then
				rootj.C0 = clerp(rootj.C0, RootCF * CF(0* Player_Size, 0* Player_Size, -1 + 0.1 * Cos(sine / 20)* Player_Size) * angles(Rad(10), Rad(0), Rad(0)), 0.15)
				neck.C0 = clerp(neck.C0, necko* CF(0, 0, 0 + ((1* Player_Size) - 1)) * angles(Rad(35 - 2.5 * Sin(sine / 30)), Rad(0), Rad(0)), 0.3)
				rl.Weld.C0 = clerp(rl.Weld.C0, CF(0.5* Player_Size, 0.1 - 0.1 * Cos(sine / 20)* Player_Size, -.3* Player_Size) * angles(Rad(0), Rad(-10), Rad(0)) * angles(Rad(-3.5), Rad(0), Rad(5)), 0.15)
				ll.Weld.C0 = clerp(ll.Weld.C0, CF(-0.5* Player_Size, 0.1 - 0.1 * Cos(sine / 20)* Player_Size, -.3* Player_Size) * angles(Rad(0), Rad(10), Rad(0)) * angles(Rad(-3.5), Rad(0), Rad(-5)), 0.15)
				RW.C0 = clerp(RW.C0, CF(1.5* Player_Size, 0.5 + 0.02 * Sin(sine / 20)* Player_Size, 0* Player_Size) * angles(Rad(65), Rad(0), Rad(25 + 4.5 * Sin(sine / 20))), 0.1)
				LW.C0 = clerp(LW.C0, CF(-1.5* Player_Size, 0.5 + 0.02 * Sin(sine / 20)* Player_Size, 0* Player_Size) * angles(Rad(55), Rad(0), Rad(-25 - 4.5 * Sin(sine / 20))), 0.1)
			end
		elseif(State == 'Idle')then
			change = 1
			if attack == false then
				rootj.C0 = clerp(rootj.C0, RootCF * CF(0* Player_Size, 0* Player_Size, -0.1 + 0.1* Player_Size * Cos(sine / 20)) * angles(Rad(0 - 5 * Sin(sine / 20)), Rad(0), Rad(0)), 0.1)
				neck.C0 = clerp(neck.C0, necko* CF(0, 0, 0 + ((1* Player_Size) - 1)) * angles(Rad(0 - 5 * Sin(sine / 20)), Rad(0), Rad(0)), 0.1)
				rl.Weld.C0 = clerp(rl.Weld.C0, CF(0.5* Player_Size, -0.9 - 0.1 * Cos(sine / 20)* Player_Size, 0* Player_Size) * angles(Rad(0 - 5 * Sin(sine / 20)), Rad(-10), Rad(0)) * angles(Rad(0), Rad(0), Rad(5)), 0.1)
				ll.Weld.C0 = clerp(ll.Weld.C0, CF(-0.5* Player_Size, -0.9 - 0.1 * Cos(sine / 20)* Player_Size, 0* Player_Size) * angles(Rad(0 - 5 * Sin(sine / 20)), Rad(10), Rad(0)) * angles(Rad(0), Rad(0), Rad(-5)), 0.1)
				RW.C0 = clerp(RW.C0, CF(1.5* Player_Size, 0.5 + 0.1 * Sin(sine / 20)* Player_Size, 0* Player_Size) * angles(Rad(0 + 15 * Sin(sine / 20)), Rad(0 + 5 * Sin(sine / 20)), Rad(10 + 5 * Sin(sine / 20))), 0.1)
				LW.C0 = clerp(LW.C0, CF(-1.5* Player_Size, 0.5 + 0.1 * Sin(sine / 20)* Player_Size, 0* Player_Size) * angles(Rad(0 + 15 * Sin(sine / 20)), Rad(0 - 5 * Sin(sine / 20)), Rad(-10 - 5 * Sin(sine / 20))), 0.1)
			end
		elseif(State == 'Walk')then
			change = 0.55
			Humanoid.JumpPower = 55
			if attack == false then
				rootj.C0 = clerp(rootj.C0, RootCF * CF(0* Player_Size, 0* Player_Size, -0.3 - 0.65 * Cos(sine / ( WALKSPEEDVALUE / 2 ))) * angles(Rad(-25), Rad(0), Rad(0 - 1.75 * Cos(sine / ( WALKSPEEDVALUE / 2))) + root.RotVelocity.Y / 75), 0.1)
				neck.C0 = clerp(neck.C0, necko* CF(0, 0, 0 + ((1* Player_Size) - 1)) * angles(Rad(-20 + 5 * Sin(sine / (WALKSPEEDVALUE / 2))), Rad(0), Rad(0) + root.RotVelocity.Y / 13), 0.1)
				rl.Weld.C0 = clerp(rl.Weld.C0, CF(0.5* Player_Size, -0.8 - 0.5 * Cos(sine / WALKSPEEDVALUE) / 2* Player_Size, 0.6 * Cos(sine / WALKSPEEDVALUE) / 2* Player_Size)  * angles(Rad(-15 - 95 * Cos(sine / WALKSPEEDVALUE)) - root.RotVelocity.Y / 75 + -Sin(sine / WALKSPEEDVALUE) / 2.5, Rad(0 - 10 * Cos(sine / WALKSPEEDVALUE)), Rad(0)) * angles(Rad(0 + 2 * Cos(sine / WALKSPEEDVALUE)), Rad(0), Rad(0)), 0.3)
		 		ll.Weld.C0 = clerp(ll.Weld.C0, CF(-0.5* Player_Size, -0.8 + 0.5 * Cos(sine / WALKSPEEDVALUE) / 2* Player_Size, -0.6 * Cos(sine / WALKSPEEDVALUE) / 2* Player_Size) * angles(Rad(-15 + 95 * Cos(sine / WALKSPEEDVALUE)) + root.RotVelocity.Y / -75 + Sin(sine / WALKSPEEDVALUE) / 2.5, Rad(0 - 10 * Cos(sine / WALKSPEEDVALUE)), Rad(0)) * angles(Rad(0 - 2 * Cos(sine / WALKSPEEDVALUE)), Rad(0), Rad(0)), 0.3)
				RW.C0 = clerp(RW.C0, CF(1.5* Player_Size, 0.5 + 0.1 * Sin(sine / WALKSPEEDVALUE)* Player_Size, 0* Player_Size) * angles(Rad(215), Rad(0), Rad(45)), 0.1)
				LW.C0 = clerp(LW.C0, CF(-1.5* Player_Size, 0.5 + 0.1 * Sin(sine / WALKSPEEDVALUE)* Player_Size, 0* Player_Size) * angles(Rad(215), Rad(0), Rad(-45)), 0.1)
			elseif attack == true and movelegs == true then
				rl.Weld.C0 = clerp(rl.Weld.C0, CF(0.5* Player_Size, -0.8 - 0.5 * Cos(sine / WALKSPEEDVALUE) / 2* Player_Size, 0.6 * Cos(sine / WALKSPEEDVALUE) / 2* Player_Size)  * angles(Rad(-10 - 25 * Cos(sine / WALKSPEEDVALUE)) - root.RotVelocity.Y / 75 + -Sin(sine / WALKSPEEDVALUE) / 2.5, Rad(0 - 10 * Cos(sine / WALKSPEEDVALUE)), Rad(0)) * angles(Rad(0 + 2 * Cos(sine / WALKSPEEDVALUE)), Rad(0), Rad(0)), 0.3)
		 		ll.Weld.C0 = clerp(ll.Weld.C0, CF(-0.5* Player_Size, -0.8 + 0.5 * Cos(sine / WALKSPEEDVALUE) / 2* Player_Size, -0.6 * Cos(sine / WALKSPEEDVALUE) / 2* Player_Size) * angles(Rad(-10 + 25 * Cos(sine / WALKSPEEDVALUE)) + root.RotVelocity.Y / -75 + Sin(sine / WALKSPEEDVALUE) / 2.5, Rad(0 - 10 * Cos(sine / WALKSPEEDVALUE)), Rad(0)) * angles(Rad(0 - 2 * Cos(sine / WALKSPEEDVALUE)), Rad(0), Rad(0)), 0.3)
			end
		end
	end
	Humanoid.WalkSpeed = Speed
	Music.SoundId = "rbxassetid://"..SONG
	Music.Looped = true
	Music.Volume = 1.5
	Music.Playing = true
end
-------------------------------------------------------
--End Animations And Script--
-------------------------------------------------------
