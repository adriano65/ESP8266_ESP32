<%
local QUERY = cgilua.QUERY
local print = cgilua.print

local isIpUpdateFlag = "true"
local reply, error = mbus.modify(
	function()
		local reply1, error1 = mbus.setParameters{ path = "TI_STORE", param = { NewModemIP=QUERY["ipAddr"]}}
		if error1 ~= nil then
			isIpUpdateFlag = "false"
		end
	end)
print(isIpUpdateFlag)
%>
