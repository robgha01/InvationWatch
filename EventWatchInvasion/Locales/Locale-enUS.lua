local AceLocale = LibStub:GetLibrary("AceLocale-3.0")
local L = AceLocale:NewLocale("EventWatchInvasion", "enUS", true, true)
if not L then return end

L["Invasion"] = true
L[" is ON"] = true
L[" is OFF"] = true
L["Click|r to toggle EventWatchInvasion on/off"] = true
L["Right-click|r to force removal of current invation data"] = true
L["Type|r /iw to report who is not Major"] = true
L["Not Major: %s"] = true
L["%s is now Major"] = true
L["Everyone is Major!"] = true

-- Event messages do not change
L["You have successfully ended the invasion."] = true
L["Qiraji reinforcements are arriving in 15 seconds. Prepare yourself. Hero!"] = true
L["A Qiraji Harbinger is approaching. Steel your resolve and end this invasion. once and for all!"] = true