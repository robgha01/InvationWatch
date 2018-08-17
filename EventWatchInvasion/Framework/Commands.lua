local function ChatCmd(input)
	if not input or input:trim() == "" then
		EventWatchInvasion:WhoNotMajor()
	elseif input:trim() == "debug" then
		EventWatch._debug = not EventWatch._debug
	elseif input:trim() == "toggle" then
		EventWatchInvasionSavedData.RankWatchEnabled = not EventWatchInvasionSavedData.RankWatchEnabled
		EventWatchInvasion:MinimapButton_Refresh()
	elseif input:trim() == "reset" then
		Reset()
		print("[Invasion] Invasion wiped")
	end
end

function EventWatchInvasion:RegisterChatCmd()
	EventWatchInvasion:RegisterChatCommand("iw", ChatCmd)
	EventWatchInvasion:RegisterChatCommand("invationwatch", ChatCmd)
end