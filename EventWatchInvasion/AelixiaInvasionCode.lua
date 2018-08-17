local inv = {};
inv.inGroup = false;
inv.players = {};

inv.ranksByID = {
	[1] = "Private",
	[2] = "Lieutenant",
	[3] = "Captain",
	[4] = "Major",
};
inv.ranks = {};
for rankID,rankName in ipairs(inv.ranksByID) do
	inv.ranks[rankName] = rankID;
end

inv.mobs = {
	-- Wave 1
	["Silithid Borer"] = 1,
	["Silithid Creeper"] = 1,
	["Silithid Stalker"] = 1,
	-- Wave 2
	["Silithid Ravager"] = 2,
	["Silithid Reaver"] = 2,
	["Silithid Spitfire"] = 2,
	-- Wave 3
	["Qiraji Mindbreaker"] = 3,
	["Qiraji Imperator"] = 3,
	["Qiraji Eviscerator"] = 3,
	-- Wave 4
	["Harbinger Nepharod"] = 4, -- Tall Thing
	["Harbinger Bhaelagor"] = 4, -- Beetle
	["The Swarm"] = 4, -- Beetle Adds
	["Harbinger Zen'tarim"] = 4, -- Sword Guy
	["Harbinger Varikesh"] = 4, -- Wasp
};

function inv.CheckGroup()
	local new = GetNumPartyMembers() + GetNumRaidMembers();
	if (new > 0) and (not inv.inGroup) then
		inv.inGroup = true;
		return true;
	elseif (new == 0) then
		inv.inGroup = false;
	end
end

function inv.GetGroup()
	if UnitInRaid("PLAYER") then
		return "RAID",GetNumRaidMembers();
	else
		return "PARTY",GetNumPartyMembers();
	end
end

function inv.GetPlayer(name)
	if (not inv.players[name]) then
		inv.players[name] = {};
	end
	return inv.players[name];
end

function inv.ScanRank(unit)
	for rankID,rankName in ipairs(inv.ranksByID) do
		if UnitAura(unit,rankName) then
			local name = UnitName(unit);
			return inv.SetRank(name,rankName);
		end
	end
end

function inv.ScanRanks()
	inv.ScanRank("PLAYER");
	local unit,count = inv.GetGroup();
	for i=1,count do
		inv.ScanRank(unit..i);
	end
end

function inv.NewInvasion()
	wipe(inv.players);
	inv.announced = false;
	inv.ScanRanks();
end

function inv.SetRank(name,rank)
	local player = inv.GetPlayer(name);
	if (player.rank ~= inv.ranks[rank]) then
		player.rank = inv.ranks[rank];
		player.current = nil;
		return true;
	end
end

function inv.CheckRank(unit)
	local name = UnitName(unit);
	inv.ScanRank(unit);
	local player = inv.GetPlayer(name);
	if player and (player.rank ~= inv.ranks["Major"]) and UnitIsConnected(unit) then
		local score = inv.GetScore(player);
		if score and (score < 160000) then
			return name.." ("..math.floor((score/160000)*100).."%)";
		end
		return name;
	end
end

function inv.CheckRanks(out)
	local unit,count = inv.GetGroup();
	if count and (count > 0) then
		local list;
		
		local name = inv.CheckRank("PLAYER");
		if name then
			list = (list and list..", " or "")..name;
		end
	
		for i=1,count do
			local name = inv.CheckRank(unit..i);
			if name then
				list = (list and list..", " or "")..name;
			end
		end
		
		if list then
			inv.announced = false;
			if out then
				SendChatMessage("[Invasion] Not Major: "..list,unit);
			end
		else
			if out or (not inv.announced) then
				inv.announced = true;
				SendChatMessage("[Invasion] Everyone is Major!",unit);
			end
		end
	end
end

function inv.IsRaidMember(flags)
	return (bit.band(flags,COMBATLOG_OBJECT_TYPE_PLAYER) > 0) and ((bit.band(flags,COMBATLOG_OBJECT_AFFILIATION_RAID) > 0) or (bit.band(flags,COMBATLOG_OBJECT_AFFILIATION_PARTY) > 0) or (bit.band(flags,COMBATLOG_OBJECT_AFFILIATION_MINE) > 0));
end

function inv.AddStat(name,stat,value)
	local player = inv.GetPlayer(name);
	if player.rank ~= inv.ranks["Major"] then
		player.total = player.total or {};
		player.current = player.current or {};
		if stat == 1 then -- damage done
			player.total.damage = (player.total.damage or 0) + value;
			player.current.damage = (player.current.damage or 0) + value;
		elseif stat == 2 then -- damage taken
			player.total.taken = (player.total.taken or 0) + value;
			player.current.taken = (player.current.taken or 0) + value;
		elseif stat == 3 then -- healing
			player.total.healing = (player.total.healing or 0) + value;
			player.current.healing = (player.current.healing or 0) + value;
		end
	end
end

function inv.GetScore(player)
	local scoreTotal;
	if player.total then
		scoreTotal = (player.total.damage or 0) + ((player.total.taken or 0)*1.25) + ((player.total.healing or 0)*1.5);
	end
	local scoreCurrent;
	if player.current then
		scoreCurrent = ((player.rank or 0)*40000) + (player.current.damage or 0) + ((player.current.taken or 0)*1.25) + ((player.current.healing or 0)*1.5);
	end
	if scoreTotal and scoreCurrent then
		return math.min(scoreTotal,scoreCurrent);
	else
		return scoreTotal or scoreCurrent;
	end
end

inv.frame = CreateFrame("Frame",nil,UIParent);
inv.frame:SetScript("OnEvent",function(self,event,...)
	if (event == "COMBAT_LOG_EVENT_UNFILTERED") then
		local _,subEvent,sourceGUID,sourceName,sourceFlags,destGUID,destName,destFlags,arg1,arg2,arg3,arg4,arg5,arg6,arg7,arg8 = ...;
		if subEvent == "SPELL_AURA_APPLIED" then -- or subEvent == "SPELL_AURA_REFRESH"
			if inv.ranks[arg2] then
				inv.SetRank(destName,arg2);
				inv.CheckRanks();
			end
		else
			local amount;
			if subEvent == "SWING_DAMAGE" then
				amount = arg1 or 0;
			end
			if inv.IsRaidMember(sourceFlags) and inv.mobs[destName] and subEvent:find("_DAMAGE$") then
				amount = amount or arg4 or 0;
				inv.AddStat(sourceName,1,amount);
			elseif inv.IsRaidMember(destFlags) and inv.mobs[sourceName] and subEvent:find("_DAMAGE$") then
				amount = amount or arg4 or 0;
				inv.AddStat(destName,2,amount);
			elseif inv.IsRaidMember(sourceFlags) and subEvent:find("_HEAL$") then
				amount = amount or ((arg4 or 0)-(arg5 or 0)) or 0;
				inv.AddStat(sourceName,3,amount);
			end
		end
	elseif (event == "ZONE_CHANGED_NEW_AREA") or (event == "ZONE_CHANGED") then
		inv.NewInvasion();
		--inv.CheckRanks();
	elseif (event == "PLAYER_ENTERING_WORLD") or (event == "PARTY_MEMBERS_CHANGED") or (event == "RAID_ROSTER_UPDATE") then
		if inv.CheckGroup() then
			inv.NewInvasion();
			--inv.CheckRanks();
		end
	elseif (event == "CHAT_MSG_RAID_BOSS_EMOTE") then
		local msg,boss = ...;
		if boss == "AQ Invasion Controller" then
			if msg == "You have successfully ended the invasion." then
				inv.NewInvasion();
				--inv.CheckRanks();
			elseif (msg == "Qiraji reinforcements are arriving in 15 seconds. Prepare yourself. Hero!") or (msg == "A Qiraji Harbinger is approaching. Steel your resolve and end this invasion, once and for all!") then
				
			end
		end		
	end
end);
inv.frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED");
--inv.frame:RegisterEvent("UNIT_AURA");
inv.frame:RegisterEvent("ZONE_CHANGED_NEW_AREA");
--inv.frame:RegisterEvent("ZONE_CHANGED");
inv.frame:RegisterEvent("PLAYER_ENTERING_WORLD");
inv.frame:RegisterEvent("PARTY_MEMBERS_CHANGED");
inv.frame:RegisterEvent("RAID_ROSTER_UPDATE");
inv.frame:RegisterEvent("CHAT_MSG_RAID_BOSS_EMOTE");

SLASH_INVASION1 = "/invasion";
SLASH_INVASION2 = "/major";
SlashCmdList["INVASION"] = function(msg)
	inv.CheckRanks(true);
end