-- // SERVICES
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
-- // OBJECTS
local Player = Players.LocalPlayer
-- // INIT
if CoreGui:FindFirstChild("ScreenGui") then CoreGui:FindFirstChild("ScreenGui"):Destroy() end
local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Kiwi-i/wallys-ui-fork/master/lib.lua", true))()
local window = library:CreateWindow("Stands Online")
-- // MAIN
local GetItems = function(object)
	if window.flags.autoget and object:IsA("Tool") and object:FindFirstChild("Handle") and not object.Parent:FindFirstChild("Humanoid") and Player.Character.Humanoid.Health ~= 0 then
		Player.Character.Humanoid:EquipTool(object)
		for _ = 1, 15 do
			if object.Parent == workspace then
				Player.Character.Humanoid:EquipTool(object)
			else
				break
			end
		end
	end
end
local ItemESP = function(object)
	if window.flags.itemesp and object:IsA("Tool") and object:FindFirstChild("Handle") and not object.Parent:FindFirstChild("Humanoid") and not object:FindFirstChild("BGUI_ESP") then
		local ESPGUI = Instance.new("BillboardGui")
		local ItemName = Instance.new("TextLabel")
		local ItemDistance = Instance.new("TextLabel")
		ESPGUI.Name = "BGUI_ESP"
		ESPGUI.Parent = object
		ESPGUI.Adornee = object.Handle
		ESPGUI.Active = true
		ESPGUI.AlwaysOnTop = true
		ESPGUI.DistanceLowerLimit = 1
		ESPGUI.DistanceStep = 0
		ESPGUI.DistanceUpperLimit = 1
		ESPGUI.Size = UDim2.new(0, 250, 0, 30)
		ESPGUI.StudsOffset = Vector3.new(0, 1, 0)
		ItemName.Name = "ItemName"
		ItemName.Parent = ESPGUI
		ItemName.BackgroundTransparency = 1
		ItemName.Size = UDim2.new(1, 0, 0, 15)
		ItemName.Font = Enum.Font.GothamBold
		ItemName.TextSize = Enum.FontSize.Size14
		ItemName.Text = object.Name
		ItemName.TextColor3 = object.Handle.Color
		ItemName.TextSize = 15
		ItemName.TextStrokeColor3 = Color3.fromRGB(255, 255, 255)
		ItemName.TextStrokeTransparency = 0
		ItemDistance.Name = "ItemDistance"
		ItemDistance.Parent = ESPGUI
		ItemDistance.BackgroundTransparency = 1
		ItemDistance.Position = UDim2.new(0, 0, 0, 15)
		ItemDistance.Size = UDim2.new(1, 0, 0, 15)
		ItemDistance.Font = Enum.Font.GothamBold
		ItemDistance.TextSize = Enum.FontSize.Size14
		ItemDistance.TextColor3 = object.Handle.Color
		ItemDistance.TextSize = 15
		ItemDistance.TextStrokeColor3 = Color3.fromRGB(255, 255, 255)
		ItemDistance.TextStrokeTransparency = 0
		local DistanceFromItem, connection
		connection = RunService.Heartbeat:Connect(function()
			DistanceFromItem = math.floor((Player.Character.HumanoidRootPart.Position - object.Handle.Position).magnitude)
			ItemDistance.Text = string.format("%sm", DistanceFromItem)
			if DistanceFromItem < 9 or object.Parent:FindFirstChild("Humanoid") then
				ESPGUI.Enabled = false
			else
				ESPGUI.Enabled = true
			end
			if not window.flags.itemesp or object.Parent == nil then
				ESPGUI:Destroy()
				connection:Disconnect()
			end
		end)
	end
end
local connection = workspace.ChildAdded:Connect(function(object)
	wait()
	GetItems(object)
	ItemESP(object)
end)
window:Section("Made by: jLn0n#1464")
window:Toggle("AutoGet Items", {flag = "autoget"}, function()
	if window.flags.autoget then
		for _, object in ipairs(workspace:GetChildren()) do
			GetItems(object)
		end
	end
end)
window:Toggle("Item ESP", {flag = "itemesp"}, function()
	if window.flags.itemesp then
		for _, object in ipairs(workspace:GetChildren()) do
			ItemESP(object)
		end
	end
end)
window:Button("Destroy GUI", function()
	CoreGui:WaitForChild("ScreenGui"):Destroy()
	connection:Disconnect()
end)