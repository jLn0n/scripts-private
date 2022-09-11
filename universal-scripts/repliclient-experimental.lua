--[[
	TODO: (not in order)
	#1 DONE: reduce the bandwidth, and use some shenanigans
	#2 DONE: add packet delay
	#3 DONE: fix the flickering of character parts on some cases
	#4 DONE: host a personal server because yes
	#5: add a id for packet comms (for custom instance replication)
	#6: rewrite the networking code and make it like the roblox ones
	#7: change the name (repliclient kinda sucks)
	#8: fix character being cloned so many times
--]]
-- config
local config = {
	socketUrl = "ws://eu-repliclient-ws.herokuapp.com", -- the server to connect

	-- high value = smooth, low value = janky
	sendPerSecond = 5, -- 5hz per second
	recievePerSecond = 10, -- 10hz per second
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
local characterTemplate = game:GetObjects("rbxassetid://6843243348")[1]
-- libraries
local bitBuffer = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/Dekkonot/bitbuffer/main/src/roblox.lua"))()
local base64 = loadstring(game:HttpGetAsync("https://gist.githubusercontent.com/Reselim/40d62b17d138cc74335a1b0709e19ce2/raw/fast_base64.lua"))()
local wsLib = {}
wsLib.__index = wsLib

function wsLib.new(url: string)
	local succ, socket = pcall(WebSocket.connect, url)

	if succ then
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

		initializeSocket(socket, reconnectSocket)
		return setmetatable(wsObj, wsLib)
	else
		return warn("Failed to connect to websocket server!")
	end
end

function wsLib:SendMessage(message)	
	if self._socket then	
		self._socket:Send(message)
	else	
		warn("Attempt to send socket message while reconnecting!")	
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
local accumulatedRecieveTime = 0
local socketObj = wsLib.new(config.socketUrl)
local connections, refs = table.create(10), table.create(0)
local fakePlayers, userIdCache = table.create(0), table.create(0)
local rateInfos = table.create(0)
local characterParts = {"Head", "Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg", "HumanoidRootPart"}
local replicationIDsInt, replicationIDsStr = {
	-- player thingys
	[0x100] = "ID_PLR_JOIN",
	[0x101] = "ID_PLR_CHATTED",
	[0x102] = "ID_PLR_LEAVE",

	-- character thingys
	[0x200] = "ID_CHAR_UPDATE",

	-- datamodel thingys
	[0x300] = "ID_INSTANCE_ADD",
	[0x301] = "ID_INSTANCE_DESTROY",
	[0x302] = "ID_PROPERTY_MODIFY",
}, table.create(0)
-- functions
local function createFakePlr(name, userId, character)
	local plrInstance = Instance.new("Player")

	plrInstance.Name = name
	plrInstance.Character = character
	sethiddenproperty(plrInstance, "UserId", userId)
	fakePlayers[name] = plrInstance
end

local function createPacketBuffer(packetId, ...)
	local packetBuffer, packetPayload = bitBuffer(), "\26|" -- payload starts with arrowleft character with a seperator

	packetBuffer.writeString(replicationIDsInt[packetId])

	local function bufferFinish()
		packetPayload ..= packetBuffer.dumpBase64()
		return packetPayload
	end

	return packetBuffer, bufferFinish
end

local function getUserIdFromName(name)
	if userIdCache[name] then return userIdCache[name] end

	local plr = players:FindFirstChild(name)
	if plr then
		userIdCache[name] = plr.UserId
		return plr.UserId
	end

	local succ, plrUserId = pcall(players.GetUserIdFromNameAsync, players, name)
	if succ then
		userIdCache[name] = plrUserId
		return plrUserId
	end
end

local function getCharacterFromUserId(userId)
	local newChar = characterTemplate:Clone()
	local _humanoid = newChar:FindFirstChild("Humanoid")

	local succ, humDesc = pcall(players.GetHumanoidDescriptionFromUserId, players, userId)

	if succ then
		newChar.Parent = workspace

		_humanoid:ApplyDescription(humDesc)
		return newChar
	else
		newChar:Destroy()
	end
end

local function rateCheck(name, rate)
	rate /= 10
	rateInfos[name] = (if not rateInfos[name] then {
		["lastTime"] = -1,
	} else rateInfos[name])
	local rateInfo = rateInfos[name]

	if rateInfo.lastTime == -1 then
		-- initializes rateInfo
		rateInfo.lastTime = os.time()

		return true
	else
		rateInfo.lastTime = (rateInfo.lastTime or os.clock())
		local timeElapsed = os.time() - rateInfo.lastTime

		if timeElapsed >= (1 / rate) then
			rateInfo.lastTime = os.clock()

			return true
		else
			return false
		end
	end
end

local function unpackOrientation(vectRot, dontUseRadians)
	vectRot = (if not dontUseRadians then vectRot * (math.pi / 180) else vectRot)
	return vectRot.X, vectRot.Y, (if typeof(vectRot) == "Vector2" then 0 else vectRot.Z)
end
-- main
if not socketObj then return warn("Please Re-execute the script, if this still happens then change the config url to another url.") end
if humanoid.RigType ~= Enum.HumanoidRigType.R6 then return warn("Repliclient currently only support R6 characters.") end

do -- initialization
	-- packet initialization
	for packetId, packetIdName in replicationIDsInt do
		replicationIDsStr[packetIdName] = packetId
	end

	-- letting the other clients to know that self joined
	local packetBuffer, bufferFinish = createPacketBuffer(replicationIDsInt[0x100])

	packetBuffer.writeString(player.Name)

	socketObj:SendMessage(bufferFinish())
end

refs.oldIndex = hookmetamethod(game, "__index", function(...)
	local self, index = ...

	-- returns the fake character indexation when called from exploit environment, returns nil if not
	if checkcaller() then
		if self == players and fakePlayers[index] then
			return fakePlayers[index]
		elseif (self:IsA("Player") and fakePlayers[tostring(self)]) and index == "Parent" then -- self.Name causes C stack overflow
			return players
		end
	end
	return refs.oldIndex(...)
end)

-- data payload parser and updater
socketObj:AddMessageCallback(function(message)
	if not rateCheck("recieve", config.recievePerSecond) then return end
	accumulatedRecieveTime = runService.Stepped:Wait()

	if string.sub(message, 1, 1) == "\26" then
		message = string.sub(message, 3, #message) -- removes "\26|"
		local succ, packetBuffer = pcall(function()
			return bitBuffer(base64.decode(message))
		end)

		if not succ then return warn("Failed to parse data recieved:\n", parsedData) end
		local packetId = packetBuffer.readString()

		if packetId == "ID_PLR_JOIN" then
			local plrName = packetBuffer.readString()

			if (player.Name ~= plrName) and (not players:FindFirstChild(plrName) and not fakePlayers[plrName]) then
				local plrUserId = getUserIdFromName(plrName)
				local plrChar = workspace:FindFirstChild(plrName) or getCharacterFromUserId(plrUserId)
				plrChar.Name = plrName

				plrChar:BreakJoints()
				
				for _, part in plrChar:GetChildren() do
					if (part:IsA("BasePart") and table.find(characterParts, part.Name)) then
						part.Anchored = true
					elseif part:IsA("Accessory") and part:FindFirstChild("Handle") then
						part.Handle.Anchored = true
					end
				end

				createFakePlr(plrName, plrUserId, plrChar)
			end
		elseif packetId == "ID_PLR_CHATTED" then
			local plrName = packetBuffer.readString()

			if (player.Name ~= plrName) and fakePlayers[plrName] then
				local plrInstance = fakePlayers[plrName]
				local chatMsg = packetBuffer.readString()

				plrInstance:Chat(chatMsg)
			end
		elseif packetId == "ID_PLR_LEFT" then
			local plrName = packetBuffer.readString()

			if (player.Name ~= plrName) and fakePlayers[plrName] then
				local plrInstance = fakePlayers[plrName]

				plrInstance.Character:Destroy()
				plrInstance:Destroy()
				fakePlayers[plrName] = nil
			end
		elseif packetId == "ID_CHAR_UPDATE" then
			local plrName = packetBuffer.readString()

			if player.Name ~= plrName then
				local plrChar = workspace:FindFirstChild(senderName)

				for _ = 1, packetBuffer.readUInt8() do -- character parts
					local partObj = plrChar:FindFirstChild(packetBuffer.readString())
					local position, orientation = packetBuffer.readVector3(), packetBuffer.readVector3()
	
					if not (partObj and partObj:IsA("BasePart")) then continue end
					partObj.CFrame = partObj.CFrame:Lerp(
						(CFrame.new(position) *
						CFrame.fromOrientation(unpackOrientation(orientation))),
						math.min(accumulatedRecieveTime / (240 / 60), 1)
					)
				end
	
				for _ = 1, packetBuffer.readUInt8() do -- character accessories
					local partObj = plrChar:FindFirstChild(packetBuffer.readString())
					local position, orientation = packetBuffer.readVector3(), packetBuffer.readVector3()
	
					if not (partObj and partObj:IsA("Accessory") and partObj:FindFirstChild("Handle")) then continue end
					partObj = partObj.Handle
					partObj.CFrame = partObj.CFrame:Lerp(
						(CFrame.new(position) *
						CFrame.fromOrientation(unpackOrientation(orientation))),
						math.min(accumulatedRecieveTime / (240 / 60), 1)
					)
				end
			end
		end
	end
end)

-- payload data sender
table.insert(connections, runService.Stepped:Connect(function()
	if not (character and humanoid) then return end
	if not rateCheck("send", config.sendPerSecond) then return end

	local packetBuffer, bufferFinish = createPacketBuffer(replicationIDsInt[0x200])

	packetBuffer.writeString(player.Name) -- sender

	packetBuffer.writeUInt8(#characterParts) -- count of character parts
	for _, object in character:GetChildren() do
		if (object:IsA("BasePart") and table.find(characterParts, object.Name)) then
			packetBuffer.writeString(object.Name) -- name
			packetBuffer.writeVector3(object.Position)
			packetBuffer.writeVector3(object.Orientation)
		end
	end

	local accessories = humanoid:GetAccessories()
	packetBuffer.writeUInt8(#accessories) -- count of accessories
	for _, accessory in accessories do
		if accessory:FindFirstChild("Handle") then
			packetBuffer.writeString(accessory.Name) -- name
			packetBuffer.writeVector3(accessory.Handle.Position)
			packetBuffer.writeVector3(accessory.Handle.Orientation)
		end
	end

	socketObj:SendMessage(bufferFinish())
end))

table.insert(connections, player.CharacterAdded:Connect(function(newChar)
	task.wait(.1)
	character = newChar
	humanoid = newChar:FindFirstChild("Humanoid")
end))

print("Repliclient started!")