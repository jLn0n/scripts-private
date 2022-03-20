local Player = game.Players.LocalPlayer
local count = 0
local countspeed = 1
local sine = 0
local sinespeed = 1
local angle = nil
local global_wait = 0
--dance booleans--
local jerk = false
local party = false
local canttouch = false
local happy = false
local spin = false
local thriller = false
local barrel = false
local sax = false
local spooky = false
local stride = false
local shuffle = false
local rock = false
local gagnam = false
local snoop = false
local darude = false
local taco = false
-------------------
--custom animate--
local walk = false
local jump = false
local sit = false
local run = false
------------------
--walk keys--
local W = false
local A = false
local S = false
local D = false
-------------
local m = Instance.new("Model",game.Players.LocalPlayer.Character) m.Name = "ModelParts"
local miniweld = nil
local rootpart = nil

local Mouse = nil
local Animate = nil
local Music = nil
local Asset = "http://www.roblox.com/asset/?id="
local Animating = nil
local humanoid = nil
local face = nil

local head = nil
local torso = nil
local ra = nil
local la = nil
local rl = nil
local ll = nil
local rs = nil
local ls = nil
local rh = nil
local lh = nil
local neck = nil
local rj = nil

local char = nil

----------musics-----------------
local M1,M2,M3,M4,M5,M6,M7,M8,M9,M10,M11,M12,M13,M14,M15,M16 = nil
---------------------------------
function AnimationStop()
	jerk = false
	party = false
	canttouch = false
	happy = false
	spin = false
	thriller = false
	barrel = false
	sax = false
	spooky = false
	stride = false
	shuffle = false
	rock = false
	gagnam = false
	snoop = false
	darude = false
	taco = false
end

local Musical
function SetMusic(id,volume)
	Musical = Instance.new("Sound",char.Head)
	if volume == nil then
		Musical.Volume = 1
	else
		Musical.Volume = volume
	end
	Musical.Looped = true
	Musical.SoundId = Asset .. id
	return Musical
end

function Generate(player)
	char = player.Character
	humanoid = char.Humanoid
	if char:FindFirstChild("Head") then
		if char.Head:FindFirstChild("face") ~= nil then
			face = char.Head:FindFirstChild("face")
			face.Texture = "rbxasset://textures/face.png"
		end
	----------musics---------------
		M1=SetMusic(168007346)
		M2=SetMusic(144901116)
		M3=SetMusic(168570436)
		M4=SetMusic(142435409)
		M5=SetMusic(131525189)
		M6=SetMusic(133196268)
		M7=SetMusic(130791919)
		M8=SetMusic(130794684)
		M9=SetMusic(155313239)
		M10=SetMusic(158036870)
		M11=SetMusic(145262991)
		M12=SetMusic(151430448)
		M13=SetMusic(130844430)
		M14=SetMusic(172388329)
		M15=SetMusic(179534184)
		M16=SetMusic(142295308)
	-------------------------------

		if char:FindFirstChild("HumanoidRootPart") ~= nil then
			rootpart = char:FindFirstChild("HumanoidRootPart")
		end
		Mouse = player:GetMouse()
		Music = Instance.new("Sound",char.Head)
		Music.Volume = 1
		Music.Looped = true
		Music.SoundId = Asset

		head = char:FindFirstChild("Head")
		torso = char:FindFirstChild("Torso")
		ra = char:FindFirstChild("Right Arm")
		la = char:FindFirstChild("Left Arm")
		rl = char:FindFirstChild("Right Leg")
		ll = char:FindFirstChild("Left Leg")
		rs = torso:FindFirstChild("Right Shoulder")
		ls = torso:FindFirstChild("Left Shoulder")
		rh = torso:FindFirstChild("Right Hip")
		lh = torso:FindFirstChild("Left Hip")
		neck = torso:FindFirstChild("Neck")
		rj = char:FindFirstChild("HumanoidRootPart"):FindFirstChild("RootJoint")

		if humanoid ~= nil then
			humanoid.Changed:Connect(function(pro)
				if pro == "MoveDirection" or pro == "Jump" then
					if Music.IsPlaying == true then
						AnimationStop()
					end
				end
			end)
			humanoid.Died:Connect(function()
				AnimationStop()
			end)

			Mouse.KeyUp:Connect(function(key)
				if key == "w" then
					W = false
				end
				if key == "a" then
					A = false
				end
				if key == "s" then
					S = false
				end
				if key == "d" then
					D = false
				end
				if string.byte(key) == 48 then
					run = false
				end
			end)

			Mouse.KeyDown:Connect(function(key)
				if key == "w" then
					W = true
					AnimationStop()
				end
				if key == "a" then
					A = true
					AnimationStop()
				end
				if key == "s" then
					S = true
					AnimationStop()
				end
				if key == "d" then
					D = true
					AnimationStop()
				end

				KeyUsed(key)
			end)
		end
	end
end

function KeyUsed(key)
	if humanoid ~= nil then
		if string.byte(key) == 32 then
			jump = true
			AnimationStop()
		end
		if string.byte(key) == 50 then
			AnimationStop()
			if sit == true then
				sit = false
			else
				sit = true
			end
		end
		if string.byte(key) == 48 then
			run = true
		end
		if W == false and A == false and S == false and D == false and jump == false and sit == false then
			if key == "Q" or key == "q" then
				AnimationStop()
				canttouch = true
				M1:Play()
			end
			if key == "E" or key == "e" then
				AnimationStop()
				party = true
				M2:Play()
			end
			if key == "R" or key == "r" then
				AnimationStop()
				jerk = true
				M3:Play()
			end
			if key == "T" or key == "t" then
				AnimationStop()
				happy = true
				M4:Play()
			end
			if key == "Y" or key == "y" then
				AnimationStop()
				spin = true
				M5:Play()
			end
			if key == "U" or key == "u" then
				AnimationStop()
				thriller = true
				M6:Play()
			end
			if key == "F" or key == "f" then
				AnimationStop()
				barrel = true
				M7:Play()
			end
			if key == "P" or key == "p" then
				AnimationStop()
				sax = true
				M8:Play()
			end
			if key == "G" or key == "g" then
				AnimationStop()
				spooky = true
				M9:Play()
			end
			if key == "H" or key == "h" then
				AnimationStop()
				stride = true
				M10:Play()
			end
			if key == "J" or key == "j" then
				AnimationStop()
				shuffle = true
				M11:Play()
			end
			if key == "K" or key == "k" then
				AnimationStop()
				rock = true
				M12:Play()
			end
			if key == "L" or key == "l" then
				AnimationStop()
				gagnam = true
				M13:Play()
			end
			if key == "Z" or key == "z" then
				AnimationStop()
				snoop = true
				M14:Play()
			end
			if key == "X" or key == "x" then
				AnimationStop()
				darude = true
				M15:Play()
			end
			if key == "C" or key == "c" then
				AnimationStop()
				taco = true
				M16:Play()
			end
		end
	end
end

Generate(Player)

game:GetService("RunService").Stepped:Connect(function()
	count = (count % 100) + countspeed
	angle = math.pi * math.sin(math.pi*2/100*count)
	countspeed = 1

	local state = char["NETLESS-REANIMATE"].Dummy.Humanoid:GetState()
	if state ~= Enum.HumanoidStateType.Freefall then
		jump = false
	else
		jump = true
		sit = false
		AnimationStop()
	end

	if canttouch == false then
		M1:Stop()
	end
	if party == false then
		M2:Stop()
	end
	if jerk == false then
		M3:Stop()
	end
	if happy == false then
		M4:Stop()
	end
	if spin == false then
		M5:Stop()
	end
	if thriller == false then
		M6:Stop()
	end
	if barrel == false then
		M7:Stop()
	end
	if sax == false then
		M8:Stop()
	end
	if spooky == false then
		M9:Stop()
	end
	if stride == false then
		M10:Stop()
	end
	if shuffle == false then
		M11:Stop()
	end
	if rock == false then
		M12:Stop()
	end
	if gagnam == false then
		M13:Stop()
	end
	if snoop == false then
		M14:Stop()
	end
	if darude == false then
		M15:Stop()
	end
	if taco == false then
		M16:Stop()
	end

	if run == true and sit == false then
		humanoid.WalkSpeed = 25
	elseif sit == true then
		humanoid.WalkSpeed = 0
	else
		humanoid.WalkSpeed = 16
	end

	if global_wait == 380 then global_wait = 0 end

	if (W == false or A == false or S == false or D == false) and jump == false and sit == false then
			ls.C1 = CFrame.new(0,0.5,-0.5) * CFrame.Angles(0, 0, 0 - angle/75)
			rs.C1 = CFrame.new(0,0.5,-0.5) * CFrame.Angles(0, 0, 0 - angle/75)
			lh.C1 = CFrame.new(0,1,0.5) * CFrame.Angles(0, 0, 0 + angle/75)
			rh.C1 = CFrame.new(0,1,0.5) * CFrame.Angles(0, 0, 0 + angle/75)
			neck.C1 = CFrame.new(0,-0.5,0) * CFrame.Angles(math.pi/2 + angle/75, math.pi, 0)
			rj.C0 = CFrame.new(0, 0, 0) * CFrame.Angles(math.pi/2, math.pi, 0)
	end


	if (W == false or A == false or S == false or D == false) and jump == false and sit == true then
		local ray = Ray.new(torso.Position, Vector3.new(0, -3, 0))
		local hitz,enz = workspace:FindPartOnRay(ray, char)
		if hitz then
			if rootpart:FindFirstChild("Weld") == nil then
				miniweld = Instance.new("Weld", rootpart)
				miniweld.C0 = hitz.CFrame:toObjectSpace(rootpart.CFrame)
				miniweld.Part0 = hitz
				miniweld.Part1 = rootpart
				humanoid.PlatformStand = true
			end
		end
	else
		if rootpart:FindFirstChild("Weld") ~= nil then
			rootpart:FindFirstChild("Weld"):Destroy()
			humanoid.PlatformStand = false
		end
	end

	if (W == false or A == false or S == false or D == false) and jump == false and sit == true then
		ls.C1 = CFrame.new(0,0.5,-0.5) * CFrame.Angles(0, 0, 0 - math.pi/15)
		rs.C1 = CFrame.new(0,0.5,-0.5) * CFrame.Angles(0, 0, 0 + math.pi/15)
		lh.C1 = CFrame.new(0,1,0.5) * CFrame.Angles(0 + math.pi/8, 0, math.pi/2 - math.pi/15)
		rh.C1 = CFrame.new(0,1,0.5) * CFrame.Angles(0 + math.pi/8, 0, -math.pi/2 + math.pi/15)
		neck.C1 = CFrame.new(0,-0.5,0) * CFrame.Angles(math.pi/2 + math.pi/15, math.pi, 0)
		rj.C0 = CFrame.new(0, -2, 0) * CFrame.Angles(math.pi/2 + math.pi/15, math.pi, 0)
	end

	if jump == true and sit == false then
		countspeed = 2
		ls.C1 = CFrame.new(0,0.5,-0.5) * CFrame.Angles(0, 0, math.pi + angle/12)
		rs.C1 = CFrame.new(0,0.5,-0.5) * CFrame.Angles(0, 0, math.pi + angle/12)
		lh.C1 = CFrame.new(0,1,0.5) * CFrame.Angles(0, 0, 0 + angle/12)
		rh.C1 = CFrame.new(0,1,0.5) * CFrame.Angles(0, 0, 0 + angle/12)
		neck.C1 = CFrame.new(0,-0.5,0) * CFrame.Angles(math.pi/2 + angle/25, math.pi, 0)
		rj.C0 = CFrame.new(0, 0, 0) * CFrame.Angles(math.pi/2+ angle/50, math.pi, 0)
	end

	if (W == true or A == true or S == true or D == true) and jump == false and sit == false then
		if run == true then
			countspeed = 4
			ls.C1 = CFrame.new(0,0.5,-0.5) * CFrame.Angles(0, 0, 0 - angle/3)
			rs.C1 = CFrame.new(0,0.5,-0.5) * CFrame.Angles(0, 0, 0 - angle/3)
			lh.C1 = CFrame.new(0,1,0.5) * CFrame.Angles(0, 0, 0 + angle/5)
			rh.C1 = CFrame.new(0,1,0.5) * CFrame.Angles(0, 0, 0 + angle/5)
			neck.C1 = CFrame.new(0,-0.5,0) * CFrame.Angles(math.pi/2 + angle/20, math.pi, 0)
			rj.C0 = CFrame.new(0, 0, 0) * CFrame.Angles(math.pi/2 + angle/40, math.pi, 0)
		else
			countspeed = 2
			ls.C1 = CFrame.new(0,0.5,-0.5) * CFrame.Angles(0, 0, 0 - angle/4)
			rs.C1 = CFrame.new(0,0.5,-0.5) * CFrame.Angles(0, 0, 0 - angle/4)
			lh.C1 = CFrame.new(0,1,0.5) * CFrame.Angles(0, 0, 0 + angle/6)
			rh.C1 = CFrame.new(0,1,0.5) * CFrame.Angles(0, 0, 0 + angle/6)
			neck.C1 = CFrame.new(0,-0.5,0) * CFrame.Angles(math.pi/2 + angle/25, math.pi, 0)
			rj.C0 = CFrame.new(0, 0, 0) * CFrame.Angles(math.pi/2+ angle/50, math.pi, 0)
		end
	end

	if W == false and A == false and S == false and D == false and jump == false and sit == false then
		if jerk == true and jump == false and sit == false then
			countspeed = 2
			ls.C1 = CFrame.new(0,0.5,-0.5) * CFrame.Angles(angle/5, 0, angle/4)
			rs.C1 = CFrame.new(0,0.5,-0.5) * CFrame.Angles(angle/5, 0, -angle/4)
			lh.C1 = CFrame.new(0,1,0.5) * CFrame.Angles(angle/10, 0, angle/5)-- * CFrame.Angles(angle*0.5, 0, -math.abs(angle*0.15))
			rh.C1 = CFrame.new(0,1,0.5) * CFrame.Angles(angle/10, 0, angle/5)-- * CFrame.Angles(-angle*0.5, 0, math.abs(angle*0.15))
			neck.C1 = CFrame.new(0,-0.5,0) * CFrame.Angles(math.pi/2 + angle/5, math.pi, 0)
			rj.C0 = CFrame.new(0, 0, 0) * CFrame.Angles(math.pi/2 + angle/5, math.pi, 0)
		elseif party == true and jump == false and sit == false then
			countspeed = 4
			lh.C1 = CFrame.new(0,1,0.5) * CFrame.Angles(angle/15, 0, angle/15)
			rh.C1 = CFrame.new(0,1,0.5) * CFrame.Angles(angle/15, 0, angle/15)
			ls.C1 = CFrame.new(0.25,0.5 + 1 * angle/10,0.5) * CFrame.Angles(math.pi  + angle/10, 0, 0 + angle/10)
			rs.C1 = CFrame.new(-0.25,0.5 + 1 * angle/10,0.5) * CFrame.Angles(math.pi  + angle/10, 0, 0  + angle/10)
			neck.C1 = CFrame.new(0,-0.5,0) * CFrame.Angles(math.pi/2 + angle/10, math.pi, 0)
			rj.C0 = CFrame.new(0, 0.5 + angle/5, 0) * CFrame.Angles(math.pi/2, math.pi, 0)
		elseif canttouch == true and jump == false and sit == false then
			countspeed = 2
			ls.C1 = CFrame.new(0,0.5,-0.5) * CFrame.Angles(0 + angle/8, 0, math.pi/12 + angle/12)
			rs.C1 = CFrame.new(0,0.5,-0.5) * CFrame.Angles(0 + angle/8, 0, -math.pi/12 - angle/12)
			lh.C1 = CFrame.new(0.35,0.7,0.5) * CFrame.Angles(0 + angle/10, 0, -math.pi/8)
			rh.C1 = CFrame.new(-0.35,0.7,0.5) * CFrame.Angles(0 + angle/10, 0, math.pi/8)
			neck.C1 = CFrame.new(0,-0.5,0) * CFrame.Angles(math.pi/2 + angle/15, math.pi, 0)
			rj.C0 = CFrame.new(angle/4, -0.3 + angle/20, 0) * CFrame.Angles(math.pi/2, math.pi, 0)
		elseif happy == true and jump == false and sit == false then
			countspeed = 4
			ls.C1 = CFrame.new(0,0.5,-0.5) * CFrame.Angles(math.pi/4, math.pi/8 + angle/8, math.pi/4 + angle/8)
			rs.C1 = CFrame.new(0,0.5,-0.5) * CFrame.Angles(math.pi/4, -math.pi/8 + angle/8, -math.pi/4 + angle/8)
			lh.C1 = CFrame.new(0,1,0.5) * CFrame.Angles(0 + angle/10, 0, 0  + angle/10)
			rh.C1 = CFrame.new(0,1,0.5) * CFrame.Angles(0 + angle/10, 0, 0  + angle/10)
			neck.C1 = CFrame.new(0,-0.5,0) * CFrame.Angles(math.pi/2 + angle/15, math.pi + angle/15, 0 + angle/15)
			rj.C0 = CFrame.new(0, 0 + angle/20, 0) * CFrame.Angles(math.pi/2, math.pi, 0)
		elseif spin == true and jump == false and sit == false then
			global_wait = (global_wait % 360) + 4
			countspeed = 4
			ls.C1 = CFrame.new(0,1,0) * CFrame.Angles(math.pi/2, 0 + angle/10, 0 + angle/10)
			rs.C1 = CFrame.new(0,1,0) * CFrame.Angles(math.pi/2, 0 - angle/10, 0 + angle/10)
			lh.C1 = CFrame.new(0,1,0.5) * CFrame.Angles(0 + angle/10, 0 + angle/10, 0  + angle/10)
			rh.C1 = CFrame.new(0,1,0.5) * CFrame.Angles(0 + angle/10, 0 + angle/10, 0  + angle/10)
			neck.C1 = CFrame.new(0,-0.5,0) * CFrame.Angles(math.pi/2, math.pi, 0)
			rj.C0 = CFrame.new(0 + angle/25, 0, 0 - angle/25) * CFrame.Angles(math.pi/2, math.pi, math.rad(global_wait*4))
		elseif thriller == true and jump == false and sit == false then
			countspeed = 2
			ls.C1 = CFrame.new(0,0.5,-0.5) * CFrame.Angles(0, 0, math.pi/2 + angle/15)
			rs.C1 = CFrame.new(0,0.5,-0.5) * CFrame.Angles(0, 0, -math.pi/2 + angle/15)
			lh.C1 = CFrame.new(0,1,0.5) * CFrame.Angles(math.pi/60 - angle/45, 0, 0 + angle/15)
			rh.C1 = CFrame.new(0,1,0.5) * CFrame.Angles(math.pi/60 + angle/45, 0, 0 + angle/15)
			neck.C1 = CFrame.new(0,-0.5,0) * CFrame.Angles(math.pi/2 + angle/15, math.pi + angle/10, 0)
			rj.C0 = CFrame.new(0, 0, 0) * CFrame.Angles(math.pi/2 + angle/50 , math.pi + angle/50, 0 + angle/50)
		elseif barrel == true and jump == false and sit == false then
			ls.C1 = CFrame.new(0,0.5,-0.5) * CFrame.Angles(0, 0, math.pi)
			rs.C1 = CFrame.new(0,0.5,-0.5) * CFrame.Angles(0, 0, math.pi)
			lh.C1 = CFrame.new(0,1,0.5) * CFrame.Angles(0, 0, 0)
			rh.C1 = CFrame.new(0,1,0.5) * CFrame.Angles(0, 0, 0)
			neck.C1 = CFrame.new(0,-0.5,0) * CFrame.Angles(math.pi/2, math.pi, 0)
			rj.C0 = CFrame.new(0 + angle, -1.8, 0) * CFrame.Angles(0, math.pi, 0 + angle)
		elseif sax == true and jump == false and sit == false then
			countspeed = 2
			ls.C1 = CFrame.new(0,0.75,-0.25) * CFrame.Angles(-math.pi/5, 0, math.pi/2 - math.abs(angle/30))
			rs.C1 = CFrame.new(0,0.75,-0.25) * CFrame.Angles(-math.pi/5, 0, -math.pi/2 + math.abs(angle/30))
			lh.C1 = CFrame.new(0,1,0.5) * CFrame.Angles(0, 0, 0 - math.abs(angle/30))
			rh.C1 = CFrame.new(0,1,0.5) * CFrame.Angles(0, 0, 0 + math.abs(angle/30))
			neck.C1 = CFrame.new(0,-0.5,0) * CFrame.Angles(math.pi/2, math.pi, 0)
			rj.C0 = CFrame.new(0, -math.abs(angle*0.05), math.abs(angle*0.025)) * CFrame.Angles(math.pi/2 + math.abs(angle/20), math.pi, 0)
		elseif spooky == true and jump == false and sit == false then
			countspeed = 3
			ls.C1 = CFrame.new(0,0.5,-0.5) * CFrame.Angles(0, 0, math.pi/2 - angle/1.5)
			rs.C1 = CFrame.new(0,0.5,-0.5) * CFrame.Angles(0, 0, -math.pi/2 + angle/1.5)
			lh.C1 = CFrame.new(0,1,0.5) * CFrame.Angles(0, 0, 0 - angle/16)
			rh.C1 = CFrame.new(0,1,0.5) * CFrame.Angles(0, 0, 0 + angle/16)
			neck.C1 = CFrame.new(0,-0.5,0) * CFrame.Angles(math.pi/2  + angle/12, math.pi, 0)
			rj.C0 = CFrame.new(0, 0 + angle / 35, 0) * CFrame.Angles(math.pi/2 + angle/25, math.pi, 0)
		elseif stride == true and jump == false and sit == false then
			countspeed = 2.5
			ls.C1 = CFrame.new(0,0.5,-0.5) * CFrame.Angles(angle/16, angle/16,math.pi/3.5 + angle/8)
			rs.C1 = CFrame.new(0,0.5,-0.5) * CFrame.Angles(angle/16, -angle/16,-math.pi/1.5 + -angle/8)
			lh.C1 = CFrame.new(0,1,0.5) * CFrame.Angles(0, angle/16, angle/16)
			rh.C1 = CFrame.new(0,1,0.5) * CFrame.Angles(0, angle/16, angle/16)
			neck.C1 = CFrame.new(0,-0.5,0) * CFrame.Angles(math.pi/2, math.pi, 0)
			rj.C0 = CFrame.new(0, 0, 0) * CFrame.Angles(math.pi/2-angle/16, math.pi, 0)
		elseif shuffle == true and jump == false and sit == false then
			countspeed = 2
			ls.C1 = CFrame.new(0,0.75,-0.35) * CFrame.Angles(math.pi/8, 0, math.pi/2 + angle/3.5)
			rs.C1 = CFrame.new(0,0.75,-0.35) * CFrame.Angles(math.pi/8, 0, -math.pi/2 + angle/3.5)
			lh.C1 = CFrame.new(0 + angle/50,1,0.5) * CFrame.Angles(0, 0 + angle/35, 0 + angle/15)
			rh.C1 = CFrame.new(0 + angle/50,1,0.5) * CFrame.Angles(0, 0 + angle/35, 0 + angle/15)
			neck.C1 = CFrame.new(0,-0.5,0) * CFrame.Angles(math.pi/2 + angle/15, math.pi, 0)
			rj.C0 = CFrame.new(0, 0, 0) * CFrame.Angles(math.pi/2 - angle/35, math.pi - angle/35, 0)
		elseif rock == true and jump == false and sit == false then
			countspeed = 4
			ls.C1 = CFrame.new(0,0.5,-0.5) * CFrame.Angles(0, 0, math.pi/2+angle/2)
			rs.C1 = CFrame.new(0,0.5,-0.5) * CFrame.Angles(0, 0, -math.pi/2+angle/2)
			lh.C1 = CFrame.new(0,1,0.5) * CFrame.Angles(0+angle/32, 0, 0+angle/32)
			rh.C1 = CFrame.new(0,1,0.5) * CFrame.Angles(0+angle/32, 0, 0-angle/32)
			neck.C1 = CFrame.new(0,-0.5,0) * CFrame.Angles(math.pi/2, math.pi, 0)
			rj.C0 = CFrame.new(0, 0 - angle/50, 0) * CFrame.Angles(math.pi/2, math.pi, 0)
		elseif gagnam == true and jump == false and sit == false then
			countspeed = 4
			ls.C1 = CFrame.new(0,0.75,-0.15) * CFrame.Angles(-math.pi/4, 0, (math.pi/2 + angle/14) - math.pi/20)
			rs.C1 = CFrame.new(0,0.75,-0.15) * CFrame.Angles(-math.pi/4, 0, (-math.pi/2 - angle/14) + math.pi/20)
			lh.C1 = CFrame.new(0,1,0.5) * CFrame.Angles(0 + angle/16, 0, 0)
			rh.C1 = CFrame.new(0,1,0.5) * CFrame.Angles(0 + angle/16, 0, 0)
			neck.C1 = CFrame.new(0,-0.5,0) * CFrame.Angles(math.pi/2 + angle/20, math.pi, 0)
			rj.C0 = CFrame.new(0, 0 + angle/40, 0) * CFrame.Angles(math.pi/2, math.pi, 0)
		elseif snoop == true and jump == false and sit == false then
			countspeed = 2
			ls.C1 = CFrame.new(0,0.5,-0.5) * CFrame.Angles(math.pi/12, 0, math.pi/4 + angle/4)
			rs.C1 = CFrame.new(0,0.5,-0.5) * CFrame.Angles(math.pi/12, 0, -math.pi/4 + angle/4)
			lh.C1 = CFrame.new(0,1,0.5) * CFrame.Angles(math.pi/24, 0, 0 + angle/4)
			rh.C1 = CFrame.new(0,1,0.5) * CFrame.Angles(math.pi/24, 0, 0 + angle/4)
			neck.C1 = CFrame.new(0,-0.5,0) * CFrame.Angles(math.pi/2 - angle/8, math.pi, 0)
			rj.C0 = CFrame.new(0, 0 + angle/48, 0) * CFrame.Angles(math.pi/2 + angle/24, math.pi, 0)
		elseif darude == true and jump == false and sit == false then
			countspeed = 3
			ls.C1 = CFrame.new(0,0.5,-0.5) * CFrame.Angles(0, 0, 0 + angle/1.5)
			rs.C1 = CFrame.new(0,0.5,-0.5) * CFrame.Angles(0, 0, 0 + angle/3)
			lh.C1 = CFrame.new(0,1,0.5) * CFrame.Angles(0, 0, 0 - angle/3)
			rh.C1 = CFrame.new(0,1,0.5) * CFrame.Angles(0, 0, 0 - angle/1.5)
			neck.C1 = CFrame.new(0,-0.5,0) * CFrame.Angles(math.pi/2, math.pi, 0)
			rj.C0 = CFrame.new(0, 0+ angle/45, 0) * CFrame.Angles(math.pi/2 - angle/6, math.pi, 0)
		elseif taco == true and jump == false and sit == false then
			countspeed = 4
			global_wait = (global_wait % 360) + 4
			ls.C1 = CFrame.new(0,1,-0.25) * CFrame.Angles(math.pi/6 + angle/12, 0, math.pi)
			rs.C1 = CFrame.new(0,1,-0.25) * CFrame.Angles(math.pi/6 + angle/12, 0, math.pi)
			lh.C1 = CFrame.new(0,1,0.5) * CFrame.Angles(0, 0, math.pi/8 + angle/16)
			rh.C1 = CFrame.new(0,1,0.5) * CFrame.Angles(0, 0, math.pi/8 + angle/16)
			neck.C1 = CFrame.new(0,-0.5,0) * CFrame.Angles(math.pi/2 - math.pi/8 + angle/16, math.pi, 0)
			rj.C0 = CFrame.new(0, 0.25 + angle/12, 0) * CFrame.Angles(math.pi/2, math.pi, math.rad(global_wait*4))
		end
	end
end)