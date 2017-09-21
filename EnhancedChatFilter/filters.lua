-- ECF
local _, ecf = ...
local AC, L, G = ecf.AC, ecf.L, ecf.G -- Aho-Corasick, locales, global variables

local _G = _G
-- Lua
local format, ipairs, max, min, next, pairs, rawset, select, tconcat, tonumber, tremove, type = format, ipairs, max, min, next, pairs, rawset, select, table.concat, tonumber, tremove, type
-- WoW
local Ambiguate, BNGetFriendGameAccountInfo, BNGetNumFriends, BNGetNumFriendGameAccounts, C_Timer_After, ChatTypeInfo, GetAchievementLink, GetFriendInfo, GetGuildInfo, GetItemInfo, GetNumFriends, GetPlayerInfoByGUID, GetRealmName, UnitExists, UnitInParty, UnitInRaid, UnitIsUnit = Ambiguate, BNGetFriendGameAccountInfo, BNGetNumFriends, BNGetNumFriendGameAccounts, C_Timer.After, ChatTypeInfo, GetAchievementLink, GetFriendInfo, GetGuildInfo, GetItemInfo, GetNumFriends, GetPlayerInfoByGUID, GetRealmName, UnitExists, UnitInParty, UnitInRaid, UnitIsUnit

-- GLOBALS: CUSTOM_CLASS_COLORS, NUM_CHAT_WINDOWS, RAID_CLASS_COLORS

-- Some UTF-8 symbols that will be auto-changed
G.UTF8Symbols = {
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
	['|']='',['@']='',['!']='',['/']='',['<']='',['>']='',['"']='',['`']='',['_']='',["'"]='',
	['#']='',['&']='',[';']='',[':']='',['~']='',['\\']='',['=']='',
}
local RaidAlertTagList = {"%*%*.+%*%*", "EUI:", "EUI_RaidCD", "PS 死亡: .+>", "|Hspell.+ [=%-]> ", "受伤源自 |Hspell.+ %(总计%): ", "Fatality:.+> ", "已打断.*|Hspell", "打断→|Hspell", "打断：.+|Hspell", "成功打断>.+<的%-"}  -- RaidAlert Tag
local QuestReportTagList = {"任务进度提示%s?[:：]", "%(任务完成%)", "<大脚组队提示>", "%[接受任务%]", "<大脚团队提示>", "进度:.+: %d+/%d+", "接受任务: ?%[%d+%]", "【网%.易%.有%.爱】", "任务.*%[%d+%].+ 已完成!"} -- QuestReport Tag
G.RegexCharList = "[%(%)%.%%%+%-%*%?%[%]%$%^{}]" -- won't work on regex blackWord, but works on others

local function SendMessage(event, msg)
	local info = ChatTypeInfo[event:sub(10)]
	for i = 1, NUM_CHAT_WINDOWS do
		local ChatFrames = _G["ChatFrame"..i]
		if (ChatFrames and ChatFrames:IsEventRegistered(event)) then
			ChatFrames:AddMessage(msg, info.r, info.g, info.b)
		end
	end
end

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
--strsub(s,i,i) is really SLOW. Don't use it.
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
local playerCache = {}
setmetatable(playerCache, {__index=function(self) return 0 end})

local chatLines = {}
local chatChannel = {["CHAT_MSG_WHISPER"] = 1, ["CHAT_MSG_SAY"] = 2, ["CHAT_MSG_YELL"] = 2, ["CHAT_MSG_CHANNEL"] = 3, ["CHAT_MSG_PARTY"] = 4, ["CHAT_MSG_PARTY_LEADER"] = 4, ["CHAT_MSG_RAID"] = 4, ["CHAT_MSG_RAID_LEADER"] = 4, ["CHAT_MSG_RAID_WARNING"] = 4, ["CHAT_MSG_INSTANCE_CHAT"] = 4, ["CHAT_MSG_INSTANCE_CHAT_LEADER"] = 4, ["CHAT_MSG_DND"] = 101}

local function ECFfilter(event,msg,player,flags,channelName,IsMyFriend,good)
	if ecf.db.enableAggressive and not good and playerCache[player] and playerCache[player] >= 3 then return true,"Bad Player" end

	local Event = chatChannel[event]

	-- filter MeetingStone(NetEase) broad msg
	if channelName == "集合石" and msg:find("^[#&$@]") then return true, "MeetingStone" end
	-- don't filter player or his friends/BNfriends
	if UnitIsUnit(player,"player") then return end

	-- don't filter GM or DEV
	if flags == "GM" or flags == "DEV" then return end

	-- remove color/hypelink
	local filterString = msg:gsub("|H[^|]+|h([^|]+)|h","%1"):gsub("|c%x%x%x%x%x%x%x%x",""):gsub("|r","")
	local oriLen = #filterString
	-- remove utf-8 chars/raidicon/space/symbols
	filterString = G.utf8replace(filterString, G.UTF8Symbols):gsub("{rt%d}",""):gsub("%s","")
	local newfilterString = filterString:gsub(G.RegexCharList, ""):upper()
	local annoying = (oriLen - #newfilterString) / oriLen

	local msgLine = newfilterString
	if(msgLine == "") then msgLine = msg end --If it has only symbols, don't change it

	--msgdata
	local msgtable = {player, {}}
	for idx=1, #msgLine do msgtable[2][idx] = msgLine:byte(idx) end

	if(ecf.db.enableWisper and Event == 1) then --Whisper Whitelist Mode, only whisper
		--Don't filter players that are from same guild/raid/party or who you have whispered
		if not(allowWisper[player] or good) then
			return true, "WhiteListMode"
		end
	end

	if(ecf.db.enableDND and ((Event <= 3 and flags == "DND") or Event == 101) and not IsMyFriend) then -- DND, whisper/yell/say/channel and auto-reply
		return true, "DND Filter"
	end

	if(ecf.db.enableAggressive and Event <= 3 and not IsMyFriend) then --AggressiveFilter
		if (annoying >= 0.25 and annoying <= 0.8 and oriLen >= 30) then -- Annoying
			return true, "Annoying: "..annoying
		end
	end

	if(Event <= (ecf.db.blackWordFilterGroup and 4 or 3) and not IsMyFriend) then --blackWord Filter, whisper/yell/say/channel and party/raid(optional)
		local count, keyWord = 0
		if AC.BuiltBlackWordTable then count, keyWord = AC:Match(msgtable[2],AC.BuiltBlackWordTable)
		else
			for k,v in pairs(ecf.db.normalWordsList) do
				if newfilterString:find(k,1,true) then
					if v.lesser then count = count + 1 else count, keyWord = -1, k;break end
				end
			end
		end
		if count ~= -1 then -- if no non-lesser word in normalBlackWordList matches
			for k,v in pairs(ecf.db.regexWordsList) do
				if filterString:find(k) then
					if v.lesser then count = count + 1 else count, keyWord = -1, k;break end
				end
			end
		end
		if count == -1 then return true, "Keyword: "..keyWord end
		if count >= ecf.db.lesserBlackWordThreshold then return true, "LesserKeywords x"..count end
	end

	if (ecf.db.enableRAF and (Event <= 2 or Event == 4)) then -- raid
		for _,RaidAlertTag in ipairs(RaidAlertTagList) do
			if msg:find(RaidAlertTag) then
				return true, RaidAlertTag.." in RaidAlertTag"
			end
		end
	end

	if (ecf.db.enableQRF and (Event <= 2 or Event == 4)) then -- quest/party
		for _,QuestReportTag in ipairs(QuestReportTagList) do
			if msg:find(QuestReportTag) then
				return true, QuestReportTag.." in QuestReportTag"
			end
		end
	end

	if(ecf.db.chatLinesLimit > 0 and Event <= (ecf.db.repeatFilterGroup and 4 or 3) and not IsMyFriend) then --Repeat Filter
		local chatLinesSize = #chatLines
		chatLines[chatLinesSize+1] = msgtable
		for i=1, chatLinesSize do
			--if there is not much difference between msgs, filter it
			if (chatLines[i][1] == msgtable[1] and stringDifference(chatLines[i][2],msgtable[2]) <= 0.1) then
				tremove(chatLines, i)
				return true, "Repeat Filter"
			end
		end
		if chatLinesSize >= ecf.db.chatLinesLimit then tremove(chatLines, 1) end
	end
end

local prevLineID, filterResult = 0, false
local function ECFfilterRecord(self,event,msg,player,_,_,_,flags,_,_,channelName,_,lineID)
	-- do nothing if main filter is off
	if(not ecf.db.enableFilter) then return end

	-- if it has been worked then use the worked result
	if(lineID == prevLineID) then
		return filterResult
	else
		prevLineID = lineID
		filterResult = false
	end

	player = Ambiguate(player, "none")
	local IsMyFriend, IsMyGuild, IsMyGroup = friends[player], GetGuildInfo("player") == GetGuildInfo(player), UnitInRaid(player) or UnitInParty(player)
	local good = IsMyFriend or IsMyGuild or IsMyGroup
	local result, reason = ECFfilter(event,msg,player,flags,channelName,IsMyFriend,good)
	filterResult = not not result

	if filterResult and not good then playerCache[player] = playerCache[player] + 1 end

	if ecf.db.debugMode then
		ecf.db.record[ecf.db.recordPos] = {event,msg,player,flags,filterResult,reason}
		ecf.db.recordPos = (ecf.db.recordPos >= 500 and ecf.db.recordPos - 500 or ecf.db.recordPos) + 1
	end

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

local monsterLines = {n=1}
setmetatable(monsterLines,{__newindex=function(self, _, v)
	rawset(self, self.n, v)
	self.n = self.n + 1
	if self.n > 7 then self.n = self.n - 7 end
end})
local function monsterFilter(self,_,msg)
	if (not ecf.db.enableFilter or not ecf.db.enableMSF or MSFOffQuestFlag) then return end

	for _, v in ipairs(monsterLines) do if (v == msg) then return true end end
	monsterLines[#monsterLines+1] = msg
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
	if (not ecf.db.enableFilter or not ecf.db.enableDSS) then return end

	for _,s in ipairs(SSFilterStrings) do if msg:find(s) then return true end end
end
if (UnitLevel("player") == GetMaxPlayerLevel()) then ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", SSFilter) end

--AchievementFilter
local achievements = {}
local function achievementReady(id)
	local area, guild = achievements[id].CHAT_MSG_ACHIEVEMENT, achievements[id].CHAT_MSG_GUILD_ACHIEVEMENT
	local myGuild = GetGuildInfo("player")
	if (area and guild and myGuild) then -- merge area to guild
		for name in pairs(area) do
			if (UnitExists(name) and myGuild == GetGuildInfo(name)) then
				guild[name], area[name] = area[name], nil
			end
		end
	end
	for event,players in pairs(achievements[id]) do
		if type(players) == "table" and next(players) ~= nil then -- skip empty
			local list = {}
			for name,class in pairs(players) do
				local color = (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[class]
				list[#list+1] = format("|cff%02x%02x%02x|Hplayer:%s|h%s|h|r", color.r*255, color.g*255, color.b*255, name, name)
			end
			SendMessage(event, format(L["GotAchievement"], tconcat(list, L["And"]), GetAchievementLink(id)))
		end
	end
	achievements[id] = nil
end

local function achievementFilter(self, event, msg, _, _, _, _, _, _, _, _, _, _, guid)
	if (not ecf.db.enableCFA or not ecf.db.enableFilter) then return end
	if (not guid or not guid:find("Player")) then return end
	local id = tonumber(msg:match("achievement:(%d+)"))
	if (not id) then return end
	local _,class,_,_,_,name,server = GetPlayerInfoByGUID(guid)
	if (not name) then return end -- check nil
	if (server ~= "" and server ~= GetRealmName()) then name = name.."-"..server end
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
	if (not ecf.db.enableFilter) then return end
	local itemID = tonumber(msg:match("|Hitem:(%d+)"))
	if(not itemID) then return end -- pet cages don't have 'item'
	if(ecf.db.lootItemFilterList[itemID]) then return true end
	if(select(3,GetItemInfo(itemID)) < ecf.db.lootQualityMin) then return true end -- ItemQuality is in ascending order
end
ChatFrame_AddMessageEventFilter("CHAT_MSG_LOOT", lootItemFilter)

local function lootCurrecyFilter(self,_,msg)
	if (not ecf.db.enableFilter) then return end
	local currencyID = tonumber(msg:match("|Hcurrency:(%d+)"))
	if(ecf.db.lootCurrencyFilterList[currencyID]) then return true end
end
ChatFrame_AddMessageEventFilter("CHAT_MSG_CURRENCY", lootCurrecyFilter)
