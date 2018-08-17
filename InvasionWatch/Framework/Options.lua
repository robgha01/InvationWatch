-- Saved Data Format and Defaults
InvasionWatchSavedData = {
	MinimapIcon = {
		hide = false, --LibDBIcon's internal state data mirrors our own option ShowMinimapButton listed above
		minimapPos = 220,
		radius = 80,
	},
}

-- Constants
InvasionWatch.Ranks = {
	[0] = "Private",	
	[1] = "Lieutenant",
	[2] = "Captain",
	[3] = "Major",
}
InvasionWatch.Who = {}
InvasionWatch.Colors = {	
	InvasionWatch	= "|cff33ff99",
	
	-- minimap button ON/OFF colors
	Minimap = {
		ON			= "|cff00ff00", -- green
		OFF			= "|cffff0000", -- red
		Click		= "|cffffff00", -- highlights text around "Click" and "Right-Click" in the tooltip
	},
}

-- LDB launcher
InvasionWatch.iconpaths = {
	ON = "Interface\\Icons\\Ability_Warrior_BattleShout", --recognizable i guess
	OFF = "Interface\\Icons\\Ability_Rogue_Disguise", --this is OK for off
}
InvasionWatch.Minimap = {
	LDBObject = LDB:NewDataObject(
		"InvasionWatch",
		{
			type = "launcher",
				
			icon = InvasionWatch.iconpaths.ON,
			text = "InvasionWatch",
				
			OnClick = function(clickedframe, button)
				if button == "RightButton" then 
					Reset()
					print("[InvasionWatch] Invasion wiped")
				else 
					InvasionWatchSavedData.RankWatchEnabled = not InvasionWatchSavedData.RankWatchEnabled
					InvasionWatch:MinimapButton_Refresh()
				end
			end,
			
			OnTooltipShow = function(tt)
				tooltip = tt
				local line = "InvasionWatch"
				if InvasionWatchSavedData.RankWatchEnabled then
					line = line..tostring(InvasionWatch.Colors.Minimap.ON)..L[" is ON"]
				else
					line = line..tostring(InvasionWatch.Colors.Minimap.OFF)..L[" is OFF"]
				end
				tt:AddLine(line)
				tt:AddLine(tostring(InvasionWatch.Colors.Minimap.Click) .. L["Click|r to toggle InvasionWatch on/off"])
				tt:AddLine(tostring(InvasionWatch.Colors.Minimap.Click) .. L["Type|r /iw to report who is not Major"])				
				tt:AddLine(tostring(InvasionWatch.Colors.Minimap.Click) .. L["Right-click|r to force removal of current invation data"])
			end,
		}
	)
}