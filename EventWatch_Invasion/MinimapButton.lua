local I = LibStub("AceAddon-3.0"):GetAddon("EventWatchInvasion")
local LDB = LibStub:GetLibrary("LibDataBroker-1.1")
local LDBIcon = LDB and LibStub("LibDBIcon-1.0", true)
local L = LibStub("AceLocale-3.0"):GetLocale("EventWatchInvasion", false)

-- LDB launcher
I.iconpaths = {
	ON = "Interface\\Icons\\Ability_Warrior_BattleShout", --recognizable i guess
	OFF = "Interface\\Icons\\Ability_Rogue_Disguise", --this is OK for off
}

I.Minimap = {
	LDBObject = LDB:NewDataObject(
		L["Invasion"],
		{
			type = "launcher",
				
			icon = I.iconpaths.ON,
			text = L["Invasion"],
				
			OnClick = function(clickedframe, button)
				if button == "RightButton" then 
					I:NewInvasion()
					print("["..L["Invasion"].."] Invasion wiped")
				else 
					EventWatchInvasionSavedData.RankWatchEnabled = not EventWatchInvasionSavedData.RankWatchEnabled
					I:MinimapButton_Refresh()
				end
			end,
			
			OnTooltipShow = function(tt)
				tooltip = tt
				local line = "Event Watch"
				if EventWatchInvasionSavedData.RankWatchEnabled then
					line = line..tostring(I.Colors.Minimap.ON)..L[" is ON"]
				else
					line = line..tostring(I.Colors.Minimap.OFF)..L[" is OFF"]
				end
				tt:AddLine(line)
				tt:AddLine(tostring(I.Colors.Minimap.Click) .. L["Click|r to toggle EventWatch on/off"])
				tt:AddLine(tostring(I.Colors.Minimap.Click) .. L["Type|r /iw to report who is not Major"])				
				tt:AddLine(tostring(I.Colors.Minimap.Click) .. L["Right-click|r to force removal of current invation data"])
			end,
		}
	)
}

function I:MinimapButton_Refresh()
	if EventWatchInvasionSavedData.RankWatchEnabled then
		I.Minimap.LDBObject.icon = I.iconpaths.ON
	else
		I.Minimap.LDBObject.icon = I.iconpaths.OFF
	end
end