local AceLocale = LibStub:GetLibrary("AceLocale-3.0")
local L = AceLocale:NewLocale("InvationWatch", "enUS", true, true)
if not L then return end

L[" is ON"] = " is ON"
L[" is OFF"] = " is OFF"
L["Click|r to toggle InvationWatch on/off"] = "Click|r to toggle InvationWatch on/off"
L["Right-click|r to force removal of current invation data"] = "Right-click|r to force removal of current invation data"
L["Type|r /iw to report who is not Major"] = "Type|r /iw to report who is not Major"
L["Not Major: %s"] = "Not Major: %s"
L["%s is now Major"] = "%s is now Major!"
L["Everyone is Major!"] = "Everyone is Major!"

-- Event messages do not change
L["You have successfully ended the invasion."] = "You have successfully ended the invasion."
L["Qiraji reinforcements are arriving in 15 seconds. Prepare yourself. Hero!"] = "Qiraji reinforcements are arriving in 15 seconds. Prepare yourself. Hero!"
L["A Qiraji Harbinger is approaching. Steel your resolve and end this invasion. once and for all!"] = "A Qiraji Harbinger is approaching. Steel your resolve and end this invasion. once and for all!"