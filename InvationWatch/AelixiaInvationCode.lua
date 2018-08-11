-- by Aelixia https://pastebin.com/bDTL4MG7
local majors = {};
local isInGroup = false;
local majorBuff = "Major";

local function ResetMajors()
	wipe(majors);
end

local function SetMajor(name)
	majors[name] = true;
end

local function CheckPlayer(unit)
	local name = UnitName(unit);
	if name and (not majors[name]) and UnitIsConnected(unit) then
		if UnitAura(unit,majorBuff) then
			SetMajor(name);
		else
			return name;
		end
	end
end

local function CheckMajors(out)
	local n,g;
	if UnitInRaid("PLAYER") then
		n = GetNumRaidMembers();
		g = "RAID";
	else
		n = GetNumPartyMembers();
		g = "PARTY";
	end
	if n > 0 then
		local list;
		local name = CheckPlayer("PLAYER");
		if name then
			list = (list and list..", " or "")..name;
		end
		for i=1,n do
			local name = CheckPlayer(g..i);
			if name then
				list = (list and list..", " or "")..name;
			end
		end
		if list then
			if out then
				SendChatMessage("[Invasion] Not Major: "..list,g);
			end
		else
			if out or (not majors.__complete) then
				majors.__complete = true;
				SendChatMessage("[Invasion] Everyone is Major!",g);
			end
		end
	end
end

local function CheckGroup()
	local new = GetNumPartyMembers() + GetNumRaidMembers();
	if (new > 0) and (not isInGroup) then
		isInGroup = true;
		return true;
	elseif (new == 0) then
		isInGroup = false;
	end
end

local frame = CreateFrame("Frame",nil,UIParent);
frame:SetScript("OnEvent",function(self,event,...)
	if (event == "COMBAT_LOG_EVENT_UNFILTERED") then
		local _,subEvent,sourceGUID,sourceName,sourceFlags,destGUID,destName,destFlags,spellID,spellName,spellSchool,auraType = ...;
		if subEvent == "SPELL_AURA_APPLIED" then -- or subEvent == "SPELL_AURA_REFRESH"
			if spellName == majorBuff then
				SetMajor(destName);
				CheckMajors();
			end
		end
	elseif (event == "ZONE_CHANGED_NEW_AREA") or (event == "ZONE_CHANGED") then
		ResetMajors();
		--CheckMajors();
	elseif (event == "PLAYER_ENTERING_WORLD") or (event == "PARTY_MEMBERS_CHANGED") or (event == "RAID_ROSTER_UPDATE") then
		if CheckGroup() then
			ResetMajors();
			--CheckMajors();
		end
	elseif (event == "CHAT_MSG_RAID") or (event == "CHAT_MSG_RAID_LEADER") or (event == "CHAT_MSG_PARTY") or (event == "CHAT_MSG_PARTY_LEADER") then
		local msg,author = ...;
		msg = msg:lower();
		if msg:find("major") then
			if (msg:find("who") or msg:find("anyone")) and msg:find("need") then
				CheckMajors(true);
			elseif msg:find("who") and ((msg:find("not") and (msg:find("is") or msg:find("are"))) or msg:find("isn'?t")) then
				CheckMajors(true);
			elseif msg:find("%?") and msg:find("everyone") then -- and (msg:find("got") or msg:find("has"))
				CheckMajors(true);
			end
		end
	end
end);

frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED");
frame:RegisterEvent("ZONE_CHANGED_NEW_AREA");
--frame:RegisterEvent("ZONE_CHANGED");
--frame:RegisterEvent("CHAT_MSG_RAID");
--frame:RegisterEvent("CHAT_MSG_RAID_LEADER");
--frame:RegisterEvent("CHAT_MSG_PARTY");
--frame:RegisterEvent("CHAT_MSG_PARTY_LEADER");
frame:RegisterEvent("PLAYER_ENTERING_WORLD");
frame:RegisterEvent("PARTY_MEMBERS_CHANGED");
frame:RegisterEvent("RAID_ROSTER_UPDATE");

SLASH_INVASION1 = "/invasion";
SLASH_INVASION2 = "/major";
SlashCmdList["INVASION"] = function(msg)
	CheckMajors(true);
end