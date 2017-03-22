local _, ecf = ...

local L = {}
-----------------------------------------------------------------------
-- zhCN
-----------------------------------------------------------------------
if (GetLocale() == "zhCN") then
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
	L["MonsterSayFilterTooltip"] = "用一个重复过滤器减少聊天框内怪物说话的刷屏。该选项不会影响怪物施放技能时的喊话，但可能屏蔽掉有用的任务提醒。"
	L["RepeatOptions"] = "重复信息设置"
	L["chatLinesLimit"] = "重复信息缓存行数"
	L["chatLinesLimitTooltips"] = "重复信息的行数设定。请根据聊天频道的聊天量调整数值。增加数值会提高内存占用。设为0以关闭重复过滤。默认值20。"
	L["MultiLines"] = "多行喊话过滤"
	L["MultiLinesTooltip"] = "重复过滤器现在也会过滤同一个人在短时间内的多行信息，这有助于减少各类宏的刷屏但同时也会过滤掉诸如dps统计的各插件通告"
	L["AlsoFilterGroup"] = "同时过滤小队团队"
	L["AlsoFilterGroupTooltips"] = "过滤器现在也会过滤小队团队中的发言，启用后你可能错过团队中有用的信息"
	L["UseWithCare"] = "危险设置"
	L["EnableAdvancedConfig"] = "启用高级选项"
	L["AdvancedWarningText"] = "不要随意更改任何你不清楚的设置，不然你很有可能会把ECF玩坏！如果你只是点着玩请取消。如果你已经知道危险性，请继续..."
	L["WhisperWhitelistMode"] = "密语白名单模式"
	L["WhisperWhitelistModeTooltip"] = "除了工会、团队、小队、好友发送的密语外，只允许你发送过密语的对方才能对你发起密语|n|cffE2252D慎用！"
	L["Aggressive"] = "额外过滤器"
	L["AggressiveTooltip"] = "一些会极大提高过滤效果和|cffE2252D误伤机率|r的过滤器集合，默认不开启。"
--BlackwordList
	L["BlackwordList"] = "黑名单关键词"
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
	L["Import"] = "导入"
	L["StringHashMismatch"] = "字符串校验错误"
	L["ImportSucceeded"] = "导入成功"
	L["Export"] = "导出"
--LootFilter
	L["LootFilter"] = "拾取过滤器"
	L["AddItemWithID"] = "添加ID"
	L["NotExists"] = "不存在"
	L["LootFilterList"] = "拾取屏蔽列表"
	L["LootQualityFilter"] = "拾取物品质量"
	L["LootQualityFilterTooltips"] = "显示拾取物品所需要的最低质量，低于此质量的物品将被过滤"
--FAQ
	L["FAQ"] = "FAQ"
	L["FAQText"] = [[这里列出常见的几个问题

1. 如何共享不同账号下的关键词列表和开关设置
    同一账户(如wow1)下的不同角色共享设置，不同账户的无法直接共享。
    你可以用字符串导入导出的方法复制关键词列表，然后人工进行设置。或者手动复制设置/设置硬链接。

2. 为何我添加关键词时总是会有"包含会被自动过滤的字符，将忽略该关键词！"这一错误？
    不要加入标点符号，这些字符会被自动忽略，只需要添加那些汉字。

3. 正则是什么？
    不知道的请不要用。不知道的请不要用。不知道的请不要用。
    如果你想学习请自行百度/谷歌。]]
--AchievementFilter
	L["GotAchievement"] = "[%s]获得了成就%s！"
	L["And"] = "、"

-----------------------------------------------------------------------
-- zhTW -- NEED HELP
-- Contributors: 老虎007@NGA
-----------------------------------------------------------------------
elseif (GetLocale() == "zhTW") then
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
	L["MonsterSayFilterTooltip"] = "用一个重复过滤器减少聊天框内怪物说话的刷屏。该选项不会影响怪物施放技能时的喊话，但可能屏蔽掉有用的任务提醒。"
	L["RepeatOptions"] = "重复信息设置"
	L["chatLinesLimit"] = "重复信息缓存行数"
	L["chatLinesLimitTooltips"] = "重复信息的行数设定。请根据聊天频道的聊天量调整数值。增加数值会提高内存占用。设为0以关闭重复过滤。默认值20"
	L["MultiLines"] = "多行喊话过滤"
	L["MultiLinesTooltip"] = "重复过滤器现在也会过滤同一个人在短时间内的多行信息，这有助于减少各类宏的刷屏但同时也会过滤掉诸如dps统计的各插件通告"
	L["AlsoFilterGroup"] = "同时过滤小队团队"
	L["AlsoFilterGroupTooltips"] = "过滤器现在也会过滤小队团队中的发言，启用后你可能错过团队中有用的信息"
	L["UseWithCare"] = "危险设置"
	L["EnableAdvancedConfig"] = "启用高级选项"
	L["AdvancedWarningText"] = "不要随意更改任何你不清楚的设置，不然你很有可能会把ECF玩坏！如果你只是点着玩请取消。如果你已经知道危险性，请继续..."
	L["WhisperWhitelistMode"] = "密語白名單模式"
	L["WhisperWhitelistModeTooltip"] = "除了工会、团队、小队、好友发送的密语外，只允许你发送过密语的对方才能对你发起密语|n|cffE2252D慎用！"
	L["Aggressive"] = "额外过滤器"
	L["AggressiveTooltip"] = "一些会极大提高过滤效果和|cffE2252D误伤机率|r的过滤器集合，默认不开启。"
--BlackwordList
	L["BlackwordList"] = "黑名单關鍵詞"
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
	L["Import"] = "導入"
	L["StringHashMismatch"] = "字符串校驗錯誤"
	L["ImportSucceeded"] = "導入成功"
	L["Export"] = "導出"
--LootFilter
	L["LootFilter"] = "拾取过滤器"
	L["AddItemWithID"] = "添加ID"
	L["NotExists"] = "不存在"
	L["LootFilterList"] = "拾取屏蔽列表"
	L["LootQualityFilter"] = "拾取物品质量"
	L["LootQualityFilterTooltips"] = "显示拾取物品所需要的最低质量，低于此质量的物品将被过滤"
--FAQ
	L["FAQ"] = "FAQ"
	L["FAQText"] = [[这里列出常见的几个问题

1. 如何共享不同账号下的关键词列表和开关设置
    同一账户(如wow1)下的不同角色共享设置，不同账户的无法直接共享。
    你可以用字符串导入导出的方法复制关键词列表，然后人工进行设置。或者手动复制设置/设置硬链接。

2. 为何我添加关键词时总是会有"包含会被自动过滤的字符，将忽略该关键词！"这一错误？
    不要加入标点符号，这些字符会被自动忽略，只需要添加那些汉字。

3. 正则是什么？
    不知道的请不要用。不知道的请不要用。不知道的请不要用。
    如果你想学习请自行百度/谷歌。]]
--AchievementFilter
	L["GotAchievement"] = "[%s]獲得了成就%s！"
	L["And"] = "、"
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
	L["MonsterSayFilterTooltip"] = "Use a repeat filter to reduce monster say msg in chat. This will not filter monster yell msg while it cast spells, but may filter quest msg in some case."
	L["RepeatOptions"] = "Repeat Options"
	L["chatLinesLimit"] = "Repeat message cache lines"
	L["chatLinesLimitTooltips"] = "Repeat message lines. Please change it to suit your message amount. Increase it will consume more memory. Set 0 to disable Repeat Filter. Default 20."
	L["MultiLines"] = "MultiLines"
	L["MultiLinesTooltip"] = "Filtered msg that is sent from the same person and in less than 1 sec. This may reduce chat spam but also remove report from addons."
	L["AlsoFilterGroup"] = "AlsoFilterGroup"
	L["AlsoFilterGroupTooltips"] = "Filter will also work on group and raid. This may filter some useful messages."
	L["UseWithCare"] = "UseWithCare"
	L["EnableAdvancedConfig"] = "Enable Advanced Config"
	L["AdvancedWarningText"] = "Please do NOT change any options that you don't understand, or you may mess ECF up. If you DO know the risk, you may continue..."
	L["WhisperWhitelistMode"] = "Whisper Whitelist Mode"
	L["WhisperWhitelistModeTooltip"] = "Filter all whisper unless it's from guild/group/raid/friends or you have just whisper them|n|cffE2252DUse with care!"
	L["Aggressive"] = "Aggressive Filters"
	L["AggressiveTooltip"] = "Some aggressive but effective Filters. Disable by default."
--BlackwordList
	L["BlackwordList"] = "BlackWordList"
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
	L["Import"] = "Import"
	L["StringHashMismatch"] = "String Hash Mismatch"
	L["ImportSucceeded"] = "Import Succeeded"
	L["Export"] = "Export"
--LootFilter
	L["LootFilter"] = "LootFilter"
	L["AddItemWithID"] = "Add With ID"
	L["NotExists"] = "Do not Exists"
	L["LootFilterList"] = "LootFilterList"
	L["LootQualityFilter"] = "LootItemQuality"
	L["LootQualityFilterTooltips"] = "Filter any loot that is poorer than you choose"
--FAQ
	L["FAQ"] = "FAQ"
	L["FAQText"] = [[这里列出常见的几个问题

1. 如何共享不同账号下的关键词列表和开关设置
    同一账户(如wow1)下的不同角色共享设置，不同账户的无法直接共享。
    你可以用字符串导入导出的方法复制关键词列表，然后人工进行设置。或者手动复制设置/设置硬链接。

2. 为何我添加关键词时总是会有"包含会被自动过滤的字符，将忽略该关键词！"这一错误？
    不要加入标点符号，这些字符会被自动忽略，只需要添加那些汉字。

3. 正则是什么？
    不知道的请不要用。不知道的请不要用。不知道的请不要用。
    如果你想学习请自行百度/谷歌。]]
--AchievementFilter
	L["GotAchievement"] = "[%s]have earned the achievement%s!"
	L["And"] = ", "
end

ecf.L = L

setmetatable(ecf.L, {__index=function(self, key)
	return key
end})