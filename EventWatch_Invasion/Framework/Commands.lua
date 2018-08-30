local I = LibStub("AceAddon-3.0"):GetAddon("EventWatchInvasion")
local L = LibStub("AceLocale-3.0"):GetLocale("EventWatchInvasion", false)
local db = EventWatchInvasionSavedData

function I:ChatMsg(msg)
	DEFAULT_CHAT_FRAME:AddMessage(msg)
end

local chat = function(msg) I:ChatMsg(msg) end
local commands = {}

local function ChatCmd(input)
	if not input or input:trim() == "" then
		I:WhoNotMajor()
	else
		for com, fun in pairs(commands) do
			if input:trim() == com then
				fun()
				return
			end
		end		
	end
end

local function ShowHelp()
	chat("Invasion Watch help:")
	chat("  /iw           -  Reports who is not major using percentage")
	chat("  /iw n         -  Reports who is not major using rank names")
	chat("  /iw toggle    -  Toggles the Major auto report On/Off")
	chat("  /iw reset     -  Wipe the current invasion data")
	chat("  /iw wa        -  Imports the weakauras (progressbar)")
	chat("  /iw h         -  Shows this message")
	chat("  /iw help      -  Shows this message")
	chat("  /iw debug     -  Enables debugging messages")
end

function I:AddCommand(name,callback)
	if commands[name] then error(("Usage: AddCommand(name, callback): 'name' - Already added! '%s'."):format(tostring(name))) end
	commands[name] = callback
end

function I:RegisterChatCmd()
	I:RegisterChatCommand("iw", ChatCmd)
	I:RegisterChatCommand("invationwatch", ChatCmd)

	-- Add base commands
	I:AddCommand("debug", function()
		EventWatch._debug = not EventWatch._debug
		chat(format("Debug %s", (EventWatch._debug and "enabled" or "disabled")))
	end)
	I:AddCommand("toggle", function()
		EventWatchInvasionSavedData.RankWatchEnabled = not EventWatchInvasionSavedData.RankWatchEnabled
		I:MinimapButton_Refresh()
	end)
	I:AddCommand("reset", function()
		I:NewInvasion()
		print("["..L["Invasion"].."] wiped")
	end)
	I:AddCommand("n", function()
		I:WhoNotMajor(I.reportType["RankName"])
	end)
	I:AddCommand("help", ShowHelp)
	I:AddCommand("h", ShowHelp)
end
