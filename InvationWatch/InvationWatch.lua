InvationWatch = LibStub("AceAddon-3.0"):NewAddon("InvationWatch", "AceConsole-3.0", "AceEvent-3.0", "AceComm-3.0", "AceTimer-3.0", "AceSerializer-3.0", "AceHook-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("InvationWatch", false)
local LDB = LibStub:GetLibrary("LibDataBroker-1.1")
local LDBIcon = LDB and LibStub("LibDBIcon-1.0", true)
InvationWatch._debug = false
InvationWatch.Ranks = {
	[0] = "Private",	
	[1] = "Lieutenant",
	[2] = "Captain",
	[3] = "Major",
}
InvationWatch.Who = {}
InvationWatch.Colors = {	
	InvationWatch	= "|cff33ff99",
	
	-- minimap button ON/OFF colors
	Minimap = {
		ON			= "|cff00ff00", -- green
		OFF			= "|cffff0000", -- red
		Click		= "|cffffff00", -- highlights text around "Click" and "Right-Click" in the tooltip
	},
}
-- define which icons we'll use
InvationWatch.iconpaths = {
	ON = "Interface\\Icons\\Ability_Warrior_BattleShout", --recognizable i guess
	OFF = "Interface\\Icons\\Ability_Rogue_Disguise", --this is OK for off
}
-- LDB launcher
InvationWatch.Minimap = {
	LDBObject = LDB:NewDataObject(
		"InvationWatch",
		{
			type = "launcher",
				
			icon = InvationWatch.iconpaths.ON,
			text = "InvationWatch",
				
			OnClick = function(clickedframe, button)
				InvationWatchSavedData.RankWatchEnabled = not InvationWatchSavedData.RankWatchEnabled
				InvationWatch:MinimapButton_Refresh()
			end,
				
			OnTooltipShow = function(tt)
				local line = "InvationWatch"
				if InvationWatchSavedData.RankWatchEnabled then
					line = line..tostring(InvationWatch.Colors.Minimap.ON)..L[" is ON"]
				else
					line = line..tostring(InvationWatch.Colors.Minimap.OFF)..L[" is OFF"]
				end
				tt:AddLine(line)
				tt:AddLine( tostring(InvationWatch.Colors.Minimap.Click) .. L["Click|r to toggle InvationWatch on/off"])
				tt:AddLine( tostring(InvationWatch.Colors.Minimap.Click) .. L["Type|r /iw to report who is not Major"])				
				--tt:AddLine( tostring(InvationWatch.Colors.Minimap.Click) .. L["Right-click|r to open the options"])
			end,
		}
	)
}

function InvationWatch:Debug(msg, ...)
	if InvationWatch._debug then
		msg = "[InvationWatch] "..msg
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
	InvationWatch:RegisterEvent("PLAYER_ENTERING_WORLD")
end

function InvationWatch:OnEnable()
	-- Called when the addon is enabled
end

function InvationWatch:OnDisable()
	-- Called when the addon is disabled
end

function InvationWatch:BroadcastMessage(msg)
	local chatType = "PARTY"
	if GetRealNumRaidMembers() > 1 then chatType = "RAID" end
	if InvationWatch._debug then
		print(msg)
	else
		SendChatMessage(msg, chatType)
	end
end

function InvationWatch:GetUnitInvationRank(unitID)
	if unitID == nil or UnitIsPlayer(unitID) == false then return end
	local unitName = UnitName(unitID)
	
	for b = 1, 40 do
		local ua = {UnitAura(unitID, b)}
		local name,rank,icon,count,dispelType,duration,expires,caster,isStealable,spellId = ua[1],ua[2],ua[3],ua[4],ua[5],ua[6],ua[7],ua[8],ua[10],ua[11]
		if not spellId then break end
		for index, rank in ipairs(InvationWatch.Ranks) do
			local isRank = rank == name
			if isRank then return index end
		end
	end

	return -1
end

function InvationWatch:UpdateUnitRank(unitID)
	local newRank = InvationWatch:GetUnitInvationRank(unitID)
	local oldRank = InvationWatch.Who[UnitName(unitID)]

	if newRank ~= -1 then
		InvationWatch.Who[UnitName(unitID)] = newRank
	end	

	return newRank, oldRank
end

function InvationWatch:ScanInvationRanks()
	local numRaid, numParty = GetRealNumRaidMembers(), GetRealNumPartyMembers()
	local n,g = nil,nil
	local unitName = ""

	-- Update self
	InvationWatch:UpdateUnitRank("player")
	--InvationWatch.Who[UnitName("player")] = InvationWatch:GetUnitInvationRank("player")
		
	if numRaid > 1 then
		n = numRaid
		g = "raid"
	elseif numParty > 0 then
		n = numParty
		g = "party"
	else
		return nil
	end
	
	--InvationWatch:Debug("Group "..g)
	--InvationWatch:Debug("Num players "..n)
	for i = 1, n do
		local unitID = g..i
		if UnitIsConnected(unitID) then
			unitName = UnitName(unitID)
			--InvationWatch.Who[unitName] = InvationWatch:GetUnitInvationRank(unitID)
			InvationWatch:UpdateUnitRank(unitID)
		end
	end
end

function InvationWatch:WhoNotMajor()
	InvationWatch:ScanInvationRanks()
	if InvationWatch.Who == nil then return end	
	local whoMsg = ""
	for name, _ in pairs(InvationWatch.Who) do
		local newRank, oldRank = InvationWatch:UpdateUnitRank(name)
		if newRank == -1 then newRank = oldRank end
		if newRank ~= 3 then
			local msgWithRank = "%s (%s), %s"
			local msgNoRank = "%s, %s"
			if rank == -1 then
				whoMsg = format(msgNoRank, name, whoMsg)
			else
				whoMsg = format(msgWithRank, name, InvationWatch.Ranks[rank], whoMsg)				
			end
		else
			InvationWatch:Debug(name.." has major ?", newRank == 3, newRank, InvationWatch.Ranks[newRank], InvationWatch.Ranks[3])
		end
	end

	whoMsg = whoMsg:sub(1, #whoMsg - 2)
	if whoMsg ~= "" then
		whoMsg = format(L["Not Major: %s"], whoMsg)
	else
		whoMsg = L["Everyone is major"]
	end
	InvationWatch:BroadcastMessage(whoMsg)
end

local function ChatCmd(input)
	if not input or input:trim() == "" then
		InvationWatch:WhoNotMajor()
	elseif input:trim() == "debug" then
		InvationWatch._debug = not InvationWatch._debug
	elseif input:trim() == "toggle" then
		InvationWatchSavedData.RankWatchEnabled = not InvationWatchSavedData.RankWatchEnabled
		InvationWatch:MinimapButton_Refresh()
	end
end

function InvationWatch:RegisterChatCmd()
	InvationWatch:RegisterChatCommand("iw", ChatCmd)
	InvationWatch:RegisterChatCommand("invationwatch", ChatCmd)
end

function InvationWatch:CleanupWho()
	local numRaid, numParty = GetRealNumRaidMembers(), GetRealNumPartyMembers()
	for name, rank in pairs(InvationWatch.Who) do
		local inGroup = false
		if numRaid > 1 then		
			inGroup = UnitInRaid(name)
		elseif numParty > 0 then
			inGroup = UnitInParty(name)
		end
		if inGroup == false then
			InvationWatch.Who[name] = nil -- Remove non existing players
		end
	end
end

function InvationWatch:UNIT_AURA(_, unitID)
	if InvationWatchSavedData.RankWatchEnabled == false then return end
	if unitID then
		local name = UnitName(unitID)
		local newRank, oldRank = InvationWatch:UpdateUnitRank(unitID)
		
		if oldRank == 2 and newRank == 3 then
			local numRaid, numParty = GetNumRaidMembers(), GetNumPartyMembers()
			local msg = format(L["%s is now Major"], name)
			--InvationWatch:BroadcastMessage(msg)
			local chatType = "PARTY"
			if GetRealNumRaidMembers() > 1 then chatType = "RAID" end
			SendChatMessage(msg, chatType)
		end		
	end

	--local foundRank = false
	--local unitName = UnitName(unitID)
	--for i = 1, 40 do
	--	local ua = {UnitAura(unitID, i)}
	--	local name,rank,icon,count,dispelType,duration,expires,caster,isStealable,spellId = ua[1],ua[2],ua[3],ua[4],ua[5],ua[6],ua[7],ua[8],ua[10],ua[11]
	--	if not spellId then break end
	--	for index, rank in ipairs(InvationWatch.Ranks) do
	--		local isRank = rank == name
	--		if isRank then
	--			--InvationWatch:Debug("UNIT_AURA " .. rank .. " " .. tostring(isRank))
	--			foundRank = true
	--			if InvationWatch.Who[unitName] ~= nil and InvationWatch.Who[unitName] == 2 and index == 3 then
	--				local numRaid, numParty = GetNumRaidMembers(), GetNumPartyMembers()
	--				local msg = format("%s is now Major", unitName)
	--				if numRaid > 1 then
	--					SendChatMessage(msg, "RAID")
	--				elseif numParty > 0 then
	--					SendChatMessage(msg, "PARTY")
	--				end
	--			end
	--			InvationWatch.Who[unitName] = index
	--		end
	--	end
	--end
	--if InvationWatch.Who[unitName] == nil then
	--	InvationWatch.Who[unitName] = -1
	--end
end

function InvationWatch:PARTY_MEMBERS_CHANGED()
	InvationWatch:CleanupWho()
end

function InvationWatch:RAID_ROSTER_UPDATE()
	InvationWatch:CleanupWho()
	if UnitInRaid("player") == nil then
		-- No longer in raid
		InvationWatch:RegisterEvent("PARTY_MEMBERS_CHANGED")
	end
end

function InvationWatch:PARTY_CONVERTED_TO_RAID()
	InvationWatch:UnregisterEvent("PARTY_MEMBERS_CHANGED")
	InvationWatch:RegisterEvent("RAID_ROSTER_UPDATE")
end

function InvationWatch:PLAYER_ENTERING_WORLD()
	InvationWatch:RegisterEvent("UNIT_AURA")
	InvationWatch:RegisterEvent("PARTY_MEMBERS_CHANGED")
	InvationWatch:RegisterEvent("PARTY_CONVERTED_TO_RAID")
	InvationWatch:MinimapButton_Refresh()
end

function InvationWatch:MinimapButton_Refresh()
	-- make sure the correct icon is selected
	-- NOTE: do this even if 'ShowMinimapButton' option is disabled
	--		to support TitanPanel or other LDB frames
	if InvationWatchSavedData.RankWatchEnabled then
		InvationWatch.Minimap.LDBObject.icon = SpeakinSpell.iconpaths.ON
	else
		InvationWatch.Minimap.LDBObject.icon = SpeakinSpell.iconpaths.OFF
	end
end