EventWatch = {}
EventWatch._debug = false
EventWatch.inGroup = false

function EventWatch:CheckGroup()
	local new = GetNumPartyMembers() + GetNumRaidMembers();
	if (new > 0) and (not inv.inGroup) then
		EventWatch.inGroup = true;
		return true;
	elseif (new == 0) then
		EventWatch.inGroup = false;
	end
end