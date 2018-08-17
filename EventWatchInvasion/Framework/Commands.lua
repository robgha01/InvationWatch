local I = LibStub("AceAddon-3.0"):GetAddon("EventWatchInvasion")
local L = LibStub("AceLocale-3.0"):GetLocale("EventWatchInvasion", false)
local db = EventWatchInvasionSavedData

local function ChatCmd(input)
	if not input or input:trim() == "" then
		I:WhoNotMajor()
	elseif input:trim() == "debug" then
		EventWatch._debug = not EventWatch._debug
	elseif input:trim() == "toggle" then
		EventWatchInvasionSavedData.RankWatchEnabled = not EventWatchInvasionSavedData.RankWatchEnabled
		I:MinimapButton_Refresh()
	elseif input:trim() == "reset" then
		I:NewInvasion()
		print("["..L["Invasion"].."] wiped")
	end
end

function I:RegisterChatCmd()
	I:RegisterChatCommand("iw", ChatCmd)
	I:RegisterChatCommand("invationwatch", ChatCmd)
end