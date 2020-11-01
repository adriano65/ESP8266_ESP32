<%cgilua.lp.include("lp/mbus_util.lp")%>
<%cgilua.lp.include("lp/portmap.lp")%>
<%
if cgilua.servervariable"REQUEST_METHOD" == "POST" then
    local action=cgilua.POST["action"]
    local modify={}
    if action == "customerReset" then
		--Delete the Portmapping data when making a customer reset.
		local virtualPath = "Device.NAT.PortMapping"	
		virtualServerDelete_IGD(virtualPath)

		local reply, error = mbus.getParameters{path = "Hosts.Host", param = "MACAddress"}
			for i, v in pairs(reply["Hosts.Host"]) do		
			local envName=v.param["MACAddress"].."_icon"
			local reply1, error1 = mbus.getParameters{ path = "ENV", param = "Value", filter = "(== Name "..envName..")" }
				if reply1["ENV"]~=nil and reply1["ENV"][1] ~= nil then
					mbus.modify(
					function()
					local result, error = mbus.deleteObjects{ path = "ENV", param = "Value", filter = "(== Name "..envName..")" }
					end)
				end
			end
		table.insert(modify,{path="DeviceConfig", param={TI_CustomReset="1"}})			
    elseif action=="saveRestart" then
        mbus.modify(
          function()
            mbus.setParameters{path = "TI_STORE.TiUserIntf", param = {writeLog = "Reboot"}}
          end)
		table.insert(modify,{path="DeviceConfig", param= {ConfigSaveDelay="0", RebootDelay="5", ConfigSave="1", Reboot="1"}})
    end
    setMBUS(modify)
end
%>
