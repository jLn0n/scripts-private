-- for this game: https://www.roblox.com/games/10268452785
-- main
print(getrenv()._G["replication-3088049980[sior@4MHysg%yZGTs8VlwAq8Y]"]) -- key is different for every player

--[[
	replication:
	  .instance:
		.new(className: string, properties: Dictionary): Instance
		.destroy(object: Instance): nil
		.modifyProperty(object: Instance, propertyName: string, value: any): nil
		.modifyProperties(object: Instance, properties: Dictionary): nil
	  .network:
		.getPartOwner(partObj: BasePart): Player
		.setPartOwner(partObj: BasePart, owner: Player): nil
--]]

--[[
	examples: (this creates a part and teleports them after 2.5 seconds)
	local createObj = replication.instance.new
	local modifyProperty = replication.instance.modifyProperty

	local newPart = createObj("Part", {
		Size = Vector3.new(math.random(1, 10), math.random(1, 10), math.random(1, 10)),
		Parent = workspace
	})
	print(newPart)

	task.delay(2.5, modifyProperty, newPart, "Position", (Vector3.yAxis * 69))
--]]
