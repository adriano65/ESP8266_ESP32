<%
local print = cgilua.print
local tprint=require("tableprint")
local BSFTstatus = "Initial state"

function splitPath(str, pat)
   local t = {}
   local fpat = "(.-)" .. pat
   local last_end = 1
   local s, e, cap = str:find(fpat, 1)
   while s do
      if s ~= 1 or cap ~= "" then
         table.insert(t,cap)
      end
      last_end = e+1
      s, e, cap = str:find(fpat, last_end)
   end
   if last_end <= #str then
      cap = str:sub(last_end)
      table.insert(t, cap)
   end
   return t
end


local reply, error = mbus.getParameters{ path = "Voice.DM", param = { "Status","LastError"} }
    local status = reply["Voice.DM"][1].param["Status"] 
    local dmsError = reply["Voice.DM"][1].param["LastError"]	   
    if status == "UNCONFIGURED" then
	BSFTstatus = translate("Initial state")
    elseif status == "DOWNLOADING" then
	BSFTstatus = translate("The downloading is in progress")
    elseif status == "CONFIGURING" then
	BSFTstatus = translate("The downloading has completed and the configuration file is being processed")
    elseif status == "RECONFIGURING" then
	BSFTstatus = translate("The downloading has completed and the configuration file is being processed")	
    elseif status == "CONFIGURED" then
	BSFTstatus = translate("The configuration file has been successfully applied")
    elseif status == "ERROR" then
	local dmsArray = splitPath(dmsError," ")
	local ipAddress = ""
	if #dmsArray > 2 then
		if dmsArray[1] == "Failed" and dmsArray[2] == "to" then
			dmsError = "Failed to Resolve"
			ipAddress = dmsArray[4]
		elseif dmsArray[1] == "connect" and dmsArray[2] == "to" then
			dmsError = "connect to server"
			ipAddress = dmsArray[4]
		end
	end
	BSFTstatus = translate("An error has occurred")..": "..translate(dmsError).." "..ipAddress				
    end
cgilua.print(tostring(BSFTstatus)) 

%>


