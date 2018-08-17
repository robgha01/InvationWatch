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
EventWatchInvasion.Colors = {	
	EventWatchInvasion	= "|cff33ff99",
	
	-- minimap button ON/OFF colors
	Minimap = {
		ON			= "|cff00ff00", -- green
		OFF			= "|cffff0000", -- red
		Click		= "|cffffff00", -- highlights text around "Click" and "Right-Click" in the tooltip
	},
}

-- State
EventWatchInvasion.Who = {}