<%
cgilua.lp.include("lp/mbus_util.lp")
cgilua.lp.include("lp/ppp.lp")
cgilua.lp.include("lp/voip.lp")
cgilua.lp.include("lp/xml.lp")
local stack={}
local rawStack={}
local fxoTeleNumber = ""
local wepGuestKey = ""


local tprint = require("tableprint")

--from dynDnsConf.lp, get the url value.
local function get_domain_name_from_url(url)
    local first = ""
    local second = "" 

    for word in string.gmatch( url, "([a-z|A-Z|0-9|%-]-)%." ) do 
        first = word
        break
    end

    for word in string.gmatch( url, "%.([a-z|A-Z|0-9|%-]*)" ) do
        second = second .. "." .. word
    end

    second = first .. second
    return second
end

--Set the dhcp pool state as the session variable, 1 means true which as a default value.
local dhcpServerState = "1"
--This session variable judges whether the ip, netmask, dhcp ranged was changed.
local isLanConfigChanged = "false"
local natIpInitDefault, natIpFinalDefault

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
    end
    return username
end

--Get the username which was made up with management ppp and data ppp.
function getUsernameWithPPP(usernameParam)
	local username = getUsernameFromPPPManagement()
	if username~=nil then
        local realnamePos = string.find(usernameParam, "@")
		if realnamePos ~= nil then
		    username = username .. tostring(string.sub(usernameParam, realnamePos))
		end
    end
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
function getExtendName(pathStr)
	local startIndex, endIndex, extendName = string.find(pathStr, "%.([^.]+)$")
	return extendName, startIndex
end

--Start to update the data from AGconfig.xml to Device2
function execRestore()
	local isNatRangeDefault=false
	local usernameParam 
	local pathDataPPP = getPathWithDataPPP()
	local dhcpServer_T = {}
	local channelAuto_T = {}

	for i,obj_T in pairs(rawStack) do
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
        local wepkeyPath = "WLAN.Intf.wl_ssid1_local0.Security.WEP"
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
end

--Add the object to the Device2
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

--Create the object in Device2
function objectCreate(set)
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
end

--Delete the object in Device2
function deleteObject(pathStr)
	local reply, error = mbus.modify(
	function()
		local reply1, error1 = mbus.deleteObjects{path = pathStr, datamodel="second"}
	end, {datamodel="second"})
end

--Delete the PortMapping and StaticAddress by the path
function deleteObjectByPath()
	local pathObj_T = {{path="Device.DHCPv4.Server.Pool.1.StaticAddress"}, {path="Device.NAT.PortMapping"}, {path="Device.NAT.X_TELECOMITALIA_IT_DynamicDNS"}}

	for i,set in pairs(pathObj_T) do
		deleteObject(set["path"])
	end	
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

--Filter the data for configured data, which could not be changed if it not in the restore list.
function filterDataConfigured()
	local restoreList = {}
	local path_T = {}
	local portMappingPath = "Device.NAT.PortMapping.{i}"
	local dhcpPath = "Device.DHCPv4.Server.Pool.{i}.StaticAddress.{i}"
	local dynDnsPath = "Device.NAT.X_TELECOMITALIA_IT_DynamicDNS.{i}"
    
	for i,obj_T in ipairs(rawStack) do
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
	rawStack = {}
	rawStack = restoreList 
	return portMappingAndDhcpAndDynDNSList
end

--It should be filtered before restore the already configured data.
function restoreAgConfiged()
	local list = filterDataConfigured()
	execRestore()
	return list
end

function restoreAgConfigedFilteredData(list)
	--If it is port mapping and dhcp static address, it should be deleted first, and then add the new object.
	if list~=nil then 
		--Delete the StaticAddress and PortMapping if it existed in the IGD.
		deleteObjectByPath()

		for i,set in pairs(list) do
		        local pathStr = set["path"]
		        local param_T = set["param"]
			objectCreate(set)
		end
	end	
end

--update the data of the AGconfig.xml to IGD
function updateParams()	
	--disable the dhcp pool before updating
	setDHCPServer("0")

	--set the operation flag of ip changing before updating.
	ipChangeSet("1")

    	local list = restoreAgConfiged()
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
	table.insert(rawStack,{pathStr, paramStack})	
end

--Parse the xargs "id=n", and return the multiobj's index
local function parseArgs(s)
	local arg = {}
	string.gsub(s, "(%w+)=([\"'])(.-)%2", function (w, _, a)
		arg[w] = a
	end)
  	return arg["id"]
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
        --Fix for 121582 Unable to do restore via GUI
	--os.rename("/tmp/AGConfig.cfg", "/tmp/AGConfig.xml")
	--os.rename("/tmp/AGConfig.kry", "/tmp/AGConfig.xml")


	local xmlPath="/tmp/AGConfig.xml"

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
%>
