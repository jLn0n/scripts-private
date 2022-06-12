--[[
IronBrew:tm: obfuscation; Version 2.7.2
]]
return(function(str_byte, tinsert, setmetatable)
	local str_char = string.char
	local str_sub = string.sub
	local tconcat = table.concat
	local ldexp = math.ldexp
	local getfenv = getfenv
	local select = select
	local tunpack = unpack or table.unpack
	local tonumber = tonumber
	local function decompressStr(stringArg)
		local L_29_, L_30_, L_31_ = "", "", {}
		local L_32_ = 256
		local charVars = {}
		for index = 0, L_32_ - 1 do
			charVars[index] = str_char(index)
		end
		local i_getCharVal = 1
		local function getCharVal()
			local n1 = tonumber(str_sub(stringArg, i_getCharVal, i_getCharVal), 36)
			i_getCharVal += 1
			local n2 = tonumber(str_sub(stringArg, i_getCharVal, ((i_getCharVal + n1) - 1)), 36)
			i_getCharVal += n1
			print(n1, n2, i_getCharVal)
			return n2
		end
		L_29_ = str_char(getCharVal())
		L_31_[1] = L_29_
		while i_getCharVal < #stringArg do
			local charVal = getCharVal()
			if charVars[charVal] then
				L_30_ = charVars[charVal]
			else
				L_30_ = L_29_ .. str_sub(L_29_, 1, 1)
			end
			charVars[L_32_] = L_29_ .. str_sub(L_30_, 1, 1)
			L_31_[#L_31_ + 1], L_29_, L_32_ = L_30_, L_30_, L_32_ + 1
		end
		return table.concat(L_31_)
	end
	local decompressed_str = decompressStr("1J1H2751J1K2751H22P22R23C23J22T1J27427522H23C1L2791327L2751G27M1N1H27Q27H2751M27927427Q1H1I279280279279")
	print(decompressed_str)

	local bxor = bit32 and bit32.bxor or
		function(L_40_arg1, L_41_arg2)
		local L_42_, L_43_, L_44_ = 1, 0, 10
		while L_40_arg1 > 0 and L_41_arg2 > 0 do
			local L_45_, L_46_ =
				L_40_arg1 % 2,
			L_41_arg2 % 2
			if L_45_ ~= L_46_ then
				L_43_ = L_43_ + L_42_
			end
			L_40_arg1, L_41_arg2, L_42_ =
				(L_40_arg1 - L_45_) / 2,
			(L_41_arg2 - L_46_) / 2,
			L_42_ * 2
		end
		if L_40_arg1 < L_41_arg2 then
			L_40_arg1 = L_41_arg2
		end
		while L_40_arg1 > 0 do
			local L_47_ = L_40_arg1 % 2
			if L_47_ > 0 then
				L_43_ = L_43_ + L_42_
			end
			L_40_arg1, L_42_ =
				(L_40_arg1 - L_47_) / 2,
			L_42_ * 2
		end
		return L_43_
	end
	local function L_16_func(
		L_48_arg1,
		L_49_arg2,
		L_50_arg3)
		if L_50_arg3 then
			local L_51_ =
				(L_48_arg1 / 2 ^ (L_49_arg2 - 1)) %
				2 ^ ((L_50_arg3 - 1) - (L_49_arg2 - 1) + 1)
			return L_51_ - L_51_ % 1
		else
			local L_52_ = 2 ^ (L_49_arg2 - 1)
			return (L_48_arg1 % (L_52_ + L_52_) >=
				L_52_) and
				1 or
				0
		end
	end
	local L_17_ = 1
	local function L_18_func()
		local L_53_,
		L_54_,
		L_55_,
		L_56_ =
			str_byte(
				decompressed_str,
				L_17_,
				L_17_ + 3
			)
		L_53_ = bxor(L_53_, 17)
		L_54_ = bxor(L_54_, 17)
		L_55_ = bxor(L_55_, 17)
		L_56_ = bxor(L_56_, 17)
		L_17_ = L_17_ + 4
		return (L_56_ * 16777216) + (L_55_ * 65536) +
			(L_54_ * 256) +
			L_53_
	end
	local function L_19_func()
		local L_57_ =
			bxor(
				str_byte(
					decompressed_str,
					L_17_,
					L_17_
				),
				17
			)
		L_17_ = L_17_ + 1
		return L_57_
	end
	local function L_20_func()
		local L_58_, L_59_ =
			str_byte(
				decompressed_str,
				L_17_,
				L_17_ + 2
			)
		L_58_ = bxor(L_58_, 17)
		L_59_ = bxor(L_59_, 17)
		L_17_ = L_17_ + 2
		return (L_59_ * 256) + L_58_
	end
	local function L_21_func()
		local L_60_ = L_18_func()
		local L_61_ = L_18_func()
		local L_62_ = 1
		local L_63_ =
			(L_16_func(L_61_, 1, 20) * (2 ^ 32)) +
			L_60_
		local L_64_ = L_16_func(L_61_, 21, 31)
		local L_65_ =
			((-1) ^ L_16_func(L_61_, 32))
		if (L_64_ == 0) then
			if (L_63_ == 0) then
				return L_65_ * 0
			else
				L_64_ = 1
				L_62_ = 0
			end
		elseif (L_64_ == 2047) then
			return (L_63_ == 0) and (L_65_ * (1 / 0)) or
				(L_65_ * (0 / 0))
		end
		return ldexp(L_65_, L_64_ - 1023) *
			(L_62_ + (L_63_ / (2 ^ 52)))
	end
	local L_22_ = L_18_func
	local function L_23_func(L_66_arg1)
		local L_67_
		if (not L_66_arg1) then
			L_66_arg1 = L_22_()
			if (L_66_arg1 == 0) then
				return ""
			end
		end
		L_67_ =
			str_sub(
				decompressed_str,
				L_17_,
				L_17_ + L_66_arg1 - 1
			)
		L_17_ = L_17_ + L_66_arg1
		local L_68_ = {}
		for L_69_forvar1 = 1, #L_67_ do
			L_68_[L_69_forvar1] =
				str_char(
					bxor(
						str_byte(
							str_sub(
								L_67_,
								L_69_forvar1,
								L_69_forvar1
							)
						),
						17
					)
				)
		end
		return tconcat(L_68_)
	end
	local L_24_ = L_18_func
	local function L_25_func(...)
		return {
			...
		}, select("#", ...)
	end
	local function L_26_func()
		local L_70_ = {}
		local L_71_ = {}
		local L_72_ = {}
		local L_73_ = {
			[#{
				{
					672,
					366,
					614,
					209
				},
				"1 + 1 = 111"
			}] = L_71_,
			[#{
				"1 + 1 = 111",
				"1 + 1 = 111",
				"1 + 1 = 111"
			}] = nil,
			[#{
				{
					456,
					566,
					22,
					446
				},
				{
					153,
					947,
					248,
					241
				},
				{
					963,
					100,
					352,
					84
				},
				{
					566,
					110,
					650,
					33
				}
			}] = L_72_,
			[#{
				"1 + 1 = 111"
			}] = L_70_
		}
		local L_74_ = L_18_func()
		local L_75_ = {}
		for L_76_forvar1 = 1, L_74_ do
			local L_77_ = L_19_func()
			local L_78_
			if (L_77_ == 0) then
				L_78_ = (L_19_func() ~= 0)
			elseif (L_77_ == 3) then
				L_78_ = L_21_func()
			elseif (L_77_ == 2) then
				L_78_ = L_23_func()
			end
			L_75_[L_76_forvar1] = L_78_
		end
		for L_79_forvar1 = 1, L_18_func() do
			local L_80_ = L_19_func()
			if (L_16_func(L_80_, 1, 1) == 0) then
				local L_81_ = L_16_func(L_80_, 2, 3)
				local L_82_ =
					L_16_func(L_80_, 4, 6)
				local L_83_ = {
					L_20_func(),
					L_20_func(),
					nil,
					nil
				}
				if (L_81_ == 0) then
					L_83_[#("H5k")] = L_20_func()
					L_83_[#("fKeV")] = L_20_func()
				elseif (L_81_ == 1) then
					L_83_[#("W9x")] = L_18_func()
				elseif (L_81_ == 2) then
					L_83_[#("tfX")] = L_18_func() - (2 ^ 16)
				elseif (L_81_ == 3) then
					L_83_[#("8Ml")] = L_18_func() - (2 ^ 16)
					L_83_[#("tsSK")] = L_20_func()
				end
				if (L_16_func(L_82_, 1, 1) == 1) then
					L_83_[#("KO")] = L_75_[L_83_[#("PO")]]
				end
				if (L_16_func(L_82_, 2, 2) == 1) then
					L_83_[#("Xff")] = L_75_[L_83_[#("4lB")]]
				end
				if (L_16_func(L_82_, 3, 3) == 1) then
					L_83_[#("8C1k")] = L_75_[L_83_[#("uF6m")]]
				end
				L_70_[L_79_forvar1] = L_83_
			end
		end
		L_73_[3] = L_19_func()
		for L_84_forvar1 = 1, L_18_func() do
			L_71_[L_84_forvar1 - 1] = L_26_func()
		end
		return L_73_
	end
	local function L_27_func(
		L_85_arg1,
		L_86_arg2,
		L_87_arg3)
		L_85_arg1 =
			(L_85_arg1 == true and L_26_func()) or
			L_85_arg1
		return (function(...)
			local L_88_ = L_85_arg1[1]
			local L_89_ = L_85_arg1[3]
			local L_90_ = L_85_arg1[2]
			local L_91_ = L_25_func
			local L_92_ = 1
			local L_93_ = -1
			local L_94_ = {}
			local L_95_ = {
				...
			}
			local L_96_ = select("#", ...) - 1
			local L_97_ = {}
			local L_98_ = {}
			for L_102_forvar1 = 0, L_96_ do
				if (L_102_forvar1 >= L_89_) then
					L_94_[L_102_forvar1 - L_89_] =
						L_95_[L_102_forvar1 + 1]
				else
					L_98_[L_102_forvar1] =
						L_95_[L_102_forvar1 + #{
						"1 + 1 = 111"
					}]
				end
			end
			local L_99_ = L_96_ - L_89_ + 1
			local L_100_
			local L_101_
			while true do
				L_100_ = L_88_[L_92_]
				L_101_ = L_100_[#("8")]
				if L_101_ <= #("mvg") then
					if L_101_ <= #("8") then
						if L_101_ > #("") then
							L_98_[L_100_[#("P2")]] =
								L_87_arg3[L_100_[#("A0O")]]
						else
							local L_103_ = L_100_[#("Cv")]
							L_98_[L_103_](
								L_98_[L_103_ + 1]
							)
						end
					elseif L_101_ == #("sU") then
						L_98_[L_100_[#("17")]] =
							L_100_[#("zlh")]
					else
						do
							return
						end
					end
				elseif L_101_ <= #("yHr05") then
					if L_101_ > #("8oMq") then
						do
							return
						end
					else
						L_98_[L_100_[#{
							"1 + 1 = 111",
							"1 + 1 = 111"
						}]] =
							L_87_arg3[L_100_[#("t0i")]]
					end
				elseif L_101_ > #("rlEi88") then
					local L_104_ = L_100_[#("xW")]
					L_98_[L_104_](
						L_98_[L_104_ + 1]
					)
				else
					L_98_[L_100_[#("7t")]] =
						L_100_[#("jbg")]
				end
				L_92_ = L_92_ + 1
			end
		end)
	end
	return L_27_func(true, {}, getfenv())()
end)(string.byte, table.insert, setmetatable)