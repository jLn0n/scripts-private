-- variables
local randomObj = Random.new()
local usePlus = randomObj:NextInteger(1, 2) == 2
local clockOffset, tickOffset = randomObj:NextInteger(256, 32768), randomObj:NextInteger(256, 32768)
local fakeLocaleId = string.char(randomObj:NextInteger(97, 122), randomObj:NextInteger(97, 122)) .. "-" .. string.char(randomObj:NextInteger(97, 122), randomObj:NextInteger(97, 122))
local refs = table.create(0)
local RandomInfo = {
	Timezones = {
		[1] = 'Eastern Daylight Time';
		[2] = 'Central Daylight Time';
		[3] = 'Mountain Daylight Time';
		[4] = 'Pacific Daylight Time';
	};
 }
-- functions
local function offsetNumber(number, offset)
	return (usePlus and number + offset or number - offset)
end
-- main
refs.os_clock = hookfunction(os.clock, newcclosure(function()
	local currentClock = refs.os_clock()
	return (not checkcaller() and offsetNumber(currentClock, clockOffset) or currentClock)
end))

refs.tick = hookfunction(tick, newcclosure(function()
	local currentTick = refs.tick()
	return (not checkcaller() and offsetNumber(currentTick, tickOffset) or currentTick)
end))

refs.os_date = hookfunction(os.date, newcclosure(function(...)
	local format = ...

	if format == "%Z" then
		return RandomInfo.Timezones[randomObj:NextInteger(1, #RandomInfo.Timezones)]
	end

	if format == "*t" then
		local dateTypeResult = refs.os_date(...)
		dateTypeResult.isdst = randomObj:NextInteger(1, 2) == 2
		return dateTypeResult
	end
	return refs.os_date(...)
end))

refs.__index = hookmetamethod(game, "__index", newcclosure(function(self, ...)
	local args = {...}

	if not checkcaller() and self:IsA("LocalizationService") and args[1] == "SystemLocaleId" then
		return fakeLocaleId
	end
	return refs.__index(self, ...)
end))
