local AceLocale = LibStub:GetLibrary("AceLocale-3.0")
local L = AceLocale:NewLocale("InvationWatch", "enUS", true, true)
if not L then return end

L[" is ON"] = " is ON"
L[" is OFF"] = " is OFF"
L["Click|r to toggle SpeakinSpell on/off"] = "Click|r to toggle InvationWatch on/off"
L["Right-click|r to open the options"] = "Right-click|r to open the options"
L["Type|r /iw to report who is not Major"] = "Type|r /iw to report who is not Major"
L["Not Major: %s"] = "Not Major: %s"
L["Everyone is major"] = "Everyone is major"