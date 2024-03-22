-- TODO: combine all runservice loops for "refitter"
-- TODO: create a new movement system instead of relying to current roblox movement
-- TODO: fix bug that makes some parts fall behind when refitting

local players = game:GetService("Players")
local run_service = game:GetService("RunService")

local void_cframe = CFrame.identity + (Vector3.xAxis * 9e10)

local remotes = {
	send_position = Instance.new("UnreliableRemoteEvent")
}
local character_data = {
	current_pos = CFrame.identity + (Vector3.yAxis * 10)
}
local character_parts = {}
local character_welds = {
	["Head"] = {"Torso", CFrame.identity + (Vector3.yAxis * 1.5), CFrame.identity},
	["Left Arm"] = {"Torso", CFrame.identity + (-Vector3.xAxis * 1.5), CFrame.identity},
	["Right Arm"] = {"Torso", CFrame.identity + (Vector3.xAxis * 1.5), CFrame.identity},
	["Left Leg"] = {"Torso", CFrame.identity + (Vector3.new(-0.5, -2)), CFrame.identity},
	["Right Leg"] = {"Torso", CFrame.identity + (Vector3.new(0.5, -2)), CFrame.identity},
}

-- functions
local function calculate_weld(part0, c0, c1)
	return part0.CFrame * c0 * c1:Inverse()
end

local function instance_helper(class_name, properties)
	local object = Instance.new("Part")

	for name, value in properties do
		if name == "Parent" then continue end
		object[name] = value
	end
	object.Parent = properties.Parent
	return object
end

-- init
owner.Character.Parent = nil

character_parts["Torso"] = instance_helper("Part", {
	Anchored = true,
	CanCollide = false,
	Size = Vector3.new(2, 2, 1),
	Color = Color3.fromRGB(69, 71, 74),
	CFrame = character_data.current_pos
})
character_parts["Head"] = instance_helper("Part", {
	Anchored = true,
	CanCollide = false,
	Color = Color3.fromRGB(115, 117, 120),
	Size = Vector3.new(2, 1, 1),
})
character_parts["Left Arm"] = instance_helper("Part", {
	Anchored = true,
	CanCollide = false,
	Color = Color3.fromRGB(115, 117, 120),
	Size = Vector3.new(1, 2, 1),
})
character_parts["Right Arm"] = instance_helper("Part", {
	Anchored = true,
	CanCollide = false,
	Color = Color3.fromRGB(115, 117, 120),
	Size = Vector3.new(1, 2, 1),
})
character_parts["Left Leg"] = instance_helper("Part", {
	Anchored = true,
	CanCollide = false,
	Color = Color3.fromRGB(115, 117, 120),
	Size = Vector3.new(1, 2, 1),
})
character_parts["Right Leg"] = instance_helper("Part", {
	Anchored = true,
	CanCollide = false,
	Color = Color3.fromRGB(115, 117, 120),
	Size = Vector3.new(1, 2, 1),
})

print("character initialized")

local client_script = NLS([[
print("client waiting")
repeat task.wait() until script:GetAttribute("initialized")
local run_service = game:GetService("RunService")

local remotes = {}
for _, remote in ipairs(script:GetChildren()) do
	remotes[remote.Name] = remote
end

local root_part = owner.Character.HumanoidRootPart
root_part.Transparency = 0.5
root_part.CanCollide = true
root_part.RootJoint:Destroy()
owner.Character.Parent = workspace
owner.Character.Torso.CFrame = CFrame.identity + (Vector3.one * 9e9)

local accumulated_time = 0
run_service.Stepped:Connect(function(delta)
	if accumulated_time < 1/15 then
		accumulated_time = accumulated_time + delta
		return
	end
	accumulated_time = 0
	remotes.send_position:FireServer(root_part.CFrame)
end)

script.Destroying:Connect(function()
	owner.Character:Destroy()
end)
print("client initialized")
]])
print("client ran")

for remote_name, remote_obj in remotes do
	remote_obj.Name = remote_name
	remote_obj.Parent = client_script
end
client_script:SetAttribute("initialized", true)
print("remote initialized")

-- main
remotes.send_position.OnServerEvent:Connect(function(_player, new_pos)
	if _player.UserId ~= owner.UserId then return end

	character_data.current_pos = new_pos
end)

for part_name, object in character_parts do
	local weld_data = character_welds[part_name]
	local new_part = object

	run_service.Heartbeat:Connect(function(delta_time)
		new_part:Destroy()
		new_part = object:Clone()
		new_part.Name = "\0"
		new_part.CFrame = (if weld_data then calculate_weld(character_parts[weld_data[1]], weld_data[2], weld_data[3]) else character_data.current_pos)
		--[=[new_part.CFrame = object.CFrame:Lerp(
			(if weld_data then calculate_weld(character_parts[weld_data[1]], weld_data[2], weld_data[3]) else character_data.current_pos),
			math.min(delta_time / (240 / 60), 1)
		)--]=]
		new_part.Parent = script
		character_parts[part_name] = new_part
	end)
end