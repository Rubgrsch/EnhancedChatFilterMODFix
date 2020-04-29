-- ECF
local _, ecf = ...
local B, L, C = unpack(ecf)

-- Lua
local _G = _G
local format, ipairs, max, min, next, pairs, tconcat, tonumber, tremove = format, ipairs, max, min, next, pairs, table.concat, tonumber, tremove
-- WoW
local Ambiguate, C_BattleNet_GetGameAccountInfoByGUID, C_Item_GetItemQualityByID, C_Timer_After, ChatTypeInfo, GetAchievementLink, GetPlayerInfoByGUID, GetTime, C_FriendList_IsFriend, IsGUIDInGroup, IsGuildMember, RAID_CLASS_COLORS = Ambiguate, C_BattleNet.GetGameAccountInfoByGUID, C_Item.GetItemQualityByID, C_Timer.After, ChatTypeInfo, GetAchievementLink, GetPlayerInfoByGUID, GetTime, C_FriendList.IsFriend, IsGUIDInGroup, IsGuildMember, RAID_CLASS_COLORS

local playerName, playerServer = GetUnitName("player"), GetRealmName()

-- Some UTF-8 symbols that will be auto-changed
local UTF8Symbols = {
	['１']='1',['２']='2',['３']='3',['４']='4',['５']='5',['６']='6',['７']='7',['８']='8',
	['９']='9',['０']='0',['⒈']='1',['⒉']='2',['⒊']='3',['⒋']='4',['⒌']='5',['⒍']='6',
	['⒎']='7',['⒏']='8',['⒐']='9',['Ａ']='A',['Ｂ']='B',['Ｃ']='C',['Ｄ']='D',['Ｅ']='E',
	['Ｆ']='F',['Ｇ']='G',['Ｈ']='H',['Ｉ']='I',['Ｊ']='J',['Ｋ']='K',['Ｌ']='L',['Ｍ']='M',
	['Ｎ']='N',['Ｏ']='O',['Ｐ']='P',['Ｑ']='Q',['Ｒ']='R',['Ｓ']='S',['Ｔ']='T',['Ｕ']='U',
	['Ｖ']='V',['Ｗ']='W',['Ｘ']='X',['Ｙ']='Y',['Ｚ']='Z',
	['·']='',['＠']='',['＃']='',['％']='',['／']='',['＆']='',['＊']='',['－']='',['＋']='',
	['｜']='',['～']='',['　']='',['，']='',['。']='',['、']='',['｛']='',['｝']='',['﹏']='',
	['？']='',['！']='',['：']='',['；']='',['￥']='',['＝']='',['—']='',['…']='',['‖']='',
	['【']='',['】']='',['『']='',['』']='',['《']='',['》']='',['（']='',['）']='',['〔']='',
	['〕']='',['〈']='',['〉']='',['＇']='',['＂']='',['’']='',['‘']='',['“']='',['”']='',
	['≈']='',['︾']='',['．']='',["∴"]='',['灬']='',['━']='',['↑']='',['↓']='',['→']='',['←']='',
	['▲']='',['丨'] = '',['〡']='',['▇']='',['√']='',
	['|']='',['@']='',['!']='',['/']='',['<']='',['>']='',['"']='',['`']='',['_']='',["'"]='',
	['#']='',['&']='',[';']='',[':']='',['~']='',['\\']='',['=']='',
	["\t"]='',["\n"]='',["\r"]='',[" "]='',
}
local RaidAlertTagList = {"%*%*.+%*%*", "EUI[:_]", "PS 死亡:", "|Hspell.+[=>%- ]+> ", "受伤源自 |Hspell", "已打断.*|Hspell", "→.?|Hspell", "打断：.+|Hspell", "打断.+>.+<", "<iLvl>", "^%-+$", "<EH>", "<友情提示>"}
local QuestReportTagList = {"任务进度提示", "任务完成[%)%-]", "<大脚", "接受任务[%]:%-]", "进度:.+: %d+/%d+", "【爱不易】", "【有爱插件】","任务.*%[%d+%].+ 已完成!"}
B.RegexCharList = "[().%%%+%-%*?%[%]$^{}]" -- won't work on regex blackWord, but works on others

-- utf8 functions are taken and modified from utf8replace from @Phanx @Pastamancer
-- replace UTF-8 characters based on a mapping table
function B.utf8replace(s)
	local pos, str = 1, ""
	local mapping = UTF8Symbols

	while pos <= #s do
		local b = s:byte(pos)
		local charbytes
		if b <= 127 then
			charbytes = 1
		elseif b <= 223 then
			charbytes = 2
		elseif b <= 239 then
			charbytes = 3
		else
			charbytes = 4
		end
		local c = s:sub(pos, pos + charbytes - 1)
		str = str..(mapping[c] or c)
		pos = pos + charbytes
	end

	return str
end

local function SendMessage(event, msg)
	local info = ChatTypeInfo[event:sub(10)]
	for i = 1, NUM_CHAT_WINDOWS do
		local ChatFrames = _G["ChatFrame"..i]
		if ChatFrames and ChatFrames:IsEventRegistered(event) then
			ChatFrames:AddMessage(msg, info.r, info.g, info.b)
		end
	end
end

-- strDiff for repeatFilter, ranged from 0 to 1, while 0 is absolutely the same
-- This function is not utf8 awared, currently not nessesary
-- This function dosen't support empty string "".
-- strsub(s,i,i) is really SLOW. Don't use it.
local last, this = {}, {}
local function strDiff(sA, sB) -- arrays of bytes
	local len_a, len_b = #sA, #sB
	local last, this = last, this
	for j=0, len_b do last[j+1] = j end
	for i=1, len_a do
		this[1] = i
		for j=1, len_b do
			this[j+1] = (sA[i] == sB[j]) and last[j] or (min(last[j+1], this[j], last[j]) + 1)
		end
		for j=1, len_b+1 do last[j]=this[j] end
	end
	return this[len_b+1]/max(len_a,len_b)
end

--------------- Filters ---------------
-- Blocked players: have been filtered many times
-- Record how many times players are filterd
local blockedPlayers = {}
setmetatable(blockedPlayers, {__index=function() return 0 end})

-- Load DB
local function LoadBlockedPlayers()
	if not C.db.blockedPlayers[playerServer] then C.db.blockedPlayers[playerServer] = {} end
	for name in pairs(C.db.blockedPlayers[playerServer]) do
		blockedPlayers[name] = 3
	end
end

-- Save DB when logout, at least 5min session is required
local function SaveBlockedPlayers()
	local serverDB = C.db.blockedPlayers[playerServer]
	for name,v in pairs(blockedPlayers) do
		if v > 3 then
			if not serverDB[name] then serverDB[name] = 1 -- add new players to DB
			elseif serverDB[name] < 5 then serverDB[name] = serverDB[name] + 1 end -- 5 times max
		end
	end
	for name,v in pairs(serverDB) do
		if blockedPlayers[name] <= 3 then
			-- if player is not shown in list then remove it from DB/decrease by 1
			serverDB[name] = v > 1 and v - 1 or nil
		end
	end
end
C_Timer_After(300, function() B:AddEventScript("PLAYER_LOGOUT", SaveBlockedPlayers) end)

-- Add reported players to blocked list
B:AddEventScript("PLAYER_REPORT_SUBMITTED", function(_,_,guid)
	local _,_,_,_,_,name,server = GetPlayerInfoByGUID(guid)
	if not name then return end -- check nil
	if server ~= "" and server ~= playerServer then name = name.."-"..server end
	blockedPlayers[name] = 4
	C.db.blockedPlayers[playerServer][name] = 3
end)

-- Chat Events
local chatLines = {}
local chatEvents = {["CHAT_MSG_WHISPER"] = 1, ["CHAT_MSG_SAY"] = 2, ["CHAT_MSG_YELL"] = 2, ["CHAT_MSG_EMOTE"] = 2, ["CHAT_MSG_TEXT_EMOTE"] = 2, ["CHAT_MSG_CHANNEL"] = 3, ["CHAT_MSG_PARTY"] = 4, ["CHAT_MSG_PARTY_LEADER"] = 4, ["CHAT_MSG_RAID"] = 4, ["CHAT_MSG_RAID_LEADER"] = 4, ["CHAT_MSG_RAID_WARNING"] = 4, ["CHAT_MSG_INSTANCE_CHAT"] = 4, ["CHAT_MSG_INSTANCE_CHAT_LEADER"] = 4, ["CHAT_MSG_DND"] = 5}

-- Store which type of channels enabled which filters, [eventIdx] = {filters}
local eventStatus = {
--	aggr, 	dnd,	black,	raid,	quest,	repeat
	{false,	false,	true,	false,	false,	false},
	{false,	false,	true,	false,	false,	false},
	{false,	false,	true,	false,	false,	false},
	{false,	false,	false,	false,	false,	false},
	{false,	false,	false,	false,	false,	false},
}

-- Config enabled filters, {filterIdx, {events}}
-- For each C.db.xxx enable filterIdx(column) -> events(row)
local optionFilters = {
	enableAggressive = {1, {1,2,3}},
	enableDND = {2, {1,2,3,5}},
	blackWordFilterGroup = {3, {4}},
	addonRAF = {4, {1,2,4}},
	addonQRF = {5, {1,2,4}},
	enableRepeat = {6, {1,2,3}},
	repeatFilterGroup = {6, {4}, "enableRepeat"},
}

function C:SetupEvent()
	for opt, v in pairs(optionFilters) do
		local status, filterIdx, meetRequested = C.db[opt], v[1], not v[3] or C.db[v[3]]
		for _, idx in ipairs(v[2]) do eventStatus[idx][filterIdx] = meetRequested and status end
	end
end

local function ECFfilter(Event,msg,player,flags,IsMyFriend,good)
	-- don't filter player/GM/DEV
	if player == playerName or flags == "GM" or flags == "DEV" then return end

	-- filter blocked players
	if not good and blockedPlayers[player] >= 3 then return true end

	-- remove color/hypelink
	local filterString = msg:gsub("|H.-|h(.-)|h","%1"):gsub("|c%x%x%x%x%x%x%x%x",""):gsub("|r","")
	local oriLen = #filterString
	-- remove utf-8 chars/symbols/raidicon
	filterString = B.utf8replace(filterString):gsub("{rt%d}","")
	-- use upper to help repeatFilter, non-regex only
	local msgLine = filterString:gsub(B.RegexCharList, ""):upper()
	-- If it has only symbols, don't change it
	if msgLine == "" then msgLine = msg end
	local annoying = (oriLen - #msgLine) / oriLen

	-- filter status for each channel
	local filtersStatus = eventStatus[Event]

	-- AggressiveFilter: Filter strings that has too much symbols
	-- AggressiveFilter: Filter journal link and club link
	if filtersStatus[1] and not IsMyFriend then
		if annoying >= 0.25 and oriLen >= 30 then return true end
		if msg:find("|Hjournal") or msg:find("|HclubTicket") then return true end
	end

	-- DND and auto-reply
	if filtersStatus[2] and (flags == "DND" or Event == 5) and not IsMyFriend then return true end

	-- blackWord Filter
	if filtersStatus[3] and not IsMyFriend then
		local count = 0
		for k,v in pairs(C.db.blackWordList) do
			if (v.regex and filterString or msgLine):find(k) then
				if v.lesser then
					count = count + 1
				else
					if C.shouldEnableKeywordCleanup then
						v.count = (v.count or 0) + 1
						C.db.totalBlackWordsFiltered = C.db.totalBlackWordsFiltered + 1
					end
					return true
				end
			end
		end
		if count >= C.db.lesserBlackWordThreshold then return true end
	end

	-- raidAlert
	if filtersStatus[4] then
		for _,tag in ipairs(RaidAlertTagList) do
			if msg:find(tag) then return true end
		end
	end
	-- questReport and partyAnnounce
	if filtersStatus[5] then
		for _,tag in ipairs(QuestReportTagList) do
			if msg:find(tag) then return true end
		end
	end

	-- Repeat Filter
	if filtersStatus[6] and not IsMyFriend then
		local msgtable = {player, {}, GetTime()}
		for idx=1, #msgLine do msgtable[2][idx] = msgLine:byte(idx) end

		local chatLines = chatLines
		local chatLinesSize = #chatLines
		chatLines[chatLinesSize+1] = msgtable
		for i=1, chatLinesSize do
			local line = chatLines[i]
			-- if there is not much difference between msgs, filter it
			-- if multiple msgs in 0.6s, filter it (channel & emote only)
			if line[1] == msgtable[1] and ((Event == 3 and msgtable[3] - line[3] < 0.6) or strDiff(line[2],msgtable[2]) <= 0.1) then
				tremove(chatLines, i)
				return true
			end
		end
		if chatLinesSize >= 30 then tremove(chatLines, 1) end
	end
end

local prevLineID, filterResult = 0, false
local function PreECFfilter(self,event,msg,player,_,_,_,flags,_,_,_,_,lineID,guid)
	-- With multiple chat tabs one msg can trigger filters multiple times and repeatFilter will return wrong result
	-- lineID returned by "CHAT_MSG_TEXT_EMOTE" is always 0
	if lineID == 0 or lineID ~= prevLineID then
		prevLineID = lineID

		player = Ambiguate(player, "none")
		local IsMyFriend, good
		if guid then
			IsMyFriend = C_BattleNet_GetGameAccountInfoByGUID(guid) or C_FriendList_IsFriend(guid)
			good = IsMyFriend or IsGuildMember(guid) or IsGUIDInGroup(guid)
		end
		filterResult = ECFfilter(chatEvents[event],msg,player,flags,IsMyFriend,good)

		if filterResult and not good then blockedPlayers[player] = blockedPlayers[player] + 1 end
	end
	return filterResult
end
for event in pairs(chatEvents) do ChatFrame_AddMessageEventFilter(event, PreECFfilter) end

-- MonsterSayFilter
-- Turn off MSF in certain quests. Chat msg are repeated but important in these quests.
local MSFOffQuestT = {[42880] = true, [54090]=true,} -- 42880: Meeting their Quota; 54090: Toys For Destruction
local MSFOffQuestFlag = false

--TODO: If player uses hearthstone to leave questzone, QUEST_REMOVED is not fired.
local function QuestChanged(self,event,arg1,arg2)
	if event == "QUEST_ACCEPTED" and MSFOffQuestT[arg2] then MSFOffQuestFlag = true end
	if event == "QUEST_REMOVED" and MSFOffQuestT[arg1] then MSFOffQuestFlag = false end
end
B:AddEventScript("QUEST_ACCEPTED", QuestChanged)
B:AddEventScript("QUEST_REMOVED", QuestChanged)

local MSL, MSLPos = {}, 1
local function MonsterFilter(self,_,msg)
	if not C.db.enableMSF or MSFOffQuestFlag then return end

	for _, v in ipairs(MSL) do if v == msg then return true end end
	MSL[MSLPos] = msg
	MSLPos = MSLPos + 1
	if MSLPos > 7 then MSLPos = MSLPos - 7 end
end
ChatFrame_AddMessageEventFilter("CHAT_MSG_MONSTER_SAY", MonsterFilter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_MONSTER_EMOTE", MonsterFilter)

-- System Message
local SystemFilterTag = {
	-- !!! Always add parentheses since gsub() has two return values !!!
	(AZERITE_ISLANDS_XP_GAIN:gsub("%%.-s",".+"):gsub("%%.-d","%%d+")), -- Azerite gain in islands
}
if UnitLevel("player") == GetMaxPlayerLevel() then -- spell learn, only when max level
	local SSFilterStrings = {
		(ERR_LEARN_ABILITY_S:gsub("%%s","(.*)")),
		(ERR_LEARN_SPELL_S:gsub("%%s","(.*)")),
		(ERR_SPELL_UNLEARNED_S:gsub("%%s","(.*)")),
		(ERR_LEARN_PASSIVE_S:gsub("%%s","(.*)")),
		(ERR_PET_SPELL_UNLEARNED_S:gsub("%%s","(.*)")),
		(ERR_PET_LEARN_ABILITY_S:gsub("%%s","(.*)")),
		(ERR_PET_LEARN_SPELL_S:gsub("%%s","(.*)")),
	}
	local i = #SystemFilterTag
	for j, s in ipairs(SSFilterStrings) do SystemFilterTag[i+j] = s end
end

local function SystemMsgFilter(self,_,msg)
	for _, s in ipairs(SystemFilterTag) do if msg:find(s) then return true end end
end
ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", SystemMsgFilter)

-- Achievement Filter
local achievements = {}
local function AchievementReady(id)
	local area, guild = achievements[id].CHAT_MSG_ACHIEVEMENT, achievements[id].CHAT_MSG_GUILD_ACHIEVEMENT
	if area and guild then -- merge area to guild
		for name in pairs(area) do
			if guild[name] then area[name] = nil end
		end
	end
	for event,players in pairs(achievements[id]) do
		if next(players) ~= nil then -- skip empty
			local list = {}
			for name,class in pairs(players) do
				list[#list+1] = format("|c%s|Hplayer:%s|h%s|h|r", RAID_CLASS_COLORS[class].colorStr, name, name)
			end
			SendMessage(event, format(L["GotAchievement"], tconcat(list, L["And"]), GetAchievementLink(id)))
		end
	end
	achievements[id] = nil
end

local function AchievementFilter(self, event, msg, _, _, _, _, _, _, _, _, _, _, guid)
	if not C.db.enableCFA or not guid or not guid:find("Player") then return end
	local id = tonumber(msg:match("|Hachievement:(%d+)"))
	if not id then return end
	local _,class,_,_,_,name,server = GetPlayerInfoByGUID(guid)
	if not name then return end -- check nil
	if server ~= "" and server ~= playerServer then name = name.."-"..server end
	if not achievements[id] then
		achievements[id] = {}
		C_Timer_After(0.5, function() AchievementReady(id) end)
	end
	achievements[id][event] = achievements[id][event] or {}
	achievements[id][event][name] = class
	return true
end
ChatFrame_AddMessageEventFilter("CHAT_MSG_ACHIEVEMENT", AchievementFilter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_GUILD_ACHIEVEMENT", AchievementFilter)

-- Loot Filter
local function lootItemFilter(self,_,msg)
	local itemID = tonumber(msg:match("|Hitem:(%d+)"))
	if not itemID then return end -- pet cages don't have 'item'
	if C.db.lootItemFilterList[itemID] then return true end
	if C_Item_GetItemQualityByID(itemID) < C.db.lootQualityMin then return true end
end
ChatFrame_AddMessageEventFilter("CHAT_MSG_LOOT", lootItemFilter)

local function lootCurrecyFilter(self,_,msg)
	local currencyID = tonumber(msg:match("|Hcurrency:(%d+)"))
	if C.db.lootCurrencyFilterList[currencyID] then return true end
end
ChatFrame_AddMessageEventFilter("CHAT_MSG_CURRENCY", lootCurrecyFilter)

-- Invite blocker
B:AddEventScript("PARTY_INVITE_REQUEST", function(self, _, _, _, _, _, _, _, guid)
	if C.db.enableInvite and not (C_BattleNet_GetGameAccountInfoByGUID(guid) or C_FriendList_IsFriend(guid) or IsGuildMember(guid)) then
		DeclineGroup()
		StaticPopup_Hide("PARTY_INVITE")
	end
end)

B:AddInitScript(LoadBlockedPlayers)
