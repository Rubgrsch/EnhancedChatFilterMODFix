local _, ecf = ...

local L = {}
-----------------------------------------------------------------------
-- zhCN
-----------------------------------------------------------------------
if (GetLocale() == "zhCN") then
	L["Options"] = "选项"
	L["ClickToOpenConfig"] = "点击打开配置界面"
	L["MainFilter"] = "总开关"
	L["MinimapButton"] = "小地图图标"
	L["WhisperWhitelistMode"] = "密语白名单模式"
	L["DND"] = "'忙碌'玩家"
	L["Repeat"] = "重复信息"
	L["Achievement"] = "成就刷屏"
	L["RaidAlert"] = "团队警报"
	L["QuestReport"] = "任务组队"
	L["IgnoreMoreList"] = "扩展屏蔽名单"
	L["IncludeAutofilteredWord"] = "包含会被自动过滤的字符，将忽略该关键词！"
	L["Remove"] = "移除"
	L["ClearUp"] = "清空"
	L["AddBlackWordTitle"] = "添加新黑名单关键字"
	L["Regex"] = "正则"
	L["And"] = "、"
	L["GotAchievement"] = "获得了成就"
	L["DoYouWantToClear"] = "你确定要清空"
	L["?"] = "么？"
	L["BlackList"] = "关键词列表"
	L["RepeatOptions"] = "重复信息设置"
	L["chatLinesLimitSlider"] = "重复信息缓存行数"
	L["stringDifferenceLimitSlider"] = "重复信息区分度"
	L["UseWithCare"] = "危险设置"
	L["Filters"] = "过滤器"
	L["Import"] = "导入"
	L["Export"] = "导出"
	L["AlsoFilterGroup"] = "同时过滤小队团队"
	L["AlsoFilterGroupTooltips"] = "关键词过滤现在也会过滤小队团队中的发言，根据关键词你可能错过团队中有用的信息"
	L["StringHashMismatch"] = "字符串校验错误"
	L["ImportSucceeded"] = "导入成功"
	L["MultiLines"] = "多行喊话过滤"
	L["EnableAdvancedConfig"] = "启用高级选项"
	L["AdvancedWarningText"] = "不要随意更改任何你不清楚的设置，不然你很有可能会把ECF玩坏！如果你已经知道危险性，请继续..."
	L["LootFilter"] = "拾取过滤器"
	L["AddItemWithID"] = "添加ID"
	L["Item"] = "物品"
	L["Currency"] = "货币"
	L["NotExists"] = "不存在"
	L["Type"] = "类型"
	L["LootFilterList"] = "拾取屏蔽列表"
	L["LootQualityFilter"] = "拾取物品质量"
	L["LootQualityFilterTooltips"] = "显示拾取物品所需要的最低质量，低于此质量的物品将被过滤"
	L["Poor"] = "垃圾"
	L["Common"] = "普通"
	L["Uncommon"] = "优秀"
	L["Rare"] = "精良"
	L["Epic"] = "史诗"

	L["General"] = "常规"
	L["BlackworldList"] = "黑名单关键词"
	L["StringIO"] = "字符串导入导出"
	L["AdvancedConfig"] = "高级"

	L["WhisperWhitelistModeTooltip"] = "启用后除了工会、团队、小队、战网好友发送的密语外，只允许你发送过密语的对方才能对你发起密语|n|cffE2252D慎用！"
	L["MultiLinesTooltip"] = "重复过滤器现在也会过滤同一个人在短时间内的多行信息，这有助于减少各类宏的刷屏但同时也会过滤掉诸如dps统计的各插件通告"
	L["DNDfilterTooltip"] = "启用后过滤'忙碌'玩家及其自动回复"
	L["RepeatFilterTooltip"] = "启用后过滤同一玩家发送的相似信息"
	L["AchievementFilterTooltip"] = "启用后合并显示多个玩家获得同一成就"
	L["RaidAlertFilterTooltip"] = "启用后过滤各类技能/打断喊话提示"
	L["QuestReportFilterTooltip"] = "启用后过滤各类组队任务喊话提醒"
	L["RegexTooltip"] = "标记添加的关键词为正则表达式|n仅对该次添加的关键词有效"
	L["chatLinesLimitSliderTooltips"] = "重复信息的行数设定。请根据聊天频道的聊天量调整数值。增加数值会提高内存占用。默认值20"
	L["stringDifferenceLimitSliderTooltips"] = "重复信息判定标准，范围0%至100%。对于同一个人的发言，0%为只过滤完全相同的内容，100%为过滤任意内容。提高设定值会提高相似信息的过滤效果但会提高误处理几率。默认值10%"
	
	L["FAQ"] = "FAQ"
	L["FAQText"] = [=[这里列出常见的几个问题

1. 如何共享不同账号下的关键词列表和开关设置
    同一账户(如wow1)下的不同角色共享设置，不同账户的无法直接共享。
    你可以用字符串导入导出的方法复制关键词列表，然后人工进行设置。或者手动复制设置/设置硬链接。

2. 为何我添加关键词时总是会有"包含会被自动过滤的字符，将忽略该关键词！"这一错误？
    不要加入标点符号，这些字符会被自动忽略，只需要添加那些汉字。

3. 正则是什么？
    不知道的请不要用。不知道的请不要用。不知道的请不要用。
    如果你想学习请自行百度/谷歌。

4. 为什么我的关键词都没勾上？每次勾上/rl之后又复原了？
    这些勾只是用来删除的，不是代表关键词启用与否。任何加入的关键词都已启用。]=]
-----------------------------------------------------------------------
-- zhTW -- NEED HELP
-- Contributors: 老虎007@NGA
-----------------------------------------------------------------------
elseif (GetLocale() == "zhTW") then
	L["Options"] = "选项"
	L["ClickToOpenConfig"] = "點擊打開配置介面"
	L["MainFilter"] = "總開關"
	L["MinimapButton"] = "小地圖圖標"
	L["WhisperWhitelistMode"] = "密語白名單模式"
	L["DND"] = "'忙碌,玩家"
	L["Repeat"] = "重複信息"
	L["Achievement"] = "成就刷屏"
	L["RaidAlert"] = "團隊警報"
	L["QuestReport"] = "任務組隊"
	L["IgnoreMoreList"] = "擴展屏蔽名單"
	L["IncludeAutofilteredWord"] = "包含會被自動過濾的字符，蔣忽略該關鍵詞！"
	L["Remove"] = "移除"
	L["ClearUp"] = "清空"
	L["AddBlackWordTitle"] = "添加新黑名單關鍵詞"
	L["Regex"] = "正規"
	L["And"] = "、"
	L["GotAchievement"] = "獲得了成就"
	L["DoYouWantToClear"] = "你确定要清空"
	L["?"] = "么？"
	L["BlackList"] = "关键词列表"
	L["RepeatOptions"] = "重复信息设置"
	L["chatLinesLimitSlider"] = "重复信息缓存行数"
	L["stringDifferenceLimitSlider"] = "重复信息区分度"
	L["UseWithCare"] = "危险设置"
	L["Filters"] = "過濾器"
	L["Import"] = "導入"
	L["Export"] = "導出"
	L["AlsoFilterGroup"] = "同时过滤小队团队"
	L["AlsoFilterGroupTooltips"] = "关键词过滤现在也会过滤小队团队中的发言，根据关键词你可能错过团队中有用的信息"
	L["StringHashMismatch"] = "字符串校驗錯誤"
	L["ImportSucceeded"] = "導入成功"
	L["MultiLines"] = "多行喊话过滤"
	L["EnableAdvancedConfig"] = "启用高级选项"
	L["AdvancedWarningText"] = "不要随意更改你不清楚的设置，不然你很有可能会把ECF玩坏！如果你已经知道危险性，请继续..."
	L["LootFilter"] = "拾取过滤器"
	L["AddItemWithID"] = "添加ID"
	L["Item"] = "物品"
	L["Currency"] = "货币"
	L["NotExists"] = "不存在"
	L["Type"] = "类型"
	L["LootFilterList"] = "拾取屏蔽列表"
	L["LootQualityFilter"] = "拾取物品质量"
	L["LootQualityFilterTooltips"] = "显示拾取物品所需要的最低质量，低于此质量的物品将被过滤"
	L["Poor"] = "垃圾"
	L["Common"] = "普通"
	L["Uncommon"] = "优秀"
	L["Rare"] = "精良"
	L["Epic"] = "史诗"

	L["General"] = "常规"
	L["BlackworldList"] = "黑名单關鍵詞"
	L["StringIO"] = "字符串導入導出"
	L["AdvancedConfig"] = "高级"

	L["WhisperWhitelistModeTooltip"] = "启用后除了工会、团队、小队、战网好友发送的密语外，只允许你发送过密语的对方才能对你发起密语|n|cffE2252D慎用！"
	L["MultiLinesTooltip"] = "重复过滤器现在也会过滤同一个人在短时间内的多行信息，这有助于减少各类宏的刷屏但同时也会过滤掉诸如dps统计的各插件通告"
	L["DNDfilterTooltip"] = "启用后过滤'忙碌'玩家及其自动回复"
	L["RepeatFilterTooltip"] = "启用后过滤同一玩家发送的相似信息"
	L["AchievementFilterTooltip"] = "启用后合并显示多个玩家获得同一成就"
	L["RaidAlertFilterTooltip"] = "启用后过滤各类技能/打断喊话提示"
	L["QuestReportFilterTooltip"] = "启用后过滤各类组队任务喊话提醒"
	L["RegexTooltip"] = "标记添加的关键词为正则表达式|n仅对该次添加的关键词有效"
	L["chatLinesLimitSliderTooltips"] = "重复信息的行数设定。请根据聊天频道的聊天量调整数值。增加数值会提高内存占用。默认值20"
	L["stringDifferenceLimitSliderTooltips"] = "重复信息判定标准值，范围0%至100%。对于同一个人的发言，0%为只过滤完全相同的内容，100%为过滤任意内容。提高设定值会提高类似信息的过滤效果但会提高误处理几率。默认值10%"
	
	L["FAQ"] = "FAQ"
	L["FAQText"] = [=[这里列出常见的几个问题

1. 如何共享不同账号下的关键词列表和开关设置
    同一账户(如wow1)下的不同角色共享设置，不同账户的无法直接共享。
    你可以用字符串导入导出的方法复制关键词列表，然后人工进行设置。或者手动复制设置/设置硬链接。

2. 为何我添加关键词时总是会有"包含会被自动过滤的字符，将忽略该关键词！"这一错误？
    不要加入标点符号，这些字符会被自动忽略，只需要添加那些汉字。

3. 正则是什么？
    不知道的请不要用。不知道的请不要用。不知道的请不要用。
    如果你想学习请自行百度/谷歌。

4. 为什么我的关键词都没勾上？每次勾上/rl之后又复原了？
    这些勾只是用来删除的，不是代表关键词启用与否。任何加入的关键词都已启用。]=]
-----------------------------------------------------------------------
-- Default: 07.29.16 -- NEED HELP
-----------------------------------------------------------------------
else
	L["Options"] = "Options"
	L["ClickToOpenConfig"] = "Click To Open Config"
	L["MainFilter"] = "Main Filter"
	L["MinimapButton"] = "Minimap Button"
	L["WhisperWhitelistMode"] = "Whisper Whitelist Mode"
	L["DND"] = "DND"
	L["Repeat"] = "Repeat"
	L["Achievement"] = "Achievement"
	L["RaidAlert"] = "RaidAlert"
	L["QuestReport"] = "QuestReport"
	L["IgnoreMoreList"] = "IgnoreMore List"
	L["ClearUp"] = "ClearUp"
	L["IncludeAutofilteredWord"] = "Includes symbels to be filtered. It will be ignored."
	L["Remove"] = "Remove"
	L["AddBlackWordTitle"] = "Add Blackword"
	L["Regex"] = "Regex"
	L["And"] = ", "
	L["GotAchievement"] = "have earned the achievement"
	L["DoYouWantToClear"] = "Do you want to clear"
	L["?"] = "?"
	L["BlackList"] = "BlackList"
	L["RepeatOptions"] = "Repeat Options"
	L["chatLinesLimitSlider"] = "Repeat message cache lines"
	L["stringDifferenceLimitSlider"] = "Repeat message Difference"
	L["UseWithCare"] = "UseWithCare"
	L["Filters"] = "Filters"
	L["Import"] = "Import"
	L["Export"] = "Export"
	L["AlsoFilterGroup"] = "AlsoFilterGroup"
	L["AlsoFilterGroupTooltips"] = "BlackWord Filter will also work on group and raid. This may filter some useful messages."
	L["StringHashMismatch"] = "String Hash Mismatch"
	L["ImportSucceeded"] = "Import Succeeded"
	L["MultiLines"] = "MultiLines"
	L["EnableAdvancedConfig"] = "Enable Advanced Config"
	L["AdvancedWarningText"] = "Please do NOT change any options that you don't understand, or you may mess ECF up. If you DO know the risk, you may continue..."
	L["LootFilter"] = "LootFilter"
	L["AddItemWithID"] = "Add With ID"
	L["Item"] = "Item"
	L["Currency"] = "Currency"
	L["NotExists"] = "Do not Exists"
	L["Type"] = "Type"
	L["LootFilterList"] = "LootFilterList"
	L["LootQualityFilter"] = "LootItemQuality"
	L["LootQualityFilterTooltips"] = "Filter any loot that is poorer than you choose"
	L["Poor"] = "Poor"
	L["Common"] = "Common"
	L["Uncommon"] = "Uncommon"
	L["Rare"] = "Rare"
	L["Epic"] = "Epic"

	L["General"] = "General"
	L["BlackworldList"] = "BlackWordList"
	L["StringIO"] = "Import/Export"
	L["AdvancedConfig"] = "Advanced"

	L["WhisperWhitelistModeTooltip"] = "While enabled, it will filter all whisper unless it's from guild/group/raid/battlenet friend or you have just whisper them|n|cffE2252DUse with care!"
	L["MultiLinesTooltip"] = "Filtered msg that is sent from the same person and in less than 1 sec. This may reduce chat spam but also remove report from addons."
	L["DNDfilterTooltip"] = "While enabled, it will filter all DND players and their auto reply"
	L["RepeatFilterTooltip"] = "While enabled, it will filter similar messages from the same player"
	L["AchievementFilterTooltip"] = "While enabled, it will filter achievement spam"
	L["RaidAlertFilterTooltip"] = "While enabled, it will filter raid alert from other players"
	L["QuestReportFilterTooltip"] = "While enabled, it will filter many kind of grouping messages"
	L["RegexTooltip"] = "Blackword that will be added should be a regex expression. Only works for this blackword."
	L["chatLinesLimitSliderTooltips"] = "Repeat message lines. Please change it to suit your message amount. Increase it will consume more memory. Default 20."
	L["stringDifferenceLimitSliderTooltips"] = "Message difference limit. Ranging from 0% to 100%. For the same sender, 0% will only filter the same message while 100% will filter any message. Increase it will filter more similar messages but also some unwanted ones. Default 10%."
	
	L["FAQ"] = "FAQ"
	L["FAQText"] = [=[这里列出常见的几个问题

1. 如何共享不同账号下的关键词列表和开关设置
    同一账户(如wow1)下的不同角色共享设置，不同账户的无法直接共享。
    你可以用字符串导入导出的方法复制关键词列表，然后人工进行设置。或者手动复制设置/设置硬链接。

2. 为何我添加关键词时总是会有"包含会被自动过滤的字符，将忽略该关键词！"这一错误？
    不要加入标点符号，这些字符会被自动忽略，只需要添加那些汉字。

3. 正则是什么？
    不知道的请不要用。不知道的请不要用。不知道的请不要用。
    如果你想学习请自行百度/谷歌。

4. 为什么我的关键词都没勾上？每次勾上/rl之后又复原了？
    这些勾只是用来删除的，不是代表关键词启用与否。任何加入的关键词都已启用。]=]
end

ecf.L = L

setmetatable(ecf.L, {__index=function(self, key)
	return key
end})