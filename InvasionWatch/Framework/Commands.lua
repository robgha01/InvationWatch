local function ChatCmd(input)
	if not input or input:trim() == "" then
		InvasionWatch:WhoNotMajor()
	elseif input:trim() == "debug" then
		APIWatch._debug = not APIWatch._debug
	elseif input:trim() == "toggle" then
		InvasionWatchSavedData.RankWatchEnabled = not InvasionWatchSavedData.RankWatchEnabled
		InvasionWatch:MinimapButton_Refresh()
	elseif input:trim() == "reset" then
		Reset()
		print("[InvasionWatch] Invasion wiped")
	end
end

function InvasionWatch:RegisterChatCmd()
	InvasionWatch:RegisterChatCommand("iw", ChatCmd)
	InvasionWatch:RegisterChatCommand("invationwatch", ChatCmd)
end