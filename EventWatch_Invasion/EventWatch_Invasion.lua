local I = LibStub("AceAddon-3.0"):GetAddon("EventWatchInvasion")
local L = LibStub("AceLocale-3.0"):GetLocale("EventWatchInvasion", false)
local db = EventWatchInvasionSavedData
local tooltip

--level 60 score required for each rank:
--Rank 1 40,000
--Rank 2 80,000
--Rank 3 120,000
--Rank 4 160,000
--score from damage done is 1:1 ratio, damage taken is 1:1.25 ratio and healing done is 1:1.5 ratio
--overhealing doesnt count but overkill damage does

function I:OnInitialize()
	-- Called when the addon is loaded
	I:RegisterChatCmd()
	I:RegisterEvent("PLAYER_ENTERING_WORLD")

	I.ranks["None"] = 0
	for rankID,rankName in ipairs(I.ranksByID) do
		I.ranks[rankName] = rankID
	end
end

function I:OnEnable()
	-- Called when the addon is enabled
end

function I:OnDisable()
	-- Called when the addon is disabled
end

function I:CheckRank(unit)
	local name = UnitName(unit);
	local player = I:GetPlayer(name);
	if player and (player.rank ~= inv.ranks["Major"]) and UnitIsConnected(unit) then
		local score = inv.GetScore(player);
		if score and (score < 160000) then
			return name.." ("..math.floor((score/160000)*100).."%)";
		end
		return name;
	end
end

function I:WhoNotMajor(reportType)
	I:ScanRanks()
	if I.players == nil then return end	
	local list = ""
	
	for name,player in pairs(I.players) do
		if UnitName(name) and UnitIsConnected(name) then
			local newRank, oldRank = I:UpdateRank(name)
			if newRank == I.ranks["None"] then newRank = oldRank end
			if newRank ~= I.ranks["Major"] then
				local msgWithRank = "%s (%s), %s"
				local msgWithProg = "%s (%s%%), %s"
				local msgNoRank = "%s, %s"
				local score = I:GetScore(player)

				if newRank == I.ranks["None"] then
					list = format(msgNoRank, name, list)
				elseif reportType and reportType == I.reportType["RankName"] then
					EventWatch:Debug(format("WhoNotMajor(%s) - %s %s %s", reportType, name, newRank, I.ranksByID[newRank]))
					list = format(msgWithRank, name, I.ranksByID[newRank], list)
				else
					if score and (score < 160000) and score >= 0 then
						list = format(msgWithProg, name, math.floor((score/160000)*100), list)				
					else
						list = format(msgWithRank, name, I.ranksByID[newRank], list)
					end
				end
			end
		end
	end

	list = list:sub(1, #list - 2)
	if list ~= "" then
		I.announced = false;
		list = format(L["Not Major: %s"], list)
	else--if not I.announced then
		list = L["Everyone is Major!"]
	end
	EventWatch:BroadcastMessage("["..L["Invasion"].."] "..list)
end

--function I:UNIT_AURA(_, unitID)
function I:UNITAURA(unitID)
	--EventWatch:Debug(format("UNITAURA: '%s'", unitID))
	if EventWatchInvasionSavedData.RankWatchEnabled == false then return end
	if unitID then
		if UnitIsPlayer(unitID) and UnitIsConnected(unitID) and (UnitInParty(unitID) or UnitInRaid(unitID)) then
			local name = UnitName(unitID)
			local newRank, oldRank = I:UpdateRank(name)
			if oldRank == I.ranks["Captain"] and newRank == I.ranks["Major"] then
				local msg = format(L["%s is now Major!"], name)
				EventWatch:BroadcastMessage("["..L["Invasion"].."] "..msg)

				local allMajor = true
				for name,player in pairs(I.players) do
					if player.rank ~= I.ranks["Major"] then
						allMajor = false
					end
				end

				if allMajor then
					I:WhoNotMajor()
				end
			end
		end
	end
end

function I:COMBAT_LOG_EVENT_UNFILTERED(_, ...)
	local _,subEvent,sourceGUID,sourceName,sourceFlags,destGUID,destName,destFlags,arg1,arg2,_,arg4,arg5 = ...
	if subEvent == "SPELL_AURA_APPLIED" then -- or subEvent == "SPELL_AURA_REFRESH"
		--EventWatch:Debug(format("SPELL_AURA_APPLIED: '%s, %s'", tostring(arg2), tostring(I.ranks[arg2])))
		if I.ranks[arg2] then
			EventWatch:Debug("SPELL_AURA_APPLIED: Is rank", I.ranks[arg2])
			I:UNITAURA(destName)
			I.isInvasion = true
		end
	else
		local amount
		if subEvent == "SWING_DAMAGE" then
			amount = arg1 or 0
		end
		if EventWatch:IsRaidMember(sourceFlags) and I.mobs[destName] and subEvent:find("_DAMAGE$") then
			amount = amount or arg4 or 0
			I:AddStat(sourceName,1,amount)
			I.isInvasion = true
		elseif EventWatch:IsRaidMember(destFlags) and I.mobs[sourceName] and subEvent:find("_DAMAGE$") then
			amount = amount or arg4 or 0
			I:AddStat(destName,2,amount)
			I.isInvasion = true
		elseif EventWatch:IsRaidMember(sourceFlags) and subEvent:find("_HEAL$") then
			amount = amount or ((arg4 or 0)-(arg5 or 0)) or 0
			I:AddStat(sourceName,3,amount)
		end
	end
end

function I:PARTY_CONVERTED_TO_RAID()
	I:UnregisterEvent("PARTY_MEMBERS_CHANGED")
	I:RegisterEvent("RAID_ROSTER_UPDATE", "CheckState")
end

function I:OnCommReceived(prefix, message, distribution, sender)
	print(prefix, message, distribution, sender)
end

function I:PLAYER_ENTERING_WORLD()
	I:CheckState()
	--I:RegisterEvent("UNIT_AURA")
	I:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	I:RegisterEvent("PARTY_MEMBERS_CHANGED","CheckState")
	I:RegisterEvent("PARTY_CONVERTED_TO_RAID")
	I:RegisterEvent("ZONE_CHANGED_NEW_AREA","CheckState")
	I:RegisterEvent("PLAYER_UNGHOST", "CheckState")
	I:RegisterEvent("CHAT_MSG_RAID_BOSS_EMOTE", "CheckStatus")
	
	I:MinimapButton_Refresh()
end