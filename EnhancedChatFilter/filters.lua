-- ECF
local _, ecf = ...
local L, G = ecf.L, ecf.G -- locales, global variables

local _G = _G
local select, ipairs, pairs, next, format, tonumber, strmatch, tconcat, strfind, strbyte = select, ipairs, pairs, next, format, tonumber, strmatch, table.concat, string.find, string.byte -- lua
local Ambiguate, BNGetNumFriends, BNGetNumFriendGameAccounts, BNGetFriendGameAccountInfo, GetFriendInfo, GetGuildInfo, GetItemInfo, GetNumFriends, GetPlayerInfoByGUID, GetTime = Ambiguate, BNGetNumFriends, BNGetNumFriendGameAccounts, BNGetFriendGameAccountInfo, GetFriendInfo, GetGuildInfo, GetItemInfo, GetNumFriends, GetPlayerInfoByGUID, GetTime -- BLZ

-- Some UTF-8 symbols that will be auto-changed
G.UTF8Symbols = {['·']='',['＠']='',['＃']='',['％']='',['／']='',['＆']='',['＊']='',
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
local RaidAlertTagList = {"%*%*.+%*%*", "EUI:.+施放了", "EUI:.+中断", "EUI:.+就绪", "EUI_RaidCD", "PS 死亡: .+>", "|Hspell.+ [=-]> ", "受伤源自 |Hspell.+ %(总计%): ", "Fatality:.+> ", "已打断.*|Hspell", "打断→%[.+%]"}  -- RaidAlert Tag
local QuestReportTagList = {"任务进度提示%s?[:：]", "%(任务完成%)", "<大脚组队提示>", "%[接受任务%]", "<大脚团队提示>", "进度:.+: %d+/%d+", "接受任务: ?%[%d+%]", "【网%.易%.有%.爱】", "任务: %[%d+%]%[.+%] 已完成!"} -- QuestReport Tag
G.filterCharList = "[|@!/<>\"`'_#&;:~\\]" -- work on any blackWord
G.filterCharListRegex = "[%(%)%.%%%+%-%*%?%[%]%$%^={}]" -- won't work on regex blackWord, but works on others

local function SendMessage(event, msg)
	local info = ChatTypeInfo[strsub(event, 10)]
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

local chatLines = {}
local chatChannel = {["CHAT_MSG_WHISPER"] = 1, ["CHAT_MSG_SAY"] = 2, ["CHAT_MSG_YELL"] = 2, ["CHAT_MSG_CHANNEL"] = 3, ["CHAT_MSG_PARTY"] = 4, ["CHAT_MSG_PARTY_LEADER"] = 4, ["CHAT_MSG_RAID"] = 4, ["CHAT_MSG_RAID_LEADER"] = 4, ["CHAT_MSG_RAID_WARNING"] = 4, ["CHAT_MSG_INSTANCE_CHAT"] = 4, ["CHAT_MSG_INSTANCE_CHAT_LEADER"] = 4, ["CHAT_MSG_DND"] = 101}

local function ECFfilter(event,msg,player,flags,channelName)
	local Event = chatChannel[event]

	-- filter MeetingStone(NetEase) broad msg
	if channelName == "集合石" and strfind(msg,"^[#&$@]") then return true, "MeetingStone" end

	local IsMyFriend, IsMyGuild, IsMyGroup = friends[player], GetGuildInfo("player") == GetGuildInfo(player), UnitInRaid(player) or UnitInParty(player)
	-- don't filter player or his friends/BNfriends
	if UnitIsUnit(player,"player") then return end

	-- don't filter GM or DEV
	if type(flags) == "string" and (flags == "GM" or flags == "DEV") then return end

	-- remove color/hypelink
	local filterString = msg:upper():gsub("|C[0-9A-F]+",""):gsub("|H[^|]+|H",""):gsub("|H|R","")
	local oriLen = #filterString
	-- remove utf-8 chars/raidicon/space/symbols
	filterString = G.utf8replace(filterString, G.UTF8Symbols):gsub("{RT%d}",""):gsub("%s", ""):gsub(G.filterCharList, "")
	local newfilterString = filterString:gsub(G.filterCharListRegex, "")
	local annoying = (oriLen - #newfilterString) / oriLen

	if(ecf.db.enableWisper and Event == 1) then --Whisper Whitelist Mode, only whisper
		--Don't filter players that are from same guild/raid/party or who you have whispered
		if not(allowWisper[player] or IsMyFriend or IsMyGuild or IsMyGroup) then
			return true, "WhiteListMode"
		end
	end

	if(ecf.db.enableDND and ((Event <= 3 and type(flags) == "string" and flags == "DND") or Event == 101)) then -- DND, whisper/yell/say/channel and auto-reply
		if not IsMyFriend then
			return true, "DND Filter"
		end
	end

	if(ecf.db.enableAggressive and Event <= 3) then --AggressiveFilter
		if not IsMyFriend then
			if (annoying >= 0.25 and annoying <= 0.8 and oriLen >= 30) then -- Annoying
				return true, "Annoying: "..annoying
			end
		end
	end

	if(Event <= (ecf.db.blackWordFilterGroup and 4 or 3) and not IsMyFriend) then --blackWord Filter, whisper/yell/say/channel and party/raid(optional)
		local count = 0
		for keyWord,ty in pairs(ecf.db.blackWordList) do
			--Check blackList
			if (strfind((not ty.regex) and newfilterString or filterString,keyWord)) then
				if (ty.lesser) then
					count = count + 1
				else
					return true, "Keyword: "..keyWord
				end
			end
		end
		if count >= ecf.db.lesserBlackWordThreshold then
			return true, "LesserKeywords x"..count
		end
	end

	if (ecf.db.enableRAF and (Event <= 2 or Event == 4)) then -- raid
		for _,RaidAlertTag in ipairs(RaidAlertTagList) do
			if(strfind(msg,RaidAlertTag)) then
				return true, RaidAlertTag.." in RaidAlertTag"
			end
		end
	end

	if (ecf.db.enableQRF and (Event <= 2 or Event == 4)) then -- quest/party
		for _,QuestReportTag in ipairs(QuestReportTagList) do
			if(strfind(msg,QuestReportTag)) then
				return true, QuestReportTag.." in QuestReportTag"
			end
		end
	end

	if(ecf.db.chatLinesLimit > 0 and Event <= (ecf.db.repeatFilterGroup and 4 or 3) and not IsMyFriend) then --Repeat Filter
		local msgLine = newfilterString
		if(msgLine == "") then msgLine = msg end --If it has only symbols, don't change it

		--msgdata
		local msgtable = {Sender = player, Msg = {}, Time = GetTime()}
		for idx=1, #msgLine do msgtable.Msg[idx] = strbyte(msgLine,idx) end
		local chatLinesSize = #chatLines
		chatLines[chatLinesSize+1] = msgtable
		for i=1, chatLinesSize do
			--if there is not much difference between msgs, filter it
			--(optional) if someone sends msgs within 0.6s, filter it
			if (chatLines[i].Sender == msgtable.Sender and ((ecf.db.multiLine and (msgtable.Time - chatLines[i].Time) < 0.600) or stringDifference(chatLines[i].Msg,msgtable.Msg) <= 0.1)) then
				tremove(chatLines, i)
				return true, "Repeat Filter"
			end
		end
		if chatLinesSize >= ecf.db.chatLinesLimit then tremove(chatLines, 1) end
	end
end

local prevLineID = 0
local filterResult = false
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

	local trimmedPlayer = Ambiguate(player, "none")
	local result, reason = ECFfilter(event,msg,trimmedPlayer,flags,channelName)
	filterResult = not not result

	if ecf.db.debugMode then
		ecf.db.record[ecf.db.recordPos] = {event,msg,trimmedPlayer,flags,filterResult,reason}
		ecf.db.recordPos = (ecf.db.recordPos >= 500 and ecf.db.recordPos - 500 or ecf.db.recordPos) + 1
	end

	return filterResult
end
for event in pairs(chatChannel) do ChatFrame_AddMessageEventFilter(event, ECFfilterRecord) end

--MonsterSayFilter
--Turn off MSF in certain quests. Chat msg are repeated but important in these quests.
local MSFOffQuestT = {[42880] = true} -- 42880: Meeting their Quota
local MSFOffQuestFlag = false

local QuestAf = CreateFrame("Frame")
QuestAf:RegisterEvent("QUEST_ACCEPTED")
QuestAf:SetScript("OnEvent", function(self,_,_,questId)
	if MSFOffQuestT[questId] then MSFOffQuestFlag = true end
end)

--TODO: If player uses hearthstone to leave questzone, QUEST_REMOVED is not fired.
local QuestRf = CreateFrame("Frame")
QuestRf:RegisterEvent("QUEST_REMOVED") -- Fires when turn in or leave quest zone, but cant get questId when turn in
QuestRf:SetScript("OnEvent", function(self,_,questId)
	if MSFOffQuestT[questId] then MSFOffQuestFlag = false end
end)

local monsterLines = {}

local function monsterFilter(self,_,msg)
	if (not ecf.db.enableFilter or not ecf.db.enableMSF or MSFOffQuestFlag) then return end

	local monsterLinesSize = #monsterLines
	monsterLines[monsterLinesSize+1] = msg
	for i=1, monsterLinesSize do
		if (monsterLines[i] == msg) then
			tremove(monsterLines, i)
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
	if (not ecf.db.enableFilter or not ecf.db.enableDSS) then return end

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
	if (not ecf.db.enableCFA or not ecf.db.enableFilter) then return end
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
	if (not ecf.db.enableFilter) then return end
	local itemID = tonumber(strmatch(msg, "|Hitem:(%d+)"))
	if(not itemID) then return end -- pet cages don't have 'item'
	if(ecf.db.lootItemFilterList[itemID]) then return true end
	if(select(3,GetItemInfo(itemID)) < ecf.db.lootQualityMin) then return true end -- ItemQuality is in ascending order
end
ChatFrame_AddMessageEventFilter("CHAT_MSG_LOOT", lootItemFilter)

local function lootCurrecyFilter(self,_,msg)
	if (not ecf.db.enableFilter) then return end
	local currencyID = tonumber(strmatch(msg, "|Hcurrency:(%d+)"))
	if(ecf.db.lootCurrencyFilterList[currencyID]) then return true end
end
ChatFrame_AddMessageEventFilter("CHAT_MSG_CURRENCY", lootCurrecyFilter)
