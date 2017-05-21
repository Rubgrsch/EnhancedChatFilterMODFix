-- ECF
local _, ecf = ...
ecf.ECF = LibStub("AceAddon-3.0"):NewAddon("EnhancedChatFilter", "AceConsole-3.0")
ecf.L, ecf.G = {}, {}
local ECF, G = ecf.ECF, ecf.G

--method run on /ecf
function ECF:EnhancedChatFilterOpen()
	if(InCombatLockdown()) then return end
	InterfaceOptionsFrame_OpenToCategory("EnhancedChatFilter")
end

--method run on /ecf-debug
function ECF:EnhancedChatFilterDebug()
	ECF:Print(ecf.db.debugMode and "Debug Mode Off!" or "Debug Mode On!")
	ecf.db.debugMode = not ecf.db.debugMode
end

--MinimapIcon
local ecfLDB = LibStub("LibDataBroker-1.1"):NewDataObject("Enhanced Chat Filter", {
	type = "data source",
	text = "Enhanced Chat Filter",
	icon = "Interface\\Icons\\Trade_Archaeology_Orc_BloodText",
	OnClick = function() ECF:EnhancedChatFilterOpen() end,
	OnTooltipShow = function(tooltip)
		tooltip:AddLine("|cffecf0f1Enhanced Chat Filter|r\n"..L["ClickToOpenConfig"])
	end
})

--Initialize
function ECF:OnInitialize()
	ECF:RegisterChatCommand("ecf", "EnhancedChatFilterOpen")
	ECF:RegisterChatCommand("ecf-debug", "EnhancedChatFilterDebug")

	G.DBInitialize()
	LibStub("LibDBIcon-1.0"):Register("Enhanced Chat Filter", ecfLDB, ecf.db.minimap)
	G.DBconvert()
	ShowFriends()
end

--Disable profanityFilter
if GetCVar("profanityFilter")~="0" then SetCVar("profanityFilter", "0") end
