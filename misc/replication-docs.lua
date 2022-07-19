-- for this game: https://www.roblox.com/games/10268452785/func-hooking
-- main
print(getrenv()._G["replication-3088049980[TQPv0hjXcxw%^fX70fuoySxbK]"]) -- key is different for every player

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
