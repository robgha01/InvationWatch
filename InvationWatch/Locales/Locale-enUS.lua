local AceLocale = LibStub:GetLibrary("AceLocale-3.0")
local L = AceLocale:NewLocale("InvationWatch", "enUS", true, true)
if not L then return end

------------------------------------------
---------- gui/minimapbutton.lua ----------
------------------------------------------
L[" is ON"] = " is ON"
L[" is OFF"] = " is OFF"
L["Click|r to toggle SpeakinSpell on/off"] = "Click|r to toggle InvationWatch on/off"
L["Right-click|r to open the options"] = "Right-click|r to open the options"