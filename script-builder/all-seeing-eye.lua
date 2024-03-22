local players = game:GetService("Players")
local runService = game:GetService("RunService")

local owner_char = owner.Character

local script_args = {...}
local eye_static_pos = owner_char:GetPivot().Position + (Vector3.yAxis * 10)

local shoot_cooldown = tonumber(script_args[1]) or 2.5
local shoot_debounce = os.clock()

local the_eye = Instance.new("Part")
the_eye.Name = "The All Seeing Eye"
the_eye.Anchored = true
the_eye.Shape = Enum.PartType.Ball
the_eye.Position = eye_static_pos
the_eye.Size = (Vector3.one * 10)
the_eye.BrickColor = BrickColor.new("Black metallic")
the_eye.Parent = script

local the_eye_highlight = Instance.new("Highlight")
the_eye_highlight.DepthMode = Enum.HighlightDepthMode.Occluded
the_eye_highlight.FillColor = Color3.fromRGB(121, 129, 143)
the_eye_highlight.FillTransparency = 0.85
the_eye_highlight.OutlineColor = Color3.fromRGB(243, 245, 244)
the_eye_highlight.OutlineTransparency = 0
the_eye_highlight.Parent = the_eye

local the_eye_texture = Instance.new("Decal")
the_eye_texture.Face = Enum.NormalId.Front
the_eye_texture.Texture = "rbxassetid://13945743757"
the_eye_texture.Parent = the_eye

local laser_proj = Instance.new("Part")
laser_proj.Name = "Eye's Laser"
laser_proj.Size = Vector3.new(1, 1, 2)
laser_proj.Anchored = true
laser_proj.Material = Enum.Material.Neon
laser_proj.CanCollide = false
laser_proj.BrickColor = BrickColor.new("Bright yellow")

local function set_part_surface(part, surfaceType)
	part.TopSurface = surfaceType
	part.BottomSurface = surfaceType
	part.LeftSurface = surfaceType
	part.RightSurface = surfaceType
	part.FrontSurface = surfaceType
	part.BackSurface = surfaceType
end

local function update_projectile_direction(projectile, direction, speed)
	local accumulated_time = 0
	local connection = runService.Heartbeat:Connect(function(delta_time)
		if accumulated_time >= 1 / 15 then
			accumulated_time = 0
			return
		end
		accumulated_time += delta_time

		local current_pos = projectile.CFrame + (direction * speed)
		projectile.CFrame = projectile.CFrame:Lerp(current_pos, math.min(delta_time / (workspace.Gravity / 60), 1))
	end)

	projectile.Destroying:Connect(function()
		connection:Disconnect()
	end)
end

local function init_projectile_raycaster(projectile)
	while true do task.wait(1/15)
		local proj_direction = projectile.CFrame.LookVector
		local raycast_result = workspace:Shapecast(projectile, proj_direction / 2)

		if raycast_result then
			local explosion = Instance.new("Explosion")
			explosion.BlastRadius = 1
			explosion.ExplosionType = Enum.ExplosionType.NoCraters
			explosion.Position = raycast_result.Position
			explosion.Parent = script

			projectile:Destroy()
			break
		end
	end
end

local function shoot_laser(dir_pos)
	local projectile = laser_proj:Clone()
	local direction = the_eye.CFrame.LookVector

	local raycaster_thread = task.spawn(init_projectile_raycaster, projectile)
	update_projectile_direction(projectile, direction, tonumber(script_args[2]) or 1.5)

	task.delay(10, function()
		projectile:Destroy()
		task.cancel(raycaster_thread)
	end)
	projectile.CFrame = CFrame.lookAt(eye_static_pos + direction * (the_eye.Size.Magnitude / 2), dir_pos)
	projectile.Parent = script
end

local function get_nearest_player()
	local nearest_plr_data = {
		distance = math.huge,
		position = nil
	}

	for _, player in players:GetPlayers() do
		local player_char = player.Character
		if not player_char then continue end
		local player_pos = player_char:GetPivot().Position
		local magnitude_range = (the_eye.Position - player_pos).Magnitude

		if (magnitude_range <= nearest_plr_data.distance) then
			nearest_plr_data.distance = magnitude_range
			nearest_plr_data.position = player_pos
		end
	end

	return nearest_plr_data
end

set_part_surface(the_eye, Enum.SurfaceType.Smooth)

local accumulated_time = 0
while true do
	local delta_time = runService.Stepped:Wait()
	if accumulated_time >= 1 / 15 then
		accumulated_time = 0
		continue
	end
	accumulated_time += delta_time

	local nearest_plr_data = get_nearest_player()
	if not nearest_plr_data.position then continue end
	local range = nearest_plr_data.distance

	if range <= 100 then
		local direction = CFrame.lookAt(eye_static_pos, nearest_plr_data.position)
		the_eye.CFrame = the_eye.CFrame:Lerp(direction, math.min(delta_time / (240 / 60), 1))

		if range <= 35 and (os.clock() - shoot_debounce) >= shoot_cooldown then
			shoot_laser(nearest_plr_data.position)
			shoot_debounce = os.clock()
		end
	end
end