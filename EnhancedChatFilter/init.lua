-- ECF
local _, ecf = ...
ecf[1] = {} -- Config
ecf[2] = {} -- Locales
ecf[3] = {} -- Globals
ecf[4] = {} -- AC
ecf.init = {}
local ECF = LibStub("AceAddon-3.0"):NewAddon("EnhancedChatFilter")
local C, L = unpack(ecf)

-- Lua
local ipairs = ipairs
-- WoW
local InterfaceOptionsFrame_OpenToCategory, ShowFriends = InterfaceOptionsFrame_OpenToCategory, ShowFriends
local LibStub = LibStub

-- GLOBALS: SLASH_ECF1

--method run on /ecf
local function ECFOpen()
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
	OnTooltipShow = function(tooltip) tooltip:AddLine(L["ClickToOpenConfig"]) end
})

--Initialize
function ECF:OnInitialize()
	for _,f in ipairs(ecf.init) do f() end
	LibStub("LibDBIcon-1.0"):Register("Enhanced Chat Filter", ecfLDB, C.db.minimap)
	ShowFriends()
end

--Disable profanityFilter
if GetCVar("profanityFilter")~="0" then SetCVar("profanityFilter", "0") end
