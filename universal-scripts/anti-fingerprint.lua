--[[
	should be on the autoexec folder of your desired scripting utility,
	recommended to use autolaunch.
--]]
-- settings
local minOffset, maxOffset =
	1024,
	65536
-- services
local _localizationService = game:GetService("LocalizationService")
-- variables
local randomObj = Random.new()
local usePlus = randomObj:NextInteger(1, 10) > 5
local clockOffset, tickOffset, timestampOffset =
	randomObj:NextInteger(minOffset, maxOffset),
	randomObj:NextInteger(minOffset, maxOffset),
	randomObj:NextInteger(minOffset, maxOffset)
local fakeLocaleId = string.char(randomObj:NextInteger(97, 122), randomObj:NextInteger(97, 122)) .. "-" .. string.char(randomObj:NextInteger(97, 122), randomObj:NextInteger(97, 122))
local fakeCountryCode = string.char(randomObj:NextInteger(65, 90), randomObj:NextInteger(65, 90))
local refs = table.create(0)
local clockTimezones = {
	"Eastern Daylight Time",
	"Central Daylight Time",
	"Mountain Daylight Time",
	"Pacific Daylight Time"
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

	if not checkcaller() then
		if format == "%Z" then
			return clockTimezones[randomObj:NextInteger(1, #clockTimezones)]
		end
		if format == "*t" then
			local dateTypeResult = refs.os_date(...)
			dateTypeResult.isdst = randomObj:NextInteger(1, 10) > 5
			return dateTypeResult
		end
	end
	return refs.os_date(...)
end))

refs.datetime_now = hookfunction(DateTime.now, newcclosure(function(...)
	local origDateTimeObj = refs.datetime_now(...)
	local offsettedDateTimeObj = DateTime.fromUnixTimestampMillis(offsetNumber(origDateTimeObj.UnixTimestampMillis, timestampOffset))

	return (not checkcaller() and offsettedDateTimeObj or origDateTimeObj)
end))

refs.__index = hookmetamethod(game, "__index", newcclosure(function(self, ...)
	local args = {...}

	if not checkcaller() and self == _localizationService and (args[1] == "RobloxLocaleId" or args[1] == "SystemLocaleId") then
		return fakeLocaleId
	end
	return refs.__index(self, ...)
end))

refs.__namecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
	local namecallMethod = getnamecallmethod()

	if not checkcaller() and self == _localizationService and namecallMethod == "GetCountryRegionForPlayerAsync" then
		return fakeCountryCode
	end
	return refs.__namecall(self, ...)
end))
