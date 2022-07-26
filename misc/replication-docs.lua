-- for this game: https://www.roblox.com/games/10268452785
-- main
print(getrenv()._G["replication-3088049980[sior@4MHysg%yZGTs8VlwAq8Y]"]) -- key is different for every player

--[[
	replication:
	  .instance:
		.new(className: string, properties: Dictionary): Instance?
		.destroy(object: Instance): nil
		.modify_property(object: Instance, propertyName: string, value: any): nil
		.modify_properties(object: Instance, properties: Dictionary): nil
	  .network:
		.get_part_owner(partObj: BasePart): Player | string
		.set_part_owner(partObj: BasePart, owner: Player | string ("server")): nil
--]]

--[[
	examples: (this creates a part and teleports them after 2.5 seconds)
	local createObj = replication.instance.new
	local modifyProperty = replication.instance.modify_property

	local newPart = createObj("Part", {
		Size = Vector3.new(math.random(1, 10), math.random(1, 10), math.random(1, 10)),
		Parent = workspace
	})

	task.delay(2.5, modifyProperty, newPart, "Position", (Vector3.yAxis * 69))
--]]
