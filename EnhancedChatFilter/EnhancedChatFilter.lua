-- Some UTF-8 symbols that will be auto-changed
local UTF8Symbols = {['·']='',['＠']='',['＃']='',['％']='',['／']='',['＆']='',['＊']='',
	['－']='',['＋']='',['｜']='',['～']='',['　']='',['，']='',['。']='',['、']='',['｛']='',['｝']='',
	['？']='',['！']='',['：']='',['；']='',['￥']='',['＝']='',['—']='',['…']='',['‖']='',
	['【']='',['】']='',['『']='',['』']='',['《']='',['》']='',['（']='',['）']='',['〔']='',
	['〕']='',['〈']='',['〉']='',['＇']='',['＂']='',['’']='',['‘']='',['“']='',['”']='',
	['１']='1',['２']='2',['３']='3',['４']='4',['５']='5',['６']='6',['７']='7',['８']='8',
	['９']='9',['０']='0',['⒈']='1',['⒉']='2',['⒊']='3',['⒋']='4',['⒌']='5',['⒍']='6',
	['⒎']='7',['⒏']='8',['⒐']='9',['Ａ']='A',['Ｂ']='B',['Ｃ']='C',['Ｄ']='D',['Ｅ']='E',
	['Ｆ']='F',['Ｇ']='G',['Ｈ']='H',['Ｉ']='I',['Ｊ']='J',['Ｋ']='K',['Ｌ']='L',['Ｍ']='M',
	['Ｎ']='N',['Ｏ']='O',['Ｐ']='P',['Ｑ']='Q',['Ｒ']='R',['Ｓ']='S',['Ｔ']='T',['Ｕ']='U',
	['Ｖ']='V',['Ｗ']='W',['Ｘ']='X',['Ｙ']='Y',['Ｚ']='Z'}
local RaidAlertTagList = {"%*%*.+%*%*", "EUI:.+施放了", "EUI:.+中断", "EUI:.+就绪", "EUI_RaidCD", "PS 死亡: .+>", "|Hspell.+ => ", "受伤源自 |Hspell.+ %(总计%): ", "Fatality:.+> %d", "已打断.*|Hspell", "打断→%[.+%]"}  -- RaidAlert Tag
local QuestReportTagList = {"任务进度提示%s?[:：]", "%(任务完成%)", "<大脚组队提示>", "%[接受任务%]", "<大脚团队提示>", "进度:.+: %d+/%d+", "接受任务: ?%[%d+%]", "【网%.易%.有%.爱】", "任务%[%d+%]%[.+%] 已完成!"} -- QuestReport Tag
local filterCharList = "[|@!/<>\"`'_#&;:~\\]" -- work on any blackWord
local filterCharListRegex = "[%(%)%.%%%+%-%*%?%[%]%$%^={}]" -- won't work on regex blackWord, but works on others

-- ECF
local _, ecf = ...
local L = ecf.L -- locales.lua

local config

local _G = _G
local gsub, select, ipairs, pairs, next, strsub, format, tonumber, strmatch, tconcat, strfind, strbyte, fmod = gsub, select, ipairs, pairs, next, strsub, format, tonumber, strmatch, table.concat, string.find, string.byte, math.fmod -- lua
local Ambiguate, band, BNGetNumFriends, BNGetNumFriendGameAccounts, BNGetFriendGameAccountInfo, ChatTypeInfo, GetCurrencyLink, GetFriendInfo, GetGuildInfo, GetItemInfo, GetNumFriends, GetPlayerInfoByGUID, GetTime = Ambiguate, bit.band, BNGetNumFriends, BNGetNumFriendGameAccounts, BNGetFriendGameAccountInfo, ChatTypeInfo, GetCurrencyLink, GetFriendInfo, GetGuildInfo, GetItemInfo, GetNumFriends, GetPlayerInfoByGUID, GetTime -- BLZ

local ECF = LibStub("AceAddon-3.0"):NewAddon("EnhancedChatFilter", "AceConsole-3.0")

--Bit Mask for blackword type
local regexBit, lesserBit = 1, 2

function ECF:MaskType(...) -- ... are boolean
	local ty = 0
	for idx, v in ipairs({...}) do
		if(v) then ty = ty + 2^(idx-1) end
	end
	return ty
end

function ECF:UnMaskType(ty) -- return boolean
	return band(ty,regexBit) ~= 0, band(ty,lesserBit) ~= 0
end

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
	}
}
--------------- Common Functions from Elsewhere ---------------
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
local function utf8replace(s, mapping)
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

--------------- Common Functions in ECF ---------------
--Make sure that blackWord won't be filtered by filterCharList and utf-8 list
local function checkBlacklist(blackWord, r)
	local newWord = blackWord:gsub("%s", ""):gsub(filterCharList, "")
	if (not r) then newWord=newWord:gsub(filterCharListRegex, "") end
	newWord = utf8replace(newWord, UTF8Symbols)
	if(newWord ~= blackWord or blackWord == "") then return true end -- Also report "" as invalid
end

local function SendMessage(event, msg)
	local info = ChatTypeInfo[strsub(event, 10)]
	for i = 1, NUM_CHAT_WINDOWS do
		local ChatFrames = _G["ChatFrame"..i]
		if (ChatFrames and ChatFrames:IsEventRegistered(event)) then
			ChatFrames:AddMessage(msg, info.r, info.g, info.b)
		end
	end
end

--Convert old config to new one
function ECF:convert()
	for key,v in pairs(config.blackWordList) do
		for key2 in pairs(config.blackWordList) do
			if key ~= key2 and strfind(key,key2) then config.blackWordList[key] = nil;break end
		end
		if(checkBlacklist(key,v.regex)) then config.blackWordList[key] = nil end
	end
end

--MinimapData
local ecfLDB = LibStub("LibDataBroker-1.1"):NewDataObject("Enhanced Chat Filter", {
	type = "data source",
	text = "Enhanced Chat Filter",
	icon = "Interface\\Icons\\Trade_Archaeology_Orc_BloodText",
	OnClick = function() ECF:EnhancedChatFilterOpen() end,
	OnTooltipShow = function(tooltip)
		tooltip:AddLine("|cffecf0f1Enhanced Chat Filter|r\n"..L["ClickToOpenConfig"])
	end
})
--Libstub for icon
local icon = LibStub("LibDBIcon-1.0")

--Initialize
function ECF:OnInitialize()
	ECF:RegisterChatCommand("ecf", "EnhancedChatFilterOpen")
	ECF:RegisterChatCommand("ecf-debug", "EnhancedChatFilterDebug")

	config = LibStub("AceDB-3.0"):New("ecfDB", defaults, "Default").profile
	icon:Register("Enhanced Chat Filter", ecfLDB, config.minimap)
	ECF:convert()
	ShowFriends()
end

--------------- Slash Command ---------------
--method run on /ecf
function ECF:EnhancedChatFilterOpen()
	if(InCombatLockdown()) then return end
	InterfaceOptionsFrame_OpenToCategory("EnhancedChatFilter")
end

--method run on /ecf-debug
function ECF:EnhancedChatFilterDebug()
	ECF:Print(config.debugMode and "Debug Mode Off!" or "Debug Mode On!")
	config.debugMode = not config.debugMode
end

--------------- Options ---------------
--These settings won't be saved
local highlightIsLesser, blackWordHighlight = false, ""
local lootHighlight = {}
local stringIO = "" -- blackWord input
local regexToggle, lesserToggle = false, false

local colorT = {} -- used in lootFilter
for i=0, 4 do
	colorT[i]=format("|c%s%s|r",select(4,GetItemQualityColor(i)),_G["ITEM_QUALITY"..i.."_DESC"])
end

function ECF:AddBlackWord(word, r, l)
	if (checkBlacklist(word, r)) then
		ECF:Printf(L["IncludeAutofilteredWord"],word)
	else
		config.blackWordList[word] = {regex = r, lesser = l,}
	end
end

local options = {
	type = "group",
	name = "EnhancedChatFilter "..GetAddOnMetadata("EnhancedChatFilter", "Version"),
	get = function(info) return config[info[#info]] end,
	set = function(info, value) config[info[#info]] = value end,
	disabled = function() return not config.enableFilter end,
	args = {
		enableFilter = {
			type = "toggle",
			name = L["MainFilter"],
			order = 1,
			disabled = false,
		},
		MinimapToggle = {
			type = "toggle",
			name = L["MinimapIcon"],
			get = function() return not config.minimap.hide end,
			set = function(_,toggle)
					config.minimap.hide = not toggle
					if(toggle) then icon:Show("Enhanced Chat Filter") else icon:Hide("Enhanced Chat Filter") end
				end,
			order = 2,
			disabled = false,
		},
		debugMode = {
			type = "toggle",
			name = "DebugMode",
			desc = "For test only",
			order = 3,
			hidden = function() return not config.advancedConfig end,
		},
		AdvancedWarning = {
			type = "execute",
			name = L["EnableAdvancedConfig"],
			confirm = true,
			confirmText = L["AdvancedWarningText"],
			func = function() config.advancedConfig = true end,
			hidden = function() return config.advancedConfig end,
			order = 9,
		},
		ToggleTab = {
			type = "group",
			name = L["General"],
			order = 10,
			args = {
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
					hidden = function() return not config.advancedConfig end,
				},
				line2 = {
					type = "header",
					name = L["RepeatOptions"],
					order = 40,
				},
				chatLinesLimit = {
					type = "range",
					name = L["chatLinesLimit"],
					desc = L["chatLinesLimitTooltips"],
					order = 41,
					min = 0,
					max = 100,
					step = 1,
					bigStep = 5,
				},
				multiLine = {
					type = "toggle",
					name = L["MultiLines"],
					desc = L["MultiLinesTooltip"],
					order = 42,
					disabled = function() return config.chatLinesLimit == 0 end,
				},
				repeatFilterGroup = {
					type = "toggle",
					name = L["AlsoFilterGroup"],
					desc = L["AlsoFilterGroupTooltips"],
					order = 43,
					disabled = function() return config.chatLinesLimit == 0 end,
				},
			},
		},
		blackListTab = {
			type = "group",
			name = L["BlackwordList"],
			order = 11,
			args = {
				blackword = {
					type = "input",
					name = L["AddBlackWordTitle"],
					order = 1,
					get = nil,
					set = function(_,value)
						ECF:AddBlackWord(value, regexToggle, lesserToggle)
					end,
					width = "full",
				},
				regexToggle = {
					type = "toggle",
					name = L["Regex"],
					desc = L["RegexTooltip"],
					get = function() return regexToggle end,
					set = function(_,value) regexToggle = value end,
					order = 2,
				},
				lesserToggle = {
					type = "toggle",
					name = L["LesserBlackWord"],
					desc = L["LesserBlackWordTooltip"],
					get = function() return lesserToggle end,
					set = function(_,value) lesserToggle = value end,
					order = 3,
					hidden = function() return not config.advancedConfig end,
				},
				line1 = {
					type = "header",
					name = _G["OPTIONS"],
					order = 10,
				},
				blackWordFilterGroup = {
					type = "toggle",
					name = L["AlsoFilterGroup"],
					desc = L["AlsoFilterGroupTooltips"],
					order = 11,
				},
				lesserBlackWordThreshold = {
					type = "range",
					name = L["LesserBlackWordThreshold"],
					desc = L["LesserBlackWordThresholdTooltips"],
					order = 12,
					min = 2,
					max = 5,
					step = 1,
					hidden = function() return not config.advancedConfig end,
				},
				line2 = {
					type = "header",
					name = L["StringIO"],
					order = 20,
				},
				stringconfig = {
					type = "input",
					name = "",
					order = 21,
					get = function() return stringIO end,
					set = function(_,value) stringIO = value end,
					width = "full",
				},
				import = {
					type = "execute",
					name = L["Import"],
					order = 22,
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
								if imTypeWord then ECF:AddBlackWord(imNewWord, ECF:UnMaskType(imTypeWord)) end
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
					order = 23,
					func = function()
						local blackStringList = {}
						for key,v in pairs(config.blackWordList) do
							local num = ECF:MaskType(v.regex, v.lesser)
							if (checkBlacklist(key, v.regex)) then
								ECF:Printf(L["IncludeAutofilteredWord"],key)
							else
								blackStringList[#blackStringList+1] = key..","..tostring(num)
							end
						end
						local blackString = tconcat(blackStringList,";")
						stringIO = blackString.."@"..StringHash(blackString)
					end,
				},
				line3 = {
					type = "header",
					name = "",
					order = 50,
				},
				blackWordList = {
					type = "select",
					name = L["BlackwordList"],
					order = 51,
					get = function() return highlightIsLesser and "" or blackWordHighlight end,
					set = function(_,value) highlightIsLesser, blackWordHighlight = false, value end,
					values = function()
						local blacklistname = {}
						for key,v in pairs(config.blackWordList) do if not v.lesser then blacklistname[key] = key end end
						return blacklistname
					end,
				},
				lesserBlackWordList = {
					type = "select",
					name = L["LesserBlackwordList"],
					order = 52,
					get = function() return highlightIsLesser and blackWordHighlight or "" end,
					set = function(_,value) highlightIsLesser, blackWordHighlight = true, value	end,
					values = function()
						local blacklistname = {}
						for key,v in pairs(config.blackWordList) do if v.lesser then blacklistname[key] = key end end
						return blacklistname
					end,
					hidden = function() return not config.advancedConfig end,
				},
				DeleteButton = {
					type = "execute",
					name = _G["REMOVE"],
					order = 53,
					func = function()
						config.blackWordList[blackWordHighlight] = nil
						blackWordHighlight = ""
					end,
					disabled = function() return blackWordHighlight == "" end,
				},
				ClearUpButton = {
					type = "execute",
					name = L["ClearUp"],
					order = 54,
					func = function() config.blackWordList, blackWordHighlight = {}, "" end,
					confirm = true,
					confirmText = format(L["DoYouWantToClear"],L["BlackList"]),
					disabled = function() return next(config.blackWordList) == nil end,
				},
			},
		},
		lootFilter = {
			type = "group",
			name = L["LootFilter"],
			order = 12,
			args = {
				addItem = {
					type = "input",
					name = L["AddItemWithID"],
					order = 1,
					get = nil,
					set = function(_,value)
						local Id = tonumber(value)
						if(config.lootType == "ITEMS") then
							if (Id == nil or GetItemInfo(Id) == nil) then -- TODO: If an item doesn't exist in cache, it reports as 'NotExists'(nil)
								ECF:Print(format("%s: ID=%d%s",_G[config.lootType],Id,L["NotExists"]))
							else
								config.lootItemFilterList[Id] = true
							end
						else
							if (Id == nil or GetCurrencyLink(Id) == nil) then
								ECF:Print(_G[config.lootType]..L["NotExists"])
							else
								config.lootCurrencyFilterList[Id] = true
							end
						end
					end,
				},
				lootType = {
					type = "select",
					name = _G["TYPE"],
					order = 2,
					values = {["ITEMS"] = _G["ITEMS"], ["CURRENCY"] = _G["CURRENCY"]},
				},
				DeleteButton = {
					type = "execute",
					name = _G["REMOVE"],
					order = 3,
					func = function()
						for key in pairs(lootHighlight) do
							if(key > 0) then
								config.lootItemFilterList[key] = nil
							else
								config.lootCurrencyFilterList[-key] = nil
							end
						end
						lootHighlight = {}
					end,
					disabled = function() return next(lootHighlight) == nil end,
				},
				ClearUpButton = {
					type = "execute",
					name = L["ClearUp"],
					order = 4,
					func = function() config.lootItemFilterList, config.lootCurrencyFilterList, lootHighlight = {}, {}, {} end,
					confirm = true,
					confirmText = format(L["DoYouWantToClear"],L["LootFilterList"]),
					disabled = function() return next(config.lootItemFilterList) == nil and next(config.lootCurrencyFilterList) == nil end,
				},
				LootFilterList = {
					type = "multiselect",
					name = L["LootFilterList"],
					order = 5,
					get = function(_,key) return lootHighlight[key] end,
					set = function(_,key,value) lootHighlight[key] = value or nil end,
					values = function()
						local lootFilterLinkList = {}
						for key in pairs(config.lootItemFilterList) do lootFilterLinkList[key] = select(2,GetItemInfo(key)) end
						for key in pairs(config.lootCurrencyFilterList) do lootFilterLinkList[-key] = GetCurrencyLink(key) end
						return lootFilterLinkList
					end,
				},
				line1 = {
					type = "header",
					name = "",
					order = 10,
				},
				lootQualityMin = {
					type = "select",
					name = L["LootQualityFilter"],
					desc = L["LootQualityFilterTooltips"],
					order = 11,
					values = colorT,
				},
			},
		},
	},
}
LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("EnhancedChatFilter", options)
LibStub("AceConfigDialog-3.0"):AddToBlizOptions("EnhancedChatFilter", "EnhancedChatFilter")

--Disable profanityFilter
if GetCVar("profanityFilter")~="0" then SetCVar("profanityFilter", "0") end

--------------- Filters ---------------
--Update friends whenever login/friendlist updates
local friends, allowWisper = {}, {}
local friendFrame = CreateFrame("Frame")
friendFrame:RegisterEvent("FRIENDLIST_UPDATE")
friendFrame:RegisterEvent("BN_FRIEND_INFO_CHANGED")
friendFrame:SetScript("OnEvent", function(self)
	friends = {}
	--Add WoW friends
	for i = 1, GetNumFriends() do
		local name = GetFriendInfo(i)
		if name then friends[Ambiguate(name, "none")] = true end
	end
	--And battlenet friends
	for i = 1, select(2, BNGetNumFriends()) do
		for j = 1, BNGetNumFriendGameAccounts(i) do
			local _, characterName, client, realmName = BNGetFriendGameAccountInfo(i, j)
			if (client == "WoW") then friends[Ambiguate(characterName.."-"..realmName, "none")] = true end
		end
	end
end)

--Add players you wispered into allowWisper list
local function addToAllowWisper(self,_,_,player)
	allowWisper[Ambiguate(player, "none")] = true
end
ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER_INFORM", addToAllowWisper)

--stringDifference for repeatFilter, ranged from 0 to 1, while 0 is absolutely the same
--This function is not utf8 awared, currently not nessesary
local function stringDifference(sA, sB) -- arrays of byte
	local len_a, len_b = #sA, #sB
	local last, this = {}, {}
	for j=0, len_b do last[j+1] = j end
	for i=1, len_a do
		this[1] = i
		for j=1, len_b do
			this[j+1] = (sA[i] == sB[j]) and last[j] or (min(last[j+1], this[j], last[j]) + 1)
		end
		for j=0, len_b do last[j+1]=this[j+1] end
	end
	return this[len_b+1]/max(len_a,len_b)
end

local chatLines = {}
local prevLineID = 0
local filterResult = false
local chatChannel = {["CHAT_MSG_WHISPER"] = 1, ["CHAT_MSG_SAY"] = 2, ["CHAT_MSG_YELL"] = 2, ["CHAT_MSG_CHANNEL"] = 3, ["CHAT_MSG_PARTY"] = 4, ["CHAT_MSG_PARTY_LEADER"] = 4, ["CHAT_MSG_RAID"] = 4, ["CHAT_MSG_RAID_LEADER"] = 4, ["CHAT_MSG_RAID_WARNING"] = 4, ["CHAT_MSG_INSTANCE_CHAT"] = 4, ["CHAT_MSG_INSTANCE_CHAT_LEADER"] = 4, ["CHAT_MSG_DND"] = 101}

local function ECFfilter(self,event,msg,player,_,_,_,flags,_,_,_,_,lineID)
	-- exit when main filter is off
	if(not config.enableFilter) then return end

	-- if it has been worked then use the worked result
	if(lineID == prevLineID) then
		return filterResult
	else
		prevLineID = lineID
		filterResult = false
	end

	local Event = chatChannel[event]
	local trimmedPlayer = Ambiguate(player, "none")
	-- don't filter player or his friends/BNfriends
	if UnitIsUnit(trimmedPlayer,"player") or friends[trimmedPlayer] then return end

	-- don't filter GM or DEV
	if type(flags) == "string" and (flags == "GM" or flags == "DEV") then return end

	if config.debugMode then print(format("RAWMsg: %s: %s",trimmedPlayer,msg)) end

	-- remove color/hypelink
	local filterString = msg:upper():gsub("|C[0-9A-F]+",""):gsub("|H[^|]+|H",""):gsub("|H|R","")
	local oriLen = #filterString
	-- remove utf-8 chars/raidicon/space/symbols
	filterString = utf8replace(filterString, UTF8Symbols):gsub("{RT%d}",""):gsub("%s", ""):gsub(filterCharList, "")
	local newfilterString = filterString:gsub(filterCharListRegex, "")
	local annoying = (oriLen - #newfilterString) / oriLen

	if(config.enableWisper and Event == 1) then --Whisper Whitelist Mode, only whisper
		--Don't filter players that are from same guild/raid/party or who you have whispered
		if not(allowWisper[trimmedPlayer] or (GetGuildInfo("player") == GetGuildInfo(trimmedPlayer)) or UnitInRaid(trimmedPlayer) or UnitInParty(trimmedPlayer)) then
			if config.debugMode then print("Trigger: WhiteListMode") end
			filterResult = true
			return true
		end
	end

	if(config.enableDND and ((Event <= 3 and type(flags) == "string" and flags == "DND") or Event == 101)) then -- DND, whisper/yell/say/channel and auto-reply
		if config.debugMode then print("Trigger: DND Filter") end
		filterResult = true
		return true
	end

	if(Event <= 3) then --AggressiveFilter
		if (config.enableAggressive and annoying >= 0.25 and annoying <= 0.8 and oriLen >= 30) then -- Annoying
			if config.debugMode then print("Trigger: Annoying: "..annoying) end
			filterResult = true
			return true
		end
	end

	if(Event <= (config.blackWordFilterGroup and 4 or 3)) then --blackWord Filter, whisper/yell/say/channel and party/raid(optional)
		local count = 0
		for keyWord,ty in pairs(config.blackWordList) do
			local currentString
			if (not ty.regex) then -- if it is not regex, filter most symbols
				keyWord = keyWord:upper()
				currentString = newfilterString
			else
				currentString = filterString
			end
			--Check blackList
			if (strfind(currentString,keyWord)) then
				if (ty.lesser) then count = count + 1
				else
					if config.debugMode then print("Trigger: Keyword: "..keyWord) end
					filterResult = true
					return true
				end
			end
		end
		if count >= config.lesserBlackWordThreshold then
			if config.debugMode then print("Trigger: LesserKeywords x"..count) end
			filterResult = true
			return true
		end
	end

	if (config.enableRAF and (Event <= 2 or Event == 4)) then -- raid
		for _,RaidAlertTag in ipairs(RaidAlertTagList) do
			if(strfind(msg,RaidAlertTag)) then
				if config.debugMode then print("Trigger: "..RaidAlertTag.." in RaidAlertTag") end
				filterResult = true
				return true
			end
		end
	end

	if (config.enableQRF and (Event <= 2 or Event == 4)) then -- quest/party
		for _,QuestReportTag in ipairs(QuestReportTagList) do
			if(strfind(msg,QuestReportTag)) then
				if config.debugMode then print("Trigger: "..QuestReportTag.." in QuestReportTag") end
				filterResult = true
				return true
			end
		end
	end

	if(config.chatLinesLimit > 0 and Event <= (config.repeatFilterGroup and 4 or 3)) then --Repeat Filter
		local msgLine = newfilterString
		if(msgLine == "") then msgLine = msg end --If it has only symbols, don't change it

		--msgdata
		local msgtable = {Sender = trimmedPlayer, Msg = {}, Time = GetTime()}
		for idx=1, #msgLine do msgtable.Msg[idx] = strbyte(msgLine,idx) end
		local chatLinesSize = #chatLines
		chatLines[chatLinesSize+1] = msgtable
		for i=1, chatLinesSize do
			--if there is not much difference between msgs, filter it
			--(optional) if someone sends msgs within 0.6s, filter it
			if (chatLines[i].Sender == msgtable.Sender and ((config.multiLine and (msgtable.Time - chatLines[i].Time) < 0.600) or stringDifference(chatLines[i].Msg,msgtable.Msg) <= 0.1)) then
				tremove(chatLines, i)
				if config.debugMode then print("Trigger: Repeat Filter") end
				filterResult = true
				return true
			end
		end
		if chatLinesSize >= config.chatLinesLimit then tremove(chatLines, 1) end
	end
end
for event in pairs(chatChannel) do ChatFrame_AddMessageEventFilter(event, ECFfilter) end

--MonsterSayFilter
local MSFOffQuestT = {[42880] = true} -- 42880: Meeting their Quota
local MSFOffQuestFlag = false

local QuestAf = CreateFrame("Frame")
QuestAf:RegisterEvent("QUEST_ACCEPTED")
QuestAf:SetScript("OnEvent", function(self,_,_,questId)
	if MSFOffQuestT[questId] then MSFOffQuestFlag = true end
end)

local QuestRf = CreateFrame("Frame")
QuestRf:RegisterEvent("QUEST_REMOVED") -- Fires when turn in or leave quest zone, but cant get questId when turn in
QuestRf:SetScript("OnEvent", function(self,_,questId)
	if MSFOffQuestT[questId] then MSFOffQuestFlag = false end
end)

local monsterLines = {}

local function monsterFilter(self,_,msg)
	if (not config.enableFilter or not config.enableMSF or MSFOffQuestFlag) then return end

	local monsterLinesSize = #monsterLines
	monsterLines[monsterLinesSize+1] = msg
	for i=1, monsterLinesSize do
		if (monsterLines[i] == msg) then
			tremove(monsterLines, i)
			if config.debugMode then print("Trigger: Monster Say Filter") end
			return true
		end
	end
	if monsterLinesSize >= 7 then tremove(monsterLines, 1) end
end
ChatFrame_AddMessageEventFilter("CHAT_MSG_MONSTER_SAY", monsterFilter)

--SpecSpellFilter
local SSFilterStrings = {
	(ERR_LEARN_ABILITY_S:gsub("%%s","(.*)")),
	(ERR_LEARN_SPELL_S:gsub("%%s","(.*)")),
	(ERR_SPELL_UNLEARNED_S:gsub("%%s","(.*)")),
	(ERR_LEARN_PASSIVE_S:gsub("%%s","(.*)")),
	(ERR_PET_SPELL_UNLEARNED_S:gsub("%%s","(.*)")),
	(ERR_PET_LEARN_ABILITY_S:gsub("%%s","(.*)")),
	(ERR_PET_LEARN_SPELL_S:gsub("%%s","(.*)")),
}
local function SSFilter(self,_,msg)
	if (not config.enableFilter or not config.enableDSS) then return end

	for _,s in ipairs(SSFilterStrings) do
		if strfind(msg, s) then return true end
	end
end
if (UnitLevel("player") == GetMaxPlayerLevel()) then ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", SSFilter) end

--AchievementFilter
local function SendAchievement(event, achievementID, players)
	local list = {}
	for name,class in pairs(players) do
		local color = (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[class]
		list[#list+1] = format("|cff%02x%02x%02x|Hplayer:%s|h%s|h|r", color.r*255, color.g*255, color.b*255, name, name)
	end
	SendMessage(event, format(L["GotAchievement"], tconcat(list, L["And"]), GetAchievementLink(achievementID)))
end

local function achievementReady(id, achievement)
	local area, guild = achievement.CHAT_MSG_ACHIEVEMENT, achievement.CHAT_MSG_GUILD_ACHIEVEMENT
	if (area and guild) then
		local myGuild = GetGuildInfo("player")
		for name in pairs(area) do
			if (UnitExists(name) and myGuild and myGuild == GetGuildInfo(name)) then
				guild[name], area[name] = area[name], nil
			end
		end
	end
	for event,players in pairs(achievement) do
		if type(players) == "table" and next(players) ~= nil then
			SendAchievement(event, id, players)
		end
	end
end

local achievements = {}
local achievementFrame = CreateFrame("Frame")
achievementFrame:Hide()
achievementFrame:SetScript("OnUpdate", function(self)
	local found = false
	for id, achievement in pairs(achievements) do
		if (achievement.timeout <= GetTime()) then
			achievementReady(id, achievement)
			achievements[id] = nil
		end
		found = true
	end
	if (not found) then self:Hide() end
end)

local function achievementFilter(self, event, msg, _, _, _, _, _, _, _, _, _, _, guid)
	if (not config.enableCFA or not config.enableFilter) then return end
	if (not guid or not strfind(guid,"Player")) then return end
	local achievementID = strmatch(msg, "achievement:(%d+)")
	if (not achievementID) then return end
	achievementID = tonumber(achievementID)
	local _,class,_,_,_,name,server = GetPlayerInfoByGUID(guid)
	if (not name) then return end -- check nil
	if (server ~= "" and server ~= GetRealmName()) then name = name.."-"..server end
	achievements[achievementID] = achievements[achievementID] or {timeout = GetTime() + 0.5}
	achievements[achievementID][event] = achievements[achievementID][event] or {}
	achievements[achievementID][event][name] = class
	achievementFrame:Show()
	return true
end
ChatFrame_AddMessageEventFilter("CHAT_MSG_ACHIEVEMENT", achievementFilter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_GUILD_ACHIEVEMENT", achievementFilter)

-- LootFilter
local function lootItemFilter(self,_,msg)
	if (not config.enableFilter) then return end
	local itemID = tonumber(strmatch(msg, "|Hitem:(%d+)"))
	if(not itemID) then return end -- pet cages don't have 'item'
	if(config.lootItemFilterList[itemID]) then return true end
	if(select(3,GetItemInfo(itemID)) < config.lootQualityMin) then return true end -- ItemQuality is in ascending order
end
ChatFrame_AddMessageEventFilter("CHAT_MSG_LOOT", lootItemFilter)

local function lootCurrecyFilter(self,_,msg)
	if (not config.enableFilter) then return end
	local currencyID = tonumber(strmatch(msg, "|Hcurrency:(%d+)"))
	if(config.lootCurrencyFilterList[currencyID]) then return true end
end
ChatFrame_AddMessageEventFilter("CHAT_MSG_CURRENCY", lootCurrecyFilter)
