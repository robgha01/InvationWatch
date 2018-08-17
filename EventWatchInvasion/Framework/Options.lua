-- Saved Data Format and Defaults
EventWatchInvasionSavedData = {
	MinimapIcon = {
		hide = false, --LibDBIcon's internal state data mirrors our own option ShowMinimapButton listed above
		minimapPos = 220,
		radius = 80,
	},
}

-- Constants
EventWatchInvasion.Ranks = {
	[0] = "Private",	
	[1] = "Lieutenant",
	[2] = "Captain",
	[3] = "Major",
}
EventWatchInvasion.Who = {}
EventWatchInvasion.Colors = {	
	EventWatchInvasion	= "|cff33ff99",
	
	-- minimap button ON/OFF colors
	Minimap = {
		ON			= "|cff00ff00", -- green
		OFF			= "|cffff0000", -- red
		Click		= "|cffffff00", -- highlights text around "Click" and "Right-Click" in the tooltip
	},
}

-- LDB launcher
EventWatchInvasion.iconpaths = {
	ON = "Interface\\Icons\\Ability_Warrior_BattleShout", --recognizable i guess
	OFF = "Interface\\Icons\\Ability_Rogue_Disguise", --this is OK for off
}
EventWatchInvasion.Minimap = {
	LDBObject = LDB:NewDataObject(
		"EventWatchInvasion",
		{
			type = "launcher",
				
			icon = EventWatchInvasion.iconpaths.ON,
			text = "EventWatchInvasion",
				
			OnClick = function(clickedframe, button)
				if button == "RightButton" then 
					Reset()
					print("[EventWatchInvasion] Invasion wiped")
				else 
					EventWatchInvasionSavedData.RankWatchEnabled = not EventWatchInvasionSavedData.RankWatchEnabled
					EventWatchInvasion:MinimapButton_Refresh()
				end
			end,
			
			OnTooltipShow = function(tt)
				tooltip = tt
				local line = "EventWatchInvasion"
				if EventWatchInvasionSavedData.RankWatchEnabled then
					line = line..tostring(EventWatchInvasion.Colors.Minimap.ON)..L[" is ON"]
				else
					line = line..tostring(EventWatchInvasion.Colors.Minimap.OFF)..L[" is OFF"]
				end
				tt:AddLine(line)
				tt:AddLine(tostring(EventWatchInvasion.Colors.Minimap.Click) .. L["Click|r to toggle EventWatchInvasion on/off"])
				tt:AddLine(tostring(EventWatchInvasion.Colors.Minimap.Click) .. L["Type|r /iw to report who is not Major"])				
				tt:AddLine(tostring(EventWatchInvasion.Colors.Minimap.Click) .. L["Right-click|r to force removal of current invation data"])
			end,
		}
	)
}