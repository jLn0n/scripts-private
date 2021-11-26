local config = {
	["itemFarm"] = {
		["enabled"] = false,
		["mode"] = "default",
		["itemsToFarm"] = {
			["standArrow"] = false,
			["rokakaka"] = false,
			["reqArrow"] = false
		}
	}
}
local itemsList = {
	["Stand Arrow"] = "standArrow",
	["Rokakaka"] = "rokakaka",
	["Refined Arrow"] = "refArrow",
	["Requiem Arrow"] = "reqArrow",
	["Heavenly Diary"] = "diaryBook",
	["Hamon Headband"] = "hbHamon",
	["Stone Mask"] = "stoneMask",
	["Steel Ball"] = "steelBall",
	["Other Items"] = "otherItems"
}

local ui_library = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/zxciaz/VenyxUI/main/Reuploaded"))()
local window = ui_library.new("Stands Online")

local itemFarm_page = window:addPage("Item Farm")
local itemFarm_config = itemFarm_page:addSection("Configuration")
local itemFarm_items = itemFarm_page:addSection("Items")

itemFarm_config:addToggle("Enable", false, function(value)
	config.itemFarm.enabled = value
end)
itemFarm_config:addDropdown("Farm Mode", {"Default", "Spawned", "Dropped"}, function(value)
	config.itemFarm.mode = string.lower(value)
end)

for item, configItemName in pairs(itemsList) do
	itemFarm_items:addToggle(item, config.itemFarm.itemsToFarm[configItemName], function(value)
		config.itemFarm.itemsToFarm[configItemName] = value
	end)
end