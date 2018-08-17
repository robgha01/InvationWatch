function InvasionWatch:GetUnitInvasionRank(unitID)
	if unitID == nil or UnitIsPlayer(unitID) == false then return end
	for index, rank in ipairs(InvasionWatch.Ranks) do
		if UnitAura(unitID, rank) then
			return index
		end	
	end
	return -1
end

function InvasionWatch:UpdateUnitRank(unitID)
	local name = UnitName(unitID)
	local newRank = InvasionWatch:GetUnitInvasionRank(unitID)
	local oldRank = InvasionWatch.Who[name]

	if oldRank == nil then
		-- This player is not tracked
		InvasionWatch.Who[name] = -1
		oldRank = -1
	end

	if newRank ~= -1 then
		InvasionWatch.Who[name] = newRank
	end

	return newRank, oldRank
end

function InvasionWatch:ScanInvasionRanks()
	local n,g;
	local unitName = ""

	-- Update self
	InvasionWatch:UpdateUnitRank("PLAYER")
	
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
				InvasionWatch:UpdateUnitRank(unitID)
			end
		end
	end
end

function InvasionWatch:CleanupWho()
	for name, rank in pairs(InvasionWatch.Who) do
		local inGroup = false
		if UnitInRaid("PLAYER") then
			inGroup = UnitInRaid(name)
		else
			inGroup = UnitInParty(name)
		end
		if inGroup == false then
			InvasionWatch.Who[name] = nil -- Remove non existing players
		end
	end
end

function InvasionWatch:CheckState()
	InvasionWatch:CleanupWho()
	if UnitInRaid("PLAYER") == nil then
		InvasionWatch:RegisterEvent("PARTY_MEMBERS_CHANGED", "CheckState") -- No longer in raid
	end
	InvasionWatch:ScanInvasionRanks()
end

function InvasionWatch:IncrementWave()
	InvasionWatch.CurrentWave = InvasionWatch.CurrentWave + 1
end

function InvasionWatch:CheckStatus(event, eventMsg, eventType)
	if ViragDevTool_AddData then
		ViragDevTool_AddData({eventMsg, eventType}, "CheckStatus")
	else
		print("CheckStatus", eventMsg, eventType)
	end

	if eventType == "AQ Invasion Controller" then
		if eventMsg == L["You have successfully ended the invasion."] then
			Reset()
		elseif eventMsg == L["Qiraji reinforcements are arriving in 15 seconds. Prepare yourself. Hero!"] then
			InvasionWatch:IncrementWave()	
		end
	end
end