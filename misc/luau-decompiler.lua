--[[
	Based of https://github.com/TacticalBFG/luau-decompiler
	just rewriting this to work in lua 5.1 because TacticalBFG write the shit in his executor called helicity which is paid
	TODO:
		#1: Extend this thing and use the latest from https://github.com/Roblox/luau/blob/master/Common/include/Luau/Bytecode.h
		#2 (fixed): convert the goto thingy to function (nvm using continue keyword is better)
		#3: debug.getinstructions and debug.getlines should be available (but executors doesn't have that function)
			so i was planning on making it on scratch tho but i should know how the function works first
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
		RETURN_CONSTRUCTOR = "\nreturn %s",
		CLOSURE_CONSTRUCTOR = "function(%s)\n%s\nend"
	}
}
-- luau
local luau = {};
luau.SIZE_A = 8
luau.SIZE_C = 8
luau.SIZE_B = 8
luau.SIZE_Bx = (luau.SIZE_C + luau.SIZE_B)
luau.SIZE_OP = 8
luau.POS_OP = 0
luau.POS_A = (luau.POS_OP + luau.SIZE_OP)
luau.POS_B = (luau.POS_A + luau.SIZE_A)
luau.POS_C = (luau.POS_B + luau.SIZE_B)
luau.POS_Bx = luau.POS_B
luau.MAXARG_A = (bit32.lshift(1, luau.SIZE_A) - 1)
luau.MAXARG_B = (bit32.lshift(1, luau.SIZE_B) - 1)
luau.MAXARG_C = (bit32.lshift(1, luau.SIZE_C) - 1)
luau.MAXARG_Bx = (bit32.lshift(1, luau.SIZE_Bx) - 1)
luau.MAXARG_sBx = bit32.rshift(luau.MAXARG_Bx, 1)
luau.BITRK = bit32.lshift(1, (luau.SIZE_B - 1))
luau.MAXINDEXRK = (luau.BITRK - 1)
luau.ISK = function(x) return bit32.band(x, luau.BITRK) end
luau.INDEXK = function(x) return bit32.band(x, bit32.bnot(luau.BITRK)) end
luau.RKASK = function(x) return bit32.bor(x, luau.BITRK) end
luau.MASK1 = function(n,p) return bit32.lshift(bit32.bnot(bit32.lshift(bit32.bnot(0), n)), p) end
luau.MASK0 = function(n,p) return bit32.bnot(luau.MASK1(n, p)) end
luau.GETARG_A = function(i) return bit32.band(bit32.rshift(i, luau.POS_A), luau.MASK1(luau.SIZE_A, 0)) end
luau.GETARG_B = function(i) return bit32.band(bit32.rshift(i, luau.POS_B), luau.MASK1(luau.SIZE_B, 0)) end
luau.GETARG_C = function(i) return bit32.band(bit32.rshift(i, luau.POS_C), luau.MASK1(luau.SIZE_C, 0)) end
luau.GETARG_Bx = function(i) return bit32.band(bit32.rshift(i, luau.POS_Bx), luau.MASK1(luau.SIZE_Bx, 0)) end
luau.GETARG_sBx = function(i) local Bx = luau.GETARG_Bx(i) local sBx = Bx + 1; if Bx > 0x7FFF and Bx <= 0xFFFF then sBx = -(0xFFFF - Bx); sBx = sBx - 1; end return sBx end
luau.GETARG_sAx = function(i) return bit32.rshift(i, 8) end
luau.GET_OPCODE = function(i) return bit32.band(bit32.rshift(i, luau.POS_OP), luau.MASK1(luau.SIZE_OP, 0)) end
luau.EMIT_ABC = function(opcode, a, b, c)
	return bit32.bor(bit32.bor(bit32.bor(opcode, luau.GETARG_A(a)), luau.GETARG_B(b)), luau.GETARG_C(c))
end
-- functions
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

local function buildCondition(instructions, index, inst, scope, elem, condType, b)
	local dist = bit32.band(bit32.rshift(inst, 16), 0xFFFF)
	local destInst = instructions[index + dist]
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

	local realDist = resolveRealDist(instructions, index + condSubtract)
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
	testScope.closeAt = index + dist + condSubtract
	return {testScope, skips, scr}
end

local function tracebackFrom(tracebackLog, index, LUAU_A, scope)
	local evalScope = scope
	local nLocals = 1

	while (evalScope ~= nil) do
		for _, loc in pairs(evalScope.localVars) do
			nLocals += 1
			if loc[1] == LUAU_A then
				return nil -- local already exists
			end
		end

		evalScope = evalScope.parent
	end

	for k = index, 1, -1 do
		local trace = tracebackLog[k]
		if (trace[4] == LUAU_A) then
			local op= trace[1]
			if (op ~= luauOps.SETTABLEK and op ~= luauOps.SETTABLER and op ~= luauOps.SETTABLEI and op ~= luauOps.SETENV and op ~= luauOps.SETUPVAL and op ~= luauOps.CALL) then
				return {trace[4], "v" .. tostring(nLocals)}
			end
		end
	end
end

local function deserializeBytecode(bytecode)
	local reader do
		reader = {}
		pos = 1
		function reader:pos() return pos end
		function reader:nextByte()
			local v = bytecode:byte(pos, pos)
			pos = pos + 1
			return v
		end
		function reader:nextChar()
			return string.char(reader:nextByte());
		end
		function reader:nextInt()
			local b = { reader:nextByte(), reader:nextByte(), reader:nextByte(), reader:nextByte() }
			return (
				bit32.bor(bit32.lshift(b[4], 24),
				bit32.bor(bit32.lshift(b[3], 16),
				bit32.bor(bit32.lshift(b[2], 8),
				b[1])))
			)
		end
		function reader:nextVarInt()
			local c1, c2, b, r = 0, 0, 0, 0
			repeat
				c1 = reader:nextByte()
				c2 = bit32.band(c1, 0x7F)
				r = bit32.bor(r, bit32.lshift(c2, b))
				b += 7
			until not bit32.btest(c1, 0x80)
			return r;
		end
		function reader:nextString()
			local result = ""
			local len = reader:nextVarInt();
			for i = 1, len do
				result = result .. reader:nextChar();
			end
			return result;
		end
		function reader:nextDouble()
			local b = {};
			for i = 1, 8 do
				table.insert(b, reader:nextByte());
			end
			local str = '';
			for i = 1, 8 do
				str = str .. string.char(b[i]);
			end
			return string.unpack("<d", str)
		end
	end

	local status = reader:nextByte()
	if (status == 1 or status == 2) then
		local protoTable = {}
		local stringTable = {}

		local sizeStrings = reader:nextVarInt()
		for i = 1, sizeStrings do
			stringTable[i] = reader:nextString()
		end

		local sizeProtos = reader:nextVarInt();
		for i = 1, sizeProtos do
			protoTable[i] = {} -- pre-initialize an entry
			protoTable[i].codeTable = {}
			protoTable[i].kTable = {}
			protoTable[i].pTable = {}
			protoTable[i].smallLineInfo = {}
			protoTable[i].largeLineInfo = {}
		end

		for i = 1, sizeProtos do
			local proto = protoTable[i]
			proto.maxStackSize = reader:nextByte()
			proto.numParams = reader:nextByte()
			proto.numUpValues = reader:nextByte()
			proto.isVarArg = reader:nextByte()

			proto.sizeCode = reader:nextVarInt()
			for j = 1,proto.sizeCode do
				proto.codeTable[j] = reader:nextInt()
			end

			proto.sizeConsts = reader:nextVarInt();
			for j = 1,proto.sizeConsts do
				local k = {};
				k.type = reader:nextByte();
				if k.type == 1 then -- boolean
					k.value = (reader:nextByte() == 1 and true or false)
				elseif k.type == 2 then -- number
					k.value = reader:nextDouble()
				elseif k.type == 3 then -- string
					k.value = stringTable[reader:nextVarInt()]
				elseif k.type == 4 then -- cache
					k.value = reader:nextInt()
				elseif k.type == 5 then -- table
					k.value = { ["size"] = reader:nextVarInt(), ["ids"] = {} }
					for s = 1,k.value.size do
						table.insert(k.value.ids, reader:nextVarInt() + 1)
					end
				elseif k.type == 6 then -- closure
					k.value = reader:nextVarInt() + 1 -- closure id
				elseif k.type ~= 0 then
					error(string.format("Unrecognized constant type: %i", k.type))
				end
				proto.kTable[j] = k
			end

			proto.sizeProtos = reader:nextVarInt();
			for j = 1,proto.sizeProtos do
				proto.pTable[j] = protoTable[reader:nextVarInt() + 1]
			end

			proto.lineDefined = reader:nextVarInt()

			local protoSourceId = reader:nextVarInt()
			proto.source = stringTable[protoSourceId]

			if (reader:nextByte() == 1) then -- Has Line info?
				local compKey = reader:nextVarInt()
				for j = 1,proto.sizeCode do
					proto.smallLineInfo[j] = reader:nextByte()
				end

				local n = bit32.band(proto.sizeCode + 3, -4)
				local intervals = bit32.rshift(proto.sizeCode - 1, compKey) + 1

				for j = 1,intervals do
					proto.largeLineInfo[j] = reader:nextInt()
				end
			end

			if (reader:nextByte() == 1) then -- Has Debug info?
				error("'decompile' can only be called on ROBLOX scripts")
			end
		end

		local mainProtoId = reader:nextVarInt()
		return protoTable[mainProtoId + 1], protoTable, stringTable;
	else
		error(string.format("Invalid bytecode (version: %i)", status))
		return nil;
	end
end

local function readProto(proto, scope, depth, protoTable)
	local decOutput = ""

	local function addTabSpace(depth, addNewline)
		decOutput ..= (addNewline and "\n" or "") .. string.rep(" ", depth * 4)
	end

	local stack, globalCache = table.create(0), table.create(0)

	local instructions, lines = proto.codeTable, proto.smallLineInfo
	local lastLine = lines[1]

	local tracebackLog = table.create(0)

	local protoScope = scope

	local codeIndex = 1
	while codeIndex < proto.sizeCode do
		local instruction = proto.codeTable[codeIndex]
		local opcode = luau.GET_OPCODE(instruction)
		local LUAU_A = luau.GETARG_A(instruction)
		local LUAU_B = luau.GETARG_B(instruction)
		local LUAU_Bx = luau.GETARG_Bx(instruction)
		local LUAU_C = luau.GETARG_C(instruction)
		local LUAU_sBx = luau.GETARG_sBx(instruction)
		local LUAU_sAx = luau.GETARG_sAx(instruction)

		addTabSpace(scope.depth)
		local backupDecOutput = decOutput

		-- Well I didn't expected to rewrite Tactical BFG's work lol
		-- so most of the stuff here will be removed/replaced with new one
		-- too lazy todo today I'll just take a break for this I hope I can continue
		-- this on weekends. Also I should really learn how the opcodes work in luau.
		if (opcode == luauOps.ENUM) then
			local globalFunc = proto.kTable[luau.GETARG_Bx(instruction)]
			local tableInfo = instructions[codeIndex + 1]
			codeIndex += 1

			local indices = bit32.rshift(tableInfo, 30)
			local x1 = (if indices ~= 0 then bit32.band(bit32.rshift(tableInfo, 20), 0x3FF) else -1)
			local x2 = (if indices > 1 then bit32.band(bit32.rshift(tableInfo, 10), 0x3FF) else -1)
			local x3 = (if indices > 2 then bit32.band(tableInfo, 0x3FF) else -1)

			stack[LUAU_A] = (if x1 ~= -1 then proto.kTable[x1] else tostring(globalFunc))

			if x2 ~= -1 then
				stack[LUAU_A] = string.format(stringBuilders.codeCompletions.INDEXTO_TABLEK, stack[LUAU_A], proto.kTable[x2])
				if x3 ~= -1 then
					stack[LUAU_A] = string.format(stringBuilders.codeCompletions.INDEXTO_TABLEK, stack[LUAU_A], proto.kTable[x3])
				end
			end
		elseif (opcode == luauOps.GETENV) then
			stack[LUAU_A] = proto.kTable[instructions[codeIndex + 1]]
			table.insert(globalCache, stack[LUAU_A])

			codeIndex += 1
		elseif (opcode == luauOps.SETENV) then -- volatile
			local name, value = proto.kTable[instructions[codeIndex + 1]], stack[LUAU_A]
			codeIndex += 1

			local info = tracebackFrom(tracebackLog, #tracebackLog, LUAU_A, scope)
			if info then
				decOutput ..= string.format(stringBuilders.codeCompletions.LOCAL_EXPR, info[2], info[1])
				table.insert(scope.localVars, {info[1], info[2]})

				stack[info[1]] = info[2]
			end

			decOutput ..= string.format(stringBuilders.codeCompletions.VALUE_SETTO, name, value)
			table.insert(globalCache, name)
		elseif (opcode == luauOps.MOVE) then
			local whereMove = luau.GETARG_B(instruction)
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

			stack[LUAU_A] = regIndex
		elseif (opcode == luauOps.LOADK) then
			stack[LUAU_A] = formatConstant(proto.kTable[luau.GETARG_Bx(instruction)])
		elseif (opcode == luauOps.LOADKX) then
			stack[LUAU_A] = formatConstant(proto.kTable[instructions[codeIndex + 1]])
			codeIndex += 1
		elseif (opcode == luauOps.LOADNUM) then
			local number = bit32.band(bit32.rshift(instruction, 16), 0xFFFF)
			number = (if number <= 0x7FFF then number else (number - 0xFFFF) - 1)

			stack[LUAU_A] = number
		elseif (opcode == luauOps.LOADBOOL) then
			local boolNumber = bit32.band(bit32.rshift(instruction, 16), 0xFF)

			stack[LUAU_A] = (if boolNumber == 0 then false else true)
		elseif (opcode == luauOps.LOADNIL) then
			stack[LUAU_A] = "nil"
		elseif (opcode == luauOps.GETTABLEK) then
			local tableIndex = stack[bit32.band(bit32.rshift(instruction, 16), 0xFF)]
			local key = proto.kTable[instructions[codeIndex + 1]]
			codeIndex += 1

			stack[LUAU_A] = string.format(stringBuilders.codeCompletions.INDEXTO_TABLEK, tableIndex, key)
		elseif (opcode == luauOps.GETTABLER) then
			local tableIndex = stack[bit32.band(bit32.rshift(instruction, 16), 0xFF)]
			local key = stack[bit32.band(bit32.rshift(instruction, 24), 0xFF)]

			stack[LUAU_A] = string.format(stringBuilders.codeCompletions.INDEXTO_TABLERI, tableIndex, key)
		elseif (opcode == luauOps.GETTABLEI) then
			local tableIndex = stack[bit32.band(bit32.rshift(instruction, 16), 0xFF)]
			local key = bit32.band(bit32.rshift(instruction, 24), 0xFF) + 1

			stack[LUAU_A] = string.format(stringBuilders.codeCompletions.INDEXTO_TABLERI, tableIndex, key)
		elseif (opcode == luauOps.GETUPVAL) then
			stack[LUAU_A] = protoScope.upvalInfo[bit32.band(bit32.rshift(instruction, 16), 0xFF ) + 1]
		elseif (opcode == luauOps.SETTABLEK) then -- volatile (2)
			local key, value = proto.kTable[instructions[codeIndex + 1]], stack[LUAU_A]
			codeIndex += 1
			LUAU_A = bit32.band(bit32.rshift(instruction, 16), 0xFF)

			local info = tracebackFrom(tracebackLog, #tracebackLog, LUAU_A, scope)
			if info then
				decOutput ..= string.format(stringBuilders.codeCompletions.LOCAL_EXPR, info[2], info[1])
				table.insert(scope.localVars, {info[1], info[2]})

				stack[info[1]] = info[2]
			end

			decOutput ..= string.format(stringBuilders.codeCompletions.SETTO_TABLEK, stack[LUAU_A], key, value)
		elseif (opcode == luauOps.SETTABLER) then -- volatile (3)
			local key, value = stack[bit32.band(bit32.rshift(instruction, 24), 0xFF)], stack[LUAU_A]
			codeIndex += 1
			LUAU_A = bit32.band(bit32.rshift(instruction, 16), 0xFF)

			local info = tracebackFrom(tracebackLog, #tracebackLog, LUAU_A, scope)
			if info then
				decOutput ..= string.format(stringBuilders.codeCompletions.LOCAL_EXPR, info[2], info[1])
				table.insert(scope.localVars, {info[1], info[2]})

				stack[info[1]] = info[2]
			end

			decOutput ..= string.format(stringBuilders.codeCompletions.SETTO_TABLERI, stack[LUAU_A], key, value)
		elseif (opcode == luauOps.SETTABLEI) then -- volatile (4)
			local key, value = (bit32.band(bit32.rshift(instruction, 24), 0xFF) + 1), stack[LUAU_A]
			codeIndex += 1
			LUAU_A = bit32.band(bit32.rshift(instruction, 16), 0xFF)

			local info = tracebackFrom(tracebackLog, #tracebackLog, LUAU_A, scope)
			if info then
				decOutput ..= string.format(stringBuilders.codeCompletions.LOCAL_EXPR, info[2], info[1])
				table.insert(scope.localVars, {info[1], info[2]})

				stack[info[1]] = info[2]
			end

			decOutput ..= string.format(stringBuilders.codeCompletions.SETTO_TABLERI, stack[LUAU_A], key, value)
		elseif (opcode == luauOps.SETUPVAL) then
			local upvalName, upvalValue = protoScope.upvalInfo[LUAU_A + 1], stack[bit32.band(bit32.rshift(instruction, 16), 0xFF)]

			local info = tracebackFrom(tracebackLog, #tracebackLog, LUAU_A, scope)
			if info then
				decOutput ..= string.format(stringBuilders.codeCompletions.LOCAL_EXPR, info[2], info[1])
				table.insert(scope.localVars, {info[1], info[2]})

				stack[info[1]] = info[2]
			end

			decOutput ..= string.format(stringBuilders.codeCompletions.VALUE_SETTO, upvalName, upvalValue)
		elseif (opcode == luauOps.ADDK or opcode == luauOps.ADDR) then
			local constOrStack = (if opcode == luauOps.ADDK then proto.kTable else stack)
			local arg1, arg2 = stack[bit32.band(bit32.rshift(instruction, 16), 0xFF)], constOrStack[bit32.band(bit32.rshift(instruction, 24), 0xFF)]

			stack[LUAU_A] = string.format(stringBuilders.codeCompletions.ADDKR, arg1, arg2)
		elseif (opcode == luauOps.SUBK or opcode == luauOps.SUBR) then
			local constOrStack = (if opcode == luauOps.SUBK then proto.kTable else stack)
			local arg1, arg2 = stack[bit32.band(bit32.rshift(instruction, 16), 0xFF)], constOrStack[bit32.band(bit32.rshift(instruction, 24), 0xFF)]

			stack[LUAU_A] = string.format(stringBuilders.codeCompletions.SUBKR, arg1, arg2)
		elseif (opcode == luauOps.MULK or opcode == luauOps.MULR) then
			local constOrStack = (if opcode == luauOps.MULK then proto.kTable else stack)
			local arg1, arg2 = stack[bit32.band(bit32.rshift(instruction, 16), 0xFF)], constOrStack[bit32.band(bit32.rshift(instruction, 24), 0xFF)]

			stack[LUAU_A] = string.format(stringBuilders.codeCompletions.MULKR, arg1, arg2)
		elseif (opcode == luauOps.DIVK or opcode == luauOps.DIVR) then
			local constOrStack = (if opcode == luauOps.DIVK then proto.kTable else stack)
			local arg1, arg2 = stack[bit32.band(bit32.rshift(instruction, 16), 0xFF)], constOrStack[bit32.band(bit32.rshift(instruction, 24), 0xFF)]

			stack[LUAU_A] = string.format(stringBuilders.codeCompletions.DIVKR, arg1, arg2)
		elseif (opcode == luauOps.MODK or opcode == luauOps.MODR) then
			local constOrStack = (if opcode == luauOps.MODK then proto.kTable else stack)
			local arg1, arg2 = stack[bit32.band(bit32.rshift(instruction, 16), 0xFF)], constOrStack[bit32.band(bit32.rshift(instruction, 24), 0xFF)]

			stack[LUAU_A] = string.format(stringBuilders.codeCompletions.MODKR, arg1, arg2)
		elseif (opcode == luauOps.POWK or opcode == luauOps.POWR) then
			local constOrStack = (if opcode == luauOps.POWK then proto.kTable else stack)
			local arg1, arg2 = stack[bit32.band(bit32.rshift(instruction, 16), 0xFF)], constOrStack[bit32.band(bit32.rshift(instruction, 24), 0xFF)]

			stack[LUAU_A] = string.format(stringBuilders.codeCompletions.POWKR, arg1, arg2)
		elseif (opcode == luauOps.NEWTABLE) then -- TODO: leaves an unhandled opcode???
			local constN = instructions[codeIndex + 1]
			local hashSize, arraySize = bit32.band(bit32.rshift(instruction, 16), 0xFF), bit32.band(bit32.rshift(instruction, 24), 0xFF)
			codeIndex += 1

			stack[LUAU_A] = (if constN == 0 then "{}" else "{")
		elseif (opcode == luauOps.LOADTABLEK) then
			local cachedResult = proto.kTable[bit32.band(bit32.rshift(instruction, 16), 0xFFFF)]

			stack[LUAU_A] = "{}" -- TODO: actually bsudxmssut the cache (idk what he is trying to say about the "bsudxmssut")
		elseif (opcode == luauOps.SETLIST) then -- TODO: multiple setlist
			local nElements = bit32.band(bit32.rshift(instruction, 24), 0xFF) - 1
			local toStore = instructions[codeIndex + 1]
			codeIndex += 1

			if (nElements == -1) then
				for kIndex = LUAU_A + 1, 255 do
					local value = stack[kIndex]
					if value == nil then break end

					stack[LUAU_A] ..= tostring(value) .. ", \n"
				end
			else
				for elementIndex = 1, nElements do
					local element = stack[LUAU_A + elementIndex]

					stack[LUAU_A] ..= tostring(element) .. ", "
				end
			end

			stack[LUAU_A] = string.sub(stack[LUAU_A], 0, string.len(stack[LUAU_A]) - 2)
			stack[LUAU_A] ..= "}"
		elseif (opcode == luauOps.CONCAT) then
			local toConcat = stack[bit32.band(bit32.rshift(instruction, 16), 0xFF)]
			local concatValue = stack[bit32.band(bit32.rshift(instruction, 24), 0xFF)]

			stack[LUAU_A] = string.format(stringBuilders.codeCompletions.CONCAT_TO, toConcat, concatValue)
		elseif (opcode == luauOps.LEN) then
			local toLen = stack[bit32.band(bit32.rshift(instruction, 16), 0xFF)]

			stack[LUAU_A] = string.format(stringBuilders.codeCompletions.LEN_SET, toLen)
		elseif (opcode == luauOps.NOT) then
			local currentlyNotNottified = stack[bit32.band(bit32.rshift(instruction, 16), 0xFF)]

			stack[LUAU_A] = string.format(stringBuilders.codeCompletions.NOT_VALUE, currentlyNotNottified)
		elseif (opcode == luauOps.UNM) then
			local unNegatifiedConstant = stack[bit32.band(bit32.rshift(instruction, 16), 0xFF)]

			stack[LUAU_A] = string.format(stringBuilders.codeCompletions.UNM_SET, unNegatifiedConstant)
		elseif (opcode == luauOps.TEST or opcode == luauOps.TESTN) then
			local condType = (if opcode == luauOps.TEST then 0 else 1)
			local result = buildCondition(instructions, codeIndex, instruction, scope, stack[LUAU_A], condType)

			scope = result[1]
			codeIndex += result[2]
			decOutput ..= result[3]
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
			local value = stack[instructions[codeIndex + 1]]
			local result = buildCondition(instructions, codeIndex, instruction, scope, stack[LUAU_A], condType, value)

			scope = result[1]
			codeIndex += result[2]
			decOutput ..= result[3]
		elseif (opcode == luauOps.FORPREP) then
			local lim, step, index = tostring(stack[LUAU_A]), tostring(stack[LUAU_A + 1]), tostring(stack[LUAU_A + 2])

			local dist = bit32.band(bit32.rshift(instruction, 16), 0xFFFF)
			local destination = instructions[codeIndex + dist]
			local forScope = {
				depth = scope.depth + 1,
				closeAt = codeIndex + dist,
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
			stack[LUAU_A + 2] = varName
			table.insert(forScope.localVars, {LUAU_A + 2, varName})
			local forLoopConstructed = string.format(stringBuilders.codeCompletions.FORLOOP_CONSTUCTOR, varName, index .. ", " .. lim .. (step ~= "1" and ", " .. step or ""))
			decOutput ..= forLoopConstructed
			scope = forScope
		elseif (opcode == luauOps.TFORPREP) then
			local _func = stack[LUAU_A]

			local dist = bit32.band(bit32.rshift(instruction, 16), 0xFFFF)
			local destination = instructions[codeIndex + dist]
			local forScope = {
				depth = scope.depth + 1,
				closeAt = codeIndex + dist,
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
			table.insert(forScope.localVars, {LUAU_A + 3, indexName})
			table.insert(forScope.localVars, {LUAU_A + 4, valName})
			local forLoopConstructed = string.format(stringBuilders.codeCompletions.TFORLOOP_CONSTRUCTOR, indexName, valName, _func)
			decOutput ..= forLoopConstructed
			scope = forScope
		elseif (opcode == luauOps.NAMECALL) then
			local callMethod = proto.kTable[instructions[codeIndex + 1]]
			codeIndex += 1
			stack[LUAU_A] = string.format(stringBuilders.codeCompletions.NAMECALL_CONSTRUCT, stack[LUAU_A], callMethod)
			local call = instructions[codeIndex + 1]
			instructions[codeIndex + 1] = luau.EMIT_ABC(luauOps.CALL, LUAU_A, luau.GETARG_B(call), luau.GETARG_C(call)) -- stolen from luau lol
		elseif (opcode == luauOps.CALL) then
			local funcName = stack[LUAU_A]
			local nArgs, nReturn = bit32.band(bit32.rshift(instruction, 16), 0xFF) - 1, bit32.band(bit32.rshift(instruction, 24), 0xFF) - 1

			local funcArgs, callStatement = "", nil
			if (nArgs == -1) then -- if args is LUA_MULTIPLE
				local argN = 1
				local argVal = stack[LUAU_A + argN]
				while (argVal ~= nil) do
					funcArgs ..= argVal .. ","
					argN += 1
					argVal = stack[LUAU_A + argN]
				end
			else
				for argIndex = 1, nArgs do
					funcArgs ..= tostring(stack[LUAU_A + argIndex]) .. ", "
					stack[LUAU_A + argIndex] = nil -- ?
				end
			end

			funcArgs = (if nArgs ~= 0 then string.sub(funcArgs, 0, string.len(funcArgs) - 2) else funcArgs)
			callStatement = string.format(stringBuilders.codeCompletions.CALL_CONSTRUCTOR, funcName, funcArgs)
			stack[LUAU_A] = callStatement

			if nReturn == 0 then
				decOutput ..= callStatement
			end
		elseif (opcode == luauOps.RETURN) then
			local nArg = bit32.band(bit32.rshift(instruction, 16), 0xFF) - 1
			local retArgs = ""

			for argIndex = 1, nArg do
				local argValue = stack[(LUAU_A + argIndex) - 1]
				retArgs ..= tostring(argValue) .. ", "
			end
			retArgs = (if nArg > 0 then string.sub(retArgs, 0, string.len(retArgs) - 1) else retArgs)
			addTabSpace(scope.depth, true)
			decOutput ..= string.format(stringBuilders.codeCompletions.RETURN_CONSTRUCTOR, retArgs)
			return {decOutput, lines[1]}
		elseif (opcode == luauOps.CLOSURE) then -- needs to be reworked
			--[[local closureIndex = bit32.band(bit32.rshift(instruction, 16), 0xFFFF)
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
				local upval = instructions[upvalIndex + codeIndex]
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
						decOutput ..= "\n-- UPVAL:" .. string.format(stringBuilders.codeCompletions.LOCAL_EXPR, vName, stack[stackPos])
						table.insert(scope.localVars, {stackPos, vName})

						funcScope.upvalInfo[upvalIndex] = vName
					end
				end

				codeIndex += 1
			end

			local funcArgs, funcArgsList = "", table.create(0)
			for argIndex = 1, nParams do
				funcArgs ..= "a" .. tostring(argIndex) .. ", "
				table.insert(funcArgsList, {argIndex - 1, "a" .. tostring(argIndex)})
			end

			funcArgs = (if nParams ~= 0 then string.sub(funcArgs, 0, string.len(funcArgs) - 2) else funcArgs)
			local funcDecompiled = reverseVM(function_, funcScope, funcArgsList)
			stack[LUAU_A] = string.format(stringBuilders.codeCompletions.CLOSURE_CONSTRUCTOR, funcArgs, funcDecompiled[1])
			lastLine = funcDecompiled[2]
			lines = funcDecompiled[2] + 1--]]
		elseif (opcode == luauOps.VARARG) then
			stack[LUAU_A] = "..."
		elseif (opcode == luauOps.CLOSE) then
			-- none
		elseif (opcode == luauOps.VARARGPREP or opcode == luauOps.CLEARSTACK) then
			-- none
		elseif (opcode == 0 and codeIndex == #lines - 1) then
			-- none
		else
			warn("UNHANDLED OPCODE", opcode)
		end

		table.insert(tracebackLog, {opcode, instruction, codeIndex, LUAU_A})

		local thisLine = lines[codeIndex]
		local dLen = thisLine - lastLine

		if (dLen > 25) then
			if (dLen > 0) then
				decOutput ..= "\n"
			end

			lastLine = thisLine

			local evalScope = scope
			while evalScope ~= nil do
				for _, elseStatement in pairs(evalScope.elses) do
					if elseStatement == codeIndex then
						if (evalScope.parent and evalScope.parent.depth > 0) then
							addTabSpace(evalScope.parent.depth, true)
						end
						decOutput ..= "else"
					end
				end

				if evalScope.closeAt == codeIndex then
					if (evalScope.parent and evalScope.parent.depth > 0) then
						addTabSpace(evalScope.parent.depth, true)
					end

					decOutput ..= "end\n"
					scope = evalScope.parent
					evalScope = scope
				else
					evalScope = scope.parent
				end
			end

			if backupDecOutput == decOutput then
				decOutput = string.sub(0, string.len(decOutput) - (scope.depth * 4))
			end
			codeIndex += 1
			continue
		end

		for _ = 1, thisLine - lastLine do
			decOutput ..= "\n"
		end
	end
end

local function reverseVM(bytecode, scope)
	local mainProto, protoTable, stringTable = deserializeBytecode(bytecode)
	mainProto.source = "main"

	return readProto(mainProto, scope, 0, protoTable)
end
reverseVM()
