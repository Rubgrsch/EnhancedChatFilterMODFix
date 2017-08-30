-- ECF
local _, ecf = ...
local ECF, L, G = ecf.ECF, ecf.L, ecf.G -- Ace3, locales, global variables

local _G = _G
-- Lua
local ipairs, format, pairs, next, select, strsplit, tconcat, tonumber, type, unpack = ipairs, format, pairs, next, select, strsplit, table.concat, tonumber, type, unpack
-- WoW
local GetCurrencyLink, GetItemInfo, ITEMS = GetCurrencyLink, GetItemInfo, ITEMS
local LibStub = LibStub

--Default Options
local defaults = {
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
	debugMode = false, -- now it's the record toggle
	record = {},
	recordPos = 1,
	ChatRecordOnlyShow = 1,
}

--------------- Functions from Elsewhere ---------------
-- utf8 functions are taken from utf8replace from @Phanx @Pastamancer
local function utf8charbytes(s, i)
	local c = s:byte(i or 1)
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
	local t, pos = {}, 1

	while pos <= #s do
		local charbytes = utf8charbytes(s, pos)
		local c = s:sub(pos, pos + charbytes - 1)
		t[#t+1] = (mapping[c] or c)
		pos = pos + charbytes
	end

	return tconcat(t)
end

--http://www.wowwiki.com/USERAPI_StringHash
local function StringHash(text)
	local counter, len = 1, #text
	for i = 1, len, 3 do
		counter = ((counter*8161)%4294967279) +  -- 2^32 - 17: Prime!
			(text:byte(i)*16776193) +
			((text:byte(i+1) or (len-i+256))*8372226) +
			((text:byte(i+2) or (len-i+256))*3932164)
	end
	return counter%4294967291 -- 2^32 - 5: Prime (and different from the prime in the loop)
end

--------------- ECF functions ---------------
-- GetItemInfo Cache
local ItemInfoRequested = {} -- [Id] = value. 0: want to add; 1: old config, true -> link
local ItemCacheFrame = CreateFrame("Frame")
ItemCacheFrame:RegisterEvent("GET_ITEM_INFO_RECEIVED")
ItemCacheFrame:SetScript("OnEvent",function(self,_,Id)
	local v = ItemInfoRequested[Id]
	if not v then return end
	local _, link = GetItemInfo(Id)
	if v == 0 then -- while adding
		if link then -- if valid
			ecf.db.lootItemFilterList[Id] = link
		else
			ECF:Printf(L["NotExists"],ITEMS,Id)
		end
	elseif v == 1 then -- change true to link
		ecf.db.lootItemFilterList[Id] = link
	end
	ItemInfoRequested[Id] = nil
end)

--Make sure that blackWord won't be filtered by filterCharList and utf-8 list
local function checkBlacklist(blackWord, r)
	local newWord = G.utf8replace(blackWord, G.UTF8Symbols):gsub("%s", "")
	if (not r) then newWord=newWord:gsub(G.RegexCharList, "") end
	if(newWord ~= blackWord or blackWord == "") then return true end -- Also report "" as invalid
end

local function updateBlackWordTable()
	G.BuildedBlackWordTable = G.ACBuild(ecf.db.blackWordList)
end

--Initialize and convert old config to new one
function G.DBInitialize()
	if next(ecfDB) == nil then ecfDB = defaults
	elseif ecfDB.profiles and ecfDB.profiles.Default then
		ecfDB = ecfDB.profiles.Default
		for k in pairs(ecfDB) do if defaults[k] == nil then ecfDB[k] = nil end end -- remove old keys
		for k,v in pairs(defaults) do if ecfDB[k] == nil then ecfDB[k] = v end end -- fallback to defaults
	end
	ecf.db = ecfDB
	for key,v in pairs(ecf.db.blackWordList) do
		for key2 in pairs(ecf.db.blackWordList) do -- remove duplicate words
			if key ~= key2 and key:find(key2) then ecf.db.blackWordList[key] = nil;break end
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
	updateBlackWordTable()
end

--------------- Options ---------------
--These settings won't be saved
local lesserWordChosen, blackWordChosen = "", ""
local itemChosen, currencyChosen = 0, 0
local stringIO = "" -- blackWord input
local regexToggle, lesserToggle = false, false

local colorT = {} -- used in lootFilter
for i=0, 4 do
	colorT[i]=format("|c%s%s|r",select(4,GetItemQualityColor(i)),_G["ITEM_QUALITY"..i.."_DESC"])
end

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
			name = FILTERS,
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
		chatLinesLimit = { -- only shown in advanced mode
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
		repeatToggle = { -- only shown in non-advanced mode
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
			name = L["FilterGroup"],
			desc = L["FilterGroupTooltips"],
			order = 43,
			disabled = function() return ecf.db.chatLinesLimit == 0 end,
		},
	},
}
options.args.blackListTab = {
	type = "group",
	name = L["BlackwordFilter"],
	order = 11,
	args = {
		blackWordList = {
			type = "select",
			name = L["BlackwordList"],
			order = 1,
			get = function() return blackWordChosen end,
			set = function(_,value) lesserWordChosen, blackWordChosen = "", value end,
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
			get = function() return lesserWordChosen end,
			set = function(_,value) lesserWordChosen, blackWordChosen = value, "" end,
			values = function()
				local blacklistname = {}
				for key,v in pairs(ecf.db.blackWordList) do if v.lesser then blacklistname[key] = key end end
				return blacklistname
			end,
			hidden = function() return not ecf.db.advancedConfig end,
		},
		DeleteButton = {
			type = "execute",
			name = REMOVE,
			order = 3,
			func = function()
				ecf.db.blackWordList[lesserWordChosen ~= "" and lesserWordChosen or blackWordChosen] = nil
				lesserWordChosen, blackWordChosen = "", ""
				updateBlackWordTable()
			end,
			disabled = function() return lesserWordChosen == "" and blackWordChosen == "" end,
		},
		ClearUpButton = {
			type = "execute",
			name = L["ClearUp"],
			order = 4,
			func = function()
				ecf.db.blackWordList, lesserWordChosen, blackWordChosen = {}, "", ""
				updateBlackWordTable()
			end,
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
				updateBlackWordTable()
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
			name = OPTIONS,
			order = 20,
		},
		blackWordFilterGroup = {
			type = "toggle",
			name = L["FilterGroup"],
			desc = L["FilterGroupTooltips"],
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
		stringConfig = {
			type = "input",
			name = "",
			order = 31,
			get = function() return stringIO end,
			set = function(_,value)
				local wordString, HashString = strsplit("@", value)
				if (tonumber(HashString) ~= StringHash(wordString)) then
					ECF:Print(L["StringHashMismatch"])
				else
					for _, blacklist in ipairs({strsplit(";", wordString)}) do
						if (blacklist ~= nil) then
							local imNewWord, r, l = strsplit(",",blacklist)
							r, l = r == "r", l == "l"
							AddBlackWord(imNewWord, r, l)
						end
					end
					updateBlackWordTable()
				end
				stringIO = ""
			end,
			width = "full",
		},
		export = {
			type = "execute",
			name = L["Export"],
			order = 32,
			func = function()
				local blackStringList = {}
				for key,v in pairs(ecf.db.blackWordList) do
					if (checkBlacklist(key, v.regex)) then
						ECF:Printf(L["IncludeAutofilteredWord"],key)
					else
						blackStringList[#blackStringList+1] = format("%s,%s,%s",key,v.regex and "r" or "",v.lesser and "l" or "")
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
			get = function() return itemChosen end,
			set = function(_,value) itemChosen, currencyChosen = value or 0, 0 end,
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
			get = function() return currencyChosen end,
			set = function(_,value) currencyChosen, itemChosen = value or 0, 0 end,
			values = function()
				local currencyFilterLinkList = {}
				for key,v in pairs(ecf.db.lootCurrencyFilterList) do currencyFilterLinkList[key] = v end
				return currencyFilterLinkList
			end,
		},
		DeleteButton = {
			type = "execute",
			name = REMOVE,
			order = 3,
			func = function()
				if(itemChosen > 0) then ecf.db.lootItemFilterList[itemChosen] = nil end
				if(currencyChosen > 0) then ecf.db.lootCurrencyFilterList[currencyChosen] = nil end
				itemChosen, currencyChosen = 0, 0
			end,
			disabled = function() return itemChosen == 0 and currencyChosen == 0 end,
		},
		ClearUpButton = {
			type = "execute",
			name = L["ClearUp"],
			order = 4,
			func = function() ecf.db.lootItemFilterList, ecf.db.lootCurrencyFilterList, itemChosen, currencyChosen = {}, {}, 0, 0 end,
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
				if not Id then ECF:Print(L["BadID"]);return end
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
						ECF:Printf(L["NotExists"],Type,Id)
					end
				end
			end,
		},
		lootType = {
			type = "select",
			name = TYPE,
			order = 12,
			values = {["ITEMS"] = ITEMS, ["CURRENCY"] = CURRENCY},
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
			values = {L["ShowAll"], L["OnlyFiltered"], L["OnlyUnfiltered"]},
		},
		recordList = {
			type = "input",
			name = "",
			get = function()
				local pos, t, IsMax, showUnfilted, showFilted = ecf.db.recordPos, {}, #ecf.db.record == 500, ecf.db.ChatRecordOnlyShow ~= 2, ecf.db.ChatRecordOnlyShow ~= 3
				for i = 1, #ecf.db.record do
					local j = i
					if IsMax then
						j = pos + j -1
						if j > 500 then j = j - 500 end
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
		},
	},
}
LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("EnhancedChatFilter", options)
LibStub("AceConfigDialog-3.0"):AddToBlizOptions("EnhancedChatFilter", "EnhancedChatFilter")
