local _, ecf = ...
local _, L = unpack(ecf)

--Default locale
if GetLocale() ~= "zhCN" and next(L) then return end

--Common in tab
L["ClearUp"] = "清空"
L["DoYouWantToClear"] = "你确定要清空%s么？"
L["FilterGroup"] = "过滤小队团队"
L["FilterGroupTooltips"] = "启用后过滤器也会过滤小队团队中的消息，你可能因此错过有用的消息"

--General
L["General"] = "常规"
L["DND"] = "'忙碌'玩家"
L["DNDfilterTooltip"] = "过滤'忙碌'玩家及其自动回复"
L["Achievement"] = "成就刷屏"
L["AchievementFilterTooltip"] = "合并显示多个玩家获得同一成就"
L["MonsterSay"] = "怪物说话"
L["MonsterSayFilterTooltip"] = "用一个重复过滤器减少NPC说话的刷屏。这不会影响施放技能时的喊话。"
L["RepeatOptions"] = "重复信息设置"
L["RepeatFilter"] = "重复过滤器"
L["RepeatFilterTooltips"] = "过滤内容相近的信息"
L["DisplayAdvancedConfig"] = "显示高级选项"
L["DisplayAdvancedConfigTooltips"] = "如果你是正常人请不要接受，不然你很有可能会把ECF玩坏！如果你同意你不是正常人的话请继续..."
L["Aggressive"] = "额外过滤器"
L["AggressiveTooltip"] = "一些会极大提高过滤效果和|cffE2252D误伤机率|r的过滤器集合"
L["BlockStrangersInvite"] = "屏蔽陌生组队邀请"
L["BlockStrangersInviteTooltip"] = "屏蔽来自非好友/工会的组队邀请"

--Addon
L["Addons"] = "插件通告过滤"
L["RaidAlert"] = "团队警报"
L["RaidAlertFilterTooltip"] = "过滤副本中各类技能/喊话提醒"
L["QuestReport"] = "任务组队"
L["QuestReportFilterTooltip"] = "过滤各类任务组队喊话提醒"

--BlackwordFilter
L["BlackwordFilter"] = "关键词过滤"
L["BlackwordList"] = "黑名单关键词列表"
L["AddBlackWordTitle"] = "添加新黑名单关键词"
L["IncludeAutofilteredWord"] = "%s包含会被自动过滤的字符，将忽略该关键词！"
L["Regex"] = "正则"
L["RegexTooltip"] = "标记添加的关键词为正则表达式，仅对该次添加的关键词有效"
L["LesserBlackWord"] = "次级关键词"
L["LesserBlackWordTooltip"] = "标记添加的关键词为次级关键词，仅对该次添加的关键词有效|n当一个信息匹配多个次级关键词时才会被屏蔽。|n|n你应该只在添加那些日常交流会用到，但你希望屏蔽的对方会大量同时使用的词汇时勾选。|n下列情况不建议勾选：各种利用异体字/同音字防屏蔽的词汇、单个汉字。"
L["AutoCleanupKeywords"] = "自动清理关键词"
L["AutoCleanupKeywordsTooltip"] = "关键词列表过长时，自动清理长时间未触发过的关键词"
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
L["NotExists"] = "%s(ID=%d)不存在"
L["ItemFilterList"] = "物品屏蔽列表"
L["CurrencyFilterList"] = "货币屏蔽列表"
L["LootQualityFilter"] = "拾取物品质量"
L["LootQualityFilterTooltips"] = "显示拾取物品所需要的最低质量，低于此质量的物品将被过滤"

--AchievementFilter
L["GotAchievement"] = "[%s]获得了成就%s！"
L["And"] = "、"
