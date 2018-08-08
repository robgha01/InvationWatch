InvationWatch = LibStub("AceAddon-3.0"):NewAddon("InvationWatch", "AceConsole-3.0", "AceEvent-3.0", "AceComm-3.0", "AceTimer-3.0", "AceSerializer-3.0", "AceHook-3.0");
InvationWatch._debug = true
InvationWatch.Ranks = {
	[0] = "Private",	
	[1] = "Lieutenant",
	[2] = "Captain",
	[3] = "Major",
}

function InvationWatch:Debug(msg, ...)
	if InvationWatch._debug then
		if ViragDevTool_AddData then
			ViragDevTool_AddData({...}, msg)
		else
			print(msg, ...)
		end
	end
end

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
	InvationWatch:Debug("GetGroupInvationRanks")
	local numRaid, numParty = GetNumRaidMembers(), GetNumPartyMembers()
	local who = {}
	local n = nil
	local g = nil
	local buffIndex = 1
	local buffName = ""
	local unitName = UnitName("player")

	-- Include self
	InvationWatch:Debug("Checking self:")
	while true do
		buffName = UnitBuff("player", buffIndex)
		InvationWatch:Debug("buffIndex "..buffIndex)
		
		if not buffName then
			break;
		end
		
		InvationWatch:Debug("buffName "..buffName)	
		InvationWatch:Debug("Checking ranks")
		for index, rank in ipairs(InvationWatch.Ranks) do
			local isRank = rank == buffName
			InvationWatch:Debug("Is " .. rank .. " " .. tostring(isRank))
			if isRank then
				who[unitName] = index
				InvationWatch:Debug("adding "..unitName.." to list", who)
			end
		end

		buffIndex = buffIndex + 1;
	end

	if numRaid > 1 then
		n = numRaid
		g = "raid"
	elseif numParty > 0 then
		n = numParty
		g = "party"
	else
		return nil
	end
	
	InvationWatch:Debug("Group "..g)
	InvationWatch:Debug("Num players "..n)

	for i = 1, n do
		buffIndex = 1;
		buffName = "";
		local gIndex = g..i
		unitName = UnitName(gIndex)
		who[unitName] = nil
		InvationWatch:Debug("Checking "..unitName..":")

		while true do
			buffName = UnitBuff(gIndex, buffIndex)
			InvationWatch:Debug("buffIndex "..buffIndex)
			
			if not buffName then
				break;
			end
			
			InvationWatch:Debug("buffName "..buffName)
			InvationWatch:Debug("Checking ranks")
			for index, rank in ipairs(InvationWatch.Ranks) do
				local isRank = rank == buffName
				InvationWatch:Debug("Is " .. rank .. " " .. tostring(isRank))
				if isRank then
					who[unitName] = index
					InvationWatch:Debug("adding "..unitName.." to list", who)
				end
			end

			buffIndex = buffIndex + 1;
		end

		if who[unitName] == nil then
			InvationWatch:Debug("No rank found for "..unitName)
			who[unitName] = -1
		end
	end

	InvationWatch:Debug("GetGroupInvationRanks:Returning", who)
	return who
end

local function WhoNotMajor()
	local playerRanks = GetGroupInvationRanks()
	if playerRanks == nil then
		return
	end
	
	local whoMsg = ""
	for name, rank in pairs(playerRanks) do
		InvationWatch:Debug("Has major ?", rank == InvationWatch.Ranks[3])
		if rank ~= InvationWatch.Ranks[3] then
			whoMsg = whoMsg .. name .. ", "
		end
	end

	whoMsg = whoMsg:sub(1, #whoMsg - 2)
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