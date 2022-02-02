-- variables
local packetIdList = { -- gathered from https://github.com/Arisstath/roblox-dissector/blob/master/peer/RakNetLayer.go#L74
	0x81, -- "ID_SET_GLOBALS"
	0x82, -- "ID_TEACH_DESCRIPTOR_DICTIONARIES"
	0x83, -- "ID_DATA"
	0x84, -- "ID_MARKER"
	0x85, -- "ID_PHYSICS"
	0x86, -- "ID_TOUCHES"
	0x87, -- "ID_CHAT_ALL"
	0x88, -- "ID_CHAT_TEAM"
	0x89, -- "ID_REPORT_ABUSE"
	0x8A, -- "ID_SUBMIT_TICKET"
	0x8B, -- "ID_CHAT_GAME"
	0x8C, -- "ID_CHAT_PLAYER"
	0x8D, -- "ID_CLUSTER"
	0x8E, -- "ID_PROTOCOL_MISMATCH"
	0x8F, -- "ID_PREFERRED_SPAWN_NAME"
	0x90, -- "ID_PROTOCOL_SYNC"
	0x91, -- "ID_SCHEMA_SYNC"
	0x92, -- "ID_PLACEID_VERIFICATION"
	0x93, -- "ID_DICTIONARY_FORMAT"
	0x94, -- "ID_HASH_MISMATCH"
	0x95, -- "ID_SECURITYKEY_MISMATCH"
	0x96, -- "ID_REQUEST_STATS"
	0x97, -- "ID_NEW_SCHEMA"
}
local whitelistedPackets = {
	0x83,
	0x85
}
local strResult = ""
-- functions
local function compilePacketPayload(packetPayload)
	local result = "\"%s\""
	for index, packet in ipairs(packetPayload) do
		result = string.format(result, string.format("%02X", packet) .. (index == #packetPayload and "" or " %s"))
	end
	return result
end
local function createPacketOutput(packetData)
	local result = ""
	-- compiled_packet
	result = result .. string.format("compiled_packet: %s\n", compilePacketPayload(packetData))
	-- packet_data
	result = result .. "packet_data:\n"
	for index, value in ipairs(packetData) do
		result = result .. string.format("  %s: %s\n", index, string.format("0x%02X (%s)", value, value) .. (table.find(packetIdList, value) and " - packet_id" or ""))
	end
	-- seperator
	result = result .. string.rep("----", 40) .. "\n"
	return result
end
-- main
rnet.Capture:Connect(function(packet)
	if table.find(whitelistedPackets, packet.id) then
		strResult = strResult .. createPacketOutput(packet.data)
	end
end)
game.Close:Connect(function()
	writefile("packet-output.txt", strResult)
	task.wait(2.5)
end)
print("packet-spy.lua running!")
