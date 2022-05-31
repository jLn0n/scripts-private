-- services
local repStorage = game:GetService("ReplicatedStorage")
-- objects
local msgReqEvent = repStorage.DefaultChatSystemChatEvents:FindFirstChild("SayMessageRequest")
local screenSpinEvent = repStorage.Remotes:FindFirstChild("ScreenSpin")
local spinModel = workspace.Spinner:FindFirstChild("Spin"):FindFirstChild("Model2")
-- variables
local msgTemplates = {
	"I think its gonna be %s",
	"The next one is %s",
	"Next is %s",
	"Its gonna be %s",
	"Next one is %s",
	"Next will be %s",
	"%s will be picked next",
	"RNG gods knows its gotta be %s",
}
-- functions
local function getSpinName(spinValue)
	for _, object in ipairs(spinModel:GetChildren()) do
		if spinValue == tonumber(object.Name) then
			return object.SurfaceGui.TextLabel.Text
		end
	end
end
-- main
screenSpinEvent.Event:Connect(function(spinType, spinValue, timeoutNumber)
	local spinName = getSpinName(spinValue)
	if spinName then
		local msgResult = string.format(msgTemplates[math.random(1, #msgTemplates)], spinName)
		msgResult ..= (if math.random(1, 3) == 1 then ", trust me" else "")
		msgResult = (if math.random(1, 8) <= 4 then string.lower(msgResult) else msgResult)
		task.delay(((((math.random() + 1) / 2) * timeoutNumber) / 10), msgReqEvent.FireServer, msgReqEvent, msgResult, "All")
	end
end)