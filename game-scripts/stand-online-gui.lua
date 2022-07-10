-- services
local coreGui = game:GetService("CoreGui")
local players = game:GetService("Players")
local runService = game:GetService("RunService")
local tweenService = game:GetService("TweenService")
-- objects
local player = players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local espFolder
local tpCompleted = Instance.new("BindableEvent")
-- variables
local ui_library = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/zxciaz/VenyxUI/main/Reuploaded"))()
local itemsList = {
	{"Rokakaka", "rokaFruit"},
	{"Stand Arrow", "standArrow"},
	--{"Gift", "giftArrow"},
	{"Refined Arrow", "refArrow"},
	{"Requiem Arrow", "reqArrow"},
	{"Disc", "discItem"},
	{"Heavenly Diary", "diaryBook"},
	{"Hamon Headband", "hbHamon"},
	{"Vampire Mask", "vampMask"},
	{"Steel Ball", "steelBall"},
	{"Other Items", "otherItems"}
}
local otherItemsList = {
	"Roka-Cola",
	"Color Arrow",
	"Pose Arrow",
	"Idle Arrow",
	"Sound Arrow",
	"Face Arrow",
}
-- config init
local config = {
	["expUtil"] = {
		["expFarm"] = false,
		["plrDist"] = 3,
		["autoPrestige"] = false,
		["farmingMob"] = "Thug"
	},
	["itemUtil"] = {
		["itemFarm"] = false,
		["itemFarming"] = "default",
		["itemWL"] = {},
		["itemEsp"] = false,
	},
	["configVer"] = 1
}
-- functions
local function getTool(toolObj) -- returns the tool if it passes a certain condition
	toolObj = (
		(toolObj:IsA("Model") and toolObj:FindFirstChildWhichIsA("Tool")) and toolObj:FindFirstChildWhichIsA("Tool") or
		--(toolObj:IsA("Model") and toolObj:FindFirstChildWhichIsA("ClickDetector", true)) and toolObj:FindFirstChildWhichIsA("MeshPart") or
		toolObj:IsA("Tool") and toolObj or nil
	)
	return (toolObj and ((toolObj:IsA("BasePart") or toolObj:FindFirstChild("Handle")) and toolObj:IsDescendantOf(workspace)) and not toolObj.Parent:FindFirstChildWhichIsA("Humanoid")) and toolObj or nil
end
local function gotAdornied(toolObj)
	for _, espThingy in ipairs(espFolder:GetChildren()) do
		if espThingy.Adornee.Parent == toolObj then
			return true
		end
	end
end
local function itemFarmable(itemName)
	for _, itemTable in ipairs(itemsList) do
		if string.find(itemName, itemTable[1]) then
			return config.itemUtil.itemWL[itemTable[2]]
		end
	end
	if config.itemUtil.itemWL.otherItems then
		for _, _itemName in ipairs(otherItemsList) do
			if string.find(itemName, _itemName) then
				return true
			end
		end
	end
end
local function tpPlayer(posCFrame, tpCompletedWait)
	posCFrame = typeof(posCFrame) == "Vector3" and CFrame.new(posCFrame) or posCFrame
	local _tweenInfo = TweenInfo.new(player:DistanceFromCharacter(posCFrame.Position) / 150, Enum.EasingStyle.Linear)
	local tweenObj = tweenService:Create(character.HumanoidRootPart, _tweenInfo, {
		CFrame = posCFrame
	})
	tweenObj.Completed:Connect(function(playbackState)
		if playbackState == Enum.PlaybackState.Completed then
			tpCompleted:Fire()
			tweenObj:Destroy()
		end
	end)
	tweenObj:Play()
	return tpCompletedWait and tpCompleted.Event:Wait() or nil
end
local function expFarmMob(mobObj)
	-- TODO: figure out how to do the expFarm
end
local function getItem(toolObj) -- TODO: make this cancellable in certain circumstances
	toolObj = getTool(toolObj)
	if (toolObj and character.Humanoid.Health ~= 0 and itemFarmable(toolObj.Name)) then
		if toolObj.Parent:IsA("Workspace") and (config.itemUtil.itemFarming == "default" or config.itemUtil.itemFarming == "dropped") then
			character.Humanoid:EquipTool(toolObj)
		elseif toolObj.Parent:IsA("Model") and (config.itemUtil.itemFarming == "default" or config.itemUtil.itemFarming == "spawned") then
			local toolHandle = toolObj:FindFirstChild("Handle")
			local toolObjThingy = toolHandle:FindFirstChildWhichIsA("TouchTransmitter") or toolHandle:FindFirstChildWhichIsA("ClickDetector", true)
			tpPlayer(toolHandle.Position, true)
			if toolObjThingy then
				if toolObjThingy:IsA("TouchTransmitter") then
					firetouchinterest(toolHandle, character.HumanoidRootPart, 0)
					firetouchinterest(toolHandle, character.HumanoidRootPart, 1)
				elseif toolObjThingy:IsA("ClickDetector") then
					fireclickdetector(toolHandle:FindFirstChildWhichIsA("ClickDetector"), 10)
				end
			end
		end
	end
end
local function getItems()
	if not config.itemUtil.itemFarm then return end
	for _, object in ipairs(workspace:GetChildren()) do
		if not config.itemUtil.itemFarm then break end
		getItem(object)
	end
end
local function itemESP(toolObj)
	toolObj = getTool(toolObj)
	if config.itemUtil.itemEsp and (toolObj and not gotAdornied(toolObj)) then
		local guiEsp, itemName, itemDist = Instance.new("BillboardGui"), Instance.new("TextLabel"), Instance.new("TextLabel")
		guiEsp.Name, itemName.Name, itemDist.Name = "itemGui", "itemName", "itemDist"
		guiEsp.Enabled = true
		guiEsp.Adornee = toolObj.Handle
		guiEsp.AlwaysOnTop = true
		guiEsp.DistanceLowerLimit = 1
		guiEsp.DistanceStep = 0
		guiEsp.DistanceUpperLimit = 1
		guiEsp.Size = UDim2.new(0, 250, 0, 30)
		guiEsp.StudsOffset = Vector3.new(0, 1, 0)
		itemName.BackgroundTransparency = 1
		itemName.Size = UDim2.new(1, 0, 0, 15)
		itemName.Font = Enum.Font.GothamBold
		itemName.TextSize = Enum.FontSize.Size14
		itemName.Text = toolObj.Name
		itemName.TextColor3 = toolObj.Handle.Color
		itemName.TextSize = 15
		itemName.TextStrokeColor3 = Color3.fromRGB(255, 255, 255)
		itemName.TextStrokeTransparency = 0
		itemDist.BackgroundTransparency = 1
		itemDist.Position = UDim2.new(0, 0, 0, 15)
		itemDist.Size = UDim2.new(1, 0, 0, 15)
		itemDist.Font = Enum.Font.GothamBold
		itemDist.TextSize = Enum.FontSize.Size14
		itemDist.TextColor3 = toolObj.Handle.Color
		itemDist.TextSize = 15
		itemDist.TextStrokeColor3 = Color3.fromRGB(255, 255, 255)
		itemDist.TextStrokeTransparency = 0
		guiEsp.Parent, itemName.Parent, itemDist.Parent = espFolder, guiEsp, guiEsp
	end
end
-- ui init
local window = ui_library.new("Stands Online")

local farming_page = window:addPage("Farming", 5012544693)

local expFarm_sect = farming_page:addSection("EXP Utils (SOON!)")
local itemFarm_sect = farming_page:addSection("Item Utils")
local itemFarm_items = farming_page:addSection("Item Whitelist")

local settings_sect = window:addPage("Settings")
local settings_section = settings_sect:addSection("Settings")

expFarm_sect:addToggle("EXP Farm", config.expUtil.expFarm, function(value)
	config.expUtil.expFarm = value
end)
expFarm_sect:addDropdown("Mob to Farm", {
	"Thug",
	"Brute",
	"Gorilla",
	"Werewolf",
	"Zombie",
	"Vampire",
	"Hamon Golem"
}, function(value)
	config.expUtil.farmingMob = value
end)
expFarm_sect:addSlider("Distance", config.expUtil.plrDist, 0, 10, function(value)
	config.expUtil.plrDist = value
end)
expFarm_sect:addToggle("Auto Prestige", config.expUtil.autoPrestige, function(value)
	config.expUtil.autoPrestige = value
end)

itemFarm_sect:addToggle("Item Farm", config.itemUtil.itemFarm, function(value)
	config.itemUtil.itemFarm = value
	task.spawn(getItems)
end)
itemFarm_sect:addDropdown("Items To Farm", {"Default", "Dropped", "Spawned"}, function(value)
	config.itemUtil.itemFarming = string.lower(value)
	task.spawn(getItems)
end)
itemFarm_sect:addToggle("Item ESP", config.itemUtil.itemEsp, function(value)
	config.itemUtil.itemEsp = value
end)
for _, itemTable in ipairs(itemsList) do
	config.itemUtil.itemWL[itemTable[2]] = true
	itemFarm_items:addToggle(itemTable[1], config.itemUtil.itemWL[itemTable[2]], function(value)
		config.itemUtil.itemWL[itemTable[2]] = value
	end)
end

settings_section:addKeybind("UI Toggle", Enum.KeyCode.RightControl, function()
	window:toggle()
end)

window:SelectPage(window.pages[1], true)
-- init
_G.standOnline_GUI = not _G.standOnline_GUI and table.create(0) or _G.standOnline_GUI
_G.standOnline_GUI.connections = not _G.standOnline_GUI.connections and table.create(0) or _G.standOnline_GUI.connections
if not _G.standOnline_GUI.executed then
	espFolder = _G.standOnline_GUI.espFolder or Instance.new("Folder")
	if espFolder.Name ~= "espFolder" then
		local gethui = gethui or gethiddenui or get_hidden_gui or function() return coreGui end
		local protectGui = (syn and syn.protect_gui) or (fluxus and fluxus.protect_gui) or nil
		if protectGui then protectGui(espFolder) end
		espFolder.Name, espFolder.Parent = "espFolder", gethui()
	end
	_G.standOnline_GUI.executed = true
end
-- main
table.insert(_G.standOnline_GUI.connections, workspace.ChildAdded:Connect(function()
	task.spawn(getItems)
	for _, object in ipairs(workspace:GetChildren()) do
		itemESP(object)
	end
end))
table.insert(_G.standOnline_GUI.connections, player.CharacterRemoving:Connect(function()
	character = player.CharacterAdded:Wait()
end))
table.insert(_G.standOnline_GUI.connections, runService.Heartbeat:Connect(function()
	for _, guiEsp in ipairs(espFolder:GetChildren()) do
		if not config.itemUtil.itemEsp or not (guiEsp.Adornee or guiEsp:FindFirstChild("itemDist")) or not guiEsp.Adornee:IsDescendantOf(game) then
			guiEsp:Destroy()
			continue
		end
		local toolObj = guiEsp.Adornee.Parent
		local distFromChar = math.floor(player:DistanceFromCharacter(toolObj.Handle.Position))
		guiEsp.itemDist.Text = string.format("%sm", distFromChar)
		guiEsp.Enabled = (distFromChar >= 10 and (toolObj:IsDescendantOf(workspace)) and not toolObj.Parent:FindFirstChildWhichIsA("Humanoid")) and true or false
	end
end))
