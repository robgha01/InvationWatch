local L = LibStub("AceLocale-3.0"):GetLocale("InvasionWatch", false)
local LDB = LibStub:GetLibrary("LibDataBroker-1.1")
local LDBIcon = LDB and LibStub("LibDBIcon-1.0", true)
local tooltip

local function Reset()
	wipe(InvasionWatch.Who)
	InvasionWatch.Who = {}
	InvasionWatch.CurrentWave = 0
end

function InvasionWatch:OnInitialize()
	-- Called when the addon is loaded
	InvasionWatch:RegisterChatCmd()
	InvasionWatch:RegisterEvent("PLAYER_ENTERING_WORLD")
end

function InvasionWatch:OnEnable()
	-- Called when the addon is enabled
end

function InvasionWatch:OnDisable()
	-- Called when the addon is disabled
end

function InvasionWatch:WhoNotMajor()
	InvasionWatch:ScanInvasionRanks()
	if InvasionWatch.Who == nil then return end	
	local whoMsg = ""
	
	for name, rank in pairs(InvasionWatch.Who) do
		if UnitName(name) and UnitIsConnected(name) then
			local newRank, oldRank = InvasionWatch:UpdateUnitRank(name)
			if newRank == -1 then newRank = oldRank end
			if newRank ~= 3 then
				local msgWithRank = "%s (%s), %s"
				local msgNoRank = "%s, %s"
				if newRank == -1 then
					whoMsg = format(msgNoRank, name, whoMsg)				
				else
					whoMsg = format(msgWithRank, name, InvasionWatch.Ranks[newRank], whoMsg)				
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

	APIWatch:BroadcastMessage("[InvasionWatch] "..whoMsg)
end

function InvasionWatch:UNIT_AURA(_, unitID)
	if InvasionWatchSavedData.RankWatchEnabled == false then return end
	if unitID then
		if UnitIsPlayer(unitID) and UnitIsConnected(unitID) and (UnitInParty(unitID) or UnitInRaid(unitID)) then
			local name = UnitName(unitID)
			local newRank, oldRank = InvasionWatch:UpdateUnitRank(unitID)
			if oldRank == 2 and newRank == 3 then
				local msg = format(L["%s is now Major"], name)
				APIWatch:BroadcastMessage("[InvasionWatch] "..msg)			
			end
		end
	end
end

function InvasionWatch:PARTY_CONVERTED_TO_RAID()
	InvasionWatch:UnregisterEvent("PARTY_MEMBERS_CHANGED")
	InvasionWatch:RegisterEvent("RAID_ROSTER_UPDATE", "CheckState")
end

function InvasionWatch:OnCommReceived(prefix, message, distribution, sender)
	print(prefix, message, distribution, sender)
end

function InvasionWatch:PLAYER_ENTERING_WORLD()
	InvasionWatch:CheckState()
	InvasionWatch:RegisterEvent("UNIT_AURA")
	InvasionWatch:RegisterEvent("PARTY_MEMBERS_CHANGED","CheckState")
	InvasionWatch:RegisterEvent("PARTY_CONVERTED_TO_RAID")
	InvasionWatch:RegisterEvent("ZONE_CHANGED_NEW_AREA","CheckState")
	InvasionWatch:RegisterEvent("PLAYER_UNGHOST", "CheckState")
	InvasionWatch:RegisterEvent("CHAT_MSG_RAID_BOSS_EMOTE", "CheckStatus")
	
	InvasionWatch:MinimapButton_Refresh()
end

function InvasionWatch:MinimapButton_Refresh()
	if InvasionWatchSavedData.RankWatchEnabled then
		InvasionWatch.Minimap.LDBObject.icon = InvasionWatch.iconpaths.ON
	else
		InvasionWatch.Minimap.LDBObject.icon = InvasionWatch.iconpaths.OFF
	end
end