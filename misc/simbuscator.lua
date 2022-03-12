--[[
	simbuscator.lua
	just a simple obfuscator without any protections in lua
--]]
-- variablesc
local hexBytes = table.create(0)
local obfTemplates = {
	["varsList"] = [==[local {fenv}=loadstring("{fenv_return}")();local {string_gsub}={fenv}("{gsub_str}");local {string_char}={fenv}("{char_str}");local {tostring}={fenv}("{tostr_str}");local {tonumber}={fenv}("{tonum_str}");local {loadstring}={fenv}("{loadstr_str}");local {math_min}={fenv}("{mmin_str}");]==],
	["minifiedHexToStr"] = [==[local function {hextostr_func}({hextostr_func_arg1}) return {string_gsub}({hextostr_func_arg1}, "{enc_str1}", function({func_inner1_arg1}) return {string_char}(({tonumber}({func_inner1_arg1}, {enc_number1}) or 0) / {dec_offsetint}) end) end;]==],
	["loadstringProxy"] = [==[local function {loadstr_proxy_func}({loadstr_proxy_func_arg1}) return {loadstring}({string_gsub}({hextostr_func}({loadstr_proxy_func_arg1}), "|", ""), "{source_name}")() end;]==],
	["loadstringScript"] = [==[{loadstr_proxy_func}("{source}");]==],
	junkCodes = {
		[==[local function {var_name}() return ({integer} == {integer}) end;]==],
		[==[local function {var_name}({var_name_arg1}, {var_name_arg2}) return ({integer} * ({var_name_arg1} / {var_name_arg2})) end;]==],
		[==[local {var_name}={var_result};]==],
	}
}
local strFenvGet = [==[return function(strArg)local seps,result=string.split(strArg, "."),getfenv() for index = 1, #seps do result = result[seps[index]] end return result end]==]
local stringList = "qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM1234567890"
-- functions
local function generateRandString(lenght)
	local result = ""
	for iter = 1, lenght do
		local randInteger = math.random(1, (iter == 1 and #stringList - 10 or #stringList))
		result ..= string.sub(stringList, randInteger, randInteger)
	end
	return result
end
local function stringToHex(stringArg, seperator, offset)
	seperator = seperator or "\\x"
	offset = offset or 1
	return string.gsub(stringArg, ".", function(value)
		return seperator .. string.format("%02X", string.byte(value) * offset)
	end)
end
local function scrambleNumber(number)
	return string.format("{math_min}(((%s / 2) * 8 / 5) * (%s / 2), 0x%02X)", number, number, number)
end
local function formatTemplate(templateName, outputs)
	if (not templateName or not obfTemplates[templateName]) or not outputs then return end
	local stringResult = obfTemplates[templateName]
	for name, value in pairs(outputs) do
		stringResult = string.gsub(stringResult, string.format("{%s}?", name), value)
	end
	return stringResult
end
local function generateJunkCode() -- TODO: generate junkcodes according to the plan
	local stringResult = obfTemplates.junkCodes[math.random(1, #obfTemplates.junkCodes)]
	string.gsub(stringResult, "{%s}?", function(value)
		if string.find(value, "integer") then
			return scrambleNumber(math.random(1, 50))
		end
	end)
	return stringResult
end
local function mergeDictionary(table1, table2)
	for key, value in pairs(table2) do
		if typeof(value) == "table" and typeof(table1[key] or false) == "table" then
			mergeDictionary(table1[key], value)
		else
			table1[key] = value
		end
	end
	return table1
end
local function obfuscateScript(outputArg, sourceName)
	outputArg = string.gsub(outputArg, "\t", "")
	local resultData = table.create(0)
	local obfResult = ""
	local offsetInt = math.random(8, 32) * 8
	local varsListOutput, minHexToStrOutput, lstrPrxyOutput, lstrMainOutput = {
		string_char = generateRandString(12),
		string_gsub = generateRandString(12),
		fenv = generateRandString(12),
		math_min = generateRandString(12),
		loadstring = generateRandString(12),
		tostring = generateRandString(12),
		tonumber = generateRandString(12),
		char_str = stringToHex("string.char"),
		gsub_str = stringToHex("string.gsub"),
		fenv_return = stringToHex(strFenvGet),
		mmin_str = stringToHex("math.min"),
		loadstr_str = stringToHex("loadstring"),
		tonum_str = stringToHex("tonumber"),
		tostr_str = stringToHex("tostring"),
	}, {
		hextostr_func = generateRandString(12),
		hextostr_func_arg1 = generateRandString(8),
		func_inner1_arg1 = generateRandString(8),
		enc_str1 = stringToHex("[%x]+"),
		enc_number1 = scrambleNumber(16),
		dec_offsetint = tostring(offsetInt)
	}, {
		loadstr_proxy_func = generateRandString(12),
		loadstr_proxy_func_arg1 = generateRandString(8),
		source_name = stringToHex(sourceName)
	}, {
		source = stringToHex(outputArg, "|", offsetInt)
	}
	for _ = 1, math.random(4, 16) do
		table.insert(resultData, math.random(1, 3), generateJunkCode())
	end
	table.insert(resultData, formatTemplate("varsList", varsListOutput))
	table.insert(resultData, formatTemplate("minifiedHexToStr", mergeDictionary(varsListOutput, minHexToStrOutput)))
	table.insert(resultData, formatTemplate("loadstringProxy", mergeDictionary(varsListOutput, mergeDictionary(minHexToStrOutput, lstrPrxyOutput))))
	table.insert(resultData, #resultData + 1, formatTemplate("loadstringScript", mergeDictionary(lstrPrxyOutput, lstrMainOutput)))
	for index = 1, #resultData do
		obfResult ..= resultData[index]
	end
	return obfResult
end
-- main
local source = [==[
	print("Hello World!")
]==]
print(obfuscateScript(source, "weaponry-gui.lua"))
