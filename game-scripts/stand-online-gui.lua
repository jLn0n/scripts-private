-- services
local players = game:GetService("Players")
local runService = game:GetService("RunService")
local coreGui = game:GetService("CoreGui")
-- objects
local player = players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local espFolder = coreGui:FindFirstChild("espFolder") or Instance.new("Folder")
-- init
_G.SO_GUI_CONNECTIONS = table.create(0)
if _G.SO_GUI_EXECUTED then
	if espFolder.Name ~= "espFolder" then
		espFolder.Name, espFolder.Parent = "espFolder", coreGui
	end
	for _, connection in ipairs(_G.SO_GUI_CONNECTIONS) do connection:Disconnect() end
	espFolder:ClearAllChildren()
	coreGui:FindFirstChild("ScreenGui"):Destroy()
end
local library = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/Kiwi-i/wallys-ui-fork/master/lib.lua", true))()
local window = library:CreateWindow("Stands Online")
-- main
local function checkTool(toolObj)
	return (toolObj:IsA("Tool") and toolObj:FindFirstChild("Handle") and toolObj.Parent:FindFirstChildWhichIsA("Humanoid"))
end
local function gotAdornied(toolObj)
	for _, espThingy in ipairs(espFolder:GetChildren()) do
		if espThingy.Adornee == toolObj then
			return true
		end
	end
end
local function getDroppedItems(toolObj)
	if window.flags.gditems and checkTool(toolObj) and character.Humanoid.Health ~= 0 then
		character.Humanoid:EquipTool(toolObj)
	end
end
local function itemESP(toolObj)
	if window.flags.itemEsp and checkTool(toolObj) and not gotAdornied(toolObj) then
		local guiEsp, itemName, itemDist = Instance.new("BillboardGui"), Instance.new("TextLabel"), Instance.new("TextLabel")
		guiEsp.Name, itemName.Name, itemDist.Name = "itemGui", "itemName", "itemDist"
		guiEsp.Parent, itemName.Parent, itemDist.Parent = espFolder, guiEsp, guiEsp
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
		local distFromChar, connection
		connection = runService.Heartbeat:Connect(function()
			if not window.flags.itemesp or toolObj.Parent == nil then
				guiEsp:Destroy()
				connection:Disconnect()
			end
			distFromChar = math.floor(player:DistanceFromCharacter(toolObj.Handle.Position))
			itemDist.Text = string.format("%sm", distFromChar)
			guiEsp.Enabled = (distFromChar <= 10 or not toolObj.Parent:IsA("Workspace")) and true or false
		end)
		table.insert(_G.SO_GUI_CONNECTIONS. connection)
	end
end
table.insert(_G.SO_GUI_CONNECTIONS, workspace.ChildAdded:Connect(function()
	for _, object in ipairs(workspace:GetChildren()) do
		itemESP(object)
		getDroppedItems(object)
	end
end))
table.insert(_G.SO_GUI_CONNECTIONS, player.CharacterRemoving:Connect(function()
	character = player.CharacterAdded:Wait()
end))
window:Section("Made by: jLn0n#1464")
window:Toggle("Get Dropped Items", {flag = "gditems"}, function()
	if window.flags.gditems then
		for _, object in ipairs(workspace:GetChildren()) do
			getDroppedItems(object)
		end
	end
end)
window:Toggle("Item ESP", {flag = "itemEsp"}, function()
	if window.flags.itemesp then
		for _, object in ipairs(workspace:GetChildren()) do
			itemESP(object)
		end
	end
end)
window:Button("Destroy GUI", function()
	for _, connection in ipairs(_G.SO_GUI_CONNECTIONS) do connection:Disconnect() end
	espFolder:ClearAllChildren()
	coreGui:WaitForChild("ScreenGui"):Destroy()
end)
