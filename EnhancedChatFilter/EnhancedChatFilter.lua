-- Some UTF-8 symbols that will be auto-changed
local UTF8Symbols = {['·']='',['＠']='',['＃']='',['％']='',
	['＆']='',['＊']='',['——']='',['＋']='',['｜']='',['～']='',['　']='',
	['，']='',['。']='',['、']='',['？']='',['！']='',['：']='',['；']='',
	['’']='',['‘']='',['“']='',['”']='',['【']='',['】']='',['『']='',
	['』']='',['《']='',['》']='',['（']='',['）']='',['￥']='',['＝']='',
	['…']='',['……']='',['１']='1',['２']='2',['３']='3',['４']='4',['５']='5',
	['６']='6',['７']='7',['８']='8',['９']='9',['０']='0',['⒈']='1',['⒉']='2',
	['⒊']='3',['⒋']='4',['⒌']='5',['⒍']='6',['⒎']='7',['⒏']='8',['⒐']='9',
	['Ａ']='A',['Ｂ']='B',['Ｃ']='C',['Ｄ']='D',['Ｅ']='E',['Ｆ']='F',['Ｇ']='G',['Ｈ']='H',
	['Ｉ']='I',['Ｊ']='J',['Ｋ']='K',['Ｌ']='L',['Ｍ']='M',['Ｎ']='N',['Ｏ']='O',['Ｐ']='P',
	['Ｑ']='Q',['Ｒ']='R',['Ｓ']='S',['Ｔ']='T',['Ｕ']='U',['Ｖ']='V',['Ｗ']='W',['Ｘ']='X',
	['Ｙ']='Y',['Ｚ']='Z',['〔']='',['〕']='',['〈']='',['〉']='',['‖']=''}
local RaidAlertTagList = {"%*%*.+%*%*", "EUI:.+施放了", "EUI:.+中断", "EUI:.+就绪", "EUI_RaidCD", "PS 死亡: .+>", "|Hspell.+ => ", "受伤源自 |Hspell.+ %(总计%): ", "Fatality:.+> %d"}  -- RaidAlert Tag
local QuestReportTagList = {"任务进度提示%s?[:：]", "%(任务完成%)", "<大脚组队提示>", "%[接受任务%]", "<大脚团队提示>", "进度:.+: %d+/%d+", "接受任务: ?%[%d+%]", "【网%.易%.有%.爱】"} -- QuestReport Tag
local filterCharList = "[|@!/<>\"`'_#&;:~\\]" -- work on any blackWord
local filterCharListRegex = "[%(%)%.%%%+%-%*%?%[%]%$%^={}]" -- won't work on regex blackWord, but works on others

-- ECF
local _, ecf = ...
local utf8replace = ecf.utf8replace -- utf8.lua
local L = ecf.L -- locales.lua

local config

local gsub, select, ipairs, tinsert, pairs, strsub, format, tonumber, strmatch, tconcat, strfind = gsub, select, ipairs, tinsert, pairs, strsub, format, tonumber, strmatch, table.concat, string.find -- lua
local GetItemInfo, GetCurrencyLink = GetItemInfo, GetCurrencyLink -- options
local Ambiguate, GetNumFriends = Ambiguate, GetNumFriends -- main filter
local ChatTypeInfo, GetPlayerInfoByGUID, GetGuildInfo, GetTime = ChatTypeInfo, GetPlayerInfoByGUID, GetGuildInfo, GetTime -- acievements

local EnhancedChatFilter = LibStub("AceAddon-3.0"):NewAddon("EnhancedChatFilter", "AceConsole-3.0", "AceEvent-3.0")

--Default Options
local defaults = {
	profile = {
		enableFilter = true, -- Main Filter
		enableWisper = false, -- Wisper WhiteMode
		enableDND = true, -- DND
		enableCFA = true, -- Achievement Filter
		enableRAF = false, -- RaidAlert Filter
		enableQRF = false, -- QuestReport and Group Filter
		enableIGM = false, -- IgnoreMore
		multiLine = false, -- MultiLines, in RepeatFilter
		blackWordList = {},
		blackWordFilterGroup = false, -- blackWord enabled in group and raid
		ignoreMoreList = {},
		lootItemFilterList = {[118043] = true, [71096] = true}, -- item list, [id] = true
		lootCurrencyFilterList = {[944] = true}, -- Currency list, [id] = true
		lootQualityMin = 0, -- loot quality filter, 0..4 = poor..epic
		minimap = {
			hide = false, -- minimap
		},
		advancedConfig = false, -- show advancedConfig
		chatLinesLimit = 20, -- in repeatFilter
		stringDifferenceLimit = 0.1, -- in repeatFilter
		debugMode = false,
	}
}

--------------- Common Functions in ECF ---------------
--Make sure that blackWord won't be filtered by filterCharList and utf-8 list
local function checkBlacklist(blackWord, typeModus)
	local newWord = blackWord:gsub("%s", ""):gsub(filterCharList, "")
	if (typeModus ~= "regex") then newWord=newWord:gsub(filterCharListRegex, "") end
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

--http://www.wowwiki.com/USERAPI_StringHash
local function StringHash(text)
	local counter = 1
	local len = string.len(text)
	for i = 1, len, 3 do
	counter = math.fmod(counter*8161, 4294967279) +  -- 2^32 - 17: Prime!
		(string.byte(text,i)*16776193) +
		((string.byte(text,i+1) or (len-i+256))*8372226) +
		((string.byte(text,i+2) or (len-i+256))*3932164)
	end
	return math.fmod(counter, 4294967291) -- 2^32 - 5: Prime (and different from the prime in the loop)
end

--Convert old config to new one
local function convert()
	if(config.blackList) then
		for _,v in ipairs(config.blackList) do config.blackWordList[v[1]] = v[2] or true end
		config.blackList = nil
	end
	for key,v in pairs(config.blackWordList) do
		if(checkBlacklist(key,v)) then config.blackWordList[key] = nil end
	end
	for idx,v in ipairs(config.ignoreMoreList) do config.ignoreMoreList[v], config.ignoreMoreList[idx] = true, nil end
end

--MinimapData
local ecfLDB = LibStub("LibDataBroker-1.1"):NewDataObject("Enhanced Chat Filter", {
	type = "data source",
	text = "Enhanced Chat Filter",
	icon = "Interface\\Icons\\Trade_Archaeology_Orc_BloodText",
	OnClick = function() EnhancedChatFilter:EnhancedChatFilterOpen() end,
	OnTooltipShow = function(tooltip)
		tooltip:AddLine("|cffecf0f1Enhanced Chat Filter|r\n"..L["ClickToOpenConfig"])
	end
})
--Libstub for icon
local icon = LibStub("LibDBIcon-1.0")

--Initialize
function EnhancedChatFilter:OnInitialize()
	EnhancedChatFilter:RegisterChatCommand("ecf", "EnhancedChatFilterOpen")
	EnhancedChatFilter:RegisterChatCommand("ecf-debug", "EnhancedChatFilterDebug")

	config = LibStub("AceDB-3.0"):New("ecfDB", defaults, "Default").profile
	icon:Register("Enhanced Chat Filter", ecfLDB, config.minimap)
	convert()
end

--------------- Slash Command ---------------
--method run on /ecf
function EnhancedChatFilter:EnhancedChatFilterOpen()
	if(InCombatLockdown()) then return end
	InterfaceOptionsFrame_OpenToCategory("EnhancedChatFilter")
end

--method run on /ecf-debug
function EnhancedChatFilter:EnhancedChatFilterDebug()
	EnhancedChatFilter:Print(config.debugMode and "Debug Mode Off!" or "Debug Mode On!")
	config.debugMode = not config.debugMode
end

--------------- Options ---------------
--These settings won't be saved
local scrollHighlight = {}
local lootHighlight = {}
local ignoreHighlight = {}
local regexToggle = false
local stringIO = "" -- blackWord input
local lootType = "Item" -- loot filter type

local options = {
	type = "group",
	name = "EnhancedChatFilter",
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
		ToggleTab = {
			type = "group",
			name = L["General"],
			order = 3,
			args = {
				line1 = {
					type = "header",
					name = L["Filters"],
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
					order = 13,
				},
				enableRAF = {
					type = "toggle",
					name = L["RaidAlert"],
					desc = L["RaidAlertFilterTooltip"],
					order = 14,
				},
				enableQRF = {
					type = "toggle",
					name = L["QuestReport"],
					desc = L["QuestReportFilterTooltip"],
					order = 15,
				},
				enableIGM = {
					type = "toggle",
					name = L["IgnoreMoreList"],
					order = 16,
				},
				line2 = {
					type = "header",
					name = L["RepeatOptions"],
					order = 20,
				},
				chatLinesLimit = {
					type = "range",
					name = L["chatLinesLimitSlider"],
					desc = L["chatLinesLimitSliderTooltips"],
					order = 21,
					min = 0,
					max = 100,
					step = 1,
					bigStep = 5,
				},
				stringDifferenceLimit = {
					type = "range",
					name = L["stringDifferenceLimitSlider"],
					desc = L["stringDifferenceLimitSliderTooltips"],
					order = 22,
					min = 0,
					max = 1,
					step = 0.01,
					bigStep = 0.1,
					isPercent = true,
					disabled = function() return config.chatLinesLimit == 0 end,
					hidden = function() return not config.advancedConfig end,
				},
				multiLine = {
					type = "toggle",
					name = L["MultiLines"],
					desc = L["MultiLinesTooltip"],
					order = 23,
					disabled = function() return config.chatLinesLimit == 0 end,
				},
				line3 = {
					type = "header",
					name = L["UseWithCare"],
					order = 30,
				},
				AdvancedWarning = {
					type = "execute",
					name = L["EnableAdvancedConfig"],
					confirm = true,
					confirmText = L["AdvancedWarningText"],
					func = function() config.advancedConfig = true end,
					hidden = function() return config.advancedConfig end,
					order = -1,
				},
				enableWisper = {
					type = "toggle",
					name = L["WhisperWhitelistMode"],
					desc = L["WhisperWhitelistModeTooltip"],
					order = 31,
					hidden = function() return not config.advancedConfig end,
				},
				debugMode = {
					type = "toggle",
					name = "DebugMode",
					desc = "For test only",
					order = 32,
					hidden = function() return not config.advancedConfig end,
				},
			},
		},
		blackListTab = {
			type = "group",
			name = L["BlackwordList"],
			order = 4,
			args = {
				blackword = {
					type = "input",
					name = L["AddBlackWordTitle"],
					order = 1,
					get = nil,
					set = function(_,value)
						if (checkBlacklist(value, regexToggle)) then
							EnhancedChatFilter:Printf(L["IncludeAutofilteredWord"],value)
						else
							config.blackWordList[value] = regexToggle or true
							scrollHighlight = {}
						end
					end,
				},
				regex = {
					type = "toggle",
					name = L["Regex"],
					desc = L["RegexTooltip"],
					order = 2,
					get = function() return regexToggle end,
					set = function(_,value) regexToggle = value and "regex" end,
				},
				DeleteButton = {
					type = "execute",
					name = L["Remove"],
					order = 3,
					func = function()
						for key in pairs(scrollHighlight) do config.blackWordList[key] = nil end
						scrollHighlight = {}
					end,
					disabled = function() return next(scrollHighlight) == nil end,
				},
				ClearUpButton = {
					type = "execute",
					name = L["ClearUp"],
					order = 4,
					func = function() config.blackWordList, scrollHighlight = {}, {} end,
					confirm = true,
					confirmText = format(L["DoYouWantToClear"],L["BlackList"]),
					disabled = function() return next(config.blackWordList) == nil end,
				},
				blackWordList = {
					type = "multiselect",
					name = L["BlackwordList"],
					order = 10,
					get = function(_,key) return scrollHighlight[key] end,
					set = function(_,key,value) scrollHighlight[key] = value or nil end,
					values = function()
						local blacklistname = {}
						for key in pairs(config.blackWordList) do blacklistname[key] = key end
						return blacklistname
					end,
				},
				line1 = {
					type = "header",
					name = L["Options"],
					order = 20,
				},
				blackWordFilterGroup = {
					type = "toggle",
					name = L["AlsoFilterGroup"],
					desc = L["AlsoFilterGroupTooltips"],
					order = 21,
				},
				line2 = {
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
					width = "double",
				},
				import = {
					type = "execute",
					name = L["Import"],
					order = 32,
					func = function()
						local wordString, HashString = strsplit("@", stringIO)
						if (tonumber(HashString) ~= tonumber(StringHash(wordString))) then
							EnhancedChatFilter:Print(L["StringHashMismatch"])
							return
						end
						local newBlackList = {strsplit(";", wordString)}
						for _, blacklist in ipairs(newBlackList) do
							if (blacklist ~= nil) then
								local imNewWord, imTypeWord = strsplit(",",blacklist)
								if (checkBlacklist(imNewWord, imTypeWord)) then
									EnhancedChatFilter:Printf(L["IncludeAutofilteredWord"],imNewWord)
								else
									config.blackWordList[imNewWord] = imTypeWord or true
								end
							end
						end
						stringIO = ""
						EnhancedChatFilter:Print(L["ImportSucceeded"])
					end,
					disabled = function() return stringIO == "" end,
				},
				export = {
					type = "execute",
					name = L["Export"],
					order = 33,
					func = function()
						local blackStringList = {}
						for key,v in pairs(config.blackWordList) do
							if (checkBlacklist(key, v)) then
								EnhancedChatFilter:Printf(L["IncludeAutofilteredWord"],key)
							else
								blackStringList[#blackStringList+1] = (v == true) and key or key..","..v
							end
						end
						local blackString = tconcat(blackStringList,";")
						stringIO = blackString.."@"..StringHash(blackString)
					end,
				},
			},
		},
		igoreMoreFilter = {
			type = "group",
			name = L["IgnoreMoreList"],
			order = 5,
			disabled = function() return not config.enableFilter or not config.enableIGM end,
			args = {
				DeleteButton = {
					type = "execute",
					name = L["Remove"],
					order = 1,
					func = function()
						for key in pairs(ignoreHighlight) do config.ignoreMoreList[key] = nil end
						ignoreHighlight = {}
					end,
					disabled = function() return next(ignoreHighlight) == nil end,
				},
				ClearUpButton = {
					type = "execute",
					name = L["ClearUp"],
					order = 2,
					func = function() config.ignoreMoreList, ignoreHighlight = {}, {} end,
					confirm = true,
					confirmText = format(L["DoYouWantToClear"],L["IgnoreMoreList"]),
					disabled = function() return next(config.ignoreMoreList) == nil end,
				},
				ignoreMoreList = {
					type = "multiselect",
					name = L["IgnoreMoreList"],
					order = 10,
					get = function(_,key) return ignoreHighlight[key] end,
					set = function(_,key,value) ignoreHighlight[key] = value or nil end,
					values = function()
						local ignoreNameList = {}
						for name in pairs(config.ignoreMoreList) do ignoreNameList[name] = name end
						return ignoreNameList
					end,
				},
			},
		},
		lootFilter = {
			type = "group",
			name = L["LootFilter"],
			order = 6,
			args = {
				addItem = {
					type = "input",
					name = L["AddItemWithID"],
					order = 1,
					get = nil,
					set = function(_,value)
						local Id = tonumber(value)
						if(lootType == "Item") then
							if (Id == nil or GetItemInfo(Id) == nil) then -- TODO: If an item doesn't exist in cache, it reports as 'NotExists'(nil)
								EnhancedChatFilter:Print(format("%s: ID=%d%s",L[lootType],Id,L["NotExists"]))
							else
								config.lootItemFilterList[Id] = true
							end
						else
							if (Id == nil or GetCurrencyLink(Id) == nil) then
								EnhancedChatFilter:Print(L[lootType]..L["NotExists"])
							else
								config.lootCurrencyFilterList[Id] = true
							end
						end
					end,
				},
				typedropdown = {
					type = "select",
					name = L["Type"],
					order = 2,
					values = {["Item"] = L["Item"], ["Currency"] = L["Currency"]},
					get = function() return lootType end,
					set = function(_,value) lootType = value end,
				},
				DeleteButton = {
					type = "execute",
					name = L["Remove"],
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
					values = {[0]=L["Poor"], [1]=L["Common"], [2]=L["Uncommon"], [3]=L["Rare"], [4]=L["Epic"]}
				},
			},
		},
		FAQTab = {
			type = "group",
			name = L["FAQ"],
			order = 7,
			args = {
				FAQText = {
					type = "description",
					name = L["FAQText"],
				},
			},
		},
	},
}
LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("EnhancedChatFilter", options)
LibStub("AceConfigDialog-3.0"):AddToBlizOptions("EnhancedChatFilter", "EnhancedChatFilter")

--Disable profanityFilter
local GetCVar,SetCVar = GetCVar,SetCVar

local profanityFilter=CreateFrame("Frame")
profanityFilter:SetScript("OnEvent", function()
	if GetCVar("profanityFilter")~="0" then SetCVar("profanityFilter", "0") end
end)
profanityFilter:RegisterEvent("VARIABLES_LOADED")
profanityFilter:RegisterEvent("CVAR_UPDATE")
profanityFilter:RegisterEvent("PLAYER_ENTERING_WORLD")
profanityFilter:RegisterEvent("BN_MATURE_LANGUAGE_FILTER")
profanityFilter:RegisterEvent("BN_CONNECTED")

-------------------------------------- Filters ------------------------------------
--IgnoreMore
local function ignoreMore(player)
	if (not config.enableIGM or not player) then return end
	local ignore = nil
	if GetNumIgnores() >= 50 then
		for i = 1, GetNumIgnores() do
			local name = GetIgnoreName(i)
			if (player == name) then
				ignore = true
				break
			end
		end
		if (not ignore) then
			local trimmedPlayer = Ambiguate(player, "none")
			tinsert(config.ignoreMoreList,{trimmedPlayer})
			if config.debugMode then print("Added to ECF ignoreMoreList!") end
			SendMessage("CHAT_MSG_SYSTEM", format(ERR_IGNORE_ADDED_S, trimmedPlayer))
		end
	end
end

hooksecurefunc("AddIgnore", ignoreMore)
hooksecurefunc("AddOrDelIgnore", ignoreMore)

--Update allowWisper list whenever login/friendlist updates
local login = nil
local allowWisper = {}
local ecfFrame = CreateFrame("Frame")
ecfFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
ecfFrame:RegisterEvent("FRIENDLIST_UPDATE")
ecfFrame:SetScript("OnEvent", function(self, event)
	if event == "PLAYER_ENTERING_WORLD" then
		ShowFriends() --friend list
	else
		if not login then --once per login
			login = true
			local num = GetNumFriends()
			for i = 1, num do
				local n = GetFriendInfo(i)
				if n then allowWisper[n] = true end -- added to allowWisper list
			end
			return
		end
	end
	if config.debugMode then for k in pairs(allowWisper) do print("ECF allowed: "..k) end end
end)

--Add players you wispered into allowWisper list
local function addToAllowWisper(self,_,_,player)
	local trimmedPlayer = Ambiguate(player, "none")
	allowWisper[trimmedPlayer] = true
end

--stringDifference for repeatFilter, ranged from 0 to 1, while 0 is absolutely the same
local function stringDifference(stringA, stringB)
	local len_a, len_b = #stringA, #stringB
	local templast, temp = {}, {}
	for j=0, len_b do templast[j+1] = j end
	for i=1, len_a do
		temp[1] = i
		for j=1, len_b do
			temp[j+1] = (stringA:sub(i,i) == stringB:sub(j,j)) and templast[j] or (min(templast[j+1], temp[j], templast[j]) + 1)
		end
		for j=0, len_b do templast[j+1]=temp[j+1] end
	end
	return temp[len_b+1]/(len_a+len_b)
end

local chatLines = {}
local prevLineID = 0
local filterResult = nil
local chatChannel = {["CHAT_MSG_WHISPER"] = 1, ["CHAT_MSG_SAY"] = 2, ["CHAT_MSG_CHANNEL"] = 3, ["CHAT_MSG_YELL"] = 3, ["CHAT_MSG_PARTY"] = 4, ["CHAT_MSG_PARTY_LEADER"] = 4, ["CHAT_MSG_RAID"] = 4, ["CHAT_MSG_RAID_LEADER"] = 4, ["CHAT_MSG_RAID_WARNING"] = 4, ["CHAT_MSG_INSTANCE_CHAT"] = 4,["CHAT_MSG_INSTANCE_CHAT_LEADER"] = 4, ["CHAT_MSG_DND"] = 101}

local function ECFfilter(self,event,msg,player,_,_,_,flags,_,_,_,_,lineID)
	-- exit when main filter is off
	if(not config.enableFilter) then return end

	-- don't filter player himself
	local trimmedPlayer = Ambiguate(player, "none")
	if UnitIsUnit(trimmedPlayer,"player") then return end

	-- if it's GM or DEV then exit
	if type(flags) == "string" and (flags == "GM" or flags == "DEV") then return end

	-- if it has been worked then use the last result
	if(lineID == prevLineID) then
		return filterResult
	else
		prevLineID = lineID
		filterResult = nil
	end

	if config.debugMode then print("RAWMsg: "..msg) end

	-- remove utf-8 chars
	local filterString = utf8replace(msg, UTF8Symbols)
	-- remove color/hypelink/space/symbols
	filterString = filterString:upper():gsub("|C[0-9A-F]+",""):gsub("|H[^|]+|H",""):gsub("|H|R",""):gsub("%s", ""):gsub(filterCharList, "")
	local newfilterString = filterString:gsub(filterCharListRegex, "")

	if(config.enableIGM and chatChannel[event] <= 1) then -- IgnoreMore, only whisper
		for _,ignorePlayer in ipairs(config.ignoreMoreList) do
			if (trimmedPlayer == ignorePlayer[1]) then
				if config.debugMode then print("Trigger: IgnoreMore Filter") end
				filterResult = true
				return true
			end
		end
	end

	if(config.enableWisper and chatChannel[event] <= 1) then --Whisper Whitelist Mode, only whisper
		ShowFriends()
		--Don't filter players that are from same guild/raid/party or friends
		if allowWisper[trimmedPlayer] or UnitIsInMyGuild(trimmedPlayer) or UnitInRaid(trimmedPlayer) or UnitInParty(trimmedPlayer) then return end
		--And battlenet friends
		for i = 1, select(2, BNGetNumFriends()) do
			local GameAccount = BNGetNumFriendGameAccounts(i)
			for j = 1, GameAccount do
				local _, rName, rGame = BNGetFriendGameAccountInfo(i, j)
				if (rName == trimmedPlayer and rGame == "WoW") then return end
			end
		end
		if config.debugMode then print("Trigger: WhiteListMode") end
		filterResult = true
		return true
	end

	if(config.enableDND and (chatChannel[event] <= 3 or chatChannel[event] == 101)) then -- DND, whisper/yell/say/channel and auto-reply
		if ((type(flags) == "string" and flags == "DND") or chatChannel[event] == 101) then
			if config.debugMode then print("Trigger: DND Filter") end
			filterResult = true
			return true
		end
	end

	if(chatChannel[event] <= (config.blackWordFilterGroup and 4 or 3)) then --blackWord Filter, whisper/yell/say/channel and party/raid(optional)
		for keyWord,v in pairs(config.blackWordList) do
			local currentString
			if (v ~= "regex") then -- if it is not regex, filter most symbols
				keyWord = keyWord:upper()
				currentString = newfilterString
			else
				currentString = filterString
			end
			--Check blackList
			if (strfind(currentString,keyWord)) then
				if config.debugMode then print("Trigger: Keyword: "..keyWord) end
				filterResult = true
				return true
			end
		end
	end

	if (config.enableRAF and (chatChannel[event] == 4 or chatChannel[event] == 2)) then -- raid
		for _,RaidAlertTag in ipairs(RaidAlertTagList) do
			if(strfind(msg,RaidAlertTag)) then
				if config.debugMode then print("Trigger: "..RaidAlertTag.." in RaidAlertTag") end
				filterResult = true
				return true
			end
		end
	end

	if (config.enableQRF and (chatChannel[event] == 4 or chatChannel[event] == 2)) then -- quest/party
		for _,QuestReportTag in ipairs(QuestReportTagList) do
			if(strfind(msg,QuestReportTag)) then
				if config.debugMode then print("Trigger: "..QuestReportTag.." in QuestReportTag") end
				filterResult = true
				return true
			end
		end
	end

	if(config.chatLinesLimit > 0 and chatChannel[event] <= 4) then --Repeat Filter
		local msgLine = newfilterString
		if(msgLine == "") then msgLine = msg end --If it has only symbols, then don't filter it

		--msgdata
		local msgtable = {Sender = trimmedPlayer, Msg = msgLine, Time = GetTime()}
		tinsert(chatLines, msgtable)
		for i=1, #chatLines-1 do
			--if there is not much difference between msgs, then filter it
			--(optional) if someone sends msgs within 0.6s ,then filter it
			if (chatLines[i].Sender == msgtable.Sender and ((config.multiLine and (msgtable.Time - chatLines[i].Time) < 0.600) or stringDifference(chatLines[i].Msg,msgtable.Msg) <= config.stringDifferenceLimit)) then
				tremove(chatLines, i)
				if config.debugMode then print("Trigger: Repeat Filter") end
				filterResult = true
				return true
			end
			if i >= config.chatLinesLimit then tremove(chatLines, 1) end
		end
	end
end

ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER_INFORM", addToAllowWisper)
ChatFrame_AddMessageEventFilter("CHAT_MSG_DND", ECFfilter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_SAY", ECFfilter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER", ECFfilter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL", ECFfilter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_YELL", ECFfilter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_PARTY", ECFfilter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_PARTY_LEADER", ECFfilter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID", ECFfilter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID_LEADER", ECFfilter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID_WARNING", ECFfilter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_INSTANCE_CHAT", ECFfilter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_INSTANCE_CHAT_LEADER", ECFfilter)

--AchievementFilter
local function SendAchievement(event, achievementID, players)
	local list = {}
	for name,guid in pairs(players) do
		local class, color, r, g, b
		if (strfind(guid,"Player")) then
			class = select(2, GetPlayerInfoByGUID(guid))
			color = (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[class]
		end
		if (not color) then
			local info = ChatTypeInfo[strsub(event, 10)]
			r, g, b = info.r, info.g, info.b
		else
			r, g, b = color.r, color.g, color.b
		end
		list[#list+1] = format("|cff%02x%02x%02x|Hplayer:%s|h%s|h|r", r*255, g*255, b*255, name, name)
	end
	SendMessage(event, format(L["GotAchievement"], tconcat(list, L["And"]), GetAchievementLink(achievementID)))
end

local function achievementReady(id, achievement)
	if (achievement.area and achievement.guild) then
		local playerGuild = GetGuildInfo("player")
		for name in pairs(achievement.area) do
			if (UnitExists(name) and playerGuild and playerGuild == GetGuildInfo(name)) then
				achievement.guild[name], achievement.area[name] = achievement.area[name], nil
			end
		end
	end
	if (achievement.area and next(achievement.area) ~= nil) then
		SendAchievement("CHAT_MSG_ACHIEVEMENT", id, achievement.area)
	end
	if (achievement.guild and next(achievement.guild) ~= nil) then
		SendAchievement("CHAT_MSG_GUILD_ACHIEVEMENT", id, achievement.guild)
	end
end

local achievements = {}
local achievementFrame = CreateFrame("Frame")
achievementFrame:Hide()
achievementFrame:SetScript("OnUpdate", function(self)
	local found
	for id, achievement in pairs(achievements) do
		if (achievement.timeout <= GetTime()) then
			achievementReady(id, achievement)
			achievements[id] = nil
		end
		found = true
	end
	if (not found) then self:Hide() end
end)

local function queueAchievementSpam(event, achievementID, name, guid)
	achievements[achievementID] = achievements[achievementID] or {timeout = GetTime() + 0.5}
	achievements[achievementID][event] = achievements[achievementID][event] or {}
	achievements[achievementID][event][name] = guid or true
	achievementFrame:Show()
end

local function achievementFilter(self, event, msg, _, _, _, _, _, _, _, _, _, _, guid)
	if (not config.enableCFA or not config.enableFilter) then return end
	if (not guid or not strfind(guid,"Player")) then return end
	local achievementID = strmatch(msg, "achievement:(%d+)")
	if (not achievementID) then return end
	achievementID = tonumber(achievementID)
	local Name,Server = select(6,GetPlayerInfoByGUID(guid))
	if (not Name) then return end -- GetPlayerInfoByGUID rarely returns nil for valid guid
	if (Server ~= "" and Server ~= GetRealmName()) then Name = Name.."-"..Server end
	queueAchievementSpam((event == "CHAT_MSG_GUILD_ACHIEVEMENT" and "guild" or "area"), achievementID, Name, guid)
	return true
end

ChatFrame_AddMessageEventFilter("CHAT_MSG_ACHIEVEMENT", achievementFilter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_GUILD_ACHIEVEMENT", achievementFilter)

-- LootFilter
local function lootitemfilter(self,_,msg)
	if (not config.enableFilter) then return end
	local itemID = tonumber(strmatch(msg, "|Hitem:(%d+)"))
	if(not itemID) then return end
	if(config.lootItemFilterList[itemID]) then return true end
	if(select(3,GetItemInfo(itemID)) < config.lootQualityMin) then return true end -- HACK: ItemQuality is in ascending order
end

ChatFrame_AddMessageEventFilter("CHAT_MSG_LOOT", lootitemfilter)

local function lootcurrecyfilter(self,_,msg)
	if (not config.enableFilter) then return end
	local currencyID = tonumber(strmatch(msg, "|Hcurrency:(%d+)"))
	if(config.lootCurrencyFilterList[currencyID]) then return true end
end

ChatFrame_AddMessageEventFilter("CHAT_MSG_CURRENCY", lootcurrecyfilter)
