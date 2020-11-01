 <%
-- filename:       device.lp
-- description:    supply useful api for mbus operation on Hosts.Host path
-- project:        BT2.0 GUI

-- name:           getDeviceNameByIp 
-- description:    get device name by ip address 
-- parameter:      ip: device ip address 
-- return value    device friendlyName 
-- author:         Zhu Hong Lei (hong-lei.zhu@thomson.net)

cgilua.lp.include("lp/mbus_util.lp")
cgilua.lp.include("lp/util.lp")

function getDeviceNameByIp(ip)
 local devicePath="Hosts.Host"
 local Data, error = mbus.getParameters{path = devicePath, param = {"UserFriendlyName"}, filter="(and (== IPAddress "..ip..") (and (!= IPIntf "..getWlanEthIntf('openzone')..") (and (!= IsLocalHost 1) (!= Interface "..getVirtualEthIntf().."))))"}
 if #Data[devicePath] >0 then
   return Data[devicePath][1].param["UserFriendlyName"]
 else
   return ip
 end
end


function getDeviceNameByMAC(mac)
  local devicePath="Hosts.Host"
  local Data, error = mbus.getParameters{path = devicePath, param = {"UserFriendlyName"}, filter="(and (== MACAddress "..mac..") (and (!= IPIntf "..getWlanEthIntf('openzone')..") (and (!= IsLocalHost 1) (!= Interface "..getVirtualEthIntf().."))))"}
  if #Data[devicePath] >0 then
    return Data[devicePath][1].param["UserFriendlyName"]
  else
    return "Unkown Host"
  end
end

function getNewIpByMAC(mac)
  local devicePath="Hosts.Host"
  local Data, error = mbus.getParameters{path = devicePath, param = "NewIPAddress", filter="(== MACAddress "..mac..")" }
  if #Data[devicePath] >0 then
    return Data[devicePath][1].param["NewIPAddress"]
  else
    return mac
  end
end



--[[
    just special for BT Hub2.0,if the userfriendlyname is same, and has connected and unconneted item, show connected one. if all connected or unconnected, show all.  


]]


function removeSameNameInHost(t)

  local nameArray={}
-- according Name to divide to several sets.
  for k, v in pairs(t) do
     -- the tostring is very important, since dName will be key of table
     local dName=tostring(v.param['UserFriendlyName'])           
     local found=0

     for m, n in pairs(nameArray) do 
        if dName==m then found=1 break end
     end

     if found==0 then
        nameArray[dName]={}
        table.insert(nameArray[dName],v) 
     elseif found==1 then
        table.insert(nameArray[dName],v) 
     end
  end

--  delete the unconnect device when unconnect and connect device are exist.

  for k,v in pairs(nameArray) do
      local active=0
      local unactive=0
      for key,value in pairs(v) do 
        if value.param['Active']=='0' then
          unactive=unactive+1 
        elseif value.param['Active']=='1' then
          active=active+1 
        end
      end
      
      if active*unactive~=0 then
         for i, value in ipairs(v) do
           if value.param['Active']=='0' then table.remove(v, i) end
         end
      end
  end
   
--  refill t from nameArray

  t={}
   
  for k,v in pairs(nameArray) do
    for key,value in pairs(v) do 
      table.insert(t,value) 
    end
  end


return t

end

function get_Devices()
	local ETH =  {}
	local USB =  {}
	local WLAN = {}
	local reply, error = mbus.getParameters{path = "Hosts.Host", param = {"HostName", "Active", "IPAddress", "IPv6Address", "MACAddress", "UserFriendlyName", "Interface", "HostName", "AddressSource"}, filter="(and (!= HostName localhost) (== Active 1))"}

	for i, v in pairs(reply["Hosts.Host"]) do
		local ip = v.param["IPAddress"]
		local ipv6 = v.param["IPv6Address"]
		local mac = v.param["MACAddress"]
		local name = v.param["HostName"]
		local interface = v.param["Interface"]
		local active = v.param["Active"]
		local status = "Not connected"
		local addr_src = v.param["AddressSource"]
		local ethPath = v.path
    
		if name=="" then
			name = v.param["UserFriendlyName"]
		end

		if (active=="1") then 
			status = "Connected" 
		end

		if (interface ~= nil) then 
			local host, error = mbus.getParameters{path = interface, param = {"Technology", "Name"} }   
			if(host[interface][1].param["Technology"] == "ETH") or interface == "" then
				-- if client connect with hub, interface is empty. So, we put it in ETH list.
				ETH[i] = {}
				ETH[i].ip = ip
				ETH[i].ipv6 = ipv6
				ETH[i].mac = mac
				ETH[i].name = name
				ETH[i].active = active
				ETH[i].ethIndex = string.sub(interface, -1) 
			elseif (host[interface][1].param["Technology"] == "WLAN" or host[interface][1].param["Technology"] == "VIRTUAL") then
				for j=1, 4 do
					--if( j ~= 2 ) then
					local wlanPath 
					local WIntfPath
					if j==1 then
					        WIntfPath ="WLAN.Intf.wlif1"
					elseif j==2 then
					        WIntfPath="WLAN.Intf.wl_ssid1_local0"
					elseif j==3 then
					        WIntfPath="WLAN.Intf.wle_radio1_ssid0"
					elseif j==4 then
					        WIntfPath="WLAN.Intf.wle_radio1_ssid1"
					end

					local wlanPath = WIntfPath..".Station"
						local reply2, error2 = mbus.getParameters{ path=wlanPath, filter="(== MACAddress "..mac..")", param={"MACAddress"},flags="KEYPATH"}
						if reply2[wlanPath][1] ~= nil then
							if (host[interface][1].param["Name"] == "wlif1" or host[interface][1].param["Name"] == "wle_radio1_ssid0" or  host[interface][1].param["Name"] == "wl_ssid1_local0" or host[interface][1].param["Name"] == "wle_radio1_ssid1") then
								WLAN[i] = {}
								WLAN[i].ip = ip
								WLAN[i].ipv6 = ipv6
								WLAN[i].mac = mac
								WLAN[i].name = name
								WLAN[i].active = active
								WLAN[i].radioIndex = "1"  
								if host[interface][1].param["Name"] == "wlif1" then
									WLAN[i].radioIndex = "1"
								elseif host[interface][1].param["Name"] == "wle_radio1_ssid0" then
									WLAN[i].radioIndex = "2"
								else
									WLAN[i].radioIndex = "0"
								end
							end				
						end
					--end
				end
			elseif (host[interface][1].param["Technology"] == "USB") then
				USB[i] = {}
				USB[i].ip = ip
				USB[i].ipv6 = ipv6
				USB[i].mac = mac
				USB[i].name = name
				USB[i].active = active
			end   
		end
	end
  
	return ETH,WLAN,USB
end

--Get the list of host including connected and disconnected client on the lan.
function getClientsOnLan()
	local ETH =  {}
	local WLAN = {}
	local ethIndex, wifiIndex = 0, 0
	local reply, error = mbus.getParameters{path = "Hosts.Host", param = {"HostName", "Active", "IPAddress","MACAddress", "UserFriendlyName", "Interface", "HostName", "AddressSource"}, filter="(and (!= HostName localhost) (== Active 1))"}

	for i, v in pairs(reply["Hosts.Host"]) do
		local ip = v.param["IPAddress"]
		local mac = v.param["MACAddress"]
		local name = v.param["HostName"]
		local interface = v.param["Interface"]
		local active = v.param["Active"]
		local status = "Not connected"
		local addr_src = v.param["AddressSource"]
    		local ethPath = v.path

		if name=="" then
			name = v.param["UserFriendlyName"]
		end

		if (active=="1") then 
			status = "Connected" 
		end

		if (interface ~= nil) then 
			local host, error = mbus.getParameters{path = interface, param = {"Technology", "Name"} }   
			if(host[interface][1].param["Technology"] == "ETH") or interface == "" then
				-- if client connect with hub, interface is empty. So, we put it in ETH list.
				ethIndex = ethIndex + 1
				ETH[ethIndex] = {}
				ETH[ethIndex].ip = ip
				ETH[ethIndex].mac = mac
				ETH[ethIndex].name = name
				ETH[ethIndex].active = active
				ETH[ethIndex].isGameDevice = isGameDevice(ethPath)
			elseif (host[interface][1].param["Technology"] == "WLAN" or host[interface][1].param["Technology"] == "VIRTUAL") then
				for j=1, 4 do
					--if( j ~= 2 ) then
			local wlanPath
			local WIntfPath
			if j==1 then
        			WIntfPath ="WLAN.Intf.wlif1"
			elseif j==2 then
        			WIntfPath="WLAN.Intf.wl_ssid1_local0"
			elseif j==3 then
        			WIntfPath="WLAN.Intf.wle_radio1_ssid0"
			elseif j==4 then
        			WIntfPath="WLAN.Intf.wle_radio1_ssid1"
			end
	
						wlanPath = WIntfPath..".Station"
						local reply2, error2 = mbus.getParameters{ path=wlanPath, filter="(== MACAddress "..mac..")", param={"MACAddress"},flags="KEYPATH"}
						if reply2[wlanPath][1] ~= nil then
							if (host[interface][1].param["Name"] == "wlif1" or host[interface][1].param["Name"] == "wle_radio1_ssid0" or  host[interface][1].param["Name"] == "wl_ssid1_local0"  or host[interface][1].param["Name"] == "wle_radio1_ssid1") then
								wifiIndex = wifiIndex + 1
								WLAN[wifiIndex] = {}
								WLAN[wifiIndex].ip = ip
								WLAN[wifiIndex].mac = mac
								WLAN[wifiIndex].name = name
								WLAN[wifiIndex].active = active
							end				
						end
					--end
				end
			end
		end
	end
 	table.sort(ETH, function(x, y) return string.lower(x["active"]) > string.lower(y["active"]) end) 
	return ETH, WLAN
end

--To judge whether it is xbox or ps 
function isGameDevice(ethPath)

	local dhcpOptionPath = ethPath .. ".DHCP.1.RxOptions.1.Field.1"
	local replay, error = mbus.getParameters{path = dhcpOptionPath, param = "Value" }
	if replay[dhcpOptionPath][1]~=nil then
		local val = string.lower(tostring(replay[dhcpOptionPath][1].param["Value"]))
		local pos = string.find(val, "xbox")
		if pos~=nil then
			return true
		end		
	
		pos = string.find(val, "ps")
		if pos~=nil then
			return true
		end
	end
	return false

end

--To check it is remote access
function isRemoteAccess()
	--If the port is 80, it should be lan access.	
	if cgilua.servervariable"SERVER_PORT" == "80" then
		return false
	end

	local is_remote = false
	local reply, error = mbus.getParameters{ path = "RemoteAccess", param = "Enable", filter = "(== Name remoteaccess)" }
	if (reply["RemoteAccess"][1] ~= nil) and (reply["RemoteAccess"][1].param ~= nil) and (reply["RemoteAccess"][1].param["Enable"] == "true") then
		is_remote = true
		reply, error = mbus.getParameters{ path = "IP.Intf.LocalNetwork.Addr", param = {"IPAddress", "SubnetMask"}, filter = "(== Primary 1)", flags = "KEYPATH" }
		for i, v in pairs(reply["IP.Intf.LocalNetwork.Addr"]) do
			if (v ~= nil) and (v.param ~= nil) and (cgilua.servervariable"REMOTE_ADDR" ~= nil) and (cgilua.servervariable"REMOTE_ADDR" ~= "") then
				local ip_start, ip_end = natRange(v.param["IPAddress"], v.param["SubnetMask"])
				if inRange(cgilua.servervariable"REMOTE_ADDR", ip_start, ip_end) then
					is_remote = false
					break
				end
			end
		end
	end
	return is_remote
end

--Show the config menu for lan user but hidden for remote user.
function showConfigMenu(pageLink)
	local str = "<em>Stato</em>&nbsp;&nbsp;|&nbsp;&nbsp;<a href='".. pageLink .."'>Configura</a>"
	if isRemoteAccess() then
		str = ""
	end
	return str
end

--To check whether it is provisioned or not
--Is Default configuration – No WAN Connection
function isDefaultConf()
	local provisioningCode = ""
	local serviceRealm = ""
	local replay1, error = mbus.getParameters{path="Device.DeviceInfo", param="ProvisioningCode", datamodel = "second"}
	if replay1["Device.DeviceInfo"][1]~=nil then
		provisioningCode = replay1["Device.DeviceInfo"][1].param["ProvisioningCode"]
	end

	local replay2, error = mbus.getParameters{path="Device.ManagementServer", param="X_TELECOMITALIA_IT_ServiceRealm", datamodel = "second"}
	if replay2["Device.ManagementServer"][1]~=nil then
		serviceRealm = replay2["Device.ManagementServer"][1].param["X_TELECOMITALIA_IT_ServiceRealm"]
	end
	
	if provisioningCode=="" and serviceRealm=="alicenewborn.mgmt" then
		return true
	end
	
	return false
end

--Get the version of the software
function getVersion()
	local pathStr = "ENV"
	local versionStr = ""
	local data, error =  mbus.getParameters{path = pathStr, param = "Value", filter = "(== Name _BUILD)"}
	if data[pathStr] ~= nil then
		versionStr = data[pathStr][1].param["Value"]
	end

	return versionStr
end

--Get the the speed of wan eth.
function getWanEthSpeed(name)
	local speed = "1000Mbps"
	local eth, error = mbus.getParameters{path="ETH.Switch.Port", param="Type", filter="(== Name " .. name .. ")"}
	if (eth["ETH.Switch.Port"][1]~=nil) and (eth["ETH.Switch.Port"][1].path~=nil) then
		local portSpeed = eth["ETH.Switch.Port"][1].param["Type"]
		local pos = string.find(portSpeed, "Base")
		if pos ~= nil then
			speed = string.sub(portSpeed, 1, pos-1) .. "Mbps"
		end
	end
	return speed
end

--Get the led light image by the state
function getLedLightPic(state, ledColor)
	ledPic = "ledlight.gif"
	if ledColor == "Red" then
		ledPic = "ledlightred.gif"
	end

	if state == "Flash" then
		ledPic = "ledblinking.gif"
		if ledColor == "Red" then
			ledPic = "ledblinkingred.gif"
		end
	end
	return ledPic
end

--Get the Board Info from device
function getDeviceBoardInfo()
    local result = {}
	local reply, error = mbus.getParameters{path = "Device.DeviceInfo", param = {"HardwareVersion","SoftwareVersion","SerialNumber","ManufacturerOUI"}, datamodel = "second"}
        if reply["Device.DeviceInfo"][1] ~= nil then
			result.hardwareVersion = reply["Device.DeviceInfo"][1].param["HardwareVersion"]
			result.softwareVersion = reply["Device.DeviceInfo"][1].param["SoftwareVersion"]
			result.serialNumber = reply["Device.DeviceInfo"][1].param["SerialNumber"]
			result.ManufacturerOUI = reply["Device.DeviceInfo"][1].param["ManufacturerOUI"]
        end
        return result
end

--split the application list for port mapping
function getListForPortMapping(list, pathLength, portMappingList)
	local gameSelectList,gameEditList,protocolSelectList,protocolEditList,appGameList,appProtocolList,virtualList={},{},{},{},{},{},{}
	
	for i,v in pairs(list) do	
		if isInPortMappingList(tostring(v["Name"]), portMappingList)==false then	
			v.path = string.sub(v.path, pathLength + 1)
			--select list
			if tostring(v["Category"])=="NATAppList.Category.1" then 
				--protocol select list			
				table.insert(protocolSelectList, v)
			else
				--game select list
				table.insert(gameSelectList, v)
			end		
		else					
			--edit list		
			if tostring(v["Category"])=="NATAppList.Category.1" then 
				--protocol edit list
				table.insert(appProtocolList, v)
                -- add to protocol select list, TI require even assigned protocol must appear in list
			    v.path = string.sub(v.path, pathLength + 1)
				table.insert(protocolSelectList, v)
			else
				--game edit list
				table.insert(appGameList, v)
                -- add to game select list, TI require even assigned game must appear in list
			    v.path = string.sub(v.path, pathLength + 1)
				table.insert(gameSelectList, v)
			end
		end
	end
	
	for i,v in pairs(portMappingList) do
		if isInEditList(v["Description"], appGameList) then
			table.insert(gameEditList, v)
		elseif isInEditList(v["Description"], appProtocolList) then
			table.insert(protocolEditList, v)
		else
			table.insert(virtualList, v)
		end	
	end	
	return gameSelectList, gameEditList, protocolSelectList, protocolEditList, virtualList
end

--To check it is existed in the edit list.
function isInEditList(name, editList)
	for i,v in pairs(editList) do	
		if tostring(v["Name"])==name then
			return true
		end
	end
	return false
end

--To check it is existed in the port mapping list.
function isInPortMappingList(appName, portMappingList)
	for i,v in pairs(portMappingList) do	
		if tostring(v["Description"])==appName then
			return true
		end
	end
	return false
end

function getHostIpv6List()
    local deviceList = {}
	local ethdevices, wlandevices = get_DevicesIPv6(1)
	
	for i,v in pairs(ethdevices) do
		if(v.ipv6 ~= nil and v.ipv6 ~="") then
		local new = v.ipv6
		table.insert(deviceList, {IPAddress=new})
		end
	end
	for j,d in pairs(wlandevices) do
		if(d.ipv6 ~= nil and d.ipv6 ~="") then
		local new = d.ipv6
		table.insert(deviceList, {IPAddress=new})
		end
	end
	return deviceList
end

--Create the Virtual Server for access list
function virtualServerCreate_firewall(name, ip, protocol, internalPort,status)

    local virtualPath = "Device.Firewall.X_TELECOMITALIA_IT_ACLv6"	
    local result=0
    if status == nil then
        status = "true"
    end

    local reply, error = mbus.modify(
        function()
			local reply, error = mbus.addObjects{ path = virtualPath, datamodel="second"}
			local vir_path = reply[virtualPath][1].path
			local reply1, error1 = mbus.setParameters{ path = vir_path, param = {Protocol = protocol, InternalPort = internalPort, Description = name}, datamodel="second"}
			local reply2, error2 = mbus.setParameters{ path = vir_path, param = {InternalClient=ip}, datamodel="second"}
			local reply3, error3 = mbus.setParameters{ path = vir_path, param = {Enable=status}, datamodel="second"}
            if (error1~=nil or error2 ~=nil or error3 ~=nil) or (reply1[vir_path][1]==nil or reply2[vir_path][1]==nil or reply3[vir_path][1]==nil) then
                result=1
            end
        end, {datamodel="second"})      
	return result     
end

--Get the detail info from the list
function getDetailInfoByPath(pathStr, list)

	local nameInfo, ipInfo, protocalInfo, internalRange, externalRange
	for i,v in pairs(list) do
		if pathStr == v.path then
			nameInfo = v["Description"]
			ipInfo = v["InternalClient"]
			protocalInfo = v["Protocol"]
			internalRange = v["InternalPort"]
			externalRange = v["ExternalPort"]
		end
	end
	return nameInfo, ipInfo, protocalInfo, internalRange, externalRange
end

function get_DevicesIPv6(showstatus)
  local ETH =  {}
  local WLAN = {}
  local reply, error = mbus.getParameters{path = "Hosts.Host", param = {"HostName", "Active", "IPv6Address", "MACAddress", "Interface"}, filter="(and (!= HostName localhost) (== Active 1))"}

  for i, v in pairs(reply["Hosts.Host"]) do repeat
	local ipv6 = v.param["IPv6Address"]
    local mac = v.param["MACAddress"]
    local interface = v.param["Interface"]
    local active = v.param["Active"]
    local status = "Not connected"
    
    if (showstatus==0) and (active=="0") then break end

    if (active=="1") then status = "Connected" end

    if (interface ~= nil) then 
      local host, error = mbus.getParameters{path = interface, param = {"Technology", "Name"} }   
      if(host[interface][1].param["Technology"] == "ETH") or interface == "" then
		-- if client connect with hub, interface is empty. So, we put it in ETH list.
        ETH[i] = {}
		ETH[i].ipv6 = ipv6
      elseif (host[interface][1].param["Technology"] == "WLAN" or host[interface][1].param["Technology"] == "VIRTUAL") then
		local reply2, error2 = mbus.getParameters{ path="WLAN.Intf.wlif1.Station", filter="(== MACAddress "..mac..")", param={"MACAddress"},flags = "KEYPATH"}
		
		-- Fix for TESSA 437, Some IPv6 clients not listed in drop down list

		local reply3, error3 = mbus.getParameters{ path="WLAN.Intf.wle_radio1_ssid0.Station", filter="(== MACAddress "..mac..")", param={"MACAddress"},flags = "KEYPATH"}
		local reply4, error4 = mbus.getParameters{ path="WLAN.Intf.wl_ssid1_local0.Station", filter="(== MACAddress "..mac..")", param={"MACAddress"},flags = "KEYPATH"}
		local reply5, error5 = mbus.getParameters{ path="WLAN.Intf.wle_radio1_ssid1.Station", filter="(== MACAddress "..mac..")", param={"MACAddress"},flags = "KEYPATH"}
		-- Fix for TESSA 437, Some IPv6 clients not listed in drop down list
		-- Adding IPv6 address of hosts connected via main 2.4GHz to the array, to show IPv6 address in the drop down list 
		
		if reply2["WLAN.Intf.wlif1.Station"][1] ~= nil then 
			if (showstatus==1) then
				if (host[interface][1].param["Name"] == "wlif1") then
					WLAN[i] = {}
					WLAN[i].ipv6 = ipv6
				end
			else
				WLAN[i] = {}
				WLAN[i].ipv6 = ipv6
			end

		-- Adding IPv6 address of hosts connected via main 5GHz to the array, to show IPv6 address in the drop down list 

		elseif reply3["WLAN.Intf.wle_radio1_ssid0.Station"][1] ~= nil then 
			if (showstatus==1) then
				if (host[interface][1].param["Name"] == "wle_radio1_ssid0") then
					WLAN[i] = {}
					WLAN[i].ipv6 = ipv6
				end
			else
				WLAN[i] = {}
				WLAN[i].ipv6 = ipv6
			end

		-- Adding IPv6 address of hosts connected via Guest 2.4GHz to the array, to show IPv6 address in the drop down list 

		elseif reply4["WLAN.Intf.wl_ssid1_local0.Station"][1] ~= nil then 
			if (showstatus==1) then
				if (host[interface][1].param["Name"] == "wl_ssid1_local0") then
					WLAN[i] = {}
					WLAN[i].ipv6 = ipv6
				end
			else
				WLAN[i] = {}
				WLAN[i].ipv6 = ipv6
			end

		-- Adding IPv6 address of hosts connected via Guest 5GHz to the array, to show IPv6 address in the drop down list 
		
		elseif reply5["WLAN.Intf.wle_radio1_ssid1.Station"][1] ~= nil then 
			if (showstatus==1) then
				if (host[interface][1].param["Name"] == "wle_radio1_ssid1") then
					WLAN[i] = {}
					WLAN[i].ipv6 = ipv6
				end
			else
				WLAN[i] = {}
				WLAN[i].ipv6 = ipv6
			end
		end
      end
    end
    
  until true end
  
  return ETH,WLAN
end

--Get the Directory Numbers Info from device
--CPE_P00122487

function getDeviceRoute()

    local directory_path = "Device.Services.VoiceService.1.VoiceProfile.1.Line.8"
    local directory_path1 = "Device.Services.VoiceService.2.VoiceProfile.1.Line.1"

    local reply, error = mbus.getParameters{path = directory_path, param = {"DirectoryNumber"}, datamodel = "second"}
        if reply[directory_path][1] ~= nil then
            local directory_val = reply[directory_path][1].param["DirectoryNumber"]
            if(directory_val ~= nil and directory_val ~= "") then
                return "true"
            end
        end
        
    local reply, error = mbus.getParameters{path = directory_path1, param = {"DirectoryNumber"}, datamodel = "second"}
        if reply[directory_path1][1] ~= nil then
            local directory_val1 = reply[directory_path1][1].param["DirectoryNumber"]
            if(directory_val1 ~= nil and directory_val1 ~= "") then
                return "true"
            end
        end

end

--To Get IPv6 Status
function getIPv6(ipv6Path)
	local IPv6status = ""
	local replyipv6State, error = mbus.getParameters{path = ipv6Path, param = {"IPv6Enable"}, datamodel = "second"}
	if (replyipv6State[ipv6Path][1] ~= nil) and (replyipv6State[ipv6Path][1].param ~= nil) then
		IPv6status = replyipv6State[ipv6Path][1].param["IPv6Enable"]
	end
	return IPv6status
end
%>
