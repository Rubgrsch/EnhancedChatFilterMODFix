-- ECF
local addonName, ecf = ...
ecf[1] = {} -- Base
ecf[2] = {} -- Locales
ecf[3] = {} -- Config
setmetatable(ecf[2], {__index=function(_, key) return key end})
local B = unpack(ecf)

-- Lua
local ipairs = ipairs

--Event
local frame = CreateFrame("Frame")
frame:SetScript("OnEvent", function(self,event,...)
	for _, func in ipairs(self[event]) do func(self,event,...) end
end)

function B:AddEventScript(event, func)
	if not frame[event] then
		frame[event] = {}
		frame:RegisterEvent(event)
	end
	local t = frame[event]
	t[#t+1] = func
end

-- Init
local init = {}
B:AddEventScript("ADDON_LOADED", function(self,event,name)
	if name == addonName then
		self:UnregisterEvent(event)
		for _,f in ipairs(init) do f() end
		init = nil
	end
end)

function B:AddInitScript(func) init[#init+1] = func end

--Disable profanityFilter
B:AddInitScript(function()
	if GetCVar("portal") == "CN" then
		ConsoleExec("portal TW")
	end
	ConsoleExec("profanityFilter 0")
end)
