--[[
utf8replace from @Phanx @Pastamancer
--]]

local strbyte, strlen, strsub, tinsert = strbyte, strlen, strsub, tinsert
-- returns the number of bytes used by the UTF-8 character at byte i in s
-- also doubles as a UTF-8 character validator

local function utf8charbytes(s, i)
	-- argument defaults
	i = i or 1

	local c = strbyte(s, i)
	-- determine bytes needed for character, based on RFC 3629
	-- validate byte 1
	if c > 0 and c <= 127 then
		-- UTF8-1
		return 1
	elseif c >= 194 and c <= 223 then
		-- UTF8-2
		return 2
	elseif c >= 224 and c <= 239 then
		-- UTF8-3
		return 3
	elseif c >= 240 and c <= 244 then
		-- UTF8-4
		return 4
	end
end

-- replace UTF-8 characters based on a mapping table
local _, ecf = ...
ecf.utf8replace = function(s, mapping)
	local pos = 1
	local newstrtable = {}

	while pos <= strlen(s) do
		local charbytes = utf8charbytes(s, pos)
		local c = strsub(s, pos, pos + charbytes - 1)

		tinsert(newstrtable, (mapping[c] or c))

		pos = pos + charbytes
	end

	return table.concat(newstrtable)
end