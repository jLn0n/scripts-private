--[[
	simbuscator.lua
	just a simple obfuscator without any protections in lua for lua
--]]
-- variables
local obfTemplates = {
	["simbuscatorWatermark"] = "--[[\n\t%s\n\tobfuscated with simbuscator.lua\n--]]\n",
	["varsList"] = [==[local {fenv},{string_gsub},{string_char},{tostring},{tonumber},{loadstring},{math_min},%s;]==],
	["varsStaters"] = [==[{fenv}=function({fenv_temp_arg1})return getfenv()["{loadstr_str}"]({fenv_temp_arg1})end;{fenv}={fenv}("{fenv_return}")();{string_gsub},{string_char},{tostring},{tonumber},{loadstring},{math_min},%s={fenv}("{gsub_str}"),{fenv}("{char_str}"),{fenv}("{tostr_str}"),{fenv}("{tonum_str}"),{fenv}("{loadstr_str}"),{fenv}("{mmin_str}"),%s;]==],
	["minifiedHexToStr"] = [==[local function {hextostr_func}({hextostr_func_arg1}) return {string_gsub}({hextostr_func_arg1}, "{enc_str1}", function({func_inner1_arg1}) return {string_char}(({tonumber}({func_inner1_arg1}, {enc_number1}) or 0) / {dec_offsetint}) end) end;]==],
	["loadstringProxy"] = [==[local function {loadstr_proxy_func}({loadstr_proxy_func_arg1}) return {loadstring}({string_gsub}({hextostr_func}({loadstr_proxy_func_arg1}), "{str_seperator}", ""), "{source_name}")() end;]==],
	["loadstringScript"] = [==[{loadstr_proxy_func}("{source}");]==],
	junkCodes = {
		[==[local function {var_name}() return ({integer} == {integer_enc1}) end;]==],
		[==[local function {var_name}({var_name_arg1}, {var_name_arg2}) return ({integer} * ({var_name_arg1} / {var_name_arg2})) end;]==],
	}
}
local variableTypeChoices = {
	"number",
	"bool",
	"string",
}
local strFenvGet = [==[return function(a)local b,c=string.split(a, "."),getfenv()for d = 1, #b do c = c[b[d]] end return c end]==]
local stringList = "qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM1234567890"
-- functions
local function stringToHex(stringArg, seperator, offset)
	seperator = seperator or "\\x"
	offset = offset or 1
	return string.gsub(stringArg, ".", function(value)
		return seperator .. string.format("%02X", string.byte(value) * offset)
	end)
end
local function scrambleNumber(number)
	return string.format("{math_min}(((%s / 2) * (8 / 5)) * (%s * (69 / 34.5)), 0x%02X)", number, number, number)
end
local function formatString(templateStr, options, func)
	local stringResult = templateStr
	for name in pairs(options) do
		stringResult = string.gsub(stringResult, string.format("{%s?}", name), (typeof(func) == "function" and func(name) or options[name]))
	end
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
local function generateRandString(lenght)
	local result = ""
	for iter = 1, lenght do
		local randInteger = math.random(1, (iter == 1 and #stringList - 10 or #stringList))
		result ..= string.sub(stringList, randInteger, randInteger)
	end
	return result
end
local function generateRandVariableValue()
	local stringResult = ""
	local pickedVariableType = variableTypeChoices[math.random(1, #variableTypeChoices)]
	if pickedVariableType == "string" then
		stringResult ..= "\"" .. stringToHex(generateRandString(math.random(1, 128))) .. "\""
	elseif pickedVariableType == "bool" then
		stringResult ..= (math.random(1, 8) <= 4 and "true" or "false")
	elseif pickedVariableType == "number" then
		local randPickedInt = math.random(1, 3)
		local randInt = math.random(1, 256)
		stringResult ..= (
			if randPickedInt == 1 then randInt
			elseif randPickedInt == 2 then "0x" .. stringToHex(randInt, "")
			else "\"" .. stringToHex(randInt) .. "\""
		)
	end
	return stringResult
end
local function generateJunkCode(addedOptions)
	local stringResult = obfTemplates.junkCodes[math.random(1, #obfTemplates.junkCodes)]
	local generatedOptions = mergeDictionary(addedOptions, {
		var_name = generateRandString(12),
		var_name_arg1 = generateRandString(8),
		var_name_arg2 = generateRandString(8),
		integer = math.random(1, 256),
		integer_enc1 = scrambleNumber(math.random(1, 1024)),
	})
	stringResult = formatString(stringResult, generatedOptions)
	return stringResult
end
local function obfuscateScript(outputArg, sourceName)
	math.randomseed(os.clock() + math.random(1, 16))
	outputArg = string.gsub(outputArg, "\t", "")
	local resultData = table.create(0)
	local offsetInt, junkCodeGenCount, strSeperator = math.random(8, 64) * 8, math.random(8, 32), "­"
	local varsList, varsStaters = obfTemplates.varsList, obfTemplates.varsStaters
	local generatedOptions = {
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
		hextostr_func = generateRandString(12),
		fenv_temp_arg1 = generateRandString(8),
		hextostr_func_arg1 = generateRandString(8),
		func_inner1_arg1 = generateRandString(8),
		enc_str1 = stringToHex("[%x]+"),
		enc_number1 = scrambleNumber(16),
		dec_offsetint = tostring(offsetInt),
		loadstr_proxy_func = generateRandString(12),
		loadstr_proxy_func_arg1 = generateRandString(8),
		source_name = stringToHex(sourceName),
		str_seperator = strSeperator,
		source = stringToHex(outputArg, strSeperator, offsetInt),
	}
	for _ = 1, junkCodeGenCount do
		table.insert(resultData, math.random(1, 7), generateJunkCode(generatedOptions))
	end
	for junkVarCount = 1, junkCodeGenCount do
		local randVarName, randVarValue = generateRandString(12), generateRandVariableValue()
		local formatterStr = (if junkCodeGenCount == junkVarCount then "" else ",%s")
		varsList = string.format(varsList, randVarName .. formatterStr)
		varsStaters = string.format(varsStaters, randVarName .. formatterStr, randVarValue .. formatterStr)
	end
	table.insert(resultData, 1, string.format(obfTemplates.simbuscatorWatermark, sourceName))
	table.insert(resultData, 3, formatString(varsList, generatedOptions))
	table.insert(resultData, 4, formatString(varsStaters, generatedOptions))
	table.insert(resultData, 5, formatString(obfTemplates.minifiedHexToStr, generatedOptions))
	table.insert(resultData, 6, formatString(obfTemplates.loadstringProxy, generatedOptions))
	table.insert(resultData, 7, formatString(obfTemplates.loadstringScript, generatedOptions))
	for index = 1, #resultData do
		if resultData[index] then continue end
		table.remove(resultData, index)
	end
	return table.concat(resultData)
end
-- main
local source = [==[
	print("Hello World!")
]==]
print(obfuscateScript(source, "print.lua"))
