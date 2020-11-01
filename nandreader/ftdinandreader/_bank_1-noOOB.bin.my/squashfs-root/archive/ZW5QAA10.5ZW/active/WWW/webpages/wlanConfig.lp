<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<title>Modem Telecom Italia</title>
<link rel="stylesheet" href="css/master.css" type="text/css" />
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
<% cgilua.lp.include("lp/wlan.lp") %>
<% cgilua.lp.include("lp/util.lp") %>
<% cgilua.lp.include("lp/mbus_util.lp") %>
<% cgilua.lp.include("lp/style.lp") %>
<%
local translate = translate
local QUERY = cgilua.QUERY
local POST = cgilua.POST

local sectionName = translate([==[Basic Settings]==])
local tprint = require("tableprint")
local print=cgilua.print

local wlanPath = "WLAN.Intf.wlif1"  
local name = "2.4 GHz"
local intfPath = "Device.WiFi.Radio.1"
local titlePic = "iwla24xl.gif"
local page = "wifi2"
if QUERY["id"]=="2" then
  wlanPath = "WLAN.Intf.wle_radio1_ssid0"  
  name = "5 GHz"
  intfPath = "Device.WiFi.Radio.2"
  titlePic = "iwla50xl.gif"
  page = "wifi5"
else
  QUERY["id"] = "1"
end
local aclMacPath = wlanPath .. ".ACL.MAC"
local result=getWlanMain(wlanPath)

local reply, error = mbus.getParameters{ path = intfPath, param = "Enable", datamodel = "second"}			
local wlanState = reply[intfPath][1].param["Enable"]
local wlanChannel = result.channel
local channelMode = result.channelmode
local wpaVersion = string.gsub(result.wpaversion,"&","-")
local wepKeyEncryption = result.wep
local wpaKeyEncryption = result.wpa

local wpaEncryption = result.encryption
if wpaVersion=="WPA" then
  wpaEncryption = "TKIP"
end
local pos = string.find(wpaEncryption,"&")
if pos~=nil then
  wpaEncryption = string.gsub(wpaEncryption,"&","-")
end

local wepKeyStyle="none"
local wpaKeyStyle="none"
local keyEncryptionStyle="none"
local wpsRegistrationStyle = "none"
local secMode = "disable"
if result.secmode=="WEP" then 
  secMode = "WEP 128 bit"
  wepKeyStyle = "block"
  keyEncryptionStyle=""
elseif result.secmode=="WPA-PSK" then
  secMode = result.secmode .. " " .. wpaEncryption .. " 256 bit"
  wpaKeyStyle = "block"
  keyEncryptionStyle=""
  wpsRegistrationStyle = ""
end

local ssid = result.ssid
local anyssid = result.anyssid
local adminState = result.adminState
local aclControl = result.control
local pageDisplay = false
local aclList, error
local numberOfMAC=0
if aclControl=="unlock" then
    aclList, error = mbus.getParameters{ path=aclMacPath, param={"MACAddress", "Permission"}, flags="KEYPATH" }
    numberOfMAC =  #aclList[aclMacPath]
end

if cgilua.servervariable"REQUEST_METHOD" == "POST" then


for i=1, tonumber(POST["changeNum"]) do
    wlanPath = POST["wlanPath"]
	if tonumber(POST["changeNum"])>1 then
	    sleep(2)
	    if( i == 2 ) then
			--incase i value becomes 2 , then avoid accessing WLAN.Intf.2
			i = 3 
		end		
	    if(i==3)  then
		wlanPath = "WLAN.Intf.wle_radio1_ssid0" 
	    elseif(i==1) then
	        wlanPath = "WLAN.Intf.wlif1"
	    elseif(i==4) then 
	        wlanPath = "WLAN.Intf.wle_radio1_ssid1"
	    end
		aclMacPath = wlanPath .. ".ACL.MAC"
	end
	local deviceID
	local intfstr = string.sub(tostring(wlanPath), 11)
	if intfstr == "wlif1" then
		deviceID = 1
	elseif( intfstr == "wl_ssid1_local0"  ) then
		deviceID = 2
	elseif( intfstr == "wle_radio1_ssid0"  ) then
		deviceID = 2
	elseif( intfstr == "wle_radio1_ssid1"  ) then
		deviceID = 4
	end

   	local modify ={}
	if POST["wpsSubmitFlag"]~="0" then
		local wps_reg_path = wlanPath..".WPS.REGISTRAR"
		if POST["wpsSubmitFlag"]=="1" and POST["pin"] ~= "" then
			table.insert(modify, {path = wps_reg_path, param = {Pin = POST["pin"], Event = "start"}, flags="KEYPATH"})
			setMBUS(modify)
		elseif POST["wpsSubmitFlag"]=="2" then
			table.insert(modify, {path = wps_reg_path, param = {Pin = "0", Event = "start"}, flags="KEYPATH"})
			setMBUS(modify)
		end
        saveall(0, 1)
        cgilua.redirect("wlanStatus.lp", { wifiPage = page })
		return
	end

	
	if POST["aclSubmitFlag"]=="1" then
		
		if aclControl=="disabled" then
			table.insert(modify, {path=wlanPath..".ACL", param= {Control="unlock"}, flags="KEYPATH"})
			
			setMBUS(modify)
			modify ={}
			aclList, error = mbus.getParameters{ path=aclMacPath, param={"MACAddress", "Permission"} ,flags="KEYPATH"}
			
			numberOfMAC =  #aclList[aclMacPath]
		end

		if numberOfMAC >= 50 then
			cgilua.redirect("resultKO.lp?pageDisplay=enough")
			return
		else
			local isAclMacExistFlag, permission = isAclMacExist(aclMacPath, POST["aclMAC"])
			if isAclMacExistFlag == true then
				if permission ~= POST["aclOption"] then
					local resultACL = macRestrictionUpdate(aclMacPath, POST["aclOption"], POST["aclMAC"])
					cgilua.redirect("wlanStatus.lp", { wifiPage = page })
					return
				else
					cgilua.redirect("resultKO.lp?pageDisplay=exist")
	                                return
				end
			end
		end
    
		local aclAddErr = macRestrictionCreate(aclMacPath, POST["aclOption"], POST["aclMAC"])
		if aclAddErr ~= false then
			cgilua.redirect("resultKO.lp")
			return
		else
            saveall(0, 1)
            cgilua.redirect("wlanStatus.lp", { wifiPage = page })
			return
		end
    	end

	if POST["wlanState"] == "true" then
		if POST["wlanState"] ~= wlanState then	
            table.insert(modify, {path = "Device.WiFi.Radio."..deviceID, param = {Enable="true"}, datamodel = "second"})
			setMBUS_IGD(modify)
				saveall(0, 1)
				cgilua.redirect("wlanStatus.lp", { wifiPage = page })
				return
		end

		if POST["wlanChannel"] ~= "Auto" then
			if (channelMode  ~= "Auto" and POST["wlanChannel"]~=wlanChannel) or (channelMode  == "Auto") then
				modify ={}
				--Set ChannelMode just to trigger notification of ChannelMode node
				table.insert(modify, {path=wlanPath, param= {ChannelMode="Manual"}, flags="KEYPATH"})
				table.insert(modify, {path=wlanPath, param= {Channel=POST["wlanChannel"]}, flags="KEYPATH"})
				setMBUS(modify)				
			end
		else
			if channelMode  ~= "Auto" then
				modify ={}					
				table.insert(modify, {path=wlanPath, param= {ChannelMode="Auto"}, flags="KEYPATH"})
				setMBUS(modify)					
			end
		end
			
		--if POST["channelWidth"] ~= nil and POST["channelWidth"] ~= result.channelwidth and (POST["secMode"] == "disable" or POST["secMode"] == "WPA-PSK AES 256 bit") then
		if POST["channelWidth"] ~= nil and POST["channelWidth"] ~= result.channelwidth then
			modify ={}
			table.insert(modify, {path=wlanPath, param= {ChannelWidth=POST["channelWidth"]}, flags="KEYPATH"})
			setMBUS(modify)
		end
   
		if POST["secMode"]~=secMode or POST["wepKey"]~=wepKeyEncryption or POST["wpaKey"]~=wpaKeyEncryption then
			modify ={}
			if POST["secMode"]=="disable" then
				local wpaVersionEncrypt = "WPA"
				table.insert(modify, {path=wlanPath..".Security", param= {Mode="disabled"}, flags="KEYPATH"})
				table.insert(modify, {path=wlanPath..".Security.WPAPSK", param={WPAVersion=wpaVersionEncrypt}, flags="KEYPATH"})
			elseif POST["secMode"]=="WEP 128 bit" then
				local wpaVersionEncrypt = "WPA"
				table.insert(modify, {path=wlanPath..".Security", param= {Mode="WEP"}, flags="KEYPATH"})
				table.insert(modify, {path=wlanPath..".Security.WEP", param= {WEPKey=POST["wepKey"]}, flags="KEYPATH"})
				table.insert(modify, {path=wlanPath..".Security.WPAPSK", param={WPAVersion=wpaVersionEncrypt}, flags="KEYPATH"})
			else					
				table.insert(modify, {path=wlanPath..".Security", param= {Mode="WPA-PSK"}, flags="KEYPATH"})
				table.insert(modify, {path=wlanPath..".Security.WPAPSK", param= {KeyPassPhrase=POST["wpaKey"]}, flags="KEYPATH"})
				local wpaVersionEncrypt = "WPA&WPA2"

				if POST["secMode"]=="WPA-PSK TKIP 256 bit" then
					wpaVersionEncrypt = "WPA"
				elseif POST["secMode"]=="WPA-PSK AES 256 bit" then
					wpaVersionEncrypt = "WPA2"
				end

				table.insert(modify, {path=wlanPath..".Security.WPAPSK", param={WPAVersion=wpaVersionEncrypt}, flags="KEYPATH"})
			end
			setMBUS(modify)				
		end
		
		if POST["aclControl"]~=aclControl then 
			modify ={}	
			local aclPath = wlanPath..".ACL"
			table.insert(modify, {path=aclPath, param= {Control=POST["aclControl"]}, flags="KEYPATH"})
			setMBUS(modify)
			if POST["aclControl"]=="disabled" then
				macRestrictionDeleteAll(aclMacPath)
			end
		end
		
		
		
		if POST["aclControl"]=="unlock" then
			for i=1,tonumber(POST["macNum"]) do
				local resultACL = false
				if POST["delMac"..i]=="ON" then
					resultACL = macRestrictionDelete(aclMacPath, POST["mac"..i])
				else
					local isAclMacExistFlag, permission = isAclMacExist(aclMacPath, POST["mac"..i])
					if isAclMacExistFlag == true and permission ~= POST["permission"..i] then
						resultACL = macRestrictionUpdate(aclMacPath, POST["permission"..i], POST["mac"..i])
					end
				end
  
				if resultACL == true then
					cgilua.redirect("resultKO.lp")
					return
				end
			end
		end

		if POST["anySSID"]~=anyssid then				
			modify ={}					
			table.insert(modify, {path=wlanPath, param= {AnySSID=POST["anySSID"]}, flags="KEYPATH"})					
			setMBUS(modify)						
		end

		if POST["ssid"] ~= ssid and POST["ssid"] ~= "" then
			modify = {}
			table.insert(modify, {path = wlanPath, param = {SSID = POST["ssid"]}, flags="KEYPATH"})
			
			setMBUS(modify)
		end

	else
		if POST["wlanState"] ~= wlanState then	
		--	table.insert(modify, {path = wlanPath, param = {Enable="false"}, flags = "KEYPATH"})
		--	setMBUS_IGD(modify)
			modify = {}
			table.insert(modify, {path = "Device.WiFi.Radio."..deviceID, param = {Enable="false"}, datamodel = "second"})
		        setMBUS_IGD(modify)
		                        
		end
	end
end
    saveall(0, 1)
    cgilua.redirect("wlanStatus.lp", { wifiPage = page })
	return

end

local errMsgInvalidWEPKey = "<p>" .. translate([==[Invalid WEP key: use only permitted characters (a-z, A-Z, 0-9) and comply with the length]==]).. "</p>"
local errMsgInvalidWPAKey = "<p>" .. translate([==[Encryption key is invalid: verify that it contains at least one character of each of the following three sets:]==]).." [a-z, A - Z], [0 - 9], [!@#$%^&*()_+-={},./<>?`~[]|;:&#92;], "..translate([==[that does not contain characters or symbols not allowed and respects the minimum and maximum length allowed (12 to 32 characters)]==]).. "</p>"
local aclEmptyMsg = "<p>" .. translate([==[Warning: You must enter at least one valid MAC address]==]) .. "</p>"

local errMsgInvalidMAC = "<p>" .. translate([==[Not valid MAC: only use hexadecimal characters (0-9, a-f) and respect the length of 12 characters]==]).. "</p>"
local errMsgMACExist = "<p>" .. translate([==[Can not add MAC Address which already exists in Authorized Devices list.]==]).. "</p>"
local errMsgMACEnough= "<p>" .. translate([==[Can not add MAC Address. Maximum size of Authorized Devices is 50.]==]).. "</p>"

local errMsgWrongPIN = "<p>" .. translate([==[Wrong PIN! The PIN must have 8 digits]==]).. "</p>"
local errMsgInvalidPIN = "<p>" .. translate([==[Invalid PIN! Enter a different PIN]==]).. "</p>"

local confMsgwifi2 = "<p>" .. translate([==[Warning: After turning off the Wi-Fi interface 2.4 GHz, Wi-Fi connected devices will be disconnected and you can not connect to the modem wirelessly.]==]) .. "</p>"
local confMsgwifi5 = "<p>" .. translate([==[Warning: After turning off the Wi-Fi interface 5 GHz, the Wi-Fi devices connected will be disconnected and you can not connect to the modem wirelessly.]==]) .. "</p>"

local errMsgConfirmChange = "<p>" .. translate([==[Warning: you also want to apply the change to the Wi-Fi 5GHz.]==]) .. "</p>"
if QUERY["id"]=="2" then
	errMsgConfirmChange = "<p>" .. translate([==[Warning: you also want to apply the change to the Wi-Fi 2.4GHz.]==]) .. "</p>"
end
local errMsgLowEncrKey = "<p>" ..translate( [==[Warning: the level of password security is not adequate.]==] ).."</p>"
local warningMsgMediumKeyStrength = "<p>"..translate( [==[Warning: the level of security of the password may not be appropriate]==] ).."</p>"


local low = translate([==[Low]==])
local medium =  translate([==[Medium]==])
local high = translate([==[High]==])

%>

<script language="JavaScript" type="text/javascript">
//<![CDATA[
function changeSecMode(secMode)
{
	if(secMode != "disable"){
		if(secMode=="WEP 128 bit"){			
			document.getElementById("wepKeyEncryption").style.display="block";
			document.getElementById("wpaKeyEncryption").style.display="none";
			document.getElementById("keyStrength").style.display="none";
		}else{
			document.getElementById("wepKeyEncryption").style.display="none";
			document.getElementById("wpaKeyEncryption").style.display="block";
		}
		document.getElementById("keyEncryption").style.display="";
	}else{
		document.getElementById("keyEncryption").style.display="none";
		document.getElementById("keyStrength").style.display="none";
	}
}

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

function asciiToHex(wepKeyVal){
	document.getElementById("wepHex").innerHTML=toHex(wepKeyVal);
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

function addMACACL()
{
  var vh = '0123456789aAbBcCdDeEfF';
  var mac = document.getElementById("aclMAC").value;
  var invalid = 0;
  if((mac=="") || (mac.length != 17)) {
    invalid = 1;
  } else {
    for(var i=0; i < mac.length; i++) {
      if(i%3==2) {
        if(mac.charAt(i) != ':') {
          invalid = 1;
          break;
        }
      }
      else {
        if(vh.indexOf(mac.charAt(i)) < 0) {
          invalid = 1;
          break;
        }
      }
    }
  }
  if(invalid)
  {
    document.getElementById("chiaveKOMsg").innerHTML = "<%=errMsgInvalidMAC%>";
    document.getElementById("wifiConfig").style.display="none";
    document.getElementById("keyConfig").style.display="block";
    return false;
  }
  <%if aclControl=="unlock" then%>
    if (<%=numberOfMAC%> >= 50)
    {
      document.getElementById("chiaveKOMsg").innerHTML = "<%=errMsgMACEnough%>";
      document.getElementById("wifiConfig").style.display="none";
      document.getElementById("keyConfig").style.display="block";
      return false;
    }
    <%for i,v in pairs(aclList[aclMacPath]) do%>
      if(mac == "<%=v.param["MACAddress"]%>")
      {
        document.getElementById("chiaveKOMsg").innerHTML = "<%=errMsgMACExist%>";
        document.getElementById("wifiConfig").style.display="none";
        document.getElementById("keyConfig").style.display="block";
        return false;
      }
    <%end%>
  <%end%>
  document.getElementById("aclSubmitFlag").value = 1;
  document.wlanConfig.submit();
}

function changeACL()
{
  if(document.getElementById("aclControl").value == "disabled")
    document.getElementById("addACL").style.display="none";
  else
    document.getElementById("addACL").style.display="";
}

function confirmConfig(){
	if("<%=wlanState%>"!="true")
	{		
		document.wlanConfig.submit();
		return true;
	}

	var isWlanStateOff = document.getElementById("wlanState2").checked;
	if(isWlanStateOff){
        <% if QUERY["id"]~="2" then %>
        {
          document.getElementById("WlanRadioOffMsg").innerHTML = "<%=confMsgwifi2%>";
          document.getElementById("wifiConfig").style.display="none";
          document.getElementById("confirmOff").style.display="block";
          return false;
        }
        <% else %>
        {
          document.getElementById("WlanRadioOffMsg").innerHTML = "<%=confMsgwifi5%>";
          document.getElementById("wifiConfig").style.display="none";
          document.getElementById("confirmOff").style.display="block";
          return false;
        }
        <% end %>
	}
	
	
	var anySSID = document.getElementById("anySSID").value;
	if(anySSID=="false" && "<%=anyssid%>"!="false"){
		document.getElementById("wifiConfig").style.display="none";
		document.getElementById("wpsConfig").style.display="block";
		return false;
	}
	confirmSSID();
}

function confirmSSID()
{
	document.getElementById("wpsConfig").style.display="none";
	var ssid = document.getElementById("ssid").value;
	if(ssid != "<%=ssid%>"){
		document.getElementById("wifiConfig").style.display="none";
		document.getElementById("ssidConfig").style.display="block";
		return false;
	}
	confirmSecurity();
}


function confirmSecurity()
{
	var retValue = checkAclList();
	if( retValue == false )
	{
		return false;
	}	
	
	document.getElementById("ssidConfig").style.display="none";
	var secMode = document.getElementById("secMode").value;
	if(secMode != "disable")
	{
		if(secMode=="WEP 128 bit")
		{
				<% if QUERY["id"]~="2" then %>
							var wepKey = document.getElementById("wepKey").value;
							if(isEncrWepKey(wepKey)==false) {
								document.getElementById("chiaveKOMsg").innerHTML = "<%=errMsgInvalidWEPKey%>";
								document.getElementById("wifiConfig").style.display="none";
								document.getElementById("keyConfig").style.display="block";
								return false;
							}
				<% end %>
		}
		else
		{
			//if the key is invalid throw M17 error message.
			var wpaKey = document.getElementById("wpaKey").value;
			if( wpaKey.length < 12) {
				document.getElementById("chiaveKOMsg").innerHTML = "<%=errMsgInvalidWPAKey%>";
				document.getElementById("wifiConfig").style.display="none";
				document.getElementById("keyConfig").style.display="block";
				return false;
			}
			//check for key strength.
			
			var wpaKeyStrength  = indicateEncryptionKeyStrength(wpaKey,false);
			//if the encryption key is at strength low throw an error message.
			if( isEncrWpaKey(wpaKey)==false || wpaKeyStrength == 1 ){		
			
				//alert("The wpa key strenth is in low");
				document.getElementById("invalidKeyStrengthMsg").innerHTML = "<%=errMsgInvalidWPAKey%>";
				document.getElementById("wifiConfig").style.display="none";
				document.getElementById("keyStrengthError").style.display="block";
				return false;
			} //if the key strength is meidium thorw a warning and execute further..
			else if ( wpaKeyStrength == 2)
			{
				
				//alert("The wpa key strenth is with medium");
				document.getElementById("wifiConfig").style.display="none";
				document.getElementById("keyStrengthWarning").style.display="block";
				return false;
			}		
		}
	}
	confirmSecurityKeyWarning();
}
	
function confirmSecurityKeyWarning()
{
    document.getElementById("keyStrengthWarning").style.display="none";
	//alert("in confirm security warning");
	var secMode = document.getElementById("secMode").value;
	if(secMode == "disable")
	{
		document.getElementById("wifiConfig").style.display="none";
		document.getElementById("encrOffConfig").style.display="block";			
	}else if(secMode == "WEP 128 bit")
	{		
		<% if QUERY["id"]=="2" then %>
					document.wlanConfig.submit();
		<% else %>
					document.getElementById("wifiConfig").style.display="none";
					document.getElementById("encrWepConfig").style.display="block";
		<% end %>			
	}else
	{			
		//document.getElementById("wifiConfig").style.display="none";
		//document.getElementById("confirmConfig").style.display="block";
		submit_ok();
	}
}

function isDigit(str)
{
  var reg = /^\d{8}$/; 
  return reg.test(str);
}

function pbcSubmit()
{
  document.getElementById("wpsSubmitFlag").value = "2";
  document.wlanConfig.submit();
}

function pinSubmit(){
  var pinVal = document.getElementById("pin").value;
  var pinLen = pinVal.length;
  
  if(pinLen != 8)
  {
    document.getElementById("pinKOMsg").innerHTML = "<%=errMsgWrongPIN%>";
    document.getElementById("wifiConfig").style.display="none";
    document.getElementById("pinConfig").style.display="block";
    return false;
  }
  if(isDigit(pinVal))
  {
    document.getElementById("wpsSubmitFlag").value="1";
    document.wlanConfig.submit();
  }else{
    document.getElementById("pinKOMsg").innerHTML = "<%=errMsgInvalidPIN%>";
    document.getElementById("wifiConfig").style.display="none";
    document.getElementById("pinConfig").style.display="block";
  }
}

function closeConfirm(){
	document.getElementById("wifiConfig").style.display="block";
	document.getElementById("confirmConfig").style.display="none";
	document.getElementById("keyConfig").style.display="none";
	document.getElementById("encrOffConfig").style.display="none";
	document.getElementById("encrWepConfig").style.display="none";
	document.getElementById("pinConfig").style.display="none";
	document.getElementById("confirmOff").style.display="none";
	document.getElementById("wpsConfig").style.display="none";
	document.getElementById("ssidConfig").style.display="none";
	document.getElementById("keyStrengthError").style.display="none";
	document.getElementById("keyStrengthWarning").style.display="none";
	document.getElementById("confirmConfigApplyChangesOtherIntf").style.display="none";
	
	wlanInit();	
	changeSecMode("<%=secMode%>");
}

function submit_ok()
{
	var anyssid = document.getElementById("anySSID").value;
	var ssid = document.getElementById("ssid").value;
	var secMode = document.getElementById("secMode").value;
	var wpaKey = document.getElementById("wpaKey").value;
	var aclControl = document.getElementById("aclControl").value;
	var changeOtherIntf = document.getElementById("changeOtherIntfFlag").value;
	if((anyssid!="<%=anyssid%>" || ssid!="<%=ssid%>" || secMode != "<%=secMode%>" || wpaKey != "<%=wpaKeyEncryption%>" || aclControl != "<%=aclControl%>") && secMode!="WEP 128 bit" && changeOtherIntf=="0")
	{		
		document.getElementById("msgChangeConfirm").innerHTML = "<%=errMsgConfirmChange%>";
		document.getElementById("wifiConfig").style.display="none";
		document.getElementById("encrOffConfig").style.display="none";

		document.getElementById("confirmOff").style.display="none";
		document.getElementById("confirmConfigApplyChangesOtherIntf").style.display="block";
		document.getElementById("changeOtherIntfFlag").value="1";
		document.getElementById("changeNum").value="2";
		return false;
	}
	showConfirmConfig();
}

// introduced this method for fixing CPE_P00106015.
function showConfirmConfig(){
		document.getElementById("wifiConfig").style.display="none";
		document.getElementById("encrOffConfig").style.display="none";
		document.getElementById("encrWepConfig").style.display="none";
		document.getElementById("confirmOff").style.display="none";
		document.getElementById("confirmConfigApplyChangesOtherIntf").style.display="none";
		document.getElementById("confirmConfig").style.display="block";
}

// introduced this method for fixing CPE_P00106015.
function submit_ok_confirm()
{
	document.wlanConfig.submit();
}
function cancel()
{
	if(document.getElementById("changeOtherIntfFlag").value=="1")
	{
		document.getElementById("changeNum").value="1";
		showConfirmConfig();
	}else{		
		document.getElementById("changeOtherIntfFlag").value="0";
		closeConfirm();
	}
	
}


function checkAclList()
{
	if(document.getElementById("aclControl").value != "disabled") 
	{
		<%
		if( aclList ~= nil ) then
			numberOfMAC =  #aclList[aclMacPath]
		end
		%>
		var aclSize=<%=numberOfMAC%>;
		if( aclSize == 0 ) 
		{
			document.getElementById("chiaveKOMsg").innerHTML = "<%=aclEmptyMsg%>";
			document.getElementById("wifiConfig").style.display="none";
			document.getElementById("ssidConfig").style.display="none";
			document.getElementById("keyConfig").style.display="block";
			return false;
		}	
	}	
	return true;
}

var desc = new Array();
	
desc[1] = "<%=low%>";
desc[2] = "<%=medium%>";
desc[3] = "<%=high%>";
	
function indicateEncryptionKeyStrength(password,style)
{
    if( style == true)
	{
		document.getElementById("keyStrength").style.display="block";
	}
	
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
	document.getElementById("encryptionKeyStrengthDesc").innerHTML = desc[score];
	document.getElementById("encryptionKeyStrength").className = "strength" + score;
	return score;
}

//]]>
</script>
</head>
<body>

<!-- <table cellspacing='0' cellpadding='0' width="100%" class="NavBar"> -->

<div class="contentContainer fontSize">
<% if QUERY["id"]=="2" then %>
  <!-- <tr><td align="left"><a href="standard.lp">Standard</a>&nbsp;&nbsp;>&nbsp;&nbsp;<a href="wlanStatus.lp?wifiPage=wifi">Wi-Fi</a> &nbsp;&nbsp;>&nbsp;&nbsp;<a href="wlanConfig.lp?id=2">Configura</a></td><td align="right"><a href="wlanStatus.lp?wifiPage=wifi5">Stato</a>&nbsp;&nbsp;|&nbsp;&nbsp;<em>Configura</em></td></tr> -->
  
	<div class="breadCrumbContainer">
		<ul class="brdCrumb">
			<li><a href="standard.lp"><%=sectionName%></a></li><li>|</li><li><a href="wlanStatus.lp?wifiPage=wifi">Wi-Fi</a></li><li>|</li>
			<li><a href="wlanConfig.lp?id=2">Wi-Fi 5 GHz</a></li>
		</ul></div>
		
		<div class="contentTab" id="content">
			<ol id="tocTab">
				<li><a href="wlanStatus.lp?wifiPage=wifi5" >
					<div class="tab">
					<span class="tabIcon_stwifi5"></span>  
					<span class="contTabTxt">WI-FI 5GH</span><span class="contTabTxt" style="text-transform:lowercase">z</span>
				</div><div class="clrBth"></div></a></li>
				<li><a href="wlanConfig.lp?id=2" class="current margin15">
					<div class="tab">
						<span class="contTabTxt transform"><%=translate([==[Configure]==])%> Wi-Fi 5 GH</span><span class="contTabTxt" style="text-transform:lowercase">z</span>
						</div></a></li>			
			</ol>
		</div>
<% else %>
  <!-- <tr><td align="left"><a href="standard.lp">Standard</a>&nbsp;&nbsp;>&nbsp;&nbsp; <a href="wlanStatus.lp?wifiPage=wifi">Wi-Fi</a> &nbsp;&nbsp;>&nbsp;&nbsp;<a href="wlanConfig.lp">Configura</a></td><td align="right"><a href="wlanStatus.lp?wifiPage=wifi2">Stato</a>&nbsp;&nbsp;|&nbsp;&nbsp;<em>Configura</em></td></tr> -->
  
  <div class="breadCrumbContainer">
		<ul class="brdCrumb">
			<li><a href="standard.lp"><%=sectionName%></a></li><li>|</li><li><a href="wlanStatus.lp?wifiPage=wifi">Wi-Fi</a></li><li>|</li>
			<li><a href="wlanConfig.lp">Wi-Fi 2.4 GHz</a></li>
		</ul></div>
	<div class="contentTab" id="content">
	<ol id="tocTab">
		<li><a href="wlanStatus.lp?wifiPage=wifi2" >
			<div class="tab">
			<span class="tabIcon_stwifi2"></span>  
			<span class="contTabTxt">WI-FI 2.4 GH</span><span class="contTabTxt" style="text-transform:lowercase">z</span>
		</div><div class="clrBth"></div></a></li>
		<li><a href="wlanConfig.lp" class="current margin15">
			<div class="tab">
				<span class="contTabTxt transform"><%=translate([==[Configure]==])%> Wi-Fi 2.4 GH</span><span class="contTabTxt" style="text-transform:lowercase">z</span>
				</div></a></li>			
	</ol>
	</div>
  
<% end %>
<!-- </table> -->

<div id="wifiConfig" class='contentcontainer'>
<div class='contentitem'>
<form method="post" id="wlanConfig" name="wlanConfig" action="">
<input type="hidden" id="aclSubmitFlag" name="aclSubmitFlag" value="0" />
<input type="hidden" id="wpsSubmitFlag" name="wpsSubmitFlag" value="0" />
<input type="hidden" id="changeOtherIntfFlag" name="changeOtherIntfFlag" value="0" />
<input type="hidden" id="wlanPath" name="wlanPath" value="<%=wlanPath%>" />
<input type="hidden" id="changeNum" name="changeNum" value="1" />

<br>
<%
	writePageHeader_new()

	--writeBlockNoTitle()
	writeBlockTitle_Guest(translate([==[Configuration]==]) .. " Wi-Fi " .. name)
	writeBlockRowCtrl_Config(translate([==[Radio Interface]==]),"<input class='inputClass' type='radio' value='true' id='wlanState1' name='wlanState' />&nbsp;"..translate([==[Active]==]).."&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<input type='radio' value='false' id='wlanState2' name='wlanState' />&nbsp;"..translate([==[Not active]==]))

if wlanState~="true" then
	--end of the disable block 
	endBlock()
else
	--Start of the enable block
	writeBlockRowCtrl_Config(translate([==[Wi-Fi network (SSID)]==]), "<select class='inputClass' size='1' id='anySSID' name='anySSID' ><option value='true'>"..translate([==[Visible]==]).."</option><option value='false'>"..translate([==[Hidden]==]).."</option></select>&nbsp;&nbsp;<input class='inputClass' type='text' id='ssid' name='ssid' size='20' maxlength='32' value='.. tostring(ssid) ..' />")

if QUERY["id"]=="2" then
 	writeBlockRowCtrl_Config(translate([==[Radio Channel]==]), "<select class='inputClass' size='1' id='wlanChannel' name='wlanChannel'><option value='Auto'>Automatico</option><option value='36'>36</option><option value='40'>40</option><option value='44'>44</option><option value='48'>48</option></select>")
%>
	  <tr><td style='vertical-align:middle;' class="wifiWarning"  colspan='4' ><font color="#FF0000"><%=translate([==[Warning]==])%></font><%=translate([==[: Manual selection is available a limited number of channels., We recommend using automatic mode for best performance]==])%></td></tr>
<%
else
	writeBlockRowCtrl_Config(translate([==[Radio Channel]==]), "<select class='inputClass' size='1' id='wlanChannel' name='wlanChannel'><option value='Auto'>Automatico</option><option value='1'>1</option><option value='2'>2</option><option value='3'>3</option><option value='4'>4</option><option value='5'>5</option><option value='6'>6</option><option value='7'>7</option><option value='8'>8</option><option value='9'>9</option><option value='10'>10</option><option value='11'>11</option><option value='12'>12</option><option value='13'>13</option></select>")
end

--if secMode == "disable" or secMode == "WPA-PSK AES 256 bit" then
	writeBlockRowCtrl_newConfig(translate([==[Bandwidth (Channel)]==]), "<select class='inputClass' size='1' id='channelWidth' name='channelWidth'><option value='20'>20 MHz</option><option value='20/40'>Auto 20 MHz/40 MHz</option></select>")
--end

local wepOption = "<option value='WEP 128 bit'>WEP (128-bit)</option>"
if QUERY["id"]=="2" then
  wepOption = ""
end
	writeBlockRowCtrl_newConfig(translate([==[Methods of encryption]==]), "<select class='inputClass' size='1' id='secMode' name='secMode'  onchange='changeSecMode(this.value)'><option value='disable'>"..translate([==[disable]==]).."</option>"..wepOption.."<option value='WPA-PSK TKIP 256 bit'>WPA-PSK TKIP 256-bit</option><option value='WPA-PSK AES 256 bit'>WPA-PSK AES 256-bit</option><option value='WPA-PSK TKIP-AES 256 bit'>WPA-PSK TKIP-AES 256-bit</option></select>")	
	
%>
<tr id="keyEncryption" style="display:<%=keyEncryptionStyle%>;"><td class="midarea4-2 verticalAlign"><%=translate([==[Encryption key]==])%>:</td><td colspan='3' class="verticalAlign" style="padding-top:7px;">
			<div id="wepKeyEncryption" style="display:<%=wepKeyStyle%>">
			<table border="0" cellpadding="0" cellspacing="0">
				<tr>			
				<td class="tdBianca_new" style="width:100%;"><input class='inputClass' type="text" id="wepKey" name="wepKey" size="13" maxlength="13" value="" onkeypress="asciiToHex(this.value)" /> [13 caratteri ASCII] </td></tr>

				<tr><td class="tdBianca_new" style="width:100%"><span id="wepHex"></span>&nbsp;[HEX]</td></tr>
			</table></div>
			<div id="wpaKeyEncryption" style="display:<%=wpaKeyStyle%>">
				<table border="0" cellspacing="0" cellpadding="0">
				<tr><td class="tdBianca_new" style="width:100%;">
				<input class="inputClass" type="text" id="wpaKey" name="wpaKey" size="25" maxlength="32" value="<%=wpaKeyEncryption%>" onchange="indicateEncryptionKeyStrength(this.value,true)" onkeyup="indicateEncryptionKeyStrength(this.value,true)"  />
				[12 - 32 <%=translate([==[characters]==])%> ASCII]
				</td></tr>
			</table></div>			
</td></tr>


<tr>	
	<td width='330' class="midarea4-2" style="height:0px"></td>
	<td width='330' colspan='3' class="midarea4-3" style="height:0px">	
		<table border="0" cellspacing="0" cellpadding="0" id="keyStrength" style="display:none">
		<tr>
		<td style="vertical-align:middle;white-space:nowrap" >&nbsp;<%=translate([==[Key strength]==])%>&nbsp;:&nbsp;&nbsp;</td>
		<td>				
			<table>
				<tr>
					<td>
					<div id="encryptionKeyStrengthDesc" value="Low">Low</div>
					</td>
				</tr>
				<tr>
					<td>
					<div id="encryptionKeyStrength" class="strength0"></div>	
					</td>
				</tr>
			</table>
		</td>
		</table>
	</td>	
</tr>

<tr><td class="midarea2 tableTitle" style="font-weight:bold;padding-left:30px" width='250px'><%=translate([==[Access Control]==])%></td></tr>
<%
	-- writeBlockTitle_Guest(translate([==[Access Control]==]))
	writeBlockRowCntrl_Access(translate([==[Access Control: The feature allows you to restrict access to the Wi-Fi network to devices indicated]==]), "<select class='inputClass' size='1' id='aclControl' name='aclControl' onchange='changeACL();'><option value='disabled'>"..translate([==[Disabled]==]).."</option><option value='unlock'>"..translate([==[Enabled]==]).."</option></select>")

	endBlock()
%>
<br/>
<div id="addACL" style="display:none">
<%
	
	writeTableBlockTitle_Authdevices(translate([==[Authorized Devices]==]),40)
	local macNum = 0
	local rowStyle = "oddrow"
	
	if aclControl=="unlock" then
		if #aclList[aclMacPath] > 0 then
			
			writeWifiBlockHeader(3, translate([==[MAC Address]==]), translate([==[Access Management]==]), translate([==[Delete]==]))
	
			for i, v in pairs(aclList[aclMacPath]) do
				local authorized, unauthorized
				local mac=v.param["MACAddress"]
                if v.param["MACAddress"] ~= nil then
                    if v.param["Permission"]=="allow" then
                        authorized = 'checked="checked"'
                        unauthorized = ""
                    else
                        unauthorized = 'checked="checked"'
                        authorized = ""
                    end
                    macNum = macNum+1			
                    if macNum%2==1 then				
                        rowStyle = "oddrow"
                    else 
                        rowStyle = "evenrow"
                    end		

                    writeTableBlockRow(3, rowStyle, tostring(mac .. "<input type='hidden' id='mac".. i .."' name='mac".. i .."' value='"..mac.."'/>"), "<input class='inputClass' type='radio' value='allow' ".. authorized .." name='permission".. i .."' />&nbsp;".. translate([==[Authorized]==]) .."&nbsp;&nbsp;&nbsp;<input class='inputClass' type='radio' value='deny' ".. unauthorized .." name='permission".. i .."' />&nbsp;" .. translate([==[Unauthorized]==]), "<input class='inputClass' type='checkbox' name='delMac".. i .."' value='ON' />")
                end
			end
			--[[
			if rowStyle == "oddrow" then
			rowStyle = "evenrow"
			else
				rowStyle = "oddrow"
			end		
			
			writeTableBlockRowCtrl_wifihidden(3, rowStyle, tostring("<table><tr><td style='width:250px'><input class='inputClass' type='text' id='aclMAC' name='aclMAC' size='17' maxlength='17' value='' />&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td><td style='width:250px'><select class='inputClass' size='1' id='aclOption' name='aclOption'><option value='allow'>"..translate([==[Authorized]==]).."</option><option value='deny' selected='true'>"..translate([==[Unauthorized]==]).."</option></select>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td><td style='width:250px' class='addButton'><a href='#' onclick='addMACACL();'><div class='midarea6-1 secondaryButton' name='thb8'>"..translate([==[Add]==]).."</div></a></td></tr></table>"))
			]]
		end
	end

	if rowStyle == "oddrow" then
		rowStyle = "evenrow"
	else
		rowStyle = "oddrow"
	end
	
	
	writeTableRow_wifihidden(3, rowStyle, tostring("<table><tr><td style='width:250px;padding-left:0px;'><input class='inputClass' type='text' id='aclMAC' name='aclMAC' size='17' maxlength='17' value='' />&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td><td style='width:250px'><select class='inputClass' size='1' id='aclOption' name='aclOption' ><option value='allow'>"..translate([==[Authorized]==]).."</option><option value='deny' selected='true'>"..translate([==[Unauthorized]==]).."</option></select>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td><td style='width:250px' class='addButton'><a href='#' onclick='addMACACL();'><div class='midarea6-1 secondaryButton' name='thb8'>"..translate([==[Add]==]).."</div></a></td></tr></table>"))


	endBlock()
%>
<input type='hidden' id='macNum' name='macNum' value='<%=macNum%>'/>
</div>

<div id="wpsRegistration" style="display:<%=wpsRegistrationStyle%>">
	<% writeBlockTitle_GuestConnect(translate([==[Connect a new host with WPS button]==])) %>
	<tr><td colspan='4' class="wifiMidareaNoHeight4-2" style="padding-left:30px;padding-top:0px"><span>[<%=translate([==[Mode only available with WPA-PSK]==])%>]</span></td></tr>
	
		<tr>
			<td style='vertical-align:middle;padding-top:0px;' class="wifiMidarea4-2"><%=translate([==[Enable WPS process]==])%>:</td>
			<td style='vertical-align:middle;padding-top:0px;' colspan='3'>
				<a style='color:black' href='#' onclick='pbcSubmit()'><div class='midarea6-1 secondaryButton' name="thb5"><%=translate([==[Run]==])%></div></a>
			</td>
		</tr>
		<tr><td  colspan='4'>&nbsp;</td></tr>
	<% endBlock() %>
	<% writeBlockTitle_GuestConnect(translate([==[Connect a new host with the PIN]==])) %>
	<tr><td colspan='4' class="wifiMidareaNoHeight4-2" style="padding-left:30px;padding-top:0px"><span>[<%=translate([==[Mode only available with WPA-PSK]==])%>]</span> </td></tr>
	
	<tr>
		<td style='vertical-align:top;padding-left:30px;padding-top:15px' class="wifiMidarea4-2"><%=translate([==[Client PIN]==])%>:
      			<input type="text" id="pin" name="pin" size="8" maxlength="8" class="inputClass" />
      			<div><span id="pinDesc">[<%=translate([==[Only numeric characters]==])%>]</span></div>
		</td>
		<td style='vertical-align:middle;padding-left:0px;padding-top:15px'>
			<a href='#' onclick='pinSubmit()'><div class='midarea6-1 secondaryButton' name="thb5"><%=translate([==[Run]==])%></div></a>
    	</td>
  	</tr>
	
	<!--
	<tr>
		<td style='vertical-align:top;padding-left:30px' class="clientPin"><%=translate([==[Client PIN]==])%>:</td>
  		<td style='vertical-align:top' colspan='3' class="midarea4-3">
      			<input type="text" id="pin" name="pin" size="8" maxlength="8" />&nbsp;&nbsp;
      			<span id="pinDesc">[<%=translate([==[Only numeric characters]==])%>]</span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				</td><td><a href='#' onclick='pinSubmit()'><div class='midarea6-1 secondaryButton' name="thb5"><%=translate([==[Run]==])%></div></a>
    		</td>
  	</tr> -->
	<% endBlock() %>
</div>

<%end%>
<!-- end of the enable block-->
<br/><br/>
<table cellspacing='0' cellpadding='0' width='100%' style="text-align:center">

<tr><td style="text-align:left;">
<table cellspacing='0' cellpadding='0'><tr>
	<td style='padding-left:280px'>
	
		<a style='color:black' href='#' onclick='confirmConfig()'><div class='midarea6-1 mainButton' name="thb6"><%=translate([==[Save]==])%></div></a></td>
	<td style='padding-left:50px'><a style='color:black' onclick='javascript: document.location.href="wlanStatus.lp?wifiPage=<%=page%>";'><div class='midarea6-1 mainButton' name="thb7"><%=translate([==[Cancel]==])%></div></a></td>
		<!-- <input type="button" class="button" onclick='confirmConfig()' value="<%=translate([==[Save]==])%>" name="thb6" />&nbsp;&nbsp;&nbsp;&nbsp;
		<input type="button" class="button" onclick='javascript: document.location.href="wlanStatus.lp?wifiPage=<%=page%>";' value="<%=translate([==[Cancel]==])%>" name="thb7" /> -->                	
	
</tr></table>
</td></tr>
</table>
<%
endPage()
%>
</form>
</div>
</div>

<div id="confirmConfig" style="display:none">
<%cgilua.lp.include("webparts/confirmWlan.lp")%>
</div>

<div id="confirmConfigApplyChangesOtherIntf" style="display:none">
<%cgilua.lp.include("webparts/wlanConfirmChangeOnOtherIntf.lp")%>
</div>

<div id="keyConfig" style="display:none">
<%cgilua.lp.include("webparts/chiaveKO.lp")%>
</div>
<div id="pinConfig" style="display:none">
<%cgilua.lp.include("webparts/pinKO.lp")%>
</div>
<div id="encrOffConfig" style="display:none">
<%cgilua.lp.include("webparts/WlanEncrOff.lp")%>
</div>
<div id="encrWepConfig" style="display:none">
<%cgilua.lp.include("webparts/WlanEncrWEP.lp")%>
</div>	
<div id="confirmOff" style="display:none">
<%cgilua.lp.include("webparts/WlanRadioOff.lp")%>
</div>
<div id="wpsConfig" style="display:none">
<%cgilua.lp.include("webparts/WPS_warning.lp")%>
</div>
<div id="keyStrengthError" style="display:none">
<%cgilua.lp.include("webparts/keyStrengthKO.lp")%>
</div>

<div id="keyStrengthWarning" style="display:none">
<%cgilua.lp.include("webparts/wpaKeyStrengthWarning.lp")%>
</div>

<div id="ssidConfig" style="display:none">
  <div class='contentcontainer'>
  <div class='contentitem'>
  <table cellspacing='0' cellpadding='0' width='100%' class="width790 marleft5 martop5">
                  <tr>
                    <td class="verticalAlign padleft35">
                      <div class="width50 fleft"><img src='images/warn__xl.png' alt='Technicolor Gateway'></div>
					  <div class="errInfo"><%=translate([==[Info]==])%></div>
                    </td>
                  </tr>
                  <tr>
                    <td class="verticalAlign">
                      <table width='100%' cellspacing='0' cellpadding='0' class="PageMessage" style="text-align:left">
                        <tr>
                          <td class="errorMessage"><%=translate([==[Warning]==])%>.</td></tr>
            <tr><td class="errorDesc">
            <% if QUERY["id"]=="2" then %>
              <p><%=translate([==[Warning: the SSID for the Wi-Fi at 5 GHz will be changed. And 'advisable to maintain the same SSID for both identifcativo Wi-Fi at 2.4 GHz and 5 GHz, unless special needs. proceed?]==])%></p>
            <% else %>
              <p><%=translate([==[Warning: the SSID for the Wi-Fi at 2.4 GHz will be changed. And 'advisable to maintain the same SSID for both identifcativo Wi-Fi at 2.4 GHz and 5 GHz, unless special needs. proceed?]==])%></p>
            <% end %>
              <br/>
                 </td></tr></table>
                   </td></tr>
                   <tr><td>
                      <table  cellspacing='0' cellpadding='0' class="fontSize padtop10 width790">
                         <tr><td class="verticalAlign fright">
                            <a class="fright" style='color:black' onclick='confirmSecurity()' href="#" ><div class='midarea6-1 mainButton' name="thb11"><%=translate([==[Next]==])%></div></a></td>
			<td  class="verticalAlign" style="padding-left:15px;">
				   <a style='color:black' onclick="closeConfirm()" href="#" ><div class='midarea6-1 mainButton' name="thb12"><%=translate([==[Cancel]==])%></div></a>
             
            </td></tr></table>
        </td></tr></table>
  </div>
  </div>
</div>

<script src="js/antiCSRF.js" type="text/javascript"></script>
<script language="javascript" type="text/javascript">
function wlanInit()
{
var wlanState = "<%=wlanState%>";

if(wlanState=="true"){
	document.getElementById("wlanState1").checked = true;
}else{
	document.getElementById("wlanState2").checked = true;
	return true;
}

var wlanChannel = "<%=wlanChannel%>";
var channelMode = "<%=channelMode%>";
if(channelMode=="Auto")
{
	document.getElementById("wlanChannel").value = "Auto";
}else{
	document.getElementById("wlanChannel").value = wlanChannel;
}

var secMode = "<%=secMode%>";
document.getElementById("secMode").value = secMode;
var wepKey = "<%=wepKeyEncryption%>";
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

document.getElementById("wepKey").value=wepKeyAscii;
document.getElementById("wepHex").innerHTML=wepKeyHex;

var aclControl = "<%=aclControl%>";
document.getElementById("aclControl").value = aclControl;
changeACL();

var anyssid = "<%=anyssid%>";
document.getElementById("anySSID").value = anyssid;
document.getElementById("ssid").value = "<%=ssid%>";


var cwidth = "<%=result.channelwidth%>";
//alert(cwidth);

if( cwidth == "20" )
{
	
	document.getElementById("channelWidth").options[0].selected = true;
}else
{
	document.getElementById("channelWidth").options[1].selected = true;
}

}

wlanInit();
</script>
</div>
</body>
</html>
