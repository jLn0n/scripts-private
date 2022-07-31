-- for this game: https://www.roblox.com/games/10268452785
print(getrenv()._G["replication-3088049980[sior@4MHysg%yZGTs8VlwAq8Y]"]) -- key is different for every player

--[[
	replication:
	  .instance:
		.new(className: string, properties: Dictionary): Instance?
		.call_func(object: Instance, funcName: string, ...): ...
		.destroy(object: Instance): nil
		.get_hook(object: Instance): userdata [ BETA ]
		.modify_property(object: Instance, propertyName: string, value: any): nil
		.modify_properties(object: Instance, properties: table): nil
	  .network:
		.get_part_owner(partObj: BasePart): Player | string
		.set_part_owner(partObj: BasePart, owner: string): nil
--]]

--[[
	examples: 
	#1: (this creates a part and teleports them after 2.5 seconds)
	local createObj = replication.instance.new
	local modifyProperty = replication.instance.modify_property

	local newPart = createObj("Part", {
		Size = Vector3.new(math.random(1, 10), math.random(1, 10), math.random(1, 10)),
		Parent = workspace
	})

	task.delay(2.5, modifyProperty, newPart, "Position", (Vector3.yAxis * 69))
	
	#2: (loads your character)
	local getHook = replication.instance.get_hook
	
	local player = game:GetService("Players").LocalPlayer
	local plrProxy = getHook(player)
	
	plrProxy:LoadCharacter()
--]]
