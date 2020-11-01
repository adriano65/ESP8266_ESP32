<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
<title>Modem Telecom Italia</title>
<!-- <link rel="stylesheet" href="css/style.css" type="text/css" /> -->
<link rel="stylesheet" href="css/master.css" type="text/css" />
</head>
<%
cgilua.lp.include("lp/wlan.lp")
cgilua.lp.include("lp/util.lp")
cgilua.lp.include("lp/mbus_util.lp")
cgilua.lp.include("lp/style.lp")
cgilua.lp.include("lp/device.lp")
cgilua.lp.include("lp/wlanGuestUtil.lp")
local tprint = require("tableprint")
local translate = translate
local POST = cgilua.POST

local wifi2Index = 1
local wifi2GuestIndex = 2
local wifi5GuestIndex = 4
local wifiIndexList = {wifi2Index,wifi2GuestIndex,wifi5GuestIndex}
local currentTime
local savedTime
local result = {}
local wlanInfo = {}

result[wifi2Index] = getWlanMain("WLAN.Intf.wlif1")
result[wifi2GuestIndex] = getWlanMain("WLAN.Intf.wl_ssid1_local0")
result[wifi5GuestIndex] = getWlanMain("WLAN.Intf.wle_radio1_ssid1")

for itr=1,#wifiIndexList do
	i=wifiIndexList[itr]
	wlanInfo[i] = {}
	if result[i].ssid ~= nil then
		wlanInfo[i].ssid = result[i].ssid .. " (" .. translate([==[Visible]==]) .. ")"
		if result[i].anyssid == "false" then
			wlanInfo[i].ssid = result[i].ssid .. " (" .. translate([==[Hidden]==]) .. ")"
		end
		
		wlanInfo[i].wpaVersion = string.gsub(result[i].wpaversion,"&","-")
		wlanInfo[i].wpaEncryption = result[i].encryption
		if wlanInfo[i].wpaVersion=="WPA" then
			wlanInfo[i].wpaEncryption = "TKIP"
		end
		
		local pos = string.find(wlanInfo[i].wpaEncryption,"&")
		if pos~=nil then
			wlanInfo[i].wpaEncryption = string.gsub(wlanInfo[i].wpaEncryption,"&","-")
		end
	
		wlanInfo[i].wpsRegistrationStyle = "none"
		wlanInfo[i].keyEncryption = ""
		wlanInfo[i].secMode = translate([==[disable]==])
		
		if result[i].secmode=="WEP" then 
			wlanInfo[i].secMode = "WEP (128 bit)"
			if string.len(result[i].wep) == 13 then
				wlanInfo[i].keyEncryption = result[i].wep .. " [ASCII]"
			elseif string.len(result[i].wep) == 26 then
				-- insert a space in 2 hex digit as TI spec require
				wlanInfo[i].keyEncryption = string.gsub(result[i].wep,"%x%x","%0 ", 12) .. " [HEX]"
			end	
		elseif result[i].secmode=="WPA-PSK" then
			wlanInfo[i].secMode = result[i].secmode .. " " .. wlanInfo[i].wpaEncryption .. " 256 bit"
			if string.len(result[i].wpa) == 64 then
				wlanInfo[i].keyEncryption = result[i].wpa .. " [HEX]"
			else
				wlanInfo[i].keyEncryption = result[i].wpa .. " [ASCII]"
			end
			wlanInfo[i].wpsRegistrationStyle = ""
		end
   		if i==1 then
   		    WIntfAclMacPath ="WLAN.Intf.wlif1.ACL.MAC"
   		elseif i==2 then
   		    WIntfAclMacPath="WLAN.Intf.wl_ssid1_local0.ACL.MAC"
   		elseif i==3 then
   		    WIntfAclMacPath="WLAN.Intf.wle_radio1_ssid0.ACL.MAC"
   		elseif i==4 then
   		    WIntfAclMacPath="WLAN.Intf.wle_radio1_ssid1.ACL.MAC"
   		end 
		wlanInfo[i].aclMacPath = WIntfAclMacPath
		wlanInfo[i].aclControl = translate([==[Disabled]==])
		if result[i].control=="unlock" then
			wlanInfo[i].aclControl = translate([==[Enabled]==]) 
		end		
	end
end
	
--temp var
local n=1

local tprint = require("tableprint")
local print = cgilua.print

local errMsgOff1 = "<p>" .. translate([==[The Wi-Fi at 2.4 GHz is turned off. Wi-Fi will be detected only at 5 GHz networks.]==]).. "</p>"
local errMsgOff2 = "<p>" .. translate([==[The Wi-Fi at 5 GHz is turned off. Wi-Fi will be detected only at 2.4 GHz networks.]==]).. "</p>"

local wifistatus = "disabled"

local SSID3Path = "Device.WiFi.SSID.3"
local SSID4Path = "Device.WiFi.SSID.4"

local accessPoint3Path = "Device.WiFi.AccessPoint.3"	
local accessPoint3SecurityPath = "Device.WiFi.AccessPoint.3.Security"
local accessPoint3WPSPath = "Device.WiFi.AccessPoint.3.WPS"

local accessPoint4Path = "Device.WiFi.AccessPoint.4"
local accessPoint4SecurityPath = "Device.WiFi.AccessPoint.4.Security"
local accessPoint4WPSPath = " Device.WiFi.AccessPoint.4.WPS"

local radio1Path = "Device.WiFi.Radio.1"
local radio2Path = "Device.WiFi.Radio.2"
local wifi2GuestPath = "WLAN.Intf.wl_ssid1_local0"  
local wifi5GuestPath = "WLAN.Intf.wle_radio1_ssid1"  
local aclMacPathGuest5 = wifi5GuestPath .. ".ACL.MAC"

--getAccessPointData(accessPoint3Path)

local ap3PointResult, accessPoint3Error = mbus.getParameters{ 	{ path=accessPoint3Path, param={"SSIDAdvertisementEnabled","Enable","X_TELECOMITALIA_IT_DisconnectTime"} },
																{ path = accessPoint3SecurityPath,param={"ModesSupported","ModeEnabled","WEPKey","KeyPassphrase"} },
																{ path = accessPoint3WPSPath, param="Enable" }, datamodel = "second" }

local ap4PointResult, accessPoint4Error = mbus.getParameters{	{ path=accessPoint4Path, param={"SSIDAdvertisementEnabled","Enable","X_TELECOMITALIA_IT_DisconnectTime"}},
																{ path = accessPoint4SecurityPath,param={"ModesSupported","ModeEnabled","WEPKey","KeyPassphrase"}},
																{ path = accessPoint4WPSPath, param="Enable"}, datamodel = "second" }


local tempResult, tempError = mbus.getParameters{ { path=SSID3Path, param="Enable"},
													{ path=SSID4Path, param="Enable"},
													{ path=radio1Path, param="Enable"},
													{ path=radio2Path, param="Enable"}, datamodel = "second" }


wlanInfo[wifi2GuestIndex].apEnabled = ap3PointResult[accessPoint3Path][1].param["Enable"]
wlanInfo[wifi5GuestIndex].apEnabled = ap4PointResult[accessPoint4Path][1].param["Enable"]

wlanInfo[wifi2GuestIndex].ssidEnabled = tempResult[SSID3Path][1].param["Enable"]
wlanInfo[wifi5GuestIndex].ssidEnabled = tempResult[SSID4Path][1].param["Enable"]
wlanInfo[wifi2GuestIndex].radioEnabled = tempResult[radio1Path][1].param["Enable"]
wlanInfo[wifi5GuestIndex].radioEnabled = tempResult[radio2Path][1].param["Enable"]

wlanInfo[wifi2GuestIndex].disconnectTime = ap3PointResult[accessPoint3Path][1].param["X_TELECOMITALIA_IT_DisconnectTime"]

--get guest enabled status
local guestEnabled = getGuestStatus()

--get frequency
local frequency = getWifiFrequency()

--[[calculate time
local reply,error = mbus.getParameters{path = "Time",param = "Time"}
currentTime = reply["Time"][1].param["Time"]
]]

local reply1,error1 = mbus.getParameters{path = "ENV.Wlan_Time",param = "Value",flags = "KEYPATH"}
if reply1["ENV.Wlan_Time"][1] ~= nil and reply1["ENV.Wlan_Time"][1].param ~= nil and reply1["ENV.Wlan_Time"][1].param["Value"] ~= nil then
savedTime = tonumber( reply1["ENV.Wlan_Time"][1].param["Value"] )
end

-- For Time display

local disconnect_time = "00:00:00"

if (wlanInfo[wifi2GuestIndex].disconnectTime == "0") then
	--BHS TESSA 630
	disconnect_time = translate([==[Never]==])
	--CPE_P00110356
	--disconnect_time = "01:00:00"	
elseif (wlanInfo[wifi2GuestIndex].disconnectTime == "1800") then
	disconnect_time = "00:30:00"
elseif (wlanInfo[wifi2GuestIndex].disconnectTime == "3600") then
	disconnect_time = "01:00:00"
elseif (wlanInfo[wifi2GuestIndex].disconnectTime == "7200") then
	disconnect_time = "02:00:00"
elseif (wlanInfo[wifi2GuestIndex].disconnectTime == "18000") then
	disconnect_time = "05:00:00"
elseif (wlanInfo[wifi2GuestIndex].disconnectTime == "86400") then
	disconnect_time = "24:00:00"
end


%>

<body>
<script language="JavaScript" type="text/javascript">
var symbols = " !\"#$%&'()*+,-./0123456789:;<=>?@";
var loAZ = "abcdefghijklmnopqrstuvwxyz";
symbols+= loAZ.toUpperCase();
symbols+= "[\\]^_`";
symbols+= loAZ;
symbols+= "{|}~";


function hour_sec(param) {
var a = param.split(":");
var seconds = (+a[0])*60*60 + (+a[1])*60 + (+a[2]);
return seconds
}
function sectohr(sec) {

var numhours = Math.floor((sec%86400)/3600);
var nummin = Math.floor(((sec%86400)%3600)/60);
var numsec = ((sec%86400)%3600)%60;
if(numhours <= 9)
{
numhours = "0"+numhours;
}
if(nummin <= 9)
{
nummin = "0"+nummin;
}
if(numsec <= 9)
{
numsec = "0"+numsec;
}
return numhours + ":" + nummin + ":" + numsec;
			
}
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
</script>
<div class="contentContainer">
	 
		<div class="breadCrumbContainer" style="width:90%">
			<ul class="brdCrumb">
				<li><a href="standard.lp"><%=translate([==[Basic Settings]==])%></a></li><li>|</li>
				<li><a href="wlanStatus.lp?wifiPage=wifi">Wi-Fi</a></li><li>|</li>
				<li><a href="wlanGuestStatus.lp"><%=translate([==[Wi-Fi Guests]==])%></a></li>
			</ul>
		</div>	

		<div class="contentTab" id="content">
			<ol id="tocTab">
				<li><a href="wlanGuestStatus.lp" class="current">
		<div class="tab">
			<span class="tabIcon_stwifi"></span>  
			<span class="contTabTxt"><%=translate([==[Wi-Fi Guests]==])%></span>
		</div>
		<div class="clrBth"></div></a></li>
		<% if isRemoteAccess() == false then %>
		<li><a class="margin15" href="wlanGuestConfig.lp">
			<div class="tab">
				<span class="contTabTxt"><%=translate([==[Configure Wi-Fi Guests]==])%></span></div></a></li>
		<% end %>	
			</ol>
		</div>

<div class='contentcontainer'>
<div id="wifiStatus">
	<div class='contentitem' class="fontSize">
	<%
		writePageHeader_new()
		--writeBlockNoTitle()
		
		writeBlockRowTitle_Guest(translate([==[Wi-Fi Guests Settings]==]))
			
		writeBlockRow_WifiGuest(translate([==[Wi-Fi Network]==]) .. " (SSID)", wlanInfo[wifi2GuestIndex].ssid)

		
		if( guestEnabled == true ) then
			writeBlockRow_WifiGuest(translate([==[Wi-Fi Guests Status]==]), translate( [==[Actived]==] ) )
		else
			writeBlockRow_WifiGuest(translate([==[Wi-Fi Guests Status]==]), translate( [==[Inactived]==] ) )
		end
		
		writeBlockRow_WifiGuest(translate([==[Frequency]==]), frequency)
%>
	
	<tr><td class="wifiMidarea4-2" style="padding-top:0px;"><%=translate([==[Auto Shut-off between]==])%>:</td><td class="midarea4-3" style="padding-top:0px;" id = 'test'></td><td>&nbsp;</td></tr>

<%		
		writeBlockRow_WifiGuest(translate([==[Methods of encryption]==]), wlanInfo[wifi2GuestIndex].secMode)
		
		if result[wifi2GuestIndex].secmode ~= "disabled" then
	%>
		<tr><td class="wifiMidarea4-2" style="padding-top:0px;"><%=translate([==[Encryption key]==])%>:</td>
		<td class="midarea4-3" colspan='3' style="padding-top:0px;"><%=wlanInfo[wifi2GuestIndex].keyEncryption%>
		<%if result[wifi2GuestIndex].secmode=="WEP" then%>
			<div id="wepHex<%=wifi2GuestIndex%>"></div>		
		<%end%>
		</td>
		</tr>
	<%	
		end
		writeBlockRow_WifiGuest(translate([==[Access Control]==]), wlanInfo[wifi2GuestIndex].aclControl)
		 
		endBlock()	
		endPage()
		
		if result[wifi2GuestIndex].control=="unlock" then
			
			local aclList, error = mbus.getParameters{ path=wlanInfo[wifi2GuestIndex].aclMacPath, param={"MACAddress", "Permission"} ,flags="KEYPATH"}
			local aclListGuest5, error2 = mbus.getParameters{ path=aclMacPathGuest5, param={"MACAddress", "Permission"} ,FLAGS="KEYPATH"}
			aclList = getMergedList(aclList,aclListGuest5)
			if #aclList[wlanInfo[wifi2GuestIndex].aclMacPath] > 0 then
				writeTableBlockTitle_Wifidevices(translate([==[Authorized Devices]==]),40)
%>
  <tr><td colspan='2'><img src='images/spacer.gif' border='0' width='1' height='1' alt=''><br></td></tr>
  <tr><td colspan='2'><img src='images/spacer.gif' border='0' width='1' height='3' alt=''><br></td></tr>
  <tr>
        <td class="macAddTitle tableHd" style="padding-left: 0px;" ><%=translate([==[MAC Address]==])%></td>
        <td class="tableHd" style="padding-left: 0px;"><%=translate([==[Access Management]==])%></td>
  </tr>
  <tr><td colspan='2'><img src='images/spacer.gif' border='0' width='1' height='3' alt=''><br></td></tr>
  <tr><td colspan='2'><img src='images/spacer.gif' border='0' width='1' height='1' alt=''><br></td></tr>

<%				local rowStyle = "oddrow"
				local rowNum = 0
				for i, v in pairs(aclList[wlanInfo[wifi2GuestIndex].aclMacPath]) do
					local str = translate([==[Authorized]==])
					if v.param["Permission"]=="deny" then
						str = translate([==[Unauthorized]==])
					end
					if v.param["MACAddress"] ~= nil then
						rowNum = rowNum + 1
						if rowNum%2==1 then
							rowStyle = "oddrow"
						else
							rowStyle = "evenrow"
						end
						writeTableBlockRow_Guest(2, rowStyle, v.param["MACAddress"], str)
					end
				end
				endBlock()
			end
		end 
	endBlock()
	%>

</div>
<script language="javascript" type="text/javascript">
<%if result[wifi2GuestIndex].secmode=="WEP" then%>
var wepKey = "<%=result[wifi2GuestIndex].wep%>";

if (wepKey.length==13)
  document.getElementById("wepHex<%=wifi2GuestIndex%>").innerHTML=toHex(wepKey)+" [HEX]";


<%end%>
function time_config() {
	var time
	
	<%if ( guestEnabled == true and wlanInfo[wifi2GuestIndex].disconnectTime ~= "0" ) then
	        -- fix for CPE_P00118328, use Time.SystemUpTime instead of os.time for countdown timer calculations
		local CurrTime = 0
	        local reply1,error1 = mbus.getParameters{path = "Time",param = "SystemUpTime"}
	        if reply1["Time"][1] ~= nil and reply1["Time"][1].param ~= nil and reply1["Time"][1].param["SystemUpTime"] ~= nil then
	        	CurrTime = tonumber( reply1["Time"][1].param["SystemUpTime"] )
	        end
	    if savedTime == nil then
	       savedTime = CurrTime
	    end
		local diffTime = CurrTime - savedTime
		local diff = tonumber(wlanInfo[wifi2GuestIndex].disconnectTime)- diffTime
		--local time = translate([==[Never]==])
		local time = "01:00:00"
		if( diff > 0 ) then
			local baseTime = os.time{year=1970, month=1, day=1, hour=0, min=0, sec=0}
			local tt = os.date("*t", baseTime+diff)
			--cgilua.errorlog("diff Time is...")
				if(tt["hour"] <= 9) then					
					tt["hour"] = "0" .. tt["hour"]
				end
				if(tt["min"] <= 9) then					
					tt["min"] = "0" .. tt["min"]
				end
				if(tt["sec"] <= 9) then					
					tt["sec"] = "0" .. tt["sec"]
				end
			time = tt["hour"]..":"..tt["min"]..":"..tt["sec"]
			--cgilua.errorlog(tt["hour"]..":"..tt["min"]..":"..tt["sec"])
		end
	%>
		time = "<%=time%>"
	<%else%>
		time="<%=disconnect_time%>";
	<%end%>
	
	document.getElementById("test").innerHTML = time;
}
time_config();
</script>

</div>
</div>
</div>
</body>
</html>
