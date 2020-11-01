<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
<title>Modem Telecom Italia</title>
<!-- <link rel="stylesheet" href="css/style.css" type="text/css" /> -->
<link rel="stylesheet" href="css/master.css" type="text/css" />

<%
cgilua.lp.include("lp/wlan.lp")
cgilua.lp.include("lp/util.lp")
cgilua.lp.include("lp/mbus_util.lp")
cgilua.lp.include("lp/style.lp")
cgilua.lp.include("lp/device.lp")
cgilua.lp.include("lp/wlanGuestUtil.lp")
cgilua.lp.include("lp/portmap.lp")
cgilua.lp.include("lp/common.lp")


local translate = translate
local POST = cgilua.POST
local tprint = require("tableprint")

local tempreply, temperror = mbus.getParameters{ path = "TI_STORE.TiUserIntf", param = "PasswordRequired"}
local isPasswordRequired = tempreply["TI_STORE.TiUserIntf"][1].param["PasswordRequired"]

if( cgilua.QUERY["display"] == nil or cgilua.QUERY["display"] ~= "fromStartup" )	then
    --normal launch
	
	local isDontShowChecked = ""
	
	local reply, error = mbus.getParameters{ path = "ENV", param = "Value", filter = "(== Name ".. "isDontShowChecked" ..")" }
	
	if reply["ENV"][1]~=nil and reply["ENV"][1].param~=nil then
		isDontShowChecked = reply["ENV"][1].param["Value"]
	end
	
	if( isPasswordRequired == "false" and(  isDontShowChecked == "" or isDontShowChecked ~= "true" ) ) then
	cgilua.redirect("startupConfig.lp?fromPage=wlanGuestConfig")
	return
	end
end
local wifi2Index = 1
local wifi2GuestIndex = 2
local wifi5GuestIndex = 4

local wifiGuestIndexList = {wifi2GuestIndex,wifi5GuestIndex}

local result = {}
local wlanInfo = {}

local wifi2GuestPath = "WLAN.Intf.wl_ssid1_local0"  
local wifi5GuestPath = "WLAN.Intf.wle_radio1_ssid1"  

local accessPoint3Path = "Device.WiFi.AccessPoint.3"	
local accessPoint4Path = "Device.WiFi.AccessPoint.4"

local aclMacPath = wifi2GuestPath .. ".ACL.MAC"
local result=getWlanMain(wifi2GuestPath)

local ssid = result.ssid
local anyssid = result.anyssid
local wlanState = getGuestStatus()
local frequency = getWifiFrequency()
local disconnectTime = getDisconnectTimeForConfig()



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


local adminState = result.adminState
local aclControl = result.control
local pageDisplay = false
local aclList, error
local aclListGuest5, error2
local numberOfMAC = 0
local aclMacPathGuest5 = wifi5GuestPath .. ".ACL.MAC"


if aclControl=="unlock" then
    aclList, error = mbus.getParameters{ path=aclMacPath, param={"MACAddress", "Permission"} ,flags="KEYPATH"}
	aclListGuest5, error2 = mbus.getParameters{ path=aclMacPathGuest5, param={"MACAddress", "Permission"},flags="KEYPATH" }
	aclList = getMergedList(aclList,aclListGuest5)
    numberOfMAC =  #aclList[aclMacPath]
end


--local function
function addACL(aclSubmitFlag,wlanPath,tempAclMacPath,aclMAC,aclOption)
	local aclList,error
	local modify = {}
	
	if aclControl=="disabled" then
		table.insert(modify, {path=wlanPath..".ACL", param= {Control="unlock"}, flags="KEYPATH"})		
		aclList, error = mbus.getParameters{ path=tempAclMacPath, param={"MACAddress", "Permission"} ,flags="KEYPATH"}
		numberOfMAC =  #aclList[tempAclMacPath]
	end

	if numberOfMAC >= 50 then
		if aclSubmitFlag == "1" then
			cgilua.redirect("resultKO.lp?pageDisplay=enough")
		end
		return false
	else
		local isAclMacExistFlag = isAclMacExist(tempAclMacPath, aclMAC)
		if isAclMacExistFlag == true  then
			if aclSubmitFlag == "1"  then
				cgilua.redirect("resultKO.lp?pageDisplay=exist")
				return false
			else
				return true
			end
		end
	end

	local aclAddErr = macRestrictionCreate(tempAclMacPath, aclOption, aclMAC)
	if aclAddErr ~= false then 
		cgilua.redirect("resultKO.lp")
		return false
	end
	setMBUS(modify)
	return true
end


if cgilua.servervariable"REQUEST_METHOD" == "POST" then
	
	local modify = {}
		
	local tempAclMacPath
	local wlanPath
	local time,val_time,val_env
	local env_time = "Wlan_Time"
        local WIntfPath		
	if POST["aclSubmitFlag"]=="1" then
	
		for itr = 1, #wifiGuestIndexList do
			i = wifiGuestIndexList[itr]
			if i==1 then
			        WIntfPath ="WLAN.Intf.wlif1"
			elseif i==2 then
			        WIntfPath="WLAN.Intf.wl_ssid1_local0"
			elseif i==3 then
			        WIntfPath="WLAN.Intf.wle_radio1_ssid0"
			elseif i==4 then
			        WIntfPath="WLAN.Intf.wle_radio1_ssid1"
			end

			--wlanPath = "WLAN.Intf."..i
			tempAclMacPath = WIntfPath .. ".ACL.MAC"
			local retval = addACL(POST["aclSubmitFlag"],WIntfPath,tempAclMacPath,POST["aclMAC"],POST["aclOption"] )
			if retval == false then
				return
			end			
		end
				
		saveall(0, 1)		
		cgilua.redirect("save_alert.lp", { u = "wlanGuestStatus.lp" })
		return
    end
	

	--setting frequency value
	local selectedFreq = POST["frequency"]
		
	-- enable/disable the guest status based on the frequency set  in previous statement
	if POST["wlanState"] == "enabled" then
		enableGuestStateWithFreq(selectedFreq)
		if( wlanState ~= true ) then
		        -- fix for CPE_P00118328, use Time.SystemUpTime instead of os.time for countdown timer calculations
			local currentTime = 0
			local reply1,error1 = mbus.getParameters{path = "Time",param = "SystemUpTime"}
			if reply1["Time"][1] ~= nil and reply1["Time"][1].param ~= nil and reply1["Time"][1].param["SystemUpTime"] ~= nil then
				currentTime = tonumber( reply1["Time"][1].param["SystemUpTime"] )
			end
			local reply,error = mbus.getParameters{path ="ENV",param = "Value",filter = "(== Name "..env_time..")"}
			mbus.modify(	
				function()
					if reply["ENV"][1] ~= nil and reply["ENV"][1].param ~= nil and reply["ENV"][1].param["Value"] ~= "" then
						mbus.setParameters{path = "ENV.Wlan_Time" , param = {Value = tostring(currentTime)},flags = "KEYPATH"}
					else
						mbus.addObjects{ path = "ENV",param = {Name = "Wlan_Time",Value = tostring(currentTime)},flags = "KEYPATH"}
					end
				end)	
		else
		--if previous staue is also enabled..
			cgilua.redirect("save_alert.lp", { u = "wlanGuestStatus.lp" })
			return
		end		
	elseif  POST["wlanState"] == "disabled" then
		disableGuestAccess()
		saveall(0, 1)
		cgilua.redirect("save_alert.lp", { u = "wlanGuestStatus.lp" })
		return
	end
	
	--setting disconnect value
	
	if (POST["disconnectTime"] ~= nil ) then
		
		setDisconnectTime(POST["disconnectTime"])
		-- fix for CPE_P00118328, use Time.SystemUpTime instead of os.time for countdown timer calculations
		local currentTime = 0
		local reply1,error1 = mbus.getParameters{path = "Time",param = "SystemUpTime"}
		if reply1["Time"][1] ~= nil and reply1["Time"][1].param ~= nil and reply1["Time"][1].param["SystemUpTime"] ~= nil then
			currentTime = tonumber( reply1["Time"][1].param["SystemUpTime"] )
		end
		local reply,error = mbus.getParameters{path ="ENV",param = "Value",filter = "(== Name "..env_time..")"}
		local modreply,moderror = mbus.modify(	
			function()
				if reply["ENV"][1] ~= nil and reply["ENV"][1].param ~= nil and reply["ENV"][1].param["Value"] ~= "" then
					mbus.setParameters{path = "ENV.Wlan_Time" , param = {Value = tostring(currentTime)},flags = "KEYPATH"}
				else
				    mbus.addObjects{ path = "ENV",param = {Name = "Wlan_Time",Value = tostring(currentTime)},flags = "KEYPATH"}
				end
			end)
	end
	
	if POST["anySSID"]~=anyssid then				
		setAnySSID(POST["anySSID"])					
	end

	if POST["ssid"] ~= ssid and POST["ssid"] ~= "" then
		setSSID(POST["ssid"])		
	end
	
	if POST["secMode"]~=secMode or POST["wepKey"]~=wepKeyEncryption or POST["wpaKey"]~=wpaKeyEncryption then
		setSecurityMode(POST["secMode"],POST["wepKey"], POST["wpaKey"] )
	end
	
	if POST["aclControl"]~=aclControl then 
		
		for itr = 1, #wifiGuestIndexList do
			i = wifiGuestIndexList[itr]
			modify ={}	
			if i==1 then
			   WIntfPath ="WLAN.Intf.wlif1"
			elseif i==2 then
			   WIntfPath="WLAN.Intf.wl_ssid1_local0"
			elseif i==3 then
			   WIntfPath="WLAN.Intf.wle_radio1_ssid0"
			elseif i==4 then
			   WIntfPath="WLAN.Intf.wle_radio1_ssid1"
			end

			--wlanPath = "WLAN.Intf."..i
			aclPath = WIntfPath .. ".ACL"
			tempAclMacPath = WIntfPath .. ".ACL.MAC"
			
			table.insert(modify, {path=aclPath, param= {Control=POST["aclControl"]}, flags="KEYPATH"})
			setMBUS(modify)
			if POST["aclControl"]=="disabled" then
			macRestrictionDeleteAll(tempAclMacPath)
			end	
		end
	end
		
	if POST["aclControl"]=="unlock" then
		for itr = 1, #wifiGuestIndexList do
			i = wifiGuestIndexList[itr]
			if i==1 then
			   WIntfPath ="WLAN.Intf.wlif1"
			elseif i==2 then
			   WIntfPath="WLAN.Intf.wl_ssid1_local0"
			elseif i==3 then
			   WIntfPath="WLAN.Intf.wle_radio1_ssid0"
			elseif i==4 then
			   WIntfPath="WLAN.Intf.wle_radio1_ssid1"
			end
			--wlanPath = "WLAN.Intf."..i
			tempAclMacPath = WIntfPath .. ".ACL.MAC"
			for i=1,tonumber(POST["macNum"]) do
				local resultACL = false
				if POST["delMac"..i]=="ON" then
					resultACL = macRestrictionDelete(tempAclMacPath, POST["mac"..i])
				else
					local isAclMacExistFlag, permission = isAclMacExist(tempAclMacPath, POST["mac"..i])
					if isAclMacExistFlag == true and permission ~= POST["permission"..i] then
						resultACL = macRestrictionUpdate(tempAclMacPath, POST["permission"..i], POST["mac"..i])
					else
						addACL("false",WIntfPath,tempAclMacPath,POST["mac"..i],POST["permission"..i])
					end
				end

				if resultACL == true then
					cgilua.redirect("resultKO.lp")
					return
				end
			end
		end
	end

	saveall(0, 1)
	cgilua.redirect("save_alert.lp", { u = "wlanGuestStatus.lp" })
	
end


--temp var
local n=1


local errMsgOff1 = "<p>" .. translate([==[The Wi-Fi at 2.4 GHz is turned off. Wi-Fi will be detected only at 5 GHz networks.]==]).. "</p>"
local errMsgOff2 = "<p>" .. translate([==[The Wi-Fi at 5 GHz is turned off. Wi-Fi will be detected only at 2.4 GHz networks.]==]).. "</p>"

local wifistatus = "disabled"
local errMsgInvalidMAC = "<p>" .. translate([==[Device not valid: only use hexadecimal characters (0-9, a-f) and respect the length of 12 characters]==]).. "</p>"
local errMsgMACExist = "<p>" .. translate([==[Can not add MAC Address which already exists in Authorized Devices list.]==]).. "</p>"
local errMsgMACEnough= "<p>" .. translate([==[Can not add MAC Addressr. Maximum size of Authorized Devices is 50.]==]).. "</p>"

local guestStateEnableWarningMsg = "<p>" .. translate([==[Warning : Enabling Wi-Fi Guests will cause the automatic switching of radio interfaces Wi-Fi match, if not already active]==]).. "</p>"
local guestStateDisableWarningMsg = "<p>" .. translate([==[Warning : After disabling Wi-Fi guests,the Wi-Fi guest users will be disconnected. interfaces Wi-Fi radio will remain active for the Wi-Fi key]==]).. "</p>"

local errMsgInvalidWEPKey = "<p>" .. translate([==[Invalid WEP key: use only permitted characters (a-z, A-Z, 0-9) and comply with the length]==]).. "</p>"
local errMsgInvalidWPAKey = "<p>" .. translate([==[Encryption key is invalid: verify that it contains at least one character of each of the following three sets:]==]).." [a-z, A - Z], [0 - 9], [!@#$%^&*()_+-={},./<>?`~[]|;:&#92;], "..translate([==[that does not contain characters or symbols not allowed and respects the minimum and maximum length allowed (12 to 32 characters)]==]).. "</p>"
local aclEmptyMsg = "<p>" .. translate([==[Warning: You must enter at least one valid MAC address]==]) .. "</p>"
local errMsgLowEncrKey = "<p>" ..translate( [==[Warning: the level of password security is not adequate.]==] ).."</p>"

local wepNotAllowedMsg = "<p>" .. translate([==[Warning: WEP mode is not applicable to the 5 GHz network]==]) .. "</p>"
local encrOffMessage = "<p>" .. translate([==[Warning: Disabling Wi-Fi encryption can connect unwanted devices. Proceed?]==]) .. "</p>"


local low = translate([==[Low]==])
local medium =  translate([==[Medium]==])
local high = translate([==[High]==])

--To get the random key from /dev/random
local wepKeyPwd = getRandomKey(13)
local wpaKeyPwd = getRandomKey(24)
local wpaKeyPwdBak = getRandomKey(24)

%>
<script language="JavaScript" type="text/javascript">
var isGuestToBeDisabled = false;
var currentState = "<%=wlanState%>"
function confimConfig()
{
	isGuestToBeDisabled = document.getElementById("wlanState2").checked;
	if( isGuestToBeDisabled == true )
	{
		document.getElementById("WlanGuestStateWarningMsg").innerHTML = "<%=guestStateDisableWarningMsg%>";		
		document.getElementById("wifiConfig").style.display="none";
		document.getElementById("guestStateWarning").style.display="block";
		return true;
	}
	else
	{
		
		if(currentState == "true")
		{
			isAccessPasswordSet();
			return true;
		}
	}
	
	
	var retValue = checkAclList();
	if( retValue == true )
	{
		confirmSecurity();		
	}	
}


function confirmSecurity()
{	
	var secMode = document.getElementById("secMode").value;
	var frequency = document.getElementById("frequency").value;
	if(secMode != "disable")
	{
		if(secMode=="WEP 128 bit")
		{
				if( frequency == "5 GHz" || frequency == "2.4 GHz e 5 GHz" )
				{
					document.getElementById("chiaveKOMsg").innerHTML = "<%=wepNotAllowedMsg%>";
					document.getElementById("wifiConfig").style.display="none";
					document.getElementById("keyConfig").style.display="block";
					return false;
				} else
				{								
					var wepKey = document.getElementById("wepKey").value;
					if(isEncrWepKey(wepKey)==false) {
						document.getElementById("chiaveKOMsg").innerHTML = "<%=errMsgInvalidWEPKey%>";
						document.getElementById("wifiConfig").style.display="none";
						document.getElementById("keyConfig").style.display="block";
						return false;
					}
				}
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
			if( wpaKeyStrength == 1  ){		
			
				//alert("The wpa key strenth is in low");
				document.getElementById("invalidKeyStrengthMsg").innerHTML = "<%=errMsgInvalidWPAKey%>";
				document.getElementById("wifiConfig").style.display="none";
				document.getElementById("keyStrengthError").style.display="block";
				return false;
			} //if the key strength is meidium thorw a warning and execute further..
			else if ( wpaKeyStrength == 2 )
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

function  confirmSecurityKeyWarning()
{
	document.getElementById("keyStrengthWarning").style.display="none";
	isAccessPasswordSet();

}

function isAccessPasswordSet()
{
	<%if( isPasswordRequired == "false" ) then%>
		document.getElementById("wifiConfig").style.display="none";
		document.getElementById("accessPasswordWarning").style.display="block";
		return false;	
	<%end%>	
	checkGuestState();
}
function checkGuestState()
{
	document.getElementById("accessPasswordWarning").style.display="none";
	var guestEnabled = document.getElementById("wlanState1").checked;
	if( guestEnabled == true )
	{
		document.getElementById("WlanGuestStateWarningMsg").innerHTML = "<%=guestStateEnableWarningMsg%>";		
	}
	else
	{
		document.getElementById("WlanGuestStateWarningMsg").innerHTML = "<%=guestStateDisableWarningMsg%>";		
	}
	document.getElementById("wifiConfig").style.display="none";
	document.getElementById("guestStateWarning").style.display="block";
	return true;
}

function confirmGuestStateWarning()
{
	if( (isGuestToBeDisabled == true) || ( isGuestToBeDisabled == false  && currentState == "true"))
	{
		submit_ok_confirm();
		return true;
	}
	document.getElementById("guestStateWarning").style.display="none";
	//alert("in confirm security warning");
	var secMode = document.getElementById("secMode").value;
	if(secMode == "disable")
	{
		document.getElementById("encrOffMessage").innerHTML="<%=encrOffMessage%>";	
		document.getElementById("wifiConfig").style.display="none";
		document.getElementById("encrOffConfig").style.display="block";	
		
	}else if(secMode == "WEP 128 bit")
	{		
		document.getElementById("wifiConfig").style.display="none";
		document.getElementById("encrWepConfig").style.display="block";		
	}
	else{
		submit_ok();
	}
}

//this method is called from other warning files like WlanEncrOff.lp
function submit_ok()
{
	document.getElementById("wifiConfig").style.display="none";
	document.getElementById("encrWepConfig").style.display="none";	
	document.getElementById("encrOffConfig").style.display="none";	
	document.getElementById("confirmConfig").style.display="block";		
}

/* This method is invoked from confirmwlan.
 * CPE_P00106015- introduced this method.
 * To make minimal changes introduced this method instead of updating all other files.
*/
function submit_ok_confirm()
{	
	document.wlanGuestConfig.submit();	
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
			document.getElementById("keyConfig").style.display="block";
			return false;
		}
	}		
	return true;
}


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

var desc = new Array();
desc[1] = "<%=low%>";
desc[2] = "<%=medium%>";
desc[3] = "<%=high%>";

function indicateEncryptionKeyStrength(password,style)
{
	var secMode = document.getElementById("secMode").value;
    if( (style == true) && (secMode != "disable") )
	{
		document.getElementById("keyStrength").style.display="";
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

function changeACL()
{
  if(document.getElementById("aclControl").value == "disabled")
    document.getElementById("addACL").style.display="none";
  else
    document.getElementById("addACL").style.display="";
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
  document.getElementById("macAdd_submit").removeAttribute("href");
  document.getElementById("macAdd_submit").onclick = null;
  document.getElementById("macAdd_submit_con").className = "addMAC_disable";
  document.getElementById("aclSubmitFlag").value = 1;
  document.wlanGuestConfig.submit();
}
//just added to invoke closeconfirm since this method is invoked from confirmwlan.
function cancel()
{
	closeConfirm();
}

function closeConfirm(){
	document.getElementById("wifiConfig").style.display="block";
	document.getElementById("keyConfig").style.display="none";
	document.getElementById("guestStateWarning").style.display="none";
	document.getElementById("keyStrengthError").style.display="none";
	document.getElementById("keyStrengthWarning").style.display="none";
	document.getElementById("encrOffConfig").style.display="none";
	document.getElementById("confirmConfig").style.display="none";
	document.getElementById("encrWepConfig").style.display="none";
	document.getElementById("accessPasswordWarning").style.display="none";
	
	wlanInit();
	var wlanState = "<%=wlanState%>";
	if(wlanState != "true"){	
		changeSecMode("<%=secMode%>");
	}
}
function getRandomString() {
	
	if("<%=wepKeyEncryption%>"=="" && document.getElementById("wepKey").value=="")
	{
		document.getElementById("wepKey").value = "<%=wepKeyPwd%>";
		asciiToHex("<%=wepKeyPwd%>");
	}	

	if("<%=wpaKeyEncryption%>"=="" && document.getElementById("wpaKey").value=="")
	{
		var wpaKeyStr = "<%=wpaKeyPwd%>";
		var level = indicateEncryptionKeyStrength(wpaKeyStr, true);
		if(level<3)
		{
			wpaKeyStr = "<%=wpaKeyPwdBak%>";
			indicateEncryptionKeyStrength(wpaKeyStr, true);
		}
		document.getElementById("wpaKey").value = wpaKeyStr;    
	}
}
</script>
</head>
<body>

<div class="contentContainer">
	 
		<div class="breadCrumbContainer" style="width:90%">
			<ul class="brdCrumb">
				<li><a href="standard.lp"><%=translate([==[Basic Settings]==])%></a></li><li>|</li>
				<li><a href="wlanStatus.lp?wifiPage=wifi">Wi-Fi</a></li><li>|</li>
				<li><a href="wlanGuestConfig.lp"><%=translate([==[Wi-Fi Guests]==])%></a></li>
			</ul>
		</div>	

		<div class="contentTab" id="content">
			<ol id="tocTab">
				<li><a href="wlanGuestStatus.lp" >
			<div class="tab">
				<span class="tabIcon_stwifi"></span>  
				<span class="contTabTxt"><%=translate([==[Wi-Fi Guests]==])%></span>
			</div>
			<div class="clrBth"></div></a></li>
			<li><a href="wlanGuestConfig.lp" class="current margin15">
			<div class="tab">
				<span class="contTabTxt"><%=translate([==[Configure Wi-Fi Guests]==])%></span></div></a></li>	
			</ol>
		</div>

<div  id="wifiConfig" class='contentcontainer'>
<div class='contentitem fontSize'>
<form method="post" id="wlanGuestConfig" name="wlanGuestConfig" action="">
<!--aclSubmit flag is used -->
<input type="hidden" id="aclSubmitFlag" name="aclSubmitFlag" value="0" />

<input type="hidden" id="changeOtherIntfFlag" name="changeOtherIntfFlag" value="0" />


<%
		writePageHeader_new()
		
		--writeBlockNoTitle()		

		writeBlockTitle_Guest(translate([==[Wi-Fi Guests Configuration]==]))
		
		if wlanState == true then
			writeTableRow_Guest(translate([==[Configure Wi-Fi Guests]==]), "<input type='radio' value='enabled' id='wlanState1' name='wlanState' />&nbsp;"..translate([==[Actived]==]).."&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<input type='radio' value='disabled' id='wlanState2' name='wlanState' />&nbsp;"..translate([==[Inactived]==]))
			endBlock()
		else
			writeBlockRow_Guest1(translate([==[Wi-Fi Network]==]) .. " (SSID)", "<select size='1' id='anySSID' name='anySSID' class='inputClass' ><option value='true'>"..translate([==[Visible]==]).."</option><option value='false'>"..translate([==[Hidden]==]).."</option></select>&nbsp;&nbsp;<input type='text' id='ssid' name='ssid' size='20'  class='inputClass' maxlength='32' value='.. tostring(ssid) ..' />")
			
			writeBlockRow_Guest1(translate([==[Configure Wi-Fi Guests]==]), "<input type='radio' value='enabled' id='wlanState1' name='wlanState' onclick='getRandomString()'/>&nbsp;"..translate([==[Actived]==]).."&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<input type='radio' value='disabled' id='wlanState2' name='wlanState' />&nbsp;"..translate([==[Inactived]==]))

			writeBlockRow_Guest1(translate([==[Frequency]==]), "<select size='1' id='frequency' name='frequency' class='inputClass'><option value='2.4 GHz'>2.4 GHz</option><option value='5 GHz'>5 GHz</option><option value='2.4 GHz e 5 GHz'>2.4 GHz e 5 GHz</option></select>")
			
writeBlockRow_Guest1(translate([==[Automatically turn off after]==]), "<select size='1' id='disconnectTime' name='disconnectTime' class='inputClass'><option value='0'>"..translate([==[Never]==]).."</option><option value='1800'>30 "..translate([==[minutes]==]).."</option><option value='3600'>1 "..translate([==[hour]==]).."</option><option value='7200'>2 "..translate([==[hours]==]).."</option><option value='18000'>5 "..translate([==[hours]==]).."</option><option value='86400'>1 "..translate([==[day]==]).."</option></select>")

			local wepOption = "<option value='WEP 128 bit'>WEP (128-bit)</option>"		
			writeBlockRow_Guest1(translate([==[Methods of encryption]==]), "<select size='1' id='secMode' name='secMode' class='inputClass'  onchange='changeSecMode(this.value)'><option value='disable'>"..translate([==[disable]==]).."</option>"..wepOption.."<option value='WPA-PSK TKIP 256 bit'>WPA-PSK TKIP 256-bit</option><option value='WPA-PSK AES 256 bit'>WPA-PSK AES 256-bit</option><option value='WPA-PSK TKIP-AES 256 bit'>WPA-PSK TKIP-AES 256-bit</option></select>")	
				
			%>
			<tr  id="keyEncryption" style="display:<%=keyEncryptionStyle%>;"><td class="midarea4-2"  style="vertical-align: top;"><%=translate([==[Encryption key]==])%>:</td><td class="midarea4-3">
						<div id="wepKeyEncryption" style="display:<%=wepKeyStyle%>">
						<table border="0" cellpadding="0" cellspacing="0">
							<tr>			
							<td class="tdBianca_new" style="width:100%;"><input type="text" id="wepKey" name="wepKey" size="13" maxlength="13" value="" onkeypress="asciiToHex(this.value)" class='inputClass' /> [13 caratteri ASCII] </td></tr>

							<tr><td class="tdBianca_new" style="width:100%"><span id="wepHex"></span>&nbsp;[HEX]</td></tr>
						</table></div>
						<div id="wpaKeyEncryption" style="display:<%=wpaKeyStyle%>">
							<table border="0" cellspacing="0" cellpadding="0">
							<tr><td class="tdBianca_new" style="width:100%;">
							<input type="text" id="wpaKey" name="wpaKey" size="25" maxlength="32" value="<%=wpaKeyEncryption%>" onchange="indicateEncryptionKeyStrength(this.value,true)" onkeyup="indicateEncryptionKeyStrength(this.value,true)" class='inputClass' />
							[12 - 32 <%=translate([==[characters]==])%> ASCII]
							</td></tr>
						</table></div>			
			</td><td>&nbsp;</td></tr>

			<tr id="keyStrength" style="display:none">
			<td class="midarea4-2">&nbsp;</td>
				<td class="midarea4-3 verticalAlign" colspan='2'>	
					<table border="0" cellspacing="0" cellpadding="0" >
					<tr>
					<td style="vertical-align:middle;white-space:nowrap" >&nbsp;<%=translate([==[Key strength]==])%>&nbsp;:&nbsp;&nbsp;</td>
					<td>				
						<table>
							<tr>
								<td>
								<div id="encryptionKeyStrengthDesc" value="Low">Password not entered</div>
								</td>
							</tr>
							<tr>
								<td>
								<div id="encryptionKeyStrength" class="strength0"></div>	
								</td>
							</tr>
						</table>
					</td>
					</tr>
					</table>
				</td>	
			</tr>

			
			<%
			writeBlockRowCntrl_Access(translate([==[Access Control]==])..translate([==[: The feature allows you to restrict access to the Wi-Fi network to devices indicated]==]), "<select size='1' id='aclControl' class='inputClass' name='aclControl' onchange='changeACL();'><option value='disabled'>"..translate([==[Disabled]==]).."</option><option value='unlock'>"..translate([==[Enabled]==]).."</option></select>")

			endBlock()
		%>
		
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

							writeTableBlockRow(3, rowStyle, tostring(mac .. "<input type='hidden' id='mac".. i .."' name='mac".. i .."' value='"..mac.."'/>"), "<input type='radio' value='allow' ".. authorized .." name='permission".. i .."' />&nbsp;".. translate([==[Authorized]==]) .."&nbsp;&nbsp;&nbsp;<input type='radio' value='deny' ".. unauthorized .." name='permission".. i .."' />&nbsp;" .. translate([==[Unauthorized]==]), "<input type='checkbox' name='delMac".. i .."' value='ON' />")
						end
					end
					
				end
			end
			
			if rowStyle == "oddrow" then
				rowStyle = "evenrow"
			else
				rowStyle = "oddrow"
			end
			
			
			writeTableBlockRowCtrl_wifihidden(3, rowStyle, tostring("<table><tr><td style='width:250px;padding-left:0px;'><input type='text' id='aclMAC' class='inputClass' name='aclMAC' size='17' maxlength='17' value='' />&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td><td style='width:250px'><select size='1' id='aclOption' name='aclOption' class='inputClass' ><option value='allow'>"..translate([==[Authorized]==]).."</option><option value='deny' selected='true'>"..translate([==[Unauthorized]==]).."</option></select>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td><td style='width:250px' class='padtop5'><a id='macAdd_submit' href='#' onclick='addMACACL();' class=''><div id='macAdd_submit_con' class='addMAC' name='thb8'>"..translate([==[Add]==]).."</div></a></td></tr></table>"))
			

			endBlock()
		%>
		<input type='hidden' id='macNum' name='macNum' value='<%=macNum%>'/>
		</div>
	
	<%end%>
	<!-- end of disable block -->
	<!-- Message added as CPE_P00106455 -->
	<table>
	<tr><td style='vertical-align:top;height:50px;width:750px;padding-left:34px;' class="midarea4-2" ><%=translate([==[The configuration of parameters for Guest Wi-Fi is only possible when enabling the interface at the same time]==])%></td></tr></table>
	<!-- end of message -->
	<br>
	<table cellspacing='0' cellpadding='0' width='100%' style="text-align:center">
				<tr><td style="text-align:left;">
				<table cellspacing='0' cellpadding='0'><tr>
				<td style='padding-left:250px'>
				<a  onclick='confimConfig()' style='color:black' href='#'>
					<div class='midarea6-1 mainButton' name="thb6" ><%=translate([==[Save]==])%>
					</div></a>
					</td>

					<td style='padding-left:50px'>
						<a style="color:black" onclick='javascript: document.location.href="wlanGuestStatus.lp";'>
							<div class='midarea6-1 mainButton' name="thb7"><%=translate([==[Cancel]==])%></div>
						</a>
					</td>
				</tr>	
	</table>
	</td></tr></table>
	<%	
	endPage()
	%>
	
</form>
</div>
</div>

<div id="guestStateWarning" style="display:none">
<%cgilua.lp.include("webparts/wlanGuestStateWarning.lp")%>
</div>

<div id="keyConfig" style="display:none">
<%cgilua.lp.include("webparts/chiaveKO.lp")%>
</div>

<div id="keyStrengthError" style="display:none">
<%cgilua.lp.include("webparts/keyStrengthKO.lp")%>
</div>

<div id="keyStrengthWarning" style="display:none">
<%cgilua.lp.include("webparts/wpaKeyStrengthWarning.lp")%>
</div>

<div id="encrOffConfig" style="display:none">
<%cgilua.lp.include("webparts/WlanEncrOff.lp")%>
</div>

<div id="encrWepConfig" style="display:none">
<%cgilua.lp.include("webparts/WlanEncrWEP.lp")%>
</div>	
<div id="confirmConfig" style="display:none">
<%cgilua.lp.include("webparts/confirmWlan.lp")%>
</div>

<div id="accessPasswordWarning" style="display:none">
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
                          <td class="errorMessage"><%=translate([==[You are about to make changes]==])%>.</td></tr>
            <tr><td class="errorDesc" id="accessPwdWarningMesg">
			<p><%=translate([==[Warning: Before enabling Wi-Fi Guest it is recommended for safety reasons to set the password for access to the pages of Management Modem.It is must to enter the password each time you access the pages in Management modem.]==])%></p>
		<br/>
                 </td></tr></table>
                   </td></tr>
                   <tr><td>
                      <table  cellspacing='0' cellpadding='0' class="fontSize padtop10 width790">
                         <tr><td class="verticalAlign fright">
                            <a class="fright" href="#" onclick="checkGuestState()"><div class='midarea6-1 mainButton' name="thb11"><%=translate([==[Next]==])%> </div></a></td>
				   <td  class="verticalAlign" style="padding-left:15px;">
				   <a href="#" onclick="closeConfirm()"><div class='midarea6-1 mainButton' name="thb12"><%=translate([==[Cancel]==])%></div></a>               
			</td></tr>
                   </table>
        </td></tr>
		</table>
</div>
</div>
</div>

<script src="js/antiCSRF.js" type="text/javascript"></script>
<script language="javascript" type="text/javascript">
function wlanInit()
{

var wlanState = "<%=wlanState%>";
if(wlanState == "true"){
	document.getElementById("wlanState1").checked = true;
	return true;
}else{	
	document.getElementById("wlanState2").checked = true;
}

var anyssid = "<%=anyssid%>";
document.getElementById("anySSID").value = anyssid;
document.getElementById("ssid").value = "<%=ssid%>";

var frequency = "<%=frequency%>";
if(frequency=="Not applicable")
{
	frequency = "2.4 GHz e 5 GHz"
}
document.getElementById("frequency").value = frequency;

var disconnectTime = "<%=disconnectTime%>";
document.getElementById("disconnectTime").value=disconnectTime;

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


}
wlanInit();


</script>
</div>
</body>
</html>
