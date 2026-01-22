--SynapseX Decompiler

local BitBuffer = {}
local DISABLE_WARNINGS = false
local NumberToBase64, Base64ToNumber
NumberToBase64 = {}
Base64ToNumber = {}
do
	local chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
	for i = 1, #chars do
		local ch = chars:sub(i, i)
		NumberToBase64[i - 1] = ch
		Base64ToNumber[ch] = i - 1
	end
end
BitBuffer.NumberToBase64 = NumberToBase64
BitBuffer.Base64ToNumber = Base64ToNumber
local PowerOfTwo
PowerOfTwo = {}
for i = 0, 64 do
	PowerOfTwo[i] = 2 ^ i
end
local BrickColorToNumber, NumberToBrickColor
BrickColorToNumber = {}
NumberToBrickColor = {}
for i = 0, 63 do
	local color = BrickColor.palette(i)
	BrickColorToNumber[color.Number] = i
	NumberToBrickColor[i] = color
end
BrickColorToNumber[1005] = 42
NumberToBrickColor[42] = BrickColor.new("Deep orange")
local floor, insert = math.floor, table.insert
local function ToBase(n, b)
	n = floor(n)
	if not b or b == 10 then
		return tostring(n)
	end
	local digits = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"
	local t = {}
	local sign = ""
	if n < 0 then
		sign = "-"
		n = -n
	end
	repeat
		local d = n % b + 1
		n = floor(n / b)
		insert(t, 1, digits:sub(d, d))
	until n == 0
	return sign .. table.concat(t, "")
end
function BitBuffer.Create()
	local this = {}
	local mBitPtr = 0
	local mBitBuffer = {}
	function this:ResetPtr()
		mBitPtr = 0
	end
	function this:Reset()
		mBitBuffer = {}
		mBitPtr = 0
	end
	function this:Eof()
		return mBitPtr >= #mBitBuffer
	end
	function this:GetData()
		local b = mBitBuffer
		self:Reset()
		return b
	end
	function this:PrintPtr()
		print(mBitPtr .. " / " .. #mBitBuffer)
	end
	local mDebug = false
	function this:SetDebug(state)
		mDebug = state
	end
	function this:FromString(str)
		this:Reset()
		for i = 1, #str do
			local ch = str:sub(i, i):byte()
			for i = 1, 8 do
				mBitPtr = mBitPtr + 1
				mBitBuffer[mBitPtr] = ch % 2
				ch = math.floor(ch / 2)
			end
		end
		mBitPtr = 0
	end
	function this:ToString()
		local str = ""
		local accum = 0
		local pow = 0
		for i = 1, math.ceil(#mBitBuffer / 8) * 8 do
			accum = accum + PowerOfTwo[pow] * (mBitBuffer[i] or 0)
			pow = pow + 1
			if pow >= 8 then
				str = str .. string.char(accum)
				accum = 0
				pow = 0
			end
		end
		return str
	end
	function this:FromBase64(str)
		this:Reset()
		for i = 1, #str do
			local ch = Base64ToNumber[str:sub(i, i)]
			assert(ch, "Bad character: 0x" .. ToBase(str:sub(i, i):byte(), 16))
			for i = 1, 6 do
				mBitPtr = mBitPtr + 1
				mBitBuffer[mBitPtr] = ch % 2
				ch = math.floor(ch / 2)
			end
			assert(ch == 0, "Character value 0x" .. ToBase(Base64ToNumber[str:sub(i, i)], 16) .. " too large")
		end
		this:ResetPtr()
	end
	function this:ToBase64()
		local strtab = {}
		local accum = 0
		local pow = 0
		for i = 1, math.ceil(#mBitBuffer / 6) * 6 do
			accum = accum + PowerOfTwo[pow] * (mBitBuffer[i] or 0)
			pow = pow + 1
			if pow >= 6 then
				table.insert(strtab, NumberToBase64[accum])
				accum = 0
				pow = 0
			end
		end
		return table.concat(strtab)
	end
	function this:Dump()
		local str = ""
		local str2 = ""
		local accum = 0
		local pow = 0
		for i = 1, math.ceil(#mBitBuffer / 8) * 8 do
			str2 = str2 .. (mBitBuffer[i] or 0)
			accum = accum + PowerOfTwo[pow] * (mBitBuffer[i] or 0)
			pow = pow + 1
			if pow >= 8 then
				str2 = str2 .. " "
				str = str .. "0x" .. ToBase(accum, 16) .. " "
				accum = 0
				pow = 0
			end
		end
		print("Bytes:", str)
		print("Bits:", str2)
	end
	local function writeBit(v)
		mBitPtr = mBitPtr + 1
		mBitBuffer[mBitPtr] = v
	end
	local function readBit(v)
		mBitPtr = mBitPtr + 1
		return mBitBuffer[mBitPtr]
	end
	function this:WriteUnsigned(w, value, printoff)
		local inValue = value
		assert(w, "Bad arguments to BitBuffer::WriteUnsigned (Missing BitWidth)")
		assert(value, "Bad arguments to BitBuffer::WriteUnsigned (Missing Value)")
		assert(value >= 0, "Negative value to BitBuffer::WriteUnsigned")
		assert(math.floor(value) == value, "Non-integer value to BitBuffer::WriteUnsigned")
		if mDebug and not printoff then
			print("WriteUnsigned[" .. w .. "]:", value)
		end
		for i = 1, w do
			writeBit(value % 2)
			value = math.floor(value / 2)
		end
		assert(value == 0, "Value " .. tostring(inValue) .. " is wider than " .. w .. " bits by " .. value)
	end
	function this:ReadUnsigned(w, printoff)
		local value = 0
		for i = 1, w do
			local r = readBit()
			value = value + r * PowerOfTwo[i - 1]
		end
		if mDebug and not printoff then
			print("ReadUnsigned[" .. w .. "]:", value)
		end
		return value
	end
	function this:WriteSigned(w, value)
		assert(w and value, "Bad arguments to BitBuffer::WriteSigned (Did you forget a bitWidth?)")
		assert(math.floor(value) == value, "Non-integer value to BitBuffer::WriteSigned")
		if mDebug then
			print("WriteSigned[" .. w .. "]:", value)
		end
		if value < 0 then
			writeBit(1)
			value = -value
		else
			writeBit(0)
		end
		this:WriteUnsigned(w - 1, value, true)
	end
	function this:ReadSigned(w)
		local sign = (-1) ^ readBit()
		local value = this:ReadUnsigned(w - 1, true)
		if mDebug then
			print("ReadSigned[" .. w .. "]:", sign * value)
		end
		return sign * value
	end
	function this:WriteString(s)
		local bitWidth = 7
		for i = 1, #s do
			if s:sub(i, i):byte() > 127 then
				bitWidth = 8
				break
			end
		end
		if bitWidth == 7 then
			this:WriteBool(false)
		else
			this:WriteBool(true)
		end
		for i = 1, #s do
			local ch = s:sub(i, i):byte()
			if ch == 16 then
				this:WriteUnsigned(bitWidth, 16)
				this:WriteBool(true)
			else
				this:WriteUnsigned(bitWidth, ch)
			end
		end
		this:WriteUnsigned(bitWidth, 16)
		this:WriteBool(false)
	end
	function this:ReadString()
		local bitWidth
		if this:ReadBool() then
			bitWidth = 8
		else
			bitWidth = 7
		end
		local str = ""
		while true do
			local ch = this:ReadUnsigned(bitWidth)
			if ch == 16 then
				local flag = this:ReadBool()
				if flag then
					str = str .. string.char(16)
				else
					break
				end
			else
				str = str .. string.char(ch)
			end
		end
		return str
	end
	function this:WriteBool(v)
		if mDebug then
			print("WriteBool[1]:", v and "1" or "0")
		end
		if v then
			this:WriteUnsigned(1, 1, true)
		else
			this:WriteUnsigned(1, 0, true)
		end
	end
	function this:ReadBool()
		local v = this:ReadUnsigned(1, true) == 1
		if mDebug then
			print("ReadBool[1]:", v and "1" or "0")
		end
		return v
	end
	function this:WriteFloat(wfrac, wexp, f)
		assert(wfrac and wexp and f)
		local sign = 1
		if f < 0 then
			f = -f
			sign = -1
		end
		local mantissa, exponent = math.frexp(f)
		if exponent == 0 and mantissa == 0 then
			this:WriteUnsigned(wfrac + wexp + 1, 0)
			return
		elseif f == 0.5 then
			exponent = -1
			mantissa = PowerOfTwo[wfrac] - 1
		else
			mantissa = (mantissa - 0.5) / 0.5 * PowerOfTwo[wfrac]
		end
		if sign == -1 then
			this:WriteBool(true)
		else
			this:WriteBool(false)
		end
		mantissa = math.floor(mantissa + 0.5)
		this:WriteUnsigned(wfrac, mantissa)
		local maxExp = PowerOfTwo[wexp - 1] - 1
		if exponent > maxExp then
			exponent = maxExp
		end
		if exponent < -maxExp then
			exponent = -maxExp
		end
		this:WriteSigned(wexp, exponent)
	end
	function this:ReadFloat(wfrac, wexp)
		assert(wfrac and wexp)
		local sign = 1
		if this:ReadBool() then
			sign = -1
		end
		local mantissa = this:ReadUnsigned(wfrac)
		local exponent = this:ReadSigned(wexp)
		if exponent == 0 and mantissa == 0 then
			return 0
		elseif exponent == -1 and mantissa == PowerOfTwo[wfrac] - 1 then
			return 0.5
		end
		mantissa = mantissa / PowerOfTwo[wfrac] * 0.5 + 0.5
		return sign * math.ldexp(mantissa, exponent)
	end
	function this:WriteFloat16(f)
		this:WriteFloat(10, 5, f)
	end
	function this:ReadFloat16()
		return this:ReadFloat(10, 5)
	end
	function this:WriteFloat32(f)
		this:WriteFloat(23, 8, f)
	end
	function this:ReadFloat32()
		return this:ReadFloat(23, 8)
	end
	function this:WriteFloat64(f)
		this:WriteFloat(52, 11, f)
	end
	function this:ReadFloat64()
		return this:ReadFloat(52, 11)
	end
	function this:WriteBrickColor(b)
		local pnum = BrickColorToNumber[b.Number]
		if not pnum then
			if not DISABLE_WARNINGS then
				warn("Attempt to serialize non-pallete BrickColor `" .. tostring(b) .. "` (#" .. b.Number .. "), using Light Stone Grey instead.")
			end
			pnum = BrickColorToNumber[BrickColor.new(1032).Number]
		end
		this:WriteUnsigned(6, pnum)
	end
	function this:ReadBrickColor()
		return NumberToBrickColor[this:ReadUnsigned(6)]
	end
	local round = function(n)
		return math.floor(n + 0.5)
	end
	function this:WriteRotation(cf)
		local lookVector = cf.lookVector
		local azumith = math.atan2(-lookVector.X, -lookVector.Z)
		local ybase = (lookVector.X ^ 2 + lookVector.Z ^ 2) ^ 0.5
		local elevation = math.atan2(lookVector.Y, ybase)
		local withoutRoll = CFrame.new(cf.p) * CFrame.Angles(0, azumith, 0) * CFrame.Angles(elevation, 0, 0)
		local x, y, z = (withoutRoll:inverse() * cf):toEulerAnglesXYZ()
		local roll = z
		azumith = round(azumith / math.pi * 2097151)
		roll = round(roll / math.pi * 1048575)
		elevation = round(elevation / (math.pi / 2) * 1048575)
		this:WriteSigned(22, azumith)
		this:WriteSigned(21, roll)
		this:WriteSigned(21, elevation)
	end
	function this:ReadRotation()
		local azumith = this:ReadSigned(22)
		local roll = this:ReadSigned(21)
		local elevation = this:ReadSigned(21)
		azumith = math.pi * (azumith / 2097151)
		roll = math.pi * (roll / 1048575)
		elevation = math.pi / 2 * (elevation / 1048575)
		local rot = CFrame.Angles(0, azumith, 0)
		rot = rot * CFrame.Angles(elevation, 0, 0)
		rot = rot * CFrame.Angles(0, 0, roll)
		return rot
	end
	function this:WriteCFrame(cframe)
		local p = cframe.p
		this:WriteFloat32(p.X)
		this:WriteFloat32(p.Y)
		this:WriteFloat32(p.Z)
		this:WriteRotation(cframe)
	end
	function this:ReadCFrame()
		return CFrame.new(this:ReadFloat32(), this:ReadFloat32(), this:ReadFloat32()) * this:ReadRotation()
	end
	function this:WriteColor3(color)
		local r, g, b = math.floor(color.r * 255 + 0.5), math.floor(color.g * 255 + 0.5), math.floor(color.b * 255 + 0.5)
		this:WriteUnsigned(8, r)
		this:WriteUnsigned(8, g)
		this:WriteUnsigned(8, b)
	end
	function this:ReadColor3()
		local r = this:ReadUnsigned(8)
		local g = this:ReadUnsigned(8)
		local b = this:ReadUnsigned(8)
		return Color3.fromRGB(r, g, b)
	end
	return this
end
function BitBuffer.SetBit(str, bitPos, v)
	local i = math.ceil(bitPos / 6)
	local len = str:len()
	if i > len then
		str = str .. string.rep(NumberToBase64[0], i - len)
	end
	bitPos = (bitPos - 1) % 6 + 1
	local ch = Base64ToNumber[str:sub(i, i)]
	local accum = 0
	local pow = 0
	for b = 1, 6 do
		local bit = ch % 2
		if b == bitPos then
			if v == 0 or not v then
				bit = 0
			else
				bit = 1
			end
		end
		accum = accum + PowerOfTwo[pow] * bit
		pow = pow + 1
		ch = math.floor(ch / 2)
	end
	return str:sub(1, i - 1) .. NumberToBase64[accum] .. str:sub(i + 1)
end
function BitBuffer.GetBit(str, bitPos)
	if bitPos > str:len() * 6 then
		return false
	end
	local i = math.ceil(bitPos / 6)
	local ch = Base64ToNumber[str:sub(i, i)]
	bitPos = (bitPos - 1) % 6
	ch = math.floor(ch / PowerOfTwo[bitPos])
	return ch % 2 == 1
end
function BitBuffer.GetMinimumBitWidth(maximumValueUnsigned)
	return math.ceil(math.log(math.max(1, maximumValueUnsigned) + 1) / math.log(2))
end
return BitBuffer
