-- ECF
local _, ecf = ...
local ECF, L, G = ecf.ECF, ecf.L, ecf.G -- Ace3, locales, global variables

local _G = _G
local type, select, ipairs, pairs, next, strsub, format, tonumber, tconcat, strfind, strbyte, fmod, unpack = type, select, ipairs, pairs, next, strsub, format, tonumber, table.concat, string.find, string.byte, math.fmod, unpack -- lua
local band, GetCurrencyLink, GetItemInfo = bit.band, GetCurrencyLink, GetItemInfo -- BLZ

--Default Options
local defaults = {
	profile = {
		enableFilter = true, -- Main Toggle
		enableWisper = false, -- Wisper WhiteMode
		enableDND = true, -- DND
		enableCFA = true, -- Achievement Filter
		enableRAF = false, -- RaidAlert Filter
		enableQRF = false, -- Quest/Group Report Filter
		enableDSS = true, -- Spec spell Filter
		enableMSF = false, -- Monster Say Filter
		enableAggressive = false, -- Aggressive Filter
		chatLinesLimit = 20, -- also enable repeatFilter
		multiLine = false, -- MultiLines, in RepeatFilter
		repeatFilterGroup = true, -- repeatFilter enabled in group and raid
		blackWordList = {},
		lesserBlackWordThreshold = 3, -- in lesserBlackWord
		blackWordFilterGroup = false, -- blackWord enabled in group and raid
		lootType = "ITEMS", -- loot filter type
		lootItemFilterList = {[118043] = true, [71096] = true, [49655] = true}, -- item list, [id] = true
		lootCurrencyFilterList = {[944] = true, [1268] = true}, -- Currency list, [id] = true
		lootQualityMin = 0, -- loot quality filter, 0..4 = poor..epic
		minimap = {
			hide = false, -- minimap
		},
		advancedConfig = false, -- show advancedConfig
		debugMode = false,
		record = {},
		recordPos = 1,
		ChatRecordOnlyShow = 1,
	}
}

--------------- Functions from Elsewhere ---------------
-- utf8 functions are taken from utf8replace from @Phanx @Pastamancer
local function utf8charbytes(s, i)
	local c = strbyte(s, i or 1)
	-- determine bytes needed for character, based on RFC 3629
	if c > 0 and c <= 127 then
		return 1
	elseif c >= 194 and c <= 223 then
		return 2
	elseif c >= 224 and c <= 239 then
		return 3
	elseif c >= 240 and c <= 244 then
		return 4
	end
end

-- replace UTF-8 characters based on a mapping table
function G.utf8replace(s, mapping)
	local pos = 1
	local t = {}

	while pos <= #s do
		local charbytes = utf8charbytes(s, pos)
		local c = strsub(s, pos, pos + charbytes - 1)
		t[#t+1] = (mapping[c] or c)
		pos = pos + charbytes
	end

	return tconcat(t)
end

--http://www.wowwiki.com/USERAPI_StringHash
local function StringHash(text)
	local counter, len = 1, #text
	for i = 1, len, 3 do
		counter = fmod(counter*8161, 4294967279) +  -- 2^32 - 17: Prime!
			(strbyte(text,i)*16776193) +
			((strbyte(text,i+1) or (len-i+256))*8372226) +
			((strbyte(text,i+2) or (len-i+256))*3932164)
	end
	return fmod(counter, 4294967291) -- 2^32 - 5: Prime (and different from the prime in the loop)
end

--------------- ECF functions ---------------
-- GetItemInfo Cache
local ItemInfoRequested = {} -- [Id] = value; value: 0: want to add; 1: old config, true -> link
local ItemCacheFrame = CreateFrame("Frame")
ItemCacheFrame:RegisterEvent("GET_ITEM_INFO_RECEIVED")
ItemCacheFrame:SetScript("OnEvent",function(self,_,Id)
	local v = ItemInfoRequested[Id]
	if not v then return end
	local _, link = GetItemInfo(Id)
	if v == 0 then -- while adding
		if link then -- if valid
			ecf.db.lootItemFilterList[Id] = link
			ECF:Print(format(L["AddedItem"],link))
		else
			ECF:Print(format(L["NotExists"],_G["ITEMS"],Id))
		end
	elseif v == 1 then -- change true to link
		ecf.db.lootItemFilterList[Id] = link
	end
	ItemInfoRequested[Id] = nil
end)

--Bit Mask for blackword type
local regexBit, lesserBit = 1, 2

local function MaskType(...) -- ... are boolean
	local ty = 0
	for idx, v in ipairs({...}) do
		if(v) then ty = ty + 2^(idx-1) end
	end
	return ty
end

local function UnMaskType(ty) -- return boolean
	return band(ty,regexBit) ~= 0, band(ty,lesserBit) ~= 0
end

function G.DBInitialize()
	ecf.db = LibStub("AceDB-3.0"):New("ecfDB", defaults, "Default").profile
end

--Make sure that blackWord won't be filtered by filterCharList and utf-8 list
local function checkBlacklist(blackWord, r)
	local newWord = blackWord:gsub("%s", ""):gsub(G.filterCharList, "")
	if (not r) then newWord=newWord:gsub(G.filterCharListRegex, "") end
	newWord = G.utf8replace(newWord, G.UTF8Symbols)
	if(newWord ~= blackWord or blackWord == "") then return true end -- Also report "" as invalid
end

--Convert old config to new one
function G.DBconvert()
	for key,v in pairs(ecf.db.blackWordList) do
		for key2 in pairs(ecf.db.blackWordList) do -- remove duplicate words
			if key ~= key2 and strfind(key,key2) then ecf.db.blackWordList[key] = nil;break end
		end
		if(checkBlacklist(key,v.regex)) then ecf.db.blackWordList[key] = nil end -- remove invalid
		if(not v.regex) then -- force upper
			ecf.db.blackWordList[key] = nil
			ecf.db.blackWordList[key:upper()] = v
		end
	end
	for Id, info in pairs(ecf.db.lootItemFilterList) do
		if info == true then ItemInfoRequested[Id] = 1 end
	end
	for Id, info in pairs(ecf.db.lootCurrencyFilterList) do
		if info == true then ecf.db.lootCurrencyFilterList[Id] = GetCurrencyLink(Id) end
	end
end

--------------- Options ---------------
--These settings won't be saved
local highlightIsLesser, blackWordHighlight = false, ""
local itemHighlight, currencyHighlight = 0, 0
local stringIO = "" -- blackWord input
local regexToggle, lesserToggle = false, false

local colorT = {} -- used in lootFilter
for i=0, 4 do
	colorT[i]=format("|c%s%s|r",select(4,GetItemQualityColor(i)),_G["ITEM_QUALITY"..i.."_DESC"])
end
local recordShowT = {L["ShowAll"],L["OnlyFiltered"],L["OnlyUnfiltered"]}

local function AddBlackWord(word, r, l)
	if (checkBlacklist(word, r)) then
		ECF:Printf(L["IncludeAutofilteredWord"],word)
	else
		if not r then word = word:upper() end
		ecf.db.blackWordList[word] = {regex = r, lesser = l,}
	end
end

local options = {
	type = "group",
	name = "EnhancedChatFilter "..GetAddOnMetadata("EnhancedChatFilter", "Version"),
	get = function(info) return ecf.db[info[#info]] end,
	set = function(info, value) ecf.db[info[#info]] = value end,
	childGroups = "tab",
	args = {},
}
options.args.General = {
	type = "group",
	name = L["General"],
	order = 1,
	args = {
		enableFilter = {
			type = "toggle",
			name = L["MainFilter"],
			order = 1,
		},
		MinimapToggle = {
			type = "toggle",
			name = L["MinimapIcon"],
			get = function() return not ecf.db.minimap.hide end,
			set = function(_,toggle)
					ecf.db.minimap.hide = not toggle
					if(toggle) then LibStub("LibDBIcon-1.0"):Show("Enhanced Chat Filter") else LibStub("LibDBIcon-1.0"):Hide("Enhanced Chat Filter") end
				end,
			order = 2,
			disabled = false,
		},
		advancedConfig = {
			type = "toggle",
			name = L["DisplayAdvancedConfig"],
			desc = L["DisplayAdvancedConfigTooltips"],
			order = 9,
			confirm = function() return not ecf.db.advancedConfig end,
		},
		line1 = {
			type = "header",
			name = _G["FILTERS"],
			order = 10,
		},
		enableDND = {
			type = "toggle",
			name = L["DND"],
			desc = L["DNDfilterTooltip"],
			order = 11,
		},
		enableCFA = {
			type = "toggle",
			name = L["Achievement"],
			desc = L["AchievementFilterTooltip"],
			order = 12,
		},
		enableRAF = {
			type = "toggle",
			name = L["RaidAlert"],
			desc = L["RaidAlertFilterTooltip"],
			order = 13,
		},
		enableQRF = {
			type = "toggle",
			name = L["QuestReport"],
			desc = L["QuestReportFilterTooltip"],
			order = 14,
		},
		enableDSS = {
			type = "toggle",
			name = L["SpecSpell"],
			desc = L["SpecSpellFilterTooltip"],
			order = 15,
		},
		enableMSF = {
			type = "toggle",
			name = L["MonsterSay"],
			desc = L["MonsterSayFilterTooltip"],
			order = 16,
		},
		enableAggressive = {
			type = "toggle",
			name = L["Aggressive"],
			desc = L["AggressiveTooltip"],
			order = 17,
		},
		enableWisper = {
			type = "toggle",
			name = L["WhisperWhitelistMode"],
			desc = L["WhisperWhitelistModeTooltip"],
			order = 18,
			hidden = function() return not ecf.db.advancedConfig end,
		},
		line2 = {
			type = "header",
			name = L["RepeatOptions"],
			order = 40,
		},
		chatLinesLimit = { -- only show in advanced mode
			type = "range",
			name = L["chatLinesLimit"],
			desc = L["chatLinesLimitTooltips"],
			order = 41,
			min = 0,
			max = 100,
			step = 1,
			bigStep = 5,
			hidden = function() return not ecf.db.advancedConfig end,
		},
		repeatToggle = { -- only show in non-advanced mode
			type = "toggle",
			name = L["RepeatFilter"],
			desc = L["RepeatFilterTooltips"],
			order = 41,
			get = function() return ecf.db.chatLinesLimit ~= 0 end,
			set = function(_,value) ecf.db.chatLinesLimit = value and 20 or 0 end,
			hidden = function() return ecf.db.advancedConfig end,
		},
		multiLine = {
			type = "toggle",
			name = L["MultiLines"],
			desc = L["MultiLinesTooltip"],
			order = 42,
			disabled = function() return ecf.db.chatLinesLimit == 0 end,
			hidden = function() return not ecf.db.advancedConfig end,
		},
		repeatFilterGroup = {
			type = "toggle",
			name = L["AlsoFilterGroup"],
			desc = L["AlsoFilterGroupTooltips"],
			order = 43,
			disabled = function() return ecf.db.chatLinesLimit == 0 end,
		},
	},
}
options.args.blackListTab = {
	type = "group",
	name = L["BlackwordList"],
	order = 11,
	args = {
		blackWordList = {
			type = "select",
			name = L["BlackwordList"],
			order = 1,
			get = function() return highlightIsLesser and "" or blackWordHighlight end,
			set = function(_,value) highlightIsLesser, blackWordHighlight = false, value end,
			values = function()
				local blacklistname = {}
				for key,v in pairs(ecf.db.blackWordList) do if not v.lesser then blacklistname[key] = key end end
				return blacklistname
			end,
		},
		lesserBlackWordList = {
			type = "select",
			name = L["LesserBlackwordList"],
			order = 2,
			get = function() return highlightIsLesser and blackWordHighlight or "" end,
			set = function(_,value) highlightIsLesser, blackWordHighlight = true, value	end,
			values = function()
				local blacklistname = {}
				for key,v in pairs(ecf.db.blackWordList) do if v.lesser then blacklistname[key] = key end end
				return blacklistname
			end,
			hidden = function() return not ecf.db.advancedConfig end,
		},
		DeleteButton = {
			type = "execute",
			name = _G["REMOVE"],
			order = 3,
			func = function()
				ecf.db.blackWordList[blackWordHighlight] = nil
				blackWordHighlight = ""
			end,
			disabled = function() return blackWordHighlight == "" end,
		},
		ClearUpButton = {
			type = "execute",
			name = L["ClearUp"],
			order = 4,
			func = function() ecf.db.blackWordList, blackWordHighlight = {}, "" end,
			confirm = true,
			confirmText = format(L["DoYouWantToClear"],L["BlackList"]),
			disabled = function() return next(ecf.db.blackWordList) == nil end,
		},
		line1 = {
			type = "header",
			name = "",
			order = 10,
		},
		blackword = {
			type = "input",
			name = L["AddBlackWordTitle"],
			order = 11,
			get = nil,
			set = function(_,value)
				AddBlackWord(value, regexToggle, lesserToggle)
			end,
		},
		regexToggle = {
			type = "toggle",
			name = L["Regex"],
			desc = L["RegexTooltip"],
			get = function() return regexToggle end,
			set = function(_,value) regexToggle = value end,
			order = 12,
			hidden = function() return not ecf.db.advancedConfig end,
		},
		lesserToggle = {
			type = "toggle",
			name = L["LesserBlackWord"],
			desc = L["LesserBlackWordTooltip"],
			get = function() return lesserToggle end,
			set = function(_,value) lesserToggle = value end,
			order = 13,
			hidden = function() return not ecf.db.advancedConfig end,
		},
		line2 = {
			type = "header",
			name = _G["OPTIONS"],
			order = 20,
		},
		blackWordFilterGroup = {
			type = "toggle",
			name = L["AlsoFilterGroup"],
			desc = L["AlsoFilterGroupTooltips"],
			order = 21,
		},
		lesserBlackWordThreshold = {
			type = "range",
			name = L["LesserBlackWordThreshold"],
			desc = L["LesserBlackWordThresholdTooltips"],
			order = 22,
			min = 2,
			max = 5,
			step = 1,
			hidden = function() return not ecf.db.advancedConfig end,
		},
		line3 = {
			type = "header",
			name = L["StringIO"],
			order = 30,
		},
		stringconfig = {
			type = "input",
			name = "",
			order = 31,
			get = function() return stringIO end,
			set = function(_,value) stringIO = value end,
			width = "full",
			multiline = 4,
			control = "ECFTextBox",
		},
		import = {
			type = "execute",
			name = L["Import"],
			order = 32,
			func = function()
				local wordString, HashString = strsplit("@", stringIO)
				if (tonumber(HashString) ~= StringHash(wordString)) then
					ECF:Print(L["StringHashMismatch"])
					return
				end
				local newBlackList = {strsplit(";", wordString)}
				for _, blacklist in ipairs(newBlackList) do
					if (blacklist ~= nil) then
						local imNewWord, imTypeWord = strsplit(",",blacklist)
						if imTypeWord then AddBlackWord(imNewWord, UnMaskType(imTypeWord)) end
					end
				end
				stringIO = ""
				ECF:Print(L["ImportSucceeded"])
			end,
			disabled = function() return stringIO == "" end,
		},
		export = {
			type = "execute",
			name = L["Export"],
			order = 33,
			func = function()
				local blackStringList = {}
				for key,v in pairs(ecf.db.blackWordList) do
					local num = MaskType(v.regex, v.lesser)
					if (checkBlacklist(key, v.regex)) then
						ECF:Printf(L["IncludeAutofilteredWord"],key)
					else
						blackStringList[#blackStringList+1] = key..","..num
					end
				end
				local blackString = tconcat(blackStringList,";")
				stringIO = blackString.."@"..StringHash(blackString)
			end,
		},
	},
}
options.args.lootFilter = {
	type = "group",
	name = L["LootFilter"],
	order = 12,
	args = {
		itemFilterList = {
			type = "select",
			name = L["ItemFilterList"],
			order = 1,
			get = function() return itemHighlight end,
			set = function(_,value) itemHighlight, currencyHighlight = value or nil, 0 end,
			values = function()
				local itemFilterLinkList = {}
				for key,v in pairs(ecf.db.lootItemFilterList) do itemFilterLinkList[key] = type(v) == "string" and v or select(2,GetItemInfo(key)) end
				return itemFilterLinkList
			end,
		},
		currencyFilterList = {
			type = "select",
			name = L["CurrencyFilterList"],
			order = 2,
			get = function() return currencyHighlight end,
			set = function(_,value) currencyHighlight, itemHighlight = value or nil, 0 end,
			values = function()
				local currencyFilterLinkList = {}
				for key,v in pairs(ecf.db.lootCurrencyFilterList) do currencyFilterLinkList[key] = v end
				return currencyFilterLinkList
			end,
		},
		DeleteButton = {
			type = "execute",
			name = _G["REMOVE"],
			order = 3,
			func = function()
				if(itemHighlight > 0) then ecf.db.lootItemFilterList[itemHighlight] = nil end
				if(currencyHighlight > 0) then ecf.db.lootCurrencyFilterList[currencyHighlight] = nil end
				itemHighlight, currencyHighlight = 0, 0
			end,
			disabled = function() return itemHighlight == 0 and currencyHighlight end,
		},
		ClearUpButton = {
			type = "execute",
			name = L["ClearUp"],
			order = 4,
			func = function() ecf.db.lootItemFilterList, ecf.db.lootCurrencyFilterList, itemHighlight, currencyHighlight = {}, {}, 0, 0 end,
			confirm = true,
			confirmText = format(L["DoYouWantToClear"],L["LootFilter"]),
			disabled = function() return next(ecf.db.lootItemFilterList) == nil and next(ecf.db.lootCurrencyFilterList) == nil end,
		},
		line1 = {
			type = "header",
			name = "",
			order = 10,
		},
		addItem = {
			type = "input",
			name = L["AddItemWithID"],
			order = 11,
			get = nil,
			set = function(_,value)
				local Id = tonumber(value)
				if type(Id) ~= "number" then ECF:Print(L["BadID"]);return end
				local Type = ecf.db.lootType
				if(Type == "ITEMS") then
					ItemInfoRequested[Id] = 0
					local _, link = GetItemInfo(Id)
					if link then
						ItemInfoRequested[Id] = nil
						ecf.db.lootItemFilterList[Id] = link
					end
				else
					local link = GetCurrencyLink(Id)
					if link then
						ecf.db.lootCurrencyFilterList[Id] = link
					else
						ECF:Print(format(L["NotExists"],_G[Type],Id))
					end
				end
			end,
		},
		lootType = {
			type = "select",
			name = _G["TYPE"],
			order = 12,
			values = {["ITEMS"] = _G["ITEMS"], ["CURRENCY"] = _G["CURRENCY"]},
		},
		line2 = {
			type = "header",
			name = L["LootQualityFilter"],
			order = 50,
		},
		lootQualityMin = {
			type = "select",
			name = L["LootQualityFilter"],
			desc = L["LootQualityFilterTooltips"],
			order = 51,
			values = colorT,
		},
	},
}
options.args.debugWindow = {
	type = "group",
	name = L["RecordWindow"],
	order = 30,
	args = {
		debugMode = {
			type = "toggle",
			name = L["ChatRecord"],
			desc = L["ChatRecordTooltips"],
			order = 1,
		},
		clearRecord = {
			type = "execute",
			name = L["ClearRecord"],
			order = 2,
			func = function() ecf.db.record, ecf.db.recordPos = {}, 1 end
		},
		ChatRecordOnlyShow = {
			type = "select",
			name = "",
			order = 3,
			values = recordShowT,
		},
		recordList = {
			type = "input",
			name = "",
			get = function()
				local pos, t, IsMax, showUnfilted, showFilted = ecf.db.recordPos, {}, #ecf.db.record == 500, ecf.db.ChatRecordOnlyShow ~= 2, ecf.db.ChatRecordOnlyShow ~= 3
				for i = 1, #ecf.db.record do
					local j
					if IsMax then
						j = pos + i -1
						if j > 500 then j = j - 500 end
					else
						j = i
					end
					local _,msg,trimmedPlayer,_,filterResult = unpack(ecf.db.record[j])
					if (showUnfilted and not filterResult) or (showFilted and filterResult) then
						t[#t+1] = format("|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_%d:0|t %s: %s",filterResult and 7 or 2,trimmedPlayer,msg)
					end
				end
				return tconcat(t,"|n")
			end,
			set = nil,
			multiline = 10,
			width = "full",
			order = 10,
			hidden = function() return not ecf.db.debugMode end,
			control = "ECFTextBox",
		},
	},
}
LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("EnhancedChatFilter", options)
LibStub("AceConfigDialog-3.0"):AddToBlizOptions("EnhancedChatFilter", "EnhancedChatFilter")
