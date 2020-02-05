-- ECF
local addonName, ecf = ...
local C, L, G = unpack(ecf)

local _G = _G
-- Lua
local format, pairs, print, next, select, tconcat, tonumber, type = format, pairs, print, next, select, table.concat, tonumber, type
-- WoW
local GetCurrencyLink, GetItemInfo, ITEMS = GetCurrencyLink, GetItemInfo, ITEMS

--Default Options
local defaults = {
	enableDND = true, -- DND
	enableCFA = true, -- Achievement Filter
	enableMSF = false, -- Monster Say Filter
	enableAggressive = false, -- Aggressive Filter
	enableRepeat = true, -- repeatFilter
	repeatFilterGroup = true, -- repeatFilter enabled in group and raid
	addonRAF = false, -- RaidAlert Filter
	addonQRF = false, -- Quest/Group Report Filter
	blackWordList = {},
	totalBlackWordsFiltered = 0, -- total blackWord filtered if keywords cleanup enabled, false if disabled
	lesserBlackWordThreshold = 3, -- in lesserBlackWord
	blackWordFilterGroup = false, -- blackWord enabled in group and raid
	lootItemFilterList = {[71096] = true, [49655] = true}, -- item list, [id] = true
	lootCurrencyFilterList = {}, -- Currency list, [id] = true
	lootQualityMin = 0, -- loot quality filter, 0..4 = poor..epic
	advancedConfig = false, -- show advancedConfig
}

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
	local newWord = G.utf8replace(blackWord)
	if not r then newWord=newWord:gsub(G.RegexCharList, "") end
	if newWord ~= blackWord or blackWord == "" then return true end -- Also report "" as invalid
end

--Initialize and convert old config to new one
ecf.init[#ecf.init+1] = function()
	if type(ecfDB) ~= "table" or next(ecfDB) == nil then ecfDB = defaults end
	C.db = ecfDB
	for k in pairs(C.db) do if defaults[k] == nil then C.db[k] = nil end end -- remove old keys
	for k,v in pairs(defaults) do
		if C.db[k] == nil then C.db[k] = v end
	end
	for Id, info in pairs(C.db.lootItemFilterList) do
		if info == true then ItemInfoRequested[Id] = 1 end
	end
	if C.db.totalBlackWordsFiltered then
		--Enable cleanup record only when total keywords > 50
		local sum = 0
		for _ in pairs(C.db.blackWordList) do sum = sum + 1 end
		C.shouldEnableKeywordCleanup = sum > 50
		--Cleanup blackwordsList: Remove rarely used keywords
		if C.shouldEnableKeywordCleanup and C.db.totalBlackWordsFiltered > 1000 then
			for k,v in pairs(C.db.blackWordList) do
				if not v.lesser and not v.count then C.db.blackWordList[k] = nil else v.count = nil end
			end
			C.db.totalBlackWordsFiltered = 0
		end
	end
	C:SetupEvent()
end

--------------- Options ---------------
--These settings won't be saved
C.UI = {
	regexToggle = false,
	lesserToggle = false,
	lootType = "ITEMS",
	stringIO = "",-- blackWord input
	wordChosen = "",
	wordChosenIsLesser = false,
	lootIDChosen = false,
	lootTypeChosen = "",
}

local colorT = {} -- used in lootFilter
for i=0, 4 do
	colorT[i]=ITEM_QUALITY_COLORS[i].hex.._G["ITEM_QUALITY"..i.."_DESC"].."|r"
end

local function AddBlackWord(word, r, l)
	if checkBlacklist(word, r) then
		print(format(L["IncludeAutofilteredWord"],word))
	else
		local tbl = {}
		if l then tbl.lesser = l end
		if r then tbl.regex = not not r end
		C.db.blackWordList[r and word or word:upper()] = tbl
	end
end

local function adv() return not C.db.advancedConfig end

local options = {
	type = "group",
	name = addonName.." "..GetAddOnMetadata(addonName, "Version"),
	get = function(info) return (C.db[info[#info]] ~= nil and C.db or C.UI)[info[#info]] end,
	set = function(info, value) (C.db[info[#info]] ~= nil and C.db or C.UI)[info[#info]] = value end,
	childGroups = "tab",
	args = {},
}
options.args.General = {
	type = "group",
	name = L["General"],
	order = 1,
	set = function(info, value) C.db[info[#info]] = value; C:SetupEvent() end,
	args = {
		advancedConfig = {
			type = "toggle",
			name = L["DisplayAdvancedConfig"],
			desc = L["DisplayAdvancedConfigTooltips"],
			order = 1,
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
		enableMSF = {
			type = "toggle",
			name = L["MonsterSay"],
			desc = L["MonsterSayFilterTooltip"],
			order = 13,
		},
		enableAggressive = {
			type = "toggle",
			name = L["Aggressive"],
			desc = L["AggressiveTooltip"],
			order = 14,
		},
		line2 = {
			type = "header",
			name = L["Addons"],
			order = 30,
		},
		addonRAF = {
			type = "toggle",
			name = L["RaidAlert"],
			desc = L["RaidAlertFilterTooltip"],
			order = 31,
		},
		addonQRF = {
			type = "toggle",
			name = L["QuestReport"],
			desc = L["QuestReportFilterTooltip"],
			order = 32,
		},
		line3 = {
			type = "header",
			name = L["RepeatOptions"],
			order = 40,
		},
		enableRepeat = {
			type = "toggle",
			name = L["RepeatFilter"],
			desc = L["RepeatFilterTooltips"],
			order = 41,
		},
		repeatFilterGroup = {
			type = "toggle",
			name = L["FilterGroup"],
			desc = L["FilterGroupTooltips"],
			order = 42,
			disabled = function() return not C.db.enableRepeat end,
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
			set = function(_,value) C.UI.wordChosen, C.UI.wordChosenIsLesser = value, false end,
			values = function()
				local blacklistname = {}
				for key,v in pairs(C.db.blackWordList) do if not v.lesser then blacklistname[key] = key end end
				return blacklistname
			end,
		},
		lesserBlackWordList = {
			type = "select",
			name = L["LesserBlackwordList"],
			order = 2,
			get = function() return C.UI.wordChosenIsLesser and C.UI.wordChosen end,
			set = function(_,value) C.UI.wordChosen, C.UI.wordChosenIsLesser = value, true end,
			values = function()
				local blacklistname = {}
				for key,v in pairs(C.db.blackWordList) do if v.lesser then blacklistname[key] = key end end
				return blacklistname
			end,
			hidden = adv
		},
		DeleteButton = {
			type = "execute",
			name = REMOVE,
			order = 3,
			func = function()
				C.db.blackWordList[C.UI.wordChosen] = nil
				C.UI.wordChosen = ""
			end,
			disabled = function() return C.UI.wordChosen == "" end,
		},
		ClearUpButton = {
			type = "execute",
			name = L["ClearUp"],
			order = 4,
			func = function()
				C.db.blackWordList = {}
				C.UI.wordChosen = ""
			end,
			confirm = true,
			confirmText = format(L["DoYouWantToClear"],L["BlackList"]),
			disabled = function() return next(C.db.blackWordList) == nil end,
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
			set = function(_,value) AddBlackWord(value, C.UI.regexToggle, C.UI.lesserToggle) end,
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
		AutoCleanup = {
			type = "toggle",
			name = L["AutoCleanupKeywords"],
			desc = L["AutoCleanupKeywordsTooltip"],
			order = 21,
			get = function() return type(C.db.totalBlackWordsFiltered) == "number" end,
			set = function(_,value)
				C.db.totalBlackWordsFiltered = value and 0 or false
				if not value then for _,v in pairs(C.db.blackWordList) do v.count = nil end end
			end,
		},
		blackWordFilterGroup = {
			type = "toggle",
			name = L["FilterGroup"],
			desc = L["FilterGroupTooltips"],
			order = 22,
			set = function(info, value) C.db[info[#info]] = value; C:SetupEvent() end,
		},
		lesserBlackWordThreshold = {
			type = "range",
			name = L["LesserBlackWordThreshold"],
			desc = L["LesserBlackWordThresholdTooltips"],
			order = 23,
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
				local wordString, HashString = value:match("([^@]*)@([^@]+)")
				if tonumber(HashString) ~= StringHash(wordString) then
					print(L["StringHashMismatch"])
				else
					for newWord, r, l in wordString:gmatch("([^;,]+),(r?),(l?)") do
						AddBlackWord(newWord, r == "r", l == "l")
					end
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
				for key,v in pairs(C.db.blackWordList) do
					blackStringList[#blackStringList+1] = format("%s,%s,%s",key,v.regex and "r" or "",v.lesser and "l" or "")
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
			values = function() return C.db.lootCurrencyFilterList end,
		},
		DeleteButton = {
			type = "execute",
			name = REMOVE,
			order = 3,
			func = function()
				(C.UI.lootTypeChosen == "ITEMS" and C.db.lootItemFilterList or C.db.lootCurrencyFilterList)[C.UI.lootIDChosen] = nil
				C.UI.lootIDChosen = false
			end,
			disabled = function() return not C.UI.lootIDChosen end,
		},
		ClearUpButton = {
			type = "execute",
			name = L["ClearUp"],
			order = 4,
			func = function() C.db.lootItemFilterList, C.db.lootCurrencyFilterList, C.UI.lootIDChosen = {}, {}, false end,
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
					local link = GetCurrencyLink(Id,0)
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
LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable(addonName, options)
LibStub("AceConfigDialog-3.0"):AddToBlizOptions(addonName)
