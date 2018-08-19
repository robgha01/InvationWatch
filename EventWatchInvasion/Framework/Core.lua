local I = LibStub("AceAddon-3.0"):GetAddon("EventWatchInvasion")
local L = LibStub("AceLocale-3.0"):GetLocale("EventWatchInvasion", false)

function I:NewInvasion()
	wipe(I.players)
	I.players = {}
	I.announced = false
	I.currentWave = 0
	I.isInvasion = false
end

function I:GetPlayer(name)
	if not I.players[name] then
		EventWatch:Debug(format("GetPlayer: '%s' - creating a new datastore", name))
		I.players[name] = {
			rank = I.ranks["None"],
			total = { damage = 0, taken = 0, healing = 0 },
			current = { damage = 0, taken = 0, healing = 0 },
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
		EventWatch:Debug(format("SetRank: '%s, %s' - rank updated", name, rank))
		return true
	end
	EventWatch:Debug(format("SetRank: '%s, %s' - not updating rank", name, rank))
	return false
end

function I:GetUnitRank(unitID)
	if unitID == nil or UnitIsPlayer(unitID) == false then return end
	for rank, index in pairs(I.ranks) do
		EventWatch:Debug(format("GetUnitRank: Checking '%s, %s'", index, rank), UnitAura(unitID, rank))
		if UnitAura(unitID, rank) then
			EventWatch:Debug(format("GetUnitRank: '%s' rank found '%s'", unitID, index))
			return index
		end
	end

	EventWatch:Debug(format("GetUnitRank: '%s' found no rank", unitID))
	return I.ranks["None"]
end

function I:UpdateRank(nameOrUnitID)
	local name = UnitName(nameOrUnitID)
	local player = I:GetPlayer(name)
	local newRank = I:GetUnitRank(name)
	local oldRank = player.rank

	if newRank ~= I.ranks["None"] then
		I:SetRank(name, newRank)
	end

	EventWatch:Debug(format("UpdateRank: '%s' - newRank: '%s' oldRank: '%s'", name, newRank, oldRank))
	return newRank, oldRank
end

function I:ScanRanks()
	EventWatch:Debug("Scanning for ranks")
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
		EventWatch:Debug("Cleanup: Checking "..name)
		local inGroup = false
		if UnitInRaid("PLAYER") then
			inGroup = UnitInRaid(name)
		else
			inGroup = UnitInParty(name)
		end
		if inGroup == false then
			EventWatch:Debug(format("Cleanup: Removing '%s' as not in group", name))
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
	EventWatch:Debug(format("CheckStatus: '%s, %s, %s,'", event, eventMsg, eventType))
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
	if player.rank ~= I.ranks["Major"] and player.total then
		scoreTotal = (player.total.damage or 0) + ((player.total.taken or 0)*I.scoresRatio["Taken"]) + ((player.total.healing or 0)*I.scoresRatio["Healing"])
		if player.rank ~= I.ranks["None"] then
			-- Check score and update it to minimum if its lower then what its supposed to have
			local minScore = I.scoresByRank[I.ranksByID[player.rank]]
			EventWatch:Debug(format("GetScore: checking minimum score '%s, %s'", tostring(minScore), tostring(scoreTotal)))
			if minScore < scoreTotal then
				EventWatch:Debug(format("GetScore: seting min score to '%s'", tostring(minScore)))
				player.total.damage = minScore
			end
		end
	else
		scoreTotal = 160000
	end

	local scoreCurrent
	if player.current then
		scoreCurrent = ((player.rank or 0)*40000) + (player.current.damage or 0) + ((player.current.taken or 0)*I.scoresRatio["Taken"]) + ((player.current.healing or 0)*I.scoresRatio["Healing"])
	end
	if scoreTotal and scoreCurrent then
		return math.min(scoreTotal,scoreCurrent)
	else
		return scoreTotal or scoreCurrent
	end
end