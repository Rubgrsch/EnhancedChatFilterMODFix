-- ECF
local addonName, ecf = ...
ecf[1] = {} -- Config
ecf[2] = {} -- Locales
ecf[3] = {} -- Globals
ecf.init = {}

-- Lua
local ipairs = ipairs
-- WoW
local ShowFriends = ShowFriends

local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", function(self,event,name)
	if name == addonName then
		self:UnregisterEvent(event)
		for _,f in ipairs(ecf.init) do f() end
		ecf.init = nil
		ShowFriends()
	end
end)

--Disable profanityFilter
if GetCVar("profanityFilter")~="0" then SetCVar("profanityFilter", "0") end
