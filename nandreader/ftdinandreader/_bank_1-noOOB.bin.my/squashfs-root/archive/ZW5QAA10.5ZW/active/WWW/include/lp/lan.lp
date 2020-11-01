<%
--Get the list of the lan connection.
function reassignlist()
	local result={}
	local reply, error = mbus.getParameters{path = "Hosts.Host", param = {"HostName", "Active", "IPAddress","MACAddress", "Interface", "NewIPAddress", "EnableDHCPStaticAddress"}, filter="(!= HostName localhost)"} 
	for i, v in pairs(reply["Hosts.Host"]) do
		local temp={}
		temp.ip = v.param["IPAddress"]
		if temp.ip=="0.0.0.0" then temp.ip="---" end

		temp.mac = v.param["MACAddress"]
		temp.name = v.param["HostName"]
		temp.active = v.param["Active"]
		temp.newip = v.param["NewIPAddress"]
		temp.staticenable = v.param["EnableDHCPStaticAddress"]

		local interface = v.param["Interface"]
		local host, error = mbus.getParameters{path = interface, param = {"Technology", "Name"} }
		temp.inter= host[interface][1].param["Technology"] 

		--if temp.inter == "ETH" or temp.inter =="WLAN" then
		if temp.active=="true" then
			table.insert(result, temp)
		else 
			if temp.staticenable=="true" then
				table.insert(result, temp)
			end
		end
		--end
	end

  --Get DHCP StaticAddr list and add unfound address(missing in hosts) into result list
	local LMAC = getLinuxMac()
	local lease, error = mbus.getParameters{path = "DHCP.Server.Lease", param = {"IPAddress","MACAddress"}, filter="(== Allocation manual)"} 
	for i, v in pairs(lease["DHCP.Server.Lease"]) do
    --exclude Modem MAC
    if v.param["MACAddress"] ~= LMAC then
      local found = 0
      for j, l in pairs(result) do
        if v.param["MACAddress"] == l.mac then
          found = 1
          break
        end
      end
      if found == 0 then
        local temp={}

        temp.ip = v.param["IPAddress"]
        temp.mac = v.param["MACAddress"]
        temp.name = "---"
        temp.active = "false"
        temp.newip = v.param["IPAddress"]
        temp.staticenable = "true"
        temp.inter = "ETH"
        table.insert(result, temp)
      end
    end
  end

	return result
end

--Enable or disable the state of dhcp pool.
function setDhcpPoolState(state)
	local modify = {}
	table.insert(modify, {path="DHCP.Server.Pool.1", param= {State=state}})
	setMBUS(modify)
end

--Create the dhcp lease
function dhcpLeaseCreate(ip, mac, gatewayIp, poolpath)
	local reply, error = mbus.modify(
		function()
			if (mac~=nil) then
				local reply2, error2 = mbus.addObjects{ path = "DHCP.Server.Lease",
                                                                        param = { ClientID = mac,
                                                                                 IPAddress = ip,
                                                                                 MACAddress = mac,
                                                                                 DHCPServerPool = poolpath,
                                                                                 LeaseTime = "0",
                                                                                 ExpirationTime = "0",
                                                                                 Gateway = gatewayIp,
                                                                                 Allocation = "manual" } }
                        end
                end)

end

-- Delete all lease
function dhcpLeaseDelete()
	local reply, error = mbus.modify(
		function()
			local reply1, error1 = mbus.deleteObjects{ path = "DHCP.Server.Lease" }
		end)

end

--Get the Linux MAC
function getLinuxMac()
	local LMAC
	local reply1, error1 = mbus.getParameters{ path = "ENV", param = "Value", filter = "(== Name _LMACADDR)" }
	if (reply1["ENV"][1]~=nil) and (reply1["ENV"][1].param~=nil) then
		LMAC=reply1["ENV"][1].param["Value"]
		-- env format is 02-90-D0-4E-F7-81, must change to 02:90:d0:4e:f7:81
		LMAC=tostring(LMAC)
		LMAC=string.gsub(LMAC,"-",":")
		LMAC=string.lower(LMAC)
	end
	return LMAC
end

-- Store all DHCP manual lease
function getDhcpLease_T(LMAC)
	local DHCP_manual={}
	local reply, error= mbus.getParameters{ path="DHCP.Server.Lease", param={"IPAddress", "MACAddress"}, filter="(and (== ExpirationTime 0) (!= MACAddress "..LMAC.."))"}
	for i, v in pairs(reply["DHCP.Server.Lease"]) do 
		if v.param["IPAddress"]~=nil and v.param["IPAddress"]~="" then
			table.insert(DHCP_manual, {ip=v.param["IPAddress"], mac=v.param["MACAddress"]})
		end
	end
	return DHCP_manual
end

-- Update samba port mapping.
function sambaPortMappingUpdate(ipAddr, dhcpIpEnd)
	local reply, error = mbus.modify(
	function()
		local reply1, error1 = mbus.setParameters{ path = "NAT.Portmap.1", param = { InsideAddress = dhcpIpEnd, InsideAddressEnd = dhcpIpEnd, OutsideAddress = ipAddr, OutsideAddressEnd = ipAddr }}
	end)
end

--Enable or disable the state of nat.
function setNatState(natIntfPath, state)
	local modify = {}
	table.insert(modify, {path=natIntfPath, param= {Status=state}})
	table.insert(modify, {path="TI_STORE.TiUserIntf", param={tclCmd="connection clear"}})
	table.insert(modify, {path="TI_STORE.TiUserIntf", param={tclCmd="connection clean"}})
	setMBUS(modify)
end

-- Disable NAT portmapping which is out of range, enable NAT portmapping which is in range.
-- Disable ALL NAT portmapping when NAT disabled, enabled ALL NAT portmapping when NAT enable
function setPortMappingStateForNat(natIntfPath, state, natIpBegin, natIpEnd)
	
	local modify_T={} 
	local dev_path="Device.NAT.PortMapping"
	local reply, error=mbus.getParameters{path=dev_path, param={"Enable", "InternalClient", "X_000E50_GUIDisabled", "X_000E50_InterfaceDisabled"}, datamodel="second"}
	local tprint = require("tableprint")
	
	
	for i, v in pairs(reply[dev_path]) do
		local ip=v.param["InternalClient"] 
		local intf_disabled=v.param["X_000E50_InterfaceDisabled"]
		local start=natIpBegin
		local endip=natIpEnd
		local gui_disabled=v.param["X_000E50_GUIDisabled"]
		-- in range, enable those disabled one but if NAT disabled will disabled
		if inRange(ip, start, endip)==true then 
			if tostring(state)=="true" then 
	
				table.insert(modify_T,{path=v.path, param={X_000E50_InterfaceDisabled="false"}, datamodel="second"})
			else
	
				table.insert(modify_T,{path=v.path, param={X_000E50_InterfaceDisabled="true"}, datamodel="second"})
			end
		else
			if intf_disabled=="false" then
				table.insert(modify_T,{path=v.path, param={X_000E50_InterfaceDisabled="true"}, datamodel="second"})
			end
		end
	end

		
	setMBUS_IGD(modify_T)
end

--Get the host path by mac address
function getHostPathByMac(mac)
	local hostPath=""
	local Data, error = mbus.getParameters{path = "Hosts.Host", param = "NewIPAddress", filter="(== MACAddress "..mac..")" }
	if #Data["Hosts.Host"] >0 then
		hostPath=Data["Hosts.Host"][1].path
	end
	return hostPath
end

--Pre-assign new ip or recovery to auto lease.
function updateIpReserved(hostPath, newip, isPreAssigned)
	local reply, error = mbus.modify(
		function()
			local reply1, error1 = mbus.setParameters{ path = hostPath, param = { NewIPAddress = newip, EnableDHCPStaticAddress=isPreAssigned}}
	end)
end

--Add new ip reserve for disconnected host
function addIpReserved(reserveMac, reserveIp)
	local reply, error = mbus.modify(
		function()
			local reply1, error1 = mbus.addObjects{ path = "Hosts.Host",
				param = { MACAddress = reserveMac,
				IPAddress = reserveIp,
				NewIPAddress = reserveIp,
				EnableDHCPStaticAddress = "1" } }
		end)
end

--Set the state of the ETH phy and WLAN Phy
function setPhyState(state)
        local modify={}
    

        if state == "0" then
                state = "disabled"
        else
                state = "enabled"
        end

        for i=1, 4 do
                table.insert(modify, {path="TI_STORE.TiUserIntf", param={tclCmd="eth device ifconfig intf ethif" .. tostring(i) .. " state " .. state}})
        end
        setMBUS(modify)
end

--Execute this action after ip changing.
function phyChangeSetting()
        --disable ETH phy and WLAN Phy
        setPhyState("0")
        sleep(10)

        local reply, error = mbus.modify(
                                function()
                                        local reply1, error1 = mbus.deleteObjects{path="IP.ARP"}
                                end)

	local reply, error = mbus.modify(
                                function()
                                        local reply1, error1 = mbus.deleteObjects{path="Hosts.Host"}
                                end)

        sleep(3)

        -- if IP is modified, it may be the case the DHCP server disabled but IP changed to another subnetwork.
        -- in IP plugin, linux.ip will be created in this case, so dhcpcd need to restart
        -- if DHCP server is checked, it will be better.
        -- force Linux to update its IP address, force Smaba update its server ip
        modify={}
        table.insert(modify, {path="ContentSharing.CIFS", param={ServerComment="Gateway"}})
        setMBUS(modify)
        modify={}
        table.insert(modify, {path="ContentSharing.CIFS", param={ServerComment="TI Gateway"}})
        setMBUS(modify)

        -- enable ETH phy and WLAN phy
        -- wait dhcpcd finish the restart
        sleep(10)
        setPhyState("1")
        sleep(10)
	
end




%>
