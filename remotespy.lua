-- FrontEnd // UI
-- Objects

local RemoteSpy = Instance.new("ScreenGui")
local BG = Instance.new("Frame")
local Ribbon = Instance.new("ImageLabel")
local Hide = Instance.new("TextButton")
local Title = Instance.new("TextLabel")
local Remotes = Instance.new("ScrollingFrame")
local ButtonsFrame = Instance.new("Frame")
local ToClipboard = Instance.new("TextButton")
local Decompile = Instance.new("TextButton")
local GetReturn = Instance.new("TextButton")
local ClearList = Instance.new("TextButton")
local CryptStrings = Instance.new("TextButton")
local EnableSpy = Instance.new("TextButton")
local Last = Instance.new("TextLabel")
local Total = Instance.new("TextLabel")
local Settings = Instance.new("TextButton")
local SetRemotes = Instance.new("ScrollingFrame")
local Storage = Instance.new("Frame")
local RBTN = Instance.new("TextButton")
local Icon = Instance.new("ImageLabel")
local RemoteName = Instance.new("TextLabel")
local ID = Instance.new("TextLabel")
local SBTN = Instance.new("TextButton")
local Icon_2 = Instance.new("ImageLabel")
local RemoteName_2 = Instance.new("TextLabel")
local ID_2 = Instance.new("TextLabel")
local Enabled = Instance.new("TextLabel")
local FullScreen = Instance.new("TextButton")
local SetRemotesTab = Instance.new("Frame")
local FilterF = Instance.new("TextButton")
local FilterE = Instance.new("TextButton")
local Search = Instance.new("TextBox")
local remotes_fired = 0
local encrypt_string = false
local spy_enabled = true
local synHL_Lib = loadstring(game:HttpGet("https://raw.githubusercontent.com/jLn0n/created-scripts-public/main/lua-syntax-highlighting.lua"))()
local Source = synHL_Lib.new({
	Name = "Source",
	Parent = BG,
	Size = UDim2.new(1, -280, 1, -90),
	Position = UDim2.new(0, 270, 0, 80),
	ZIndex = 1
})
local SourceChildren = Source:getChildren()

-- Properties

RemoteSpy.Name = "RemoteSpy"
RemoteSpy.Parent = game.CoreGui

BG.Name = "BG"
BG.Parent = RemoteSpy
BG.Active = true
BG.AnchorPoint = Vector2.new(.5, .5)
BG.BackgroundColor3 = Color3.new(0.141176, 0.141176, 0.141176)
BG.BorderColor3 = Color3.new(0.243137, 0.243137, 0.243137)
BG.Position = UDim2.new(0.5, 0, 0.5, 0)
BG.Size = UDim2.new(1, -300, 1, -200)
BG.ClipsDescendants = true

Ribbon.Name = "Ribbon"
Ribbon.Parent = BG
Ribbon.BackgroundColor3 = Color3.new(0.760784, 0.0117647, 0.317647)
Ribbon.BorderSizePixel = 0
Ribbon.Size = UDim2.new(1, 0, 0, 20)
Ribbon.ZIndex = 2

Hide.Name = "Hide"
Hide.Parent = Ribbon
Hide.BackgroundColor3 = Color3.new(1, 0, 0)
Hide.BorderSizePixel = 0
Hide.Position = UDim2.new(1, -40, 0, 0)
Hide.Size = UDim2.new(0, 40, 0, 20)
Hide.ZIndex = 3
Hide.Font = Enum.Font.SourceSansBold
Hide.TextSize = Enum.FontSize.Size14
Hide.Text = "_"
Hide.TextColor3 = Color3.new(1, 1, 1)
Hide.TextSize = 14

Title.Name = "Title"
Title.Parent = Ribbon
Title.BackgroundColor3 = Color3.new(1, 0.0117647, 0.423529)
Title.BorderSizePixel = 0
Title.Position = UDim2.new(0.5, -100, 0, 0)
Title.Size = UDim2.new(0, 200, 0, 20)
Title.ZIndex = 3
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = Enum.FontSize.Size14
Title.Text = "Remote2Script v2"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.TextSize = 14

Remotes.Name = "Remotes"
Remotes.Parent = BG
Remotes.BackgroundColor3 = Color3.new(0.0784314, 0.0784314, 0.0784314)
Remotes.BorderColor3 = Color3.new(0.243137, 0.243137, 0.243137)
Remotes.Position = UDim2.new(0, 10, 0, 80)
Remotes.CanvasSize = UDim2.new(0, 0, 40, 0)
Remotes.Size = UDim2.new(0, 250, 1, -90)
Remotes.ZIndex = 2
Remotes.BottomImage = "rbxassetid://148970562"
Remotes.MidImage = "rbxassetid://148970562"
Remotes.ScrollBarThickness = 5
Remotes.TopImage = "rbxassetid://148970562"

ButtonsFrame.Name = "ButtonsFrame"
ButtonsFrame.Parent = BG
ButtonsFrame.BackgroundColor3 = Color3.new(0.0784314, 0.0784314, 0.0784314)
ButtonsFrame.BorderColor3 = Color3.new(0.243137, 0.243137, 0.243137)
ButtonsFrame.Position = UDim2.new(0, 10, 0, 30)
ButtonsFrame.Size = UDim2.new(1, -20, 0, 40)
ButtonsFrame.ZIndex = 2
ButtonsFrame.ClipsDescendants = true

ToClipboard.Name = "ToClipboard"
ToClipboard.Parent = ButtonsFrame
ToClipboard.BackgroundColor3 = Color3.new(0.0784314, 0.0784314, 0.0784314)
ToClipboard.BorderColor3 = Color3.new(0.117647, 0.392157, 0.117647)
ToClipboard.Position = UDim2.new(0, 10, 0.5, -10)
ToClipboard.Size = UDim2.new(0, 100, 0, 20)
ToClipboard.ZIndex = 3
ToClipboard.Font = Enum.Font.SourceSansBold
ToClipboard.TextSize = Enum.FontSize.Size14
ToClipboard.Text = "COPY"
ToClipboard.TextColor3 = Color3.new(0.235294, 0.784314, 0.235294)
ToClipboard.TextSize = 14

Decompile.Name = "Decompile"
Decompile.Parent = ButtonsFrame
Decompile.BackgroundColor3 = Color3.new(0.0784314, 0.0784314, 0.0784314)
Decompile.BorderColor3 = Color3.new(0.384314, 0.384314, 0.384314)
Decompile.Position = UDim2.new(0, 120, 0.5, -10)
Decompile.Size = UDim2.new(0, 100, 0, 20)
Decompile.ZIndex = 3
Decompile.Font = Enum.Font.SourceSansBold
Decompile.TextSize = Enum.FontSize.Size14
Decompile.Text = "DECOMPILE"
Decompile.TextColor3 = Color3.new(0.784314, 0.784314, 0.784314)
Decompile.TextSize = 14

GetReturn.Name = "GetReturn"
GetReturn.Parent = ButtonsFrame
GetReturn.BackgroundColor3 = Color3.new(0.0784314, 0.0784314, 0.0784314)
GetReturn.BorderColor3 = Color3.new(0.384314, 0.384314, 0.384314)
GetReturn.Position = UDim2.new(0, 230, 0.5, -10)
GetReturn.Size = UDim2.new(0, 100, 0, 20)
GetReturn.ZIndex = 3
GetReturn.Font = Enum.Font.SourceSansBold
GetReturn.TextSize = Enum.FontSize.Size14
GetReturn.Text = "GET RETURN"
GetReturn.TextColor3 = Color3.new(0.784314, 0.784314, 0.784314)
GetReturn.TextSize = 14

ClearList.Name = "ClearList"
ClearList.Parent = ButtonsFrame
ClearList.BackgroundColor3 = Color3.new(0.0784314, 0.0784314, 0.0784314)
ClearList.BorderColor3 = Color3.new(0.384314, 0.384314, 0.384314)
ClearList.Position = UDim2.new(0, 340, 0.5, -10)
ClearList.Size = UDim2.new(0, 100, 0, 20)
ClearList.ZIndex = 3
ClearList.Font = Enum.Font.SourceSansBold
ClearList.TextSize = Enum.FontSize.Size14
ClearList.Text = "CLEAR LOGS"
ClearList.TextColor3 = Color3.new(0.784314, 0.784314, 0.784314)
ClearList.TextSize = 14

CryptStrings.Name = "CryptStrings"
CryptStrings.Parent = ButtonsFrame
CryptStrings.BackgroundColor3 = Color3.new(0.0784314, 0.0784314, 0.0784314)
CryptStrings.BorderColor3 = Color3.new(0.392157, 0.117647, 0.117647)
CryptStrings.Position = UDim2.new(0, 450, 0.5, -10)
CryptStrings.Size = UDim2.new(0, 100, 0, 20)
CryptStrings.ZIndex = 3
CryptStrings.Font = Enum.Font.SourceSansBold
CryptStrings.TextSize = Enum.FontSize.Size14
CryptStrings.Text = "CRYPT STRINGS"
CryptStrings.TextColor3 = Color3.new(0.784314, 0.235294, 0.235294)
CryptStrings.TextSize = 14

EnableSpy.Name = "EnableSpy"
EnableSpy.Parent = ButtonsFrame
EnableSpy.BackgroundColor3 = Color3.new(0.0784314, 0.0784314, 0.0784314)
EnableSpy.BorderColor3 = Color3.fromRGB(30, 100, 30)
EnableSpy.Position = UDim2.new(0, 560, 0.5, -10)
EnableSpy.Size = UDim2.new(0, 100, 0, 20)
EnableSpy.ZIndex = 3
EnableSpy.Font = Enum.Font.SourceSansBold
EnableSpy.TextSize = Enum.FontSize.Size14
EnableSpy.Text = "REMOTESPY"
EnableSpy.TextColor3 = Color3.fromRGB(60, 200, 60)
EnableSpy.TextSize = 14

Last.Name = "Last"
Last.Parent = ButtonsFrame
Last.BackgroundColor3 = Color3.new(0.0784314, 0.0784314, 0.0784314)
Last.BorderColor3 = Color3.new(0.384314, 0.384314, 0.384314)
Last.Position = UDim2.new(0, 670, 0.5, -10)
Last.Size = UDim2.new(0, 200, 0, 20)
Last.ZIndex = 3
Last.Font = Enum.Font.SourceSansBold
Last.TextSize = Enum.FontSize.Size14
Last.Text = ""
Last.TextColor3 = Color3.new(1, 1, 1)
Last.TextSize = 14
Last.TextWrapped = true

Total.Name = "Total"
Total.Parent = ButtonsFrame
Total.BackgroundColor3 = Color3.new(0.0784314, 0.0784314, 0.0784314)
Total.BorderColor3 = Color3.new(0.384314, 0.384314, 0.384314)
Total.Position = UDim2.new(0, 880, 0.5, -10)
Total.Size = UDim2.new(0, 50, 0, 20)
Total.ZIndex = 3
Total.Font = Enum.Font.SourceSansBold
Total.TextSize = Enum.FontSize.Size14
Total.Text = "0"
Total.TextColor3 = Color3.new(1, 1, 1)
Total.TextSize = 14
Total.TextWrapped = true

Settings.Name = "Settings"
Settings.Parent = ButtonsFrame
Settings.BackgroundColor3 = Color3.new(0.0784314, 0.0784314, 0.0784314)
Settings.BorderColor3 = Color3.new(0.117647, 0.392157, 0.392157)
Settings.Position = UDim2.new(1, -110, 0.5, -10)
Settings.Size = UDim2.new(0, 100, 0, 20)
Settings.ZIndex = 3
Settings.Font = Enum.Font.SourceSansBold
Settings.TextSize = Enum.FontSize.Size14
Settings.Text = "REMOTES"
Settings.TextColor3 = Color3.new(0.235294, 0.784314, 0.784314)
Settings.TextSize = 14

SetRemotes.Name = "SetRemotes"
SetRemotes.Parent = BG
SetRemotes.BackgroundColor3 = Color3.new(0.0784314, 0.0784314, 0.0784314)
SetRemotes.BorderColor3 = Color3.new(0.243137, 0.243137, 0.243137)
SetRemotes.Position = UDim2.new(0, 270, 0, 80)
SetRemotes.Size = UDim2.new(1, -280, 1, -140)
SetRemotes.Visible = false
SetRemotes.ZIndex = 2
SetRemotes.BottomImage = "rbxassetid://148970562"
SetRemotes.CanvasSize = UDim2.new(0, 0, 25, 0)
SetRemotes.MidImage = "rbxassetid://148970562"
SetRemotes.ScrollBarThickness = 5
SetRemotes.TopImage = "rbxassetid://148970562"

Storage.Name = "Storage"
Storage.Parent = RemoteSpy
Storage.BackgroundColor3 = Color3.new(1, 1, 1)
Storage.Size = UDim2.new(0, 100, 0, 100)
Storage.Visible = false

RBTN.Name = "RBTN"
RBTN.Parent = Storage
RBTN.BackgroundColor3 = Color3.new(0.0784314, 0.0784314, 0.0784314)
RBTN.BorderColor3 = Color3.new(0.243137, 0.243137, 0.243137)
RBTN.Position = UDim2.new(0, 10, 0, 10)
RBTN.Size = UDim2.new(1, -20, 0, 20)
RBTN.ZIndex = 3
RBTN.Font = Enum.Font.SourceSansBold
RBTN.TextSize = Enum.FontSize.Size14
RBTN.Text = ""
RBTN.TextColor3 = Color3.new(0.784314, 0.784314, 0.784314)
RBTN.TextSize = 14
RBTN.TextXAlignment = Enum.TextXAlignment.Left

Icon.Name = "Icon"
Icon.Parent = RBTN
Icon.BackgroundColor3 = Color3.new(1, 1, 1)
Icon.BackgroundTransparency = 1
Icon.Size = UDim2.new(0, 20, 0, 20)
Icon.ZIndex = 4
Icon.Image = "rbxassetid://413369506"

RemoteName.Name = "RemoteName"
RemoteName.Parent = RBTN
RemoteName.BackgroundColor3 = Color3.new(0.713726, 0.00392157, 0.298039)
RemoteName.BorderSizePixel = 0
RemoteName.Position = UDim2.new(0, 30, 0, 0)
RemoteName.Size = UDim2.new(0, 140, 0, 20)
RemoteName.ZIndex = 4
RemoteName.Font = Enum.Font.SourceSansBold
RemoteName.TextSize = Enum.FontSize.Size14
RemoteName.Text = "10"
RemoteName.TextColor3 = Color3.new(0.784314, 0.784314, 0.784314)
RemoteName.TextSize = 14

ID.Name = "ID"
ID.Parent = RBTN
ID.BackgroundColor3 = Color3.new(0.458824, 0.00392157, 0.192157)
ID.BorderSizePixel = 0
ID.Position = UDim2.new(1, -50, 0, 0)
ID.Size = UDim2.new(0, 50, 0, 20)
ID.ZIndex = 4
ID.Font = Enum.Font.SourceSansBold
ID.TextSize = Enum.FontSize.Size14
ID.Text = "10"
ID.TextColor3 = Color3.new(0.784314, 0.784314, 0.784314)
ID.TextSize = 14

SBTN.Name = "SBTN"
SBTN.Parent = Storage
SBTN.BackgroundColor3 = Color3.new(0.0784314, 0.0784314, 0.0784314)
SBTN.BorderColor3 = Color3.new(0.243137, 0.243137, 0.243137)
SBTN.Position = UDim2.new(0, 10, 0, 10)
SBTN.Size = UDim2.new(1, -20, 0, 20)
SBTN.ZIndex = 3
SBTN.Font = Enum.Font.SourceSansBold
SBTN.TextSize = Enum.FontSize.Size14
SBTN.Text = ""
SBTN.TextColor3 = Color3.new(0.784314, 0.784314, 0.784314)
SBTN.TextSize = 11
SBTN.TextXAlignment = Enum.TextXAlignment.Left

Icon_2.Name = "Icon"
Icon_2.Parent = SBTN
Icon_2.BackgroundColor3 = Color3.new(1, 1, 1)
Icon_2.BackgroundTransparency = 1
Icon_2.Size = UDim2.new(0, 20, 0, 20)
Icon_2.ZIndex = 4
Icon_2.Image = "rbxassetid://413369506"

RemoteName_2.Name = "RemoteName"
RemoteName_2.Parent = SBTN
RemoteName_2.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
RemoteName_2.BorderSizePixel = 1
RemoteName_2.BorderColor3 = Color3.fromRGB(62, 62, 62)
RemoteName_2.Position = UDim2.new(0, 30, 0, 0)
RemoteName_2.Size = UDim2.new(0, 140, 0, 20)
RemoteName_2.ZIndex = 4
RemoteName_2.Font = Enum.Font.SourceSansBold
RemoteName_2.TextSize = Enum.FontSize.Size14
RemoteName_2.Text = "SayMessageRequest"
RemoteName_2.TextColor3 = Color3.fromRGB(200, 200, 200)
RemoteName_2.TextSize = 11

ID_2.Name = "ID"
ID_2.Parent = SBTN
ID_2.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
ID_2.BorderSizePixel = 1
ID_2.BorderColor3 = Color3.fromRGB(62, 62, 62)
ID_2.Position = UDim2.new(1, -700, 0, 0)
ID_2.Size = UDim2.new(0, 700, 0, 20)
ID_2.ZIndex = 3
ID_2.Font = Enum.Font.SourceSansBold
ID_2.TextSize = Enum.FontSize.Size14
ID_2.Text = "10"
ID_2.TextColor3 = Color3.new(0.784314, 0.784314, 0.784314)
ID_2.TextSize = 14

Enabled.Name = "Enabled"
Enabled.Parent = SBTN
Enabled.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Enabled.BorderSizePixel = 1
Enabled.BorderColor3 = Color3.fromRGB(30, 100, 30)
Enabled.Position = UDim2.new(0, 210, 0, 0)
Enabled.Size = UDim2.new(0, 100, 1, 0)
Enabled.ZIndex = 4
Enabled.Font = Enum.Font.SourceSansBold
Enabled.TextSize = Enum.FontSize.Size14
Enabled.Text = "Enabled"
Enabled.TextColor3 = Color3.fromRGB(60, 200, 60)
Enabled.TextSize = 14

FullScreen.Name = "FullScreen"
FullScreen.Parent = Ribbon
FullScreen.BackgroundColor3 = Color3.new(1, 0, 0)
FullScreen.BorderSizePixel = 0
FullScreen.Position = UDim2.new(1, -90, 0, 0)
FullScreen.Size = UDim2.new(0, 40, 0, 20)
FullScreen.ZIndex = 3
FullScreen.Font = Enum.Font.SourceSansBold
FullScreen.TextSize = Enum.FontSize.Size14
FullScreen.Text = "[~]"
FullScreen.TextColor3 = Color3.new(1, 1, 1)
FullScreen.TextSize = 14

SetRemotesTab.Name = "SetRemotesTab"
SetRemotesTab.Parent = BG
SetRemotesTab.Visible = false
SetRemotesTab.BackgroundColor3 = Color3.new(0.0784314, 0.0784314, 0.0784314)
SetRemotesTab.BorderColor3 = Color3.new(0.243137, 0.243137, 0.243137)
SetRemotesTab.ClipsDescendants = true
SetRemotesTab.Position = UDim2.new(0, 270, 1, -50)
SetRemotesTab.Size = UDim2.new(1, -280, 0, 40)
SetRemotesTab.ZIndex = 2

FilterF.Name = "FilterF"
FilterF.Parent = SetRemotesTab
FilterF.BackgroundColor3 = Color3.new(0.0784314, 0.0784314, 0.0784314)
FilterF.BorderColor3 = Color3.new(0.392157, 0.117647, 0.117647)
FilterF.Position = UDim2.new(0, 120, 0.5, -10)
FilterF.Size = UDim2.new(0, 120, 0, 20)
FilterF.ZIndex = 3
FilterF.Font = Enum.Font.SourceSansBold
FilterF.TextSize = Enum.FontSize.Size14
FilterF.Text = "FILTER FUNCTIONS"
FilterF.TextColor3 = Color3.new(0.784314, 0.235294, 0.235294)
FilterF.TextSize = 14

FilterE.Name = "FilterE"
FilterE.Parent = SetRemotesTab
FilterE.BackgroundColor3 = Color3.new(0.0784314, 0.0784314, 0.0784314)
FilterE.BorderColor3 = Color3.new(0.392157, 0.117647, 0.117647)
FilterE.Position = UDim2.new(0, 10, 0.5, -10)
FilterE.Size = UDim2.new(0, 100, 0, 20)
FilterE.ZIndex = 3
FilterE.Font = Enum.Font.SourceSansBold
FilterE.TextSize = Enum.FontSize.Size14
FilterE.Text = "FILTER EVENTS"
FilterE.TextColor3 = Color3.new(0.784314, 0.235294, 0.235294)
FilterE.TextSize = 14

Search.Name = "Search"
Search.Parent = SetRemotesTab
Search.BackgroundColor3 = Color3.new(0.0784314, 0.0784314, 0.0784314)
Search.BorderColor3 = Color3.new(0.243137, 0.243137, 0.243137)
Search.Position = UDim2.new(0, 250, 0.5, -10)
Search.Selectable = true
Search.Size = UDim2.new(1, -260, 0, 20)
Search.ZIndex = 3
Search.Font = Enum.Font.SourceSansBold
Search.TextSize = Enum.FontSize.Size14
Search.Text = "[SEARCH]"
Search.TextColor3 = Color3.new(0.784314, 0.784314, 0.784314)
Search.TextSize = 14

-- FrontEnd-Backend // UI Functions
local Draggify = function(frame, button)
	local TweenService, UIS = game:GetService("TweenService"), game:GetService("UserInputService")
	local dragToggle = false
	local dragInput
	local dragStart
	local startPos
	local updateInput = function(input)
		local delta = input.Position - dragStart
		local pos = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		TweenService:Create(
			frame,
			TweenInfo.new(0),
			{Position = pos}
		):Play()
	end
	button.InputBegan:Connect(function(input)
		if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and UIS:GetFocusedTextBox() == nil then
			dragToggle = true
			dragStart = input.Position
			startPos = frame.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragToggle = false
				end
			end)
		end
	end)
	button.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)
	UIS.InputChanged:Connect(function(input)
		if input == dragInput and dragToggle then
			updateInput(input)
		end
	end)
end

local HasSpecial = function(string)
	return (string:match("%c") or string:match("%s") or string:match("%p") or tonumber(string:sub(1, 1))) ~= nil
end

local GetPath = function(object)
	local strings = {}
	local temp = {}
	local error = false

	while object ~= game do
		if object == nil then
			error = true
			break
		end
		table.insert(temp, object.Parent == game and object.ClassName or object.Name)
		object = object.Parent
	end

	table.insert(strings, "game:GetService(\"" .. temp[#temp] .. "\")")

	for i = #temp - 1, 1, -1 do
		table.insert(strings, HasSpecial(temp[i]) and "[\"" .. temp[i] .. "\"]" or "." .. temp[i])
	end

	return (error and "nil -- Path contained invalid instance" or table.concat(strings, ""))
end

local GetType = function(object)
	local Types = {
		EnumItem = function()
			return string.format("Enum.%s.%s", object.EnumType, object.Name)
		end,
		Instance = function()
			return GetPath(object)
		end,
		CFrame = function()
			return string.format("CFrame.new(%s)", tostring(object))
		end,
		Vector3 = function()
			return string.format("Vector3.new(%s)", tostring(object))
		end,
		BrickColor = function()
			return string.format("BrickColor.new(\"%s\")", object.Name)
		end,
		Color3 = function()
			return string.format("Color3.new(%s)", tostring(object))
		end,
		string = function()
			return string.format("\"%s\"", (encrypt_string and object:gsub(".", function(text) return "\\" .. text:byte() end) or object))
		end,
		Ray = function()
			return string.format("Ray.new(Vector3.new(%s), Vector3.new(%s))", tostring(object.Origin), tostring(object.Direction))
		end
	}
	return Types[typeof(object)] ~= nil and Types[typeof(object)]() or tostring(object)
end

local size_frame = function(frame, UDim)
	frame:TweenSize(UDim, "Out", "Quint", 0.3)
end

local pos_frame = function(frame, UDim)
	frame:TweenPosition(UDim, "Out", "Quint", 0.3)
end

local size_pos_frame = function(frame, UDim, UDim2)
	frame:TweenSizeAndPosition(UDim, UDim2, "Out", "Quint", 0.3)
end

local hide = function()
	BG.AnchorPoint = Vector2.new()
	size_frame(BG, UDim2.new(0, 300, 0, 20))
	pos_frame(BG, UDim2.new(0, 100, 0, -27))
	pos_frame(Title, UDim2.new(0, 0, 0, 0))
	pos_frame(Remotes, UDim2.new(0, 10, 0, 100))
	Source:setProperty("Position", UDim2.new(0, 270, 0, 100))
	SetRemotes.Visible = false
	SetRemotesTab.Visible = false
	Source.Visible = true

	return "[]"
end

local show = function()
	BG.AnchorPoint = Vector2.new(.5, .5)
	size_frame(BG, UDim2.new(1, -300, 1, -200))
	pos_frame(BG, UDim2.new(.5, 0, .5, 0))
	pos_frame(Title, UDim2.new(0.5, -100, 0, 0))
	pos_frame(Remotes, UDim2.new(0, 10, 0, 80))
	Source:setProperty("Position", UDim2.new(0, 270, 0, 80))

	return "_"
end

local onclick_hide = function()
	Hide.Text = Hide.Text == "_" and hide() or show()
end

local onclick_settings = function()
	Source.Visible = not Source.Visible
	SetRemotes.Visible = not Source.Visible
	SetRemotesTab.Visible = not Source.Visible
end

local onclick_remotespy = function()
	spy_enabled = not spy_enabled
	EnableSpy.TextColor3 = EnableSpy.TextColor3 == Color3.fromRGB(60, 200, 60) and Color3.fromRGB(200, 60, 60) or Color3.fromRGB(60, 200, 60)
	EnableSpy.BorderColor3 = EnableSpy.TextColor3 == Color3.fromRGB(200, 60, 60) and Color3.fromRGB(100, 30, 30) or Color3.fromRGB(30, 100, 30)
end

local onclick_cryptstring = function()
	encrypt_string = not encrypt_string
	CryptStrings.TextColor3 = CryptStrings.TextColor3 == Color3.fromRGB(60, 200, 60) and Color3.fromRGB(200, 60, 60) or Color3.fromRGB(60, 200, 60)
	CryptStrings.BorderColor3 = CryptStrings.TextColor3 == Color3.fromRGB(200, 60, 60) and Color3.fromRGB(100, 30, 30) or Color3.fromRGB(30, 100, 30)
end

local clear_logs = function()
	Remotes:ClearAllChildren()
	remotes_fired = 0
	Total.Text = "0"
end

local filter_events = function()
	local n = 0
	for i, object in pairs(SetRemotes:GetChildren()) do
		object.Visible = not (FilterE.TextColor3 == Color3.fromRGB(60, 200, 60) and object.Icon.Image == "rbxassetid://413369623")
		if object.Visible == true then
			n = n + 1
			object.Position = UDim2.new(0, 10, 0, -20 + n * 30)
		else
			object.Position = UDim2.new(0, 10, 0, -20 + i * 30)
		end
	end
end

local filter_functions = function()
	local n = 0
	for i, object in pairs(SetRemotes:GetChildren()) do
		object.Visible = not (FilterF.TextColor3 == Color3.fromRGB(60, 200, 60) and object.Icon.Image == "rbxassetid://413369506")
		if object.Visible == true then
			n = n + 1
			object.Position = UDim2.new(0, 10, 0, -20 + n * 30)
		else
			object.Position = UDim2.new(0, 10, 0, -20 + i * 30)
		end
	end
end

local onclick_fevents = function()
	FilterE.TextColor3 = FilterE.TextColor3 == Color3.fromRGB(60, 200, 60) and Color3.fromRGB(200, 60, 60) or Color3.fromRGB(60, 200, 60)
	FilterE.BorderColor3 = FilterE.TextColor3 == Color3.fromRGB(200, 60, 60) and Color3.fromRGB(100, 30, 30) or Color3.fromRGB(30, 100, 30)
	filter_events()
end

local onclick_ffunctions = function()
	FilterF.TextColor3 = FilterF.TextColor3 == Color3.fromRGB(60, 200, 60) and Color3.fromRGB(200, 60, 60) or Color3.fromRGB(60, 200, 60)
	FilterF.BorderColor3 = FilterF.TextColor3 == Color3.fromRGB(200, 60, 60) and Color3.fromRGB(100, 30, 30) or Color3.fromRGB(30, 100, 30)
	filter_functions()
end

local copy_source = function()
	local scriptVar = SourceChildren.TextSource.Holder.Text
	local copy = (Clipboard and Clipboard.set or Synapse and Synapse.copy or setclipboard)
	copy(scriptVar)
end

local onclick_fullscreen = function()
	BG.AnchorPoint = Vector2.new()
	size_pos_frame(BG, UDim2.new(1, 0, 1, 40), UDim2.new(0, 0, 0, -40))
end

local filter_remotes = function(type)
	local n = 0
	if type == "Text" then
		for i, object in pairs(SetRemotes:GetChildren()) do
			if object.Name:lower():match(Search.Text:lower()) and string ~= "" then
				object.Visible = true
				n = n + 1
			else
				object.Visible = false
			end
			if object.Visible == true then
				object.Position = UDim2.new(0, 10, 0, -20 + n * 30)
			else
				object.Position = UDim2.new(0, 10, 0, -20 + i * 30)
			end
		end
	end
end

local fix = function(string)
	if string == "/e fix" then
		show()
		wait(0.3)
		BG.AnchorPoint = Vector2.new(.5, .5)
		pos_frame(BG, UDim2.new(.5, 0, .5, 0))
	end
end

Draggify(BG, Title)
-- FrontEnd-Connections // UI Events

Hide.MouseButton1Down:Connect(onclick_hide)
Settings.MouseButton1Down:Connect(onclick_settings)
ClearList.MouseButton1Down:Connect(clear_logs)
EnableSpy.MouseButton1Down:Connect(onclick_remotespy)
ToClipboard.MouseButton1Down:Connect(copy_source)
CryptStrings.MouseButton1Down:Connect(onclick_cryptstring)
FullScreen.MouseButton1Down:Connect(onclick_fullscreen)
FilterE.MouseButton1Down:Connect(onclick_fevents)
FilterF.MouseButton1Down:Connect(onclick_ffunctions)
Search.Changed:Connect(filter_remotes)
game:GetService("Players").LocalPlayer.Chatted:Connect(fix)

-- Recursive Remotefill // UI-Backend

local Table_TS
Table_TS = function(tableArg, tabcount)
	tabcount = tabcount or 0
	local result = {}
	for name, value in pairs(tableArg) do
		local varName = string.format("\n%s%s", string.rep("\t", tabcount + 1), (type(name) == "number" and string.format("[%s] = ", name) or string.format("[\"%s\"] = ", name)))
		table.insert(result, varName .. (type(value) == "table" and Table_TS(value, tabcount + 1) or GetType(value)))
	end

	return string.format("{%s\n%s}", table.concat(result, ", "), string.rep("\t", tabcount))
end

local fill
fill = function(base)
	for _, object in pairs(base:GetChildren()) do
		if object.ClassName:match("Remote") and object.Name ~= "CharacterSoundEvent" then
			local B = SBTN:Clone()
			B.Parent = SetRemotes
			B.Icon.Image = (object:IsA("RemoteEvent") and "rbxassetid://413369506" or "rbxassetid://413369623")
			B.RemoteName.Text = object.Name
			B.ID.Text = GetPath(object)
			B.Name = object.Name
			B.Position = UDim2.new(0, 10, 0, -20 + #SetRemotes:GetChildren() * 30)
			B.MouseButton1Down:Connect(function()
				B.Enabled.Text = B.Enabled.Text == "Enabled" and "Disabled" or "Enabled"
				B.Enabled.TextColor3 = B.Enabled.Text == "Enabled" and Color3.fromRGB(60, 200, 60) or Color3.fromRGB(200, 60, 60)
				B.Enabled.BorderColor3 = B.Enabled.Text == "Enabled" and Color3.fromRGB(30, 100, 30) or Color3.fromRGB(100, 30, 30)
			end)
		end
		fill(object)
	end
end
fill(game)

-- Backend // Remotespy Backend

local setreadonly = setreadonly or make_writeable
local game_meta = getrawmetatable(game)
local game_namecall
local namecall_dump = {}
local current_rmt = nil
local g_caller = nil
local f_return = nil
local Step = game:GetService("RunService").Stepped
local newcclosure = function(...) return ... end
setreadonly(game_meta, false)

local namecall_script = function(object, method, ...)
	local scriptVar = string.format("-- Script generated by R2Sv2\n-- R2Sv2 developed by Luckyxero, modified by jLn0n#1464\n-- Remote Path: %s\n", GetPath(object))
	local stringedArgs = Table_TS({...})
	if stringedArgs == "{\n}" then
		scriptVar = scriptVar .. "-- No args found\n\32\n"
		scriptVar = scriptVar .. string.format("local Event = %s\n", GetPath(object))
		scriptVar = scriptVar .. string.format("Event:%s()", method)
	else
		scriptVar = scriptVar .. string.format("-- %s arg(s) found\n\32\n", #{...})
		scriptVar = scriptVar .. string.format("local remote_args = %s\n", stringedArgs)
		scriptVar = scriptVar .. string.format("local Event = %s\n", GetPath(object))
		scriptVar = scriptVar .. string.format("Event:%s(table.unpack(remote_args))", method)
	end
	return scriptVar
end

local dump_script = function(scriptArg)
	Source:setProperty("TextSource", scriptArg)
end

local log_remote = function(tableArg)
	if SetRemotes:FindFirstChild(tableArg.object.Name).Enabled.Text == "Disabled" then return end
	g_caller = tableArg.caller
	remotes_fired = remotes_fired + 1
	Total.Text = remotes_fired

	local B = RBTN:Clone()
	B.Parent = Remotes
	B.Position = UDim2.new(0, 10, 0, -20 + #Remotes:GetChildren() * 30)
	B.Icon.Image = tableArg.method == "FireServer" and "rbxassetid://413369506" or "rbxassetid://413369623"
	B.RemoteName.Text = tableArg.object.Name
	B.ID.Text = tostring(remotes_fired)
	B.MouseButton1Down:Connect(function()
		dump_script(tableArg.cScript)
		g_caller = tableArg.caller
		f_return = tableArg.f_return == nil and tableArg.object.Name .. " is not a RemoteFunction" or tableArg.f_return
	end)
end

local get_namecall_dump = function(scriptArg, object, ...)
	local Ret = "nil"
	if object.ClassName == "RemoteFunction" then
		local freturn = {pcall(object.InvokeServer, object, ...)}
		freturn = {select(2, unpack(freturn))}

		if #freturn ~= 0 then
			Ret = Table_TS(freturn)
		end
	end
	namecall_dump[#namecall_dump + 1] = {
		cScript = namecall_script(object, object.ClassName == "RemoteEvent" and "FireServer" or "InvokeServer", ...),
		caller = scriptArg,
		object = object,
		method = (object.ClassName == "RemoteEvent" and "FireServer" or "InvokeServer"),
		f_return = Ret
	}
end

GetReturn.MouseButton1Down:Connect(function()
	dump_script(f_return)
end)

Decompile.MouseButton1Down:Connect(function()
	local source = decompile(g_caller, true)
	dump_script(type(source) == "boolean" and "-- Failed to decompile caller script!" or source)
end)

Step:Connect(function()
	if #namecall_dump > 0 then
		log_remote(table.remove(namecall_dump, 1))
	end
end)

game_namecall = hookfunction(game_meta.__namecall, newcclosure(function(object, ...)
	local method = getnamecallmethod()
	local args = {...}
	if object.Name ~= "CharacterSoundEvent" and method:match("Server") and spy_enabled == true then
		get_namecall_dump(getcallingscript(), object, unpack(args))
	end

	return game_namecall(object, ...)
end))
