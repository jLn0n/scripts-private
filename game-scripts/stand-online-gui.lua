-- services
local coreGui = game:GetService("CoreGui")
local players = game:GetService("Players")
local runService = game:GetService("RunService")
local tweenService = game:GetService("TweenService")
-- objects
local player = players.LocalPlayer
local gameUI = player.PlayerGui:FindFirstChild("CoreGUI")
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:FindFirstChildWhichIsA("Humanoid")
local rootPart = character:FindFirstChild("HumanoidRootPart")
local tpCompleted = Instance.new("BindableEvent")
-- folders
local events = gameUI.Events
local quests = player.PlayerGui:FindFirstChild("Quest").Quest
local plrStatus = character:FindFirstChild("Status")
local espFolder
-- variables
local currentLvl
local tpFarmingOffset
local killingMobs = false
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
		["plrDist"] = 5,
		["autoPrestige"] = false,
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
local invokeFunc = Instance.new("RemoteFunction").InvokeServer
local function getTool(toolObj) -- returns the tool if it passes a certain condition
	toolObj = (
		(toolObj:IsA("Model") and toolObj:FindFirstChildWhichIsA("Tool")) and toolObj:FindFirstChildWhichIsA("Tool") or
		--(toolObj:IsA("Model") and toolObj:FindFirstChildWhichIsA("ClickDetector", true)) and toolObj:FindFirstChildWhichIsA("MeshPart") or
		toolObj:IsA("Tool") and toolObj or nil
	)
	return (toolObj and ((toolObj:IsA("BasePart") or toolObj:FindFirstChild("Handle")) and toolObj:IsDescendantOf(workspace)) and not toolObj.Parent:FindFirstChildWhichIsA("Humanoid")) and toolObj or nil
end
local function getCurrentLvl()
	if not (gameUI and gameUI:FindFirstChild("Frame")) then return end
	local lvl = string.gsub(gameUI.Frame.EXPBAR.TextLabel.Text, "%D", "")
	return tonumber(lvl)
end
local function getFarmingMob()
	return (
		if currentLvl >= 80 then
			"HamonGolem"
		elseif currentLvl >= 65 then
			"Vampire"
		elseif currentLvl >= 45 then
			"Zombie"
		elseif currentLvl >= 30 then
			"Werewolf"
		elseif currentLvl >= 20 then
			"Gorilla" -- 🦍
		elseif currentLvl >= 10 then
			"Brute"
		elseif currentLvl >= 1 then
			"Thug"
		else nil
	)
end
local function spawnStand(spawn)
	if not (plrStatus and plrStatus.StandOut.Value ~= spawn) then return end
	task.spawn(events.SummonStand.InvokeServer, events.SummonStand)
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
local function tpPlayer(position, tpCompletedWait)
	if not rootPart then return end
	position = (if typeof(position) == "CFrame" then position elseif typeof(position) == "Vector3" then CFrame.new(position) else nil)
	local _tweenInfo = TweenInfo.new(player:DistanceFromCharacter(position.Position) / 150, Enum.EasingStyle.Linear)
	local tweenObj = tweenService:Create(rootPart, _tweenInfo, {
		CFrame = position
	})
	tweenObj.Completed:Connect(function(playbackState)
		if playbackState == Enum.PlaybackState.Completed then
			tpCompleted:Fire(position)
			tweenObj:Destroy()
		end
	end)
	tweenObj:Play()
	if tpCompletedWait then
		local tpCompletedValue do
			task.spawn(function()
				tpCompletedValue = tpCompleted.Event:Wait()
			end)
		end
		repeat runService.Heartbeat:Wait() until tpCompletedValue == position
	end
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
					firetouchinterest(toolHandle, rootPart, 0)
					firetouchinterest(toolHandle, rootPart, 1)
				elseif toolObjThingy:IsA("ClickDetector") then
					fireclickdetector(toolObjThingy)
					task.wait(2)
					fireclickdetector(toolObjThingy)
				end
			end
		end
	end
end
local function getItems()
	if not config.itemUtil.itemFarm then return end
	for _, object in workspace:GetChildren() do
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

local expFarm_sect = farming_page:addSection("EXP Utils")
local itemFarm_sect = farming_page:addSection("Item Utils")
local itemFarm_items = farming_page:addSection("Item Whitelist")

local settings_sect = window:addPage("Settings")
local settings_section = settings_sect:addSection("Settings")

expFarm_sect:addToggle("EXP Farm", config.expUtil.expFarm, function(value)
	config.expUtil.expFarm = value
	killingMobs = false
end)
expFarm_sect:addSlider("Distance", config.expUtil.plrDist, 0, 10, function(value)
	config.expUtil.plrDist = value
	tpFarmingOffset = ((CFrame.identity + (Vector3.yAxis * value)) * CFrame.Angles(math.rad(-90), 0, 0))
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
	_G.standOnline_GUI.runFarmLoop = false
end
-- main
tpFarmingOffset = ((CFrame.identity + (Vector3.yAxis * config.expUtil.plrDist)) * CFrame.Angles(math.rad(-90), 0, 0))
table.insert(_G.standOnline_GUI.connections, workspace.ChildAdded:Connect(function()
	task.spawn(getItems)
	for _, object in workspace:GetChildren() do
		itemESP(object)
	end
end))
table.insert(_G.standOnline_GUI.connections, player.CharacterAdded:Connect(function(spawnedChar)
	task.wait(.5)
	character = spawnedChar
	humanoid = character:FindFirstChildWhichIsA("Humanoid")
	rootPart = character:FindFirstChild("HumanoidRootPart")
	plrStatus = character:FindFirstChild("Status")
	gameUI = player.PlayerGui:WaitForChild("CoreGUI")
	events = gameUI.Events
end))
table.insert(_G.standOnline_GUI.connections, runService.Heartbeat:Connect(function()
	currentLvl = getCurrentLvl()

	if config.expUtil.autoPrestige and currentLvl == 100 then
		task.spawn(invokeFunc, events.Prestige)
	end
	if config.expUtil.expFarm then
		rootPart.Velocity, rootPart.RotVelocity = Vector3.zero, Vector3.zero
	end

	for _, guiEsp in espFolder:GetChildren() do
		if not config.itemUtil.itemEsp or not (guiEsp.Adornee or guiEsp:FindFirstChild("itemDist")) or not guiEsp.Adornee:IsDescendantOf(game) then
			guiEsp:Destroy()
			continue
		end
		local toolObj = guiEsp.Adornee.Parent
		local distFromChar = math.floor(player:DistanceFromCharacter(toolObj.Handle.Position))
		guiEsp.itemDist.Text = string.format("%sm", distFromChar)
		guiEsp.Enabled = (if (distFromChar >= 10 and (toolObj:IsDescendantOf(workspace)) and not toolObj.Parent:FindFirstChildWhichIsA("Humanoid")) then true else false)
	end
end))
table.insert(_G.standOnline_GUI.connections, runService.Stepped:Connect(function()
	if not config.expUtil.expFarm then return end
	for _, object in character:GetChildren() do
		if not object:IsA("BasePart") then continue end
		object.CanCollide = false
	end
end))
_G.standOnline_GUI.runFarmLoop = true
while _G.standOnline_GUI.runFarmLoop do runService.Heartbeat:Wait()
	if (not (config.expUtil.expFarm and currentLvl)) or not (humanoid and rootPart) then continue end
	local farmingMob = getFarmingMob()

	if not (quests:FindFirstChildWhichIsA("Frame") and string.find(quests:FindFirstChildWhichIsA("Frame").Name, farmingMob)) then
		local questName = (if farmingMob == "Gorilla" then "🦍😡💢" elseif farmingMob == "HamonGolem" then "Golem" else farmingMob) .. " Quest"
		for _, object in workspace:GetChildren() do
			if string.find(object.Name, questName) and object:FindFirstChild("HumanoidRootPart") then
				spawnStand(false)
				tpPlayer(object.HumanoidRootPart.CFrame, true)
				fireclickdetector(object:FindFirstChild("ClickDetector"))
				task.wait(2)
				fireclickdetector(object:FindFirstChild("ClickDetector"))
				break
			end
		end
	end

	farmingMob = (if farmingMob == "Gorilla" then "🦍" else farmingMob)
	if not killingMobs then
		killingMobs = true
		for _, object in workspace:GetChildren() do
			if (not config.expUtil.expFarm or not quests:FindFirstChildWhichIsA("Frame")) then break end
			if (object.Name == farmingMob and object:FindFirstChild("HumanoidRootPart") and (object:FindFirstChild("Humanoid") and object.Humanoid ~= 0)) then
				local mobHumanoid, mobRootPart = object:FindFirstChild("Humanoid"), object:FindFirstChild("HumanoidRootPart")
				local mobSize do
					local sizeVect3 = object:GetExtentsSize()
					mobSize = (Vector3.yAxis * sizeVect3.Y)
				end
				spawnStand(true)
				tpPlayer(mobRootPart.CFrame, true)

				repeat runService.Heartbeat:Wait()
					humanoid:ChangeState(11)
					rootPart.CFrame = (mobRootPart.CFrame * tpFarmingOffset) + mobSize
					task.delay(10, invokeFunc, events.Barrage)
					task.delay(10, invokeFunc, events.Heavy)
					task.spawn(invokeFunc, events.Punch)
				until not (humanoid and rootPart) or (humanoid.Health == 0 or mobHumanoid.Health == 0) or (not config.expUtil.expFarm or not quests:FindFirstChildWhichIsA("Frame"))
			end
		end
		killingMobs = false
	end
	task.wait(1)
end
