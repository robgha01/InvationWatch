function APIWatch:Debug(msg, ...)
	if APIWatch._debug then
		if ViragDevTool_AddData then
			ViragDevTool_AddData({...}, msg)
		else
			print(msg, ...)
		end
	end
end

function APIWatch:SafeMsg(text, linewidth)
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

function APIWatch:BroadcastMessage(msg)
	local chatType = "PARTY"
	if GetRealNumRaidMembers() > 1 then chatType = "RAID" end
	if APIWatch._debug then
		print(msg)		
	else
		-- split the message if over 250 chars
		for i, m in ipairs(APIWatch:SafeMsg(msg, 245)) do
			SendChatMessage(m, chatType)
		end
	end
end