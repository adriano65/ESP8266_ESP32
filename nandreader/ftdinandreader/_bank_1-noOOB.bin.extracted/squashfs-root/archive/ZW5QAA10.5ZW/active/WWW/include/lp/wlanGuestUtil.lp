<%
-- filename:       wlanGuest.lp

local wlanPath2 = "WLAN.Intf.wl_ssid1_local0"
local wlanPath4 = "WLAN.Intf.wle_radio1_ssid1"

local wlanPath = "WLAN.Intf."
local WIntfPath
local wifi2Index = 1
local wifi2GuestIndex = 2
local wifi5GuestIndex = 4
local wifiGuestIndexList = {wifi2GuestIndex,wifi5GuestIndex}

local wlanGuestInfo = {}
wlanGuestInfo[wifi2GuestIndex] = {}
wlanGuestInfo[wifi5GuestIndex] = {}

local accessPoint3Path = "Device.WiFi.AccessPoint.3"	
local accessPoint3SecurityPath = "Device.WiFi.AccessPoint.3.Security"
local accessPoint3WPSPath = "Device.WiFi.AccessPoint.3.WPS"

local accessPoint4Path = "Device.WiFi.AccessPoint.4"
local accessPoint4SecurityPath = "Device.WiFi.AccessPoint.4.Security"
local accessPoint4WPSPath = " Device.WiFi.AccessPoint.4.WPS"

local SSID3Path = "Device.WiFi.SSID.3"
local SSID4Path = "Device.WiFi.SSID.4"

local radio1Path = "Device.WiFi.Radio.1"
local radio2Path = "Device.WiFi.Radio.2"

local aclMacPath = wlanPath2 .. ".ACL.MAC"
local aclMacPathGuest5 = wlanPath4 .. ".ACL.MAC"


local ap3PointResult, accessPoint3Error = mbus.getParameters{ path=accessPoint3Path, param={"Enable","X_TELECOMITALIA_IT_DisconnectTime"},
                                                               datamodel = "second" }								

local ap4PointResult, accessPoint4Error = mbus.getParameters{ path=accessPoint4Path, param={"Enable","X_TELECOMITALIA_IT_DisconnectTime"},
																 datamodel = "second" }

																 
local ap3PointResultStatus, accessPoint3ErrorStatus = mbus.getParameters{ path=accessPoint3Path, param={"Status","X_TELECOMITALIA_IT_DisconnectTime"},
                                                               datamodel = "second" }								

local ap4PointResultStatus, accessPoint4ErrorStatus = mbus.getParameters{ path=accessPoint4Path, param={"Status","X_TELECOMITALIA_IT_DisconnectTime"},
																 datamodel = "second" }

local tempResult, tempError = mbus.getParameters{ { path=SSID3Path, param="Enable"},
													{ path=SSID4Path, param="Enable"},
													{ path=radio1Path, param="Enable"},
													{ path=radio2Path, param="Enable"}, datamodel = "second" }

													
wlanGuestInfo[wifi2GuestIndex].apEnabled = ap3PointResult[accessPoint3Path][1].param["Enable"]
wlanGuestInfo[wifi5GuestIndex].apEnabled = ap4PointResult[accessPoint4Path][1].param["Enable"]

wlanGuestInfo[wifi2GuestIndex].apStatus = ap3PointResultStatus[accessPoint3Path][1].param["Status"]
wlanGuestInfo[wifi5GuestIndex].apStatus = ap4PointResultStatus[accessPoint4Path][1].param["Status"]

wlanGuestInfo[wifi2GuestIndex].ssidEnabled = tempResult[SSID3Path][1].param["Enable"]
wlanGuestInfo[wifi5GuestIndex].ssidEnabled = tempResult[SSID4Path][1].param["Enable"]
wlanGuestInfo[wifi2GuestIndex].radioEnabled = tempResult[radio1Path][1].param["Enable"]
wlanGuestInfo[wifi5GuestIndex].radioEnabled = tempResult[radio2Path][1].param["Enable"]

wlanGuestInfo[wifi2GuestIndex].disconnectTime = ap3PointResult[accessPoint3Path][1].param["X_TELECOMITALIA_IT_DisconnectTime"]
local tprint = require("tableprint")

local frequency = "Not applicable"
local frequency1 = "2.4 GHz"
local frequency2 = "5 GHz"
local frequency3 = "2.4 GHz e 5 GHz"

local tprint = require("tableprint")
local modify = {}
-------------------------
--getWifiGuestIndexList
-------------------------
function getWifiGuestIndexList()
	return  wifiGuestIndexList
end
-------------------------------------
-- get and set Disconnect Time
--------------------------------------
function getDisconnectTimeForConfig()
	local disconnectTime = wlanGuestInfo[wifi2GuestIndex].disconnectTime
	--CPE_P00110356
	if disconnectTime == "0" then 
	   disconnectTime = 3600
	end
	return disconnectTime
end

function setDisconnectTime(disconnectInterval)
        mbus.modify(
        function()
        mbus.setParameters{path=accessPoint3Path, param= {X_TELECOMITALIA_IT_DisconnectTime = disconnectInterval}, datamodel = "second"}
        end, {datamodel="second"})
        sleep(3)
        mbus.modify(
        function()
        mbus.setParameters{path=accessPoint4Path, param= {X_TELECOMITALIA_IT_DisconnectTime = disconnectInterval}, datamodel = "second"}
        end, {datamodel="second"})
	--saveall(0, 1)
end
------------------------------------------
--SSID
-----------------------------------------

function setAnySSID(value)
    mbus.modify(
    function()
        mbus.setParameters{path=wlanPath2, param= {AnySSID=value}, flags="KEYPATH"}
    end)
    sleep(3)
    mbus.modify(
    function()
        mbus.setParameters{path=wlanPath4, param= {AnySSID=value}, flags="KEYPATH"}
    end)
    sleep(3)
end


function setSSID(value)
    mbus.modify(
    function()
        mbus.setParameters{path=wlanPath2, param= {SSID=value}, flags="KEYPATH"}
    end)
    sleep(3)
    mbus.modify(
    function()
        mbus.setParameters{path=wlanPath4, param= {SSID=value}, flags="KEYPATH"}
    end)
    sleep(3)

end

-------------------------------------------------------
--getGuestAccess
-------------------------------------------------------
function getGuestStatus()

    local cond1 = false
    local cond2 = false

    --check wifi2.4guest
    if( wlanGuestInfo[wifi2GuestIndex].radioEnabled == "true" and wlanGuestInfo[wifi2GuestIndex].ssidEnabled == "true" and wlanGuestInfo[wifi2GuestIndex].apEnabled == "true"  ) then
        cond1 = true
    end
    --check wifi5guest
    if( wlanGuestInfo[wifi5GuestIndex].radioEnabled == "true" and wlanGuestInfo[wifi5GuestIndex].ssidEnabled == "true" and wlanGuestInfo[wifi5GuestIndex].apEnabled == "true" ) then
        cond2 = true
    end

	return cond1 or cond2
	
end


function enableGuestStateWithFreq(selectedfrequency)
	modify = {}
	if( selectedfrequency == frequency1 ) then	

		if(  wlanGuestInfo[wifi2GuestIndex].radioEnabled ~= "true" ) then
			table.insert(modify, { path = radio1Path, param = {Enable="true"},datamodel = "second"})
		end
		
		table.insert(modify, { path = accessPoint3Path, param = {Enable="true"}, datamodel = "second" })   
		table.insert(modify, { path = SSID3Path, param = {Enable="true"},datamodel = "second"})		
		table.insert(modify, { path = SSID4Path, param = {Enable="false"},datamodel = "second"})
		table.insert(modify, { path = accessPoint4Path, param = {Enable="false"}, datamodel = "second" })
		
	elseif ( selectedfrequency == frequency2 ) then	
	
		if(  wlanGuestInfo[wifi5GuestIndex].radioEnabled ~= "true" ) then
			table.insert(modify, { path = radio2Path, param = {Enable="true"},datamodel = "second"})
		end		
		table.insert(modify, { path = accessPoint4Path, param = {Enable="true"}, datamodel = "second" })							   
		table.insert(modify, { path = SSID4Path, param = {Enable="true"},datamodel = "second"})		
		table.insert(modify, { path = SSID3Path, param = {Enable="false"},datamodel = "second"})	
		table.insert(modify, { path = accessPoint3Path, param = {Enable="false"}, datamodel = "second" })		
		
	elseif ( selectedfrequency == frequency3 ) then	
	
		if(  wlanGuestInfo[wifi2GuestIndex].radioEnabled ~= "true" ) then
			table.insert(modify, { path = radio1Path, param = {Enable="true"},datamodel = "second"})
		end
		if(  wlanGuestInfo[wifi5GuestIndex].radioEnabled ~= "true" ) then
			table.insert(modify, { path = radio2Path, param = {Enable="true"},datamodel = "second"})
		end		
		table.insert(modify, { path = SSID3Path, param = {Enable="true"},datamodel = "second"})	
		table.insert(modify, { path = accessPoint3Path, param = {Enable="true"}, datamodel = "second" }) 
		table.insert(modify, { path = SSID4Path, param = {Enable="true"},datamodel = "second"})
		table.insert(modify, { path = accessPoint4Path, param = {Enable="true"}, datamodel = "second" })							   
		
	end
		setMBUS_IGD(modify)	
		--saveall(0, 1)	
end

function disableGuestAccess()
	modify = {}
	table.insert(modify, { path = accessPoint4Path, param = {Enable="false"}, datamodel = "second" })	
	table.insert(modify, { path = accessPoint3Path, param = {Enable="false"}, datamodel = "second" })   
	setMBUS_IGD(modify)	
	--saveall(0, 1)	
end

-----------------------------------
--Begin : calculate frequency value
-----------------------------------
function getFrequency()

	if( ( wlanGuestInfo[wifi2GuestIndex].ssidEnabled == "true") and  ( wlanGuestInfo[wifi5GuestIndex].ssidEnabled == "false") ) then
		return frequency1
	elseif ( ( wlanGuestInfo[wifi5GuestIndex].ssidEnabled == "true" )  and ( wlanGuestInfo[wifi2GuestIndex].ssidEnabled == "false") ) then
		return frequency2
	else
		return frequency3
	end
	return frequency
	
end

--End: calculate frequency value


-----------------------------------
--Begin : calculate frequency value
-----------------------------------
function getWifiFrequency()
	if( ((wlanGuestInfo[wifi2GuestIndex].ssidEnabled == "true") and (wlanGuestInfo[wifi2GuestIndex].apStatus == "Enabled") and (wlanGuestInfo[wifi5GuestIndex].ssidEnabled == "true") and (wlanGuestInfo[wifi5GuestIndex].apStatus == "Enabled")) or ((wlanGuestInfo[wifi2GuestIndex].ssidEnabled == "true") and (wlanGuestInfo[wifi2GuestIndex].apStatus == "Disabled" or wlanGuestInfo[wifi2GuestIndex].apStatus == "Disabled_TIME_OUT" ) and (wlanGuestInfo[wifi5GuestIndex].ssidEnabled == "true") and (wlanGuestInfo[wifi5GuestIndex].apStatus == "Disabled" or wlanGuestInfo[wifi5GuestIndex].apStatus == "Disabled_TIME_OUT")) ) then
		return frequency3
	elseif ( ((wlanGuestInfo[wifi2GuestIndex].ssidEnabled == "true") and (wlanGuestInfo[wifi2GuestIndex].apStatus == "Enabled") and (wlanGuestInfo[wifi5GuestIndex].ssidEnabled == "true") and (wlanGuestInfo[wifi5GuestIndex].apStatus == "Disabled" or wlanGuestInfo[wifi5GuestIndex].apStatus == "Disabled_TIME_OUT")) or ((wlanGuestInfo[wifi2GuestIndex].ssidEnabled == "true") and (wlanGuestInfo[wifi2GuestIndex].apStatus == "Enabled") and (wlanGuestInfo[wifi5GuestIndex].ssidEnabled == "false") and (wlanGuestInfo[wifi5GuestIndex].apStatus == "Enabled")) or ((wlanGuestInfo[wifi2GuestIndex].ssidEnabled == "true") and (wlanGuestInfo[wifi2GuestIndex].apStatus == "Enabled") and (wlanGuestInfo[wifi5GuestIndex].ssidEnabled == "false") and (wlanGuestInfo[wifi5GuestIndex].apStatus == "Disabled" or wlanGuestInfo[wifi5GuestIndex].apStatus == "Disabled_TIME_OUT")) or ((wlanGuestInfo[wifi2GuestIndex].ssidEnabled == "true") and (wlanGuestInfo[wifi2GuestIndex].apStatus == "Disabled" or wlanGuestInfo[wifi2GuestIndex].apStatus == "Disabled_TIME_OUT") and (wlanGuestInfo[wifi5GuestIndex].ssidEnabled == "false") and (wlanGuestInfo[wifi5GuestIndex].apStatus == "Enabled")) or ((wlanGuestInfo[wifi2GuestIndex].ssidEnabled == "true") and (wlanGuestInfo[wifi2GuestIndex].apStatus == "Disabled" or wlanGuestInfo[wifi2GuestIndex].apStatus == "Disabled_TIME_OUT") and (wlanGuestInfo[wifi5GuestIndex].ssidEnabled == "false") and (wlanGuestInfo[wifi5GuestIndex].apStatus == "Disabled" or wlanGuestInfo[wifi5GuestIndex].apStatus == "Disabled_TIME_OUT")) ) then
		return frequency1
	elseif ( ((wlanGuestInfo[wifi2GuestIndex].ssidEnabled == "true") and (wlanGuestInfo[wifi2GuestIndex].apStatus == "Disabled" or wlanGuestInfo[wifi2GuestIndex].apStatus == "Disabled_TIME_OUT") and (wlanGuestInfo[wifi5GuestIndex].ssidEnabled == "true") and (wlanGuestInfo[wifi5GuestIndex].apStatus == "Enabled")) or ((wlanGuestInfo[wifi2GuestIndex].ssidEnabled == "false") and (wlanGuestInfo[wifi2GuestIndex].apStatus == "Enabled") and (wlanGuestInfo[wifi5GuestIndex].ssidEnabled == "true") and (wlanGuestInfo[wifi5GuestIndex].apStatus == "Enabled")) or ((wlanGuestInfo[wifi2GuestIndex].ssidEnabled == "false") and (wlanGuestInfo[wifi2GuestIndex].apStatus == "Enabled") and (wlanGuestInfo[wifi5GuestIndex].ssidEnabled == "true") and (wlanGuestInfo[wifi5GuestIndex].apStatus == "Disabled" or wlanGuestInfo[wifi5GuestIndex].apStatus == "Disabled_TIME_OUT")) or ((wlanGuestInfo[wifi2GuestIndex].ssidEnabled == "false") and (wlanGuestInfo[wifi2GuestIndex].apStatus == "Disabled" or wlanGuestInfo[wifi2GuestIndex].apStatus == "Disabled_TIME_OUT") and (wlanGuestInfo[wifi5GuestIndex].ssidEnabled == "true") and (wlanGuestInfo[wifi5GuestIndex].apStatus == "Enabled")) or ((wlanGuestInfo[wifi2GuestIndex].ssidEnabled == "false") and (wlanGuestInfo[wifi2GuestIndex].apStatus == "Disabled" or wlanGuestInfo[wifi2GuestIndex].apStatus == "Disabled_TIME_OUT") and (wlanGuestInfo[wifi5GuestIndex].ssidEnabled == "true") and (wlanGuestInfo[wifi5GuestIndex].apStatus == "Disabled" or wlanGuestInfo[wifi5GuestIndex].apStatus == "Disabled_TIME_OUT")) ) then
		return frequency2
	else
		return frequency3
	end
		
end

--End: calculate frequency value

function setFrequency(value)
local modify = {}

	if( value == frequency1 ) then
		table.insert(modify, { path = SSID3Path, param = {Enable="true"},datamodel = "second"})
		table.insert(modify, { path = SSID4Path, param = {Enable="false"},datamodel = "second"})
	elseif ( value == frequency2 ) then
		table.insert(modify, { path = SSID3Path, param = {Enable="false"},datamodel = "second"})
		table.insert(modify, { path = SSID4Path, param = {Enable="true"},datamodel = "second"})
	elseif ( value == frequency3 ) then
		table.insert(modify, { path = SSID3Path, param = {Enable="true"},datamodel = "second"})
		table.insert(modify, { path = SSID4Path, param = {Enable="true"},datamodel = "second"})
	end
		setMBUS_IGD(modify)	
		saveall(0, 1)	
	
	local tempResult, tempError = mbus.getParameters{ { path=SSID3Path, param="Enable"},
													{ path=SSID4Path, param="Enable"}, datamodel = "second" }

	wlanGuestInfo[wifi2GuestIndex].ssidEnabled = tempResult[SSID3Path][1].param["Enable"]
	wlanGuestInfo[wifi5GuestIndex].ssidEnabled = tempResult[SSID4Path][1].param["Enable"]
end	

function setSecurityMode(secMode,wepKey,wpaKey)

sleep(6)
for itr=1,#wifiGuestIndexList do
  i=wifiGuestIndexList[itr]
	 if i==1 then
           WIntfPath ="WLAN.Intf.wlif1"
        elseif i==2 then
           WIntfPath="WLAN.Intf.wl_ssid1_local0"
        elseif i==3 then
           WIntfPath="WLAN.Intf.wle_radio1_ssid0"
        elseif i==4 then
           WIntfPath="WLAN.Intf.wle_radio1_ssid1"
        end

	if secMode == "disable" then
		local wpaVersionEncrypt = "WPA"

        mbus.modify(
        function()
        mbus.setParameters{path=WIntfPath..".Security", param= {Mode="disabled"},flags="KEYPATH"}
        end)
        sleep(3)
        mbus.modify(
        function()
        mbus.setParameters{path=WIntfPath..".Security.WPAPSK", param= {WPAVersion=wpaVersionEncrypt},flags="KEYPATH"}
        end) 
        sleep(3)
	elseif secMode == "WEP 128 bit" then
		local wpaVersionEncrypt = "WPA"
        mbus.modify(
        function()
        mbus.setParameters{path=WIntfPath..".Security", param= {Mode="WEP"},flags="KEYPATH"}
        end)
        sleep(3)
        mbus.modify(
        function()
        mbus.setParameters{path=WIntfPath..".Security.WEP", param= {WEPKey=wepKey},flags="KEYPATH"}
        end)
        sleep(3)
        mbus.modify(
        function()
        mbus.setParameters{path=WIntfPath..".Security.WPAPSK", param= {WPAVersion=wpaVersionEncrypt},flags="KEYPATH"}
        end)
        sleep(3)
	else
        mbus.modify(
        function()
        mbus.setParameters{path=WIntfPath..".Security", param= {Mode="WPA-PSK"},flags="KEYPATH"}
        end)
        sleep(3)
        mbus.modify(
        function() 
        mbus.setParameters{path=WIntfPath..".Security.WPAPSK", param= {KeyPassPhrase=wpaKey},flags="KEYPATH"}
        end)
        sleep(3)
		local wpaVersionEncrypt = "WPA&WPA2"

		if secMode == "WPA-PSK TKIP 256 bit" then
		wpaVersionEncrypt = "WPA"
		elseif secMode == "WPA-PSK AES 256 bit" then
		wpaVersionEncrypt = "WPA2"
		end
        mbus.modify(
        function()
        mbus.setParameters{path=WIntfPath..".Security.WPAPSK", param= {WPAVersion=wpaVersionEncrypt},flags="KEYPATH"}
        end)
        sleep(3)
	end
end

--saveall(0, 1)

end

function getMergedList(aclList,aclListGuest5)
for i,v in pairs(aclListGuest5[aclMacPathGuest5]) do
	if isMacExistsInGuest2(aclList, tostring( v.param["MACAddress"] ) ) == false  then
		table.insert(aclList[aclMacPath],v)
	end
end
return aclList
end

function isMacExistsInGuest2(aclList,macName)
 for i,v in pairs(aclList[aclMacPath]) do
	if tostring(v.param["MACAddress"]) == macName then
		return true
	end
 end
 return false
end

%>

