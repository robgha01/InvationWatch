local I = LibStub("AceAddon-3.0"):GetAddon("EventWatchInvasion")

-- Saved Data Format and Defaults
EventWatchInvasionSavedData = {
	MinimapIcon = {
		hide = false, --LibDBIcon's internal state data mirrors our own option ShowMinimapButton listed above
		minimapPos = 220,
		radius = 80,
	},
}

--- Constants
I.ranksByID = {
	[1] = "Private",	
	[2] = "Lieutenant",
	[3] = "Captain",
	[4] = "Major",
}
I.ranks = {}

I.mobs = {
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
}

I.Colors = {
	EventWatchInvasion	= "|cff33ff99",
	
	-- minimap button ON/OFF colors
	Minimap = {
		ON			= "|cff00ff00", -- green
		OFF			= "|cffff0000", -- red
		Click		= "|cffffff00", -- highlights text around "Click" and "Right-Click" in the tooltip
	},
}

--- State

--[[
	rank: number
	current: {
		damage: number
		taken: number
		healing: number
	}
	total: {
		damage: number
		taken: number
		healing: number
	}
--]]
I.players = {}