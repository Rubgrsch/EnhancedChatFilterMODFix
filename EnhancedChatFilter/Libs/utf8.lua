--[[
utf8replace from @Phanx @Pastamancer
--]]

local strbyte, strlen, strsub, type = string.byte, string.len, string.sub, type
local utfdebug = nil
-- returns the number of bytes used by the UTF-8 character at byte i in s
-- also doubles as a UTF-8 character validator

local function utf8charbytes(s, i)
	-- argument defaults
	i = i or 1

	-- argument checking
	if utfdebug and type(s) ~= "string" then
		error("bad argument #1 to 'utf8charbytes' (string expected, got ".. type(s).. ")")
	end
	if utfdebug and type(i) ~= "number" then
		error("bad argument #2 to 'utf8charbytes' (number expected, got ".. type(i).. ")")
	end

	local c = strbyte(s, i)

	-- determine bytes needed for character, based on RFC 3629
	-- validate byte 1
	if c > 0 and c <= 127 then
		-- UTF8-1
		return 1

	elseif c >= 194 and c <= 223 then
		-- UTF8-2
		local c2 = strbyte(s, i + 1)

		if utfdebug and not c2 then
			error("UTF-8 string terminated early")
		end

		-- validate byte 2
		if utfdebug and (c2 < 128 or c2 > 191) then
			error("Invalid UTF-8 character")
		end

		return 2

	elseif c >= 224 and c <= 239 then
		-- UTF8-3
		local c2 = strbyte(s, i + 1)
		local c3 = strbyte(s, i + 2)

		if utfdebug and (not c2 or not c3) then
			error("UTF-8 string terminated early")
		end

		-- validate byte 2
		if utfdebug and (c == 224 and (c2 < 160 or c2 > 191)) then
			error("Invalid UTF-8 character")
		elseif utfdebug and (c == 237 and (c2 < 128 or c2 > 159)) then
			error("Invalid UTF-8 character")
		elseif utfdebug and (c2 < 128 or c2 > 191) then
			error("Invalid UTF-8 character")
		end

		-- validate byte 3
		if utfdebug and (c3 < 128 or c3 > 191) then
			error("Invalid UTF-8 character")
		end

		return 3

	elseif c >= 240 and c <= 244 then
		-- UTF8-4
		local c2 = strbyte(s, i + 1)
		local c3 = strbyte(s, i + 2)
		local c4 = strbyte(s, i + 3)

		if utfdebug and (not c2 or not c3 or not c4) then
			error("UTF-8 string terminated early")
		end

		-- validate byte 2
		if utfdebug and (c == 240 and (c2 < 144 or c2 > 191)) then
			error("Invalid UTF-8 character")
		elseif utfdebug and (c == 244 and (c2 < 128 or c2 > 143)) then
			error("Invalid UTF-8 character")
		elseif utfdebug and (c2 < 128 or c2 > 191) then
			error("Invalid UTF-8 character")
		end

		-- validate byte 3
		if utfdebug and (c3 < 128 or c3 > 191) then
			error("Invalid UTF-8 character")
		end

		-- validate byte 4
		if utfdebug and (c4 < 128 or c4 > 191) then
			error("Invalid UTF-8 character")
		end

		return 4

	else
		error("Invalid UTF-8 character")
	end
end

-- replace UTF-8 characters based on a mapping table
local _, ecf = ...
ecf.utf8replace = function(s, mapping)
	-- argument checking
	if type(s) ~= "string" then
		error("bad argument #1 to 'utf8replace' (string expected, got ".. type(s).. ")")
	end
	if type(mapping) ~= "table" then
		error("bad argument #2 to 'utf8replace' (table expected, got ".. type(mapping).. ")")
	end

	local pos = 1
	local bytes = strlen(s)
	local charbytes
	local newstr = ""

	while pos <= bytes do
		charbytes = utf8charbytes(s, pos)
		local c = strsub(s, pos, pos + charbytes - 1)

		newstr = newstr .. (mapping[c] or c)

		pos = pos + charbytes
	end

	return newstr
end