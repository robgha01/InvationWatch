local LDB = LibStub:GetLibrary("LibDataBroker-1.1")
local LDBIcon = LDB and LibStub("LibDBIcon-1.0", true)
local L = LibStub("AceLocale-3.0"):GetLocale("EventWatchInvasion", false)

-- LDB launcher
EventWatchInvasion.iconpaths = {
	ON = "Interface\\Icons\\Ability_Warrior_BattleShout", --recognizable i guess
	OFF = "Interface\\Icons\\Ability_Rogue_Disguise", --this is OK for off
}

EventWatchInvasion.Minimap = {
	LDBObject = LDB:NewDataObject(
		L["Invasion"],
		{
			type = "launcher",
				
			icon = EventWatchInvasion.iconpaths.ON,
			text = L["Invasion"],
				
			OnClick = function(clickedframe, button)
				if button == "RightButton" then 
					Reset()
					print("["..L["Invasion"].."] Invasion wiped")
				else 
					EventWatchInvasionSavedData.RankWatchEnabled = not EventWatchInvasionSavedData.RankWatchEnabled
					EventWatchInvasion:MinimapButton_Refresh()
				end
			end,
			
			OnTooltipShow = function(tt)
				tooltip = tt
				local line = L["Invasion"]
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

function EventWatchInvasion:MinimapButton_Refresh()
	if EventWatchInvasionSavedData.RankWatchEnabled then
		EventWatchInvasion.Minimap.LDBObject.icon = EventWatchInvasion.iconpaths.ON
	else
		EventWatchInvasion.Minimap.LDBObject.icon = EventWatchInvasion.iconpaths.OFF
	end
end