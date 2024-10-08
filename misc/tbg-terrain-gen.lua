-- game link: https://www.roblox.com/games/7061626307
-- services
local repStorage = game:GetService("ReplicatedStorage")
-- remotes
local placeBlock = repStorage.Remotes:FindFirstChild("PlaceBlock")
local removeBlock = repStorage.Remotes:FindFirstChild("MineBlock")
-- generation settings
local amplitude = 8
local frequency = 1 / 12
local baseHeight = 4 + amplitude / 2
local worldSize = 50
local worldSeed = ((math.random(1, 99999999) % math.random(1, 99999999)) * (math.random(1, 99999999) % math.random(1, 99999999))) % math.random(1, 99999999)
-- functions
local invokeFunc = placeBlock.InvokeServer
local function modifyBlock(blockType, position)
	if blockType == "Air" then
		task.spawn(invokeFunc, removeBlock, position)
	else
		task.spawn(invokeFunc, placeBlock, blockType, position)
	end
end
-- main
for _, object in ipairs(workspace:GetChildren()) do
	if object:IsA("BasePart") and object:FindFirstChild("Health") and object.Transparency ~= 1 then
		modifyBlock("Air", object)
	end
end
for x = -worldSize / 2, worldSize / 2 do
	for z = -worldSize / 2, worldSize / 2 do
		local heightNoise = baseHeight + math.noise(
			x * frequency,
			worldSeed,
			z * frequency
		) * amplitude
		for y = 1, math.floor(heightNoise) do
			local blockPos = (Vector3.new(x, y, z) * 4)
			modifyBlock((y >= math.floor(heightNoise) and "Grass" or "Dirt"), blockPos)
		end
	end
end
