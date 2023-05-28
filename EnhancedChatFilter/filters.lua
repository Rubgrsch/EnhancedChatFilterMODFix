-- ECF
local _, ecf = ...
local B, L, C = unpack(ecf)

-- Lua
local _G = _G
local format, ipairs, max, min, pairs, tconcat, tonumber, tremove = format, ipairs, max, min, pairs, table.concat, tonumber, tremove
-- WoW
local Ambiguate, C_BattleNet_GetGameAccountInfoByGUID, C_Item_GetItemQualityByID, C_Timer_After, ChatTypeInfo, GetAchievementLink, GetPlayerInfoByGUID, GetTime, C_FriendList_IsFriend, IsGUIDInGroup, IsGuildMember, RAID_CLASS_COLORS = Ambiguate, C_BattleNet.GetGameAccountInfoByGUID, C_Item.GetItemQualityByID, C_Timer.After, ChatTypeInfo, GetAchievementLink, GetPlayerInfoByGUID, GetTime, C_FriendList.IsFriend, IsGUIDInGroup, IsGuildMember, RAID_CLASS_COLORS

local playerName, playerServer = GetUnitName("player"), GetRealmName()

-- Some UTF-8 symbols that will be auto-changed
local UTF8Symbols = {
	['１']='1',['２']='2',['３']='3',['４']='4',['５']='5',['６']='6',['７']='7',['８']='8',['９']='9',['０']='0',['⒈']='1',['⒉']='2',['⒊']='3',['⒋']='4',['⒌']='5',['⒍']='6',['⒎']='7',['⒏']='8',['⒐']='9',['①']='1',['②']='2',['③']='3',['④']='4',['⑤']='5',['⑥']='6',['⑦']='7',['⑧']='8',['⑨']='9',['⓪']='0',['Ａ']='A',['Ｂ']='B',['Ｃ']='C',['Ｄ']='D',['Ｅ']='E',['Ｆ']='F',['Ｇ']='G',['Ｈ']='H',['Ｉ']='I',['Ｊ']='J',['Ｋ']='K',['Ｌ']='L',['Ｍ']='M',['Ｎ']='N',['Ｏ']='O',['Ｐ']='P',['Ｑ']='Q',['Ｒ']='R',['Ｓ']='S',['Ｔ']='T',['Ｕ']='U',['Ｖ']='V',['Ｗ']='W',['Ｘ']='X',['Ｙ']='Y',['Ｚ']='Z',
	['·']='',['＠']='',['＃']='',['％']='',['／']='',['＆']='',['＊']='',['－']='',['＋']='',['｜']='',['～']='',['　']='',['，']='',['。']='',['、']='',['｛']='',['｝']='',['﹏']='',['？']='',['！']='',['：']='',['；']='',['￥']='',['＝']='',['—']='',['…']='',['‖']='',['【']='',['】']='',['『']='',['』']='',['《']='',['》']='',['（']='',['）']='',['〔']='',['〕']='',['〈']='',['〉']='',['＇']='',['＂']='',['’']='',['‘']='',['“']='',['”']='',['≈']='',['︾']='',['．']='',['∴']='',['灬']='',['━']='',['↑']='',['↓']='',['→']='',['←']='',['▲']='',['丨'] = '',['〡']='',['▇']='',['√']='',['↘']='',['↙']='',['★']='',['‐']='',
	['|']='',['@']='',['!']='',['/']='',['<']='',['>']='',['"']='',['`']='',['_']='',["'"]='',['#']='',['&']='',[';']='',[':']='',['~']='',['\\']='',['=']='',['\t']='',['\n']='',['\r']='',[' ']='',
}
local RaidAlertTagList = {"%*%*.+%*%*", "EUI[:_]", "PS 死亡:", "|Hspell.+[=>%- ]+> ", "受伤源自 |Hspell", "已打断.*|Hspell", "→.?|Hspell", "打断了.+|Hspell", "打断：.+|Hspell", "打断.+>.+<", "<iLvl>", "^%-+$", "<EH>", "<友情提示>", "挂了。%("}
local QuestReportTagList = {"任务进度提示", "任务完成[%)%-]", "<大脚", "接受任务[%]:%-]", "进度:.+: %d+/%d+", "任务.*%[%d+%].+ 已完成!", "接受任务：", "任务进度:"}
B.RegexCharList = "[().%%%+%-%*?%[%]$^{}]" -- won't work on regex blackWord, but works on others

-- utf8 functions are taken and modified from utf8replace from @Phanx @Pastamancer
-- replace UTF-8 characters based on a mapping table
function B.utf8replace(s)
	local pos, t = 1, {}
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
		c = mapping[c] or c
		if c ~= "" then t[#t+1] = c end
		pos = pos + charbytes
	end

	return tconcat(t)
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

-- strDiff() calculates Levenshtein Distance, ranged from 0 to 1, while 0 is absolutely the same.
-- sA and sB must be tables of bytes or chars, not whole msg strings.
-- This function is not utf8 awared, currently not nessesary.
-- This function dosen't support empty string "".
local last, this = {}, {}
local function strDiff(sA, sB)
	local len_a, len_b = #sA, #sB
	local last, this = last, this
	for j=0, len_b do last[j+1] = j end
	for i=1, len_a do
		this[1] = i
		for j=1, len_b do
			this[j+1] = (sA[i] == sB[j]) and last[j] or (min(last[j+1], this[j], last[j]) + 1)
		end
		last, this = this, last
	end
	return last[len_b+1]/max(len_a,len_b)
end

--------------- Filters ---------------
-- Blocked players: have been filtered many times
-- Record how many times players are filterd
local blockedPlayers, blockedMsgs = {}, {}
setmetatable(blockedPlayers, {__index=function() return 0 end})
setmetatable(blockedMsgs, {__index=function() return 0 end})
local initTime

-- Load DB
-- Blocked players data is stored per server. So we wont wipe other servers data.
local function LoadBlockedPlayers()
	initTime = GetTime()
	if not C.db.blockedPlayers[playerServer] then C.db.blockedPlayers[playerServer] = {} end
	for name,v in pairs(C.db.blockedPlayers[playerServer]) do
		blockedPlayers[name] = v
	end
	if not C.db.blockedMsgs[playerServer] then C.db.blockedMsgs[playerServer] = {} end
	for msg,v in pairs(C.db.blockedMsgs[playerServer]) do
		blockedMsgs[msg] = v
	end
end

-- Save DB when logout, at least 5min session is required
local function SaveBlockedPlayers()
	local playersDB = C.db.blockedPlayers[playerServer]
	local msgsDB = C.db.blockedMsgs[playerServer]
	local loginTime = GetTime() - initTime
	if loginTime > 300 then -- 5min
		for name,v in pairs(blockedPlayers) do
			local result = playersDB[name] or 0
			result = (v - result) * loginTime / 600 + result - 1
			if result > 0 then
				playersDB[name] = min(result,100)
			else
				playersDB[name] = nil
			end
		end
		for msg,v in pairs(blockedMsgs) do
			local result = msgsDB[msg] or 0
			result = (v - result) * loginTime / 600 + result - 1
			if result > 0 then
				msgsDB[msg] = min(result,100)
			else
				msgsDB[msg] = nil
			end
		end
	else
		for name,v in pairs(blockedPlayers) do if not playersDB[name] then playersDB[name] = v end end
		for msg,v in pairs(blockedMsgs) do if not msgsDB[msg] then msgsDB[msg] = v end end
	end
end
B:AddEventScript("PLAYER_LOGOUT", SaveBlockedPlayers)

-- Add reported players to blocked list
B:AddEventScript("PLAYER_REPORT_SUBMITTED", function(_,_,guid)
	local _,_,_,_,_,name,server = GetPlayerInfoByGUID(guid)
	if not name then return end -- check nil
	if server ~= "" and server ~= playerServer then name = name.."-"..server end
	blockedPlayers[name] = 20
end)

-- Languages that player understand
local availableLanguages = {
	[""] = true,
}

-- Chat Events
local chatLines = {}
local chatEvents = {["CHAT_MSG_WHISPER"] = 1, ["CHAT_MSG_SAY"] = 2, ["CHAT_MSG_YELL"] = 2, ["CHAT_MSG_EMOTE"] = 2, ["CHAT_MSG_TEXT_EMOTE"] = 2, ["CHAT_MSG_CHANNEL"] = 3, ["CHAT_MSG_PARTY"] = 4, ["CHAT_MSG_PARTY_LEADER"] = 4, ["CHAT_MSG_RAID"] = 4, ["CHAT_MSG_RAID_LEADER"] = 4, ["CHAT_MSG_RAID_WARNING"] = 4, ["CHAT_MSG_INSTANCE_CHAT"] = 4, ["CHAT_MSG_INSTANCE_CHAT_LEADER"] = 4, ["CHAT_MSG_DND"] = 5}

local function ECFfilter(Event,msg,player,flags,IsMyFriend,good)
	-- don't filter player/system/GM/DEV
	-- player == "" in local defense channel
	if player == playerName or player == "" or flags == "GM" or flags == "DEV" then return end

	-- remove color/hypelink
	local filterString = msg:gsub("|H.-|h(.-)|h","%1"):gsub("|A.-|a",""):gsub("|c%x%x%x%x%x%x%x%x",""):gsub("|r","")
	local oriLen = #filterString
	-- remove utf-8 chars/symbols/raidicon
	filterString = B.utf8replace(filterString):gsub("{rt%d}","")
	-- use upper to help repeatFilter, non-regex only
	local msgLine = filterString:gsub(B.RegexCharList, ""):upper()
	-- If it has only symbols, don't change it
	if msgLine == "" then msgLine = msg end
	local annoying = (oriLen - #msgLine) / oriLen

	local db = C.db
	-- AggressiveFilter:
	-- Filter blocked players and blocked msg
	-- Filter strings that has too much symbols
	-- Filter journal link and club link
	if db.enableAggressive and Event <= 3 and not good then
		if (blockedPlayers[player] >= 3 or blockedMsgs[msgLine] >= 3)
		or (annoying >= 0.25 and oriLen >= 30)
		or (msg:find("|Hjournal") or msg:find("|HclubTicket")) then return msgLine end
	end

	-- DND and auto-reply
	if db.enableDND and ((Event <= 3 and flags == "DND") or Event == 5) and not IsMyFriend then return msgLine end

	-- blackWord Filter
	if Event <= (db.blackWordFilterGroup and 4 or 3) and not IsMyFriend then
		local count = 0
		for k,v in pairs(db.blackWordList) do
			if (v.regex and filterString or msgLine):find(k) then
				if v.lesser then
					count = count + 1
				else
					if C.shouldEnableKeywordCleanup then
						v.count = (v.count or 0) + 1
						db.totalBlackWordsFiltered = db.totalBlackWordsFiltered + 1
					end
					return msgLine
				end
			end
		end
		if count >= db.lesserBlackWordThreshold then return msgLine end
	end

	-- raidAlert
	if db.addonRAF and (Event <= 2 or Event == 4) then
		for _,tag in ipairs(RaidAlertTagList) do
			if msg:find(tag) then return msgLine end
		end
	end
	-- questReport and partyAnnounce
	if db.addonQRF and (Event <= 2 or Event == 4) then
		for _,tag in ipairs(QuestReportTagList) do
			if msg:find(tag) then return msgLine end
		end
	end

	-- Repeat Filter
	if db.enableRepeat and (Event <= (db.repeatFilterGroup and 4 or 3)) and not IsMyFriend then
		local msgtable = {player, {}, GetTime()}
		for idx=1, #msgLine do msgtable[2][idx] = msgLine:byte(idx) end

		local chatLines = chatLines
		local chatLinesSize = #chatLines
		chatLines[chatLinesSize+1] = msgtable -- chatLinesSize is now actual_size-1
		for i=1, chatLinesSize do -- for every msg except the last
			local line = chatLines[i]
			-- if there is not much difference between msgs, filter it
			-- if multiple msgs in 0.6s, filter it (channel & emote only)
			if line[1] == msgtable[1] and ((Event == 3 and msgtable[3] - line[3] < 0.6) or strDiff(line[2],msgtable[2]) <= 0.1) then
				tremove(chatLines, i)
				return msgLine
			end
		end
		if chatLinesSize >= 30 then tremove(chatLines, 1) end
	end
end

local prevLineID, filterResult = 0, false
local function PreECFfilter(self,event,msg,player,language,_,_,flags,_,_,_,_,lineID,guid)
	-- With multiple chat tabs one msg can trigger filters multiple times and repeatFilter will return wrong result
	if lineID ~= prevLineID then
		prevLineID = lineID

		-- filter unknown languages
		if not availableLanguages[language] and C.db.enableLanguage then
			filterResult = true
			return true
		end

		player = Ambiguate(player, "none")
		local IsMyFriend, good
		if guid then
			IsMyFriend = C_BattleNet_GetGameAccountInfoByGUID(guid) or C_FriendList_IsFriend(guid)
			good = IsMyFriend or IsGuildMember(guid) or IsGUIDInGroup(guid)
		end
		local result = ECFfilter(chatEvents[event],msg,player,flags,IsMyFriend,good)
		filterResult = result

		if result and not good then
			blockedPlayers[player] = blockedPlayers[player] + 1
			blockedMsgs[result] = blockedMsgs[result] + 1
		end
	end
	return filterResult
end

-- MonsterSayFilter
-- Turn off MSF in certain quests. Chat msg are repeated but important in these quests.
local MSFOffQuestT = {[42880] = true, [54090]=true,} -- 42880: Meeting their Quota; 54090: Toys For Destruction
local MSFOffQuestFlag = false

--TODO: If player uses hearthstone to leave questzone, QUEST_REMOVED is not fired.
local function QuestChanged(self,event,questId)
	if MSFOffQuestT[questId] then MSFOffQuestFlag = event == "QUEST_ACCEPTED" end
end
B:AddEventScript("QUEST_ACCEPTED", QuestChanged)
B:AddEventScript("QUEST_REMOVED", QuestChanged)

local MSL, MSLPos, lastMSID, lastMSIDResult = {}, 1, nil, false
local function MonsterFilter(self,_,msg,_,_,_,_,_,_,_,_,_,lineID)
	if not C.db.enableMSF or MSFOffQuestFlag then return end
	if lineID ~= lastMSID then -- for multi chat tabs, check only once
		lastMSID = lineID

		for _, v in ipairs(MSL) do
			if v == msg then
				lastMSIDResult = true
				return true
			end
		end
		MSL[MSLPos] = msg
		MSLPos = MSLPos + 1
		if MSLPos > 7 then MSLPos = MSLPos - 7 end
		lastMSIDResult = false
	end
	return lastMSIDResult
end

-- System Message
local SystemFilterTag = {
	-- !!! Always add parentheses since gsub() has two return values !!! (xxx:gsub())
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

-- Achievement Filter
local achievements, achievementIdx = {}, {}
local function AchievementReady()
	local id = achievementIdx[1]
	local area, guild = {}, {}
	for guid,event in pairs(achievements[id]) do
		local _,class,_,_,_,name,server = GetPlayerInfoByGUID(guid)
		if name then
			if server ~= "" and server ~= playerServer then name = name.."-"..server end
			local s = format("|c%s|Hplayer:%s|h%s|h|r", RAID_CLASS_COLORS[class].colorStr, name, name)
			if event == "CHAT_MSG_ACHIEVEMENT" then
				area[#area+1] = s
			else
				guild[#guild+1] = s
			end
		end
	end
	if #area > 0 then SendMessage("CHAT_MSG_ACHIEVEMENT", format(L["GotAchievement"], tconcat(area, L["And"]), GetAchievementLink(id))) end
	if #guild > 0 then SendMessage("CHAT_MSG_GUILD_ACHIEVEMENT", format(L["GotAchievement"], tconcat(guild, L["And"]), GetAchievementLink(id))) end
	achievements[id] = nil
	tremove(achievementIdx, 1)
end

local function AchievementFilter(self, event, msg, _, _, _, _, _, _, _, _, _, _, guid)
	if not C.db.enableCFA or not guid or not guid:find("Player") then return end
	local id = tonumber(msg:match("|Hachievement:(%d+)"))
	if not id then return end
	if not achievements[id] then
		achievements[id] = {}
		achievementIdx[#achievementIdx+1] = id
		C_Timer_After(0.5, AchievementReady)
	end
	local stat = achievements[id][guid]
	if not stat or (stat == "CHAT_MSG_ACHIEVEMENT" and event == "CHAT_MSG_GUILD_ACHIEVEMENT") then achievements[id][guid] = event end
	return true
end

-- Loot Filter
local function lootItemFilter(self,_,msg)
	local itemID = tonumber(msg:match("|Hitem:(%d+)"))
	if not itemID then return end -- pet cages don't have 'item'
	if C.db.lootItemFilterList[itemID] then return true end
	if C_Item_GetItemQualityByID(itemID) < C.db.lootQualityMin then return true end
end

local function lootCurrecyFilter(self,_,msg)
	local currencyID = tonumber(msg:match("|Hcurrency:(%d+)"))
	if C.db.lootCurrencyFilterList[currencyID] then return true end
end

-- Invite blocker
B:AddEventScript("PARTY_INVITE_REQUEST", function(self, _, _, _, _, _, _, _, guid)
	if C.db.enableInvite and not (C_BattleNet_GetGameAccountInfoByGUID(guid) or C_FriendList_IsFriend(guid) or IsGuildMember(guid)) then
		DeclineGroup()
		StaticPopup_Hide("PARTY_INVITE")
	end
end)

B:AddEventScript("GROUP_INVITE_CONFIRMATION", function()
	if not C.db.enableInvite then return end
	local guid = GetNextPendingInviteConfirmation()
	if guid and not (C_BattleNet_GetGameAccountInfoByGUID(guid) or C_FriendList_IsFriend(guid) or IsGuildMember(guid)) then
		RespondToInviteConfirmation(guid, false)
		StaticPopup_Hide("GROUP_INVITE_CONFIRMATION")
	end
end)

-- init
B:AddInitScript(function()
	LoadBlockedPlayers()
	for i=1, GetNumLanguages() do availableLanguages[GetLanguageByIndex(i)] = true end
	-- Disable community invite
	SetCVar("showToastClubInvitation", C.db.enableCommunity and 0 or 1)
	-- In case db is not ready
	for event in pairs(chatEvents) do ChatFrame_AddMessageEventFilter(event, PreECFfilter) end
	ChatFrame_AddMessageEventFilter("CHAT_MSG_MONSTER_SAY", MonsterFilter)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_MONSTER_EMOTE", MonsterFilter)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", SystemMsgFilter)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_ACHIEVEMENT", AchievementFilter)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_GUILD_ACHIEVEMENT", AchievementFilter)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_LOOT", lootItemFilter)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_CURRENCY", lootCurrecyFilter)
end)
