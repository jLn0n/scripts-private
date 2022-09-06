-- config
local config = {
	socketUrl = "ws://ws-clientserver.herokuapp.com"
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
local wsLib = {}
wsLib.__index = wsLib

function wsLib.new(url: string)
	local wsObj = {
		_forcedClose = false,
		_socket = WebSocket.connect(url),
		_connections = table.create(0),
		_onMsgCallbacks = table.create(0)
	}

	local function onSocketMsg(message)
		for _, callback in wsObj._onMsgCallbacks do
			callback(message)
		end
	end

	local function initializeSocket(socket, reconnectCallback)
		for index, connection in wsObj._onMsgCallbacks do
			connection:Disconnect()
			table.remove(wsObj._onMsgCallbacks, index)
		end

		wsObj._socket.OnMessage:Connect(onSocketMsg)
		wsObj._socket.OnClose:Connect(reconnectCallback)
	end

	local function reconnectSocket()
		if wsObj._forcedClose then return end
		local reconnected, reconnectCount = false, 0

		print("Lost connection, reconnecting...")
		wsObj._socket = nil
		repeat
			local succ, result = pcall(WebSocket.connect, url)

			if succ then
				reconnected = true
				wsObj._socket = result
				break
			else
				reconnectCount += 1
			end
		until (reconnected or reconnectCount >= 15)
		
		if reconnected then
			print("Connection Re-istablished!")
		else
			warn("Failed to reconnect.")
		end
	end

	initializeSocket(wsObj._socket, reconnectSocket)
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
-- functions
local function encryptNumber(number)
	number = tostring(number)
	for index, value in numberToEncTable do
		if (typeof(index) == "string") then continue end
		number = string.gsub(number, tostring(index), value)
	end
	number = string.gsub(number, ",", numberToEncTable[","])
	number = string.gsub(number, "-", numberToEncTable["-"])
	number = string.gsub(number, " ", "")

	local args = string.split(number, numberToEncTable[","])

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
	print(number)

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

local function createFakePlr(name, character)
	local plrInstance = Instance.new("Player")

	plrInstance.Name = name
	plrInstance.Character = character
	fakePlayers[name] = plrInstance
end
-- main
do
	for index = 1, 13 do
		table.insert(numberToEncTable, index - 1, string.char(index + 14))
	end

	numberToEncTable[","] = numberToEncTable[10]
	numberToEncTable["-"] = numberToEncTable[11]
	numberToEncTable["."] = numberToEncTable[12]
	numberToEncTable[10], numberToEncTable[11], numberToEncTable[12] = nil, nil, nil
end

refs.oldIndex = hookmetamethod(game, "__index", function(...)
	local self, index = ...

	if self == players and fakePlayers[index] then
		-- returns the fake character when indexed from exploit environment, returns nil if not
		return (if checkcaller() then fakePlayers[index] else refs.oldIndex(...))
	elseif (self:IsA("Player") and self:IsDescendantOf(fakePlrParent)) and index == "Parent" then -- IsDescendantOf is better to be used here
		return (if checkcaller() then players else nil)
	end
	return refs.oldIndex(...)
end)

-- data payload parser and updater
socketObj:AddMessageCallback(function(message)
	local parsedData = httpService:JSONDecode(base64.decode(message))

	if parsedData[1] == "\27" then
		local playerName = parsedData[3]

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
table.insert(connections, runService.Heartbeat:Connect(function()
	if not (character and humanoid) then return end
	local dataPayload = {
		"\27", -- header
		{ -- character position & orientation
			{}, -- parts
			{}  -- accessories
		},
		player.Name, -- sender
	}

	for _, object in character:GetChildren() do
		if (object:IsA("BasePart") and table.find(characterParts, object.Name)) then
			dataPayload[2][1][object.Name] = {
				[1] = encryptNumber(object.Position),
				[1] = encryptNumber(object.Orientation),
			}
		end
	end

	for _, accessory in humanoid:GetAccessories() do
		if accessory:FindFirstChild("Handle") then
			dataPayload[2][1][accessory.Name] = {
				[1] = encryptNumber(accessory.Handle.Position),
				[1] = encryptNumber(accessory.Handle.Orientation),
			}
		end
	end

	socketObj:SendMessage(base64.encode(httpService:JSONEncode(dataPayload)))
	runService.Stepped:Wait()
end))

table.insert(connections, player.CharacterAdded:Connect(function(newChar)
	character = newChar
	humanoid = newChar:FindFirstChild("Humanoid")
end))

print("Clientserver started!")