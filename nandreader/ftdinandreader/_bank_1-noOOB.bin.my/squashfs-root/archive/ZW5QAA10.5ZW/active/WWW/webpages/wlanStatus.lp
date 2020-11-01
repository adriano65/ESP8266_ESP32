<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
<title>Modem Telecom Italia</title>
<!-- <link rel="stylesheet" href="css/style.css" type="text/css" /> -->
<link rel="stylesheet" href="css/master.css" type="text/css" />
<script type="text/javascript">
function enableWifi()
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
	
}
</script>
</head>
<%
cgilua.lp.include("lp/wlan.lp")
cgilua.lp.include("lp/util.lp")
cgilua.lp.include("lp/mbus_util.lp")
cgilua.lp.include("lp/style.lp")
cgilua.lp.include("lp/device.lp")
cgilua.lp.include("lp/wlanGuestUtil.lp")

local translate = translate
local POST = cgilua.POST

local wifi2Index = 1
local wifi5Index = 3
local wifiIndexList = {wifi2Index,wifi5Index}

--temp var
local n=1

local tprint = require("tableprint")
local print = cgilua.print

if cgilua.servervariable"REQUEST_METHOD" == "POST" then
	local modify = {}

	-- Change WiFi radio state
	local state = "true"
	if POST["wlanState"]=="0" then
		state = "false"
	end
	table.insert(modify, { path="Device.WiFi.Radio.1", param = {Enable = state}, datamodel = "second" })
	table.insert(modify, { path="Device.WiFi.Radio.2", param = {Enable = state}, datamodel = "second" })
	
	setMBUS_IGD(modify)
	
	saveall(0, 1)
	cgilua.redirect("save_alert.lp", { u = "wlanStatus.lp?wifiPage=wifi"})
	return
end

--scan list should be updated before getting the list info.
local showStyle = "block"
local linkStyle = cgilua.QUERY["linkStyle"] 

if cgilua.QUERY["linkStyle"]~=nil then
  showStyle = "none"
  --aplist scan update
  local modify = {}
  local ret, error = mbus.getParameters{ path = "WLAN.Intf", param= "Status" }

  if ret["WLAN.Intf"][wifi2Index].param["Status"]=="enabled" then
    table.insert(modify,{path="WLAN.Intf.wlif1.ACS", param= {Rescan="1"}})
  end
  if ret["WLAN.Intf"][wifi5Index].param["Status"]=="enabled" then
    table.insert(modify,{path="WLAN.Intf.wle_radio1_ssid0.ACS", param= {Rescan="1"}})
  end
  if #modify > 0 then
    setMBUS(modify)
  end
else
  linkStyle = "none"
end

local isRemote = isRemoteAccess()
local board = getBoardInfo()

local result = {}
local linkInfo = {}
local wlanInfo = {}
--[[
result[wifi2Index] = getWlanMain("WLAN.Intf.wlif1")
linkInfo[wifi2Index] = getLinkInfo("WLAN.Intf.wlif1")
result[wifi5Index] = getWlanMain("WLAN.Intf.wle_radio1_ssid0")
linkInfo[wifi5Index] = getLinkInfo("WLAN.Intf.wle_radio1_ssid0")
]]
local tempPath
local radio_IntfPath
local reply, error
local intf_Status = {}
local radio_Status = {}
local WIntfaclMACPath
local WIntfPath
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

	--tempPath = "WLAN.Intf."..i
	radio_IntfPath = "Device.WiFi.Radio."..i
	result[i] = getWlanMain(WIntfPath)
	linkInfo[i] =  getLinkInfo(WIntfPath)

	local reply, error = mbus.getParameters{ path = radio_IntfPath, param = "Status", datamodel = "second"}		
	intf_Status[i] = reply[radio_IntfPath][1].param["Status"]
	if intf_Status[i] ~= nil and intf_Status[i] == "Up" then
		radio_Status[i] = translate([==[Active]==])
	else
		radio_Status[i] = translate([==[Not active]==])
	end
	
end

--temp var
local i = 1

for itr=1,#wifiIndexList do
  i=wifiIndexList[itr]

  wlanInfo[i] = {}
  --print("wifiIndex ",i)
  if result[i].ssid ~= nil then
    wlanInfo[i].status = result[i].status
    wlanInfo[i].wlanState = translate([==[Active]==])
    if result[i].status=="disabled" then
      wlanInfo[i].wlanState = translate([==[Not active]==])
    end

    wlanInfo[i].ssid = result[i].ssid .. " (" .. translate([==[Visible]==]) .. ")"
    if result[i].anyssid == "false" then
      wlanInfo[i].ssid = result[i].ssid .. " (" .. translate([==[Hidden]==]) .. ")"
    end

     --[[ wlanInfo[i].channelWidth = result[i].channelwidth .. " MHz (" .. translate([==[Manual]==]) .. ")"
    if result[i].channelwidth == "20/40" then
      wlanInfo[i].channelWidth = result[i].channelwidth .. " MHz (" .. translate([==[Automatic]==]) .. ")"
    end 
	]]
	
	--print("Current Channel Width"..result[i].channelwidth)

    wlanInfo[i].channelWidth = result[i].channelwidth .. " MHz"
    if result[i].channelwidth == "20" then
                wlanInfo[i].channelWidth = result[i].channelwidth .. " MHz"
    elseif result[i].channelwidth == "20/40" then
                wlanInfo[i].channelWidth = "Auto 20 MHz / 40 MHz"
    end
	
    wlanInfo[i].wlanChannel = result[i].channel .. " (" .. translate([==[Manual]==]) .. ")"
    if result[i].channelmode=="Auto" then
      wlanInfo[i].wlanChannel = result[i].channel .. " (" .. translate([==[Automatic]==]) .. ")"
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
           WIntfaclMACPath ="WLAN.Intf.wlif1"
    elseif i==2 then
           WIntfaclMACPath="WLAN.Intf.wl_ssid1_local0"
    elseif i==3 then
           WIntfaclMACPath="WLAN.Intf.wle_radio1_ssid0"
    elseif i==4 then
           WIntfaclMACPath="WLAN.Intf.wle_radio1_ssid1"
    end
    wlanInfo[i].aclMacPath = WIntfaclMACPath..".ACL.MAC"
    wlanInfo[i].aclControl = translate([==[Disabled]==])
    if result[i].control=="unlock" then
      wlanInfo[i].aclControl = translate([==[Enabled]==]) 
    end
    local WIntfSTAPath
    --Wi-Fi Links of station signal
     if i==1 then
           WIntfSTAPath ="WLAN.Intf.wlif1"
     elseif i==2 then
           WIntfSTAPath="WLAN.Intf.wl_ssid1_local0"
     elseif i==3 then
           WIntfSTAPath="WLAN.Intf.wle_radio1_ssid0"
     elseif i==4 then
           WIntfSTAPath="WLAN.Intf.wle_radio1_ssid1"
     end
    wlanInfo[i].stationList=getList_keystr(WIntfSTAPath..".Station",nil,"MACAddress","RssiLevel", "RxPhyRate", "Capabilities")
   
    --Wi-Fi Networks(aplist scan)
    wlanInfo[i].scanList={}
    
    if linkStyle ~= "none" and result[i].status=="enabled" then
    for apList in string.gmatch(tostring(result[i].apList_T), "([^;]+)") do
      for bssidVal, ssidVal, channelVal, rssiVal, secmode, unknown in string.gmatch(apList, "([^:]*):([^:]*):([^:]*):([^:]*):([^:]*):([^:]*)") do
        table.insert(wlanInfo[i].scanList, {ssid=ssidVal, channel=channelVal, bssid=bssidVal, rssi=rssiVal})
      end
    end
    end
  end
end

wlanInfo[wifi2Index].name = "2.4 GHz"
wlanInfo[wifi5Index].name = "5 GHz"


local errMsgOff1 = "<p>" .. translate([==[The Wi-Fi at 2.4 GHz is turned off. Wi-Fi will be detected only at 5 GHz networks.]==]).. "</p>"
local errMsgOff2 = "<p>" .. translate([==[The Wi-Fi at 5 GHz is turned off. Wi-Fi will be detected only at 2.4 GHz networks.]==]).. "</p>"

%>

<body onload="javascript:enableWifi();">

<script language="JavaScript" type="text/javascript">
<%
if (cgilua.QUERY["wifiPage"] == "wifi") then
%>
if(window.parent.menu.document.getElementById("wifist")!=null && 
		window.parent.menu.document.getElementById("wifist") != "undefinded") {
	window.parent.menu.document.getElementById("wifist").className="submenuselect";
	window.parent.menu.document.getElementById("wifi2").className="";
	window.parent.menu.document.getElementById("wifi5").className="";
	window.parent.menu.document.getElementById("wifi_guest").className="";
	window.parent.menu.document.getElementById("stat").className="";
}
<%
end
%>
if(window.parent.menu.document.getElementById("wifist")!=null && 
		window.parent.menu.document.getElementById("wifist") != "undefinded") {	
	window.parent.menu.document.getElementById("wifi2li").style.display="block";
	window.parent.menu.document.getElementById("wifi5li").style.display="block";
	window.parent.menu.document.getElementById("wifi_guestli").style.display="block";
}	

//<![CDATA[
function doShowList()
{
  document.location.href="wlanStatus.lp?wifiPage=wifi&linkStyle=block";
  return false;
}

function ShowLista()
{
  if("<%=linkStyle%>"=="none")
  {
    var state1 = "<%=wlanInfo[wifi2Index].status%>";
    var state2 = "<%=wlanInfo[wifi5Index].status%>";
    if(state1=="disabled")
    {
      document.getElementById("WlanIntfOffMsg").innerHTML = "<%=errMsgOff1%>";
      document.getElementById("wifiStatus").style.display="none";
      document.getElementById("intfOff").style.display="block";
      return false;
    }
    else if(state2=="disabled")
    {
      document.getElementById("WlanIntfOffMsg").innerHTML = "<%=errMsgOff2%>";
      document.getElementById("wifiStatus").style.display="none";
      document.getElementById("intfOff").style.display="block";
      return false;
    }
    document.location.href="wlanStatus.lp?wifiPage=wifi&linkStyle=block";
    return false;
  }
  var el = document.getElementById("listawifi");
  var bt = document.getElementById("buttonlista");
  el.style.display = "";
  bt.style.display = "none";
  return false;
}

function HideLista()
{
	var el = document.getElementById("listawifi");
	var bt = document.getElementById("buttonlista");
	el.style.display = "none";
	bt.style.display = "";	
	return false;
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

function refreshChannel(n)
{
  document.location.href = "refresh_chan.lp?intf=" + n;
}

function confirmConfig()
{
  var isWlanStateOff = document.getElementById("disableWLAN").checked;
  if(isWlanStateOff){
    document.getElementById("wifiStatus").style.display="none";
    document.getElementById("confirmOff").style.display="block";
    return false;
  }
  document.wlanStatus.submit();
}

function submit_ok()
{
  document.wlanStatus.submit();
}

function closeConfirm()
{
  document.getElementById("wifiStatus").style.display="block";
  document.getElementById("confirmOff").style.display="none";
  document.getElementById("intfOff").style.display="none";
}
//]]>
</script>

<div class="contentContainer fontSize">
	<div class="breadCrumbContainer">
		<ul class="brdCrumb">
			<li><a href="standard.lp"><%=translate([==[Basic Settings]==])%></a></li><li>|</li><li><a href="wlanStatus.lp?wifiPage=wifi">Wi-Fi</a></li>
				
		
			


<!-- <table cellspacing='0' cellpadding='0' width="100%" class="NavBar">
<tr><td align="left"><a href="standard.lp">Standard</a>&nbsp;&nbsp;>&nbsp;&nbsp;<a href="wlanStatus.lp?wifiPage=wifi">Wi-Fi</a> -->
<%
if isRemote==false then
        if cgilua.QUERY["wifiPage"] ~= "wifi" then
%>
<li>|</li>
        <%if cgilua.QUERY["wifiPage"] == "wifi2" then%>
		
        <li><a href="wlanStatus.lp?wifiPage=wifi2">Wi-Fi 2.4 GHz</a></li>
		
		<!-- </td><td align="right"><em>Stato</em>&nbsp;&nbsp;|&nbsp;&nbsp;<a href="wlanConfig.lp">Configura</a> -->
        <%else%>
		
        <li><a href="wlanStatus.lp?wifiPage=wifi5">Wi-Fi 5 GHz</a></li>		
		
		<!-- </td><td align="right"><em>Stato</em>&nbsp;&nbsp;|&nbsp;&nbsp;<a href="wlanConfig.lp?id=2">Configura</a> -->
        <%end
        end
end%>
<!-- </td></tr>
</table> -->
	</ul></div>
					
<div class='contentcontainer'>
<div id="wifiStatus">
<form method="post" id="wlanStatus" name="wlanStatus" action="">
<!-- Wifi common start -->
<%
if cgilua.QUERY["wifiPage"] == "wifi" then
%>

<div class="contentTab" id="content">
			<ol id="tocTab">
				<li><a class="current">
		<div class="tab">
			<span class="tabIcon_stwifi"></span>  
			<span class="contTabTxt">WI-FI</span>
		</div>
		<div class="clrBth"></div></a></li>
			</ol>
		</div>
<div class='contentitem'>

<%
	writePageHeader_new()
	writeBlockNoTitle()
%>

<tr class='midarea3' style="padding-left:0px;">
  <td width="300px"><%=translate([==[Radio Interfaces]==])%>:</td>
  <td width="430px"colspan='2'>
<%
if isRemote then
        if result[wifi2Index].status=="enabled" and result[wifi5Index].status=="enabled" then
                cgilua.print(translate([==[Active]==]))
        else
                cgilua.print(translate([==[Disable]==]))
        end
else
%>
    <input type="radio" value="1" id="enableWLAN" name="wlanState">&nbsp;<%=translate([==[Active]==])%>&nbsp;&nbsp;&nbsp;&nbsp;    
    <input type="radio" value="0" id="disableWLAN" name="wlanState">&nbsp;<%=translate([==[Disable]==])%>
<%end%>
  </td>
</tr>
<% endBlock() %>

<% if isRemote==false then%>

	<table><tr class='' style='padding-left:0px'>
			<td style='padding-left:250px'>
			<a style='color:black' onclick='confirmConfig()' href="#">
			<div class="midarea6-1 mainButton" name="thb6"><%=translate([==[Save]==])%></div></a></td>
			
			<td style='padding-left:50px'>
			<a style='color:black' href='standard.lp'>
			<div class="midarea6-1 mainButton" name="thb7"><%=translate([==[Cancel]==])%></div></a></td>
			</tr>
	</table>

<%end%>


<% if wlanInfo[wifi2Index].status == "enabled" or wlanInfo[wifi5Index].status == "enabled" then %>
<div id="buttonlista" style="display:<%=showStyle%>">

<%
  writeItemTitle(translate([==[Show nearby Wi-Fi networks]==]))
  endBlock()
%>
  <table cellspacing='0' cellpadding='0' width='100%' style="text-align:center" class="fontSize">
    <!-- <tr class='midarea6'> -->
      <td style='vertical-align:top; padding-left: 270px;'>
		<a style='color:black' onclick="return ShowLista();">
		<div class="midarea7-1 secondaryButton" name="thb7"><%=translate([==[List Wi-Fi Networks]==])%></div></a>
      </td>
    <!-- </tr> -->
  </table>
</div>

<div width="600px" id="listawifi" style="display:<%=linkStyle%>">

<%
  writeItemTitle(translate([==[Show nearby Wi-Fi networks]==]))
  endBlock()
%>
  <br>
  <table cellspacing='0' cellpadding='0' width='100%' style="text-align:center" class="fontSize">
    <tr style="width:750px;padding-top:10px;">
      <td style="width:390px;vertical-align:top">
		<a style='color:black;float:right;padding-right:50px;' onclick='javascript: document.location.href="wlanStatus.lp?wifiPage=wifi&linkStyle=block"'>
		<div class='midarea6-1 mainButton' name="thb11"><%=translate([==[Update]==])%></div></a></td>
		
		<td style="vertical-align:top">
		<a style='color:black' onclick="return HideLista();">
		<div class="midarea7-1 secondaryButton" name="thb7"><%=translate([==[Hide List Wi-Fi Networks]==])%></div></a></td>
    </tr>
  </table>
<%
--for n=wifiIndex, wifi5Index do
for itr=1,#wifiIndexList do
  n=wifiIndexList[itr]
  if wlanInfo[n].status == "enabled" then
    writeTableWifiWithoutPic(translate([==[Wi-Fi Networks]==]) .. " " .. wlanInfo[n].name)
    writeTableBlockHeader_WiFi(4, translate([==[Wi-Fi Network]==]) .. " (SSID)", translate([==[BSSID]==]), translate([==[Channel]==]), translate([==[Level Field]==]))

    --list the Wi-Fi Networks
    local rowStyle = "oddrow"
    local rowNum = 0
    for k,v in pairs(wlanInfo[n].scanList) do
      if v["rssi"]~="" then
        local level = rssiToLevel(tonumber(v["rssi"]))
        
        rowNum = rowNum + 1
        if rowNum%2==1 then
          rowStyle = "oddrow"
        else
          rowStyle = "evenrow"
        end
%>
        <!-- <tr><td width='33%' class='<%=rowStyle%>' colspan='4'><img src='images/spacer.gif' border='0' width='1' height='3' alt=''><br></td></tr> -->
        <tr>
          <td class="<%=rowStyle%> width150 contentSSID">
            <%
            --fix bug 75495, when ssid is empty, must show a empty box
            if v["ssid"]=="" then
              cgilua.print("&nbsp;&nbsp;")
            else
              cgilua.print(cgilua.html_escape(v["ssid"]))
            end
            %>
          </td>
          <td class="<%=rowStyle%> width150"><%=v["bssid"]%></td>
          <td class="<%=rowStyle%> width150"><%=v["channel"]%></td>
          <td class="<%=rowStyle%> width150">
            <table class="tablePB" cellspacing="0" width="100"><!--display the signals -->
              <tbody>
                <tr>
                <%for i=0, level do%>
                  <td class="pbtdcolor<%=i%>">&nbsp;</td>
                <%end%>
                <%for i=1, 5-level do%>
                  <td class="pbtdwhite">&nbsp;</td>
                <%end%>
                </tr>
              </tbody>
            </table>
          </td>
        </tr>
        <!-- <tr><td class="<%=rowStyle%>" colspan='4'><img src='images/spacer.gif' border='0' width='1' height='3' alt=''><br></td></tr> -->
<% 
      end
    end
    endBlock()
  end
end
%>
   <br/>
  <table cellspacing='0' cellpadding='0' width='100%' style="text-align:center">
    <tr style="width:750px;padding-top:10px;" >
      <td style="width:390px;vertical-align:top">
<% if isRemote==false then%>
		<a style="color:black;float:right;padding-right:50px" onclick="javascript:document.location.href='wlanStatus.lp?wifiPage=wifi&linkStyle=block'"><div class='midarea6-1 mainButton' name="thb11"><%=translate([==[Update]==])%></div></a></td>
		
		<td style="vertical-align:top"><a onclick="return HideLista();"><div class='midarea7-1 secondaryButton' name="thb7"><%=translate([==[Hide List Wi-Fi Networks]==])%></div></a>
<% end%>
      </td>
    </tr>
  </table>
</div>
<%
	local tprint = require("tableprint")
	local print = cgilua.print
	local indexList
	local writeGuestBlock = false
	local ipv6Enable = getIPv6("Device.IP")
	local activeGuestFrequency
	
	--this loop itereate twice to write wifi tables and wifiguest tables.
	for loopItr = 1,2 do
	
		if ( loopItr == 1 ) then
			--For Wifi Block
			writeItemTitle(translate([==[Wi-Fi Links]==]))
			endBlock()
			indexList = wifiIndexList
		else
			--For Wifi Guest Block
			
			if( getGuestStatus() == true ) then
				
				writeItemTitle(translate([==[Wi-Fi Guests Links]==]))
				endBlock()
				-- guestIndexList available in wlanGuestUtil.lp
				indexList = getWifiGuestIndexList()
				activeGuestFrequency = getWifiFrequency()
				writeGuestBlock = true
			end
			
		end
		
		local writeBlock
		local wifiPath
	
		--for n=wifi2Index, wifi5Index do
		for itr=1,#indexList do
		
			n=indexList[itr]
			writeBlock = false
			if n==1 then
			   wifiPath ="WLAN.Intf.wlif1"
			elseif n==2 then
			   wifiPath="WLAN.Intf.wl_ssid1_local0"
			elseif n==3 then
			   wifiPath="WLAN.Intf.wle_radio1_ssid0"
			elseif n==4 then
			   wifiPath="WLAN.Intf.wle_radio1_ssid1"
			end

			--wifiPath = "WLAN.Intf."..tonumber(n)
			if( loopItr == 1 ) then			
				local reply, error = mbus.getParameters{ path = wifiPath, param = "RadioEnable",flags="KEYPATH"}			
				if reply[wifiPath][1].param["RadioEnable"]=="true" then
					writeBlock = true
					writeTableBlockTitleWithoutPic(translate([==[Wi-Fi Links]==]) .. " " .. wlanInfo[n].name)
				end
			else				
				if( writeGuestBlock == true ) then
				   
					wlanInfo[n] = {}
					if( n == 2 and ( activeGuestFrequency == "2.4 GHz" or activeGuestFrequency == "2.4 GHz e 5 GHz") ) then
						wlanInfo[n].name = "2.4 GHz"
						writeBlock = true						
					elseif( n==4 and ( activeGuestFrequency == "5 GHz" or activeGuestFrequency == "2.4 GHz e 5 GHz") ) then
						wlanInfo[n].name = "5 GHz"
						writeBlock = true
					end
					
					--Wi-Fi Links of station signal
					if( writeBlock == true ) then
						wlanInfo[n].stationList=getList_keystr(wifiPath..".Station",nil,"MACAddress","RssiLevel", "RxPhyRate", "Capabilities")
						writeTableBlockTitleWithoutPic(translate([==[Wi-Fi Guests Links]==]) .. " " .. wlanInfo[n].name)
					end					
				end
			end
		
			if ( writeBlock == true ) then
			
				if ipv6Enable == "true" then
					writeWiFiTableBlockHeader(6, translate([==[Type]==]), translate([==[Speed]==]), translate([==[Host Name]==]), translate([==[MAC Address]==]), translate([==[Address IP]==]), translate([==[IPv6 Address]==]))
				else
					writeWiFiTableBlockHeader(5, translate([==[Type]==]), translate([==[Speed]==]), translate([==[Host Name]==]), translate([==[MAC Address]==]), translate([==[Address IP]==]))
				end
				
				local rowStyle = "oddrow"
				local rowNum = 0
		 
				for i, v in pairs(linkInfo[n]) do
					v.param["PhyMode"] = ""
					v.param["PhyRate"] = ""
					for j,m in pairs(wlanInfo[n].stationList) do
						if m["MACAddress"]==v.param["MACAddress"] then
							if m["Capabilities"] ~= nil then
								-- get 802.11b, 802.11g or 802.11n
								v.param["PhyMode"] = string.sub(m["Capabilities"], 1, 7)
							end
							if m["RxPhyRate"] ~= nil then
								v.param["PhyRate"] = tonumber(m["RxPhyRate"])/1000 .. " Mbit/s"
							end
						end
					end
					rowNum = rowNum + 1
					if rowNum%2==1 then
						rowStyle = "oddrow"
					else
						rowStyle = "evenrow"
					end
					if ipv6Enable == "true" then
						writeWiFiTableBlockRow(6, rowStyle, v.param["PhyMode"], v.param["PhyRate"], v.param["HostName"], v.param["MACAddress"], v.param["IPAddress"], v.param["IPv6Address"])
					else
						writeWiFiTableBlockRow(5, rowStyle, v.param["PhyMode"], v.param["PhyRate"], v.param["HostName"], v.param["MACAddress"], v.param["IPAddress"])
					end
				end  
		  
				if #linkInfo[n]==0 then
					if ipv6Enable == "true" then
						writeWiFiTableBlockRow(6, "oddrow", translate([==[No Wi-Fi host connected.]==]), "", "", "", "", "")
					else
						writeWiFiTableBlockRow(5, "oddrow", translate([==[No Wi-Fi host connected.]==]), "", "", "", "")
					end
				end
				endBlock()
			else
				--cgilua.print("no information")
			end
		end
	end
end
end
%>
</div>
<!-- Wifi common end -->

<!-- Wifi 2.4G and 5G start -->
<%
--for n=wifi2Index, wifi5Index do
for itr=1,#wifiIndexList do
  n=wifiIndexList[itr]
	if (cgilua.QUERY["wifiPage"] == "wifi2" and n==wifi2Index) or (cgilua.QUERY["wifiPage"] == "wifi5" and n==wifi5Index) then
		local titlePic = "iwla24xl.gif"
		if cgilua.QUERY["wifiPage"] == "wifi5" then
			titlePic = "iwla50xl.gif" 
		end
		
		if( cgilua.QUERY["wifiPage"] == "wifi2" ) then
		%>
		
		<div class="contentTab" id="content">
			<ol id="tocTab">
				<li><a href="wlanStatus.lp?wifiPage=wifi2" class="current">
		<div class="tab">
			<span class="tabIcon_stwifi2"></span>  
			<span class="contTabTxt">WI-FI 2.4GH</span><span class="contTabTxt" style="text-transform:lowercase">z</span>
		</div>
		<div class="clrBth"></div></a></li>
		<% if isRemoteAccess() == false then %>
			<li><a class="margin15" href="wlanConfig.lp">
		<div class="tab">
			<span class="contTabTxt transform"><%=translate([==[Configure]==])%> Wi-Fi 2.4 GH</span><span class="contTabTxt" style="text-transform:lowercase">z</span>
			</div></a></li>	
		<% end %>		
			</ol>
		</div>
		
		<% else if ( cgilua.QUERY["wifiPage"] == "wifi5" ) then
		%>
		<div class="contentTab" id="content">
			<ol id="tocTab">
				<li><a href="wlanStatus.lp?wifiPage=wifi5" class="current">
		<div class="tab">
			<span class="tabIcon_stwifi5"></span>  
			<span class="contTabTxt">WI-FI 5GH</span><span class="contTabTxt" style="text-transform:lowercase">z</span>
		</div>
		<div class="clrBth"></div></a></li>
		<% if isRemoteAccess() == false then %>
			<li><a class="margin15" href="wlanConfig.lp?id=2">
		<div class="tab">
			<span class="contTabTxt transform"><%=translate([==[Configure]==])%> Wi-Fi 5 GH</span><span class="contTabTxt" style="text-transform:lowercase">z</span>
			</div></a></li>	
		<% end %>		
			</ol>
		</div>
		
		<%
	end
 end
		%>
		<div class='contentitem'>
		<%
		
		writePageHeader_new()
		
		--writeBlockNoTitle()
		writeBlockTitle_Wifi(translate([==[Wi-Fi Settings]==]) .. " " .. wlanInfo[n].name)
		--writeItemTitle(translate([==[Wi-Fi Settings]==]) .. " " .. wlanInfo[n].name)
		local j=1
		if n == 3 then j=2 end
		writeBlockRow5(translate([==[Radio Interface]==]), radio_Status[j])
		writeBlockRow5(translate([==[Wi-Fi network (SSID)]==]), wlanInfo[n].ssid)
%>
  <tr><td style='vertical-align:top' class="midarea4-9"><%=translate([==[Radio Channel]==])%>:</td><td style='vertical-align:top'  class="channelButton" ><%=wlanInfo[n].wlanChannel%>
<% if isRemote==false then%>
    <%if result[n].channelmode=="Auto" then%>
      </td><td class="alignMid">
	  <a style='color:black' onclick='refreshChannel(<%=n%>);'><div class='midarea7-2 secondaryButton' name="thb9" style="padding-top:3px;width:120px;height:20px;"><%=translate([==[Search Channel]==])%></div></a>
    <%end%>
<%end%>
  </td></tr>
<%
  writeBlockRow5(translate([==[Bandwidth (Channel)]==]), wlanInfo[n].channelWidth)
  writeBlockRow5(translate([==[Methods of encryption]==]), wlanInfo[n].secMode)
  if result[n].secmode ~= "disabled" then
%>
  <tr style="width:750px;"><td class="midarea4-9"><%=translate([==[Encryption key]==])%>:</td>
    <%
    local remoteAccessStatus = isRemoteAccess()
    if remoteAccessStatus==false then
    %>
    <td colspan='2' class="midarea4-8"><%=wlanInfo[n].keyEncryption%>
    <%if result[n].secmode=="WEP" then%>
      <div id="wepHex<%=n%>"></div>
    <%end%>
    </td>
    <%end%>
  </tr>
<%
  end
  writeBlockRow5(translate([==[Access Control]==]), wlanInfo[n].aclControl)
  endBlock()

  if result[n].control=="unlock" then
    local aclList, error = mbus.getParameters{ path=wlanInfo[n].aclMacPath, param={"MACAddress", "Permission"},flags="KEYPATH" }
    if #aclList[wlanInfo[n].aclMacPath] > 0 then
      writeTableBlockTitle_Wifidevices(translate([==[Authorized Devices]==]),40)
	  
	  %>
  <tr><td colspan='2'><img src='images/spacer.gif' border='0' width='1' height='1' alt=''><br></td></tr>
  <tr>
        <td class="authHeader tableHd" style="padding-left: 0px;"><%=translate([==[MAC Address]==])%></td>
        <td class="tableHd" style="padding-left: 0px;"><%=translate([==[Access Management]==])%></td>
  </tr>
  <tr><td colspan='2'><img src='images/spacer.gif' border='0' width='1' height='1' alt=''><br></td></tr>

<%
	  
      --writeTableBlockHeader(2, translate([==[MAC Address]==]), translate([==[Access Management]==]))
      local rowStyle = "oddrow"
      local rowNum = 0
      for i, v in pairs(aclList[wlanInfo[n].aclMacPath]) do
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

endBlock() %>
</div>
<!-- Wifi 2.4G and 5G end -->

<%if result[n].secmode=="WEP" then%>
<script language="javascript" type="text/javascript">
var wepKey = "<%=result[n].wep%>";
if (wepKey.length==13)
  document.getElementById("wepHex<%=n%>").innerHTML=toHex(wepKey)+" [HEX]";
else
  document.getElementById("wepHex<%=n%>").innerHTML=toAscii(wepKey)+" [ASCII]";
</script>
<% end 
 end 
 end 
 endPage() %>
</form>
</div>
</div>
</div>

<% if cgilua.QUERY["wifiPage"] == "wifi" then %>
<div id="confirmOff" style="display:none">
<%cgilua.lp.include("webparts/WlanRadioOff.lp")%>
</div>
<div id="intfOff" style="display:none">
<%cgilua.lp.include("webparts/WlanIntfOff.lp")%>
</div>
<script src="js/antiCSRF.js" type="text/javascript"></script>
<script language="javascript" type="text/javascript">
<% if isRemote==false then%>
var radioState = "<%=result[wifi2Index].status%>";
var radioState2 = "<%=result[wifi5Index].status%>";
if((radioState=="enabled") || (radioState2=="enabled")){
  document.getElementById("enableWLAN").checked = true;
}else{
  document.getElementById("disableWLAN").checked = true;
}
<%end%>
</script>
<% end %>
</div>

</body>
</html>
