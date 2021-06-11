-- // SERVICES
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
-- // OBJECTS
local Player = Players.LocalPlayer
-- // INIT
if CoreGui:FindFirstChild("ScreenGui") then CoreGui:FindFirstChild("ScreenGui"):Destroy() _G.CAConnection:Disconnect(); _G.CAConnection = nil end
local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Kiwi-i/wallys-ui-fork/master/lib.lua", true))()
local window = library:CreateWindow("Stands Online")
-- // MAIN
local GetItems = function(object)
	if window.flags.gditems and object:IsA("Tool") and not object.Parent:FindFirstChildWhichIsA("Humanoid") and object:FindFirstChild("Handle") and Player.Character.Humanoid.Health ~= 0 then
		for _ = 1, 10 do
			Player.Character.Humanoid:EquipTool(object)
		end
	end
end
local ItemESP = function(object)
	if window.flags.itemesp and object:IsA("Tool") and not object.Parent:FindFirstChildWhichIsA("Humanoid") and object:FindFirstChild("Handle") and not object.Handle:FindFirstChild("BGUI_ESP") then
		local ESPGUI = Instance.new("BillboardGui")
		local ItemName = Instance.new("TextLabel")
		local ItemDistance = Instance.new("TextLabel")
		ESPGUI.Name = "BGUI_ESP"
		ESPGUI.Parent = object.Handle
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
			if not window.flags.itemesp or not _G.CAConnection or object.Parent == nil then
				ESPGUI:Destroy()
				connection:Disconnect()
			end
			DistanceFromItem = math.floor((Player.Character.HumanoidRootPart.Position - object.Handle.Position).magnitude)
			ItemDistance.Text = string.format("%sm", DistanceFromItem)
			if DistanceFromItem < 9 or not object.Parent:IsA("Workspace") then
				ESPGUI.Enabled = false
			else
				ESPGUI.Enabled = true
			end
		end)
	end
end
_G.CAConnection = Workspace.ChildAdded:Connect(function()
	for _, object in ipairs(Workspace:GetChildren()) do
		ItemESP(object)
		GetItems(object)
	end
end)
window:Section("Made by: jLn0n#1464")
window:Toggle("Get Dropped Items", {flag = "gditems"}, function()
	if window.flags.gditems then
		for _, object in ipairs(Workspace:GetChildren()) do
			GetItems(object)
		end
	end
end)
window:Toggle("Item ESP", {flag = "itemesp"}, function()
	if window.flags.itemesp then
		for _, object in ipairs(Workspace:GetChildren()) do
			ItemESP(object)
		end
	end
end)
window:Button("Destroy GUI", function()
	CoreGui:WaitForChild("ScreenGui"):Destroy()
	_G.CAConnection:Disconnect()
	_G.CAConnection = nil
end)
