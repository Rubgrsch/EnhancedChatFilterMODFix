-- Contributor: EK
local _, ecf = ...
local _, L = unpack(ecf)

if GetLocale() ~= "zhTW" then return end

--Common in tab
L["ClearUp"] = "清空"
L["DoYouWantToClear"] = "你確定要清空%s嗎？"
L["FilterGroup"] = "過濾小隊團隊"
L["FilterGroupTooltips"] = "啟用後，過濾器也會過濾小隊和團隊中的訊息，你可能因此錯過有用的消息。"

--General
L["General"] = "一般"
L["Chat"] = "聊天"
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
L["BlockOtherLanguages"] = "其他種族語言"
L["BlockOtherLanguagesTooltip"] = "過濾聽不懂的玩家種族語言，主要來自對立陣營。"
L["Social"] = "社交"
L["BlockStrangersInvite"] = "阻擋組隊邀請請求"
L["BlockStrangersInviteTooltip"] = "阻擋來自非好友／公會的組隊邀請和請求，但偶爾會讓你無法進入預組隊伍"
L["BlockCommunityInvite"] = "阻擋社區邀請"
L["BlockCommunityInviteTooltip"] = "阻擋所有社群邀請"

--Addon
L["Addons"] = "插件通報"
L["RaidAlert"] = "團隊警報"
L["RaidAlertFilterTooltip"] = "過濾副本中各類技能／喊話提醒。"
L["QuestReport"] = "任務組隊"
L["QuestReportFilterTooltip"] = "過濾各類任務組隊喊話提醒。"

--BlackwordFilter
L["BlackwordFilter"] = "關鍵詞過濾"
L["BlackwordList"] = "黑名單關鍵詞列表"
L["AddBlackWordTitle"] = "添加新的黑名單關鍵詞"
L["IncludeAutofilteredWord"] = "%s包含會被自動過濾的字元，將忽略該關鍵詞！"
L["Regex"] = "正規表示式"
L["RegexTooltip"] = "標記添加的關鍵詞為正則表達式，僅對該次添加的關鍵詞有效。"
L["LesserBlackWord"] = "次級關鍵詞"
L["LesserBlackWordTooltip"] = "標記添加的關鍵詞為次級關鍵詞，僅對該次添加的關鍵詞有效。|n當一個訊息匹配多個次級關鍵詞時才會被過濾。|n|n你應該只在添加那些「日常交流會用到，但你希望過濾」而且「對方會大量同時使用」的詞匯時勾選。|n下列情況不建議勾選：各種利用異體字／同音字防過濾的詞匯、單個漢字。"
L["AutoCleanupKeywords"] = "自動清理關鍵詞"
L["AutoCleanupKeywordsTooltip"] = "關鍵詞列表過長時，自動清理長時間未觸發過的關鍵詞。|n對次級關鍵詞無效。"
L["LesserBlackwordList"] = "次級黑名單關鍵詞"
L["LesserBlackWordThreshold"] = "次級關鍵詞閾值"
L["LesserBlackWordThresholdTooltips"] = "一個訊息包含的次級關鍵詞數量要達到閾值才會被過濾。"
L["BlackList"] = "關鍵詞列表"
L["StringIO"] = "字串導入導出"
L["StringHashMismatch"] = "字串驗證錯誤"
L["Export"] = "導出"

--LootFilter
L["LootFilter"] = "拾取過濾"
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
