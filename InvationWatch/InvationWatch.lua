InvationWatch = LibStub("AceAddon-3.0"):NewAddon("InvationWatch", "AceConsole-3.0", "AceEvent-3.0", "AceComm-3.0", "AceTimer-3.0", "AceSerializer-3.0", "AceHook-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("InvationWatch", false)
local LDB = LibStub:GetLibrary("LibDataBroker-1.1")
local LDBIcon = LDB and LibStub("LibDBIcon-1.0", true)
InvationWatch._debug = true
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

function InvationWatch:ScanInvationRanks()
	--InvationWatch:Debug("ScanInvationRanks")
	local numRaid, numParty = GetNumRaidMembers(), GetNumPartyMembers()
	local n = nil
	local g = nil
	local buffName = ""
	local unitName = UnitName("player")

	-- Start check player
	InvationWatch:Debug("Checking InvationWatch:")
	for b = 1, 40 do
		local ua = {UnitAura("player", b)}
		local buffName,rank,icon,count,dispelType,duration,expires,caster,isStealable,spellId = ua[1],ua[2],ua[3],ua[4],ua[5],ua[6],ua[7],ua[8],ua[10],ua[11]
		if not spellId then break end
		
		--InvationWatch:Debug("buffName "..buffName)	
		--InvationWatch:Debug("Checking ranks")
		for index, rank in ipairs(InvationWatch.Ranks) do
			local isRank = rank == buffName
			--InvationWatch:Debug("Is " .. rank .. " " .. tostring(isRank))
			if isRank then
				InvationWatch.Who[unitName] = index
				InvationWatch:Debug("adding "..unitName.." to list", InvationWatch.Who)
				break
			end
		end
	end

	if InvationWatch.Who[unitName] == nil then
		InvationWatch:Debug("No rank found for "..unitName)
		InvationWatch.Who[unitName] = nil
	end
	-- End check player

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
		buffName = "";
		local unitID = g..i

		if UnitIsConnected(unitID) then
			unitName = UnitName(unitID)
			--InvationWatch:Debug("Checking "..unitName..":")
			for b = 1, 40 do
				local ua = {UnitAura(unitID, b)}
				local buffName,rank,icon,count,dispelType,duration,expires,caster,isStealable,spellId = ua[1],ua[2],ua[3],ua[4],ua[5],ua[6],ua[7],ua[8],ua[10],ua[11]
				if not spellId then break end		
						
				--InvationWatch:Debug("buffName "..buffName)
				--InvationWatch:Debug("Checking ranks")
				for index, rank in ipairs(InvationWatch.Ranks) do
					local isRank = rank == buffName
					--InvationWatch:Debug("Is " .. rank .. " " .. tostring(isRank), buffName)
					if isRank then
						InvationWatch.Who[unitName] = index
						InvationWatch:Debug("adding "..unitName.." to list", who)
						break
					end
				end
			end

			if InvationWatch.Who[unitName] == nil then
				--InvationWatch:Debug("No rank found for "..unitName)
				InvationWatch.Who[unitName] = -1		
			end
		end
	end
end

function InvationWatch:WhoNotMajor()
	InvationWatch:ScanInvationRanks()
	if InvationWatch.Who == nil then return end	
	local whoMsg = ""
	for name, rank in pairs(InvationWatch.Who) do
		--InvationWatch:Debug("Has major ?", rank == InvationWatch.Ranks[3])
		if rank ~= InvationWatch.Ranks[3] then
			local msgWithRank = "%s (%s), %s"
			local msgNoRank = "%s, %s"
			if rank == -1 then
				whoMsg = format(msgNoRank, name, whoMsg)
			else
				whoMsg = format(msgNoRank, name, InvationWatch.Ranks[rank], whoMsg)				
			end			
		end
	end

	whoMsg = whoMsg:sub(1, #whoMsg - 2)
	if whoMsg ~= "" then
		whoMsg = format(L["Not Major: %s"], whoMsg)
	else
		whoMsg = L["Everyone is major"]
	end

	local numRaid, numParty = GetNumRaidMembers(), GetNumPartyMembers()
	if numRaid > 1 then
		SendChatMessage(whoMsg, "RAID")		
	elseif numParty > 0 then
		SendChatMessage(whoMsg, "PARTY")		
	end
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
end

--local whoUnitRank = {}
function InvationWatch:UNIT_AURA(_, unitID)
	if InvationWatchSavedData.RankWatchEnabled == false then return end
	
	local foundRank = false
	local unitName = UnitName(unitID)
	for i = 1, 40 do
		local ua = {UnitAura(unitID, i)}
		local name,rank,icon,count,dispelType,duration,expires,caster,isStealable,spellId = ua[1],ua[2],ua[3],ua[4],ua[5],ua[6],ua[7],ua[8],ua[10],ua[11]
		if not spellId then break end
		for index, rank in ipairs(InvationWatch.Ranks) do
			local isRank = rank == name
			if isRank then
				--InvationWatch:Debug("UNIT_AURA " .. rank .. " " .. tostring(isRank))
				foundRank = true
				if InvationWatch.Who[unitName] ~= nil and InvationWatch.Who[unitName] == 2 and index == 3 then
					local numRaid, numParty = GetNumRaidMembers(), GetNumPartyMembers()
					local msg = format("%s is now Major", unitName)
					if numRaid > 1 then
						SendChatMessage(msg, "RAID")
					elseif numParty > 0 then
						SendChatMessage(msg, "PARTY")
					end
				end
				InvationWatch.Who[unitName] = index
			end
		end
	end
	if foundRank == false and InvationWatch.Who[unitName] ~= nil then
		InvationWatch.Who[unitName] = -1
	end
end

function InvationWatch:PLAYER_ENTERING_WORLD()
	InvationWatch:RegisterEvent("UNIT_AURA")
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