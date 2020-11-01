local fxoTeleNumber = ""
local wepGuestKey = ""

local tprint=require("tableprint")
function sleep(n)  
  while n  > 0 do  
    n = n - 1
    end
end

--Set the state of the ETH phy and WLAN Phy
function setPhyState(state)
        local modify={}
        table.insert(modify, {path="WLAN", param={Enable=state}})

        if state == "0" then
                state = "disabled"
        else
                state = "enabled"
        end

        for i=1, 4 do
                table.insert(modify, {path="TI_STORE.TiUserIntf", param={tclCmd="eth device ifconfig intf ethif" .. tostring(i) .. " state " .. state}})
        end
        local res =  setMBUS(modify)
		--tprint("@@@setPhyState result is");
		--tprint(res);
end

--Execute this action after ip changing.
function phyChangeSetting()
	--tprint("@@@ phyChangeSetting start...")
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
        local modify={}
        table.insert(modify, {path="TI_STORE.TiUserIntf", param={linuxCmd="/etc/init.d/udhcpcd stop &"}})
        setMBUS(modify)
        sleep(2)
        modify={}
        table.insert(modify, {path="TI_STORE.TiUserIntf", param={linuxCmd="/etc/init.d/udhcpcd start &"}})
        setMBUS(modify)
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
	
	--tprint("@@@ phyChangeSetting end...")
end

-- name:           setMBUS
-- description:    set parameter to MBUS 
-- parameter:      set:  a table for set info 
-- return value    null  

function setMBUS(set)
  --tprint("@@@ setMBUS start ...")
  --tprint(set)
  local result=0
  if #set>0 then
      local reply, error = mbus.modify(
        function()
          local reply, error = mbus.setParameters(set)
          if error~=nil then result=1 end
        end)
  end
  --tprint("@@@ setMBUS result")
  --tprint(result)
  --tprint("@@@ setMBUS end ...")
  return result
end

-- name:           setMBUS_IGD
-- description:    set parameter to MBUS IGD datamodel
-- parameter:      set:  a table for set info 
-- return value    null  

function setMBUS_IGD(set)
  --tprint("@@@ setMBUS_IGD start....")
  --tprint(set)
  local result=0
  set["datamodel"]="second"
  if #set>0 then
      local reply1, error1 = mbus.modify(
        function()
          local reply, error = mbus.setParameters(set)
          if error~=nil then 
	          result=1 
          end
        end,
		{datamodel="second"}
      )
	if error1 ~=nil then 
	   result=1 
	end	  
  end
  --tprint("@@@ setMBUS_IGD result")
  --tprint(result)
  --tprint("@@@ setMBUS_IGD end....")
  return result
end

local stack={}

--Set the dhcp pool state as the session variable, 0 means false which as a default value.
local dhcpServerState = "0"
--This session variable judges whether the ip, netmask, dhcp ranged was changed.
local isLanConfigChanged = "false"
local natIpInitDefault, natIpFinalDefault

--Path list which should be checked to other vendors in which its path without sequence number.
local pathList_T = {{"InternetGatewayDevice.WANDevice.WANConnectionDevice.WANPPPConnection", 0}, {"InternetGatewayDevice.WANDevice.WANConnectionDevice.WANIPConnection", 0}, {"InternetGatewayDevice.WANDevice.WANConnectionDevice", 0}}
--Define the exception of the parameters for factory default in the table like "{path, {param1,param2,...}}"
local factoryException_T = {
{"InternetGatewayDevice.WANDevice.1.WANConnectionDevice.1.WANPPPConnection.1", {}},
{"InternetGatewayDevice.DeviceInfo", {"ProvisioningCode"}},
{"InternetGatewayDevice.ManagementServer", {"X_TELECOMITALIA_IT_ServiceRealm"}},
{"InternetGatewayDevice.Layer3Forwarding", {}},
{"InternetGatewayDevice.Layer3Forwarding.Forwarding.{i}", {}},
{"InternetGatewayDevice.USBHosts.Host.{i}", {}},
{"InternetGatewayDevice.LANDevice.1.Hosts", {}},
--{"InternetGatewayDevice.LANDevice.1.LANHostConfigManagement.DHCPStaticAddress.{i}", {}},
{"InternetGatewayDevice.LANDevice.1.Hosts.Host.{i}", {}},
{"InternetGatewayDevice.WANDevice.1.WANConnectionDevice.1.WANPPPConnection.{i}", {"Name", "ConnectionStatus", "Uptime", "LastConnectionError", "ExternalIPAddress", "CurrentMRUSize", "X_TELECOMITALIA_IT_CurrentDNSServer", "X_TELECOMITALIA_IT_WINS", "PortMappingNumberOfEntries"}},
{"InternetGatewayDevice.WANDevice.1.WANConnectionDevice.1.WANPPPConnection.3.PortMapping.{i}", {"X_TELECOMITALIA_IT_HostMACAddress"}},
{"InternetGatewayDevice.WANDevice.1.WANConnectionDevice.1.WANPPPConnection.3.Stats", {}}
}

--Define the list of parameters to be restored in the table like "{path, {param1,param2,...}}"
local restoredParams_T = {
{"Device.UserInterface", {"PasswordRequired", "X_TELECOMITALIA_IT_LedLowConsumptionEnable"}},
{"Device.USB.USBHosts", {"X_TELECOMITALIA_IT_USBService"}},
{"Device.WiFi.Radio.{i}", {"Enable", "OperatingStandards", "Channel", "AutoChannelEnable", "AutoChannelRefreshPeriod", "X_TELECOMITALIA_IT_ChannelRefresh", "OperatingChannelBandwidth"}},
{"Device.WiFi.SSID.{i}", {"Enable", "SSID", "X_TELECOMITALIA_IT_MACAddressControlEnabled", "X_TELECOMITALIA_IT_AllowedMACAddresses"}},
{"Device.WiFi.AccessPoint.{i}", {"Enable", "SSIDAdvertisementEnabled", "WMMEnable", "X_TELECOMITALIA_IT_DisconnectTime"}},
{"Device.WiFi.AccessPoint.{i}.Security", {"ModeEnabled", "WEPKey", "KeyPassphrase"}},
{"Device.IP.Interface.3.IPv4Address.1", {"IPAddress", "SubnetMask"}},
{"Device.LANConfigSecurity", {"ConfigPassword"}},
{"Device.NAT", {"PortMappingNumberOfEntries", "X_TELECOMITALIA_IT_DynamicDNSNumberOfEntries", "X_TELECOMITALIA_IT_URLFilteringNumberOfEntries"}},
{"Device.NAT.InterfaceSetting.2", {"Enable", "X_TELECOMITALIA_IT_NATStartIPAddress", "X_TELECOMITALIA_IT_NATEndIPAddress", "X_TELECOMITALIA_IT_NATExcludedInternalIPAddresses"}},
{"Device.NAT.PortMapping.{i}", {"Enable", "Interface", "AllInterfaces", "LeaseDuration", "RemoteHost", "ExternalPort", "InternalPort", "Protocol", "InternalClient", "Description", "X_000E50_GUIDisabled", "X_000E50_InterfaceDisabled"}},
{"Device.NAT.X_TELECOMITALIA_IT_DynamicDNS.{i}", {"Enable", "Status", "Interface", "Domain", "Provider", "Username", "Password"}},
{"Device.NAT.X_TELECOMITALIA_IT_URLFiltering.{i}", {"Enable", "Interface", "FilteredURLs", "FilteredURLsExclude"}},
{"Device.DHCPv4.Server", {"Enable"}},
{"Device.DHCPv4.Server.Pool.1", {"Enable", "Interface", "MinAddress", "MaxAddress", "ReservedAddresses", "SubnetMask", "IPRouters", "StaticAddressNumberOfEntries"}},
{"Device.DHCPv4.Server.Pool.1.StaticAddress.{i}", {"Enable", "Chaddr", "Yiaddr"}},
{"Device.Users.User.1", {"Enable", "RemoteAccessCapable", "Username", "Password"}},
{"Device.UPnP.Device", {"Enable", "UPnPMediaServer"}},
{"Device.Firewall", {"Config"}},
{"Device.Services.VoiceService.{i}.VoiceProfile.{i}", {"PSTNFailOver"}},
{"Device.Services.VoiceService.1.VoiceProfile.1.X_TELECOMITALIA_IT_UAMap.{i}", {"FromUA", "ToVoicePort", "Preassigned"}},
{"Device.Services.VoiceService.1.VoiceProfile.1.X_TELECOMITALIA_IT_VoicePortMap.{i}", {"ToUA", "FromVoicePort", "Priority"}},
{"Device.Services.VoiceService.{i}.PhyInterface.{i}", {"X_TELECOMITALIA_IT_SwitchToPSTNIn", "X_TELECOMITALIA_IT_SwitchToPSTNOut", "X_TELECOMITALIA_IT_POSConfig"}}
}

--Define the restore wait infomation which is display in restore modem configuration.
local restoreWait_T = {
{"Device.DeviceInfo", "ModelName", "apparatus"},
{"Device.UserInterface.X_TELECOMITALIA_IT_WebPage", "Profile", "serviceProfile"},
{"Device.UserInterface", "PasswordRequired", "passwordSetting"},
{"Device.UserInterface", "X_TELECOMITALIA_IT_LedLowConsumptionEnable", "LedLowConsumptionEnable"},
{"Device.IP.Interface.3.IPv4Address.1", "IPAddress", "gatewayIpAddress"},
{"Device.IP.Interface.3.IPv4Address.1", "SubnetMask", "subnetMask"},
{"Device.DHCPv4.Server", "Enable", "dhcpEnable"},
{"Device.DHCPv4.Server.Pool.1", "Enable", "dhcpService"},
{"Device.DHCPv4.Server.Pool.1", "Interface", "dhcpInterface"},
{"Device.DHCPv4.Server.Pool.1", "MinAddress", "dhcpIpInit"},
{"Device.DHCPv4.Server.Pool.1", "MaxAddress", "dhcpIpFinal"},
{"Device.DHCPv4.Server.Pool.1", "ReservedAddresses", "allowedMacAddresses"},
{"Device.DHCPv4.Server.Pool.1", "SubnetMask", "dhcpSubnetMask"},
{"Device.DHCPv4.Server.Pool.1", "IPRouters", "dhcpIPRouters"},
{"Device.DHCPv4.Server.Pool.1", "StaticAddressNumberOfEntries", "dhcpStaticAddressNumberOfEntries"},
{"Device.NAT.", "PortMappingNumberOfEntries", "natPortMappingNumberOfEntries"},
{"Device.NAT.", "X_TELECOMITALIA_IT_DynamicDNSNumberOfEntries", "natDynamicDNSNumberOfEntries"},
{"Device.NAT.", "X_TELECOMITALIA_IT_URLFilteringNumberOfEntries", "natURLFilteringNumberOfEntries"},
{"Device.NAT.InterfaceSetting.2", "Enable", "natService"},
{"Device.NAT.InterfaceSetting.2", "X_TELECOMITALIA_IT_NATStartIPAddress", "natIpInit"},
{"Device.NAT.InterfaceSetting.2", "X_TELECOMITALIA_IT_NATEndIPAddress", "natIpFinal"},
{"Device.NAT.InterfaceSetting.2", "X_TELECOMITALIA_IT_NATExcludedInternalIPAddresses", "NATExcludedInternalIPAddresses"},
{"Device.NAT.PortMapping.{i}", "InternalClient","hostAddress"},
{"Device.NAT.PortMapping.{i}", "InternalPort","internalPort"},
{"Device.NAT.PortMapping.{i}", "ExternalPort","externalPort"},
{"Device.NAT.PortMapping.{i}", "Protocol","portMappingProtocol"},
{"Device.NAT.PortMapping.{i}", "Enable", "portMappingEnabled"},
{"Device.NAT.PortMapping.{i}", "Description", "portMappingDescription"},
{"Device.NAT.PortMapping.{i}", "Interface", "portMappingInterface"},
{"Device.NAT.PortMapping.{i}", "AllInterfaces", "portMappingAllInterfaces"},
{"Device.NAT.PortMapping.{i}", "LeaseDuration", "portMappingLeaseDuration"},
{"Device.NAT.PortMapping.{i}", "RemoteHost", "portRemoteHost"},
{"Device.PPP.Interface.1", "Name", "pppUser1Name"},
{"Device.PPP.Interface.2", "Name", "pppUser2Name"},
{"Device.Users.User.1", "Enable", "UserEnable"},
{"Device.Users.User.1", "RemoteAccessCapable", "RemoteAccessCapable"},
{"Device.Users.User.1", "Username", "Username"},
{"Device.Users.User.1", "Password", "Password"},
{"Device.LANConfigSecurity", "ConfigPassword", "passwordValue"},
{"Device.Firewall", "Config", "firewallSetting"},
{"Device.DHCPv4.Server.Pool.1.StaticAddress.{i}", "Enable", "preEnable"},
{"Device.DHCPv4.Server.Pool.1.StaticAddress.{i}", "Yiaddr", "preAllocatedIp"},
{"Device.DHCPv4.Server.Pool.1.StaticAddress.{i}", "Chaddr", "preAllocatedMacAddress"},
{"Device.WiFi.Radio.1", "Enable", "wifiRadioEnable"},
{"Device.WiFi.Radio.1", "AutoChannelEnable", "wifiAutoChannel"},
{"Device.WiFi.Radio.1", "Channel", "wifiChannel"},
{"Device.WiFi.Radio.1", "OperatingStandards", "wifiRadio1OperatingStandards"},
{"Device.WiFi.Radio.1", "AutoChannelRefreshPeriod", "wifiRadio1AutoChannelRefreshPeriod"},
{"Device.WiFi.Radio.1", "X_TELECOMITALIA_IT_ChannelRefresh", "wifiRadio1ChannelRefresh"},
{"Device.WiFi.Radio.1", "OperatingChannelBandwidth", "wifiRadio1OperatingChannelBandwidth"},
{"Device.WiFi.SSID.1", "SSID", "wifiSsid"},
{"Device.WiFi.SSID.1", "Enable", "wifiSsidEnable"},
{"Device.WiFi.SSID.1", "X_TELECOMITALIA_IT_MACAddressControlEnabled", "wifiAccessControl"},
{"Device.WiFi.SSID.1", "X_TELECOMITALIA_IT_AllowedMACAddresses", "wifiAllowMac"},
{"Device.WiFi.AccessPoint.1", "Enable", "wifiAccEnable"},
{"Device.WiFi.AccessPoint.1", "SSIDAdvertisementEnabled", "wifiAdvEnable"},
{"Device.WiFi.AccessPoint.1", "WMMEnable", "wifiWMMEnable"},
{"Device.WiFi.AccessPoint.1", "X_TELECOMITALIA_IT_DisconnectTime", "wifiDisTime"},
{"Device.WiFi.AccessPoint.1.Security", "ModeEnabled", "wifiBeaconType"},
{"Device.WiFi.AccessPoint.1.Security", "KeyPassphrase", "wifiKeyPassphrase"},
{"Device.WiFi.AccessPoint.1.Security", "WEPKey", "wifiWEPKey"},
{"Device.WiFi.Radio.2", "Enable", "wifi5RadioEnable"},
{"Device.WiFi.Radio.2", "AutoChannelEnable", "wifi5AutoChannel"},
{"Device.WiFi.Radio.2", "Channel", "wifi5Channel"},
{"Device.WiFi.Radio.2", "OperatingStandards", "wifiRadio2OperatingStandards"},
{"Device.WiFi.Radio.2", "AutoChannelRefreshPeriod", "wifiRadio2AutoChannelRefreshPeriod"},
{"Device.WiFi.Radio.2", "X_TELECOMITALIA_IT_ChannelRefresh", "wifiRadio2ChannelRefresh"},
{"Device.WiFi.Radio.2", "OperatingChannelBandwidth", "wifiRadio2OperatingChannelBandwidth"},
{"Device.WiFi.SSID.2", "SSID", "wifi5Ssid"},
{"Device.WiFi.SSID.2", "Enable", "wifiSsid5Enable"},
{"Device.WiFi.SSID.2", "X_TELECOMITALIA_IT_MACAddressControlEnabled", "wifi5AccessControl"},
{"Device.WiFi.SSID.2", "X_TELECOMITALIA_IT_AllowedMACAddresses", "wifi5AllowMac"},
{"Device.WiFi.AccessPoint.2", "Enable", "wifi5AccEnable"},
{"Device.WiFi.AccessPoint.2", "SSIDAdvertisementEnabled", "wifi5AdvEnable"},
{"Device.WiFi.AccessPoint.2", "WMMEnable", "wifi5WMMEnable"},
{"Device.WiFi.AccessPoint.2", "X_TELECOMITALIA_IT_DisconnectTime", "wifi5DisTime"},
{"Device.WiFi.AccessPoint.2.Security", "ModeEnabled", "wifi5BeaconType"},
{"Device.WiFi.AccessPoint.2.Security", "KeyPassphrase", "wifi5KeyPassphrase"},
{"Device.WiFi.AccessPoint.2.Security", "WEPKey", "wifi5WEPKey"},
{"Device.WiFi.SSID.3", "Enable", "wifiGuestEnable"},
{"Device.WiFi.SSID.3", "SSID", "wifiGuestSsid"},
{"Device.WiFi.SSID.3", "X_TELECOMITALIA_IT_MACAddressControlEnabled", "wifiGuestAccessControl"},
{"Device.WiFi.SSID.3", "X_TELECOMITALIA_IT_AllowedMACAddresses", "wifiGuestAllowMac"},
{"Device.WiFi.AccessPoint.3", "Enable", "wifiGuestAccEnable"},
{"Device.WiFi.AccessPoint.3", "SSIDAdvertisementEnabled", "wifiGuestAdvEnable"},
{"Device.WiFi.AccessPoint.3", "WMMEnable", "wifiGuestWMMEnable"},
{"Device.WiFi.AccessPoint.3", "X_TELECOMITALIA_IT_DisconnectTime", "wifiGuestDisTime"},
{"Device.WiFi.AccessPoint.3.Security", "ModeEnabled", "wifiGuestBeaconType"},
{"Device.WiFi.AccessPoint.3.Security", "KeyPassphrase", "wifiGuestKeyPassphrase"},
{"Device.WiFi.AccessPoint.3.Security", "WEPKey", "wifiGuestWEPKey"},
{"Device.WiFi.SSID.4", "Enable", "wifiGuest5Enable"},
{"Device.WiFi.SSID.4", "SSID", "wifiGuest5Ssid"},
{"Device.WiFi.SSID.4", "X_TELECOMITALIA_IT_MACAddressControlEnabled", "wifiGuest5AccessControl"},
{"Device.WiFi.SSID.4", "X_TELECOMITALIA_IT_AllowedMACAddresses", "wifiGuest5AllowMac"},
{"Device.WiFi.AccessPoint.4", "Enable", "wifiGuest5AccEnable"},
{"Device.WiFi.AccessPoint.4", "SSIDAdvertisementEnabled", "wifiGuest5AdvEnable"},
{"Device.WiFi.AccessPoint.4", "WMMEnable", "wifiGuest5WMMEnable"},
{"Device.WiFi.AccessPoint.4", "X_TELECOMITALIA_IT_DisconnectTime", "wifiGuest5DisTime"},
{"Device.WiFi.AccessPoint.4.Security", "ModeEnabled", "wifiGuest5BeaconType"},
{"Device.WiFi.AccessPoint.4.Security", "KeyPassphrase", "wifiGuest5KeyPassphrase"},
{"Device.WiFi.AccessPoint.4.Security", "WEPKey", "wifiGuest5WEPKey"},
{"Device.Hosts.Host.{i}", "HostName", "hostName"},
{"Device.Hosts.Host.{i}", "IPAddress", "wifiIp"},
{"Device.Hosts.Host.{i}", "PhysAddress", "wifiMacAddress"},
{"Device.USB.USBHosts", "X_TELECOMITALIA_IT_USBService", "usbService"},
{"Device.NAT.X_TELECOMITALIA_IT_URLFiltering.1", "Enable", "urlEnable"},
{"Device.NAT.X_TELECOMITALIA_IT_URLFiltering.1", "FilteredURLs", "urlFilterUrls"},
{"Device.NAT.X_TELECOMITALIA_IT_URLFiltering.1", "FilteredURLsExclude", "urlexcludeEnable"},
{"Device.NAT.X_TELECOMITALIA_IT_URLFiltering.1", "Interface", "urlFilteringInterface"},
{"Device.NAT.X_TELECOMITALIA_IT_DynamicDNS.{i}", "Provider", "dynProvider"},
{"Device.NAT.X_TELECOMITALIA_IT_DynamicDNS.{i}", "Domain", "dynDomain"},
{"Device.NAT.X_TELECOMITALIA_IT_DynamicDNS.{i}", "Username", "dynUsername"},
{"Device.NAT.X_TELECOMITALIA_IT_DynamicDNS.{i}", "Password", "dynPassword"},
{"Device.NAT.X_TELECOMITALIA_IT_DynamicDNS.{i}", "Enable", "dynEnable"},
{"Device.NAT.X_TELECOMITALIA_IT_DynamicDNS.{i}", "Status", "dynStatus"},
{"Device.NAT.X_TELECOMITALIA_IT_DynamicDNS.{i}", "Interface", "dynInterface"},
{"Device.UPnP.Device", "UPnPMediaServer", "upnpMedia"},
{"Device.UPnP.Device", "Enable", "upnpEnable"},
{"Device.Services.VoiceService.1.VoiceProfile.1.X_TELECOMITALIA_IT_UAMap.{i}", "FromUA", "fromUA"},
{"Device.Services.VoiceService.1.VoiceProfile.1.X_TELECOMITALIA_IT_UAMap.{i}", "ToVoicePort", "toVP"},
{"Device.Services.VoiceService.1.VoiceProfile.1.X_TELECOMITALIA_IT_UAMap.{i}", "Preassigned", "UAMAPPreassigned"},
{"Device.Services.VoiceService.1.VoiceProfile.1.X_TELECOMITALIA_IT_VoicePortMap.{i}", "ToUA", "toUA"},
{"Device.Services.VoiceService.1.VoiceProfile.1.X_TELECOMITALIA_IT_VoicePortMap.{i}", "FromVoicePort", "fromVP"},
{"Device.Services.VoiceService.1.VoiceProfile.1.X_TELECOMITALIA_IT_VoicePortMap.{i}", "Priority", "portmapPriority"},
{"Device.Services.VoiceService.1.PhyInterface.1", "X_TELECOMITALIA_IT_SwitchToPSTNIn", "pstnin1"},
{"Device.Services.VoiceService.1.PhyInterface.1", "X_TELECOMITALIA_IT_SwitchToPSTNOut", "pstnout1"},
{"Device.Services.VoiceService.1.PhyInterface.1", "X_TELECOMITALIA_IT_POSConfig", "pos1"},
{"Device.Services.VoiceService.1.PhyInterface.2", "X_TELECOMITALIA_IT_SwitchToPSTNIn", "pstnin2"},
{"Device.Services.VoiceService.1.PhyInterface.2", "X_TELECOMITALIA_IT_SwitchToPSTNOut", "pstnout2"},
{"Device.Services.VoiceService.1.PhyInterface.2", "X_TELECOMITALIA_IT_POSConfig", "pos2"},
{"Device.Services.VoiceService.1.PhyInterface.3", "X_TELECOMITALIA_IT_SwitchToPSTNIn", "pstnin3"},
{"Device.Services.VoiceService.1.PhyInterface.3", "X_TELECOMITALIA_IT_SwitchToPSTNOut", "pstnout3"},
{"Device.Services.VoiceService.1.PhyInterface.3", "X_TELECOMITALIA_IT_POSConfig", "pos3"},
{"Device.Services.VoiceService.1.PhyInterface.4", "X_TELECOMITALIA_IT_SwitchToPSTNIn", "pstnin4"},
{"Device.Services.VoiceService.1.PhyInterface.4", "X_TELECOMITALIA_IT_SwitchToPSTNOut", "pstnout4"},
{"Device.Services.VoiceService.1.PhyInterface.4", "X_TELECOMITALIA_IT_POSConfig", "pos4"},
--Not define the below path as multi path, just single every parameter.
{"Device.Services.VoiceService.1.VoiceProfile.1", "PSTNFailOver", "pstnfail1"},
{"Device.Services.VoiceService.2.VoiceProfile.1", "PSTNFailOver", "pstnfail2"},
{"Device.Services.VoiceService.2.VoiceProfile.2", "PSTNFailOver", "pstnfail3"},
{"Device.Services.VoiceService.2.VoiceProfile.3", "PSTNFailOver", "pstnfail4"},
{"Device.Services.VoiceService.2.VoiceProfile.4", "PSTNFailOver", "pstnfail5"},
{"Device.Services.VoiceService.3.VoiceProfile.1", "PSTNFailOver", "pstnfail6"},
{"Device.Services.VoiceService.3.VoiceProfile.2", "PSTNFailOver", "pstnfail7"},
{"Device.Services.VoiceService.3.VoiceProfile.3", "PSTNFailOver", "pstnfail8"},
{"Device.Services.VoiceService.3.VoiceProfile.4", "PSTNFailOver", "pstnfail9"},
{"Device.Services.VoiceService.3.VoiceProfile.5", "PSTNFailOver", "pstnfail10"},
{"Device.Services.VoiceService.3.VoiceProfile.6", "PSTNFailOver", "pstnfail11"},
{"Device.Services.VoiceService.3.VoiceProfile.7", "PSTNFailOver", "pstnfail12"},
{"Device.Services.VoiceService.3.VoiceProfile.8", "PSTNFailOver", "pstnfail13"},
{"Device.Services.VoiceService.3.VoiceProfile.9", "PSTNFailOver", "pstnfail14"},
{"Device.Services.VoiceService.3.VoiceProfile.10", "PSTNFailOver", "pstnfail15"},
{"Device", "WEPKeyInAtomic", "wepkey"},
{"Device", "FXONumber", "fxonumber"}
}

--Judge whether the table is null
function table_is_empty(t)

        return _G.next( t ) == nil

end

--Get the username from ppp management.
function getUsernameFromPPPManagement()
    local username
    local pathStr = "Device.PPP.Interface.1"
    local data, error = mbus.getParameters{path=pathStr, param="Username", datamodel="second"}
    if data[pathStr][1] ~= nil then
        username = data[pathStr][1].param["Username"]
        local position = string.find(username, "@")
        if position ~= nil then
            username = string.sub(username, 1, position-1)
        end

	--tprint("@@@getUsernameFromPPPManagement end")
        return username
    end
end

--Get the username which was made up with management ppp and data ppp.
function getUsernameWithPPP(usernameParam)
	--tprint("@@@getUsernameWithPPP start")
	local username = getUsernameFromPPPManagement()
	if username~=nil then
		local realnamePos = string.find(usernameParam, "@")
		if realnamePos ~= nil then
			username = username .. tostring(string.sub(usernameParam, realnamePos))
		end
        end
	--tprint("@@@getUsernameWithPPP end")
	return username
end

--Get the path of data ppp
function getPathWithDataPPP()
	local pathStr = "Device.PPP.Interface"
	local data, error = mbus.getParameters{path=pathStr, param="Name", filter="(== Name 'User session')", datamodel="second"}
	if data[pathStr][1] ~= nil then
		return data[pathStr][1].path	
	end
	return pathStr..".3"
end

--Get the extend name and start position from the path of IGD, which is the string after the last point.
--Like "InternetGatewayDevice.WANDevice.1.WANConnectionDevice.1.WANPPPConnection.3", it should be "3" to the extend name.
--Like "InternetGatewayDevice.WANDevice.1.WANConnectionDevice.1.WANPPPConnection.3.PortMapping", it should be "PortMapping" to the extend name.
function getExtendName(pathStr)
	local startIndex, endIndex, extendName = string.find(pathStr, "%.([^.]+)$")
	return extendName, startIndex
end

--Start to update the data from AGconfig.xml to Device
function execRestore()
	--tprint("@@@ execRestore start")
	local isNatRangeDefault=false
	local usernameParam 
	local factoryFlag = isAgInFactory()
	local pathDataPPP = getPathWithDataPPP()

	local dhcpServer_T = {}
	local channelAuto_T = {}
	for i,obj_T in pairs(stack) do
		local modify = {}
		local params_T = {}
		local pathStr = obj_T[1]
		local paramName = obj_T[2][1]
		local paramValue = obj_T[2][2]

        --Deal with the "&" in KeyPassphrase of wifi part.
        if (pathStr=="Device.WiFi.AccessPoint.1.Security" or pathStr=="Device.WiFi.AccessPoint.2.Security") and paramName=="KeyPassphrase" then
            if string.find(paramValue, "&amp;")~=nil then
                paramValue = string.gsub(paramValue, "&amp;", "&")
            end
            if string.find(paramValue, "&lt;")~=nil then
                paramValue = string.gsub(paramValue, "&lt;", "<")
            end
            if string.find(paramValue, "&gt;")~=nil then
                paramValue = string.gsub(paramValue, "&gt;", ">")
            end
            if string.find(paramValue, "&quot;")~=nil then
                paramValue = string.gsub(paramValue, "&quot;", "\"")
            end
        end
        --deal with the urlFilter add object.
        if paramName=="FilteredURLs" then
            paramName = "AddURL"
        end

        if paramName=="AddURL" then
            --local paramClearUrl_T["ClearURL"] = "1"
            table.insert(modify, {path=pathStr, param={ClearURL="1"}, datamodel="second"})
            setMBUS_IGD(modify)

            params_T[paramName] = paramValue
            table.insert(modify, {path=pathStr, param=params_T, datamodel="second"})
            setMBUS_IGD(modify)
        else
            params_T[paramName] = paramValue
            table.insert(modify, {path=pathStr, param=params_T, datamodel="second"})
            setMBUS_IGD(modify)
        end
	end

    --Restore the wepkey to atomic for ascii code displayed in the screen.
    local modify = {}
    local wepkeyForGuset = wepGuestKey
    if wepkeyForGuset~="" then
        local wepkeyPath = "WLAN.Intf.2.Security.WEP"
        table.insert(modify, {path = wepkeyPath, param = {WEPKey=wepkeyForGuset}})
        setMBUS(modify)
    end

    --Deal with the ENV value of FXO number.
    local modify = {}
    local fixedFXONum = fxoTeleNumber
    if fixedFXONum~="" then
        local IsFXONumExist = getFXONum()
        if IsFXONumExist=="" then
            local reply, error = mbus.modify(
            function()
                local reply, error = mbus.addObjects{path = "ENV", param = {Value = fixedFXONum, Name = "IsFXONum"}}
            end)
        else
            local replyFXOPath, errorFXOPath = mbus.getParameters{ path = "ENV", param = { "Name", "Value" }, filter = "(== Name ".. "IsFXONum" ..")" }
            local FXOPath = replyFXOPath["ENV"][1].path
            table.insert(modify, {path = FXOPath, param = {Value = fixedFXONum}})
            setMBUS(modify)
        end
    end

    --Deal with the ENV value of currentTime for wifi guest disconnect time.
    local currentTime = os.time()
    local reply,error = mbus.getParameters{path ="ENV",param = "Value",filter = "(== Name ".."Wlan_Time"..")"}
    mbus.modify(    
        function()
            if reply["ENV"][1] ~= nil and reply["ENV"][1].param ~= nil and reply["ENV"][1].param["Value"] ~= "" then 
                mbus.setParameters{path = "ENV.Wlan_Time" , param = {Value = tostring(currentTime)},flags = "KEYPATH"}
            else
                mbus.addObjects{ path = "ENV",param = {Name = "Wlan_Time",Value = tostring(currentTime)},flags = "KEYPATH"}
            end
        end)

	--update ip, or netmask or dhcp range 
	if isLanConfigChanged=="true" then
		setMBUS_IGD(dhcpServer_T)
		sleep(10)
	end
	--tprint("@@@ execRestore end")
end


--Add the object to the Device
function addObject(set)
	local pathDetail
	local pathStr = set["path"]	
	local param_T = set["param"]
    if string.match(pathStr, "PortMapping")~=nil then
        pathStr = "Device.NAT.PortMapping"
        local name = param_T["Description"]
        local interCli = param_T["InternalClient"]
        local protocol = param_T["Protocol"]
        local internalPort = param_T["InternalPort"]
        local externalPort = param_T["ExternalPort"]
        local status = param_T["Enable"]
        local interface = param_T["Interface"]
        local manualDisabled = "0"
        local intfDisabled = "0"
	local result = 0
        local reply, error = mbus.modify(
        function()
            local reply1, error1 = mbus.addObjects{ path = pathStr, param = { Description = name, 
                                                                              InternalClient = interCli, 
                                                                              InternalPort = internalPort, 
                                                                              ExternalPort = externalPort, 
                                                                              Protocol = protocol, 
                                                                              Enable = status, 
                                                                              Interface = interface, 
                                                                              X_000E50_GUIDisabled = manualDisabled, 
                                                                              X_000E50_InterfaceDisabled = intfDisabled}, datamodel="second"}
        end, {datamodel="second"})
    elseif string.match(pathStr, "X_TELECOMITALIA_IT_DynamicDNS")~=nil then
        pathStr = "DynDNS.Client"
        local username = param_T["Username"]
        local password = param_T["Password"]
        local dynEnable = param_T["Enable"]
        local serviceProvider = param_T["Provider"]
        local domainName = get_domain_name_from_url(param_T["Domain"])
        local servicePath, dynDnsClientPath
        local info = getPPP("PPP.Intf.2")
        local interface = info.ipintf
        if serviceProvider=="dyndns.it" then
            servicePath = "DynDNS.Service.1"
        elseif serviceProvider=="dyndns.org" then
            servicePath = "DynDNS.Service.2"
        elseif serviceProvider=="no-ip.com" then
            servicePath = "DynDNS.Service.3"
        elseif serviceProvider=="dtdns.com" then
            servicePath = "DynDNS.Service.4"
        end

        local reply, error = mbus.modify(
            function()
                local reply1, error1 = mbus.addObjects{path=pathStr, param={UserName=username, Password=password, Service=servicePath, Interface=interface}}
                if error1 ~= nil then
                    cgilua.redirect("resultKO.lp")
                    return
                end

                dynDnsClientPath=reply1[pathStr][1].path
                local reply2, error2 = mbus.addObjects{path = dynDnsClientPath..".Host", param = {Name=domainName}}
                if error2 ~= nil then
                    cgilua.redirect("resultKO.lp")
                    return
                end 
            end)
        if info.ppp_status ~= "Connected" then
            local modify = {}
            table.insert(modify, {path="PPP.Intf.2", param= {TI_Enable="true"}})
            setMBUS(modify)
        end
        if dynDnsClientPath ~= nil then
            modify = {}
            table.insert(modify, {path=dynDnsClientPath, param= {Enable=dynEnable}})
            setMBUS(modify)
        end
    elseif string.match(pathStr, "StaticAddress")~=nil then
        local dhcpStaticAddrEnable = param_T["Enable"]
	local yiaddr = param_T["Yiaddr"]
	local chaddr = param_T["Chaddr"]
	local result = 0
        if dhcpStaticAddrEnable=="true" then
            local reply, error = mbus.modify(
            function()
                local reply1, error1 = mbus.addObjects{ path = pathStr, param = { Enable=dhcpStaticAddrEnable,
										  Yiaddr=yiaddr,
                                                                                  Chaddr=chaddr}, datamodel="second"}
            end, {datamodel="second"})
        end
    else
        local reply, error = mbus.modify(
        function()
            local reply1, error1 = mbus.addObjects{path = pathStr, param = param_T, datamodel="second"}
                pathDetail=reply1[pathStr][1].path
                if error1~=nil then
                    result=1
                end
        end, {datamodel="second"})	
        return pathDetail
    end
end

--Update the object to the Device2
function updateObject(set)
	local pathStr = set["path"]	
	local param_T = set["param"]
	local modify = {}
	
	table.insert(modify, {path=pathStr, param=param_T, datamodel="second"})
	
	setMBUS_IGD(modify)
end

--Create the object in Device
function objectCreate(set)

	--tprint("@@@###objectCreate start.....")	
	--tprint(set)	
	local result=0
	local pathStr = set["path"]	
	local param_T = set["param"]	
	
	local extendName, startPosition = getExtendName(pathStr)
	if type(tonumber(extendName)) == "number" then
		pathStr = string.sub(pathStr, 1, startPosition-1)
		extendName,startPosition  = getExtendName(pathStr)
		set["path"]=pathStr		
	end	
	
	local pathDetail = addObject(set)

	if extendName=="Interface" then --PPP.Interface
		local modify = {}	
		local username = getUsernameWithPPP(param_T["Username"])
		table.insert(modify, {path=pathDetail, param={Username=username}, datamodel="second"})
		table.insert(modify, {path=pathDetail, param={Name="User session"}, datamodel="second"})	
		table.insert(modify, {path=pathDetail, param={DNSServers=param_T["DNSServers"]}, datamodel="second"})	
		table.insert(modify, {path=pathDetail, param={ConnectionTrigger=param_T["ConnectionTrigger"]}, datamodel="second"})
		table.insert(modify, {path=pathDetail, param={Enable=param_T["Enable"]}, datamodel="second"})

		--If the nat ip range is 0.0.0.0, it would be reset to it default value.
                if param_T["X_TELECOMITALIA_IT_NATStartIPAddress"] == "0.0.0.0" or param_T["X_TELECOMITALIA_IT_NATEndIPAddress"] == "0.0.0.0" then
			table.insert(modify, {path=pathDetail, param={X_TELECOMITALIA_IT_NATStartIPAddress=natIpInitDefault, X_TELECOMITALIA_IT_NATEndIPAddress=natIpFinalDefault}, datamodel="second"})
                end

		setMBUS_IGD(modify)
	end
	--tprint("@@@###objectCreate end.....")	
end


--Delete the object in Device
function deleteObject(pathStr)
	local reply, error = mbus.modify(
	function()
		local reply1, error1 = mbus.deleteObjects{ path = pathStr, datamodel="second"}
	end, {datamodel="second"})
end

--Delete the PortMapping and DHCPStaticAddress by the path
function deleteObjectByPath()
	local pathObj_T = {{path="Device.DHCPv4.Server.Pool.1.StaticAddress"}, {path="Device.NAT.PortMapping"}, {path="Device.NAT.X_TELECOMITALIA_IT_DynamicDNS"}}

	for i,set in pairs(pathObj_T) do
		deleteObject(set["path"])
	end	
end

--Query from Device to check whether it is existed.
function isExistedInAg(set)
	local flag = false
	local pathStr = set[1]
	local paramStr = set[2][1]

	local data, error = mbus.getParameters{path=pathStr, param=paramStr, datamodel="second"}
	if table_is_empty(data[pathStr][1].param) == false then
		flag = true
	end

	return flag
end

--Compare with params between stack and exception tables.
function compareParams(paramStack_T, paramFilter_T)
	local paramElement = paramStack_T[1]	
													
	for t,paramFilter in pairs(paramFilter_T) do	
		if paramElement == paramFilter then
			return true
		end
	end								
	return false
end

--Get the table of param like param={paramName1=paramValue1,paramName2=paramValue2,...}
function getParamByPath(instance)
	local pathStr = instance[1]
	local param_T = {}
	for j,obj_T in pairs(stack) do
		if pathStr==obj_T[1] and obj_T[2][1]~="X_TELECOMITALIA_IT_HostMACAddress" then
			param_T[obj_T[2][1]]=obj_T[2][2]
		end
	end
	return param_T
end

--Assemble the object in factory default like "{path=pathName, param={paramName1=paramValue1,paramName2=paramValue2,...}"
function assembleObjInFactory(path_T)
	local list = {}	
	for i,pathElem in pairs(path_T) do
		if isExistedInAg(pathElem)==false then			
			local param_T = getParamByPath(pathElem)			
			
			if table_is_empty(param_T)==false then
				table.insert(list, {path=pathElem[1], param=param_T})
			end
		end
	end
	return list
end

--Assemble the object in Configured like "{path=pathName, param={paramName1=paramValue1,paramName2=paramValue2,...}"
function assembleObjConfigured(path_T)
	local list = {}	
	for i,pathElem in pairs(path_T) do
		local param_T = getParamByPath(pathElem)			
			
		if table_is_empty(param_T)==false then
			table.insert(list, {path=pathElem[1], param=param_T})
		end
	end
	return list
end

--Check whether the path is existed in the path stack
function isExistedInPathStack(path_T, obj_T)
	local pathStr = obj_T[1]
	
	for j,pathElem in pairs(path_T) do		
		if pathStr==pathElem[1] then
			return true
		end
	end
	
	return false
end

--Check the multi exception for path
function pathFormatInFactory(pathStr)
	local result = pathStr
	local startIndex, endIndex, extendName = string.find(pathStr, "%.([^.]+)$")
	if type(tonumber(extendName)) == "number" then
		result = string.sub(pathStr, 1, startIndex) .. "{i}"		
	end
	return result
end

--Remove the factory exception data from stack
function removeExceptionData(stackFiltered)
	table.sort(stackFiltered, function(x, y) return x > y end)
	for i,obj_T in pairs(stackFiltered) do		
		local removeStack_T = table.remove(stack, obj_T)
	end
end

--Handle the factory exception list
function isInExceptionList(set)
	local pathStr = set[1]
	local params_T = set[2]

	for j,objElem in pairs(factoryException_T) do
		local isMultiException = string.find(objElem[1], "{i}")
		if isMultiException ~= nil then
			pathStr = pathFormatInFactory(pathStr)
		end
 		
		if pathStr == objElem[1] then
			local paramStr = objElem[2][1]
			if paramStr == nil then
				return true
			end
			if compareParams(params_T, objElem[2]) then	
				return true
			end				 
		end
	end
	return false
end

--Handle the restore list
function isInRestoreList(set)
	local pathStr = set[1]
	local params_T = set[2]

	for i, elem_T in pairs(restoredParams_T) do
        local pathIdxToPatten = string.gsub(elem_T[1], "%.{i}", "%%.(%%d+)")
        local isPathMatch,_,idx = string.find(pathStr, pathIdxToPatten.."$")
		if nil ~= isPathMatch then
			if compareParams(params_T, elem_T[2]) then
				return true
			end
		end
	end
	return false
end

--Filter the data for factory default, which should not change the ppp session name and should assemble the object which didn't exist in the Device.
function filterDataInFactory()
	local path_T = {}
	local stackFiltered = {}

	for i,obj_T in pairs(stack) do
		--Record the factory exception element.
		if isInExceptionList(obj_T) then
			table.insert(stackFiltered, i)
		end

		--Get all the path together
		if isExistedInPathStack(path_T, obj_T) == false then		
			table.insert(path_T, obj_T)
		end
	end	
	
	--Remove the element from the stack which is in factory exception
	removeExceptionData(stackFiltered)

	--Get the list after assembling the object.
	return assembleObjInFactory(path_T)
end

--Filter the data for configured data, which could not be changed if it not in the restore list.
function filterDataConfigured()
	local restoreList = {}
	local path_T = {}
	local portMappingPath = "Device.NAT.PortMapping.{i}"
	local dhcpPath = "Device.DHCPv4.Server.Pool.{i}.StaticAddress.{i}"
	local dynDnsPath = "Device.NAT.X_TELECOMITALIA_IT_DynamicDNS.{i}"
    
	for i,obj_T in ipairs(stack) do
		local pathStr = string.gsub(obj_T[1], "%.%d+", "%.{i}")
		local params_T = obj_T[2]

		--To check whether it is port mapping, if yes then add its path to the pathStack.
		if (pathStr == portMappingPath or pathStr == dhcpPath or pathStr == dynDnsPath) and isExistedInPathStack(path_T, obj_T) == false then
			table.insert(path_T, obj_T)
		else	
			--If it is in the list of restore, it should be add to the stack of filter
			if isInRestoreList(obj_T) then			
				table.insert(restoreList, obj_T)
			end
		end	
	end

	--Get the list after assembling the object of port mapping and dhcp static address.
	local portMappingAndDhcpAndDynDNSList = assembleObjConfigured(path_T)

	--Get the restore list which should be updated
	stack = {}
	stack = restoreList 

	return portMappingAndDhcpAndDynDNSList 
end

--As readonly params can't be modified in mbus, it's only to filter the PPP session.
function restoreAgInFactory()
	--Delete the DHCPStaticAddress if it existed in the Device.
	deleteObjectByPath()

	local list = filterDataInFactory()
	execRestore()

	if list ~= nil then		
		table.sort(list, function(x, y) return string.lower(x["path"]) < string.lower(y["path"]) end)
		for i,set in pairs(list) do 
			objectCreate(set)
		end
	end

end

--It should be filtered before restore the already configured data.
function restoreAgConfiged()

	local pathObj = "Device.NAT.PortMapping"
	deleteObject(pathObj)	
	
	local list = filterDataConfigured()
	execRestore()
	return list
end

function restoreAgConfigedFilteredData(list)
	--If it is port mapping and dhcp static address, it should be deleted first, and then add the new object.
	if list~=nil then 
		--Delete the StaticAddress and PortMapping if it existed in the Device.


		for i,set in pairs(list) do
		        local pathStr = set["path"]
		        local param_T = set["param"]
			objectCreate(set)
		end
	end	
end

--Query from Device to check whether it is AG in factory or already configured
function isAgInFactory()
	local flag = true
	local pathStr = "Device.ManagementServer"
	local data, error = mbus.getParameters{path=pathStr, param="X_TELECOMITALIA_IT_ServiceRealm", datamodel="second"}
	if data[pathStr] ~= nil then
		if data[pathStr][1].param["X_TELECOMITALIA_IT_ServiceRealm"] ~= "alicenewborn.mgmt" then
			flag = false
		end
	end

	return flag
end

--update the data of the AGconfig.xml to Device
function updateParams()	
	--disable the dhcp pool before updating
	setDHCPServer("0")

	--set the operation flag of ip changing before updating.
	ipChangeSet("1")

	local list
	local factoryFlag = isAgInFactory()
	if factoryFlag then
		list = restoreAgInFactory()
	else
		list = restoreAgConfiged()
	end
	sleep(5)
	
	--set the operation flag of ip changing after updating.
        ipChangeSet("0")		

	--update the state of dhcp pool after updating.
	--setDHCPServerState(dhcpServerState)
	setDHCPServer("1")

	restoreAgConfigedFilteredData(list)	

        --update the state of media server after updating.
        setMediaServerState()

        --update the wifi and wifi guest allowed mac.
        setWifiAllowMac()

	--Add the dhcp lease for linux service such as 192.168.1.254
	if isLanConfigChanged == "true" then
		addDhcpLease()
	end
end

--Add the dhcp lease for Linux service.
function addDhcpLease()
	local dhcpPoolPath = "DHCP.Server.Pool.1"
	local dhcpLeasePath= "DHCP.Server.Lease"
	local LMAC, gateWayIp, dhcpIpEnd

	local reply1, error1 = mbus.getParameters{ path = "ENV", param = "Value", filter = "(== Name _LMACADDR)" }
	if (reply1["ENV"][1]~=nil) and (reply1["ENV"][1].param~=nil) then
		LMAC=reply1["ENV"][1].param["Value"]
		-- env format is 02-90-D0-4E-F7-81, must change to 02:90:d0:4e:f7:81
		LMAC=tostring(LMAC)
		LMAC=string.gsub(LMAC,"-",":")
		LMAC=string.lower(LMAC)
	end

	local reply2, error2 = mbus.getParameters{ path = dhcpLeasePath, param = "MACAddress", filter = "(== MACAddress " .. LMAC .. ")" }
        if reply2[dhcpLeasePath][1]~=nil then
		local leasePathStr = reply2[dhcpLeasePath][1].path
		local reply, error = mbus.modify(
                                function()
                                        local reply1, error1 = mbus.deleteObjects{path=leasePathStr}
                                end)	
        end

	local reply3, error3 = mbus.getParameters{ path = dhcpPoolPath, param = {"Gateway", "MaxAddress"} }
	if (reply3[dhcpPoolPath][1]~=nil) and (reply3[dhcpPoolPath][1].param~=nil) then
		gateWayIp = reply3[dhcpPoolPath][1].param["Gateway"]
		dhcpIpEnd = reply3[dhcpPoolPath][1].param["MaxAddress"] 
	end

	local reply, error = mbus.modify(
	function()
		if (LMAC~=nil) then
			local reply2, error2 = mbus.addObjects{ path = dhcpLeasePath,
								param = { ClientID = LMAC,
									IPAddress = dhcpIpEnd,
									MACAddress = LMAC,
									DHCPServerPool = dhcpPoolPath ,
									LeaseTime = "0",
									ExpirationTime = "0",
									Gateway = gateWayIp,
									Allocation = "manual" } }
		end
	end)		

end

--Get the detail path from the path stack.like "InternetGatewayDevice.LANDevice.1.LANEthernetInterfaceConfig.1.Stats"
local function getPathFromTop(pathStack)
	local pathStr = ""
	for i,v in pairs(pathStack) do
		pathStr = pathStr .. "." .. v
	end
	return string.sub(pathStr, 2, string.len(pathStr))
end

--Insert each of the param to the table like : "{path, {paramName, ParamValue}}"
local function setEachParamToObjStack(pathStr, paramName, paramValue)

	local paramStack={}
	table.insert(paramStack, paramName)
	table.insert(paramStack, paramValue)
	table.insert(stack,{pathStr, paramStack})
	
end

--Parse the xargs "id=n", and return the multiobj's index
local function parseArgs(s)
	local arg = {}
	string.gsub(s, "(%w+)=([\"'])(.-)%2", function (w, _, a)
		arg[w] = a
	end)
  	return arg["id"]
end

--Match the partent path to the pathStr
local function matchParentPath(pathStr, pathParentStr)

	if pathParentStr==nil then
		return false
	end
	
	local search = string.find(pathStr, tostring(pathParentStr))
	if search~=nil then	
		return true
	end

	return false
end

--Get the path sequence if it is existed in the pathList_T
local function getPathSequenceNum(pathStr, oldPathStr)
	local pathSequenceNum
	local pathStrWithoutNum = string.gsub(pathStr, ".%d+", "")
	for i, pathElem in pairs(pathList_T) do			
			
		if pathStrWithoutNum == pathElem[1] then				
			local ext, pos = getExtendName(pathStr)
			if type(tonumber(ext)) == "number" and tonumber(ext)>3 then					
				if pathStr~=oldPathStr then							
					pathElem[2] = pathElem[2] + 1
				end
				pathSequenceNum = pathElem[2]
				return pathSequenceNum					
			end				
		end				
	end
	return false
end

--Check whether it is wan device.
local function isWanConnectionDevice(pathStrWithoutNum)
	local pos = string.find(pathStrWithoutNum, "InternetGatewayDevice.WANDevice.WANConnectionDevice")
	if pos ~= nil then
		return true
	end
	return false
end

--Restruct the stack in order to deal with other vendors xml.
local function restructStack()
	local oldPathStr
	local newPathStr
	local oldPathParentStr
	local newPathParentStr
	local lastOldPathParentStr
	local lastNewPathParentStr

	for i, obj_T in pairs(stack) do
		local pathStr = obj_T[1]
		local pathStrWithoutNum = string.gsub(pathStr, ".%d+", "")
			
		if isWanConnectionDevice(pathStrWithoutNum) then
			local pathSequenceNum = getPathSequenceNum(pathStr, oldPathStr)
			if pathSequenceNum ~= false then
				oldPathStr = pathStr
				local ext, pos = getExtendName(pathStr)			
				newPathStr = string.sub(pathStr, 1, pos) .. tostring(pathSequenceNum)
				obj_T[1] = newPathStr			
			
				if pathStrWithoutNum == pathList_T[3][1] then
					lastOldPathParentStr = oldPathStr
					lastNewPathParentStr = newPathStr
				end

				if pathStrWithoutNum == pathList_T[1][1] or pathStrWithoutNum == pathList_T[2][1] then					
					oldPathParentStr = oldPathStr
					newPathParentStr = newPathStr
				end
			end
	
			if matchParentPath(pathStr, oldPathParentStr) then
				obj_T[1] = string.gsub(pathStr, oldPathParentStr, newPathParentStr)
			end
	
			if matchParentPath(pathStr, lastOldPathParentStr) then
				pathStr = obj_T[1]
				obj_T[1] = string.gsub(pathStr, lastOldPathParentStr, lastNewPathParentStr)
			end
		end
	end
	
end

function isOtherVendor(pathStr)
	local pathStrWithoutNum = string.gsub(pathStr, ".%d+", "")
					
	if pathStrWithoutNum == pathList_T[3][1] then
		local ext, pos = getExtendName(pathStr)
		if tonumber(ext)>3 then
			return true
		end
	end
	return false
end

--Parse the AGconfig.xml to table as the type : "{path, {paramName, ParamValue}}"		
local function parseXml(s)

    local srcfile = string.sub(s, 271)
    s = "<Device>" .. srcfile
	local ni,c,label,xarg, empty
	local i, j = 1, 1		
	local top = {}
	--local otherVendorFlag = false

	while true do

		ni,j,c,label,xarg, empty = string.find(s, "<(%/?)([%w_:]+)(.-)(%/?)>", i)
		
		if not ni then break end	
		
		if empty == "/" then	-- empty element tag
			local pathStr = getPathFromTop(top)
            if label~="FXONumber" and label~="WEPKeyInAtomic" then
			    setEachParamToObjStack(pathStr, label, "")
            end
		elseif c == "" then	 -- start tag
						
			local pathStart = label
			if xarg ~= "" and label~="FXONumber" and label~="WEPKeyInAtomic" and (parseArgs(xarg)) ~= nil then
				pathStart = pathStart .. "." .. parseArgs(xarg)
			end
			table.insert(top,pathStart)
		else	-- end tag	
									
			local toclose = table.remove(top)
			local text = string.sub(s, i, ni-1)
			text=string.gsub(text, "^%s*", "")

			if text ~= "" then	
				local pathStr = getPathFromTop(top)
                if label=="FXONumber" then
                    fxoTeleNumber = text
                end
                if label=="WEPKeyInAtomic" then
                    wepGuestKey = text
                end
				if pathStr ~= "" and label~="FXONumber" and label~="WEPKeyInAtomic" then
                    if label=="KeyPassphrase" then
                        --add special sign such as "& < >" solution
                        text = string.gsub(text, "&amp;", "&")
                        text = string.gsub(text, "&lt;", "<")
                        text = string.gsub(text, "&gt;", ">")
                        text = string.gsub(text, "&quot;", "\"")
                    end
					setEachParamToObjStack(pathStr, label, text)
				end
			end
					
		end
		i = j+1
	end
	
	--Sort for the stack, if the sequence index is less then 10 it would add "0" to compare with the num which more than 10.
	table.sort(stack, function(x, y) 
		local xx = string.gsub(x[1], "%d+", function(num) if tonumber(num)<10 then num = "0"..num end return num end)
		local yy = string.gsub(y[1], "%d+", function(num) if tonumber(num)<10 then num = "0"..num end return num end)
		return string.lower(xx) < string.lower(yy) end)
end

-- read the whole contents of the xml file from "/tmp/AGConfig.xml"
function readXml()
	local open=io.open
	local src

	local xmlPath="/dl/AGConfig_TI.xml"

	local fh = open (xmlPath)
	if fh~=nil then
		src = fh:read("*a")
		fh:close()
	end
	return src
end

--Set the dhcp pool disable at the begin of updating and enable the dhcp pool after updating.
function setDHCPServer(state)
    local poolPath = "Device.DHCPv4.Server.Pool.1"
    local natPath = "Device.NAT.InterfaceSetting.2"
    local ipAddrPath = "Device.IP.Interface.3.IPv4Address.1"
    local waitInfoStack = getRestoreWaitStack()
    local IPAddrRes = waitInfoStack["gatewayIpAddress"]
    local subMaskRes = waitInfoStack["subnetMask"]

    local modify = {}
    table.insert(modify, {path=ipAddrPath, param={IPAddress=IPAddrRes, SubnetMask=subMaskRes}, datamodel="second"})
    setMBUS_IGD(modify)

    local dhcpMinAddress = waitInfoStack["dhcpIpInit"]
    local dhcpMaxAddress = waitInfoStack["dhcpIpFinal"]
    local natMinAddress = waitInfoStack["natIpInit"]
    local natMaxAddress = waitInfoStack["natIpFinal"]

    local modify = {}
    table.insert(modify, {path=poolPath, param= {Enable=state, MinAddress=dhcpMinAddress, MaxAddress=dhcpMaxAddress}, datamodel="second"})
    setMBUS_IGD(modify)

    local modify = {}
    table.insert(modify, {
                  path=natPath,
                  param={X_TELECOMITALIA_IT_NATStartIPAddress=natMinAddress,
                         X_TELECOMITALIA_IT_NATEndIPAddress=natMaxAddress},
                  datamodel="second"})
    setMBUS_IGD(modify)
end

--Set the dhcp pool disable at the begin of updating and enable the dhcp pool after updating.
function setDHCPServerState(state)
    local poolPath = "Device.DHCPv4.Server.Pool.1"
    local modify = {}
    table.insert(modify, {path=poolPath, param= {Enable=state}, datamodel="second"})
    setMBUS_IGD(modify)
end

--Set the media server state.
function setMediaServerState()
    local waitInfoStack = getRestoreWaitStack()
    local mediaState = waitInfoStack["upnpMedia"]
    local modify = {}
    table.insert(modify, {path="ContentSharing.UPnPAV", param={Enable=mediaState}})
    table.insert(modify, {path="UPnP", param={Enable=mediaState}})
    if mediaState == "true" then
        table.insert(modify, {path="System", param={UPnP="true"}})
    end
    setMBUS(modify)
end

--Set the param of wifiAllowMac.
function setWifiAllowMac()
    local mac2Path = "Device.WiFi.SSID.1"
    local mac5Path = "Device.WiFi.SSID.2"
    local macGuest2Path = "Device.WiFi.SSID.3"
    local macGuest5Path = "Device.WiFi.SSID.4"
    local waitInfoStack = getRestoreWaitStack()
    local allow2Mac = waitInfoStack["wifiAllowMac"]
    local allow5Mac = waitInfoStack["wifi5AllowMac"]
    local allowGuest2Mac = waitInfoStack["wifiGuestAllowMac"]
    local allowGuest5Mac = waitInfoStack["wifiGuest5AllowMac"]

    --insert each mac address for restored.
    local modify = {}
    if allow2Mac~=nil then
        table.insert(modify, {path=mac2Path, param={X_TELECOMITALIA_IT_AllowedMACAddresses=allow2Mac}, datamodel="second"})
    end
    setMBUS_IGD(modify)

    modify = {}
    if allow5Mac~=nil then
        table.insert(modify, {path=mac5Path, param={X_TELECOMITALIA_IT_AllowedMACAddresses=allow5Mac}, datamodel="second"})
    end
    setMBUS_IGD(modify)

    modify = {}
    if allowGuest2Mac~=nil then
        table.insert(modify, {path=macGuest2Path, param={X_TELECOMITALIA_IT_AllowedMACAddresses=allowGuest2Mac}, datamodel="second"})
    end
    setMBUS_IGD(modify)

    modify = {}
    if allowGuest5Mac~=nil then
        table.insert(modify, {path=macGuest5Path, param={X_TELECOMITALIA_IT_AllowedMACAddresses=allowGuest5Mac}, datamodel="second"})
    end
    setMBUS_IGD(modify)
end

--Set the operation flag of ip changing.
function ipChangeSet(state)
    local path = "TI_STORE.TiUserIntf"
    local modify = {}
    table.insert(modify, {path=path, param= {GUI_SetIP=state}})
    setMBUS(modify)
end

--restore xml 
function restoreXml(isLanChanged, natIpInit, natIpFinal)
	isLanConfigChanged = isLanChanged
	natIpInitDefault = natIpInit
	natIpFinalDefault = natIpFinal
	local xmlContent = readXml()
	local clearXmlBuff = string.gsub(xmlContent, "[\n\t]", "")
	parseXml(clearXmlBuff)
	updateParams()
end

--To check whether it is multi object, if yes then return the name.
function getMultiObjName(path)
	local pathDetail = string.gsub(path, "%.%d+", "")	
	local i, f, objName = string.find (pathDetail, "%.([^.]+)$")
	return objName
end

--Filter the data which couldn't be changed.
function getRestoreWaitStack()
	local restoreWaitStack = {}
	--multi instance 
	restoreWaitStack["PortMapping"] = {}
	restoreWaitStack["StaticAddress"] = {}
	restoreWaitStack["Host"] = {}
	restoreWaitStack["X_TELECOMITALIA_IT_DynamicDNS"] = {}
	restoreWaitStack["X_TELECOMITALIA_IT_UAMap"] = {}
	restoreWaitStack["X_TELECOMITALIA_IT_VoicePortMap"] = {}
    
    for i,obj_T in pairs(stack) do
        local pathStr = obj_T[1]
        local params_T = obj_T[2]

        for j=1,#restoreWait_T do
          local pathIdxToPatten = string.gsub(restoreWait_T[j][1], "%.{i}", "%%.(%%d+)")

          if pathIdxToPatten ~= tostring(restoreWait_T[j][1]) then
            --handle to multi object                
            local findRes,_,idx = string.find(pathStr, pathIdxToPatten.."$")
            local paramNameFromStack = params_T[1]
            local paramNameFromRestore = restoreWait_T[j][2]
            if nil ~= findRes and paramNameFromStack == paramNameFromRestore then
              local key = restoreWait_T[j][3]
              local multiObjName = getMultiObjName(pathStr)

              if table.maxn(restoreWaitStack[multiObjName]) < tonumber(idx) then
                local temp_T = {}
                temp_T[key] = params_T[2]
                table.insert(restoreWaitStack[multiObjName], temp_T)
              else
                restoreWaitStack[multiObjName][tonumber(idx)][key] = params_T[2]
              end
              break
            end
          else --handle to single object
            local path = restoreWait_T[j][1]
            local param = restoreWait_T[j][2]
            local key = restoreWait_T[j][3]
            if pathStr == path and params_T[1] == param then
                restoreWaitStack[key] = params_T[2]
                break
            end
          end  --if multi end
          restoreWaitStack["wepkey"] = wepGuestKey
          restoreWaitStack["fxonumber"] = fxoTeleNumber
        end
    end
	return restoreWaitStack	
end

--Get the restore wait infomation
function getWaitInfo()
	
	local xmlContent = readXml()
	parseXml(xmlContent)
	local waitInfoStack = getRestoreWaitStack()
	return waitInfoStack
end	


function getIPInfo()
	local result={}
	local dhcp, error = mbus.getParameters{path="DHCP.Server", param = {"Enable"}}
	result.dhcpState = dhcp["DHCP.Server"][1].param["Enable"]

	local dhcp, error = mbus.getParameters{path="DHCP.Server.Pool", param = {"MinAddress","MaxAddress","LeaseTime","State"}, filter="(== Name LocalNetwork_default)"}
	if dhcp["DHCP.Server.Pool"][1]~=nil then
		result.enable=dhcp["DHCP.Server.Pool"][1].param["State"]
		result.poolpath=dhcp["DHCP.Server.Pool"][1].path
		result.beginip=dhcp["DHCP.Server.Pool"][1].param["MinAddress"]
		result.endip=dhcp["DHCP.Server.Pool"][1].param["MaxAddress"]
		result.leasetime=dhcp["DHCP.Server.Pool"][1].param["LeaseTime"]
		if result.leasetime=="-1" then
			result.days=0
			result.hours=0
		else
			result.days=result.leasetime/(60*60*24)
			result.hours=result.leasetime/(60*60)-result.days*24
		end
	end

	local hub, error = mbus.getParameters{ path="IP.Intf",param = "Name", filter="(== Name LocalNetwork)" }
	local ipintf=hub["IP.Intf"][1].path
	local hub, error = mbus.getParameters{path=ipintf..".Addr",param ={"IPAddress","SubnetMask"}, filter="(== Preferred 1)"}
	result.ippath=hub[ipintf..".Addr"][1].path
	result.ipaddress=hub[ipintf..".Addr"][1].param["IPAddress"]
	result.ipmask=hub[ipintf..".Addr"][1].param["SubnetMask"]

	--Get the public ip and submask
	local pubIpIntf, error = mbus.getParameters{path=ipintf..".Addr",param ={"IPAddress","SubnetMask"}, filter="(== Primary 0)"}
	if pubIpIntf[ipintf..".Addr"][1]~=nil then
		result.pubIp = pubIpIntf[ipintf..".Addr"][1].param["IPAddress"]
		result.pubSubmask = pubIpIntf[ipintf..".Addr"][1].param["SubnetMask"]
	end

	local reply, error = mbus.getParameters{ path = ipintf..".Stats", param = {"RxBCPackets", "RxUCPackets", "RxMCPackets", "TxBCPackets", "TxUCPackets", "TxMCPackets"} }	
	result.ethPacketsReceived = reply[ipintf..".Stats"][1].param["RxBCPackets"] + reply[ipintf..".Stats"][1].param["RxUCPackets"] + reply[ipintf..".Stats"][1].param["RxMCPackets"]
	result.ethPacketsSent = reply[ipintf..".Stats"][1].param["TxBCPackets"] + reply[ipintf..".Stats"][1].param["TxUCPackets"] + reply[ipintf..".Stats"][1].param["TxMCPackets"]
	return result
end

bit={data32={}}

for i=1,32 do
    bit.data32[i]=2^(32-i)
end

function    bit:b2d(arg)

    local   nr=0

    for i=1,32 do

        if arg[i] ==1 then

        nr=nr+2^(32-i)

        end

    end

    return  nr

end   --bit:b2d


function bit:d2b(arg)

    local   tr={}

    for i=1,32 do

        if arg >= self.data32[i] then

        tr[i]=1

        arg=arg-self.data32[i]

        else

        tr[i]=0

        end

    end

    return   tr

end   --bit:d2b


function    bit:_and(a,b)

    local   op1=self:d2b(a)

    local   op2=self:d2b(b)

    local   r={}

    

    for i=1,32 do

        if op1[i]==1 and op2[i]==1  then

            r[i]=1

        else

            r[i]=0

        end

    end

    return  self:b2d(r)

    

end --bit:_and

function    bit:_or(a,b)

    local   op1=self:d2b(a)

    local   op2=self:d2b(b)

    local   r={}

    

    for i=1,32 do

        if  op1[i]==1 or   op2[i]==1   then

            r[i]=1

        else

            r[i]=0

        end

    end

    return  self:b2d(r)

end --bit:_or

function    bit:_not(a)

    local   op1=self:d2b(a)

    local   r={}

    for i=1,32 do

        if  op1[i]==1   then

            r[i]=0

        else

            r[i]=1

        end

    end

    return  self:b2d(r)

end --bit:_not



-- convert ip address to binary number
function ip2long(ip)
    local _,_,a,b,c,d =string.find(tostring(ip),"(%d+).(%d+).(%d+).(%d+)")
    return tonumber(a)*16777216+tonumber(b)*65536+tonumber(c)*256+tonumber(d)
end

-- convert binary number of ip address to xxx.xxx.xxx.xxx fromat
function long2ip(ipnumber)
    local temp1, temp2, seg1, seg2, seg3, seg4
    temp1= ipnumber%(256*256*256)
    seg1= (ipnumber-temp1)/(256*256*256)
    temp2= temp1%(256*256)
    seg2=(temp1-temp2)/(256*256)
    temp1= temp2%256
    seg3= (temp2-temp1)/256
    seg4= temp1
    return seg1.."."..seg2.."."..seg3.."."..seg4
end

-- return true when ip is in start and end
function inRange(ip, start, endip)
   if ip2long(ip)>=ip2long(start) and ip2long(ip)<=ip2long(endip) then
      return true 
   else
      return false
   end
end

--return the nat range from the ip and net mask
function natRange(ip, netmask)
	
	local ipLong=ip2long(ip)
	local maskLong=ip2long(netmask)

	local startip= bit:_and(ipLong,maskLong) + 1
	local endip = bit:_or(ipLong , bit:_not(maskLong)) - 1
	if ipLong == startip then startip=startip+1 end
	if ipLong == endip then endip=endip-1 end

	local beginip=long2ip(startip)
	local lastip=long2ip(endip)

	return beginip, lastip
end






-----------------------------------------
--test code for setMbus and setMbus_IGD--
-----------------------------------------
--local modify={}
--table.insert(modify, {path="PPP.Intf.1", param={NATExcludedInternalIPAddress="192.168.100.58"}})
--setMBUS(modify)

--local modify2={}
--table.insert(modify2, {path="InternetGatewayDevice.ManagementServer", param={ManageableDeviceNotificationLimit="22"}})
--setMBUS_IGD(modify2)


-----------------------------------------
--main part------------------------------
-----------------------------------------
--tprint("@@@script: start to load kry fiel by LUA script");

local waitInfo_T = getWaitInfo()
function isIpChanged()
	local ipInfo = getIPInfo()
	local ipAddr = ipInfo.ipaddress
	local ipMask = ipInfo.ipmask
	local dhcpIpBegin = ipInfo.beginip
	local dhcpIpEnd = ipInfo.endip
	if ipAddr ~= tostring(waitInfo_T["gatewayIpAddress"]) or ipMask ~= tostring(waitInfo_T["subnetMask"]) or dhcpIpBegin ~= tostring(waitInfo_T["dhcpIpInit"]) or dhcpIpEnd ~= tostring(waitInfo_T["dhcpIpFinal"]) then
		return true
	end
	return false
end

isLanConfigChanged = isIpChanged() 
--tprint("@@@ isLanCongigChanged value is :")
--tprint(isLanConfigChanged)

local natIpInitDefault, natIpFinalDefault = natRange(waitInfo_T["gatewayIpAddress"], waitInfo_T["subnetMask"])
--tprint("@@@ natIpInitDefault value is :")
--tprint(natIpInitDefault)
--tprint("@@@ natIpFinalDefault  value is :")
--tprint(natIpFinalDefault)

local xmlContent = readXml()
parseXml(xmlContent)
updateParams()
--phyChangeSetting()

-----------------------------------------
--test code for setMbus and setMbus_IGD--
-----------------------------------------
--local modify={}
--table.insert(modify, {path="PPP.Intf", param={Enable="false"}})
--setMBUS(modify)
--sleep(100000) 
--modify={}
--table.insert(modify, {path="PPP.Intf", param={Enable="true"}})
--setMBUS(modify)

--tprint("@@@script: End of  load kry fiel by LUA script");

