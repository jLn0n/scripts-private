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
local eventsFolder = gameUI.Events
local quests = player.PlayerGui:FindFirstChild("Quest").Quest
local plrStatus = character:FindFirstChild("Status")
local espFolder
-- variables
local currentLvl
local tpFarmingOffset
local killingMobs, killingSeaCreature = false, false
local ui_library = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/zxciaz/VenyxUI/main/Reuploaded"))()
local events = table.create(0)
local itemsList = {
	["rokaFruit"] = "Rokakaka",
	["standArrow"] = "Stand Arrow",
	["refArrow"] = "Refined Arrow",
	["reqArrow"] = "Requiem Arrow",
	["discItem"] = "Disc",
	["diaryItem"] = "Heavenly Diary",
	["hamonItem"] = "Hamon Headband",
	["maskItem"] = "Vampire Mask",
	["ballItem"] = "Steel Ball",
	["eventItems"] = "Event Items",
	["otherItems"] = "Other Items"
}
local otherItemsList = {
	"Roka-Cola",
	"Color Arrow",
	"Pose Arrow",
	"Idle Arrow",
	"Sound Arrow",
	"Face Arrow",
}
local eventItemsList = {
	"Gift",
	"Spooky Arrow",
	"Scary Arrow"
}
-- config init
local config = {
	["expUtil"] = {
		["expFarm"] = false,
		["plrDist"] = 3,
		["autoPrestige"] = false,
	},
	["itemUtil"] = {
		["itemFarm"] = false,
		["itemFarming"] = "default",
		["itemWL"] = table.create(0),
		["itemEsp"] = false,
	},
	["miscUtil"] = {
		["antiAfk"] = false,
		["seaCreatureFarm"] = false,
		["walkspeed"] = 16,
		["jumppower"] = 50
	},
	["configVer"] = 1
}
-- functions
local invokeFunc = Instance.new("RemoteFunction").InvokeServer
local function updateEventsList()
	repeat runService.Heartbeat:Wait() until #eventsFolder:GetChildren() ~= 0
	table.clear(events)
	for _, object in eventsFolder:GetChildren() do
		events[object.Name] = object
	end
end
local function getTool(toolObj) -- returns the tool if it passes a certain condition
	toolObj = (
		(toolObj:IsA("Model") and toolObj:FindFirstChildWhichIsA("Tool")) and toolObj:FindFirstChildWhichIsA("Tool") or
		--(toolObj:IsA("Model") and toolObj:FindFirstChildWhichIsA("ClickDetector", true)) and toolObj:FindFirstChildWhichIsA("MeshPart") or
		toolObj:IsA("Tool") and toolObj or nil
	)
	return (toolObj and ((toolObj:IsA("BasePart") or toolObj:FindFirstChild("Handle")) and toolObj:IsDescendantOf(workspace)) and not toolObj.Parent:FindFirstChildWhichIsA("Humanoid")) and toolObj or nil
end
local function getCurrentLvl() -- maybe improve this
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
			"Gorilla"
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
local function checkMob(mobEntity)
	local mobHumanoid, mobRootPart = mobEntity:FindFirstChild("Humanoid"), mobEntity:FindFirstChild("HumanoidRootPart")

	return (mobEntity:IsA("Model") and (mobRootPart and (mobHumanoid and mobHumanoid.Health ~= 0))), mobHumanoid, mobRootPart
end
local function gotAdornied(toolObj)
	for _, espThingy in espFolder:GetChildren() do
		if espThingy.Adornee.Parent == toolObj then
			return true
		end
	end
end
local function itemFarmable(itemName_in)
	for configId, itemName in itemsList do
		if not string.find(itemName_in, itemName) then continue end
		return config.itemUtil.itemWL[configId]
	end

	if config.itemUtil.itemWL.otherItems then
		for _, itemName in otherItemsList do
			if not string.find(itemName_in, itemName) then continue end
			return true
		end
	end

	if config.itemUtil.itemWL.eventItems then
		for _, itemName in eventItemsList do
			if not string.find(itemName_in, itemName) then continue end
			return true
		end
	end
	return false
end
local function tpPlayer(position, tpCompletedWait)
	if not rootPart then return end
	position = (if typeof(position) == "CFrame" then position elseif typeof(position) == "Vector3" then CFrame.new(position) else nil)
	local _tweenInfo = TweenInfo.new(player:DistanceFromCharacter(position.Position) / 150, Enum.EasingStyle.Linear)
	local tweenObj = tweenService:Create(rootPart, _tweenInfo, {
		CFrame = position
	})
	local _anchorConnection = rootPart:GetPropertyChangedSignal("Anchored"):Connect(function()
		local func = (if rootPart.Anchored then tweenObj.Pause else tweenObj.Play)
		func(tweenObj)
	end)

	tweenObj.Completed:Connect(function(playbackState)
		if playbackState == Enum.PlaybackState.Completed then
			tpCompleted:Fire(position)
			_anchorConnection:Disconnect()
			tweenObj:Destroy()
		end
	end)
	tweenObj:Play()

	if tpCompletedWait then
		local tpCompletedValue

		task.spawn(function()
			tpCompletedValue = tpCompleted.Event:Wait()
		end)
		repeat runService.Heartbeat:Wait() until (tpCompletedValue == position)
	end
end
local function getItem(toolObj)
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
local function toggleAntiAfk(value)
	for _, connection in getconnections(player.Idled) do
		local func = (if not value then connection.Enable else (connection.Disable or connection.Disconnect))
		func(connection)
	end
end
-- ui init
local window = ui_library.new("Stands Online")

local farming_page = window:addPage("Farming", 5012544693)
local expFarm_sect = farming_page:addSection("EXP Utils")
local itemFarm_sect = farming_page:addSection("Item Utils")
local itemFarm_items = farming_page:addSection("Item Whitelist")

local misc_page = window:addPage("Misceleanous")
local misc_sect = misc_page:addSection("Misceleanous")

local settings_page = window:addPage("Settings")
local settings_sect = settings_page:addSection("Settings")

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
for configId, itemName in itemsList do
	config.itemUtil.itemWL[configId] = true
	itemFarm_items:addToggle(itemName, config.itemUtil.itemWL[configId], function(value)
		config.itemUtil.itemWL[configId] = value
	end)
end

misc_sect:addToggle("Anti-AFK", config.miscUtil.antiAfk, function(value)
	config.miscUtil.antiAfk = value
	toggleAntiAfk(value)
end)
misc_sect:addToggle("Sea Creature Farm", config.miscUtil.seaCreatureFarm, function(value)
	config.miscUtil.seaCreatureFarm = value
end)
misc_sect:addSlider("WalkSpeed", config.miscUtil.walkspeed, 0, 100, function(value)
	config.miscUtil.walkspeed = value
end)
misc_sect:addSlider("JumpPower", config.miscUtil.jumppower, 0, 100, function(value)
	config.miscUtil.jumppower = value
end)

settings_sect:addKeybind("UI Toggle", Enum.KeyCode.RightControl, function()
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
		_G.standOnline_GUI.espFolder = espFolder
	end
	_G.standOnline_GUI.executed = true
	_G.standOnline_GUI.runFarmLoop = false
end
do
	tpFarmingOffset = ((CFrame.identity + (Vector3.yAxis * config.expUtil.plrDist)) * CFrame.Angles(math.rad(-90), 0, 0))
	toggleAntiAfk(config.miscUtil.antiAfk)
	task.spawn(updateEventsList)
end
-- main
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
	eventsFolder = gameUI:WaitForChild("Events")
	task.spawn(updateEventsList)
end))
table.insert(_G.standOnline_GUI.connections, runService.Heartbeat:Connect(function()
	currentLvl = getCurrentLvl()

	if config.expUtil.autoPrestige and currentLvl == 100 then
		task.spawn(invokeFunc, events.Prestige)
	end

	if config.expUtil.expFarm then
		rootPart.Velocity, rootPart.RotVelocity = Vector3.zero, Vector3.zero
	end

	humanoid.WalkSpeed, humanoid.JumpPower = config.miscUtil.walkspeed, config.miscUtil.jumppower

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
	if config.expUtil.expFarm then
		for _, object in character:GetChildren() do
			if not object:IsA("BasePart") then continue end
			object.CanCollide = false
		end
	end
end))
_G.standOnline_GUI.runFarmLoop = true
while _G.standOnline_GUI.runFarmLoop do runService.Heartbeat:Wait()
	if (not (config.expUtil.expFarm and currentLvl)) or not (humanoid and rootPart) then continue end

	if config.miscUtil.seaCreatureFarm and not killingSeaCreature then
		killingSeaCreature = true
		for _, object in workspace:GetChildren() do
			local passedCheck, mobHumanoid, mobRootPart = checkMob(object)
			if object.Name == "Sea Creature" and (passedCheck and (mobRootPart and mobHumanoid)) then
				local mobSizeY do
					local sizeVect3 = object:GetExtentsSize()
					mobSizeY = (Vector3.yAxis * sizeVect3.Y)
				end
				spawnStand(true)
				tpPlayer(mobRootPart.CFrame, true)

				repeat runService.Heartbeat:Wait()
					humanoid:ChangeState(11)
					rootPart.CFrame = ((mobRootPart.CFrame * tpFarmingOffset) + mobSizeY)
					task.delay(10, invokeFunc, events.Barrage)
					task.delay(10, invokeFunc, events.Heavy)
					task.spawn(invokeFunc, events.Punch)
				until not (humanoid and rootPart) or (humanoid.Health == 0 or mobHumanoid.Health == 0)
				break
			end
		end
		killingSeaCreature = false
	end

	if (config.expUtil.expFarm and currentLvl) and not killingSeaCreature then
		local farmingMob = getFarmingMob()
		local questName = (if farmingMob == "Gorilla" then "🦍😡💢" elseif farmingMob == "HamonGolem" then "Golem" else farmingMob).. " Quest"

		if not (quests:FindFirstChildWhichIsA("Frame") and string.find(quests:FindFirstChildWhichIsA("Frame").Name, "Quest")) then
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
				local passedCheck, mobHumanoid, mobRootPart = checkMob(object)
				if object.Name == farmingMob and (passedCheck and (mobRootPart and mobHumanoid)) then
					local mobSizeY do
						local sizeVect3 = object:GetExtentsSize()
						mobSizeY = (Vector3.yAxis * sizeVect3.Y)
					end
					spawnStand(true)
					tpPlayer(mobRootPart.CFrame, true)

					repeat runService.Heartbeat:Wait()
						humanoid:ChangeState(11)
						rootPart.CFrame = ((mobRootPart.CFrame * tpFarmingOffset) + mobSizeY)
						task.delay(10, invokeFunc, events.Barrage)
						task.delay(10, invokeFunc, events.Heavy)
						task.spawn(invokeFunc, events.Punch)
					until not (humanoid and rootPart) or (humanoid.Health == 0 or mobHumanoid.Health == 0) or (not config.expUtil.expFarm or not quests:FindFirstChildWhichIsA("Frame"))
				end
			end
			killingMobs = false
		end
	end
	task.wait(1)
end
