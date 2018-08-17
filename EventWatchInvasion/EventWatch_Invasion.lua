local L = LibStub("AceLocale-3.0"):GetLocale("EventWatchInvasion", false)
local tooltip

local function Reset()
	wipe(EventWatchInvasion.Who)
	EventWatchInvasion.Who = {}
	EventWatchInvasion.CurrentWave = 0
end

function EventWatchInvasion:OnInitialize()
	-- Called when the addon is loaded
	EventWatchInvasion:RegisterChatCmd()
	EventWatchInvasion:RegisterEvent("PLAYER_ENTERING_WORLD")
end

function EventWatchInvasion:OnEnable()
	-- Called when the addon is enabled
end

function EventWatchInvasion:OnDisable()
	-- Called when the addon is disabled
end

function EventWatchInvasion:WhoNotMajor()
	EventWatchInvasion:ScanInvasionRanks()
	if EventWatchInvasion.Who == nil then return end	
	local whoMsg = ""
	
	for name, rank in pairs(EventWatchInvasion.Who) do
		if UnitName(name) and UnitIsConnected(name) then
			local newRank, oldRank = EventWatchInvasion:UpdateUnitRank(name)
			if newRank == -1 then newRank = oldRank end
			if newRank ~= 3 then
				local msgWithRank = "%s (%s), %s"
				local msgNoRank = "%s, %s"
				if newRank == -1 then
					whoMsg = format(msgNoRank, name, whoMsg)				
				else
					whoMsg = format(msgWithRank, name, EventWatchInvasion.Ranks[newRank], whoMsg)				
				end
			end
		end
	end

	whoMsg = whoMsg:sub(1, #whoMsg - 2)
	if whoMsg ~= "" then
		whoMsg = format(L["Not Major: %s"], whoMsg)
	else
		whoMsg = L["Everyone is Major!"]
	end

	EventWatch:BroadcastMessage("["..L["Invasion"].."] "..whoMsg)
end

function EventWatchInvasion:UNIT_AURA(_, unitID)
	if EventWatchInvasionSavedData.RankWatchEnabled == false then return end
	if unitID then
		if UnitIsPlayer(unitID) and UnitIsConnected(unitID) and (UnitInParty(unitID) or UnitInRaid(unitID)) then
			local name = UnitName(unitID)
			local newRank, oldRank = EventWatchInvasion:UpdateUnitRank(unitID)
			if oldRank == 2 and newRank == 3 then
				local msg = format(L["%s is now Major"], name)
				EventWatch:BroadcastMessage("["..L["Invasion"].."] "..msg)			
			end
		end
	end
end

function EventWatchInvasion:PARTY_CONVERTED_TO_RAID()
	EventWatchInvasion:UnregisterEvent("PARTY_MEMBERS_CHANGED")
	EventWatchInvasion:RegisterEvent("RAID_ROSTER_UPDATE", "CheckState")
end

function EventWatchInvasion:OnCommReceived(prefix, message, distribution, sender)
	print(prefix, message, distribution, sender)
end

function EventWatchInvasion:PLAYER_ENTERING_WORLD()
	EventWatchInvasion:CheckState()
	EventWatchInvasion:RegisterEvent("UNIT_AURA")
	EventWatchInvasion:RegisterEvent("PARTY_MEMBERS_CHANGED","CheckState")
	EventWatchInvasion:RegisterEvent("PARTY_CONVERTED_TO_RAID")
	EventWatchInvasion:RegisterEvent("ZONE_CHANGED_NEW_AREA","CheckState")
	EventWatchInvasion:RegisterEvent("PLAYER_UNGHOST", "CheckState")
	EventWatchInvasion:RegisterEvent("CHAT_MSG_RAID_BOSS_EMOTE", "CheckStatus")
	
	EventWatchInvasion:MinimapButton_Refresh()
end