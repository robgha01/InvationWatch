local I = LibStub("AceAddon-3.0"):GetAddon("EventWatchInvasion")
local L = LibStub("AceLocale-3.0"):GetLocale("EventWatchInvasion", false)

function I:NewInvasion()
	wipe(I.players)
	I.players = {}
	I.announced = false
	I.currentWave = 0
end

function I:GetPlayer(name)
	if not I.players[name] then
		I.players[name] = {
			rank = -1
		}
	end
	return I.players[name]
end

function I:SetRank(name, rank)
	if type(rank) == "number" then rank = I.ranksByID[rank] end
	local player = I:GetPlayer(name)
	if player.rank ~= I.ranks[rank] then
		player.rank = I.ranks[rank]
		player.current = nil
		return true
	end
end

function I:GetUnitRank(unitID)
	if unitID == nil or UnitIsPlayer(unitID) == false then return end
	for index, rank in ipairs(I.ranks) do
		if UnitAura(unitID, rank) then
			return index
		end
	end
	return -1
end

function I:UpdateRank(nameOrUnitID)
	local name = UnitName(nameOrUnitID)
	local player = I:GetPlayer(name)
	local newRank = I:GetUnitRank(name)
	local oldRank = player.rank

	if newRank ~= -1 then
		I:SetRank(name, newRank)
	end

	return newRank, oldRank
end

function I:ScanRanks()
	local g,n = EventWatch:GetGroup()
	
	-- Update self
	I:UpdateRank("PLAYER")
	
	if n > 0 then
		for i = 1, n do
			local unitID = g..i
			if UnitIsPlayer(unitID) and UnitIsConnected(unitID) then
				I:UpdateRank(unitID)
			end
		end
	end
end

function I:Cleanup()
	for name,d in pairs(I.players) do
		local inGroup = false
		if UnitInRaid("PLAYER") then
			inGroup = UnitInRaid(name)
		else
			inGroup = UnitInParty(name)
		end
		if inGroup == false then
			I.players[name] = nil -- Remove non existing players
		end
	end
end

function I:CheckState()
	I:Cleanup()
	if UnitInRaid("PLAYER") == nil then
		I:RegisterEvent("PARTY_MEMBERS_CHANGED", "CheckState") -- No longer in raid
	end
	I:ScanRanks()
end

function I:IncrementWave()
	I.currentWave = I.currentWave + 1
end

function I:CheckStatus(event, eventMsg, eventType)
	if ViragDevTool_AddData then
		ViragDevTool_AddData({eventMsg, eventType}, "CheckStatus")
	else
		print("CheckStatus", eventMsg, eventType)
	end

	if eventType == "AQ Invasion Controller" then
		if eventMsg == L["You have successfully ended the invasion."] then
			I:NewInvasion()
		elseif eventMsg == L["Qiraji reinforcements are arriving in 15 seconds. Prepare yourself. Hero!"] then
			I:IncrementWave()	
		end
	end
end

function I:AddStat(name,stat,value)
	local player = I:GetPlayer(name);
	if player.rank ~= I.ranks["Major"] then
		player.total = player.total or {}
		player.current = player.current or {}
		if stat == 1 then -- damage done
			player.total.damage = (player.total.damage or 0) + value
			player.current.damage = (player.current.damage or 0) + value
		elseif stat == 2 then -- damage taken
			player.total.taken = (player.total.taken or 0) + value
			player.current.taken = (player.current.taken or 0) + value
		elseif stat == 3 then -- healing
			player.total.healing = (player.total.healing or 0) + value
			player.current.healing = (player.current.healing or 0) + value
		end
	end
end

function I:GetScore(player)
	if type(player) == "string" then player = I:GetPlayer(player) end
	local scoreTotal
	if player.total then
		scoreTotal = (player.total.damage or 0) + ((player.total.taken or 0)*1.25) + ((player.total.healing or 0)*1.5)
	end
	local scoreCurrent
	if player.current then
		scoreCurrent = ((player.rank or 0)*40000) + (player.current.damage or 0) + ((player.current.taken or 0)*1.25) + ((player.current.healing or 0)*1.5)
	end
	if scoreTotal and scoreCurrent then
		return math.min(scoreTotal,scoreCurrent)
	else
		return scoreTotal or scoreCurrent
	end
end