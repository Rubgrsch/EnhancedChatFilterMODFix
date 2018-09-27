-- ECF
local _, ecf = ...
local C, L, G = unpack(ecf)

local _G = _G
-- Lua
local format, ipairs, max, min, next, pairs, select, tconcat, tonumber, tremove, twipe = format, ipairs, max, min, next, pairs, select, table.concat, tonumber, tremove, table.wipe
-- WoW
local Ambiguate, BNGetFriendGameAccountInfo, BNGetNumFriends, BNGetNumFriendGameAccounts, C_Timer_After, ChatTypeInfo, GetAchievementLink, GetFriendInfo, GetGuildInfo, GetItemInfo, GetNumFriends, GetPlayerInfoByGUID, GetTime, RAID_CLASS_COLORS, UnitExists, UnitInParty, UnitInRaid = Ambiguate, BNGetFriendGameAccountInfo, BNGetNumFriends, BNGetNumFriendGameAccounts, C_Timer.After, ChatTypeInfo, GetAchievementLink, GetFriendInfo, GetGuildInfo, GetItemInfo, GetNumFriends, GetPlayerInfoByGUID, GetTime, RAID_CLASS_COLORS, UnitExists, UnitInParty, UnitInRaid

-- GLOBALS: NUM_CHAT_WINDOWS

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
	['▲']='',['丨'] = '',['〡']='',
	['|']='',['@']='',['!']='',['/']='',['<']='',['>']='',['"']='',['`']='',['_']='',["'"]='',
	['#']='',['&']='',[';']='',[':']='',['~']='',['\\']='',['=']='',
	["\t"]='',["\n"]='',["\r"]='',[" "]='',
}
local RaidAlertTagList = {"%*%*.+%*%*", "EUI[:_]", "PS 死亡: .+>", "|Hspell.+ [=%-]> ", "受伤源自 |Hspell", "Fatality:.+> ", "已打断.*|Hspell", "打断→|Hspell", "打断：.+|Hspell", "成功打断>.+<的%-", "|Hspell.+>>"}
local QuestReportTagList = {"任务进度提示", "任务完成[%)%-]", "<大脚", "接受任务[%]:]", "进度:.+: %d+/%d+", "【爱不易】", "任务.*%[%d+%].+ 已完成!", "%[World Quest Tracker%]", "一起来做世界任务<"}
local iLvlTagList = {"<iLvl>", "^%-+$"}
local NormalTagList = {"<LFG>"}
local AggressiveTagList = {"|Hjournal"}
G.RegexCharList = "[().%%%+%-%*?%[%]$^{}]" -- won't work on regex blackWord, but works on others

-- utf8 functions are taken and modified from utf8replace from @Phanx @Pastamancer
-- replace UTF-8 characters based on a mapping table
local utf8tbl = {}
function G.utf8replace(s)
	local pos = 1
	twipe(utf8tbl)
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
		utf8tbl[#utf8tbl+1] = (mapping[c] or c)
		pos = pos + charbytes
	end

	return tconcat(utf8tbl)
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

--------------- Filters ---------------
--Update friends whenever login/friendlist updates
local friends = {}
local friendFrame = CreateFrame("Frame")
friendFrame:RegisterEvent("FRIENDLIST_UPDATE")
friendFrame:RegisterEvent("BN_FRIEND_INFO_CHANGED")
friendFrame:SetScript("OnEvent", function()
	twipe(friends)
	--Add WoW friends
	for i = 1, GetNumFriends() do
		local name = GetFriendInfo(i)
		if name then friends[Ambiguate(name, "none")] = true end
	end
	--And battlenet friends
	for i = 1, select(2, BNGetNumFriends()) do
		for j = 1, BNGetNumFriendGameAccounts(i) do
			local _, characterName, client, realmName = BNGetFriendGameAccountInfo(i, j)
			if client == "WoW" then friends[Ambiguate(characterName.."-"..realmName, "none")] = true end
		end
	end
end)

--strDiff for repeatFilter, ranged from 0 to 1, while 0 is absolutely the same
--This function is not utf8 awared, currently not nessesary
--strsub(s,i,i) is really SLOW. Don't use it.
local last, this = {}, {}
local function strDiff(sA, sB) -- arrays of byte
	local len_a, len_b = #sA, #sB
	twipe(last)
	twipe(this)
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

--Record how many times players are filterd
local playerCache = {}
setmetatable(playerCache, {__index=function() return 0 end})

local chatLines = {}
local chatChannel = {["CHAT_MSG_WHISPER"] = 1, ["CHAT_MSG_SAY"] = 2, ["CHAT_MSG_YELL"] = 2, ["CHAT_MSG_CHANNEL"] = 3, ["CHAT_MSG_EMOTE"] = 3, ["CHAT_MSG_PARTY"] = 4, ["CHAT_MSG_PARTY_LEADER"] = 4, ["CHAT_MSG_RAID"] = 4, ["CHAT_MSG_RAID_LEADER"] = 4, ["CHAT_MSG_RAID_WARNING"] = 4, ["CHAT_MSG_INSTANCE_CHAT"] = 4, ["CHAT_MSG_INSTANCE_CHAT_LEADER"] = 4, ["CHAT_MSG_DND"] = 101}

local function ECFfilter(Event,msg,player,flags,IsMyFriend,good)
	-- don't filter player/GM/DEV
	if player == playerName or flags == "GM" or flags == "DEV" then return end

	-- filter bad players
	if C.db.enableAggressive and not good and playerCache[player] >= 3 then return true end

	-- remove color/hypelink
	local filterString = msg:gsub("|H.-|h(.-)|h","%1"):gsub("|c%x%x%x%x%x%x%x%x",""):gsub("|r","")
	local oriLen = #filterString
	-- remove utf-8 chars/raidicon/space/symbols
	filterString = G.utf8replace(filterString):gsub("{rt%d}","")
	local msgLine = filterString:gsub(G.RegexCharList, ""):upper()
	local annoying = (oriLen - #msgLine) / oriLen

	--If it has only symbols, don't change it
	if msgLine == "" then msgLine = msg end

	--msgdata
	local msgtable = {player, {}, GetTime()}
	for idx=1, #msgLine do msgtable[2][idx] = msgLine:byte(idx) end

	-- DND, whisper/yell/say/channel and auto-reply
	if C.db.enableDND and ((Event <= 3 and flags == "DND") or Event == 101) and not IsMyFriend then return true end

	-- AggressiveFilter: Filter strings that has too much symbols
	-- AggressiveFilter: Filter AggressiveTags, currently only journal link
	if C.db.enableAggressive and Event <= 3 and not IsMyFriend then
		if annoying >= 0.25 and oriLen >= 30 then return true end
		for _,tag in ipairs(AggressiveTagList) do
			if msg:find(tag) then return true end
		end
	end

	--blackWord Filter, whisper/yell/say/channel and party/raid(optional)
	if Event <= (C.db.blackWordFilterGroup and 4 or 3) and not IsMyFriend then
		local count = 0
		for k,v in pairs(C.db.blackWordList) do
			if filterString:find(k) then
				if v.lesser then count = count + 1 else return true end
			end
		end
		if count >= C.db.lesserBlackWordThreshold then return true end
	end

	if Event <= 2 or Event == 4 then
		-- raidAlert
		if C.db.addonRAF then
			for _,tag in ipairs(RaidAlertTagList) do
				if msg:find(tag) then return true end
			end
		end
		-- iLvl Announcement
		if C.db.addonItemLvl then
			for _,tag in ipairs(iLvlTagList) do
				if msg:find(tag) then return true end
			end
		end
		-- questReport and partyAnnounce
		if C.db.addonQRF then
			for _,tag in ipairs(QuestReportTagList) do
				if msg:find(tag) then return true end
			end
		end
	end

	-- Fk LFG
	if Event == 1 then
		for _,tag in ipairs(NormalTagList) do
			if msg:find(tag) then return true end
		end
	end

	--Repeat Filter
	if C.db.enableRepeat and Event <= (C.db.repeatFilterGroup and 4 or 3) and not IsMyFriend then
		local chatLinesSize = #chatLines
		chatLines[chatLinesSize+1] = msgtable
		for i=1, chatLinesSize do
			--if there is not much difference between msgs, filter it
			--if multiple msgs in 0.6s, filter it (channel & emote only)
			if chatLines[i][1] == msgtable[1] and ((Event == 3 and msgtable[3] - chatLines[i][3] < 0.6) or strDiff(chatLines[i][2],msgtable[2]) <= 0.1) then
				tremove(chatLines, i)
				return true
			end
		end
		if chatLinesSize >= 30 then tremove(chatLines, 1) end
	end
end

local prevLineID, filterResult = 0, false
local function ECFfilterRecord(self,event,msg,player,_,_,_,flags,_,_,channelName,_,lineID)
	-- filter MeetingStone(NetEase) broad msg so it will not trigger any ECFfilters
	if channelName == "集合石" then return true end

	-- if it has been worked then use the worked result
	if lineID == prevLineID then return filterResult end
	prevLineID = lineID

	player = Ambiguate(player, "none")
	local IsMyFriend = friends[player]
	local good = IsMyFriend or GetGuildInfo("player") == GetGuildInfo(player) or UnitInRaid(player) or UnitInParty(player)
	filterResult = ECFfilter(chatChannel[event],msg,player,flags,IsMyFriend,good)

	if filterResult and not good then playerCache[player] = playerCache[player] + 1 end

	return filterResult
end
for event in pairs(chatChannel) do ChatFrame_AddMessageEventFilter(event, ECFfilterRecord) end

--MonsterSayFilter
--Turn off MSF in certain quests. Chat msg are repeated but important in these quests.
local MSFOffQuestT = {[42880] = true} -- 42880: Meeting their Quota
local MSFOffQuestFlag = false

--TODO: If player uses hearthstone to leave questzone, QUEST_REMOVED is not fired.
local Questf = CreateFrame("Frame")
Questf:RegisterEvent("QUEST_ACCEPTED")
Questf:RegisterEvent("QUEST_REMOVED")
Questf:SetScript("OnEvent", function(self,event,arg1,arg2)
	if event == "QUEST_ACCEPTED" and MSFOffQuestT[arg2] then MSFOffQuestFlag = true end
	if event == "QUEST_REMOVED" and MSFOffQuestT[arg1] then MSFOffQuestFlag = false end
end)

local MSL, MSLPos = {}, 1
local function monsterFilter(self,_,msg)
	if not C.db.enableMSF or MSFOffQuestFlag then return end

	for _, v in ipairs(MSL) do if v == msg then return true end end
	MSL[MSLPos] = msg
	MSLPos = MSLPos + 1
	if MSLPos > 7 then MSLPos = MSLPos - 7 end
end
ChatFrame_AddMessageEventFilter("CHAT_MSG_MONSTER_SAY", monsterFilter)

--SystemMessage
local SystemFilterTag = {
	(AZERITE_ISLANDS_XP_GAIN:gsub("%%.-s",".+"):gsub("%%.-d","%%d+")),
}
if UnitLevel("player") == GetMaxPlayerLevel() then
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

local function systemMsgFilter(self,_,msg)
	for _, s in ipairs(SystemFilterTag) do if msg:find(s) then return true end end
end
ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", systemMsgFilter)

--AchievementFilter
local achievements = {}
local function achievementReady(id)
	local area, guild = achievements[id].CHAT_MSG_ACHIEVEMENT, achievements[id].CHAT_MSG_GUILD_ACHIEVEMENT
	local myGuild = GetGuildInfo("player")
	if area and guild and myGuild then -- merge area to guild
		for name in pairs(area) do
			if UnitExists(name) and myGuild == GetGuildInfo(name) then
				guild[name], area[name] = area[name], nil
			end
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

local function achievementFilter(self, event, msg, _, _, _, _, _, _, _, _, _, _, guid)
	if not C.db.enableCFA then return end
	if not guid or not guid:find("Player") then return end
	local id = tonumber(msg:match("|Hachievement:(%d+)"))
	if not id then return end
	local _,class,_,_,_,name,server = GetPlayerInfoByGUID(guid)
	if not name then return end -- check nil
	if server ~= "" and server ~= playerServer then name = name.."-"..server end
	if not achievements[id] then
		achievements[id] = {}
		C_Timer_After(0.5, function() achievementReady(id) end)
	end
	achievements[id][event] = achievements[id][event] or {}
	achievements[id][event][name] = class
	return true
end
ChatFrame_AddMessageEventFilter("CHAT_MSG_ACHIEVEMENT", achievementFilter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_GUILD_ACHIEVEMENT", achievementFilter)

--LootFilter
local function lootItemFilter(self,_,msg)
	local itemID = tonumber(msg:match("|Hitem:(%d+)"))
	if not itemID then return end -- pet cages don't have 'item'
	if C.db.lootItemFilterList[itemID] then return true end
	if select(3,GetItemInfo(itemID)) < C.db.lootQualityMin then return true end -- ItemQuality is in ascending order
end
ChatFrame_AddMessageEventFilter("CHAT_MSG_LOOT", lootItemFilter)

local function lootCurrecyFilter(self,_,msg)
	local currencyID = tonumber(msg:match("|Hcurrency:(%d+)"))
	if C.db.lootCurrencyFilterList[currencyID] then return true end
end
ChatFrame_AddMessageEventFilter("CHAT_MSG_CURRENCY", lootCurrecyFilter)
