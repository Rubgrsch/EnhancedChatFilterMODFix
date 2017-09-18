local _, ecf = ...
local L = ecf.L

local locale = GetLocale()
-----------------------------------------------------------------------
-- zhCN
-----------------------------------------------------------------------
if (locale == "zhCN") then
--Titles
	L["MainFilter"] = "总开关"
	L["MinimapIcon"] = "小地图图标"
--Minimap Tooltips
	L["ClickToOpenConfig"] = "点击打开配置界面"
--Common in tab
	L["ClearUp"] = "清空"
	L["DoYouWantToClear"] = "你确定要清空%s么？"
--General
	L["General"] = "常规"
	L["DND"] = "'忙碌'玩家"
	L["DNDfilterTooltip"] = "过滤'忙碌'玩家及其自动回复"
	L["Achievement"] = "成就刷屏"
	L["AchievementFilterTooltip"] = "合并显示多个玩家获得同一成就"
	L["RaidAlert"] = "团队警报"
	L["RaidAlertFilterTooltip"] = "过滤各类技能/打断喊话提示"
	L["QuestReport"] = "任务组队"
	L["QuestReportFilterTooltip"] = "过滤各类组队任务喊话提醒"
	L["SpecSpell"] = "天赋技能"
	L["SpecSpellFilterTooltip"] = "如果你已满级则过滤你及宠物的技能/天赋学习信息"
	L["MonsterSay"] = "怪物说话"
	L["MonsterSayFilterTooltip"] = "用一个重复过滤器减少聊天框内怪物说话的刷屏。这不会影响怪物施放技能时的喊话。"
	L["RepeatOptions"] = "重复信息设置"
	L["chatLinesLimit"] = "重复信息缓存行数"
	L["chatLinesLimitTooltips"] = "重复信息的行数设定。请根据聊天频道的聊天量调整数值。增加数值会提高内存占用。设为0以关闭重复过滤。默认值20。"
	L["RepeatFilter"] = "重复过滤器"
	L["RepeatFilterTooltips"] = "过滤内容相近的信息"
	L["FilterGroup"] = "过滤小队团队"
	L["FilterGroupTooltips"] = "启用后过滤器也会过滤小队团队中的消息，你可能因此错过有用的信息"
	L["DisplayAdvancedConfig"] = "显示高级选项"
	L["DisplayAdvancedConfigTooltips"] = "显示更多更复杂的选项。|n如果你是正常人请不要接受，不然你很有可能会把ECF玩坏！如果你同意你不是正常人的话请继续..."
	L["WhisperWhitelistMode"] = "密语白名单模式"
	L["WhisperWhitelistModeTooltip"] = "除了工会、团队、小队、好友发送的密语外，只允许你发送过密语的对方才能对你发起密语|n|cffE2252D慎用！"
	L["Aggressive"] = "额外过滤器"
	L["AggressiveTooltip"] = "一些会极大提高过滤效果和|cffE2252D误伤机率|r的过滤器集合"
--BlackwordFilter
	L["BlackwordFilter"] = "关键词过滤"
	L["BlackwordList"] = "黑名单关键词列表"
	L["AddBlackWordTitle"] = "添加新黑名单关键词"
	L["IncludeAutofilteredWord"] = "%s包含会被自动过滤的字符，将忽略该关键词！"
	L["Regex"] = "正则"
	L["RegexTooltip"] = "标记添加的关键词为正则表达式，仅对该次添加的关键词有效"
	L["LesserBlackWord"] = "次级关键词"
	L["LesserBlackWordTooltip"] = "标记添加的关键词为次级关键词，仅对该次添加的关键词有效|n当一个信息匹配多个次级关键词时才会被屏蔽。|n|n你应该只在添加那些日常交流会用到，但你希望屏蔽的对方会大量同时使用的词汇时勾选。|n下列情况不建议勾选：各种利用异体字/同音字防屏蔽的词汇、单个汉字。"
	L["LesserBlackwordList"] = "次级黑名单关键词"
	L["LesserBlackWordThreshold"] = "次级关键词阈值"
	L["LesserBlackWordThresholdTooltips"] = "过滤包含至少阈值数目的次级关键词的信息"
	L["BlackList"] = "关键词列表"
	L["StringIO"] = "字符串导入导出"
	L["StringHashMismatch"] = "字符串校验错误"
	L["Export"] = "导出"
--LootFilter
	L["LootFilter"] = "拾取过滤器"
	L["AddItemWithID"] = "添加ID"
	L["BadID"] = "错误的ID"
	L["ItemFilterList"] = "物品屏蔽列表"
	L["CurrencyFilterList"] = "货币屏蔽列表"
	L["LootQualityFilter"] = "拾取物品质量"
	L["LootQualityFilterTooltips"] = "显示拾取物品所需要的最低质量，低于此质量的物品将被过滤"
--AchievementFilter
	L["GotAchievement"] = "[%s]获得了成就%s！"
	L["And"] = "、"
--Record
	L["RecordWindow"] = "聊天记录"
	L["ChatRecord"] = "开启聊天记录"
	L["ChatRecordTooltips"] = "开启后将记录系统信息以外的聊天信息，并可以查看哪些信息被过滤"
	L["ClearRecord"] = "清除聊天记录"
	L["ShowAll"] = "全部显示"
	L["OnlyFiltered"] = "仅过滤"
	L["OnlyUnfiltered"] = "仅未过滤"
--Error
	L["DBOutOfDate"] = "你的配置文件太旧了！你的配置文件版本:%d，插件最低兼容版本:%d"

-----------------------------------------------------------------------
-- zhTW -- NEED HELP
-- Contributors: 老虎007@NGA
-----------------------------------------------------------------------
elseif (locale == "zhTW") then
--Titles
	L["MainFilter"] = "總開關"
	L["MinimapIcon"] = "小地圖圖標"
--Minimap Tooltips
	L["ClickToOpenConfig"] = "點擊打開配置介面"
--Common in tab
	L["ClearUp"] = "清空"
	L["DoYouWantToClear"] = "你确定要清空%s么？"
--General
	L["General"] = "常规"
	L["DND"] = "'忙碌'玩家"
	L["DNDfilterTooltip"] = "过滤'忙碌'玩家及其自动回复"
	L["Achievement"] = "成就刷屏"
	L["AchievementFilterTooltip"] = "合并显示多个玩家获得同一成就"
	L["RaidAlert"] = "團隊警報"
	L["RaidAlertFilterTooltip"] = "过滤各类技能/打断喊话提示"
	L["QuestReport"] = "任務組隊"
	L["QuestReportFilterTooltip"] = "过滤各类组队任务喊话提醒"
	L["SpecSpell"] = "天赋技能"
	L["SpecSpellFilterTooltip"] = "如果你已满级则过滤你及宠物的技能/天赋学习信息"
	L["MonsterSay"] = "怪物说话"
	L["MonsterSayFilterTooltip"] = "用一个重复过滤器减少聊天框内怪物说话的刷屏。这不会影响怪物施放技能时的喊话。"
	L["RepeatOptions"] = "重复信息设置"
	L["chatLinesLimit"] = "重复信息缓存行数"
	L["chatLinesLimitTooltips"] = "重复信息的行数设定。请根据聊天频道的聊天量调整数值。增加数值会提高内存占用。设为0以关闭重复过滤。默认值20"
	L["RepeatFilter"] = "重复过滤器"
	L["RepeatFilterTooltips"] = "过滤内容相近的信息"
	L["FilterGroup"] = "过滤小队团队"
	L["FilterGroupTooltips"] = "启用后过滤器也会过滤小队团队中的消息，你可能因此错过有用的信息"
	L["DisplayAdvancedConfig"] = "显示高级选项"
	L["DisplayAdvancedConfigTooltips"] = "显示更多更复杂的选项。|n如果你是正常人请不要接受，不然你很有可能会把ECF玩坏！如果你同意你不是正常人的话请继续..."
	L["WhisperWhitelistMode"] = "密語白名單模式"
	L["WhisperWhitelistModeTooltip"] = "除了工会、团队、小队、好友发送的密语外，只允许你发送过密语的对方才能对你发起密语|n|cffE2252D慎用！"
	L["Aggressive"] = "额外过滤器"
	L["AggressiveTooltip"] = "一些会极大提高过滤效果和|cffE2252D误伤机率|r的过滤器集合"
--BlackwordFilter
	L["BlackwordFilter"] = "关键词过滤"
	L["BlackwordList"] = "黑名单关键词列表"
	L["AddBlackWordTitle"] = "添加新黑名單關鍵詞"
	L["IncludeAutofilteredWord"] = "%s包含會被自動過濾的字符，蔣忽略該關鍵詞！"
	L["Regex"] = "正規"
	L["RegexTooltip"] = "标记添加的关键词为正则表达式|n仅对该次添加的关键词有效"
	L["LesserBlackWord"] = "次级关键词"
	L["LesserBlackWordTooltip"] = "标记添加的关键词为次级关键词，仅对该次添加的关键词有效|n当一个信息匹配多个次级关键词时才会被屏蔽。|n|n你应该只在添加那些日常交流会用到，但你希望屏蔽的对方会大量同时使用的词汇时勾选。|n下列情况不建议勾选：各种利用异体字/同音字防屏蔽的词汇、单个汉字。"
	L["LesserBlackwordList"] = "次级黑名单关键词"
	L["LesserBlackWordThreshold"] = "次级关键词阈值"
	L["LesserBlackWordThresholdTooltips"] = "过滤包含至少阈值数目的次级关键词的信息"
	L["BlackList"] = "关键词列表"
	L["StringIO"] = "字符串導入導出"
	L["StringHashMismatch"] = "字符串校驗錯誤"
	L["Export"] = "導出"
--LootFilter
	L["LootFilter"] = "拾取过滤器"
	L["AddItemWithID"] = "添加ID"
	L["BadID"] = "错误的ID"
	L["NotExists"] = "%s(ID=%d)不存在"
	L["ItemFilterList"] = "物品屏蔽列表"
	L["CurrencyFilterList"] = "货币屏蔽列表"
	L["LootQualityFilter"] = "拾取物品质量"
	L["LootQualityFilterTooltips"] = "显示拾取物品所需要的最低质量，低于此质量的物品将被过滤"
--AchievementFilter
	L["GotAchievement"] = "[%s]獲得了成就%s！"
	L["And"] = "、"
--Record
	L["RecordWindow"] = "聊天记录"
	L["ChatRecord"] = "开启聊天记录"
	L["ChatRecordTooltips"] = "开启后将记录系统信息以外的聊天信息，并可以查看哪些信息被过滤"
	L["ClearRecord"] = "清除聊天记录"
	L["ShowAll"] = "全部显示"
	L["OnlyFiltered"] = "仅过滤"
	L["OnlyUnfiltered"] = "仅未过滤"
--Error
	L["DBOutOfDate"] = "你的配置文件太旧了！你的配置文件版本:%d，插件最低兼容版本:%d"

-----------------------------------------------------------------------
-- Default -- NEED HELP
-----------------------------------------------------------------------
else
--Titles
	L["MainFilter"] = "Main Filter"
	L["MinimapIcon"] = "Minimap Button"
--Minimap Tooltips
	L["ClickToOpenConfig"] = "Click To Open Config"
--Common in tab
	L["ClearUp"] = "ClearUp"
	L["DoYouWantToClear"] = "Do you want to clear %s?"
--General
	L["General"] = "General"
	L["DND"] = "DND"
	L["DNDfilterTooltip"] = "Filter all DND players and their auto reply"
	L["Achievement"] = "Achievement"
	L["AchievementFilterTooltip"] = "Filter achievement spam"
	L["RaidAlert"] = "RaidAlert"
	L["RaidAlertFilterTooltip"] = "Filter raid alert from other players"
	L["QuestReport"] = "QuestReport"
	L["QuestReportFilterTooltip"] = "Filter many kind of grouping messages"
	L["SpecSpell"] = "SpecSpell"
	L["SpecSpellFilterTooltip"] = "Filter spell/talent learning messages if player is at max level"
	L["MonsterSay"] = "MonsterSay"
	L["MonsterSayFilterTooltip"] = "Use a repeat filter to reduce monster say msg in chat. This will not filter monster yell msg while it cast spells."
	L["RepeatOptions"] = "Repeat Options"
	L["chatLinesLimit"] = "Repeat message cache lines"
	L["chatLinesLimitTooltips"] = "Repeat message lines. Please change it to suit your message amount. Increase it will consume more memory and CPU. Set 0 to disable Repeat Filter. Default 20."
	L["RepeatFilter"] = "RepeatFilter"
	L["RepeatFilterTooltips"] = "Filter similar messages."
	L["FilterGroup"] = "FilterGroup"
	L["FilterGroupTooltips"] = "Enable to filter group and raid. This may filter some useful messages."
	L["DisplayAdvancedConfig"] = "Display Advanced Config"
	L["DisplayAdvancedConfigTooltips"] = "Please do NOT change any options that you don't understand, or you may mess ECF up. If you DO know the risk, you may continue..."
	L["WhisperWhitelistMode"] = "Whisper Whitelist Mode"
	L["WhisperWhitelistModeTooltip"] = "Filter all whisper unless it's from guild/group/raid/friends or you have just whisper them|n|cffE2252DUse with care!"
	L["Aggressive"] = "Aggressive Filters"
	L["AggressiveTooltip"] = "Some aggressive but effective Filters."
--BlackwordFilter
	L["BlackwordFilter"] = "BlackwordFilter"
	L["BlackwordList"] = "BlackwordList"
	L["AddBlackWordTitle"] = "Add Blackword"
	L["IncludeAutofilteredWord"] = "%s includes symbels to be filtered. It will be ignored."
	L["Regex"] = "Regex"
	L["RegexTooltip"] = "Blackword that will be added should be a regex expression. Only works for this blackword."
	L["LesserBlackWord"] = "LesserBlackWord"
	L["LesserBlackWordTooltip"] = "Blackword that will be added should be a lesser blackword. Only works for this blackword.|nA message will be filtered when contains multiple lesser blackwords.|n|nYou should only add words which are used by everyone, but the spam will have much more at the same time.|nDon't add words that are too short."
	L["LesserBlackwordList"] = "LesserBlackwordList"
	L["LesserBlackWordThreshold"] = "LesserBlackWordThreshold"
	L["LesserBlackWordThresholdTooltips"] = "Filter msgs contained many lesser blackwords"
	L["BlackList"] = "BlackList"
	L["StringIO"] = "Import/Export"
	L["StringHashMismatch"] = "String Hash Mismatch"
	L["Export"] = "Export"
--LootFilter
	L["LootFilter"] = "LootFilter"
	L["AddItemWithID"] = "Add With ID"
	L["BadID"] = "Bad ID"
	L["NotExists"] = "%s(ID = %d) doesn't exist"
	L["ItemFilterList"] = "ItemFilterList"
	L["CurrencyFilterList"] = "CurrencyFilterList"
	L["LootQualityFilter"] = "LootItemQuality"
	L["LootQualityFilterTooltips"] = "Filter any loot that is poorer than you choose"
--AchievementFilter
	L["GotAchievement"] = "[%s]have earned the achievement%s!"
	L["And"] = ", "
--Record
	L["RecordWindow"] = "Chat Record"
	L["ChatRecord"] = "Enable Chat Record"
	L["ChatRecordTooltips"] = "Enable chat record. This will record non-system chat msg and you can check whether they are filtered by ECF."
	L["ClearRecord"] = "ClearRecord"
	L["ShowAll"] = "ShowAll"
	L["OnlyFiltered"] = "OnlyFiltered"
	L["OnlyUnfiltered"] = "OnlyUnfiltered"
--Error
	L["DBOutOfDate"] = "Your profile is too old! Your profile version: %d, addon compatibal version: %d."
end

setmetatable(ecf.L, {__index=function(self, key) return key end})
