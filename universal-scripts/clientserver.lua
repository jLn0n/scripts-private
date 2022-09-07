--[[
	TODO:
	#1: reduce the bandwidth, and use some shenanigans	
	#2 DONE: add packet delay
	#3: fix the flickering of character parts on some cases
	#4: host a fast websocket server using replit
--]]
-- config
local config = {
	socketUrl = "ws://ws-clientserver.herokuapp.com", -- the server to connect
	sendPerSecond = .15, -- 15 times per second
	recievePerSecond = .30, -- 30 times per second
}
-- services
local httpService = game:GetService("HttpService")
local players = game:GetService("Players")
local runService = game:GetService("RunService")
local tweenService = game:GetService("TweenService")
-- objects
local player = players.LocalPlayer
local character = player.Character
local humanoid = character.Humanoid
-- libraries
local base64 = loadstring(game:HttpGetAsync("https://gist.githubusercontent.com/Reselim/40d62b17d138cc74335a1b0709e19ce2/raw/fast_base64.lua"))()
local lz4 = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/metatablecat/lz4-lua/master/lz4-luau.lua"))()
local wsLib = {}
wsLib.__index = wsLib

function wsLib.new(url: string)
	local wsObj = {
		_forcedClose = false,
		_socket = nil,
		_connections = table.create(0),
		_onMsgCallbacks = table.create(0)
	}

	local function onSocketMsg(message)
		for _, callback in wsObj._onMsgCallbacks do
			task.spawn(callback, message)
		end
	end

	local function initializeSocket(socket, reconnectCallback)
		for index, connection in wsObj._connections do
			connection:Disconnect()
			table.remove(wsObj._connections, index)
		end

		wsObj._socket = socket
		socket.OnMessage:Connect(onSocketMsg)
		socket.OnClose:Connect(reconnectCallback)
	end

	local function reconnectSocket()
		if wsObj._forcedClose then return end
		local newSocket, reconnected, reconnectCount = nil, false, 0

		print("Lost connection, reconnecting...")
		repeat
			local succ, result = pcall(WebSocket.connect, url)

			if succ then
				reconnected, newSocket = true, result
				break
			else
				reconnectCount += 1
			end
		until (reconnected or reconnectCount >= 15)
		
		if reconnected then
			initializeSocket(newSocket, reconnectSocket)
			print("Reconnected successfully!")
		else
			warn("Failed to reconnect after 15 tries, trying again.")
			reconnectSocket()
		end
	end

	initializeSocket(WebSocket.connect(url), reconnectSocket)
	return setmetatable(wsObj, wsLib)
end

function wsLib:SendMessage(message)	
	if self._socket then	
		self._socket:Send(message)
	else	
		warn("Attempt to send socket message when reconnecting!")	
	end	
end

function wsLib:AddMessageCallback(callback)
	table.insert(self._onMsgCallbacks, callback)
end

function wsLib:Close()
	for index, connection in self._connections do
		connection:Disconnect()
		table.remove(self._connections, index)
	end
	
	self._forcedClose = true
	if self._socket then self._socket:Close() end
	setmetatable(self, nil)
end
-- variables
local socketObj = wsLib.new(config.socketUrl)
local refs = table.create(0)
local fakePlayers = table.create(0)
local numberToEncTable = table.create(0)
local connections = table.create(0)
local characterParts = {"Head", "Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg"}
local accumulatedTime = {
	send = 0,
	recieve = 0
}
-- functions
local function encryptNumber(number)
	number = tostring(number)
	for index, value in numberToEncTable do
		if (typeof(tonumber(index)) == "nil") then continue end
		number = string.gsub(number, index, value)
	end

	number = string.gsub(number, "-", numberToEncTable["-"])
	number = string.gsub(number, " ", "")

	local args = string.split(number, ",")

	if #args ~= 0 then
		number = ""

		for index, arg in args do
			local splitted = string.split(arg, ".")
			if #splitted == 2 then
				arg = splitted[1] .. numberToEncTable["."] .. splitted[2]
			end

			if index ~= #args then
				number ..= arg .. numberToEncTable[","]
			elseif index == #args then
				number ..= arg
			end
		end
	end
	return number
end

local function decryptNumber(number)
	number = tostring(number)

	for index, value in numberToEncTable do
		number = string.gsub(number, value, tostring(index)) -- reversed
	end
	return number
end

local function unpackVect3(vect3)
	vect3 = tostring(vect3)
	local args = string.split(vect3, ",")
	
	for index, value in args do
		args[index] = tonumber(value)
	end
	return Vector3.new(unpack(args))
end

local function unpackOrientation(vectRot, dontUseRadians)
	vectRot = (if not dontUseRadians then vectRot * (math.pi / 180) else vectRot)
	return vectRot.X, vectRot.Y, (if typeof(vectRot) == "Vector2" then 0 else vectRot.Z)
end

local function createFakePlr(name, character)
	local plrInstance = Instance.new("Player")

	plrInstance.Name = name
	plrInstance.Character = character
	fakePlayers[name] = plrInstance
end
-- main
do
	for index = 1, 13 do
		index -= 1
		table.insert(numberToEncTable, tostring(index), string.char(index + 14))
	end

	numberToEncTable[","] = numberToEncTable[10]
	numberToEncTable["-"] = numberToEncTable[11]
	numberToEncTable["."] = numberToEncTable[12]
	numberToEncTable[10], numberToEncTable[11], numberToEncTable[12] = nil, nil, nil
end

refs.oldIndex = hookmetamethod(game, "__index", function(...)
	local self, index = ...

	-- returns the fake character indexation when called from exploit environment, returns nil if not
	if checkcaller() then
		if self == players and fakePlayers[index] then
			return fakePlayers[index]
		elseif (self:IsA("Player") and self:IsDescendantOf(fakePlrParent)) and index == "Parent" then -- IsDescendantOf is better to be used here
			return players
		end
	end
	return refs.oldIndex(...)
end)

-- data payload parser and updater
socketObj:AddMessageCallback(function(message)
	accumulatedTime.recieve += runService.Heartbeat:Wait()

	while accumulatedTime.recieve >= config.recievePerSecond do
		accumulatedTime.recieve -= config.recievePerSecond
	end

	if string.sub(message, 1, 1) == "\26" then
		message = string.sub(message, 3, #message) -- removes "\26|"
		local succ, parsedData = pcall(function()
			return httpService:JSONDecode(lz4.decompress(base64.decode(message)))
		end)

		if not succ then 
			return warn("Failed to parse data recieved:", parsedData)
		end
		local playerName = parsedData[1]

		if player.Name ~= playerName then
			local plrChar = workspace:FindFirstChild(playerName)

			if not players:FindFirstChild(playerName) then
				plrChar = game:GetObjects("rbxassetid://5195737219")[1]
				plrChar.Name = playerName
				plrChar.Parent = workspace
				createFakePlr(playerName, plrChar)
			end

			if not plrChar:FindFirstChild("JointsGone") then
				plrChar:BreakJoints()
				
				for _, part in plrChar:GetChildren() do
					if (part:IsA("BasePart") and table.find(characterParts, part.Name)) then
						part.Anchored = true
					elseif part:IsA("Accessory") and part:FindFirstChild("Handle") then
						part.Handle.Anchored = true
					end
				end

				local JointsGone = Instance.new("NumberValue")
				JointsGone.Name = "JointsGone"
				JointsGone.Value = 1
				JointsGone.Parent = plrChar
			end

			for partName, cframeData in parsedData[2][1] do
				local partObj = plrChar:FindFirstChild(partName)

				if not (partObj and partObj:IsA("BasePart")) then continue end
				tweenService:Create(partObj, TweenInfo.new(.1), {
					Position = unpackVect3(decryptNumber(cframeData[1])),
					Orientation = unpackVect3(decryptNumber(cframeData[2]))
				}):Play()
			end

			for partName, cframeData in parsedData[2][2] do
				local partObj = plrChar:FindFirstChild(partName)

				if not (partObj and partObj:FindFirstChild("Handle")) then continue end
				tweenService:Create(partObj.Handle, TweenInfo.new(.1), {
					Position = unpackVect3(decryptNumber(cframeData[1])),
					Orientation = unpackVect3(decryptNumber(cframeData[2]))
				}):Play()
			end
		end
	end
end)

-- payload data sender
table.insert(connections, runService.Heartbeat:Connect(function(deltaTime)
	if not (character and humanoid) then return end
	accumulatedTime.send += deltaTime

	while accumulatedTime.send >= config.sendPerSecond do
		accumulatedTime.send -= config.sendPerSecond
	end
	
	local dataPayload, packetPayload = {
		player.Name, -- sender
		{ -- character position & orientation
			{}, -- parts
			{}  -- accessories
		},
	}, "\26|" -- packet starts with arrowleft character with a seperator

	for _, object in character:GetChildren() do
		if (object:IsA("BasePart") and table.find(characterParts, object.Name)) then
			dataPayload[2][1][object.Name] = {
				[1] = encryptNumber(object.Position),
				[2] = encryptNumber(object.Orientation),
			}
		end
	end

	for _, accessory in humanoid:GetAccessories() do
		if accessory:FindFirstChild("Handle") then
			dataPayload[2][2][accessory.Name] = {
				[1] = encryptNumber(accessory.Handle.Position),
				[2] = encryptNumber(accessory.Handle.Orientation),
			}
		end
	end

	packetPayload ..= base64.encode(lz4.compress(httpService:JSONEncode(dataPayload)))
	socketObj:SendMessage(packetPayload)
end))

table.insert(connections, player.CharacterAdded:Connect(function(newChar)
	task.wait(.1)
	character = newChar
	humanoid = newChar:FindFirstChild("Humanoid")
end))

print("Clientserver started!")