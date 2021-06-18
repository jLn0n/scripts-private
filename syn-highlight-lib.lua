-- // SERVICES
local TextService = game:GetService("TextService")
-- // OBJECTS
local synHLUI_Template = game:GetObjects("rbxassetid://6969756999")[1]
-- // MODULES
local Lexer = loadstring(game:HttpGet("https://raw.githubusercontent.com/jLn0n/created-scripts-public/main/boatbomber-lexer.lua", true))()
-- // VARIABLES
local sformat, smatch, sgsub = string.format, string.match, string.gsub
local Lexer_scan = Lexer.scan
-- // MAIN
local updateTextSource = function(object, textSource)
	for tok, str in Lexer_scan(textSource) do
		for _, lexObj in ipairs(object:GetChildren()) do
			if lexObj.Name == tok then
				lexObj.Text = lexObj.Text .. str
			else
				lexObj.Text = lexObj.Text .. sgsub(str, "[^\n\r]", " ")
			end
		end
	end
end

local getTextSize = function()
end

local M = {} -- why use metatables lol

function M.new(guiParent, properties)
	assert(guiParent == nil and typeof(guiParent) == "Instance", "the argument #1 should be a instance")
	assert(type(properties) == "table", "the argument #2 should be a table")
	local synHL_UI = synHLUI_Template:Clone()
	local TextLines = synHL_UI.TextLines
	local TextSource = synHL_UI.TextSource
	local sub_M = {
		_connections = {},
	}

	synHL_UI.Parent, synHL_UI.Position, synHL_UI.Size = guiParent, properties.Position or UDim2.new(), properties.Size or UDim2.new(0, 600, 0, 650)
	updateTextSource(properties.Text or "")

	function sub_M:updateSource(textSource)
		updateTextSource(textSource)
	end

	function sub_M:Destroy()
		for _, connection in ipairs(sub_M._connections) do
			connection:Disconnect()
		end
		synHL_UI:Destroy()
	end

	return sub_M
end

return M
