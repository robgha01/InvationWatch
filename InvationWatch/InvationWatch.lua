InvationWatch = LibStub("AceAddon-3.0"):NewAddon("InvationWatch", "AceConsole-3.0", "AceEvent-3.0", "AceComm-3.0", "AceTimer-3.0", "AceSerializer-3.0", "AceHook-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("InvationWatch", false)
local LDB = LibStub:GetLibrary("LibDataBroker-1.1")
local LDBIcon = LDB and LibStub("LibDBIcon-1.0", true)
local tooltip
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

local function Reset()
	wipe(InvationWatch.Who)
end

-- LDB launcher
InvationWatch.Minimap = {
	LDBObject = LDB:NewDataObject(
		"InvationWatch",
		{
			type = "launcher",
				
			icon = InvationWatch.iconpaths.ON,
			text = "InvationWatch",
				
			OnClick = function(clickedframe, button)
				if button == "RightButton" then 
					Reset()
					print("[InvationWatch] Invation wiped")
				else 
					InvationWatchSavedData.RankWatchEnabled = not InvationWatchSavedData.RankWatchEnabled
					InvationWatch:MinimapButton_Refresh()
				end
			end,
			
			OnTooltipShow = function(tt)
				tooltip = tt
				local line = "InvationWatch"
				if InvationWatchSavedData.RankWatchEnabled then
					line = line..tostring(InvationWatch.Colors.Minimap.ON)..L[" is ON"]
				else
					line = line..tostring(InvationWatch.Colors.Minimap.OFF)..L[" is OFF"]
				end
				tt:AddLine(line)
				tt:AddLine(tostring(InvationWatch.Colors.Minimap.Click) .. L["Click|r to toggle InvationWatch on/off"])
				tt:AddLine(tostring(InvationWatch.Colors.Minimap.Click) .. L["Type|r /iw to report who is not Major"])				
				tt:AddLine(tostring(InvationWatch.Colors.Minimap.Click) .. L["Right-click|r to force removal of current invation data"])
			end,
		}
	)
}
 
local function SafeMsg(text, linewidth)
    if not linewidth then
        linewidth = 35
    end
 
    local spaceleft = linewidth
    local res = {}
    local line = {}
	local function splittokens(s)
		local res = {}
		for w in s:gmatch("%S+") do
			res[#res+1] = w
		end
		return res
	end
 
    for _, word in ipairs(splittokens(text)) do
        if #word + 1 > spaceleft then
            table.insert(res, table.concat(line, ' '))
            line = {word}
            spaceleft = linewidth - #word
        else
            table.insert(line, word)
            spaceleft = spaceleft - (#word + 1)
        end
    end
 
    table.insert(res, table.concat(line, ' '))
    return res
end

function InvationWatch:Debug(msg, ...)
	if InvationWatch._debug then
		msg = "[IW] "..msg
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
		-- split the message if over 250 chars
		for i, m in ipairs(SafeMsg(msg, 35)) do
			SendChatMessage(m, chatType)
		end
	end
end

function InvationWatch:GetUnitInvationRank(unitID)
	if unitID == nil or UnitIsPlayer(unitID) == false then return end
	for index, rank in ipairs(InvationWatch.Ranks) do
		if UnitAura(unitID, rank) then
			return index
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
	local n,g;
	local unitName = ""

	-- Update self
	InvationWatch:UpdateUnitRank("PLAYER")
	
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
			if UnitIsConnected(unitID) then
				unitName = UnitName(unitID)				
				InvationWatch:UpdateUnitRank(unitID)
			end
		end
	end
end

function InvationWatch:WhoNotMajor()
	InvationWatch:ScanInvationRanks()
	if InvationWatch.Who == nil then return end	
	local whoMsg = ""
	
	for name, rank in pairs(InvationWatch.Who) do
		local newRank, oldRank = InvationWatch:UpdateUnitRank(name)
		if newRank == -1 then newRank = oldRank end
		if newRank ~= 3 then
			local msgWithRank = "%s (%s), %s"
			local msgNoRank = "%s, %s"
			if newRank == -1 then
				whoMsg = format(msgNoRank, name, whoMsg)				
			else
				whoMsg = format(msgWithRank, name, InvationWatch.Ranks[newRank], whoMsg)				
			end
		else
			InvationWatch:Debug(name.." has major ?", newRank == 3, newRank, InvationWatch.Ranks[newRank], InvationWatch.Ranks[3])
		end
	end

	whoMsg = whoMsg:sub(1, #whoMsg - 2)
	if whoMsg ~= "" then
		whoMsg = format(L["Not Major: %s"], whoMsg)
	else
		whoMsg = L["Everyone is Major!"]
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
	elseif input:trim() == "reset" then
		Reset()
		print("[InvationWatch] Invation wiped")
	end
end

function InvationWatch:RegisterChatCmd()
	InvationWatch:RegisterChatCommand("iw", ChatCmd)
	InvationWatch:RegisterChatCommand("invationwatch", ChatCmd)
end

function InvationWatch:CleanupWho()
	for name, rank in pairs(InvationWatch.Who) do
		local inGroup = false
		if UnitInRaid("PLAYER") then
			inGroup = UnitInRaid(name)
		else
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
			local msg = format(L["%s is now Major"], name)
			InvationWatch:BroadcastMessage(msg)			
		end	
	end
end

function InvationWatch:CheckState()
	InvationWatch:CleanupWho()
	if UnitInRaid("PLAYER") == nil then
		-- No longer in raid
		InvationWatch:RegisterEvent("PARTY_MEMBERS_CHANGED", "CheckState")
	end
end

function InvationWatch:PARTY_CONVERTED_TO_RAID()
	InvationWatch:UnregisterEvent("PARTY_MEMBERS_CHANGED")
	InvationWatch:RegisterEvent("RAID_ROSTER_UPDATE", "CheckState")
end

function InvationWatch:PLAYER_ENTERING_WORLD()
	InvationWatch:CheckState()
	InvationWatch:RegisterEvent("UNIT_AURA")
	InvationWatch:RegisterEvent("PARTY_MEMBERS_CHANGED","CheckState")
	InvationWatch:RegisterEvent("PARTY_CONVERTED_TO_RAID")
	InvationWatch:RegisterEvent("ZONE_CHANGED_NEW_AREA","CheckState")
	InvationWatch:MinimapButton_Refresh()
end

function InvationWatch:MinimapButton_Refresh()
	if InvationWatchSavedData.RankWatchEnabled then
		InvationWatch.Minimap.LDBObject.icon = SpeakinSpell.iconpaths.ON
	else
		InvationWatch.Minimap.LDBObject.icon = SpeakinSpell.iconpaths.OFF
	end
end