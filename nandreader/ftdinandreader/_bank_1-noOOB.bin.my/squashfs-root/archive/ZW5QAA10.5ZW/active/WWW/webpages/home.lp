<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
	<meta http-equiv="X-UA-Compatible" content="IE=9"/>
	<title>Modem Telecom Italia</title>
	<link rel="stylesheet" href="css/master.css" type="text/css"/>
		<style type="text/css">
/*==== Begin Navbar Styles ====*/

.imglist li {
    position:relative;
    float:left;
        list-style:none;
		
}



.imglist ul {
    position:absolute; /* position the sublist to nearest positioned ancestor, the (#nav li) in this case*/
    list-style:none;
	display:none;
	height: 100px;
	width: 85px;
	overflow-y:auto;
	background: white;
	border: black 1px solid;
	/*z-index:3;*/
}

.imageIconFix {
	margin-top:25px;
}

margin-left20{
			margin-left:30%;
}

</style>

	<script language="javascript" type="text/javascript" src="js/browserDetect.js"></script>
	<script language="javascript" type="text/javascript" src="js/portmap.js"></script>
	
	<script type="text/javascript">
var changeFlag = true;
var ie6_img_hack = false;

function displayList(valueIn, picIn){
	disableListAll();
	disableListAll_wifi();
	if(document.getElementById("inlist" + valueIn))
	{
	document.getElementById("inlist" + valueIn).style.display = "block";
	document.getElementById("pointing"+ valueIn).style.display = "block";
	}
	
	
	if(msieversion() != -1 && msieversion() <= 6) {
		
		if(document.getElementById("wifiImage"+valueIn) != null)
		{
			ie6_img_hack = true;
			document.getElementById("wifiImage"+valueIn).style.display = "none";
			
			var iconIndex = valueIn;
			var iconToHide1 = iconIndex;
			var iconToHide2 = iconIndex-1;
			
			if(document.getElementById("wifiImage"+iconToHide1) != null) {
				document.getElementById("wifiImage"+iconToHide1).style.display = "none";
			}
						
			if(document.getElementById("wifiImage"+iconToHide2) != null) {
				document.getElementById("wifiImage"+iconToHide2).style.display = "none";
			}
		} else {
		
			ie6_img_hack = true;
		
			var iconIndex = valueIn;
			var iconToHide1 = iconIndex;
			var iconToHide2 = iconIndex-1;
			
			if(document.getElementById("wifiImage"+iconToHide2) != null) {
				document.getElementById("wifiImage"+iconToHide2).style.display = "none";
			}
		}

		//document.getElementById("inlist" + valueIn).style.top = "50px"
		//document.getElementById("inlist" + valueIn).style.left = "-5px"

	} 
	changeFlag = false;
}

function disableListAll(){
	if (changeFlag){	
		if(document.getElementById("inlist1"))
		document.getElementById("inlist1").style.display = "none";
		if(document.getElementById("inlist2"))
		document.getElementById("inlist2").style.display = "none";
		if(document.getElementById("inlist3"))
		document.getElementById("inlist3").style.display = "none";
		if(document.getElementById("inlist4"))
		document.getElementById("inlist4").style.display = "none";
		if(document.getElementById("inlist5"))
		document.getElementById("inlist5").style.display = "none";
		
		if(document.getElementById("pointing1"))
		document.getElementById("pointing1").style.display = "none";
		if(document.getElementById("pointing2"))
		document.getElementById("pointing2").style.display = "none";
		if(document.getElementById("pointing3"))
		document.getElementById("pointing3").style.display = "none";
		if(document.getElementById("pointing4"))
		document.getElementById("pointing4").style.display = "none";
		if(document.getElementById("pointing5"))
		document.getElementById("pointing5").style.display = "none";
		
		
		if(document.getElementById("tooltip_arrow1"))
		document.getElementById("tooltip_arrow1").style.display = "none";
		if(document.getElementById("tooltip_arrow2"))
		document.getElementById("tooltip_arrow2").style.display = "none";
		if(document.getElementById("tooltip_arrow3"))
		document.getElementById("tooltip_arrow3").style.display = "none";
		if(document.getElementById("tooltip_arrow4"))
		document.getElementById("tooltip_arrow4").style.display = "none";
		if(document.getElementById("tooltip_arrow5"))
		document.getElementById("tooltip_arrow5").style.display = "none";
		
		
		if(ie6_img_hack)
		{
			// alert("ie6_img_hack");
			ie6_img_hack = false;
			for(var i=1;i<=5;i++)
			{
				var wifiImgObj = "wifiImage"+i;
				if(document.getElementById(wifiImgObj))
				document.getElementById(wifiImgObj).style.display = "";
			}
		}
	}
}

function displayList_wifi(wifiValue, picIn){
	disableListAll();
	disableListAll_wifi();
	if(document.getElementById("wifilist" + wifiValue))
	{
	document.getElementById("wifilist" + wifiValue).style.display = "block";
	document.getElementById("tooltip_arrow"+wifiValue).style.display = "block";
	}
	if(msieversion() != -1 && msieversion() <= 6) {
		if(picIn == 'AccessPoint_ok.png'  || picIn == 'STB_ok.png') {
			document.getElementById("wifilist" + wifiValue).style.top = "30px"
		} else if( picIn == 'dev___xl_ok.png') {
			document.getElementById("wifilist" + wifiValue).style.top = "25px"
		} else {
			document.getElementById("wifilist" + wifiValue).style.top = "50px"
		}
		document.getElementById("wifilist" + wifiValue).style.left = "-5px"
	}
	changeFlag = false;
}

function disableListAll_wifi(){
	if (changeFlag){
		if(document.getElementById("wifilist1"))
		document.getElementById("wifilist1").style.display = "none";
		if(document.getElementById("wifilist2"))
		document.getElementById("wifilist2").style.display = "none";
		if(document.getElementById("wifilist3"))
		document.getElementById("wifilist3").style.display = "none";
		if(document.getElementById("wifilist4"))
		document.getElementById("wifilist4").style.display = "none";
		if(document.getElementById("wifilist5"))
		document.getElementById("wifilist5").style.display = "none";
	}
}

function changeListFlag() {
	changeFlag = true;	
}


function showTooltip(div, title, desc)
{
 div.style.display = 'inline';
 div.style.position = 'absolute';
 div.style.width = '316px';
 div.style.backgroundColor = '#e9eef2';
 div.style.border = 'solid 1px black';
 div.style.padding = '10px';
 div.style.left = '145px';
  div.style.font = '11px Arial';

 div.innerHTML =  title + '<div style="padding-top:5px;">' + desc + '</div>';
}
 
function hideTooltip(div)
{
 div.style.display = 'none';
}

function msieversion() {
	var ua = window.navigator.userAgent
	var msie = ua.indexOf ( "MSIE " )

	if ( msie > 0 )     // If Internet Explorer, return version number
		return parseInt (ua.substring (msie+5, ua.indexOf (".", msie )));
	else                 // If another browser, return 0
		return -1;
}
</script>

</head>
<% 
cgilua.lp.include("lp/dsl.lp")
cgilua.lp.include("lp/ppp.lp")
cgilua.lp.include("lp/usb.lp")
cgilua.lp.include("lp/wlan.lp") 
cgilua.lp.include("lp/device.lp")
cgilua.lp.include("lp/common.lp") 
cgilua.lp.include("lp/mbus_util.lp") 
cgilua.lp.include("lp/connectionService.lp") 
local tprint = require("tableprint")
local translate = translate
local TI_Device = getTIInfo_Device()
local POST=cgilua.POST
local FXO_val = getDeviceRoute()

-- Get the Device.Services.X_TELECOMITALIA_IT_VoIPServiceType State value from the Gateway
function getTIServiceType()
	local replyType, error = mbus.getParameters{ path = "Device.Services", param="X_TELECOMITALIA_IT_VoIPServiceType" , datamodel = "second" }   
	local serviceType = replyType["Device.Services"][1].param["X_TELECOMITALIA_IT_VoIPServiceType"]
	return serviceType
end
--Get WAN Connection from data PPP named "User session"
function getWanConnection()
	local pubIp = ""
	local ppp0_path = ""
	local replay1, error = mbus.getParameters{path="Device.PPP.Interface", filter="(== Name 'User session')", datamodel = "second"}
	local pppStatus, connectionStatus

	if replay1["Device.PPP.Interface"][1]~=nil then
		ppp0_path = replay1["Device.PPP.Interface"][1].path
		local enable = replay1["Device.PPP.Interface"][1].param["Enable"]
		connectionStatus = replay1["Device.PPP.Interface"][1].param["ConnectionStatus"]
	
		if enable == "true" and connectionStatus == "Connected" then
			pppStatus = translate([==[Active]==])
		elseif enable == "true" and connectionStatus == "Disconnected" then
			pppStatus = translate([==[Not active]==])
		elseif enable == "true" and (connectionStatus == "Connecting" or connectionStatus == "Authenticating") then
			pppStatus = translate([==[In activation]==])
		elseif enable == "false" then
			pppStatus = translate([==[unavailable]==])
		end 
	end
	return pppStatus, ppp0_path, connectionStatus
end

function getPPPInterEnable()
    local pppInterPath = "Device.PPP.Interface"
    local pppEnable
    local reply, error = mbus.getParameters{path=pppInterPath, filter="(== Name 'User session')", datamodel = "second"}
    if reply[pppInterPath]~=nil and reply[pppInterPath][1]~=nil then
        pppEnable = reply[pppInterPath][1].param["Enable"]
    end
    return pppEnable
end

--Get WAN Connection from data PPP named "User session"
function getIpIntf(pppPath)
	local pubIp = ""
	local ipIntfEnable = ""

	local replay1, error = mbus.getParameters{path="Device.IP.Interface", param="Enable", filter="(== LowerLayers "..pppPath..")", datamodel = "second"}
	
	if replay1["Device.IP.Interface"][1]~=nil then
		local ipPath = replay1["Device.IP.Interface"][1].path .. ".IPv4Address"
		ipIntfEnable = replay1["Device.IP.Interface"][1].param["Enable"]

		local replay2, error = mbus.getParameters{path=ipPath, param="IPAddress", datamodel = "second"}
		if replay2[ipPath][1]~=nil then
			pubIp = replay2[ipPath][1].param["IPAddress"]
		end
	end
	return pubIp, ipIntfEnable
end

--Set the state of wifi
function setWifiState(state, wifiId)
	local pathStr = "Device.WiFi.Radio.1"
	if wifiId=="3" then
		pathStr = "Device.WiFi.Radio.2"	
	end

	local reply, error = mbus.modify(
         function()
            local reply, error = mbus.setParameters{path=pathStr, param={Enable=state}, datamodel = "second"}
         end, {datamodel="second"})
end

--Set the security of wifi
function setWifiConfig(wifiId, secMode, wepKey, wpaKey)
	local wlanPath = "WLAN.Intf.wlif1"
	if wifiId=="3" then
		wlanPath = "WLAN.Intf.wle_radio1_ssid0"	
	end

	local modify ={}
	if secMode=="disable" then
		local wpaVersionEncrypt = "WPA"
		table.insert(modify, {path=wlanPath..".Security", param= {Mode="disabled"}, flags="KEYPATH"})
		table.insert(modify, {path=wlanPath..".Security.WPAPSK", param={WPAVersion=wpaVersionEncrypt}, flags="KEYPATH"})
	elseif secMode=="WEP" then
		local wpaVersionEncrypt = "WPA"
		table.insert(modify, {path=wlanPath..".Security", param= {Mode="WEP"}, flags="KEYPATH"})
		table.insert(modify, {path=wlanPath..".Security.WEP", param= {WEPKey=wepKey}, flags="KEYPATH"})
		table.insert(modify, {path=wlanPath..".Security.WPAPSK", param={WPAVersion=wpaVersionEncrypt}, flags="KEYPATH"})
	else
		table.insert(modify, {path=wlanPath..".Security", param= {Mode="WPA-PSK"}, flags="KEYPATH"})
		table.insert(modify, {path=wlanPath..".Security.WPAPSK", param= {KeyPassPhrase=wpaKey}, flags="KEYPATH"})
		local wpaVersionEncrypt = "WPA&WPA2"

		if secMode=="WPA-PSK TKIP 256 bit" then
			wpaVersionEncrypt = "WPA"
		elseif secMode=="WPA-PSK AES 256 bit" then
			wpaVersionEncrypt = "WPA2"
		end

		table.insert(modify, {path=wlanPath..".Security.WPAPSK", param={WPAVersion=wpaVersionEncrypt}, flags="KEYPATH"})
	end
	setMBUS(modify)
end

--Get encryption of wifi wpa
function getWpaEncryption(wpaVersion, wpaEncryption)
	wpaVersion = string.gsub(wpaVersion,"&","-")
	
	if wpaVersion=="WPA" then
		wpaEncryption = "TKIP"
	end
	local pos = string.find(wpaEncryption,"&")
	if pos~=nil then
		wpaEncryption = string.gsub(wpaEncryption,"&","-")
	end
	return wpaEncryption
end

--Get the encryption mode and password of wifi
function getWifiMethod(secmode, wep, wpa, wpaEncryption)
	local password = ""
	local temptab={}
	local temp = ""
	local encryption = translate([==[disable]==])
	if secmode=="WEP" then
		encryption = "WEP"
		if string.len(wep) == 13 then
			password = wep
		elseif string.len(wep) == 26 then
			-- insert a space in 2 hex digit as TI spec require
			--password = string.gsub(wep,"%x%x","%0 ", 12)
			for i=1,25,2 do
				temp = string.sub(wep,i,i+1)
				temp2 = tonumber("0x" .. temp)
				if temp2 then 
					temptab[#temptab+1] = string.char(temp2)
				end
			end
				password = table.concat(temptab)
		end
	elseif secmode=="WPA-PSK" then
		encryption = secmode .. " " .. wpaEncryption .. " 256 bit"
		password = wpa
	end
	
	return encryption, password
end

-- Check Telefoni
function getDeviceInfo()
	local reply, error = mbus.getParameters{ path = "Device.DeviceInfo", param="X_TELECOMITALIA_IT_ServiceType" , datamodel = "second" }   
	local devType = nil
	if reply["Device.DeviceInfo"] ~= nil and reply["Device.DeviceInfo"][1] ~= nil then
		devType = reply["Device.DeviceInfo"][1].param["X_TELECOMITALIA_IT_ServiceType"]
	end
	return devType
end

--post handle--
if cgilua.servervariable"REQUEST_METHOD" == "POST" then
	
	--Protected Call has been given to avoid Internal Server Error CPE_P00106551
	function pcall_MainHomeMethod()
	--if the post is because of icon type change perform this block
	if( POST["iconChangeFlag"] == "1") then
		-- add or update env
		local envName=POST["macAddress"].."_icon"
		local iconType=POST["iconType"]
		local reply, error = mbus.getParameters{path = "ENV", param = "Value", filter = "(== Name "..envName..")"}
		  mbus.modify(
			function()
			  if reply["ENV"][1]~=nil and reply["ENV"][1].param~=nil and reply["ENV"][1].param["Value"]~=nil then
				mbus.setParameters{path = "ENV", param = {Value = iconType}, filter = "(== Name "..envName..")" }
			  else
				mbus.addObjects{path = "ENV", param = {Name = envName, Value = iconType} }
			  end
			end)
		cgilua.redirect("save_alert.lp", { u = "home.lp" })
		return
	end
	--if the post is because of icon type change perform this block
	
		
	
	local wifiIndex = POST["wifiIdx"]
	local wifiState = POST["wifiState"]
	local wifiConfigFlag = POST["wifiConfigFlag"]
	--set the wifi state to change as active of inactive
	if wifiState ~="" then
		if wifiState =="0" then
			--disable the wifi
			setWifiState("0", wifiIndex)
			else
				--enable the wifi
			setWifiState("1", wifiIndex)
		end
	end

	--config the wifi 
	if wifiConfigFlag == "1" then
		local secMode, wepKey, wpaKey = POST["secMode"..wifiIndex], POST["wepKey"..wifiIndex], POST["wpaKey"..wifiIndex]
		setWifiConfig(wifiIndex, secMode, wepKey, wpaKey)
		if tonumber(POST["changeNum"])>1 then
			local wifiOtherIndex = "3"
			if wifiIndex~="1" then
				wifiOtherIndex = "1"
			end
			setWifiConfig(wifiOtherIndex, secMode, wepKey, wpaKey)
		end 
	end

	saveall(0, 1)	
	cgilua.redirect("save_alert.lp", { u = "home.lp" })
	return
	end
	if pcall(pcall_MainHomeMethod) then
		--saveall(0, 1)
		cgilua.redirect("save_alert.lp", { u = "home.lp" })
		return
	else
		cgilua.redirect("save_alert.lp", { u = "home.lp" })
		return
	end

end


--------------init data-------------
local wifiObj_T = getWlanInfoHome()
local ethdevices, wlandevices = getClientsOnLan()
local wanConnType, wanConnTitle = getWANConnectionType()
local isRemoteAccess = isRemoteAccess()

local TI_info = getTIInfoHome()
local TI_info_Device = getTIInfo_Device()
local dsl = getDSLInfoHome()
local wanEthIntf = getLanStat("ethif5")
local pppManagementStatus = getPPPManagementState()

local pppStatus, ppp0_path, ppp0_status = getWanConnection()
local pubIp, ipIntfEnable = getIpIntf(ppp0_path)

local isPPPConnected = false
if isDefaultConf() then
	if dsl.dsl_status=="Up" or pppManagementStatus=="Connected" then
		isPPPConnected = true
		if dsl.dsl_status~="Up" then
			local portSpeed = getWanEthSpeed("ethif5")
			dsl.upstream = portSpeed
			dsl.downstream = portSpeed
		end
	end
else	
	if dsl.dsl_status=="Up" or (wanEthIntf.state == "Active" and (pppManagementStatus=="Connected" or ppp0_status=="Connected")) then
		isPPPConnected = true
		if dsl.dsl_status~="Up" then
			local portSpeed = getWanEthSpeed("ethif5")
			dsl.upstream = portSpeed
			dsl.downstream = portSpeed
		end
	end
end

-- LED status
local pppLed = "ledoff.gif"
local dslLed = "ledoff.gif"
local wifiLed = "ledoff.gif"
local dectLed = "ledoff.gif"
local lineOneLed = "ledoff.gif"
local lineTwoLed = "ledoff.gif"

local led, err = mbus.getParameters{ path = "LEDS.LED", param = {"Name", "State", "Color"}, filter = "(!= Color None)" }
for i, v in pairs(led["LEDS.LED"]) do
	if v.param["Name"] == "Internet" then
		pppLed = getLedLightPic(v.param["State"], v.param["Color"])
  	elseif v.param["Name"] == "Wifi" then
		wifiLed = getLedLightPic(v.param["State"], v.param["Color"])
  	elseif v.param["Name"] == "ADSL" then
		dslLed = getLedLightPic(v.param["State"], v.param["Color"])
    elseif v.param["Name"] == "DECT" then
        dectLed = getLedLightPic(v.param["State"], v.param["Color"])
    elseif v.param["Name"] == "Line1" then
        lineOneLed = getLedLightPic(v.param["State"], v.param["Color"])
    elseif v.param["Name"] == "Line2" then
        lineTwoLed = getLedLightPic(v.param["State"], v.param["Color"])
	end
end

local serviceLed="ledlight.gif"
if TI_info.static == "off" then
	serviceLed="ledoff.gif"
elseif TI_info.static == "green_blink" then
	serviceLed="ledblinking.gif"
elseif TI_info.static == "red_fixed" then
	serviceLed="ledlightred.gif"
elseif TI_info.static == "red_blink" then
	serviceLed="ledblinkingred.gif"
end

--STB status
local iptv_status = translate([==[Inactived]==])
local IPTV_Ser = get_IPTVService()
if IPTV_Ser ~= "OFF" and IPTV_Ser ~= "Off" then
	if wanConnType=="ETH" or wanConnType == "VDSL" then
		iptv_status = translate([==[Actived]==])
	else
		if TI_info.iptvActive == "true" and wanConnType~="" then
			iptv_status = translate([==[Actived]==])
		end
	end
end
							
local mtv_status = translate([==[Inactived]==])
local managedTV_Path = "Device.DHCPv4.Client.1"
local reply, error = mbus.getParameters{path = managedTV_Path, datamodel = "second"}
local m_Enable = reply[managedTV_Path][1].param["Enable"]
if m_Enable == "true" then
	mtv_status = translate([==[Actived]==])
end
								
local msgTxt = ""
local msgBgStyle="msgBgRed"
local msgIcon="msgRedAlert.gif"
if isDefaultConf() then
	msgTxt = translate([==[Configuration is not available. Leave the modem on and connected and wait for the service configuration.]==])	
elseif wanConnType~="ETH" and dsl.dsl_status~="Up" then
	msgTxt = translate([==[The DSL connection is not active. Check the DSL cable is connected and verify proper operation of the line.]==])
elseif wanConnType=="ETH" and wanEthIntf.state == "Inactive" then
	msgTxt = translate([==[The FIBER Ethernet connection is not active. Check that the Ethernet cable is connected and verify proper operation of the line.]==])
elseif (wifiObj_T[1].secmode == "disabled" or wifiObj_T[1].secmode == "WEP") or (wifiObj_T[3].secmode == "disabled" or wifiObj_T[3].secmode == "WEP") then
	msgTxt = translate([==[Warning: Wi-Fi radio interface is used in insecure mode. It is recommended to set the mode of WPA-PSK AES 256-bit]==])	
else
	msgTxt = translate([==[It is advised to regularly change encryption key, and set WPA-PSK AES 256-bit.]==])
	msgBgStyle="msgBgGreen"
	msgIcon="msgGrayAlert.gif"
end

local errMsgInvalidWEPKey = "<p>" .. translate([==[Invalid WEP key: use only permitted characters (a-z, A-Z, 0-9) and comply with the length]==]).. "</p>"
local errMsgInvalidWPAKey = "<p>" .. translate([==[Encryption key is invalid: verify that it contains at least one character of each of the following three sets:]==]).." [a-z, A - Z], [0 - 9], [!@#$%^&*()_+-={},./<>?`~[]|;:&#92;], "..translate([==[that does not contain characters or symbols not allowed and respects the minimum and maximum length allowed (12 to 32 characters)]==]).. "</p>"
local errMsgLowEncrKey = "<p>" ..translate( [==[Warning: the level of password security is not adequate.]==] ).."</p>"
local errMsgConfirmChange2 = "<p>" .. translate([==[Warning: you also want to apply the change to the Wi-Fi 2.4GHz.]==]) .. "</p>"
local errMsgConfirmChange5 = "<p>" .. translate([==[Warning: you also want to apply the change to the Wi-Fi 5GHz.]==]) .. "</p>"
%>
<script type="text/javascript">
var symbols = " !\"#$%&'()*+,-./0123456789:;<=>?@";
var loAZ = "abcdefghijklmnopqrstuvwxyz";
symbols+= loAZ.toUpperCase();
symbols+= "[\\]^_`";
symbols+= loAZ;
symbols+= "{|}~";

function toHex(webKeyVal)
{	
	var valueStr = webKeyVal;
	var hexChars = "0123456789abcdef";
	var text = "";
	for( i=0; i<valueStr.length; i++ )
	{
		var oneChar = valueStr.charAt(i);
		var asciiValue = symbols.indexOf(oneChar) + 32;
		var index1 = asciiValue % 16;
		var index2 = (asciiValue - index1)/16;
		if ( text != "" ) text += " ";
		text += hexChars.charAt(index2);
		text += hexChars.charAt(index1);
	}

	return text;	
}

function toAscii(hex)
{
  var str = '';
  for (var i=0; i < hex.length; i +=2)
      str+=String.fromCharCode(parseInt(hex.substr(i,2),16));
  return str;
}

function format_hex(hex)
{
	var str = '';
	for(var i = 0; i < hex.length; i += 2)
		str += hex.substr(i, 2) + ' ';
	return str;
}

function asciiToHex(wepKeyVal, wifiIdx){
	document.getElementById("wepHex"+wifiIdx).innerHTML=toHex(wepKeyVal);
}

function isEncrWepKey(str)
{
	var reg = /^[\da-zA-Z]{13}$/; 
	return reg.test(str);        
}

function isEncrWpaKey(str)
{
	var reg = /^[0-9a-zA-Z!@#$%^&*()_+\-={}.,\/<>?`~\[\]|;:\\]*$/; 	
	return reg.test(str);      
}

//Set the value to wifi config page
function setWifiMethod(secMode, wepKey, wifiIdx)
{
	var wepKeyHex;
	var wepKeyAscii;

	if (wepKey.length==13)
	{
		wepKeyHex=toHex(wepKey);
		wepKeyAscii=wepKey;
	}
	else
	{
 		//why Ascii then hex, just add whitespace in 2 digit in HEX format, TI requrest
		wepKeyHex=format_hex(wepKey);
		wepKeyAscii=toAscii(wepKey);
	}
	document.getElementById("secMode"+wifiIdx).value = secMode;
	document.getElementById("wepKey"+wifiIdx).value=wepKeyAscii;
	document.getElementById("wepHex"+wifiIdx).innerHTML=wepKeyHex;
}

function changeSecMode(secMode, wifiIdx)
{
	if(secMode != "disable"){
		if(secMode=="WEP"){	
			document.getElementById("wepKeyEncryption"+wifiIdx).style.display="block";
			document.getElementById("wpaKeyEncryption"+wifiIdx).style.display="none";
		}else{
			document.getElementById("wepKeyEncryption"+wifiIdx).style.display="none";
			document.getElementById("wpaKeyEncryption"+wifiIdx).style.display="block";
		}
		document.getElementById("keyEncryption"+wifiIdx).style.display="";
	}else{
		document.getElementById("keyEncryption"+wifiIdx).style.display="none";
	}
}

//submit the wifi state to change as active of inactive.
function submitWifi(wifiState, wifiIdx)
{
	document.getElementById("wifiState").value=wifiState;
	document.getElementById("wifiIdx").value=wifiIdx;
	document.getElementById("wifiSetup").style.display="none";
	showConfirmConfig();
	//document.modemShow.submit();
}

function showSecurityConfig(wifiIdx)
{
	document.getElementById("wifi"+wifiIdx+"Show").style.display="none";
	document.getElementById("wifi"+wifiIdx+"Config").style.display="block";
}

var desc = new Array();
	
desc[1] = "Low";
desc[2] = "Medium";
desc[3] = "High";

function indicateEncryptionKeyStrength(password)
{
	
	var score   = 1;
	var isSpecialCharExists = false;	
	var isAlphaNumericCharExists = false;
	var length =  password.length;
	
	//is any uppercase, lowervase and a number presents
	isAlphaNumericCharExists = ( ( password.match(/[a-zA-Z]/) )  && ( password.match(/\d+/) ) );
	
	//if password has at least one special caracther give 1 point
	isSpecialCharExists =  password.match(/.[!,@,#,$,%,^,&,*,(,),_,+,\-,=,{,},\,,.,\/,<,>,?,`,~,\[,\],|,;,:,\\]/);
	
	if ( length >= 12 && isAlphaNumericCharExists && isSpecialCharExists ) {
			score = 2;
		}
	if ( length >= 24 ) {
		score = 2;
		if ( isAlphaNumericCharExists && isSpecialCharExists ){
			score = 3;
		}
	}	

		//Chect at the last
	if( isEncrWpaKey(password) == false )
	{
		score=1;
	}
	return score;
}
var secMode;
function wifiConfirm(wifiIdx)
{
	document.getElementById("wifiIdx").value=wifiIdx;
	document.getElementById("wifiConfigFlag").value="1";
	

	
	secMode = document.getElementById("secMode"+wifiIdx).value;
	if(secMode != "disable"){
		if(secMode=="WEP"){
			var wepKey = document.getElementById("wepKey"+wifiIdx).value;
			if(isEncrWepKey(wepKey)==false) {
				document.getElementById("chiaveKOMsg").innerHTML = "<%=errMsgInvalidWEPKey%>";
				document.getElementById("homePage").style.display="none";
				document.getElementById("homeHeaderPage").style.display="none";
				document.getElementById("keyConfig").style.display="block";
				document.getElementById("wifiSetup").style.display="none";				

				return false;
			}
		}else{
			var wpaKey = document.getElementById("wpaKey"+wifiIdx).value;
			if( wpaKey.length < 12) {
				document.getElementById("chiaveKOMsg").innerHTML = "<%=errMsgInvalidWPAKey%>";

				document.getElementById("homePage").style.display="none";
				document.getElementById("homeHeaderPage").style.display="none";
				document.getElementById("keyConfig").style.display="block";
				document.getElementById("wifiSetup").style.display="none";

				return false;
			}
			//have to do some more for password strength.
			var wpaKeyStrength = indicateEncryptionKeyStrength(wpaKey);
			if( wpaKeyStrength == 1 ) {
				document.getElementById("chiaveKOMsg").innerHTML = "<%=errMsgInvalidWPAKey%>";

				document.getElementById("homePage").style.display="none";
				document.getElementById("homeHeaderPage").style.display="none";
				document.getElementById("keyConfig").style.display="block";
				document.getElementById("wifiSetup").style.display="none";

				return false;				
			}else if ( wpaKeyStrength == 2 )
			{
				
				//alert("The wpa key strenth is with medium");
				document.getElementById("homePage").style.display="none";
				document.getElementById("homeHeaderPage").style.display="none";
				document.getElementById("keyStrengthWarning").style.display="block";
				document.getElementById("wifiSetup").style.display="none";

				return false;
			}
		}
	}
	confirmSecurityKeyWarning();	
}

function confirmSecurityKeyWarning()
{
/*
    document.getElementById("keyStrengthWarning").style.display="none";
	document.getElementById("wifiIdx").value=wifiIdx;
	document.getElementById("wifiConfigFlag").value="1";
	
	var secMode = document.getElementById("secMode"+wifiIdx).value;
	*/
	document.getElementById("keyStrengthWarning").style.display="none";
	if(secMode == "disable"){
		document.getElementById("homePage").style.display="none";
		document.getElementById("homeHeaderPage").style.display="none";
		document.getElementById("encrOffConfig").style.display="block";
		document.getElementById("wifiSetup").style.display="none";

	}else if(secMode == "WEP"){
		document.getElementById("homePage").style.display="none";
		document.getElementById("homeHeaderPage").style.display="none";
		document.getElementById("encrWepConfig").style.display="block";
		document.getElementById("wifiSetup").style.display="none";
	}else{
		submit_ok();
	}
}

function wifiCancel(wifiIdx)
{
	document.getElementById("wifiIdx").value="";
	document.getElementById("wifiConfigFlag").value="0";
	document.getElementById("wifi"+wifiIdx+"Show").style.display="block";
	document.getElementById("wifi"+wifiIdx+"Config").style.display="none";
}

function closeConfirm(){
	document.getElementById("homePage").style.display="block";
	document.getElementById("homeHeaderPage").style.display="block";
	document.getElementById("keyConfig").style.display="none";
	document.getElementById("confirmConfig").style.display="none";
	document.getElementById("keyStrengthWarning").style.display="none";
	document.getElementById("encrOffConfig").style.display="none";
	document.getElementById("encrWepConfig").style.display="none";
	document.getElementById("wifiSetup").style.display="block";
	document.getElementById("confirmConfigApplyChangesOtherIntf").style.display="none";
}

function isWifiChanged()
{
	var wifiIdx = document.getElementById("wifiIdx").value;
	var oldSecMode = document.getElementById("oldSecMode"+wifiIdx).value;
	var oldPassword = document.getElementById("oldPassword"+wifiIdx).value;
	var wpaKey = document.getElementById("wpaKey"+wifiIdx).value;
	var changeOtherIntf = document.getElementById("changeOtherIntfFlag").value;

	if(changeOtherIntf=="1")
	{
		return false;
	}

	if(secMode == "WEP")
	{
		return false;
	}

	//Encryption mode changed
	if(oldSecMode != secMode)	
	{
		return true;
	}else{
		//WPA key changed
		if(oldPassword != wpaKey)
		{
			return true;
		}	
	}

	return false;
}

function submit_ok()
{	
	if(isWifiChanged())
	{	
		var wifiIdx = document.getElementById("wifiIdx").value;
		if(wifiIdx=="1")
		{
			document.getElementById("msgChangeConfirm").innerHTML = "<%=errMsgConfirmChange5%>";
		}else{
			document.getElementById("msgChangeConfirm").innerHTML = "<%=errMsgConfirmChange2%>";
		}
		document.getElementById("homePage").style.display="none";
		document.getElementById("homeHeaderPage").style.display="none";
		document.getElementById("encrOffConfig").style.display="none";
		document.getElementById("encrWepConfig").style.display="none";
		document.getElementById("confirmConfigApplyChangesOtherIntf").style.display="block";
		document.getElementById("changeOtherIntfFlag").value="1";
		document.getElementById("changeNum").value="2";
		document.getElementById("wifiSetup").style.display="none";

		return false;
	}
	showConfirmConfig();	
}

// introduced this method for fixing CPE_P00106015.
function showConfirmConfig(){
		document.getElementById("homePage").style.display="none";
		document.getElementById("homeHeaderPage").style.display="none";
		document.getElementById("encrOffConfig").style.display="none";
		document.getElementById("encrWepConfig").style.display="none";
		document.getElementById("confirmConfigApplyChangesOtherIntf").style.display="none";
		document.getElementById("wifiSetup").style.display="none";	
		document.getElementById("confirmConfig").style.display="block";
}

// introduced this method for fixing CPE_P00106015.
function submit_ok_confirm()
{
	document.getElementById("wifi_submit").removeAttribute("href");
    document.getElementById("wifi_submit").onclick = null;
    document.getElementById("wifi_submit_con").className = "next_wifidisable";
	document.modemShow.submit();
}
function cancel(){
	if(document.getElementById("changeOtherIntfFlag").value=="1")
	{
		document.getElementById("changeNum").value="1";
		showConfirmConfig();
	}else{		
		document.getElementById("changeOtherIntfFlag").value="0";
		closeConfirm();
	}
}

function linkToLan()
{	
	/*window.parent.menu.document.getElementById("tagItem0").className="Menu1Item";
	window.parent.menu.document.getElementById("tagtd0").height="";
	window.parent.menu.document.getElementById("tagItem1").className="Menu1ItemOver";
	window.parent.menu.document.getElementById("tag1").style.display="block";
	window.parent.menu.document.getElementById("tagtd1").height="100%";
	window.parent.menu.document.getElementById("menuItem3").className="Menu2ItemOver"; */

	
	if( window.parent.menu.document.getElementById("home")!=null && 
		window.parent.menu.document.getElementById("home") != "undefinded") {
		window.parent.menu.document.getElementById("home").style.display="block";
		window.parent.menu.document.getElementById("home").className="";
	}
	if(window.parent.menu.document.getElementById("base")!=null && 
		window.parent.menu.document.getElementById("base") != "undefinded") {
		window.parent.menu.document.getElementById("base").className="Icons";
	}
	if(window.parent.menu.document.getElementById("d2")!=null && 
		window.parent.menu.document.getElementById("d2") != "undefinded") {
		window.parent.menu.document.getElementById("d2").style.display="block";
	}
	if(window.parent.menu.document.getElementById("stcon")!=null && 
		window.parent.menu.document.getElementById("stcon") != "undefinded") {
		window.parent.menu.document.getElementById("stcon").className="";
	}
	if(window.parent.menu.document.getElementById("serte")!=null && 
		window.parent.menu.document.getElementById("serte") != "undefinded") {
		window.parent.menu.document.getElementById("serte").className="";
	}
	if(window.parent.menu.document.getElementById("lanst")!=null && 
		window.parent.menu.document.getElementById("lanst") != "undefinded") {
		window.parent.menu.document.getElementById("lanst").className="submenuselect";
	}
	if(window.parent.menu.document.getElementById("wifist")!=null && 
		window.parent.menu.document.getElementById("wifist") != "undefinded") {
		window.parent.menu.document.getElementById("wifist").className="";
	}
	if(window.parent.menu.document.getElementById("wifi2")!=null && 
		window.parent.menu.document.getElementById("wifi2") != "undefinded") {
		window.parent.menu.document.getElementById("wifi2").style.display="none";		
	}
	if(window.parent.menu.document.getElementById("wifi5")!=null && 
		window.parent.menu.document.getElementById("wifi5") != "undefinded") {
		window.parent.menu.document.getElementById("wifi5").style.display="none";
	}
	if(window.parent.menu.document.getElementById("wifi_guest")!=null && 
		window.parent.menu.document.getElementById("wifi_guest") != "undefinded") {
		window.parent.menu.document.getElementById("wifi_guest").style.display="none";
	}
	if(window.parent.menu.document.getElementById("asst")!=null && 
		window.parent.menu.document.getElementById("asst") != "undefinded") {
		window.parent.menu.document.getElementById("asst").className="";
	}
	if(window.parent.menu.document.getElementById("stat")!=null && 
		window.parent.menu.document.getElementById("stat") != "undefinded") {
		window.parent.menu.document.getElementById("stat").className="";
	}
	if(window.parent.menu.document.getElementById("loac")!=null && 
		window.parent.menu.document.getElementById("loac") != "undefinded") {
		window.parent.menu.document.getElementById("loac").className="";
	}
	if(window.parent.menu.document.getElementById("advance")!=null && 
		window.parent.menu.document.getElementById("advance") != "undefinded") {
		window.parent.menu.document.getElementById("advance").style.display="block";
	}
	window.location = "lanStatus.lp";
}
function linkToHome()
{	
	window.parent.document.getElementById("menu").src="menu.lp";
}
function linkToWifi()
{	
	if(window.parent.menu.document.getElementById("home")!=null && 
		window.parent.menu.document.getElementById("home") != "undefinded") {
		window.parent.menu.document.getElementById("home").style.display="block";
		window.parent.menu.document.getElementById("home").className="";
	}
	
	if(window.parent.menu.document.getElementById("base")!=null && 
		window.parent.menu.document.getElementById("base") != "undefinded") {
		window.parent.menu.document.getElementById("base").className="Icons";
	}

	if(window.parent.menu.document.getElementById("d2")!=null && 
		window.parent.menu.document.getElementById("d2") != "undefinded") {
		window.parent.menu.document.getElementById("d2").style.display="block";
		window.parent.menu.document.getElementById("img_base").src="images/menu_ico_impostazioni_on.png";
		window.parent.menu.document.getElementById('img_home').src="images/menu_ico_modem.png";
		window.parent.menu.document.getElementById('img_advance').src="images/menu_ico_imp_avan.png";
	}

	if(window.parent.menu.document.getElementById("stcon")!=null && 
		window.parent.menu.document.getElementById("stcon") != "undefinded") {
		window.parent.menu.document.getElementById("stcon").className="";
	}

	if(window.parent.menu.document.getElementById("serte")!=null && 
		window.parent.menu.document.getElementById("serte") != "undefinded") {
		window.parent.menu.document.getElementById("serte").className="";
	}

	if(window.parent.menu.document.getElementById("lanst")!=null && 
		window.parent.menu.document.getElementById("lanst") != "undefinded") {
		window.parent.menu.document.getElementById("lanst").className="";
	}
	if(window.parent.menu.document.getElementById("wifist")!=null && 
		window.parent.menu.document.getElementById("wifist") != "undefinded") {
		window.parent.menu.document.getElementById("wifist").className="submenuselect";
	}

	if(window.parent.menu.document.getElementById("asst")!=null && 
		window.parent.menu.document.getElementById("asst") != "undefinded") {
		window.parent.menu.document.getElementById("asst").className="";
	}
	if(window.parent.menu.document.getElementById("stat")!=null && 
		window.parent.menu.document.getElementById("stat") != "undefinded") {
		window.parent.menu.document.getElementById("stat").className="";
	}
	if(window.parent.menu.document.getElementById("loac")!=null && 
		window.parent.menu.document.getElementById("loac") != "undefinded") {
		window.parent.menu.document.getElementById("loac").className="";
	}
	if(window.parent.menu.document.getElementById("advance")!=null && 
		window.parent.menu.document.getElementById("advance") != "undefinded") {
		window.parent.menu.document.getElementById("advance").style.display="block";
	}
	window.location = "wlanStatus.lp?wifiPage=wifi";
}

function linkToUsb()
{	
	var id = "";
	if(window.parent.menu.document.getElementById("home")!=null && 
		window.parent.menu.document.getElementById("home") != "undefinded") {
		window.parent.menu.document.getElementById("home").style.display="block";
		window.parent.menu.document.getElementById("home").className="";
	}
	if(window.parent.menu.document.getElementById("base")!=null && 
		window.parent.menu.document.getElementById("base") != "undefinded") {
		window.parent.menu.document.getElementById("base").className="block";
	}
	if(window.parent.menu.document.getElementById("tele")!=null && 
		window.parent.menu.document.getElementById("tele") != "undefinded") {
		window.parent.menu.document.getElementById("tele").className="";
	}
	if(window.parent.menu.document.getElementById("teleSub")!=null && 
		window.parent.menu.document.getElementById("teleSub") != "undefinded") {
		window.parent.menu.document.getElementById("teleSub").style.display="none";
	}
	if(window.parent.menu.document.getElementById("usbst")!=null && 
		window.parent.menu.document.getElementById("usbst") != "undefinded") {
		window.parent.menu.document.getElementById("usbst").className="submenuselect1";
	}
	if(window.parent.menu.document.getElementById("media")!=null && 
		window.parent.menu.document.getElementById("media") != "undefinded") {
		window.parent.menu.document.getElementById("media").className="";
	}
		if(window.parent.menu.document.getElementById("ipv6")!=null && 
		window.parent.menu.document.getElementById("ipv6") != "undefinded") {
		window.parent.menu.document.getElementById("ipv6").className="";
		window.parent.menu.document.getElementById("ipv6firewall").className="";
		window.parent.menu.document.getElementById("ipv6list").style.display="none";
	}
	
	if(window.parent.menu.document.getElementById("port")!=null && 
		window.parent.menu.document.getElementById("port") != "undefinded") {	
		window.parent.menu.document.getElementById("port").className="";
	}
	
	if(window.parent.menu.document.getElementById("dns")!=null && 
		window.parent.menu.document.getElementById("dns") != "undefinded") {		
		window.parent.menu.document.getElementById("dns").className="";
	}
	if(window.parent.menu.document.getElementById("firewa")!=null && 
		window.parent.menu.document.getElementById("firewa") != "undefinded") {
		window.parent.menu.document.getElementById("firewa").className="";
	}
	
	if(window.parent.menu.document.getElementById("urlfi")!=null && 
		window.parent.menu.document.getElementById("urlfi") != "undefinded") {	
		window.parent.menu.document.getElementById("urlfi").className="";
	}
	/*if(window.parent.menu.document.getElementById("reac")!=null && 
		window.parent.menu.document.getElementById("reac") != "undefinded") {	
		window.parent.menu.document.getElementById("reac").className="";
	} */
	if(window.parent.menu.document.getElementById("waon")!=null && 
		window.parent.menu.document.getElementById("waon") != "undefinded") {	
		window.parent.menu.document.getElementById("waon").className="";
	}
	if(window.parent.menu.document.getElementById("stru")!=null && 
		window.parent.menu.document.getElementById("stru") != "undefinded") {	
		window.parent.menu.document.getElementById("stru").className="";
	}
	if(window.parent.menu.document.getElementById("advance")!=null && 
		window.parent.menu.document.getElementById("advance") != "undefinded") {	
		window.parent.menu.document.getElementById("advance").className="Icons";
	}
	if(window.parent.menu.document.getElementById("d3")!=null && 
		window.parent.menu.document.getElementById("d3") != "undefinded") {
		window.parent.menu.document.getElementById("d3").style.display="block";
		window.parent.menu.document.getElementById("img_base").src="images/menu_ico_impostazioni.png";
		window.parent.menu.document.getElementById('img_home').src="images/menu_ico_modem.png";
		window.parent.menu.document.getElementById('img_advance').src="images/menu_ico_imp_avan_on.png";
	}
	window.location = "usbStato.lp";
}

function linkToTele()
{	
	
	var id = "";
	
	if(window.parent.menu.document.getElementById("home")!=null && 
		window.parent.menu.document.getElementById("home") != "undefinded") {
		window.parent.menu.document.getElementById("home").style.display="block";
		window.parent.menu.document.getElementById("home").className="";
	}
	if(window.parent.menu.document.getElementById("base")!=null && 
		window.parent.menu.document.getElementById("base") != "undefinded") {
		window.parent.menu.document.getElementById("base").className="block";
	}
	if(window.parent.menu.document.getElementById("tele")!=null && 
		window.parent.menu.document.getElementById("tele") != "undefinded") {
		window.parent.menu.document.getElementById("tele").className="submenuselect1";
	}
	if(window.parent.menu.document.getElementById("teleSub")!=null && 
		window.parent.menu.document.getElementById("teleSub") != "undefinded") {
		window.parent.menu.document.getElementById("teleSub").className="";
	}
	if(window.parent.menu.document.getElementById("usbst")!=null && 
		window.parent.menu.document.getElementById("usbst") != "undefinded") {
		window.parent.menu.document.getElementById("usbst").className="";
	}
	if(window.parent.menu.document.getElementById("media")!=null && 
		window.parent.menu.document.getElementById("media") != "undefinded") {
		window.parent.menu.document.getElementById("media").className="";
	}	
	if(window.parent.menu.document.getElementById("ipv6")!=null && 
		window.parent.menu.document.getElementById("ipv6") != "undefinded") {
		window.parent.menu.document.getElementById("ipv6").className="";
	}
	if(window.parent.menu.document.getElementById("port")!=null && 
		window.parent.menu.document.getElementById("port") != "undefinded") {	
		window.parent.menu.document.getElementById("port").className="";
	}
	
	if(window.parent.menu.document.getElementById("dns")!=null && 
		window.parent.menu.document.getElementById("dns") != "undefinded") {	
		window.parent.menu.document.getElementById("dns").className="";
	}
	if(window.parent.menu.document.getElementById("firewa")!=null && 
		window.parent.menu.document.getElementById("firewa") != "undefinded") {
		window.parent.menu.document.getElementById("firewa").className="";
	}
	
	if(window.parent.menu.document.getElementById("urlfi")!=null && 
		window.parent.menu.document.getElementById("urlfi") != "undefinded") {
		window.parent.menu.document.getElementById("urlfi").className="";
	}
	/*if(window.parent.menu.document.getElementById("reac")!=null && 
		window.parent.menu.document.getElementById("reac") != "undefinded") {
		window.parent.menu.document.getElementById("reac").className="";
	} */
	if(window.parent.menu.document.getElementById("waon")!=null && 
		window.parent.menu.document.getElementById("waon") != "undefinded") {
		window.parent.menu.document.getElementById("waon").className="";
	}
	if(window.parent.menu.document.getElementById("stru")!=null && 
		window.parent.menu.document.getElementById("stru") != "undefinded") {
		window.parent.menu.document.getElementById("stru").className="";
	}
	if(window.parent.menu.document.getElementById("advance")!=null && 
		window.parent.menu.document.getElementById("advance") != "undefinded") {
		window.parent.menu.document.getElementById("advance").className="Icons";
	}
	if(window.parent.menu.document.getElementById("d3")!=null && 
		window.parent.menu.document.getElementById("d3") != "undefinded") {
		window.parent.menu.document.getElementById("d3").style.display="block";
		window.parent.menu.document.getElementById("img_base").src="images/menu_ico_impostazioni.png";
		window.parent.menu.document.getElementById('img_home').src="images/menu_ico_modem.png";
		window.parent.menu.document.getElementById('img_advance').src="images/menu_ico_imp_avan_on.png";
	}
	window.location = "voipStato.lp";
}


function usbOpenLink(usbAddr)
{
	window.location="usbStato.lp";
}

//Query the led state in every 2 seconds by ajax
function changeLedLight()
{
    var urlStr = "/led_ajax.lp";
    var params="";
    ajax_get(urlStr, params, ledUpdate_cb);
}

//Callback handle to led update:arrayLed{0=dsl, 1=ppp, 2=wifi, 3=service, 4=dect, 5=line1, 6=line2}
function ledUpdate_cb(ajax_obj)
{
	var rsps = ajax_obj.responseText.replace(/\s/g,"");
	
	var arrayLed = rsps.split("##");
	
	if(document.getElementById("dslLedImg")) { 
		if(arrayLed[0] != document.getElementById("dslLedImg").value)
		{
			document.getElementById("dslLedImg").value = arrayLed[0];
			document.getElementById("dslLedPic").innerHTML = "<img src='images/"+arrayLed[0]+"'>";
		}
	}
	
	if(document.getElementById("pppLedImg")) { 
		if(arrayLed[1] != document.getElementById("pppLedImg").value)
		{
			document.getElementById("pppLedImg").value = arrayLed[1];
			document.getElementById("pppLedPic").innerHTML = "<img src='images/"+arrayLed[1]+"'>";
		}
	}

	if(document.getElementById("wifiLedImg")) { 
		if(arrayLed[2] != document.getElementById("wifiLedImg").value)
		{
			document.getElementById("wifiLedImg").value = arrayLed[2];
			document.getElementById("wifiLedPic").innerHTML = "<img src='images/"+arrayLed[2]+"'>";
		}
	}
	
	if(document.getElementById("serviceLedImg")) { 
		if(arrayLed[3] != document.getElementById("serviceLedImg").value)
		{
			document.getElementById("serviceLedImg").value = arrayLed[3];
			document.getElementById("serviceLedPic").innerHTML = "<img src='images/"+arrayLed[3]+"'>";
		}
	}

	if(document.getElementById("dectLedImg")) { 
		if(arrayLed[4] != document.getElementById("dectLedImg").value)
		{
			document.getElementById("dectLedImg").value = arrayLed[4];
			document.getElementById("dectLedPic").innerHTML = "<img src='images/"+arrayLed[4]+"'>";
		}
	}

	if(document.getElementById("lineOneLedImg")) { 
		if(arrayLed[5] != document.getElementById("lineOneLedImg").value)
		{
			document.getElementById("lineOneLedImg").value = arrayLed[5];
			document.getElementById("lineOneLedPic").innerHTML = "<img src='images/"+arrayLed[5]+"'>";
		}
	}

	if(document.getElementById("lineTwoLedImg")) { 
		if(arrayLed[6] != document.getElementById("lineTwoLedImg").value)
		{
			document.getElementById("lineTwoLedImg").value = arrayLed[6];
			document.getElementById("lineTwoLedPic").innerHTML = "<img src='images/"+arrayLed[6]+"'>";
		}
	}
}

window.setInterval("changeLedLight()", 2000);


function updateIconInEnv(macAddress,iconType)
{
document.getElementById("macAddress").value = macAddress;
document.getElementById("iconType").value = iconType;
document.getElementById("iconChangeFlag").value = "1";
document.modemShow.submit();

//submit a  form
}

</script>
<%if isRemoteAccess==false then%>
	<body onload="javascript:linkToHome();" onclick="disableListAll();disableListAll_wifi();">
<%else%>
	<body onload="javascript:linkToHome();">
<%end%>	

<div class="contentcontainer">
<hr>
<form method="POST" id="modemShow" name="modemShow" action="">
<input type="hidden" id="wifiState" name="wifiState" value="" />
<input type="hidden" id="wifiIdx" name="wifiIdx" value="" />
<input type="hidden" id="wifiConfigFlag" name="wifiConfigFlag" value="0" />
<input type="hidden" id="changeOtherIntfFlag" name="changeOtherIntfFlag" value="0" />
<input type="hidden" id="changeNum" name="changeNum" value="1" />
<input type="hidden" id="macAddress" name="macAddress" value="0"/>
<input type="hidden" id="iconType" name="iconType" value="0"/>
<input type="hidden" id="iconChangeFlag" name="iconChangeFlag" value="0"/>	
	

<table id="homeHeaderPage" width="87%" border="0" cellspacing="0" cellpadding="0" class="fontSize">
	<tr><!-- Show warning message -->
	<td>
		<div class="<%=msgBgStyle%>">
			<div class="hdrtxt padleft10"><%=msgTxt%></div></div>
			<div class="clrBth"></div>
	</td>
	</tr><!-- End of warning message -->

	<tr>
	<td>
	<div class="sectionContainerTop fontSize paddtop10" style="padding-right: 0px; padding-left: 0px;">		

			<table class="hometopimgtxt">
				<tbody>
					<tr id="homePage">
						<!-- Show internet connection -->
						<td class="state verticalAlign" >

							<table  border="0" cellpadding="0" cellspacing="0"  class="tablecontainttbl fontSize">
								<!--<tr><td>&nbsp;</td></tr>-->
								<tr><td class="ltpd60 txtLeft transform fbold"><%=translate([==[State of Modem]==])%> </td><td class="ltpd10 transform fbold">&nbsp;&nbsp;&nbsp;&nbsp;</td></tr>
								<!--<tr><td>&nbsp;</td></tr>-->
								<tr><td>&nbsp;</td></tr>
	<%if isPPPConnected then%>
			<% if (pppStatus == translate([==[Active]==])) then %>
								<tr><td class="ltpd60 txtRight "><%=translate([==[Internet Connection]==])%>: </td><td class="ltpd10 transform fbold"><span><%=pppStatus%></span></td></tr>	
			<%else%>			
								<tr><td class="ltpd60 txtRight "><%=translate([==[Internet Connection]==])%>: </td><td class="ltpd10 transform fbold span_red"><%=pppStatus%></td></tr>								
			<%end%>					
			<%			local pppEnable = getPPPInterEnable()
			if pppEnable~="false" then
			%>
								<tr><td class="ltpd60 txtRight"><%=translate([==[Public IP Address]==])%>: </td><%  if ipIntfEnable=="true" then %><td class="ltpd10 fbold  fcolor"><%=pubIp%></td><%  end %></tr>
			<%end%>
								<tr><td class="ltpd60 txtRight "><%=translate([==[Maximum Speed Download]==])%>: </td><td class="ltpd10  fcolor"><%=dsl.downstream%></td></tr>
								<tr><td class="ltpd60 txtRight "><%=translate([==[Maximum Speed Upload]==])%>: </td><td class="ltpd10  fcolor"><%=dsl.upstream%></td></tr>
			<% if TI_Device.lanOption == "res-rt-napt" or TI_Device.lanOption == "res-rt" or TI_Device.lanOption == "res-rt-napt-ipv6" then%>
								<tr><td class="ltpd60 txtRight "><%=translate([==[IPTV service]==])%>: </td><td class="ltpd10  fcolor"><%=iptv_status%></td></tr>
								<tr><td class="ltpd60 txtRight "><%=translate([==[Managed TV service]==])%>: </td><td class="ltpd10  fcolor"><%=mtv_status%></td></tr>
			<%end%>
	<%else%>
								<tr><td class="ltpd60 txtRight "><%=translate([==[Internet Connection]==])%>: </td><td class="ltpd10 transform fbold span_red"><%=translate([==[Not active]==])%></td></tr>
			<%
			local pppEnable = getPPPInterEnable()
			if pppEnable~="false" then
			%>
								<tr><td class="ltpd60 txtRight"><%=translate([==[Public IP Address]==])%>: </td><td class="ltpd10 fbold  fcolor"></td></tr>
			<%end%>
								<tr><td class="ltpd60 txtRight "><%=translate([==[Maximum Speed Download]==])%>: </td><td class="ltpd10  fcolor"></td></tr>
								<tr><td class="ltpd60 txtRight "><%=translate([==[Maximum Speed Upload]==])%>: </td><td class="ltpd10  fcolor"></td></tr>
			<% if TI_Device.lanOption == "res-rt-napt" or TI_Device.lanOption == "res-rt" or TI_Device.lanOption == "res-rt-napt-ipv6" then%>
							<tr><td class="ltpd60 txtRight "><%=translate([==[IPTV service]==])%>: </td><td class="ltpd10  fcolor"><%=iptv_status%></td></tr>
							<tr><td class="ltpd60 txtRight "><%=translate([==[Managed TV service]==])%>: </td><td class="ltpd10  fcolor"><%=mtv_status%></td></tr>							
			<%end%>
    <%end%>
							<tr><td class="ltpd60 txtRight " <%if TI_Device.lanOption ~= "res-rt-napt" and TI_Device.lanOption ~= "res-rt" and TI_Device.lanOption ~= "res-rt-napt-ipv6" then%>width="30%"<%end%>><%=translate([==[Profile Tariff]==])%>: </td><td class="ltpd10 fcolor"><%=TI_info_Device.profile%></td></tr>
							</table>
							<div class="clrBth"></div>
						</td>
						<!-- end of internet connection -->
						
						
						
						<td class="state imgCont">
														
							<table cellspacing='0' cellpadding='0' border="0" class="hometbtop">
					    	<tr>
							<td align="right"> 
							<table cellspacing='0' cellpadding='0' border="0" class="hometb">

				<tr><td class="width20">&nbsp;</td>
				<td class="ledBg width45 txtAlignCenter"><img src="images/dsl.gif" alt="dsl" /></td>
				<td class="ledBg width45 txtAlignCenter"><img src="images/net.gif" alt="Internet" /></td>
				<td class="ledBg width45 txtAlignCenter"><img src="images/wlan.gif" alt="Power" /></td>
				<td class="ledBg width45 txtAlignCenter"><img src="images/service.gif" alt="service" /></td>
				<td class="ledBg width45 txtAlignCenter"><img src="images/dect.gif" alt="DECT" /></td>
				<td class="ledBg width45 txtAlignCenter"><img src="images/line1.gif" alt="Line1" /></td>
				<td class="ledBg width45 txtAlignCenter"><img src="images/line2.gif" alt="Line2" /></td>
				<td class="width20">&nbsp;</td></tr>

			<tr>
			<td class="width20">&nbsp;</td>
			<td class="ledBg1 width45"><div id="dslLedPic" class="alignMid txtAlignCenter width45"><img src="images/<%=dslLed%>" class="alignMid"/></div></td>
			<td class="ledBg1 width45"><div id="pppLedPic" class="alignMid txtAlignCenter width45"><img src="images/<%=pppLed%>" class="alignMid"/></div></td>
			<td class="ledBg1 width45"><div id="wifiLedPic" class="alignMid txtAlignCenter width45"><img src="images/<%=wifiLed%>" class="alignMid"/></div></td>		
			<td class="ledBg1 width45"><div id="serviceLedPic" class="alignMid txtAlignCenter width45"><img src="images/<%=serviceLed%>" class="alignMid"/></div></td>
			<td class="ledBg1 width45"><div id="dectLedPic" class="alignMid txtAlignCenter width45"><img src="images/<%=dectLed%>" class="alignMid"/></td>
			<td class="ledBg1 width45"><div id="lineOneLedPic" class="alignMid txtAlignCenter width45"><img src="images/<%=lineOneLed%>" class="alignMid"/></td>
			<td class="ledBg1 width45"><div id="lineTwoLedPic" class="alignMid txtAlignCenter width45"><img src="images/<%=lineTwoLed%>" class="alignMid"/></td>
			<td class="width20">&nbsp;</td>
			
			</tr>	
			<tr style="height:10px;"><td colspan="9"></td></tr>	
			</table>
			</td></tr>
			
			<tr>
			<td style="text-align: center;"><img src="images/downarrow.png" /></td>
			</tr>
			<tr>
			<td style="text-align: center;"><img src="images/modem.jpg" /></td>
			</tr>

			</table>	
			</td>
			</tr>
			</tbody>
			</table>
		
		</div>
		</td>
	</tr>
	
	<!-- Ethernet,WAN, USP and Telephony start here--->
	<% local countIn = 0 %>
	<tr>
	<td>
		<div class="sectionContainer fontSize">
				<div class="trtxthght fbold transform fontSize" style="padding-left:8px"><%=translate([==[Connected Devices]==])%></div>
				<div class="clrBth"></div>
			<div>
			<table cellpadding="0" cellspacing="0">
			
				<tbody>
					<tr class="oddRow" style="height:100px;">
						<td style = "padding-top:15px">
							<div class="tblInfoConatiner wdth130px">
								<div class="tblImgContainer" style="padding-top:12px">
									<img  src="images/talble_eth.png"/>
								</div>
								<%	
									local ethNum=0 									
								for i,v in pairs(ethdevices) do 									
									if v.active=="true" then 										
											ethNum=ethNum+1 									
									end									
								end
								%>
								<div class="contentInfo ">
									<div class="contentTxt">(<%=ethNum%>) ethernet</div>
									<div class="clrBth"></div>
									<div><a href="javascript:linkToLan();" style="cursor:pointer"><div  class="detailArea  transform"><%=translate([==[Details]==])%></div></a></div>
								</div>
								<div class="clrBth"></div>
							</div>
						</td>
												
						<%			
						if(ethNum ~= 0) then						
							local ethIndexNum = 0
							countIn = 0
							for i,v in pairs(ethdevices) do 
								countIn = countIn + 1
								ethIndexNum = ethIndexNum + 1
								local iconType,hostPic = getIconForDevice(v.mac)
								if v.isGameDevice then
									hostPic = "dev___xl.png"
								end
								if v.active=="false" then 
									hostPic = "ico_host_generico_ko.png"
								end
						%>		
						<td style = "padding-top:15px">
							<div class="tblInfoConatiner wdth130px">
								<div class="tblImgContainer">
									<ul class="imglist fontSize txtAlignCenter">
                                        <li><img src="images/<%=hostPic%>" onclick="displayList(<%=countIn %>, '<%=hostPic%>');" onmouseout="changeListFlag();" height="50" width="50"/>
										<%if isRemoteAccess==false then%>
										
											<div id="pointing<%=countIn %>" style="display:none;margin-top:0%;">		
											<img src="images/arrow.png" style="position:absolute;margin-top:0%;margin-left:-41%;z-index:99;"/>
										</div>
										
										
										<!-- Code to show the Menu icons in table format -->
										<ul id="inlist<%=countIn %>" class="listIcon" style="margin-top:36%;z-index:90; <%if countIn == 4 then %>margin-left: -500%;<% elseif countIn == 5 then %>margin-left: -725%; <%end%>"> <!-- style="margin-top:25px"> -->
										<li>
										
										<div style="position:relative;">
										
											<table cellspacing='0' cellpadding='0'  border="0" class="txtAlignCenter">
											<tbody>
											<tr class="oddRowMenu">
											<td><table cellspacing='0' cellpadding='0'  border="0"><tr>

											<td>
													<a href="#" onclick="updateIconInEnv('<%=v.mac%>', 'generic')"><img src="images/ico_host_generico.png"/></a> <br/>
													<div class="contentTxt menuList wdth70px">Generico</div>
											<td>
													<a href="#" onclick="updateIconInEnv('<%=v.mac%>', 'pc')"><img src="images/ico_pc.png"/></a> <br/>
													<div class="contentTxt menuList wdth70px">PC</div>
												</td>
												<td>
													<a href="#" onclick="updateIconInEnv('<%=v.mac%>', 'smartphone')"><img src="images/ico_smartphone.png" /></a> <br/>
													<div class="contentTxt menuList wdth70px">Smartphone</div>
												</td>
												<td>
													<a href="#" onclick="updateIconInEnv('<%=v.mac%>', 'tablet')"><img src="images/ico_tablet.png" /></a> <br/>
													<div class="contentTxt menuList wdth70px">Tablet</div>
												</td>
												<td>
												
												<a href="#" onclick="updateIconInEnv('<%=v.mac%>', 'notebook')"><img src="images/ico_notebook.png" /></a> <br/>
													<div class="contentTxt menuList wdth70px">Notebook</div>
												</td>
												<td>
													<a href="#" onclick="updateIconInEnv('<%=v.mac%>', 'camera')"><img src="images/ico_videocamera.png" /></a> <br/>
													<div class="contentTxt menuList wdth70px">Camera</div>
												</td>
												</tr></table></td>

											</tr>
											<tr class="oddRowMenu">
											<td><table cellspacing='0' cellpadding='0'  border="0"><tr>	
											<td style="">
												   <a href="#" onclick="updateIconInEnv('<%=v.mac%>', 'console')"><img src="images/ico_game.png" /></a> <br/>
													<div class="contentTxt menuList wdth70px">Console</div>

												</td>
											
											<td style="">
												   <a href="#" onclick="updateIconInEnv('<%=v.mac%>', 'tv')"><img src="images/TV.png" /></a> <br/>
													<div class="contentTxt menuList wdth70px">TV</div>

												</td>
												<td>
													<a href="#" onclick="updateIconInEnv('<%=v.mac%>', 'ap')"><img src="images/ico_exx.png" /></a> <br/>
													<div class="contentTxt menuList wdth70px">Access Point</div>

												</td>
												<td>
												   <a href="#" onclick="updateIconInEnv('<%=v.mac%>', 'stb')"><img src="images/ico_stb.png" /></a> <br/>
													<div class="contentTxt menuList wdth70px">Decoder</div>

												</td>
												<td>
												   <a href="#" onclick="updateIconInEnv('<%=v.mac%>', 'repeater')"><img src="images/ico_repeater.png" /></a> <br/>
													<div class="contentTxt menuList wdth70px">Repeater</div>

												</td>
												<td>
												   <a href="#" onclick="updateIconInEnv('<%=v.mac%>', 'mediaplayer')"><img src="images/ico_mediaplayer.png" /></a> <br/>
													<div class="contentTxt menuList wdth70px">Media Player</div>

												</td>
												<!--<td>
												   <a href="#" onclick="updateIconInEnv('<%=v.mac%>', 'stb')"><img src="images/STB.png" /></a> <br/>
													<div class="contentTxt menuList wdth70px">Set Top Box</div>

												</td>--></tr></table></td>

											</tr>
											<!-- <tr class="oddRowMenu listIconNameProperty">
												<td><div class="contentTxt">TV</div></td>
												<td><div class="contentTxt">Access Point</div></td>
												<td><div class="contentTxt">Set Top Box</div></td>
											</tr> -->
										</tbody>
										</table></div>
									</li>
									</ul>
									<%end%>
                                         </li>
                                     </ul>
								</div>
								
								<div class="contentInfo width65">
							     <div id="myid<%=countIn %>" name="myid<%=countIn %>" class="contentTxt1 width65 wordWrap"></div>	
								
								</div>
								<div class="clrBth"></div>
							</div>
						</td>
						<script type="text/javascript">
						    var a = "<%=v.name%>"
							if(a.length >= 17)
							{
							var b = a.substring(0,17)+'...';
							document.getElementById("myid<%=countIn %>").innerHTML = b;
							}
							else
							{									
							document.getElementById("myid<%=countIn %>").innerHTML = a;
							}
							//alert(b);
						</script>
						<% --Maximum connection pc is five and more than one wifi if it exists.
							if ethIndexNum>=5 then
								break
							end
							end							
							for j=1,5-ethIndexNum do								
								cgilua.print("<td class='wdth130px'>&nbsp;</td>")
							end
						else
							cgilua.print("<td class='wdth130px'>&nbsp;</td>")
							cgilua.print("<td class='wdth130px'>&nbsp;</td>")
							cgilua.print("<td class='wdth130px'>&nbsp;</td>")
							cgilua.print("<td class='wdth130px'>&nbsp;</td>")
							cgilua.print("<td class='wdth130px'>&nbsp;</td>")							
						end%>						
						
					</tr>

					
					<tr class="evenRow"  style="height:100px">
						<td style = "padding-top:15px">
							<div class="tblInfoConatiner wdth130px ">
								<div class="tblImgContainer" style="padding-top:12px">
									<img  src="images/table_wifi.png"/>
								</div>

								<%	
									local wifiIndexNum = 0
									if _G.next(wlandevices) ~= nil then	
																				
										for i,v in pairs(wlandevices) do
											wifiIndexNum = wifiIndexNum + 1
										end
									end
								%>


								<div class="contentInfo ">
									<div class="contentTxt">(<%=wifiIndexNum%>) Wi-Fi</div>
									<div ><a href="javascript:linkToWifi();" style="cursor:pointer"><div  class="detailArea  transform"><%=translate([==[Details]==])%></div></a></div>
								</div>
								<div class="clrBth"></div>
							</div>
						</td>
						<%	
							local wifiIncenum = 0
							local ethIndexNum = 0
							if _G.next(wlandevices) ~= nil then 
								countIn = 0
								for i,v in pairs(wlandevices) do
									countIn = countIn + 1
									wifiIncenum = wifiIncenum + 1
									local iconType,hostPic = getIconForDevice(v.mac)
									
						%>	
						<td style = "padding-top:15px" class="verticalAlign">
							<div class="tblInfoConatiner">
								<div class="tblImgContainer fleft" >
									<ul class="imglist" >								
                                   <div> <li><img src="images/<%=hostPic%>" onclick="displayList_wifi(<%=countIn %>, '<%=hostPic%>');" onmouseout="changeListFlag();" id="wifiImage<%=countIn %>" style="padding-left:4px;" >
									<%if isRemoteAccess==false then%>
									
								<div id="tooltip_arrow<%=countIn %>" style="display: none; margin-top: 0%;">
									<img style="position:absolute;margin-top:-4px;margin-left:16%;z-index:99;" src="images/arrow_whiteBg.png">
									</div>
									<ul id="wifilist<%=countIn %>" class="listIcon" style="margin-top: 27%; z-index: 90; <%if countIn == 4 then %>margin-left: -480%;<% elseif countIn == 5 then %>margin-left: -672%; <%end%>"> <!-- style="margin-top:25px"> -->
										<li>
										<div style="position:relative;z-index:90;">
											<table cellspacing='0' cellpadding='0'  border="0" class="txtAlignCenter">
											<tbody>
											<tr class="oddRowMenu">
											<td><table cellspacing='0' cellpadding='0'  border="0">
<tr>										<td>
											<a href="#" onclick="updateIconInEnv('<%=v.mac%>', 'generic')"><img src="images/ico_host_generico.png"/></a> <br/>
													<div class="contentTxt menuList wdth70px">Generico</div>
											</td>
											<td>
												<a href="#" onclick="updateIconInEnv('<%=v.mac%>', 'pc')"><img src="images/ico_pc.png"/></a> <br/>
													<div class="contentTxt menuList wdth70px">PC</div>
											</td>
											<td>
													<a href="#" onclick="updateIconInEnv('<%=v.mac%>', 'smartphone')"><img src="images/ico_smartphone.png" /></a> <br/>
													<div class="contentTxt menuList wdth70px">Smartphone</div>
												</td>
												<td>
													<a href="#" onclick="updateIconInEnv('<%=v.mac%>', 'tablet')"><img src="images/ico_tablet.png" /></a> <br/>
													<div class="contentTxt menuList wdth70px">Tablet</div>
												</td>
												<td>
												<a href="#" onclick="updateIconInEnv('<%=v.mac%>', 'notebook')"><img src="images/ico_notebook.png" /></a> <br/>
													<div class="contentTxt menuList wdth70px">Notebook</div>
												</td>
												<td>
													<a href="#" onclick="updateIconInEnv('<%=v.mac%>', 'camera')"><img src="images/ico_videocamera.png" /></a> <br/>
													<div class="contentTxt menuList wdth70px">Camera</div>
												</td>
												
												
												</tr></table></td>

											</tr>
											<tr class="oddRowMenu">
											<td><table cellspacing='0' cellpadding='0'  border="0"><tr>	
											<td>
													 <a href="#" onclick="updateIconInEnv('<%=v.mac%>', 'console')"><img src="images/ico_game.png" /></a> <br/>
													<div class="contentTxt menuList wdth70px">Console</div>
												</td>
											<td style="">
												   <a href="#" onclick="updateIconInEnv('<%=v.mac%>', 'tv')"><img src="images/TV.png" /></a> <br/>
													<div class="contentTxt menuList wdth70px">TV</div>

												</td>
												<td>
													<a href="#" onclick="updateIconInEnv('<%=v.mac%>', 'ap')"><img src="images/ico_exx.png" /></a> <br/>
													<div class="contentTxt menuList wdth70px">Access Point</div>

												</td>
												<td>
												   <a href="#" onclick="updateIconInEnv('<%=v.mac%>', 'stb')"><img src="images/ico_stb.png" /></a> <br/>
													<div class="contentTxt menuList wdth70px">Decoder</div>

												</td>
												<td>
												   <a href="#" onclick="updateIconInEnv('<%=v.mac%>', 'repeater')"><img src="images/ico_repeater.png" /></a> <br/>
													<div class="contentTxt menuList wdth70px">Repeater</div>

												</td>
												<td>
												   <a href="#" onclick="updateIconInEnv('<%=v.mac%>', 'mediaplayer')"><img src="images/ico_mediaplayer.png" /></a> <br/>
													<div class="contentTxt menuList wdth70px">Media Player</div>

												</td>
												</tr></table></td>

											</tr>
														</tbody>
										</table></div>
									</li>
									</ul>
									
									<%end%>
                                         </li>
                                     </ul>
								</div></div>
							
								<div class="contentInfo width65 fleft">
									<div id="wifiid<%=countIn %>" name="wifiid<%=countIn %>" class="contentTxt1 width65 wordWrap"><%=v.name%></div>								
								</div>
								<div class="clrBth"></div>
							</div>
						</td>
						<script type="text/javascript">
						    var a = "<%=v.name%>"
							if(a.length >= 17)
							{
							var b = a.substring(0,17)+'...';
							document.getElementById("wifiid<%=countIn %>").innerHTML = b;
							}
							else
							{									
							document.getElementById("wifiid<%=countIn %>").innerHTML = a;
							}
							//alert(b);
						</script>
						<%		--Maximum connection pc is five and more than one wifi if it exists. 
								if wifiIncenum>=5  then
									break
								end
								end
								for j=1,5-wifiIncenum do								
								cgilua.print("<td class='wdth130px'>&nbsp;</td>")
								end
							else
								cgilua.print("<td class='wdth130px'>&nbsp;</td>")
								cgilua.print("<td class='wdth130px'>&nbsp;</td>")
								cgilua.print("<td class='wdth130px'>&nbsp;</td>")
								cgilua.print("<td class='wdth130px'>&nbsp;</td>")
								cgilua.print("<td class='wdth130px'>&nbsp;</td>")
							end
						%>
		
					</tr>
					<tr class="oddRow usb_bg"  style="height:100px">
						<td style = "padding-top:15px;vertical-align:top">
							<div class="tblInfoConatiner wdth130px ">
								<div class="tblImgContainer paddtop10" style="width:32px">
									<img  src="images/table_usb.png"/>
								</div>
								<%
									local usbNum = 0
									local cs_state, cs_name = get_cs_state()
									local usbdisk_info, printer_info
									if cs_state == "true" then
										usbdisk_info = get_usb_list_home() 
									end
									if usbdisk_info~=nil then
										for i=1,#usbdisk_info do                    		
											usbNum = usbNum + 1
										end
									end
									local ps_state = get_ps_state()
									if ps_state == "true" then
											printer_info = get_printer_info()
									end
									if printer_info~=nil then
										for i = 1, #printer_info do
												usbNum = usbNum + 1
										end
										end
								

								%>
						<%if isRemoteAccess then%>	
								<div class="contentInfo " style="width:81px">
									<div class="contentTxt">(<%=usbNum%>) Usb</div>
									<div ><a href="javascript:linkToUsb();" style="cursor:pointer"><div  class="detailArea transform"><%=translate([==[Details]==])%></div></a></div>
								</div>
								<div class="clrBth"></div>
						<%else%>
								<div class="contentInfo " style="width:81px">
									<div class="contentTxt">(<%=usbNum%>) Usb</div>
									<div ><a href="javascript:linkToUsb();" style="cursor:pointer"><div  class="detailArea transform"><%=translate([==[Details]==])%></div></a></div>
								</div>
								<div class="clrBth"></div>
						<%end%>
							</div>
						</td>
						<%
							--storage device
							local usbincenum = 0;
							
							if usbdisk_info~=nil then
								for i=1,#usbdisk_info do                    		
									usbincenum = usbincenum + 1				
									local sharing_addr = tostring(usbdisk_info[i].sharing_addr)
									sharing_addr = "file:///"..string.gsub(sharing_addr, "\\", "\/")
										local remote_addr = "/var/usbmount/" .. tostring(usbdisk_info[i].device_name)
						%>
						<td class="verticalAlign paddtop10">
							<div class="tblInfoConatiner1 wdth130px">
								<div class="tblImgContainer2">
									<img  src="images/ico_hd.png"/>
								</div>
								<div class="contentInfo wdth72px" >
									<div class="contentTxt2 contentWifi"><%=usbdisk_info[i].friendly_name%></div>
									<%if isRemoteAccess then%>
										<!-- <div ><a href="#" onclick="usbOpenLink('<%=sharing_addr%>')"><div class="homebtnAPRI"><%=translate([==[Open]==])%></div></a></div> -->
										<div ><a href="remoteAccessUsb.lp?filePath=<%=remote_addr%>" style="cursor:pointer"><div class="homebtnAPRI"><%=translate([==[Open]==])%></div></a></div>
									<%else%>										
										<div ><a href="remoteAccessUsb.lp?filePath=<%=remote_addr%>" style="cursor:pointer"><div class="homebtnAPRI"><%=translate([==[Open]==])%></div></a></div>
									<%end%>
								</div>
								<div class="clrBth"></div>
							</div>
						</td>
						<%		--Maximum connection pc is five and more than one wifi if it exists. 
								if usbincenum>=5  then
									break
								end
								end
								for j=1,5-usbincenum do								
									--cgilua.print("<td class='wdth120px'>&nbsp;</td>")
								end

							else
								--cgilua.print("<td class='wdth120px'>&nbsp;</td>")
							end
							--print device
							if usbincenum <5 then
							
							
								if printer_info~=nil then
								
									for i = 1, #printer_info do
										usbincenum = usbincenum + 1
										
										if usbincenum >5 then
											break
										end
										
										local printName = printer_info[i].name
										if printName == "" then
											printName = "PRINTER"
										end
						%>

						<td class="verticalAlign paddtop10">
							<div class="tblInfoConatiner1 wdth130px">
								<div class="tblImgContainer2">
									<img  src="images/prin__xl.png"/>
								</div>
								<div class="contentInfo wdth72px">
									<div class="contentTxt2 contentWifi"><%=printName%></div>									
									<div ><a href="javascript:linkToUsb();" style="cursor:pointer"><div class="homebtnAPRI"><%=translate([==[Open]==])%></div></a></div>

								</div>
								<div class="clrBth"></div>
							</div>
						</td>
						<%end 
							
						end 
						for j=1,5-usbincenum do								
									cgilua.print("<td class='wdth130px'>&nbsp;</td>")
								end
						end%>
						
						</tr>
						<%if getTIServiceType() == "SIP_GW" then%>
						<%if FXO_val == "true" then%>
						<tr class="evenRow"  style="height:100px">
						<td style = "padding-top:15px">
							<div class="tblInfoConatiner wdth130px">
								<div class="tblImgContainer" style="padding-top:12px">
									<img  src="images/table_tel.png"/>
								</div>
								<div class="contentInfo ">
									<div id="telephonyRow" class="contentTxt">(0) telefoni</div>
									<div><a href="javascript:linkToTele();" style="cursor:pointer"><div  class="detailArea transform"><%=translate([==[Details]==])%></div></a></div>
								</div>
								<div class="clrBth"></div>
							</div>
						</td>
								<% 
							
		           				local rowNum = 0
								local count=0
								local teleCount = 0
								local telefoniDisplayCounter = 5
		           				local teleName, telePortType, teleNum
       			  	   			local portMapPath = "Device.Services.VoiceService.1.VoiceProfile.1.X_TELECOMITALIA_IT_VoicePortMap"
            					local reply, error = mbus.getParameters{ path = portMapPath, param = {"ToUA", "FromVoicePort"}, datamodel = "second" }
								--1if
								if reply[portMapPath][1]~=nil and reply[portMapPath][1].param["ToUA"]~=nil then								
								--2ndfor
								
									for i,v in pairs(reply[portMapPath]) do
									if v.param["FromVoicePort"] ~= nil then
									
									local telePortPathName = v.param["FromVoicePort"]
									local portId = string.sub(telePortPathName, -1)
									local teleLineNumPath = v.param["ToUA"]
									local replyTele, error = mbus.getParameters{ path = teleLineNumPath, param = "DirectoryNumber", datamodel = "second" }
									teleNum = replyTele[teleLineNumPath][1].param["DirectoryNumber"]
									--4
										if telePortPathName~="Device.Services.VoiceService.1.PhyInterface.3" then
											--5
											if string.match(tostring(telePortPathName), "DECTHandset")~=nil then
												telePortType = "DECT"..portId
											else
												telePortType = "FXS"..portId
											
												--for i,v in pairs(telePortType) do
													--		rowNum = rowNum + 1
												--end
											end
											--5
											--6
											if string.match(tostring(telePortPathName), "DECTHandset")==nil then
											count=count+1
													
													-- Check for the max number of Telefone images to be displayed
													if count <= telefoniDisplayCounter then
														teleCount = teleCount + 1
														teleName = "Telefono "..tostring(teleCount)
													%>
													<td style = "padding-top:15px">
														<div class="tblInfoConatiner1 wdth130px">
															<div class="tblImgContainer">
																<img  src="images/ico_telefono.png"/>
															</div>

															<div class="contentInfo">
																<div class="contentTxt3"><%= teleName  %></div>
																
															</div>
															<div class="clrBth"></div>
														</div>
													</td>
													<% 
													end
											else
												local DECTHandsetActive = "false"
												local reply, error = mbus.getParameters{ path = telePortPathName, param = "Active", datamodel = "second" }
												DECTHandsetActive = reply[telePortPathName][1].param["Active"]
												--7
												if DECTHandsetActive=="true" then
												count=count+1
												
													-- Check for the max number of Telefone images to be displayed
													if count <= telefoniDisplayCounter then
														teleCount = teleCount + 1
														teleName = "Telefono "..tostring(teleCount)
													%>
													<td style = "padding-top:15px">
														<div class="tblInfoConatiner1 wdth130px">
															<div class="tblImgContainer">
																<img  src="images/ico_telefono.png"/>
															</div>

															<div class="contentInfo">
																<div class="contentTxt3"><%= teleName  %></div>
																
															</div>
															<div class="clrBth"></div>
														</div>
													</td>
													<% 
													end
												end
												--7
											end
											--6
										 else --4thelse
										
										--8thfor
											for j=1,5 do
											rowNum = rowNum + 1
												if rowNum%2==1 then
													rowStyle = "evenrow"
												else
													rowStyle = "oddrow"
												end
											
											local DECTHandsetPath = "Device.Services.VoiceService.1.PhyInterface.3.X_TELECOMITALIA_IT_DECTHandset." .. j
											local reply, error = mbus.getParameters{ path = DECTHandsetPath, param = "Active", datamodel = "second" }
											local DECTActive = reply[DECTHandsetPath][1].param["Active"]
											--9if
											if DECTActive=="true" then
												telePortType = "DECT" .. tostring(j)
												count=count+1
												
												-- Check for the max number of Telefone images to be displayed
												if count <= telefoniDisplayCounter then
													teleCount = teleCount + 1
													teleName = "Telefono "..tostring(teleCount)
												%>
												<td style = "padding-top:15px">
													<div class="tblInfoConatiner1 wdth130px">
														<div class="tblImgContainer">
															<img src="images/ico_telefono.png"/>
														</div>

														<div class="contentInfo">
															<div class="contentTxt3"><%= teleName  %></div>
															
														</div>
														<div class="clrBth"></div>
													</div>
												</td>
												<%
												end
											end --9if
										 end --8thfor
                end --4thif
				end --nil check if end
            end --2ndfor
            end --1if 			
			%>
			<script type="text/javascript">			
			document.getElementById("telephonyRow").innerHTML="(<%= count %>) telefoni";
			</script>
				
						</tr>
						
						<%end end%>	
					</tbody>
				
				</table>
			</div>
		</div>
	</td>
	</tr>
	<!-- Ethernet,WAN, USP and Telephony ends here--->
</table>

<div class="sectionContainerWifi fontSize" id="wifiSetup">
			<div class="trtxthght fbold transform fontSize padTop10" style="padding-left:18px"><%=translate([==[Quick Setup Wi-Fi]==])%></div><div class="mrgnleft5px padngtop5px" ><img src='images/info.png'  height="20"  width="20"  onMouseOut="hideTooltip(t1)"  onMouseOver="showTooltip(t1, 'La configurazione rapida Wi-Fi consente di attivare e disattivare le interfacce radio e  modificarne la modalit&agrave; di sicurezza e la chiave di cifratura.',
		'La funzione &quot;Ottimizza Wi-Fi&quot; effettua la ricerca automatica del canale radio con meno interferenza.')" /></div>
			<div style="display:none" id="t1"></div>
			<div class="clrBth"></div>




	
		<%
		    local wifi2Index = 1
			local wifi5Index  = 3
			local wifiIndexList = {wifi2Index,wifi5Index}
			
			local wifiTitlePic = "iwla24s.png"
			local wifiBand = "2.4"
			for itr = 1, #wifiIndexList do
			    n = wifiIndexList[itr]
			--for n=1, 2 do
				if n == 3 then				    
					wifiTitlePic = "iwla50s.png"
					wifiBand = 5
				end
				local wlanState = translate([==[Active]==])
				local wlanStateStyle = "fontGreen"
				if wifiObj_T[n].status=="disabled" then
					wlanState = translate([==[Not active]==])
					wlanStateStyle = "fontLightGrey"
				end
			
				local wpaEncryption = getWpaEncryption(wifiObj_T[n].wpaversion, wifiObj_T[n].encryption)

				local encryption, password = getWifiMethod(wifiObj_T[n].secmode, wifiObj_T[n].wep, wifiObj_T[n].wpa, wpaEncryption)
				local alertPic = ""
				-- CPE_P00105400
                                -- local encryptionStyle== "fontDarkGrey"
                                local encryptionStyle = "ltpd5 fcolor"

				if wifiObj_T[n].secmode=="disabled" or wifiObj_T[n].secmode=="WEP" then
					alertPic = "<img src='images/alert.gif' />"
					encryptionStyle = "fontRed"
				end

				local wepKeyStyle="none"
				local wpaKeyStyle="none"
				local keyEncryptionStyle="none"
				if wifiObj_T[n].secmode=="WEP" then
					wepKeyStyle = "block"
					keyEncryptionStyle=""
				elseif wifiObj_T[n].secmode~="disabled" then
					wpaKeyStyle = "block"
					keyEncryptionStyle=""		
				end

				
		%>
		
			<!-- wifi connection -->			
			
			<table id="homePage" cellspacing='0' cellpadding='0' border="0" style="margin:0 12px;" class='oddRB fontSize'>
			<tr>
			<td style='vertical-align:middle;width:10%;'>
				<div class="tblImgContainer3"><img src='images/<%=wifiTitlePic%>' alt='Technicolor Gateway'>&nbsp;&nbsp;&nbsp;&nbsp;</div>
			</td>
			<td style='vertical-align:middle;white-space:nowrap;width:20%;padding:0 5px;'>
				<div class="contentTxt fbold padLeft15 width100px">WI-FI <%=wifiBand%> GHz</div>				
				
                		<% if isRemoteAccess==false then%>
                			<%if wifiObj_T[n].status=="enabled" then%>
                    	<div class="fleft"><div class="fleft"><img src="images/switch_on.png"></div><div class="fleft buttonarea mainButton"><a href="#" class="buttonText" onclick="submitWifi('0', '<%=n%>')" /><%=translate([==[Disable]==])%></div></div>
                			<%else%>
						<div class="fleft"><div class="fleft"><img src="images/switch_off.png"></div><div class="buttonarea fleft mainButton"><a href="#"  class="buttonText" onclick="submitWifi('1', '<%=n%>')" /><%=translate([==[Active]==])%></div></div>
					     
                			<%end%>
                		<%end%>
                	</td>			
			<td class='' style='width:80%;'>

				<table id="wifi<%=n%>Show" width="100%" class='contentInfo' cellspacing='0' cellpadding='0' style="line-height:150%; table-layout:fixed;"> 
                	<tr>
				<td class="margin10px fsize" style="width:60%;white-space:normal;">
				<table cellspacing='0' cellpadding='0' border="0" class="fontSize">
				<tr><td class="txtRight padng2px"><%=translate([==[Name]==])%> (SSID):</td>
				<td class="ltpd5 fcolor"><%=wifiObj_T[n].ssid%></td></tr> 
				<tr><td class="txtRight padng2px"><%=translate([==[Key encryption]==])%>:</td>
				<td class="fontDarkGrey fontSize" style="word-break:break-all; overflow:hidden;padding-left:5px;width:300px;" class="ltpd5 fcolor">
				<% if isRemoteAccess==false then cgilua.print(password) end%></td></tr>
				<tr><td class="txtRight padng2px" style="vertical-align:baseline;_padding-top:10px;"><%=translate([==[Encryption mode]==])%>:</td>
				<td class="<%=encryptionStyle%>" style="padding-left:5px;vertical-align:baseline;"><%=encryption%><%=alertPic %></td></tr> 
			
				
				
				<tr>
				<td><input type="hidden" id="oldSecMode<%=n%>" name="oldSecMode<%=n%>" value="<%=encryption%>" />
				<input type="hidden" id="oldPassword<%=n%>" name="oldPassword<%=n%>" value="<%=password%>" />&nbsp;</td></tr></table></td>
				
				<td class="mrgn11px" style='vertical-align:top;font-size:12px;'>
				
				<% if isRemoteAccess==false then%>
				
				<div class="Hbtn1 mrgntop5px " style="float:right"><a href="#" style="cursor:pointer" <%if wifiObj_T[n].status=="enabled" then%> onclick="showSecurityConfig(<%=n%>)" <%end%>><div class="homeMainBtn fbold transform fontSize" align="center"><%=translate([==[Wi-Fi security]==])%></div></a></div>
				<!-- <td><input type="button" value="<%=translate([==[Wi-Fi security]==])%>" onclick="showSecurityConfig(<%=n%>)" /></td> -->
				<div class="Hbtn1 mrgnbtm5px " style="float:right"><a href="#" style="cursor:pointer" <%if wifiObj_T[n].status=="enabled" then%> onclick="javascript:window.location.href='refresh_chan.lp?intf=<%=n%>';" <%end%>><div class="homeMainBtn fbold transform fontSize" align="center"><%=translate([==[Wi-Fi optimize]==])%></div></a></div>
				<!-- <td colspan='2'><input type="button" value="<%=translate([==[Wi-Fi optimize]==])%>" onclick="javascript:window.location.href='refresh_chan.lp?intf=<%=n%>';" /></td> -->
				
				<%end%>
				</td>
				</tr>
				</table>
				<!-- set wifi encryption mode and password -->
				<table id="wifi<%=n%>Config" width='100%' class='martop10 fontSize' cellspacing='0' cellpadding='0' width="100%" cellspacing="0" cellpadding="0" style="line-height: 150%; table-layout: fixed; display:none;">
				<tr>
				
				<td  style="width:60%;" class="margin10px fsize">
				<table border="0" cellpadding="0" cellspacing="0" class="fontSize padtop10">
				
					<tr>
					<td class="txtRight padng2px" style="vertical-align:top"><%=translate([==[Key encryption]==])%>:</td>
					<td class="ltpd5 fcolor width300">
					<div id="keyEncryption<%=n%>" style="display:<%=keyEncryptionStyle%>">
					<div id="wepKeyEncryption<%=n%>" style="display:<%=wepKeyStyle%>">
                        		<table border="0" cellpadding="0" cellspacing="0" class="fontSize">
                                <tr>
                                <td ><input type="text" id="wepKey<%=n%>" name="wepKey<%=n%>" size="13" maxlength="13" value="<%=wifiObj_T[n].wep%>" onkeypress="asciiToHex(this.value, '<%=n%>')"  class="inputClass"/></td></tr>
                                <tr><td  style="width:100%"><span id="wepHex<%=n%>"></span>&nbsp;[HEX]</td></tr>
                        		</table></div>
					<div id="wpaKeyEncryption<%=n%>" style="display:<%=wpaKeyStyle%>">
                                <table border="0" cellspacing="0" cellpadding="0" class="fontSize">
                                <tr><td  style="width:100%;">
                                <input type="text" id="wpaKey<%=n%>" name="wpaKey<%=n%>"   class="inputClass"size="32" maxlength="32" value="<%=wifiObj_T[n].wpa%>" />
                                </td></tr>
                        		</table></div>
					</div></td></tr>
					
					<tr>
				<td class="txtRight padng2px"><%=translate([==[Encryption mode]==])%>:</td>
					<td class="ltpd5 fcolor">
					<select class="inputClass" size="1" id="secMode<%=n%>" name="secMode<%=n%>" onchange="changeSecMode(this.value,'<%=n%>')">
						<option value="disable"><%=translate([==[disable]==])%></option>
						<%if n~=3 then%>
						<option value="WEP">WEP (128-bit)</option>
						<%end%>
						<option value="WPA-PSK TKIP 256 bit">WPA-PSK TKIP 256-bit</option>
						<option value="WPA-PSK AES 256 bit">WPA-PSK AES 256-bit</option>
						<option value="WPA-PSK TKIP-AES 256 bit">WPA-PSK TKIP-AES 256-bit</option>
					</select></td></tr>

					</table>
				</td>
				
				<td class="mrgn11px fontSize" style='vertical-align:top;'>
					<div class="Hbtn1 mrgntop5px fontSize"><a href="#" style="cursor:pointer" onclick="wifiConfirm('<%=n%>')"><div class="homeSecBtn fbold transform" align="center"><%=translate([==[confirmation]==])%></div></a></div>
					
					<div class="Hbtn1 mrgnbtm5px fontSize"><a href="#" style="cursor:pointer" onclick="wifiCancel('<%=n%>')"><div class="homeSecBtn fbold transform" align="center"><%=translate([==[Cancel]==])%></div></a></div>
					
					</td></tr>
				</table>
				</td></tr>			
			</table>	
			<!-- end of wifi connection -->			
			<script language="javascript" type="text/javascript">setWifiMethod("<%=encryption%>", "<%=wifiObj_T[n].wep%>", "<%=n%>");</script>
		</td>
		<%if n == 1 then%><td>&nbsp;</td><%end%>
		</tr></table>
	<%end%>
	</div>
	</td></tr>
	
	
</table>
<input type="hidden" id="dslLedImg" name="dslLedImg" value="<%=dslLed%>" />
<input type="hidden" id="pppLedImg" name="pppLedImg" value="<%=pppLed%>" />
<input type="hidden" id="wifiLedImg" name="wifiLedImg" value="<%=wifiLed%>" />
<input type="hidden" id="serviceLedImg" name="serviceLedImg" value="<%=serviceLed%>" />
<input type="hidden" id="dectLedImg" name="dectLedImg" value="<%=dectLed%>" />
<input type="hidden" id="lineOneLedImg" name="lineOneLedImg" value="<%=lineOneLed%>" />
<input type="hidden" id="lineTwoLedImg" name="lineTwoLedImg" value="<%=lineTwoLed%>" />
</form>
</div>

<script src="js/antiCSRF.js" type="text/javascript"></script>
<script src="js/browser.js" type="text/javascript"></script>

<script>
var browserName = getBrowserName();
var majorVersion = getBrowserMajorVersion();

</script>

<!-- warning and error message -->
<div id="confirmConfig" style="display:none">
<%cgilua.lp.include("webparts/confirmWlan.lp")%>
</div>

<div id="confirmConfigApplyChangesOtherIntf" style="display:none">
<%cgilua.lp.include("webparts/wlanConfirmChangeOnOtherIntf.lp")%>
</div>

<div id="keyConfig" style="display:none">
<%cgilua.lp.include("webparts/chiaveKO.lp")%>
</div>
<div id="encrOffConfig" style="display:none">
<%cgilua.lp.include("webparts/WlanEncrOff.lp")%>
</div>
<div id="encrWepConfig" style="display:none">
<%cgilua.lp.include("webparts/WlanEncrWEP.lp")%>
</div>	
<div id="keyStrengthWarning" style="display:none">
<%cgilua.lp.include("webparts/wpaKeyStrengthWarning.lp")%>
</div>

<%
	local deviceInfo, error = mbus.getParameters{ path = "Device.DeviceInfo", param={"ModelName", "SoftwareVersion"}, datamodel = "second" }   
	local modelName = deviceInfo["Device.DeviceInfo"][1].param["ModelName"]
	local softwareVersion = deviceInfo["Device.DeviceInfo"][1].param["SoftwareVersion"]
	
	local deviceService, error = mbus.getParameters{ path = "Device.ManagementServer", param={"X_TELECOMITALIA_IT_ServiceRealm"}, datamodel = "second" }   
	local serviceRealm = deviceService["Device.ManagementServer"][1].param["X_TELECOMITALIA_IT_ServiceRealm"]	
%>
<!-- Adobe Marketing Cloud Tag Management code
Copyright 1996-2014 Adobe, Inc. All Rights Reserved
More info available at http://www.adobe.com -->
<script type="text/javascript"></script>
<script>//<![CDATA[
(function() {
  var d=document,
  h=d.getElementsByTagName('head')[0],
  st=d.createElement('script');
  st.type='text/javascript';
  st.async=true;
  st.src='js/s_code.js';
  h.appendChild(st);
}()); 

if(s){
     s.pageName="AG:HomePage";
     s.channel="HomePage";
     s.prop9="All AGs";
     s.prop21="<%=modelName%>";
     s.prop22="<%=softwareVersion%>";
     s.prop23="<%=serviceRealm%>";
     s.t()
}
//]]></script>
<!-- End Adobe Marketing Cloud Tag Management code -->

</body>
</html>
