-- services
local coreGui = game:GetService("CoreGui")
local players = game:GetService("Players")
local runService = game:GetService("RunService")
local tweenService = game:GetService("TweenService")
-- objects
local player = players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local espFolder = coreGui:FindFirstChild("espFolder") or Instance.new("Folder")
-- init
do
	_G.SO_GUI_CONNECTIONS = not _G.SO_GUI_CONNECTIONS and table.create(0) or _G.SO_GUI_CONNECTIONS
	if _G.SO_GUI_EXECUTED then
		if espFolder.Name ~= "espFolder" then
			espFolder.Name, espFolder.Parent = "espFolder", coreGui
		end
		for _, connection in ipairs(_G.SO_GUI_CONNECTIONS) do connection:Disconnect() end
		espFolder:ClearAllChildren()
		coreGui:FindFirstChild("ScreenGui"):Destroy()
	end
	if espFolder.Name ~= "espFolder" then
		espFolder.Name, espFolder.Parent = "espFolder", coreGui
	end
	_G.SO_GUI_EXECUTED = true
end
local library = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/Kiwi-i/wallys-ui-fork/master/lib.lua", true))()
local window = library:CreateWindow("Stands Online")
-- main
local function getTool(toolObj) -- returns a tool if it passes a certain condition
	toolObj = ((toolObj:IsA("Model") and toolObj:FindFirstChildWhichIsA("Tool")) and toolObj:FindFirstChildWhichIsA("Tool") or toolObj:IsA("Tool") and toolObj or nil)
	return (toolObj and (toolObj:FindFirstChild("Handle") and toolObj:IsDescendantOf(workspace)) and not toolObj.Parent:FindFirstChildWhichIsA("Humanoid")) and toolObj or nil
end
local function gotAdornied(toolObj)
	for _, espThingy in ipairs(espFolder:GetChildren()) do
		if espThingy.Adornee.Parent == toolObj then
			return true
		end
	end
end
local function tpPlayer(posCFrame)
	posCFrame = typeof(posCFrame) == "Vector3" and CFrame.new(posCFrame) or posCFrame
	local _tweenInfo = TweenInfo.new(player:DistanceFromCharacter(posCFrame.Position) / (4.5 * 10), Enum.EasingStyle.Quad)
	local tweenObj = tweenService:Create(character.HumanoidRootPart, _tweenInfo, {
		CFrame = (posCFrame * CFrame.new(Vector3.new(0, .5, 0)))
	})
	tweenObj.Completed:Connect(function()
		tweenObj:Destroy()
	end)
	tweenObj:Play()
	return tweenObj.Completed
end
local function getDroppedItems()
	for _, toolObj in ipairs(workspace:GetChildren()) do
		toolObj = getTool(toolObj)
		if not window.flags.gditems then break end
		if (toolObj and character.Humanoid.Health ~= 0) then
			if toolObj.Parent:IsA("Workspace") then
				character.Humanoid:EquipTool(toolObj)
			elseif toolObj.Parent:IsA("Model") then
				local toolHandle = toolObj:FindFirstChild("Handle")
				tpPlayer(toolHandle.Position):Wait()
				task.wait(.2)
				firetouchinterest(toolHandle, character.HumanoidRootPart, 0)
				firetouchinterest(toolHandle, character.HumanoidRootPart, 1)
			end
		end
	end
end
local function itemESP(toolObj)
	toolObj = getTool(toolObj)
	if window.flags.itemEsp and (toolObj and not gotAdornied(toolObj)) then
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
table.insert(_G.SO_GUI_CONNECTIONS, workspace.ChildAdded:Connect(function()
	for _, object in ipairs(workspace:GetChildren()) do
		itemESP(object)
	end
	getDroppedItems()
end))
table.insert(_G.SO_GUI_CONNECTIONS, player.CharacterRemoving:Connect(function()
	character = player.CharacterAdded:Wait()
end))
table.insert(_G.SO_GUI_CONNECTIONS, runService.Heartbeat:Connect(function()
	for _, guiEsp in ipairs(espFolder:GetChildren()) do
		if not window.flags.itemEsp or not (guiEsp.Adornee or guiEsp:FindFirstChild("itemDist")) or not guiEsp.Adornee:IsDescendantOf(game) then
			guiEsp:Destroy()
			continue
		end
		local toolObj = guiEsp.Adornee.Parent
		local distFromChar = math.floor(player:DistanceFromCharacter(toolObj.Handle.Position))
		guiEsp:FindFirstChild("itemDist").Text = string.format("%sm", distFromChar)
		guiEsp.Enabled = (distFromChar >= 10 and (toolObj:IsDescendantOf(workspace)) and not toolObj.Parent:FindFirstChildWhichIsA("Humanoid")) and true or false
	end
end))
window:Section("Made by: jLn0n#1464")
window:Toggle("Get Dropped Items", {flag = "gditems"}, function()
	if window.flags.gditems then
		coroutine.wrap(getDroppedItems)()
	end
end)
window:Toggle("Item ESP", {flag = "itemEsp"}, function()
	if window.flags.itemEsp then
		for _, object in ipairs(workspace:GetChildren()) do
			itemESP(object)
		end
	end
end)
window:Button("Destroy GUI", function()
	for _, connection in ipairs(_G.SO_GUI_CONNECTIONS) do connection:Disconnect() end
	espFolder:ClearAllChildren()
	coreGui:WaitForChild("ScreenGui"):Destroy()
	_G.SO_GUI_EXECUTED = false
end)
