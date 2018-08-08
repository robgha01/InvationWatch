InvationWatch = LibStub("AceAddon-3.0"):NewAddon("InvationWatch", "AceConsole-3.0", "AceEvent-3.0", "AceComm-3.0", "AceTimer-3.0", "AceSerializer-3.0", "AceHook-3.0");
InvationWatch.Ranks = {
	[0] = "Private",	
	[1] = "Lieutenant",
	[2] = "Captain",
	[3] = "Major",
}

function InvationWatch:OnInitialize()
	-- Called when the addon is loaded
	InvationWatch:RegisterChatCmd()
end

function InvationWatch:OnEnable()
	-- Called when the addon is enabled
end

function InvationWatch:OnDisable()
	-- Called when the addon is disabled
end

local function GetGroupInvationRanks()
	local numRaid, numParty = GetNumRaidMembers(), GetNumPartyMembers()
	local who = {}
	local n = nil
	local g = nil

	if numRaid > 1 then
		n = numRaid
		g = "raid"
	elseif numParty > 0 then
		n = numParty
		g = "party"
	else
		return nil
	end
		
	for i = 1, n do
		local buffIndex = 1;
		local buffName = "";
		local gIndex = g..i
		local unitName = UnitName(gIndex)
		who[unitName] = nil

		while true do
			buffName = UnitBuff(gIndex, buffIndex)

			if not buffName then
				break;
			end
						
			for index, rank in ipairs(InvationWatch.Ranks) do
				local isRank = rank == buffName
				if isRank then
					who[unitName] = index
				end
			end

			i = i + 1;
		end

		if who[unitName] == nil then
			who[unitName] = -1
		end
	end

	return who
end

local function WhoNotMajor()
	local playerRanks = GetGroupInvationRanks()

	if playerRanks == nil then
		return
	end
	
	local whoMsg = ""
	for name, rank in ipairs(playerRanks) do
		if rank ~= InvationWatch.Ranks[3] then
			whoMsg = whoMsg .. name .. ","
		end
	end

	if whoMsg ~= "" then
		print(whoMsg)
	end
end

local function ChatCmd(input)
	if not input or input:trim() == "" then
		WhoNotMajor()
	end
end

function InvationWatch:RegisterChatCmd()
	InvationWatch:RegisterChatCommand("iw", ChatCmd)
end