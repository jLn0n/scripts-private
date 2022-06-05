--[[
	Based of https://github.com/TacticalBFG/luau-decompiler
	just rewriting this to work in lua 5.1 because TacticalBFG write the shit in lua 5.3 or 5.4
	TODO:
		#1: Extend this thing and use the latest from https://github.com/Roblox/luau/blob/master/Common/include/Luau/Bytecode.h
		#2: convert the goto thingy to function (used continue lol)
--]]
-- variables
local luauOps = { -- TODO #1
	VARARGPREP = 0xA3,
	CLEARSTACK = 0xC0,
	GETENV = 0x35,
	SETENV = 0x18,
	ENUM = 0xA4,

	MOVE = 0x52,
	LOADK = 0x6F,
	LOADKX = 0x86,
	LOADNUM = 0x8C,
	LOADBOOL = 0xA9,
	LOADNIL = 0xC6,

	GETTABLEK = 0x4D,
	GETTABLER = 0x87,
	GETUPVAL = 0xFB,
	GETTABLEI = 0x13,

	SETTABLEK = 0x30,
	SETTABLER = 0x6A,
	SETUPVAL = 0xDE,
	SETTABLEI = 0xF6,

	ADDK = 0x95,
	SUBK = 0x78,
	MULK = 0x5B,
	DIVK = 0x3E,
	MODK = 0x21,
	POWK = 0x4,

	ADDR = 0x43,
	SUBR = 0x26,
	MULR = 0x9,
	DIVR = 0xEC,
	MODR = 0xCF,
	POWR = 0xB2,

	NEWTABLE = 0xFF,
	LOADTABLEK = 0xE2,
	SETLIST = 0xC5,

	NAMECALL = 0xBC,

	CONCAT = 0x73,
	LEN = 0x1C,
	NOT = 0x56,
	UNM = 0x39,

	UJMP = 0x65,
	SJMP = 0x48,
	LJMP = 0x69,

	TESTN = 0xE,
	TEST = 0x2B,
	EQN = 0x9A,
	EQ = 0xF1,
	LTN = 0x60,
	LT = 0xB7,
	LEQN = 0x7D,
	LEQ = 0xD4,

	TFORLOOP = 0xFA,
	TFORPREP = 0x17,
	FORPREP = 0xA8,
	FORLOOP = 0x8B,

	CALL = 0x9F,
	RETURN = 0x82,
	CLOSURE = 0xD9,
	CLOSE = 0xC1,
	CROSSENVUP = 0x12,
	VARARG = 0xDD
}
local stringBuilders = {
	conditions = {
		notCondition = "not %s",
		equalTo = "%s == %s",
		notEqualTo = "%s ~= %s",
		greaterThan = "%s > %s",
		equalToGreaterThan = "%s >= %s",
		lessThan = "%s < %s",
		equalToLessThan = "%s <= %s",
		ifConditionThen = "if (%s) then",
		whileConditionDo = "while (%s) do"
	},
	codeCompletions = {
		ADDKR = "%s + %s",
		SUBKR = "%s - %s",
		MULKR = "%s * %s",
		DIVKR = "%s / %s",
		MODKR = "%s % %s",
		POWKR = "%s ^ %s",
		LOCAL_EXPR = "\nlocal %s = %s\n",
		VALUE_SETTO = "%s = %s",
		INDEXTO_TABLEK = "%s.%s",
		INDEXTO_TABLERI = "%s[%s]",
		SETTO_TABLEK = "%s.%s = %s",
		SETTO_TABLERI = "%s[%s] = %s",
		CONCAT_TO = "%s .. %s",
		LEN_SET = "#%s",
		NOT_VALUE = "not %s",
		UNM_SET = "-%s",
		FORLOOP_CONSTUCTOR = "for %s = %s do",
		TFORLOOP_CONSTRUCTOR = "for %s, %s in %s do",
		NAMECALL_CONSTRUCT = "%s:%s",
		CALL_CONSTRUCTOR = "%s(%s)",
		RETURN_CONSTRUCTOR = "\n%sreturn %s",
		CLOSURE_CONSTRUCTOR = "function(%s)\n%s\nend"
	}
}
-- functions
local luau = {
	getOpcode = function(inst)
		return bit32.band(inst, 0xFF)
	end,
	getA = function(inst)
		return bit32.band(bit32.rshift(inst, 8), 0xFF)
	end,
	getB = function(inst)
		return bit32.band(bit32.rshift(inst, 16), 0xFF)
	end,
	getC = function(inst)
		return bit32.band(bit32.rshift(inst, 24), 0xFF)
	end,
	getBx = function(inst)
		return bit32.band(bit32.rshift(inst, 16), 0xFFFF)
	end,
	emitABC = function(opcode, a, b, c)
		return bit32.bor(bit32.bor(bit32.bor(opcode, (bit32.lshift(a, 8))), (bit32.lshift(b, 16))), (bit32.lshift(c, 24)))
	end
}

local function formatConstant(constant)
	if typeof(constant) == "string" then
		constant = string.format("\"%s\"", constant)
	end
	return constant
end

local function resolveRealDist(code, where)
	local inst = code[where]
	local op = bit32.band(inst, 0xFF)
	local realEnding = -1
	local inc = false

	if (op == luauOps.TEST or op == luauOps.TESTN or op == luauOps.EQ or op == luauOps.EQN or op == luauOps.LT -- Because AsBx B
	or op == luauOps.LTN or op == luauOps.LEQ or op == luauOps.LEQN) then -- because AsBx
		realEnding = bit32.band(bit32.rshift(inst, 16), 0xFFFF)
		local testTo = bit32.band(bit32.rshift(inst, 16), 0xFFFF)
		local elsePositions = {}
		local resolvedTo = code[where + realEnding]
		local resolvedOp = bit32.band(resolvedTo, 0xFF)

		while (resolvedOp == luauOps.UJMP or resolvedOp == luauOps.SJMP or resolvedOp == luauOps.LJMP) do
			local thisDist = -1
			if (resolvedOp == luauOps.SJMP) then
				thisDist = bit32.band(bit32.rshift(resolvedTo, 16), 0xFFFF)
				if (thisDist > 0x7FFF) then -- negative jump?
					return {-2, realEnding} -- while resolver can FOD and do everything
				end
			elseif (resolvedOp == luauOps.UJMP) then
				thisDist = bit32.band(bit32.rshift(resolvedTo, 16), 0xFFFF)
				if ((realEnding - testTo) > 2) then -- uh?
					table.insert(elsePositions, realEnding+where)
				end
				-- need to add in else statements
			else
				warn("TODO: LONG JUMP RESOLVER")
			end
			if (thisDist < 1) then
				warn("SHORT ELSE LOOP")
				break;
			end
			realEnding = realEnding + thisDist
			resolvedTo = code[where + realEnding]
			resolvedOp = bit32.band(resolvedTo, 0xFF)
		end
		--virbnmzxyp("really ends at",realEnding," on opcode ",resolvedOp)
		return {realEnding, elsePositions}
	else
		return {-3} -- not a conditional
	end
end

local function resolveWhileLoop(code, start, destination)
	local destInst = code[destination]
	local destOp = bit32.band(destInst, 0xFF)
	if (destOp ~= luauOps.SJMP) then return end
	local trueEnd = 1
	local jmpDist = bit32.band(bit32.rshift(destInst, 16), 0xFFFF)
	if (jmpDist <= 0x7FFF) then return end
	jmpDist = jmpDist - 0xFFFF

	local checkPos = destination + jmpDist
	warn("while jumpdist", jmpDist, checkPos, start)
	local reboundInst = code[checkPos]

	while (checkPos <= #code) do -- scan remaining instructions for the while
		local checkDist = resolveRealDist(code, checkPos)
		if (checkDist[1] > 0) then
			warn("REALISTIC JMP", checkDist[1])
		end
		checkPos += 1
	end
	return trueEnd
end

local function buildCondition(instructions, i, inst, scope, elem, condType, b)
	local dist = bit32.band(bit32.rshift(inst, 16), 0xFFFF)
	local destInst = instructions[i + dist]
	local destOp = bit32.band(destInst, 0xFF)
	local scr = ""
	local skips = 0
	local testScope = {
		depth = scope.depth + 1,
		closeAt = -1,
		parent = scope,
		elses = {},
		isWhile = false,
		isBreakable = false,

		localVars = {},
		upvalInfo = {}
	}

	local condSubtract = (if condType >= 2 then -1 else 0)
	local conditionResult = (
		if condType == 1 then elem
		elseif condType == 0 then string.format(stringBuilders.conditions.notCondition, elem)
		elseif condType == 2 then string.format(stringBuilders.conditions.notEqualTo, elem, b)
		elseif condType == 3 then string.format(stringBuilders.conditions.equalTo, elem, b)
		elseif condType == 4 then string.format(stringBuilders.conditions.lessThan, elem, b)
		elseif condType == 5 then string.format(stringBuilders.conditions.greaterThan, elem, b)
		elseif condType == 6 then string.format(stringBuilders.conditions.equalToLessThan, elem, b)
		elseif condType == 7 then string.format(stringBuilders.conditions.equalToGreaterThan, elem, b)
		else ""
	)

	local realDist = resolveRealDist(instructions, i + condSubtract)
	if (realDist[1] == -2) then -- while loop
		scr = scr .. string.format(stringBuilders.conditions.whileConditionDo, conditionResult)
		testScope.isWhile = true
		testScope.isBreakable = true
		dist = realDist[2]
	else
		if (destOp == luauOps.UJMP) then -- thing 5.4 compiler does
			skips += 1
		end
		dist = realDist[1]
		testScope.elses = realDist[2]
	end

	if (not testScope.isWhile) then
		scr = scr .. string.format(stringBuilders.conditions.ifConditionThen, conditionResult)
	end
	testScope.closeAt = i + dist + condSubtract
	return {testScope, skips, scr}
end

local function tracebackFrom(log, i, A, scope)
	local evalScope = scope
	local nLocals = 1

	while (evalScope ~= nil) do
		for _, loc in pairs(evalScope.localVars) do
			nLocals += 1
			if loc[1] == A then
				return nil -- local already exists
			end
		end

		evalScope = evalScope.parent
	end

	for k = i, 1, -1 do
		local trace = log[k]
		if (trace[4] == A) then
			local op= trace[1]
			if (op ~= luauOps.SETTABLEK and op ~= luauOps.SETTABLER and op ~= luauOps.SETTABLEI and op ~= luauOps.SETENV and op ~= luauOps.SETUPVAL and op ~= luauOps.CALL  ) then
				return {trace[4], "v" .. tostring(nLocals)}
			end
		end
	end
end

local function reverseVM(func, scope, vars)
	local decompileResult = ""
	local funcConstants, funcProtos = debug.getconstants(func), debug.getprotos(func)
	local constAdjusted, protosAdjusted = table.create(0), table.create(0)

	for index = 1, #funcConstants do
		constAdjusted[index - 1] = constAdjusted[index]
	end
	for index = 1, #funcProtos do
		protosAdjusted[index - 1] = protosAdjusted[index]
	end

	local stack, globalCache = table.create(0), table.create(0)

	local codeInst, codeLines = debug.getinstructions(func), debug.getlines(func)
	local lastLine = codeLines[1]

	local tracebackLog = table.create(0)

	if vars then
		for _, varArg in pairs(vars) do
			stack[varArg[1]] = varArg[2]
			table.insert(scope.localVars, varArg)
		end
	end

	local protoScope = scope

	local instIndex = 1
	while (instIndex <= #codeInst) do
		local instruction = codeInst[instIndex]
		local opcode = luau.getOpcode(instruction)
		local argA = luau.getA(instruction)

		decompileResult ..= string.rep(" ", scope.depth * 4)
		local backupDResultToCheck = decompileResult

		if (opcode == luauOps.ENUM) then
			local globalFunc = constAdjusted[luau.getBx(instruction)]
			local tableInfo = codeInst[instIndex + 1]
			instIndex += 1

			local indices = bit32.rshift(tableInfo, 30)
			local x1 = (if indices ~= 0 then bit32.band(bit32.rshift(tableInfo, 20), 0x3FF) else -1)
			local x2 = (if indices > 1 then bit32.band(bit32.rshift(tableInfo, 10), 0x3FF) else -1)
			local x3 = (if indices > 2 then bit32.band(tableInfo, 0x3FF) else -1)

			stack[argA] = (if x1 ~= -1 then constAdjusted[x1] else tostring(globalFunc))

			if x2 ~= -1 then
				stack[argA] = string.format(stringBuilders.codeCompletions.INDEXTO_TABLEK, stack[argA], constAdjusted[x2])
				if x3 ~= -1 then
					stack[argA] = string.format(stringBuilders.codeCompletions.INDEXTO_TABLEK, stack[argA], constAdjusted[x3])
				end
			end
		elseif (opcode == luauOps.GETENV) then
			stack[argA] = constAdjusted[codeInst[instIndex + 1]]
			table.insert(globalCache, stack[argA])

			instIndex += 1
		elseif (opcode == luauOps.SETENV) then -- volatile
			local name, value = constAdjusted[codeInst[instIndex + 1]], stack[argA]
			instIndex += 1

			local info = tracebackFrom(tracebackLog, #tracebackLog, argA, scope)
			if info then
				decompileResult ..= string.format(stringBuilders.codeCompletions.LOCAL_EXPR, info[2], info[1])
				table.insert(scope.localVars, {info[1], info[2]})

				stack[info[1]] = info[2]
			end

			decompileResult ..= string.format(stringBuilders.codeCompletions.VALUE_SETTO, name, value)
			table.insert(globalCache, name)
		elseif (opcode == luauOps.MOVE) then
			local whereMove = luau.getB(instruction)
			local regIndex = -1
			local evalScope = scope

			while (evalScope ~= nil) do
				for _, locVar in pairs(evalScope.localVars) do
					if locVar[1] == whereMove then
						regIndex = locVar[2]
					end
				end

				if regIndex ~= -1 then
					break; -- give local locals priority
				end

				evalScope = evalScope.parent
			end

			if regIndex == -1 then
				regIndex = stack[whereMove]
			end

			stack[argA] = regIndex
		elseif (opcode == luauOps.LOADK) then
			stack[argA] = formatConstant(constAdjusted[luau.getBx(instruction)])
		elseif (opcode == luauOps.LOADKX) then
			stack[argA] = formatConstant(constAdjusted[codeInst[instIndex + 1]])
			instIndex += 1
		elseif (opcode == luauOps.LOADNUM) then
			local number = bit32.band(bit32.rshift(instruction, 16), 0xFFFF)
			number = (if number <= 0x7FFF then number else (number - 0xFFFF) - 1)

			stack[argA] = number
		elseif (opcode == luauOps.LOADBOOL) then
			local boolNumber = bit32.band(bit32.rshift(instruction, 16), 0xFF)

			stack[argA] = (if boolNumber == 0 then false else true)
		elseif (opcode == luauOps.LOADNIL) then
			stack[argA] = "nil"
		elseif (opcode == luauOps.GETTABLEK) then
			local tableIndex = stack[bit32.band(bit32.rshift(instruction, 16), 0xFF)]
			local key = constAdjusted[codeInst[instIndex + 1]]
			instIndex += 1

			stack[argA] = string.format(stringBuilders.codeCompletions.INDEXTO_TABLEK, tableIndex, key)
		elseif (opcode == luauOps.GETTABLER) then
			local tableIndex = stack[bit32.band(bit32.rshift(instruction, 16), 0xFF)]
			local key = stack[bit32.band(bit32.rshift(instruction, 24), 0xFF)]

			stack[argA] = string.format(stringBuilders.codeCompletions.INDEXTO_TABLERI, tableIndex, key)
		elseif (opcode == luauOps.GETTABLEI) then
			local tableIndex = stack[bit32.band(bit32.rshift(instruction, 16), 0xFF)]
			local key = bit32.band(bit32.rshift(instruction, 24), 0xFF) + 1

			stack[argA] = string.format(stringBuilders.codeCompletions.INDEXTO_TABLERI, tableIndex, key)
		elseif (opcode == luauOps.GETUPVAL) then
			stack[argA] = protoScope.upvalInfo[bit32.band(bit32.rshift(instruction, 16), 0xFF ) + 1]
		elseif (opcode == luauOps.SETTABLEK) then -- volatile (2)
			local key, value = constAdjusted[codeInst[instIndex + 1]], stack[argA]
			instIndex += 1
			argA = bit32.band(bit32.rshift(instruction, 16), 0xFF)

			local info = tracebackFrom(tracebackLog, #tracebackLog, argA, scope)
			if info then
				decompileResult ..= string.format(stringBuilders.codeCompletions.LOCAL_EXPR, info[2], info[1])
				table.insert(scope.localVars, {info[1], info[2]})

				stack[info[1]] = info[2]
			end

			decompileResult ..= string.format(stringBuilders.codeCompletions.SETTO_TABLEK, stack[argA], key, value)
		elseif (opcode == luauOps.SETTABLER) then -- volatile (3)
			local key, value = stack[bit32.band(bit32.rshift(instruction, 24), 0xFF)], stack[argA]
			instIndex += 1
			argA = bit32.band(bit32.rshift(instruction, 16), 0xFF)

			local info = tracebackFrom(tracebackLog, #tracebackLog, argA, scope)
			if info then
				decompileResult ..= string.format(stringBuilders.codeCompletions.LOCAL_EXPR, info[2], info[1])
				table.insert(scope.localVars, {info[1], info[2]})

				stack[info[1]] = info[2]
			end

			decompileResult ..= string.format(stringBuilders.codeCompletions.SETTO_TABLERI, stack[argA], key, value)
		elseif (opcode == luauOps.SETTABLEI) then -- volatile (4)
			local key, value = (bit32.band(bit32.rshift(instruction, 24), 0xFF) + 1), stack[argA]
			instIndex += 1
			argA = bit32.band(bit32.rshift(instruction, 16), 0xFF)

			local info = tracebackFrom(tracebackLog, #tracebackLog, argA, scope)
			if info then
				decompileResult ..= string.format(stringBuilders.codeCompletions.LOCAL_EXPR, info[2], info[1])
				table.insert(scope.localVars, {info[1], info[2]})

				stack[info[1]] = info[2]
			end

			decompileResult ..= string.format(stringBuilders.codeCompletions.SETTO_TABLERI, stack[argA], key, value)
		elseif (opcode == luauOps.SETUPVAL) then
			local upvalName, upvalValue = protoScope.upvalInfo[argA + 1], stack[bit32.band(bit32.rshift(instruction, 16), 0xFF)]

			local info = tracebackFrom(tracebackLog, #tracebackLog, argA, scope)
			if info then
				decompileResult ..= string.format(stringBuilders.codeCompletions.LOCAL_EXPR, info[2], info[1])
				table.insert(scope.localVars, {info[1], info[2]})

				stack[info[1]] = info[2]
			end

			decompileResult ..= string.format(stringBuilders.codeCompletions.VALUE_SETTO, upvalName, upvalValue)
		elseif (opcode == luauOps.ADDK or opcode == luauOps.ADDR) then
			local constOrStack = (if opcode == luauOps.ADDK then constAdjusted else stack)
			local arg1, arg2 = stack[bit32.band(bit32.rshift(instruction, 16), 0xFF)], constOrStack[bit32.band(bit32.rshift(instruction, 24), 0xFF)]

			stack[argA] = string.format(stringBuilders.codeCompletions.ADDKR, arg1, arg2)
		elseif (opcode == luauOps.SUBK or opcode == luauOps.SUBR) then
			local constOrStack = (if opcode == luauOps.SUBK then constAdjusted else stack)
			local arg1, arg2 = stack[bit32.band(bit32.rshift(instruction, 16), 0xFF)], constOrStack[bit32.band(bit32.rshift(instruction, 24), 0xFF)]

			stack[argA] = string.format(stringBuilders.codeCompletions.SUBKR, arg1, arg2)
		elseif (opcode == luauOps.MULK or opcode == luauOps.MULR) then
			local constOrStack = (if opcode == luauOps.MULK then constAdjusted else stack)
			local arg1, arg2 = stack[bit32.band(bit32.rshift(instruction, 16), 0xFF)], constOrStack[bit32.band(bit32.rshift(instruction, 24), 0xFF)]

			stack[argA] = string.format(stringBuilders.codeCompletions.MULKR, arg1, arg2)
		elseif (opcode == luauOps.DIVK or opcode == luauOps.DIVR) then
			local constOrStack = (if opcode == luauOps.DIVK then constAdjusted else stack)
			local arg1, arg2 = stack[bit32.band(bit32.rshift(instruction, 16), 0xFF)], constOrStack[bit32.band(bit32.rshift(instruction, 24), 0xFF)]

			stack[argA] = string.format(stringBuilders.codeCompletions.DIVKR, arg1, arg2)
		elseif (opcode == luauOps.MODK or opcode == luauOps.MODR) then
			local constOrStack = (if opcode == luauOps.MODK then constAdjusted else stack)
			local arg1, arg2 = stack[bit32.band(bit32.rshift(instruction, 16), 0xFF)], constOrStack[bit32.band(bit32.rshift(instruction, 24), 0xFF)]

			stack[argA] = string.format(stringBuilders.codeCompletions.MODKR, arg1, arg2)
		elseif (opcode == luauOps.POWK or opcode == luauOps.POWR) then
			local constOrStack = (if opcode == luauOps.POWK then constAdjusted else stack)
			local arg1, arg2 = stack[bit32.band(bit32.rshift(instruction, 16), 0xFF)], constOrStack[bit32.band(bit32.rshift(instruction, 24), 0xFF)]

			stack[argA] = string.format(stringBuilders.codeCompletions.POWKR, arg1, arg2)
		elseif (opcode == luauOps.NEWTABLE) then -- TODO: leaves an unhandled opcode???
			local constN = codeInst[instIndex + 1]
			local hashSize, arraySize = bit32.band(bit32.rshift(instruction, 16), 0xFF), bit32.band(bit32.rshift(instruction, 24), 0xFF)
			instIndex += 1

			stack[argA] = (if constN == 0 then "{}" else "{")
		elseif (opcode == luauOps.LOADTABLEK) then
			local cachedResult = constAdjusted[bit32.band(bit32.rshift(instruction, 16), 0xFFFF)]

			stack[argA] = "{}" -- TODO: actually bsudxmssut the cache (idk what he is trying to say about the "bsudxmssut")
		elseif (opcode == luauOps.SETLIST) then -- TODO: multiple setlist
			local nElements = bit32.band(bit32.rshift(instruction, 24), 0xFF) - 1
			local toStore = codeInst[instIndex + 1]
			instIndex += 1

			if (nElements == -1) then
				for kIndex = argA + 1, 255 do
					local value = stack[kIndex]
					if value == nil then break end

					stack[argA] ..= tostring(value) .. ", \n"
				end
			else
				for elementIndex = 1, nElements do
					local element = stack[argA + elementIndex]

					stack[argA] ..= tostring(element) .. ", "
				end
			end

			stack[argA] = string.sub(stack[argA], 0, string.len(stack[argA]) - 2)
			stack[argA] ..= "}"
		elseif (opcode == luauOps.CONCAT) then
			local toConcat = stack[bit32.band(bit32.rshift(instruction, 16), 0xFF)]
			local concatValue = stack[bit32.band(bit32.rshift(instruction, 24), 0xFF)]

			stack[argA] = string.format(stringBuilders.codeCompletions.CONCAT_TO, toConcat, concatValue)
		elseif (opcode == luauOps.LEN) then
			local toLen = stack[bit32.band(bit32.rshift(instruction, 16), 0xFF)]

			stack[argA] = string.format(stringBuilders.codeCompletions.LEN_SET, toLen)
		elseif (opcode == luauOps.NOT) then
			local currentlyNotNottified = stack[bit32.band(bit32.rshift(instruction, 16), 0xFF)]

			stack[argA] = string.format(stringBuilders.codeCompletions.NOT_VALUE, currentlyNotNottified)
		elseif (opcode == luauOps.UNM) then
			local unNegatifiedConstant = stack[bit32.band(bit32.rshift(instruction, 16), 0xFF)]

			stack[argA] = string.format(stringBuilders.codeCompletions.UNM_SET, unNegatifiedConstant)
		elseif (opcode == luauOps.TEST or opcode == luauOps.TESTN) then
			local condType = (if opcode == luauOps.TEST then 0 else 1)
			local result = buildCondition(codeInst, instIndex, instruction, scope, stack[argA], condType)

			scope = result[1]
			instIndex += result[2]
			decompileResult ..= result[3]
		elseif (opcode == luauOps.EQ or opcode == luauOps.EQN or opcode == luauOps.LT or opcode == luauOps.LTN or opcode == luauOps.LEQ or opcode == luauOps.LEQN) then
			local condType = (
				if opcode == luauOps.EQ then 2
				elseif opcode == luauOps.EQN then 3
				elseif opcode == luauOps.LTN then 4
				elseif opcode == luauOps.LT then 5
				elseif opcode == luauOps.LEQN then 6
				elseif opcode == luauOps.LEQ then 7
				else 8
			)
			local value = stack[codeInst[instIndex + 1]]
			local result = buildCondition(codeInst, instIndex, instruction, scope, stack[argA], condType, value)

			scope = result[1]
			instIndex += result[2]
			decompileResult ..= result[3]
		elseif (opcode == luauOps.FORPREP) then
			local lim, step, index = tostring(stack[argA]), tostring(stack[argA + 1]), tostring(stack[argA + 2])

			local dist = bit32.band(bit32.rshift(instruction, 16), 0xFFFF)
			local destination = codeInst[instIndex + dist]
			local forScope = {
				depth = scope.depth + 1,
				closeAt = instIndex + dist,
				parent = scope,
				elses = table.create(0),
				isWhile = false,
				isBreakable = false,

				localVars = table.create(0),
				upvalInfo = table.create(0)
			}

			local evalScope = scope
			local breakableCount = 0
			local varName
			while evalScope ~= nil do
				if evalScope.isBreakable then
					breakableCount += 1
				end

				evalScope = evalScope.parent
			end

			varName = (if breakableCount > 0 then "i_" .. tostring(breakableCount) else "i")
			stack[argA + 2] = varName
			table.insert(forScope.localVars, {argA + 2, varName})
			local forLoopConstructed = string.format(stringBuilders.codeCompletions.FORLOOP_CONSTUCTOR, varName, index .. ", " .. lim .. (step ~= "1" and ", " .. step or ""))
			decompileResult ..= forLoopConstructed
			scope = forScope
		elseif (opcode == luauOps.TFORPREP) then
			local _func = stack[argA]

			local dist = bit32.band(bit32.rshift(instruction, 16), 0xFFFF)
			local destination = codeInst[instIndex + dist]
			local forScope = {
				depth = scope.depth + 1,
				closeAt = instIndex + dist,
				parent = scope,
				elses = table.create(0),
				isWhile = false,
				isBreakable = false,

				localVars = table.create(0),
				upvalInfo = table.create(0)
			}

			local evalScope = scope
			local breakableCount = 0
			local indexName, valName
			while evalScope ~= nil do
				if evalScope.isBreakable then
					breakableCount += 1
				end

				evalScope = evalScope.parent
			end
			indexName = (if breakableCount > 0 then "i_" .. tostring(breakableCount) else "i")
			valName = (if breakableCount > 0 then "v_" .. tostring(breakableCount) else "v")
			table.insert(forScope.localVars, {argA + 3, indexName})
			table.insert(forScope.localVars, {argA + 4, valName})
			local forLoopConstructed = string.format(stringBuilders.codeCompletions.TFORLOOP_CONSTRUCTOR, indexName, valName, _func)
			decompileResult ..= forLoopConstructed
			scope = forScope
		elseif (opcode == luauOps.NAMECALL) then
			local callMethod = constAdjusted[codeInst[instIndex + 1]]
			instIndex += 1
			stack[argA] = string.format(stringBuilders.codeCompletions.NAMECALL_CONSTRUCT, stack[argA], callMethod)
			local call = codeInst[instIndex + 1]
			codeInst[instIndex + 1] = luau.emitABC(luauOps.CALL, argA, luau.getB(call), luau.getC(call)) -- stolen from luau lol
		elseif (opcode == luauOps.CALL) then
			local funcName = stack[argA]
			local nArgs, nReturn = bit32.band(bit32.rshift(instruction, 16), 0xFF) - 1, bit32.band(bit32.rshift(instruction, 24), 0xFF) - 1

			local funcArgs, callStatement = "", nil
			if (nArgs == -1) then -- if args is LUA_MULTIPLE
				local argN = 1
				local argVal = stack[argA + argN]
				while (argVal ~= nil) do
					funcArgs ..= argVal .. ","
					argN += 1
					argVal = stack[argA + argN]
				end
			else
				for argIndex = 1, nArgs do
					funcArgs ..= tostring(stack[argA + argIndex]) .. ", "
					stack[argA + argIndex] = nil -- ?
				end
			end

			funcArgs = (if nArgs ~= 0 then string.sub(funcArgs, 0, string.len(funcArgs) - 2) else funcArgs)
			callStatement = string.format(stringBuilders.codeCompletions.CALL_CONSTRUCTOR, funcName, funcArgs)
			stack[argA] = callStatement

			if nReturn == 0 then
				decompileResult ..= callStatement
			end
		elseif (opcode == luauOps.RETURN) then
			local nArg = bit32.band(bit32.rshift(instruction, 16), 0xFF) - 1
			local indents = string.rep(" ", scope.depth * 4)
			local retArgs = ""

			for argIndex = 1, nArg do
				local argValue = stack[(argA + argIndex) - 1]
				retArgs ..= tostring(argValue) .. ", "
			end
			retArgs = (if nArg > 0 then string.sub(retArgs, 0, string.len(retArgs) - 1) else retArgs)
			decompileResult ..= string.format(stringBuilders.codeCompletions.RETURN_CONSTRUCTOR, indents, retArgs)

			return {decompileResult, codeLines[1]}
		elseif (opcode == luauOps.CLOSURE) then
			local closureIndex = bit32.band(bit32.rshift(instruction, 16), 0xFFFF)
			local function_ = protoScope[closureIndex]
			local funcInfo = debug.getinfo(function_)
			local nUps, nParams = funcInfo.nups, funcInfo.nparams

			local funcScope = {
				depth = scope.depth + 1,
				closeAt = -1,
				parent = scope,
				elses = table.create(0),
				isWhile = false,
				isBreakable = false,

				localVars = table.create(0),
				upvalInfo = table.create(0)
			}

			for upvalIndex = 1, nUps do
				local upval = codeInst[upvalIndex + instIndex]
				local inStackFlag, stackPos = bit32.band(bit32.rshift(instruction, 8), 0xFF), bit32.band(bit32.rshift(instruction, 16), 0xFF)
				local inStack = (if inStackFlag == 2 then false else true)
				local caught = false

				if inStack then
					local evalScope = scope

					while evalScope ~= nil do
						for _, localVar in pairs(evalScope.localVars) do
							local localStackPos = localVar[1]
							if localStackPos == stackPos then
								funcScope.upvalInfo = localVar[2]
								caught = true
							end
						end

						evalScope = evalScope.parent
					end

					if not caught then
						warn("upvalue not caught")
						local vName = "v" .. tostring(#scope.localVars + 1)
						decompileResult ..= "\n-- UPVAL:" .. string.format(stringBuilders.codeCompletions.LOCAL_EXPR, vName, stack[stackPos])
						table.insert(scope.localVars, {stackPos, vName})

						funcScope.upvalInfo[upvalIndex] = vName
					end
				end

				instIndex += 1
			end

			local funcArgs, funcArgsList = "", table.create(0)
			for argIndex = 1, nParams do
				funcArgs ..= "a" .. tostring(argIndex) .. ", "
				table.insert(funcArgsList, {argIndex - 1, "a" .. tostring(argIndex)})
			end

			funcArgs = (if nParams ~= 0 then string.sub(funcArgs, 0, string.len(funcArgs) - 2) else funcArgs)
			local funcDecompiled = reverseVM(function_, funcScope, funcArgsList)
			stack[argA] = string.format(stringBuilders.codeCompletions.CLOSURE_CONSTRUCTOR, funcArgs, funcDecompiled[1])
			lastLine = funcDecompiled[2]
			codeLines = funcDecompiled[2] + 1
		elseif (opcode == luauOps.VARARG) then
			stack[argA] = "..."
		elseif (opcode == luauOps.CLOSE) then
			-- none
		elseif (opcode == luauOps.VARARGPREP or opcode == luauOps.CLEARSTACK) then
			-- none
		elseif (opcode == 0 and instIndex == #codeLines - 1) then
			-- none
		else
			warn("UNHANDLED OPCODE", opcode)
		end

		table.insert(tracebackLog, {opcode, instruction, instIndex, argA})

		local thisLine = codeLines[instIndex]
		local dLen = thisLine - lastLine

		if (dLen > 25) then
			if (dLen > 0) then
				decompileResult ..= "\n"
			end

			lastLine = thisLine

			local evalScope = scope
			while evalScope ~= nil do
				for _, elseStatement in pairs(evalScope.elses) do
					if elseStatement == instIndex then
						local indents = (if (evalScope.parent and evalScope.parent.depth > 0) then string.rep(" ", evalScope.parent.depth * 4) else "")
						decompileResult ..= "\n" .. indents .. "else"
					end
				end

				if evalScope.closeAt == instIndex then
					local indents = (if (evalScope.parent and evalScope.parent.depth > 0) then string.rep(" ", evalScope.parent.depth * 4) else "")

					decompileResult ..= "\n" .. indents .. "end\n"
					scope = evalScope.parent
					evalScope = scope
				else
					evalScope = scope.parent
				end
			end

			if backupDResultToCheck == decompileResult then
				decompileResult = string.sub(0, string.len(decompileResult) - (scope.depth * 4))
			end
			instIndex += 1
			continue
		end

		for _ = 1, thisLine - lastLine do
			decompileResult ..= "\n"
		end
	end

	return {decompileResult, codeLines[1]}
end

local function decompileFunc(script: LocalScript | ModuleScript)
	local globalScope = {
		depth = 0,
		closeAt = -1,
		parent = nil,
		elses = table.create(0),
		isWhile = false,
		isBreakable = false,

		localVars = table.create(0),
		upvalInfo = table.create(0)
	}
	local func = getscriptclosure(script)
	local decompiledScript = reverseVM(func, globalScope, table.create(0))[1]
	return decompiledScript
end
getgenv().decompile = decompileFunc
