<%
-- filename:       wlan.lp
-- description:    supply useful api for WLAN mbus data model operation
-- project:        BT2.0 GUI


-- name:           get_WirelessStatus 
-- description:    get WLAN interface status
-- parameter:      nil
-- return value    WLAN.Enable
local tprint = require("tableprint")
function get_WirelessStatus()
  local reply, error = mbus.getParameters{path = "WLAN", param = {"Enable"}}
  return reply["WLAN"][1].param["Enable"]
end

--Get the security mode 
function getSecMode(secPath)
	local sec_data, error = mbus.getParameters{path = secPath, param= "Mode",flags="KEYPATH"}
	return sec_data[secPath][1].param["Mode"]
end

--Get the wep key 
function getWepKey(secWebPath)
	local wep_data, error = mbus.getParameters{path = secWebPath, param= "WEPKey",flags="KEYPATH"}
	return wep_data[secWebPath][1].param["WEPKey"]
end

--Get the wpa info 
function getWpaInfo(secWpaPath)
	local wpa_data, error = mbus.getParameters{path = secWpaPath, param={"KeyPassPhrase", "WPAVersion", "Encryption"},flags="KEYPATH"}
	local wpaversion = wpa_data[secWpaPath][1].param["WPAVersion"]
	local encryption = wpa_data[secWpaPath][1].param["Encryption"]
	local wpa = wpa_data[secWpaPath][1].param["KeyPassPhrase"]
	return wpaversion, encryption, wpa
end

--Get the wlan info for welcome page.
--function getWlanInfoHome()
--	local mpath = "WLAN.Intf" 
--	local result={}  
--	local wlan_data, error = mbus.getParameters{path = mpath, param = {"SSID","Status"}}
--	for i, v in pairs(wlan_data[mpath]) do
--		if i=="1" then
--		        WIntfPath ="WLAN.Intf.wlif1"
--		elseif i=="2" then
  --      		WIntfPath="WLAN.Intf.wl_ssid1_local0"
--		elseif i=="3" then
  --      		WIntfPath="WLAN.Intf.wle_radio1_ssid0"
--		elseif i=="4" then
  --      		WIntfPath="WLAN.Intf.wle_radio1_ssid1"
--		end
--		result[i] = {}
--		result[i].ssid = v.param["SSID"]
--		result[i].status = v.param["Status"]
--		result[i].secmode = getSecMode(v.path ..".Security")
--		result[i].wep = getWepKey(v.path..".Security.WEP")
--		result[i].wpaversion, result[i].encryption, result[i].wpa  = getWpaInfo(v.path..".Security.WPAPSK")		
--	end
--	return result

function getWlanInfoHome()
local WIntfPath
local reply, error
local result = {}

for i = 1, 4 do
        if i==1 then
           WIntfPath ="WLAN.Intf.wlif1"
        elseif i==2 then
           WIntfPath="WLAN.Intf.wl_ssid1_local0"
        elseif i==3 then
           WIntfPath="WLAN.Intf.wle_radio1_ssid0"
        elseif i==4 then
           WIntfPath="WLAN.Intf.wle_radio1_ssid1"
        end


        local reply, error = mbus.getParameters{ path = WIntfPath, param = {"SSID","Status"},flags="KEYPATH"}
        result[i]={}
        result[i].ssid = reply[WIntfPath][1].param["SSID"]
	result[i].status = reply[WIntfPath][1].param["Status"]
	result[i].secmode = getSecMode(WIntfPath..".Security")
	result[i].wep = getWepKey(WIntfPath..".Security.WEP")
        result[i].wpaversion, result[i].encryption, result[i].wpa  = getWpaInfo(WIntfPath..".Security.WPAPSK")

end
return result
end
-- name:           getWlanMain
-- description:    get WLAN.Intf info 
-- parameter:      mpath: WLAN intf MBUS path 
-- return value    a table of all wlan info. 

function getWlanMain(mpath)
  local result={} 
  local mpathSec=mpath..".Security" 
  local acl_path = mpath..".ACL"
  local acs_path = mpath..".ACS"
  local wps_path = mpath..".WPS"
  local wlan_data, error = mbus.getParameters{ {path = mpath, param = {"Name", "Enable", "ChannelMode", "Channel", "SSID","BSSID","InteropMode","Rate","AnySSID","Status", "ChannelWidth"} ,flags="KEYPATH"}, 
                                          {path = mpathSec,param= "Mode",flags="KEYPATH"},
                                          {path = mpath..".Security.WEP", param ="WEPKey",flags="KEYPATH"},
                                          {path = mpath..".Security.WPAPSK", param = {"KeyPassPhrase","PSK","WPAVersion","Encryption"},flags="KEYPATH"},
					  {path = mpath..".ACL",param= "Control", flags="KEYPATH"},
					  {path = mpath..".ACS",param= "BssList", flags="KEYPATH"},
					  {path = mpath..".WPS",param= {"AdminState","OperState"}, flags="KEYPATH"},
					  {path = mpath.."WPS.APPROXY",param= {"CurrentPin","RandomPin"}, flags="KEYPATH"},
					  {path = mpath.."WPS.REGISTRAR",param= {"Pin"}, flags="KEYPATH"} }

  result.name = wlan_data[mpath][1].param["Name"]
  result.enable = wlan_data[mpath][1].param["Enable"]
  result.status= wlan_data[mpath][1].param["Status"]
  result.anyssid = wlan_data[mpath][1].param["AnySSID"]
  result.ssid = wlan_data[mpath][1].param["SSID"]                                    
  result.channel = wlan_data[mpath][1].param["Channel"]
  result.channelmode = wlan_data[mpath][1].param["ChannelMode"]
  result.channelwidth = wlan_data[mpath][1].param["ChannelWidth"]
  result.macaddr = wlan_data[mpath][1].param["BSSID"]
  result.intftype = wlan_data[mpath][1].param["InteropMode"]
  result.speed = wlan_data[mpath][1].param["Rate"]
  
  result.mode=-1
  result.basemode=-1 
  
  result.secmode=wlan_data[mpathSec][1].param["Mode"]
  result.wpaversion=wlan_data[mpath..".Security.WPAPSK"][1].param["WPAVersion"]
  result.encryption = wlan_data[mpath..".Security.WPAPSK"][1].param["Encryption"]

  if result.secmode=="disable" then 
    result.mode=1 
  elseif result.secmode=="WEP" then 
    result.mode=2
    result.basemode=1  
  elseif result.secmode=="WPA-PSK" then 
    result.basemode=0
    if result.wpaversion=="WPA+WPA2" then
      result.mode=3
    elseif result.wpaversion=="WPA" then
      result.mode=4
    elseif result.wpaversion=="WPA2" then
      result.mode=5
    end
  end  

  result.wep  = wlan_data[mpath..".Security.WEP"][1].param["WEPKey"]
  result.wpa  = wlan_data[mpath..".Security.WPAPSK"][1].param["KeyPassPhrase"]
  if result.wep=="guest00000000" then
    result.wep = ""
  end
  if result.wpa=="guest@000000" then
    result.wpa = ""
  end
    
  if (#result.wep==5) or (#result.wep==10) then 
  	result.wepkey_sel = "64"
  	result.wepkey_num = "10"
  elseif (#result.wep==13) or (#result.wep==26) then 
  	result.wepkey_sel = "128"
  	result.wepkey_num = "26"
  end

  --local acl_path = mpath..".ACL"
  --local wlan_acl_data, error = mbus.getParameters{{path = acl_path,param= "Control", flag="KEYPATH"}}
  --result.control=wlan_acl_data[acl_path][1].param["Control"]
  result.control=wlan_data[acl_path][1].param["Control"]

  --local acs_path = mpath..".ACS"
  --local wlan_acs_data, error = mbus.getParameters{{path = acs_path,param= "BssList", flag="KEYPATH"}}
  result.apList_T=wlan_data[acs_path][1].param["BssList"]

  --local wps_path = mpath..".WPS"
  --local wlan_wps_data, error = mbus.getParameters{	{path = wps_path,param= {"AdminState","OperState"}, flag="KEYPATH"},
							--{path = wps_path..".APPROXY",param= {"CurrentPin","RandomPin"}, flag="KEYPATH"},
							--{path = wps_path..".REGISTRAR",param= {"Pin"}, flag="KEYPATH"}} 
  result.wps_path=wlan_data[wps_path][1].path
  result.adminState=wlan_data[wps_path][1].param["AdminState"]  
  result.currentPin=wlan_data[mpath.."WPS.APPROXY"][1].param["CurrentPin"]  
  result.randomPin=wlan_data[mpath.."WPS.APPROXY"][1].param["RandomPin"]
  result.wps_pin_path = wlan_data[mpath.."WPS.APPROXY"][1].path
  result.wps_reg_path = wlan_data[mpath.."WPS.REGISTRAR"][1].path
  
  return result 
end    

-- name:           cChannelPOST
-- description:    create wlan channel part POST table
-- parameter:      mpath: WLAN intf MBUS path 
-- return value    return 1 tables include the MBUS channel set info table 

function cChannelPOST(mpath)

  local channel={}
  -- get original parameter 
  local old_data = getWlanMain(mpath)
   
   if POST["channel_mode"]=="Auto" and old_data.channelmode~="Auto" then
     table.insert(channel,{path=mpath, param= {ChannelMode="Auto"}})
   else 
     if POST["channel_mode"]~="Auto" and old_data.channelmode=="Auto" then
       table.insert(channel,{path=mpath, param= {ChannelMode="Manual"}})
     end
     if POST["channel_mode"]~="Auto" and POST["channel_mode"]~=old_data.channel then
       table.insert(channel,{path=mpath, param= {Channel=POST["channel_mode"]}})
     end
   end
   if POST["ssid"]~=nil and old_data.ssid~=POST["ssid"] then
     table.insert(channel,{path=mpath, param= {SSID=POST["ssid"]}})
   end
   if POST["intf_type"]~=nil and old_data.intftype~=POST["intf_type"] then
     table.insert(channel,{path=mpath, param= {InteropMode=POST["intf_type"]}})
   end
  
  return channel
end


-- name:           cSecPOST
-- description:    create wlan security part POST table
-- parameter:      mpath: WLAN intf MBUS path 
-- return value    return 1 tables include the MBUS security set info table 

function cSecPOST(mpath)
  local sec={}
  -- get original parameter 
  local old_data = getWlanMain(mpath)

   if POST["hidessid"]~=nil and POST["hidessid"]~=old_data.anyssid then
    table.insert(sec,{path=mpath, param={AnySSID=POST["hidessid"]}})
   end
   --if POST["wps"]~=nil and POST["wps"]~=old_data.wps then
   -- table.insert(sec,{path=mpath, param={WpsAdminState=POST["wps"]}})
   --end

   if POST["encryption"]=="no" then
     table.insert(sec,{path=mpath..".Security",param={Mode="disabled"}})
   elseif POST["encryption"]=="WEP" then
     if old_data.secmode~="WEP" then
        table.insert(sec,{path=mpath..".Security", param={Mode="WEP"}})
     end
     if POST['wkey']~="" and old_data.wep~=POST["wkey"] then
        table.insert(sec,{path=mpath..".Security.WEP", param={WEPKey=POST["wkey"]}})
     end
   elseif POST["encryption"]~=nil then
     if old_data.secmode~="WPA-PSK" then
        table.insert(sec,{path=mpath..".Security", param={Mode="WPA-PSK"}})
     end
     if POST["wpakey"]~="" and old_data.wpa~=POST["wpakey"] then
        table.insert(sec,{path=mpath..".Security.WPAPSK", param={PSK=POST["wpakey"]}})
     end
     if POST["encryption"]~="WPA-PSK" then
        if old_data.wpaversion~=POST["encrytion"] then
           table.insert(sec,{path=mpath..".Security.WPAPSK", param={WPAVersion=POST["encryption"]}})
        end
     end
   end   
     
  return sec
end

function getFonInfo()
  local fon, error =  mbus.getParameters{path = "IP.Intf", param="Name", filter="(== Name ipOpenzone)"}
  local enable="0"
  local num=0
 
  if (fon["IP.Intf"][1]~=nil) and (fon["IP.Intf"][1].param["Name"]~=nil) then
     enable="1" 
     local fonList=getList("Hosts.Host","(and (==IPIntf "..fon['IP.Intf'][1].path.." ) (== Active 1))","HostName")
     num=#fonList
  end
  return enable, num
end

-- name:           getTod
-- description:    get energy saving and access control stauts
-- parameter:      nil
-- return value    esaving : "Not enabled" or "Active"
--                 accesscontrol : "Not enabled" or "Enabled"
function getToD()
    local esaving = "Not enabled"
    local accesscontrol = "Not enabled"
    local isenable = "1"

    local reply, error = mbus.getParameters{ path="ToD.Schedule", filter="(== ScheduleType AccessControl)", param={"Enable", "Reference"} }

    for i, v in pairs(reply["ToD.Schedule"]) do
        if (v.param["Enable"]=="1") and (v.param["Reference"]~="") then
            local reply1, error1 = mbus.getParameters{ path=v.path..".Day", param="Active" }
            if (reply1[v.path..".Day"][1]~=nil) then
                local daypath = reply1[v.path..".Day"][1].path
                if (daypath~=nil) then
                    local reply2, error2 = mbus.getParameters{ path=daypath..".TimeRange", param="Active" }
                    if (reply2[daypath..".TimeRange"][1]~=nil) and (reply2[daypath..".TimeRange"][1].path~=nil) then
                        accesscontrol = "Enabled"
                        break
                    end
                end
            end
        end
    end

    local reply, error = mbus.getParameters{ path="ToD.Schedule", filter="(and (== ScheduleType Action) (!= Action ''))", param={"Enable", "Active", "Action"} }

    for i, v in pairs(reply["ToD.Schedule"]) do
        if (v.param["Action"]~=nil) then
            local actionParam = v.param["Action"]..".SetValue.1.Param"
            local reply2, error2 = mbus.getParameters{ path=actionParam, filter="(and (== Object LEDS) (== ParamName EnergySaving))", param={"Value"} }
            if (reply2[actionParam][1]~=nil) and (reply2[actionParam][1].param["Value"]~=nil) then
                local reply3, error3 = mbus.getParameters{ path=actionParam, filter="(and (== Object WLAN) (== On Inactive))", param={"Value"} }
                if (reply3[actionParam][1]~=nil) then
                    isenable = reply3[actionParam][1].param["Value"]
                    if (v.param["Enable"]=="1") and (isenable~=nil) then
                        esaving = "Not currently active"
                        if (v.param["Active"]=="1") then
                            esaving = "Active"
                            break
                        end
                        break
                    end
                end
            end
        end
    end

    return esaving, accesscontrol, isenable
end


-- name:           changeEsavingAction
-- description:    change energy saving action params
-- parameter:      isEnable: wireless interface is enabled or disabled
-- return value    nil

function changeEsavingAction(isEnable)
    local reply, error = mbus.getParameters{ path="ToD.Schedule", filter="(and (== ScheduleType Action) (!= Action ''))", param={"Enable", "Active", "Action"} }

    for i, v in pairs(reply["ToD.Schedule"]) do
        if (v.param["Action"]~=nil) then
            local parampath = v.param["Action"]..".SetValue.1.Param"
            local reply2, error2 = mbus.getParameters{ path=parampath, filter="(and (== Object WLAN) (== On Inactive))", param={"Value"} }
            if (reply2[parampath][1]~=nil) then
                local inactivepath = reply2[parampath][1].path
                local modify = {}
                table.insert(modify, {path=inactivepath, param={Value=isEnable}})
                setMBUS(modify)
                break
            end
        end
    end
end

-- name:           getLinkInfo
-- description:    get the wifi links info from host
-- parameter:      name: wifi's name
-- return value    nil
local tprint = require("tableprint")
function getLinkInfo(name)
	local station=name..".Station"
	local reply, error = mbus.getParameters{ path=station, param="MACAddress", flags = "KEYPATH" }
	local result={}
	local n = 0
	for i, v in pairs(reply[station]) do
		if  v.param["MACAddress"] ~= nil then
			local mac_filter="(and (== MACAddress " .. v.param["MACAddress"] .. ") (== Active 1))"
			local reply2, error2 = mbus.getParameters{ path="Hosts.Host", filter=mac_filter, param={"HostName", "UserFriendlyName", "IPAddress", "MACAddress", "Active", "IPv6Address"}}

	
                 
	--	 local reply2, error2 = mbus.getParameters{ path="Hosts.Host", filter=mac_filter, param={"HostName", "UserFriendlyName", "IPAddress", "MACAddress", "Active", "IPv6Address"}}
	         

		if(error2==nil and reply2["Hosts.Host"][1]~=nil) then
				n = n + 1
	--			result[n]={}
				result[n]=reply2["Hosts.Host"][1]
			end
		end
	end
	return result 
end



--get all host info
function getHostInfo()
	
	local reply, error = mbus.getParameters{ path="Hosts.Host", filter="(and (!= Interface '') (!=IsLocalHost 'true'))", param={"UserFriendlyName", "IPAddress", "MACAddress", "Active", "Interface"} }

        for i, v in pairs(reply["Hosts.Host"]) do
              local temp=v.param["Interface"]
              local reply1, error1=mbus.getParameters{path=temp, param="Reference"} 
              local ref= tostring(reply1[temp][1].param["Reference"])
              if string.match(ref, "WLAN")==nil then 
                   table.remove(reply["Hosts.Host"],i)
              end
        end 
	
	return reply   
end

--judge the acl mac info exist
function isAclMacExist(aclMacPath, mac)
	local isExist = false
	local permission = ""

	local reply, error = mbus.getParameters{ path=aclMacPath, filter="(== MACAddress " .. tostring(mac) .. ")",flags="KEYPATH"}

	if reply[aclMacPath][1]~=nil then
		isExist = true
		permission = reply[aclMacPath][1].param["Permission"]
	end
	return isExist, permission
end

--Create the MAC Restriction
function macRestrictionCreate(aclMacPath, permission, mac)
	local isError = true
	local reply, error = mbus.modify(
	function()
	  pcall_status, pcall_error = pcall(
	function()
	local reply1, error1 = mbus.addObjects{ path = aclMacPath, param = { MACAddress = mac,Permission = permission,}, flags="KEYPATH" }
	end)
	end)
	
	--if error == nil then
	if (error == nil or pcall_status == true) then
		isError = false
	else
		isError = true
	end
	return isError
end

--Modify the MAC Restriction
function macRestrictionUpdate(aclMacPath, permission, mac)
	local isError = true
	local reply, error = mbus.modify(
	function()
	  pcall_status, pcall_error = pcall(
		function()
		local reply1, error1 = mbus.setParameters{ path=aclMacPath, param={Permission=permission},filter="(== MACAddress " .. mac .. ")",flags="KEYPATH"}	
		end)
		end)
	--if error == nil then
	if (error == nil or pcall_status == true) then
		isError = false
	else
		isError = true
	end
	return isError
end

--Delete the MAC Restriction
function macRestrictionDelete(aclMacPath, mac)
	local isError = true
	local reply, error = mbus.modify(
	function()
	  pcall_status, pcall_error = pcall(
		function()
			local result, error = mbus.deleteObjects {path = aclMacPath, filter = "(== MACAddress " .. mac .. ")",flags="KEYPATH"}
	end)
	end)
	
	--if error == nil then
	if (error == nil or pcall_status == true) then
		isError = false
	else
		isError = true
	end
	return isError
end

--Delete all the MAC Restriction
function macRestrictionDeleteAll(aclMacPath)
    local isError = true
    local reply, error = mbus.modify(
		function()
	  pcall_status, pcall_error = pcall(
        function()
            local result, error = mbus.deleteObjects {path = aclMacPath,flags="KEYPATH"}
    end)
	end)

    --if error == nil then
	if (error == nil or pcall_status == true) then
        isError = false
	else
		isError = true
    end
    return isError
end

--Change the number of rssi to signal level
function rssiToLevel(rssi)
	local result = 0
	if rssi == nil then
		return result
	end

	if rssi>=0 then
		result = 0
	elseif rssi>=-55 then
		result = 5
	elseif rssi>=-65 then
		result = 4
	elseif rssi>=-75 then
		result = 3
	elseif rssi>=-80 then
		result = 2
	elseif rssi>=-85 then
		result = 1
	end

	return result
end

local function urandom( count )
	count = count or 1
	local randomfile = assert(io.open("/dev/urandom", "r"))
	local data = randomfile:read(count)
	randomfile:close()
	return data
end

function getRandomKey( random_length )
	local alpha_lower = "abcdefghijklmnopqrstuvwxyz"
	local alpha_upper = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
	local digit = "0123456789"
	local special = "!@#$%^&*()_+-={},./?~[]|;:"
	local random_chars = alpha_lower .. alpha_upper .. digit
	if random_length>13 then
		random_chars = alpha_lower .. alpha_upper .. digit .. special
	end

	local t = {}
	local random_data = urandom( random_length )

	for i = 1, random_length do
		local byte = string.byte(random_data, i)
		byte = (byte % #random_chars) + 1
		t[i] = string.char(string.byte(random_chars, byte))
	end
	return table.concat(t)
end
%>

