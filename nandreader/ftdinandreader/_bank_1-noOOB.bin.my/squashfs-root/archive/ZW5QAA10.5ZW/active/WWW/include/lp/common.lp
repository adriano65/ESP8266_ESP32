<%
cgilua.lp.include("lp/bit.lp")
cgilua.lp.include("lp/mbus_util.lp")

function getTIInfo_Device()
	local result = {}
	local reply, error = mbus.getParameters{path = "Device.UserInterface.X_TELECOMITALIA_IT_WebPage", datamodel = "second"}
	result.lanOption = reply["Device.UserInterface.X_TELECOMITALIA_IT_WebPage"][1].param["LANOption"]
	result.profile = reply["Device.UserInterface.X_TELECOMITALIA_IT_WebPage"][1].param["Profile"]
	return result
end

-- get TI User intf info for welcome page
function getTIInfoHome()
	local result = {}
	local reply, error = mbus.getParameters{path = "TI_STORE.TiUserIntf", param={"Profile","LANOption","Static","IPTV_Active"}}
							 
	result.static = reply["TI_STORE.TiUserIntf"][1].param["Static"]      
	result.iptvActive = reply["TI_STORE.TiUserIntf"][1].param["IPTV_Active"]
	result.lanOption = reply["TI_STORE.TiUserIntf"][1].param["LANOption"]
	result.profile = reply["TI_STORE.TiUserIntf"][1].param["Profile"]
 
	return result
end

-- get TI Userinterface Web Page info
function getTIInfo()
	local result = {}
	
	local reply, error = mbus.getParameters{ {path = "TI_STORE.TiUserIntf", param={"ConnectionMode","Profile","LANOption","PublicPrimaryDNS","PublicSecondaryDNS","Static","IPTV_Active","AdminPassword"}},
							   {path = "TI_STORE.TIDhcp", param={"DHCPServerConfigurable"}},
							   {path = "TI_STORE.TILANDev", param={"STBLANInterface"}}}

	result.connectMode = reply["TI_STORE.TiUserIntf"][1].param["ConnectionMode"]
	result.profile = reply["TI_STORE.TiUserIntf"][1].param["Profile"]
	result.lanOption = reply["TI_STORE.TiUserIntf"][1].param["LANOption"]
	result.pubPrimDNS = reply["TI_STORE.TiUserIntf"][1].param["PublicPrimaryDNS"] 
	result.static = reply["TI_STORE.TiUserIntf"][1].param["Static"]      
	result.iptvActive = reply["TI_STORE.TiUserIntf"][1].param["IPTV_Active"]
	result.stbConnected = "false"
	result.stbConnected_num = 0
    result.pubSecDNS = reply["TI_STORE.TiUserIntf"][1].param["PublicSecondaryDNS"]  
	result.dhcpServerConfigurable = reply["TI_STORE.TIDhcp"][1].param["DHCPServerConfigurable"]
	result.adminPassword = reply["TI_STORE.TiUserIntf"][1].param["AdminPassword"]
 
 result.stbIntf = {}
 reply, error = mbus.getParameters{ path = "Device.Hosts.Host", param = {"Alias", "Layer1Interface"}, datamodel = "second" }
 for i, v in pairs(reply["Device.Hosts.Host"]) do
  if string.sub(tostring(v.param["Alias"]), 1, 20) == "Telecom IPTV Decoder" then
    result.stbConnected = "true"
    result.stbConnected_num = result.stbConnected_num + 1
    result.stbIntf[result.stbConnected_num] = string.sub(tostring(v.param["Layer1Interface"]), -1)
  end
 end
 
	return result
end

--get Primary or Secondary DNS default from DNS.Server.Route.1/2
function getDefaultDNS(num)
	local dnsPath = "Device.DNS.Client.Server." .. num 

    	local reply, error = mbus.getParameters{ path = dnsPath, param={"DNSServer"}, datamodel = "second"}
    	return reply[dnsPath][1].param["DNSServer"]

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

	--Get the private ip and submask
--[[	local lanIpPath = "Device.IP.Interface.3.IPv4Address.1"
	local lanip, error = mbus.getParameters{path=lanIpPath, datamodel = "second"}
	if lanip[lanIpPath][1] ~= nil and lanip[lanIpPath][1].param["IPAddress"] ~= nil then
		result.ipaddress=lanip[lanIpPath][1].param["IPAddress"]
		result.ipmask=lanip[lanIpPath][1].param["SubnetMask"]
	end
	
	--Get the public ip and submask
	local publanIpPath = "Device.IP.Interface.3.IPv4Address.2"
	local publanIpPath = "Device.IP.Interface.3.IPv4Address.2"
	local publanip, puberror = mbus.getParameters{path=publanIpPath, datamodel = "second"} ]]--
	local hub, error = mbus.getParameters{ path="IP.Intf",param = "Name", filter="(== Name LocalNetwork)" }
	local ipintf=hub["IP.Intf"][1].path
	local hub, error = mbus.getParameters{path=ipintf..".Addr",param ={"IPAddress","SubnetMask"}, filter="(== Preferred 1)"}
	if hub[ipintf..".Addr"][1]==nil then
		-- If there is no preferred IP address, get the first IP address
		hub, error = mbus.getParameters{path=ipintf..".Addr",param ={"IPAddress","SubnetMask"}}
	end
	result.ippath=hub[ipintf..".Addr"][1].path
	result.ipaddress=hub[ipintf..".Addr"][1].param["IPAddress"]
	result.ipmask=hub[ipintf..".Addr"][1].param["SubnetMask"]

	--Get the public ip and submask
	local pubIpIntf, error = mbus.getParameters{path=ipintf..".Addr",param ={"IPAddress","SubnetMask"}, filter="(== Primary 0)"}
	if pubIpIntf[ipintf..".Addr"][1]~=nil and pubIpIntf[ipintf..".Addr"][1].param["IPAddress"]~=result.ipaddress then
		result.pubIp = pubIpIntf[ipintf..".Addr"][1].param["IPAddress"]
		result.pubSubmask = pubIpIntf[ipintf..".Addr"][1].param["SubnetMask"]
	end

	local reply, error = mbus.getParameters{ path = ipintf..".Stats", param = {"RxBCPackets", "RxUCPackets", "RxMCPackets", "TxBCPackets", "TxUCPackets", "TxMCPackets"} }	
	result.ethPacketsReceived = reply[ipintf..".Stats"][1].param["RxBCPackets"] + reply[ipintf..".Stats"][1].param["RxUCPackets"] + reply[ipintf..".Stats"][1].param["RxMCPackets"]
	result.ethPacketsSent = reply[ipintf..".Stats"][1].param["TxBCPackets"] + reply[ipintf..".Stats"][1].param["TxUCPackets"] + reply[ipintf..".Stats"][1].param["TxMCPackets"]
	return result
end

--[[get host ip by mask
function getHostIpByMask(ip, mask)
	local lastMaskIP
	local i=1
	local t={}
	for str in string.gmatch( ip,"(%d+)") do
		t[i] = str
		i = i + 1
	end

	i=1
	for str in string.gmatch( mask,"(%d+)") do
		if str ~= "255" then
			lastMaskIP = bit:_and(tonumber(str),tonumber(t[i]))
		end
	end
	
	return lastMaskIP
end
]]

--get final ip nums
function getFinalIpNum(mask)
	local lastMask = 0
	local j=0
	local pt={}

	for str in string.gmatch( mask,"(%d+)") do
		if str ~= "255" then
			lastMask = str
		end
	end
	return 255-tonumber(lastMask)
end

--[[get IP result
function getIpResult(ipDef, lastIpPart)
	local i=1
	local result=""

	for str in string.gmatch( ipDef,"(%d+)") do
		if i<4 then
			if result ~= "" then
				result=result .. "." .. str
			else
				result=result .. str
			end
		else
			result=result .. "." .. lastIpPart
		end
		i=i+1
	end
	
	return result
end
]]

--get public lan status
function getPubLAN()
	local result={}
	local ipPath = "IP.Intf"
	local ipIntf, error = mbus.getParameters{path=ipPath, filter = "(== Name LocalNetwork)"}

	local pubLanPath = ipIntf[ipPath][1].path .. ".Addr"
	local pubLan, error = mbus.getParameters{path=pubLanPath, param = {"Enable", "IPAddress","SubnetMask"}, filter = "(and (== Primary 0) (== Enable 1))"}
	result.isPubLan = false
	if pubLan[pubLanPath][1]~=nil then
		result.isPubLan = true
		result.pubLanEnable = pubLan[pubLanPath][1].param["Enable"]
		result.pubIpDef = pubLan[pubLanPath][1].param["IPAddress"]
		result.pubIpMask = pubLan[pubLanPath][1].param["SubnetMask"]
        --local hostIP = getHostIpByMask(result.pubIpDef,result.pubIpMask)
        --result.beginip = getIpResult(result.pubIpDef,hostIP+1)
        --result.endip = getIpResult(result.pubIpDef, hostIP + getFinalIpNum(result.pubIpMask)-1)

        local ip=ip2long(result.pubIpDef)
        local mask=ip2long(result.pubIpMask)

        local startip= bit:_and(ip,mask) + 1
        local endip = bit:_or(ip , bit:_not(mask)) - 1
        if ip == startip then startip=startip+1 end
        if ip == endip then endip=endip-1 end

        result.beginip=long2ip(startip)
        result.endip=long2ip(endip)

	end
	return result
end

--get CWMP traffic 
function getCWMPState()
	local state = ""
	local cwmp, error = mbus.getParameters{path="CWMP", param = {"SessionStatus"}}
	if cwmp["CWMP"][1] ~= nil then
		state = cwmp["CWMP"][1].param["SessionStatus"]
	end
	return state
end

--To get the active/inactive style of the font
function isActiveColor(state)
	local color = "tdGreen"
	if state ~= "Active" then
		color = "tdRed"
	end

	return color
end

--get the hostname of the lan interface
function getHostName(state,interface)
   local hostName = ""
   local mac = ""
   if state ~= nil and state == "Active" then
      
      local devicePath="Hosts.Host"
      local Data, error = mbus.getParameters{path = devicePath, param = {"HostName", "UserFriendlyName", "MACAddress", "Active"}, filter="(and (== Interface "..interface..") (!= Active 0))"}

      if #Data[devicePath] > 1 then
	 return -1
      elseif #Data[devicePath] == 1 and Data[devicePath][1] ~= nil then
	 hostName = Data[devicePath][1].param["HostName"]
	 mac      = Data[devicePath][1].param["MACAddress"]
      end
      
      if interface == "ETH.Phys.6" and mac ~= "" then
	 local pwlan = "WLAN.Intf.wlif1.Station"
	 local data, error = mbus.getParameters { path = pwlan, param = {"IPAddress"}, filter = "(== MACAddress "..mac..")",flags="KEYPATH"}
	 if data[pwlan][1] == nil then 
	    hostName = "" 
	 end
      end
   end
   return hostName
end

--get the NAT status
function getNatStatus(ipIntf)
	local natPath = "NAT.Intf"

	local status = "disabled"	
	local nat, error = mbus.getParameters{path = natPath, param = {"Status"}, filter="(== IPIntf "..ipIntf..")"}
	local natIntfPath = nat[natPath][1].path
	if nat[natPath][1] ~= nil then
		status = nat[natPath][1].param["Status"]
	end
	return status,natIntfPath
end

function get_STBIPAddress() 
  local STB_ArraryTable={}
  local reply, error = mbus.getParameters{path = "DHCP.Server.Lease", param = {"IPAddress"}, flags="KEYPATH" }
  for i, v in pairs(reply["DHCP.Server.Lease"]) do
    local reply2, error2 = mbus.getParameters{path = v.path..".RxOptions.60.Field", param = {"Value"}, flags="KEYPATH" }
    for k, w in pairs(reply2[v.path..".RxOptions.60.Field"]) do
	  if string.find(tostring(w.param["Value"]), "stb") ~= nil then
		table.insert(STB_ArraryTable,v.param["IPAddress"])
      end
    end
  end
  return STB_ArraryTable
end


function get_IPTVService() 
  local IPTV_Service
  local reply, error = mbus.getParameters{path = "Device.Bridging", param = "X_TELECOMITALIA_IT_IPTVService", datamodel = "second" }
  return reply["Device.Bridging"][1].param["X_TELECOMITALIA_IT_IPTVService"] 
end


function get_IPv6Service() 
  local reply, error = mbus.getParameters{path = "Device.UserInterface.X_TELECOMITALIA_IT_WebPage", param = "LANOption", datamodel = "second" }
  return (reply["Device.UserInterface.X_TELECOMITALIA_IT_WebPage"][1].param["LANOption"])
end

function get_deviceNatStatus()
local result={}
	local reply,error = mbus.getParameters{path = "Device.NAT.InterfaceSetting.2", param = {"Enable", "X_TELECOMITALIA_IT_NATStartIPAddress", "X_TELECOMITALIA_IT_NATEndIPAddress", "X_TELECOMITALIA_IT_NATExcludedInternalIPAddresses"}, datamodel = "second" }
	 result.NatPath = reply["Device.NAT.InterfaceSetting.2"][1]
	 result.enable = reply["Device.NAT.InterfaceSetting.2"][1].param["Enable"]  
	 result.NATStartIPAddress = reply["Device.NAT.InterfaceSetting.2"][1].param["X_TELECOMITALIA_IT_NATStartIPAddress"] 
	 result.NATEndIPAddress = reply["Device.NAT.InterfaceSetting.2"][1].param["X_TELECOMITALIA_IT_NATEndIPAddress"]  
	 result.NATExcludedInternalIPAddresses = reply["Device.NAT.InterfaceSetting.2"][1].param["X_TELECOMITALIA_IT_NATExcludedInternalIPAddresses"]
  return result	 
end
------------------------
--get the icon type if already stored in env
------------------------

function getIconForDevice(macAddress) 

local tprint = require("tableprint")
local envName=macAddress.."_icon"

local picName="ico_host_generico.png"
local iconType="generic"
local reply, error = mbus.getParameters{ path = "ENV", param = "Value", filter = "(== Name "..envName..")" }


if reply["ENV"][1]~=nil and reply["ENV"][1].param~=nil then
				iconType = reply["ENV"][1].param["Value"]
end
if( iconType == nil or iconType =="" ) then
	picName ="ico_host_generico.png"
elseif( iconType == "tablet") then
	picName="ico_tablet.png"
elseif( iconType == "smartphone") then
	picName="ico_smartphone.png"
elseif( iconType == "pc") then
	picName="ico_pc.png"
elseif( iconType == "ap") then
	picName="ico_exx.png"
elseif( iconType == "game") then
	picName="dev___xl.png"
elseif( iconType == "stb") then
	picName="ico_stb.png"
elseif( iconType == "tv") then
	picName="TV.png"
elseif( iconType == "generic") then
	picName="ico_host_generico.png"
elseif( iconType == "notebook") then
	picName="ico_notebook.png"
elseif( iconType == "camera") then
	picName="ico_videocamera.png"
elseif( iconType == "console") then
	picName="ico_game.png"
elseif( iconType == "repeater") then
	picName="ico_repeater.png"
elseif( iconType == "mediaplayer") then
	picName="ico_mediaplayer.png"
end

return iconType,picName
end

--Get all DNS from Device path
function getAllDNSCount()
 	local dyn = {}
 	local sta = {}
	local i , count
	i = 0
	local replyIncoming, error = mbus.getParameters{ path = "DNS.Server.Route", param = {"IPIntf", "Flags", "DNSServer"}, filter = "(== IPIntf ".."IP.Intf.ppp_0"..")", flags="KEYPATH" }
 	for j,k in pairs(replyIncoming["DNS.Server.Route"]) do
	 	i = i +1 
 		if (k.param["Flags"]) ~= "0" then
    			dyn[i] = k.param["DNSServer"]
 		else
    			sta[i] = k.param["DNSServer"]
 		end   
	end
	
	count = 0
	for t in pairs(dyn) do 
	count = count + 1
	end
	
	return count 
end

function getAllDNS(num)
        local dyn = {}
        local sta = {}
        local i 
        i = 0
        local replyIncoming, error = mbus.getParameters{ path = "DNS.Server.Route", param = {"IPIntf", "Flags", "DNSServer"}, filter = "(== IPIntf ".."IP.Intf.ppp_0"..")", flags="KEYPATH" }
        for j,k in pairs(replyIncoming["DNS.Server.Route"]) do
                if (k.param["Flags"]) ~= "0" then
 		i = i +1
                        dyn[i] = k.param["DNSServer"]
                end
        end
        i = 0
        local replyIncoming, error = mbus.getParameters{ path = "DNS.Server.Route", param = {"IPIntf", "Flags", "DNSServer"}, filter = "(== IPIntf ".."IP.Intf.ppp_0"..")", flags="KEYPATH" }
        for j,k in pairs(replyIncoming["DNS.Server.Route"]) do
                if (k.param["Flags"]) == "0" then
			i = i +1
                        sta[i] = k.param["DNSServer"]
                end
        end

	if num == 98 then
		return sta[1]
	elseif num == 99 then
		return sta[2]
	else
		return dyn[num]
	end
		

end

%>

