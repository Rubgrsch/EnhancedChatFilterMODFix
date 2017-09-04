-- ECF
local _, ecf = ...
ecf.ECF = LibStub("AceAddon-3.0"):NewAddon("EnhancedChatFilter")
ecf.AC, ecf.L, ecf.G = {}, {}, {}
local ECF, L, G = ecf.ECF, ecf.L, ecf.G

-- WoW
local InCombatLockdown, InterfaceOptionsFrame_OpenToCategory, ShowFriends = InCombatLockdown, InterfaceOptionsFrame_OpenToCategory, ShowFriends
local LibStub = LibStub

-- GLOBALS: SLASH_ECF1

--method run on /ecf
local function ECFOpen()
	if(InCombatLockdown()) then return end
	InterfaceOptionsFrame_OpenToCategory("EnhancedChatFilter")
end
SlashCmdList.ECF = ECFOpen
SLASH_ECF1 = "/ecf"

--MinimapIcon
local ecfLDB = LibStub("LibDataBroker-1.1"):NewDataObject("Enhanced Chat Filter", {
	type = "data source",
	text = "Enhanced Chat Filter",
	icon = "Interface\\Icons\\Trade_Archaeology_Orc_BloodText",
	OnClick = ECFOpen,
	OnTooltipShow = function(tooltip)
		tooltip:AddLine("|cffecf0f1Enhanced Chat Filter|r\n"..L["ClickToOpenConfig"])
	end
})

--Initialize
function ECF:OnInitialize()
	G.DBInitialize()
	LibStub("LibDBIcon-1.0"):Register("Enhanced Chat Filter", ecfLDB, ecf.db.minimap)
	ShowFriends()
end

--Disable profanityFilter
if GetCVar("profanityFilter")~="0" then SetCVar("profanityFilter", "0") end
