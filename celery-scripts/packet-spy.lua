-- variables
local packetIdList = {
	["1B"] = "ID_PHYSICS",
	["83"] = "ID_DATA",
}
local packetsToFind = {
	0x83,
	0x03,
	0x01
}
local strResult, packetSpyEnabled = "", false
-- functions
local function compilePacketData(packetData)
	local result = "\"%s\""
	for index, packet in ipairs(packetData) do
		result = string.format(result, string.format("%02X", packet) .. (index == #packetData and "" or " %s"))
	end
	return result
end
local function createPacketOutput(packetData)
	local result = ""
	-- compiled_packet
	result ..= string.format("compiled_packet: %s\n", compilePacketData(packetData))
	-- packet_data
	result ..= "packet_data:\n"
	for index, packet in ipairs(packetData) do
		local packetHex = string.format("%02X", packet)
		result ..= string.format("  %s: %s\n", index, string.format("0x%s (%s)", packetHex, packet) .. (packetIdList[packetHex] and string.format(" - packet-id: %s", packetIdList[packetHex]) or ""))
	end
	-- seperator
	result ..= string.rep("----", 40) .. "\n"
	return result
end
local function packetsFound(packetData)
	local packetIndex, foundPackets = 0, 0
	for _, packet in ipairs(packetData) do
		packetIndex += 1
		if packetsToFind[packetIndex] == packet then
			foundPackets += 1
		end
	end
	return foundPackets == #packetsToFind
end
-- main
print("packet-spy.lua running!")
getgenv()._G.packetSpyToggle = function()
	packetSpyEnabled = not packetSpyEnabled
	print("packet spy is", (packetSpyEnabled and "enabled" or "disabled"))
	if not packetSpyEnabled then
		writefile("packet-output.txt", strResult)
	end
end
while true do task.wait()
	if packetSpyEnabled then
		local packetData = rnet.getpacket()
		if packetsFound(packetData) then
			strResult ..= createPacketOutput(packetData)
		end
	end
end
