<%
local QUERY = cgilua.QUERY
local print = cgilua.print

local pathId = QUERY["pathId"]
if QUERY["pathId"] ~= nil then
	local pathDetail = "Device.Services.VoiceService.1.PhyInterface." .. tostring(pathId) .. ".Tests"
	local testState, connection, volDC, volAC, insulationResistance, phoneRelease, impedance, dial
	local reply, error = mbus.getParameters{ path = pathDetail, param = {"TestState", "PhoneConnectivity", "X_TELECOMITALIA_IT_Vloop_DC", "X_TELECOMITALIA_IT_Vloop_AC", "X_TELECOMITALIA_IT_Rloop", "X_TELECOMITALIA_IT_OffHook", "X_TELECOMITALIA_IT_REN", "X_TELECOMITALIA_IT_PSTN"}, datamodel = "second" }

	if reply[pathDetail]~=nil and reply[pathDetail][1]~=nil then
		testState = reply[pathDetail][1].param["TestState"]
		connection = reply[pathDetail][1].param["PhoneConnectivity"]
		volDC = reply[pathDetail][1].param["X_TELECOMITALIA_IT_Vloop_DC"]
		volAC = reply[pathDetail][1].param["X_TELECOMITALIA_IT_Vloop_AC"]
		insulationResistance = reply[pathDetail][1].param["X_TELECOMITALIA_IT_Rloop"]
		phoneRelease = reply[pathDetail][1].param["X_TELECOMITALIA_IT_OffHook"]
		impedance = reply[pathDetail][1].param["X_TELECOMITALIA_IT_REN"]
		dial = reply[pathDetail][1].param["X_TELECOMITALIA_IT_PSTN"]
	end
	
	print(tostring(testState) .. "##" .. tostring(connection) .. "##" .. tostring(volDC) .. "##" .. tostring(volAC) .. "##" .. tostring(insulationResistance) .. "##" .. tostring(phoneRelease) .. "##" .. tostring(impedance) .. "##" .. tostring(dial))
end
%>

