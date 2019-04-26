local _, ecf = ...
local _, L = unpack(ecf)

if (locale == "zhCN") then
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
elseif (locale == "zhTW") then
   --Common in tab
  L["ClearUp"] = "清空"
  L["DoYouWantToClear"] = "你確定要清空%s嗎？"
  L["FilterGroup"] = "過濾小隊團隊"
  L["FilterGroupTooltips"] = "啟用後，過濾器也會過濾小隊和團隊中的訊息，你可能因此錯過有用的消息。"

  --General
  L["General"] = "一般"
  L["DND"] = "「忙碌」玩家"
  L["DNDfilterTooltip"] = "過濾「忙碌」玩家及其自動回覆。"
  L["Achievement"] = "成就洗頻"
  L["AchievementFilterTooltip"] = "合併顯示多個玩家同時獲得的同一成就。"
  L["MonsterSay"] = "怪物說話"
  L["MonsterSayFilterTooltip"] = "用一個重覆過濾器減少NPC對話的洗頻。這不會影響施放技能時的喊話。"
  L["RepeatOptions"] = "重覆訊息設定"
  L["RepeatFilter"] = "重覆過濾器"
  L["RepeatFilterTooltips"] = "過濾內容相近的訊息"
  L["DisplayAdvancedConfig"] = "顯示高級選項"
  L["DisplayAdvancedConfigTooltips"] = "如果你是正常人請不要接受，不然你很有可能會把ECF玩壞！如果你同意你不是正常人的話請繼續..."
  L["Aggressive"] = "額外過濾器"
  L["AggressiveTooltip"] = "由一些會極大提高過濾效果和|cffE2252D誤傷機率|r的關鍵字合集組成的過濾器。"

  --Addon
  L["Addons"] = "插件通報過濾"
  L["RaidAlert"] = "團隊警報"
  L["RaidAlertFilterTooltip"] = "過濾副本中各類技能／喊話提醒。"
  L["QuestReport"] = "任務組隊"
  L["QuestReportFilterTooltip"] = "過濾各類任務組隊喊話提醒。"

  --BlackwordFilter
  L["BlackwordFilter"] = "關鍵詞過濾"
  L["BlackwordList"] = "黑名單關鍵詞列表"
  L["AddBlackWordTitle"] = "添加新的黑名單關鍵詞"
  L["IncludeAutofilteredWord"] = "%s包含會被自動過濾的字元，將忽略該關鍵詞！"
  L["Regex"] = "正則"
  L["RegexTooltip"] = "標記添加的關鍵詞為正則表達式，僅對該次添加的關鍵詞有效"
  L["LesserBlackWord"] = "次級關鍵詞"
  L["LesserBlackWordTooltip"] = "標記添加的關鍵詞為次級關鍵詞，僅對該次添加的關鍵詞有效|n當一個訊息匹配多個次級關鍵詞時才會被過濾。|n|n你應該只在添加那些「日常交流會用到，但你希望過濾」而且「對方會大量同時使用」的詞匯時勾選。|n下列情況不建議勾選：各種利用異體字／同音字防過濾的詞匯、單個漢字。"
  L["LesserBlackwordList"] = "次級黑名單關鍵詞"
  L["LesserBlackWordThreshold"] = "次級關鍵詞閾值"
  L["LesserBlackWordThresholdTooltips"] = "過濾包含至少閾值數目的次級關鍵詞之訊息"
  L["BlackList"] = "關鍵詞列表"
  L["StringIO"] = "字元串導入導出"
  L["StringHashMismatch"] = "字元串驗證錯誤"
  L["Export"] = "導出"

  --LootFilter
  L["LootFilter"] = "拾取過濾器"
  L["AddItemWithID"] = "添加ID"
  L["BadID"] = "錯誤的ID"
  L["NotExists"] = "%s(ID=%d)不存在"
  L["ItemFilterList"] = "物品黑名單列表"
  L["CurrencyFilterList"] = "貨幣黑名單列表"
  L["LootQualityFilter"] = "拾取物品品質"
  L["LootQualityFilterTooltips"] = "顯示拾取物品所需要的最低品質，低於此品質的物品將被過濾"

  --AchievementFilter
  L["GotAchievement"] = "[%s]獲得了成就%s！"
  L["And"] = "、"

else
--Common in tab
	L["ClearUp"] = "ClearUp"
	L["DoYouWantToClear"] = "Do you want to clear %s?"
	L["FilterGroup"] = "FilterGroup"
	L["FilterGroupTooltips"] = "Enable to filter group and raid. This may filter some useful messages."
	
--General
	L["General"] = "General"
	L["DND"] = "DND"
	L["DNDfilterTooltip"] = "Filter all DND players and their auto reply"
	L["Achievement"] = "Achievement"
	L["AchievementFilterTooltip"] = "Filter achievement spam"
	L["MonsterSay"] = "MonsterSay"
	L["MonsterSayFilterTooltip"] = "Use a repeat filter to reduce monster say msg in chat. This will not filter monster yell msg while it cast spells."
	L["RepeatOptions"] = "Repeat massage settings"
	L["RepeatFilter"] = "RepeatFilter"
	L["RepeatFilterTooltips"] = "Filter similar messages."
	L["DisplayAdvancedConfig"] = "Display Advanced Config"
	L["DisplayAdvancedConfigTooltips"] = "Please do NOT change any options that you don't understand, or you may mess ECF up. If you DO know the risk, you may continue..."
	L["Aggressive"] = "Aggressive Filters"
	L["AggressiveTooltip"] = "Some aggressive but effective Filters."

--Addon
	L["Addons"] = "AddonFilters"
	L["RaidAlert"] = "RaidAlert"
	L["RaidAlertFilterTooltip"] = "Filter raid alert from other players"
	L["QuestReport"] = "QuestReport"
	L["QuestReportFilterTooltip"] = "Filter many kind of grouping messages"
	
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
	L["GotAchievement"] = "[%s] have earned achievement %s!"
	L["And"] = ", "
end

setmetatable(L, {__index=function(_, key) return key end})
