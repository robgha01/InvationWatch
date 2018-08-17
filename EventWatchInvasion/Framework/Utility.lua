function EventWatchInvasion:GetUnitInvasionRank(unitID)
	if unitID == nil or UnitIsPlayer(unitID) == false then return end
	for index, rank in ipairs(EventWatchInvasion.Ranks) do
		if UnitAura(unitID, rank) then
			return index
		end	
	end
	return -1
end

function EventWatchInvasion:UpdateUnitRank(unitID)
	local name = UnitName(unitID)
	local newRank = EventWatchInvasion:GetUnitInvasionRank(unitID)
	local oldRank = EventWatchInvasion.Who[name]

	if oldRank == nil then
		-- This player is not tracked
		EventWatchInvasion.Who[name] = -1
		oldRank = -1
	end

	if newRank ~= -1 then
		EventWatchInvasion.Who[name] = newRank
	end

	return newRank, oldRank
end

function EventWatchInvasion:ScanInvasionRanks()
	local n,g;
	local unitName = ""

	-- Update self
	EventWatchInvasion:UpdateUnitRank("PLAYER")
	
	if UnitInRaid("PLAYER") then
		n = GetNumRaidMembers();
		g = "RAID";
	else
		n = GetNumPartyMembers();
		g = "PARTY";	
	end
	
	if n > 0 then
		for i = 1, n do
			local unitID = g..i
			if UnitIsPlayer(unitID) and UnitIsConnected(unitID) then
				unitName = UnitName(unitID)				
				EventWatchInvasion:UpdateUnitRank(unitID)
			end
		end
	end
end

function EventWatchInvasion:CleanupWho()
	for name, rank in pairs(EventWatchInvasion.Who) do
		local inGroup = false
		if UnitInRaid("PLAYER") then
			inGroup = UnitInRaid(name)
		else
			inGroup = UnitInParty(name)
		end
		if inGroup == false then
			EventWatchInvasion.Who[name] = nil -- Remove non existing players
		end
	end
end

function EventWatchInvasion:CheckState()
	EventWatchInvasion:CleanupWho()
	if UnitInRaid("PLAYER") == nil then
		EventWatchInvasion:RegisterEvent("PARTY_MEMBERS_CHANGED", "CheckState") -- No longer in raid
	end
	EventWatchInvasion:ScanInvasionRanks()
end

function EventWatchInvasion:IncrementWave()
	EventWatchInvasion.CurrentWave = EventWatchInvasion.CurrentWave + 1
end

function EventWatchInvasion:CheckStatus(event, eventMsg, eventType)
	if ViragDevTool_AddData then
		ViragDevTool_AddData({eventMsg, eventType}, "CheckStatus")
	else
		print("CheckStatus", eventMsg, eventType)
	end

	if eventType == "AQ Invasion Controller" then
		if eventMsg == L["You have successfully ended the invasion."] then
			Reset()
		elseif eventMsg == L["Qiraji reinforcements are arriving in 15 seconds. Prepare yourself. Hero!"] then
			EventWatchInvasion:IncrementWave()	
		end
	end
end