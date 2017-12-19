-- ECF
local addonName, ecf = ...
local C, L, G, AC = unpack(ecf)

local _G = _G
-- Lua
local error, ipairs, format, pairs, print, next, select, strsplit, tconcat, tonumber, type, unpack = error, ipairs, format, pairs, print, next, select, strsplit, table.concat, tonumber, type, unpack
-- WoW
local GetCurrencyLink, GetItemInfo, ITEMS = GetCurrencyLink, GetItemInfo, ITEMS
local LibStub = LibStub

-- DB Version Check
local currentVer, lastCompatibleVer = 1, 0
local versionTable = {
	[0] = "???", -- Too old
	[1] = "7.3.0-3",
}

--Default Options
local defaults = {
	enableWisper = false, -- Wisper WhiteMode
	enableDND = true, -- DND
	enableCFA = true, -- Achievement Filter
	enableRAF = false, -- RaidAlert Filter
	enableQRF = false, -- Quest/Group Report Filter
	enableDSS = true, -- Spec spell Filter
	enableMSF = false, -- Monster Say Filter
	enableAggressive = false, -- Aggressive Filter
	chatLinesLimit = 20, -- also enable repeatFilter
	repeatFilterGroup = true, -- repeatFilter enabled in group and raid
	regexWordsList = {},
	normalWordsList = {},
	lesserBlackWordThreshold = 3, -- in lesserBlackWord
	blackWordFilterGroup = false, -- blackWord enabled in group and raid
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
	DBversion = currentVer,
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
			C.db.lootItemFilterList[Id] = link
		else
			print(format(L["NotExists"],ITEMS,Id))
		end
	elseif v == 1 then -- change true to link
		C.db.lootItemFilterList[Id] = link
	end
	ItemInfoRequested[Id] = nil
end)

--Make sure that blackWord won't be filtered by filterCharList and utf-8 list
local function checkBlacklist(blackWord, r)
	local newWord = G.utf8replace(blackWord, G.UTF8Symbols):gsub("%s", "")
	if not r then newWord=newWord:gsub(G.RegexCharList, "") end
	if newWord ~= blackWord or blackWord == "" then return true end -- Also report "" as invalid
end

local function updateBlackWordTable()
	AC.BuiltBlackWordTable = AC:Build(C.db.normalWordsList)
end

--Initialize and convert old config to new one
ecf.init[#ecf.init+1] = function()
	if type(ecfDB) ~= "table" or next(ecfDB) == nil then ecfDB = defaults
	elseif ecfDB.profiles and ecfDB.profiles.Default then ecfDB = ecfDB.profiles.Default end
	C.db = ecfDB
	if not C.db.DBversion then C.db.DBversion = 0 end -- if config is too old then don't even have DBversion
	for k,v in pairs(defaults) do if C.db[k] == nil then C.db[k] = v end end -- fallback to defaults
	if C.db.DBversion < lastCompatibleVer then error(format(L["DBOutOfDate"],versionTable[C.db.DBversion],versionTable[lastCompatibleVer])) end
	-- Start of DB Conversion
	if C.db.blackWordList then -- Compatible for 1
		for k,v in pairs(C.db.blackWordList) do
			(v.regex and C.db.regexWordsList or C.db.normalWordsList)[k] = {lesser = v.lesser}
		end
	end
	-- End of DB conversion
	C.db.DBversion = currentVer
	for k in pairs(C.db) do if defaults[k] == nil then C.db[k] = nil end end -- remove old keys
	for Id, info in pairs(C.db.lootItemFilterList) do
		if info == true then ItemInfoRequested[Id] = 1 end
	end
	for Id, info in pairs(C.db.lootCurrencyFilterList) do
		if info == true then C.db.lootCurrencyFilterList[Id] = GetCurrencyLink(Id) end
	end
	updateBlackWordTable()
end

--------------- Options ---------------
--These settings won't be saved
C.UI = {
	regexToggle = false,
	lesserToggle = false,
	lootType = "ITEMS",
	stringIO = "",-- blackWord input
	lootIDChosen = nil,
	lootTypeChosen = nil,
	wordChosen = "",
	wordChosenIsLesser = false,
}

local colorT = {} -- used in lootFilter
for i=0, 4 do
	colorT[i]=format("%s%s|r",ITEM_QUALITY_COLORS[i].hex,_G["ITEM_QUALITY"..i.."_DESC"])
end

local function AddBlackWord(word, r, l)
	if checkBlacklist(word, r) then
		print(format(L["IncludeAutofilteredWord"],word))
	else
		if r then
			C.db.regexWordsList[word] = {lesser = l}
		else
			C.db.normalWordsList[word:upper()] = {lesser = l}
		end
	end
end

local function adv() return not C.db.advancedConfig end

local options = {
	type = "group",
	name = format("%s %s",addonName,GetAddOnMetadata(addonName, "Version")),
	get = function(info) return (C.db[info[#info]] ~= nil and C.db or C.UI)[info[#info]] end,
	set = function(info, value) (C.db[info[#info]] ~= nil and C.db or C.UI)[info[#info]] = value end,
	childGroups = "tab",
	args = {},
}
options.args.General = {
	type = "group",
	name = L["General"],
	order = 1,
	args = {
		MinimapToggle = {
			type = "toggle",
			name = L["MinimapIcon"],
			get = function() return not C.db.minimap.hide end,
			set = function(_,toggle)
					C.db.minimap.hide = not toggle
					if toggle then LibStub("LibDBIcon-1.0"):Show(addonName) else LibStub("LibDBIcon-1.0"):Hide(addonName) end
				end,
			order = 1,
		},
		advancedConfig = {
			type = "toggle",
			name = L["DisplayAdvancedConfig"],
			desc = L["DisplayAdvancedConfigTooltips"],
			order = 9,
			confirm = adv,
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
			hidden = adv,
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
			hidden = adv,
		},
		repeatToggle = { -- only shown in non-advanced mode
			type = "toggle",
			name = L["RepeatFilter"],
			desc = L["RepeatFilterTooltips"],
			order = 41,
			get = function() return C.db.chatLinesLimit ~= 0 end,
			set = function(_,value) C.db.chatLinesLimit = value and defaults.chatLinesLimit or 0 end,
			hidden = function() return C.db.advancedConfig end,
		},
		repeatFilterGroup = {
			type = "toggle",
			name = L["FilterGroup"],
			desc = L["FilterGroupTooltips"],
			order = 42,
			disabled = function() return C.db.chatLinesLimit == 0 end,
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
			get = function() return not C.UI.wordChosenIsLesser and C.UI.wordChosen end,
			set = function(_,value)
				C.UI.wordChosen = value
				C.UI.wordChosenIsLesser = false
			end,
			values = function()
				local blacklistname = {}
				for key,v in pairs(C.db.regexWordsList) do if not v.lesser then blacklistname[key] = key end end
				for key,v in pairs(C.db.normalWordsList) do if not v.lesser then blacklistname[key] = key end end
				return blacklistname
			end,
		},
		lesserBlackWordList = {
			type = "select",
			name = L["LesserBlackwordList"],
			order = 2,
			get = function() return C.UI.wordChosenIsLesser and C.UI.wordChosen end,
			set = function(_,value)
				C.UI.wordChosen = value
				C.UI.wordChosenIsLesser = true
			end,
			values = function()
				local blacklistname = {}
				for key,v in pairs(C.db.regexWordsList) do if v.lesser then blacklistname[key] = key end end
				for key,v in pairs(C.db.normalWordsList) do if v.lesser then blacklistname[key] = key end end
				return blacklistname
			end,
			hidden = adv
		},
		DeleteButton = {
			type = "execute",
			name = REMOVE,
			order = 3,
			func = function()
				(C.db.regexWordsList[C.UI.wordChosen] and C.db.regexWordsList or C.db.normalWordsList)[C.UI.wordChosen] = nil
				C.UI.wordChosen = ""
				updateBlackWordTable()
			end,
			disabled = function() return C.UI.wordChosen == "" end,
		},
		ClearUpButton = {
			type = "execute",
			name = L["ClearUp"],
			order = 4,
			func = function()
				C.db.regexWordsList, C.db.normalWordsList = {}, {}
				C.UI.wordChosen = ""
				updateBlackWordTable()
			end,
			confirm = true,
			confirmText = format(L["DoYouWantToClear"],L["BlackList"]),
			disabled = function() return next(C.db.regexWordsList) == nil and next(C.db.normalWordsList) == nil end,
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
				AddBlackWord(value, C.UI.regexToggle, C.UI.lesserToggle)
				updateBlackWordTable()
			end,
		},
		regexToggle = {
			type = "toggle",
			name = L["Regex"],
			desc = L["RegexTooltip"],
			order = 12,
			hidden = adv,
		},
		lesserToggle = {
			type = "toggle",
			name = L["LesserBlackWord"],
			desc = L["LesserBlackWordTooltip"],
			order = 13,
			hidden = adv,
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
			hidden = adv,
		},
		line3 = {
			type = "header",
			name = L["StringIO"],
			order = 30,
		},
		stringIO = {
			type = "input",
			name = "",
			order = 31,
			set = function(_,value)
				local wordString, HashString = strsplit("@", value)
				if tonumber(HashString) ~= StringHash(wordString) then
					print(L["StringHashMismatch"])
				else
					for _, blacklist in ipairs({strsplit(";", wordString)}) do
						if blacklist ~= nil then
							local imNewWord, r, l = strsplit(",",blacklist)
							r, l = r == "r", l == "l"
							AddBlackWord(imNewWord, r, l)
						end
					end
					updateBlackWordTable()
				end
				C.UI.stringIO = ""
			end,
			width = "full",
		},
		export = {
			type = "execute",
			name = L["Export"],
			order = 32,
			func = function()
				local blackStringList = {}
				for key,v in pairs(C.db.regexWordsList) do
					blackStringList[#blackStringList+1] = format("%s,r,%s",key,v.lesser and "l" or "")
				end
				for key,v in pairs(C.db.normalWordsList) do
					blackStringList[#blackStringList+1] = format("%s,,%s",key,v.lesser and "l" or "")
				end
				local blackString = tconcat(blackStringList,";")
				C.UI.stringIO = blackString.."@"..StringHash(blackString)
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
			get = function() return C.UI.lootTypeChosen == "ITEMS" and C.UI.lootIDChosen end,
			set = function(_,value) C.UI.lootIDChosen, C.UI.lootTypeChosen = value, "ITEMS" end,
			values = function()
				local itemFilterLinkList = {}
				for key,v in pairs(C.db.lootItemFilterList) do itemFilterLinkList[key] = type(v) == "string" and v or select(2,GetItemInfo(key)) end
				return itemFilterLinkList
			end,
		},
		currencyFilterList = {
			type = "select",
			name = L["CurrencyFilterList"],
			order = 2,
			get = function() return C.UI.lootTypeChosen == "CURRENCY" and C.UI.lootIDChosen end,
			set = function(_,value) C.UI.lootIDChosen, C.UI.lootTypeChosen = value, "CURRENCY" end,
			values = function()
				local currencyFilterLinkList = {}
				for key,v in pairs(C.db.lootCurrencyFilterList) do currencyFilterLinkList[key] = v end
				return currencyFilterLinkList
			end,
		},
		DeleteButton = {
			type = "execute",
			name = REMOVE,
			order = 3,
			func = function()
				(C.UI.lootTypeChosen == "ITEMS" and C.db.lootItemFilterList or C.db.lootCurrencyFilterList)[C.UI.lootIDChosen] = nil
				C.UI.lootIDChosen = nil
			end,
			disabled = function() return not C.UI.lootIDChosen end,
		},
		ClearUpButton = {
			type = "execute",
			name = L["ClearUp"],
			order = 4,
			func = function() C.db.lootItemFilterList, C.db.lootCurrencyFilterList, C.UI.lootIDChosen = {}, {}, nil end,
			confirm = true,
			confirmText = format(L["DoYouWantToClear"],L["LootFilter"]),
			disabled = function() return next(C.db.lootItemFilterList) == nil and next(C.db.lootCurrencyFilterList) == nil end,
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
				if not Id then print(L["BadID"]);return end
				if C.UI.lootType == "ITEMS" then
					ItemInfoRequested[Id] = 0
					local _, link = GetItemInfo(Id)
					if link then
						ItemInfoRequested[Id] = nil
						C.db.lootItemFilterList[Id] = link
					end
				else
					local link = GetCurrencyLink(Id)
					if link then
						C.db.lootCurrencyFilterList[Id] = link
					else
						print(format(L["NotExists"],C.UI.lootType,Id))
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
	name = L["HistoryWindow"],
	order = 30,
	args = {
		debugMode = {
			type = "toggle",
			name = L["ChatHistory"],
			desc = L["ChatHistoryTooltips"],
			order = 1,
		},
		clearRecord = {
			type = "execute",
			name = L["ClearHistory"],
			order = 2,
			func = function() C.db.record, C.db.recordPos = {}, 1 end
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
				local pos, t, IsMax, showUnfilted, showFilted = C.db.recordPos, {}, #C.db.record == 500, C.db.ChatRecordOnlyShow ~= 2, C.db.ChatRecordOnlyShow ~= 3
				for i = 1, #C.db.record do
					local j = i
					if IsMax then
						j = pos + j -1
						if j > 500 then j = j - 500 end
					end
					local _,msg,player,_,result = unpack(C.db.record[j])
					if (showUnfilted and not result) or (showFilted and result) then
						t[#t+1] = format("|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_%d:0|t %s: %s",result and 7 or 2,player,msg)
					end
				end
				return tconcat(t,"|n")
			end,
			set = function() return end,
			multiline = 10,
			width = "full",
			order = 10,
			hidden = function() return not C.db.debugMode end,
		},
	},
}
LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable(addonName, options)
LibStub("AceConfigDialog-3.0"):AddToBlizOptions(addonName)
