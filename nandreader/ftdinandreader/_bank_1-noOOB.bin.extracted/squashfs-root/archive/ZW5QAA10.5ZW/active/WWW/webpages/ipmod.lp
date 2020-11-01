<%cgilua.lp.include("lp/lan.lp")%>
<%cgilua.lp.include("lp/mbus_util.lp")%>

<%

-- Fix for security issue in TI_M5
-- Merge label MOD_ARCHIVE_DANT-V_r10.5_r10.5.e_WIPRO_V1.0.2-a7

local POST=cgilua.POST

-- this file support ip change and dhcp range change, because dhcp range change also need phy down and up
if POST["tag"]=="ip" then
	local modify={}
	table.insert(modify, {path="TI_STORE.TiUserIntf", param= {GUI_SetIP="1"}})
	setMBUS(modify)
    
    	-- ip setting start 
	modify={}
 	table.insert(modify, {path=POST["path"], param= {IPAddress=POST["ip"], SubnetMask=POST["mask"]}})
	setMBUS(modify)

    	sleep(10)

	modify={}
	table.insert(modify, {path="TI_STORE.TiUserIntf", param= {GUI_SetIP="0"}})
	setMBUS(modify)

	if POST["natState"]=="enabled" then
		modify={}
		table.insert(modify, {path=POST["natIntfPath"], param= {Status="enabled"}})
		table.insert(modify, {path="TI_STORE.TiUserIntf", param={tclCmd="connection clear"}})
		table.insert(modify, {path="TI_STORE.TiUserIntf", param={tclCmd="connection clean"}})	
		setMBUS(modify)
	end

	--disable ETH phy and WLAN Phy, then flush hostmgr and ARP, force Linux to update its IP address, force Smaba update its server ip, at last enable ETH phy and WLAN Phy 
	if phyChangeSetting() ~= 1 then
		--ip setting end
		local reply, error = mbus.modify(
        	 function()
	        local reply, error = mbus.setParameters{path="DeviceConfig", param={ConfigSaveDelay="0", ConfigSave="1"}}
        	end)
	else
		cgilua.redirect("resultKO.lp")
	end

end
%>
