function EventWatch:Debug(msg, ...)
	if EventWatch._debug then
		if ViragDevTool_AddData then
			ViragDevTool_AddData({...}, msg)
		else
			print(msg, ...)
		end
	end
end

function EventWatch:SafeMsg(text, linewidth)
    if not linewidth then
        linewidth = 35
    end
 
    local spaceleft = linewidth
    local res = {}
    local line = {}
	local function splittokens(s)
		local res = {}
		for w in s:gmatch("%S+") do
			res[#res+1] = w
		end
		return res
	end
 
    for _, word in ipairs(splittokens(text)) do
        if #word + 1 > spaceleft then
            table.insert(res, table.concat(line, ' '))
            line = {word}
            spaceleft = linewidth - #word
        else
            table.insert(line, word)
            spaceleft = spaceleft - (#word + 1)
        end
    end
 
    table.insert(res, table.concat(line, ' '))
    return res
end

function EventWatch:BroadcastMessage(msg)
	local chatType = "PARTY"
	if GetRealNumRaidMembers() > 1 then chatType = "RAID" end
	if EventWatch._debug then
		print(msg)		
	else
		-- split the message if over 250 chars
		for i, m in ipairs(EventWatch:SafeMsg(msg, 245)) do
			SendChatMessage(m, chatType)
		end
	end
end

function EventWatch:GetGroup()
	if UnitInRaid("PLAYER") then
		return "RAID",GetNumRaidMembers();
	else
		return "PARTY",GetNumPartyMembers();
	end
end

function EventWatch:IsRaidMember(flags)
	return (bit.band(flags,COMBATLOG_OBJECT_TYPE_PLAYER) > 0) and ((bit.band(flags,COMBATLOG_OBJECT_AFFILIATION_RAID) > 0) or (bit.band(flags,COMBATLOG_OBJECT_AFFILIATION_PARTY) > 0) or (bit.band(flags,COMBATLOG_OBJECT_AFFILIATION_MINE) > 0));
end