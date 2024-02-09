--[[
	universal-patches.lua
	@jLn0n | 2023

	features:
	* client antikick
	* anti-fingerprint
	* UWP detection bypass (removed since obsolete)
	* mobile spoof [unstable] (WIP)

	should be on the autoexec folder of your desired scripting utility,
	recommended to be used at scripting utilities that has autoexec that runs before ReplicatedFirst.

	TODOS:
	#1: make the randomization of fingerprint data as realistic as possible.
--]]
-- settings
local minOffset, maxOffset = 512, 65535
local toggles = {
	antikick = true,
	fingerprint_spoof = true,
	mobile_spoof = false
}
-- variables
local randomObj = Random.new()
local usePlus = randomObj:NextInteger(1, 10) > 5
local refs = {}
local instanceRefs = {}
local instanceHooks = {method = {}, property = {}}
local methodHookRefs = {}
local timezoneList = {
	"Eastern Daylight Time",
	"Central Daylight Time",
	"Mountain Daylight Time",
	"Pacific Daylight Time"
}

-- functions
local setidentity = setidentity or setthreadidentity or set_thread_identity or setthreadcontext or set_thread_context or (syn and syn.set_thread_identity)
local getidentity = getidentity or getthreadidentity or get_thread_identity or getthreadcontext or get_thread_context or (syn and syn.get_thread_identity)

local getInstanceId do
	local _fetchId = Instance.new("BindableFunction")
	local _getDebugId = game.GetDebugId
	local _invokeBindable = _fetchId.Invoke

	function _fetchId.OnInvoke(...)
		return _getDebugId(...)
	end

	function getInstanceId(instance: Instance): string
		return _invokeBindable(_fetchId, instance)
	end
end

local function offsetNumber(number: number, offset: number): number
	return (if usePlus then number + offset else number - offset)
end

local function cloneReference(instance: Instance): Instance
	return (if typeof(cloneref) == "function" then cloneref(instance) else instance)
end

local _compareInstances = compareinstances
local function compareInstances(instance1: Instance, instance2: Instance)
	return (
		if typeof(_compareInstances) == "function" then
			_compareInstances(instance1, instance2)
		else rawequal(instance1, instance2)
	)
end

local secureCall = syn and syn.secure_call or newcclosure(function(func, scriptObj: LuaSourceContainer?, ...)
	local scriptEnv = (
		if typeof(scriptObj) == "Instance" and scriptObj:IsA("LuaSourceContainer") then
			getsenv(scriptObj)
		else getrenv()
	)

	return coroutine.wrap(function(...)
		local currentIdentity = getidentity()
		setidentity(2)
		setfenv(0, scriptEnv); setfenv(1, scriptEnv)
		local res = {func(...)}
		setidentity(currentIdentity)
		return table.unpack(res)
	end)(...)
end)

--[[
	this implementation tries to bypass the hookfunction detection: https://devforum.roblox.com/t/anticheat-methods/2662072

	this bypass has not been tested yet.
	in theory we will not get detected if we return a cloned `funcToHook` function
	this method returns a cloned `funcToHook` function instead of returning the result of `hookfunction`
	(idk if it should) the clonefunction being used should be able to clone a function properly instead of wrapping the function on a new function
--]]
local safeHookfunction, safeHookmetamethod do
	local _hookfunction = clonefunction(hookfunction)
	local _datamodelArgGuard = {
		["__index"] = function(...)
			local self, index = ...
			local argCount = select("#", ...)

			return (argCount >= 2) and (typeof(self) == "Instance" and typeof(index) == "string")
		end,
		["__namecall"] = function(...)
			local self = ...
			local namecallMethod, argCount = getnamecallmethod(), select("#", ...)

			return (argCount >= 1) and (typeof(self) == "Instance" and typeof(namecallMethod) == "string")
		end,
		["__newindex"] = function(...)
			local self, index = ...
			local argCount = select("#", ...)

			return (argCount >= 3) and (typeof(self) == "Instance" and typeof(index) == "string")
		end,
		["default"] = function(...)
			local self = ...
			local argCount = select("#", ...)

			return (argCount >= 1) and (typeof(self) == "Instance")
		end
	}

	function safeHookfunction<T>(funcToHook: T, hook: (...any) -> (...any)): T
		local func_return = clonefunction(funcToHook)

		_hookfunction(funcToHook, hook)
		return func_return
	end

	type MetamethodFunc = (self: any, ...any) -> (...any)
	function safeHookmetamethod(object: table | Instance, metamethodName: string, hook: MetamethodFunc, argGuard: boolean?): MetamethodFunc
		argGuard = (if typeof(argGuard) == "nil" then true else argGuard)
		local object_mt = assert(getrawmetatable(object), "object has no metatable.")
		local mt_method = assert(object_mt[metamethodName], `invalid metamethod '{tostring(metamethodName)}' on object.`)
		assert(typeof(hook) == "function", `invalid hook, got {typeof(hook)}`)

		hook = (if islclosure(hook) then newcclosure(hook) else hook)
		local old_methodfunc;

		if argGuard and (typeof(object) == "Instance") then -- arg guard on Instance only
			local argument_valid = (_datamodelArgGuard[metamethodName] or _datamodelArgGuard.default)
			local argGuardedHook = newcclosure(function(...)
				return (if argument_valid(...) then hook(...) else old_methodfunc(...))
			end)
			old_methodfunc = safeHookfunction(mt_method, argGuardedHook)
		end
		old_methodfunc = safeHookfunction(mt_method, hook)
		return old_methodfunc
	end
end

-- prevents null character terminator attacks
local function sanitizeString(value: string?): string
	local newStrValue = string.split(value, "\0")[1]
	return newStrValue
end

local function checkInstanceIndex(instance: Instance, index: string): (boolean, number)
	local success, result = pcall(function()
		return instance[index]
	end)

	return success, (
		if typeof(result) == "function" then
			3
		elseif typeof(result) == "RBXScriptSignal" then
			2
		else 1
	)
end

-- TODO: add support for classnames that can be used for multiple instances
local function hookInstanceMethod(instance: Instance, methodNames: {string}, hook)
	local instanceId = getInstanceId(instance)
	local methodHooks = instanceHooks.method[instanceId] or {}
	if not instanceHooks.method[instanceId] then
		instanceHooks.method[instanceId] = methodHooks
	end

	for _, methodName in methodNames do
		local existed, indexType = checkInstanceIndex(instance, methodName)
		if not (existed and indexType == 3) then
			warn(`{instance.ClassName}::{methodName} not a method.`)
			continue
		end

		methodHooks[methodName] = (if islclosure(hook) then newcclosure(hook) else hook)
		-- stores references of the hooked function
		if not methodHookRefs[instance.ClassName] then
			methodHookRefs[instance.ClassName] = {}
		end
		methodHookRefs[instance.ClassName][methodName] = safeHookfunction(instance[methodName], methodHooks[methodName])
	end
end

local function hookInstanceProperty(instance: Instance, propertyName: string, hook)
	local instanceId = getInstanceId(instance)
	local propertyHooks = instanceHooks.property[instanceId] or {}
	if not instanceHooks.property[instanceId] then
		instanceHooks.property[instanceId] = propertyHooks
	end

	local existed, indexType = checkInstanceIndex(instance, propertyName)
	if not (existed and indexType == 1) then
		return warn(`{instance.ClassName}["{propertyName}"] not a property.`)
	end

	propertyHooks[propertyName] = (if islclosure(hook) then newcclosure(hook) else hook)
end

-- init
instanceRefs.Debris, instanceRefs.GuiService, instanceRefs.HttpService, instanceRefs.LocalizationService, instanceRefs.Players, instanceRefs.UserInputService =
	cloneReference(game:GetService("Debris")),
	cloneReference(game:GetService("GuiService")),
	cloneReference(game:GetService("HttpService")),
	cloneReference(game:GetService("LocalizationService")),
	cloneReference(game:GetService("Players")),
	cloneReference(game:GetService("UserInputService"))

-- game-specific patches
if (game.PlaceId == 391104146 or game.PlaceId == 481396142) then -- lets party infinite
	local nullifier = function() return task.wait(9e99) end

	for _, value in getgc(false) do
		if typeof(value) ~= "function" then continue end
		local source = debug.info(value, "s")

		if not string.find(source, "GetIP") then continue end
		-- normal hookfunction is used since we nullified the function, not modified.
		hookfunction(value, newcclosure(nullifier))
	end
end

-- main
if toggles.fingerprint_spoof then
	local offsetData = {
		["clockOffset"] = randomObj:NextInteger(minOffset, maxOffset),
		["tickOffset"] = randomObj:NextInteger(minOffset, maxOffset),
		["timestampOffset"] = randomObj:NextInteger(minOffset, maxOffset),
	}

	local fakeFingerprintData = {
		["RobloxLocaleId"] = string.char(randomObj:NextInteger(97, 122), randomObj:NextInteger(97, 122)) .. "-" .. string.char(randomObj:NextInteger(97, 122), randomObj:NextInteger(97, 122)),
		["SystemLocaleId"] = string.char(randomObj:NextInteger(97, 122), randomObj:NextInteger(97, 122)) .. "-" .. string.char(randomObj:NextInteger(97, 122), randomObj:NextInteger(97, 122)),
		["CountryCode"] = string.char(randomObj:NextInteger(65, 90), randomObj:NextInteger(65, 90)),
		["Timezone"] = timezoneList[randomObj:NextInteger(1, #timezoneList)],
		["IsDaylightSavings"] = randomObj:NextInteger(1, 10) > 5,
	}

	refs.os_clock = safeHookfunction(os.clock, newcclosure(function()
		local callingScript = getcallingscript()
		local currentClock = secureCall(refs.os_clock, callingScript)

		return (not checkcaller() and offsetNumber(currentClock, offsetData.clockOffset) or currentClock)
	end))

	refs.tick = safeHookfunction(tick, newcclosure(function()
		local callingScript = getcallingscript()
		local currentTick = secureCall(refs.tick, callingScript)

		return (not checkcaller() and offsetNumber(currentTick, offsetData.tickOffset) or currentTick)
	end))

	refs.os_date = safeHookfunction(os.date, newcclosure(function(...)
		local callingScript = getcallingscript()
		local result = {secureCall(refs.os_date, callingScript, ...)}
		local format = ...

		if not checkcaller() then
			local dateTypeResult = result[1]

			if format == "%Z" then
				return fakeFingerprintData.Timezone
			elseif typeof(dateTypeResult) == "table" and typeof(rawget(dateTypeResult, "isdst")) == "boolean" then
				rawset(dateTypeResult, "isdst", fakeFingerprintData.IsDaylightSavings)
				return dateTypeResult
			elseif typeof(dateTypeResult) == "number" then
				return offsetNumber(dateTypeResult, offsetData.timestampOffset)
			end
		end
		return unpack(result)
	end))

	refs.datetime_now = safeHookfunction(DateTime.now, newcclosure(function(...)
		local callingScript = getcallingscript()
		local origDateTimeObj = secureCall(refs.datetime_now, callingScript, ...)
		local offsettedDateTimeObj = DateTime.fromUnixTimestampMillis(offsetNumber(origDateTimeObj.UnixTimestampMillis, offsetData.timestampOffset))

		return (not checkcaller() and offsettedDateTimeObj or origDateTimeObj)
	end))

	hookInstanceProperty(instanceRefs.LocalizationService, "RobloxLocaleId", function()
		return fakeFingerprintData.RobloxLocaleId
	end)
	hookInstanceProperty(instanceRefs.LocalizationService, "SystemLocaleId", function()
		return fakeFingerprintData.SystemLocaleId
	end)

	hookInstanceMethod(instanceRefs.LocalizationService, {"GetCountryRegionForPlayerAsync"}, function(self, player)
		local playerInstRef = cloneReference(player)

		if compareInstances(playerInstRef, instanceRefs.LocalPlayer) then
			return fakeFingerprintData.CountryCode
		end
		return methodHookRefs.LocalizationService.GetCountryRegionForPlayerAsync(self, player)
	end)
end

if toggles.antikick then
	hookInstanceMethod(instanceRefs.Debris, {"AddItem"}, function(self, instance, count)
		local instanceRef = cloneReference(instance)

		if compareInstances(instanceRef, instanceRefs.LocalPlayer) then
			return nil
		end
		return methodHookRefs.Debris.AddItem(self, instance, count)
	end)

	task.spawn(function()
		repeat task.wait() until instanceRefs.Players.LocalPlayer
		instanceRefs.LocalPlayer = cloneReference(instanceRefs.Players.LocalPlayer)

		hookInstanceMethod(instanceRefs.LocalPlayer, {"Kick", "kick"}, function(self, ...)
			if type(...) == "userdata" and (typeof(...) ~= "Instance" or typeof(...) ~= "RaycastParams") then
				return methodHookRefs.Player.Kick(self, ...)
			end
			return nil
		end)
		hookInstanceMethod(instanceRefs.LocalPlayer, {"Destroy", "destroy"}, function() return nil end)
	end)
end

if toggles.mobile_spoof then
	-- TODO: compare instance instead of descendant check
	local function checkIfControlModule(scriptCaller: LuaSourceContainer)
		return (
			typeof(scriptCaller) == "Instance" and
			scriptCaller:IsA("ModuleScript") and
			tostring(scriptCaller) == "ControlModule" and
			tostring(scriptCaller.Parent) == "PlayerModule" and
			(scriptCaller:FindFirstAncestorWhichIsA("PlayerScripts"))
		)
	end

	-- very obscure hooks >:(
	hookInstanceProperty(instanceRefs.UserInputService, "TouchEnabled", function()
		return (
			if checkIfControlModule(getcallingscript()) then
				false
			else true
		)
	end)
	hookInstanceProperty(instanceRefs.UserInputService, "MouseEnabled", function()
		return (
			if checkIfControlModule(getcallingscript()) then
				true
			else false
		)
	end)
	hookInstanceProperty(instanceRefs.UserInputService, "KeyboardEnabled", function()
		return (
			if checkIfControlModule(getcallingscript()) then
				true
			else false
		)
	end)
end

-- datamodel hooks init
refs.__index = safeHookmetamethod(game, "__index", newcclosure(function(...)
	local self, index = ...
	local selfRef = cloneReference(self)
	index = sanitizeString(index)
	local selfHooks = instanceHooks.property[getInstanceId(selfRef)]
	local hook = (if selfHooks then selfHooks[index] else nil)

	return (if hook then hook(self) else refs.__index(...))
end))

refs.__namecall = safeHookmetamethod(game, "__namecall", newcclosure(function(...)
	local selfRef = cloneReference(...)
	local namecallMethod = getnamecallmethod()
	local selfHooks = instanceHooks.method[getInstanceId(selfRef)]
	local hook = (if selfHooks then selfHooks[namecallMethod] else nil)

	return (if hook then hook(...) else refs.__namecall(...))
end))
