<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
  <title>Modem Telecom Italia</title>
  <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
  <!-- <link rel="stylesheet" href="css/style.css" type="text/css" /> -->
  <link rel="stylesheet" href="css/master.css" type="text/css" />
  <script language="javascript" type="text/javascript" src="js/script.js"></script> 
    <script language="JavaScript" type="text/javascript">
   if(window.parent.menu.document.getElementById("advance")!=null && 
		window.parent.menu.document.getElementById("advance") != "undefinded") {

		
	} if(window.parent.menu.document.getElementById("teleSubli")!=null && 
		window.parent.menu.document.getElementById("teleSubli") != "undefinded") {
		window.parent.menu.document.getElementById("teleSubli").className="";
		window.parent.menu.document.getElementById("teleSubli").style.display="none";	
	}
	
	if(window.parent.menu.document.getElementById("tele")!=null && 
		window.parent.menu.document.getElementById("tele") != "undefinded") {
		window.parent.menu.document.getElementById("tele").className="";
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
		if(window.parent.menu.document.getElementById("ipv6list")) {
			window.parent.menu.document.getElementById("ipv6firewall").className="";
			window.parent.menu.document.getElementById("ipv6list").style.display="none";
		}
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
	if(window.parent.menu.document.getElementById("waon")!=null && 
		window.parent.menu.document.getElementById("waon") != "undefinded") {
		window.parent.menu.document.getElementById("waon").className="";
	}
	if(window.parent.menu.document.getElementById("stru")!=null && 
		window.parent.menu.document.getElementById("stru") != "undefinded") {
		window.parent.menu.document.getElementById("stru").className="";
	}	
  </script>
</head>
<body>

<%
cgilua.lp.include("lp/menu.lp")
cgilua.lp.include("lp/device.lp")
local FXO_val = getDeviceRoute()
local reply, error = mbus.getParameters{ path = "TI_STORE.TiUserIntf", param="LANOption" }
local lanOption = reply["TI_STORE.TiUserIntf"][1].param["LANOption"] or ""

local reply, error = mbus.getParameters{path = "Device.UserInterface.X_TELECOMITALIA_IT_WebPage", param = "LANOption", datamodel = "second" }
local ipv6lanOption = reply["Device.UserInterface.X_TELECOMITALIA_IT_WebPage"][1].param["LANOption"] or ""
  
-- Get the Device.Services.X_TELECOMITALIA_IT_VoIPServiceType State value from the Gateway
function getTIServiceType()
	local replyType, error = mbus.getParameters{ path = "Device.Services", param="X_TELECOMITALIA_IT_VoIPServiceType" , datamodel = "second" }   
	local serviceType = replyType["Device.Services"][1].param["X_TELECOMITALIA_IT_VoIPServiceType"]
	return serviceType
end

function getDeviceInfo()
	local reply, error = mbus.getParameters{ path = "Device.DeviceInfo", param="X_TELECOMITALIA_IT_ServiceType" , datamodel = "second" }   
	local devType = nil
	if reply["Device.DeviceInfo"] ~= nil and reply["Device.DeviceInfo"][1] ~= nil then
		devType = reply["Device.DeviceInfo"][1].param["X_TELECOMITALIA_IT_ServiceType"]
	end
	return devType
end
%>


<div class="contentContainer">
	 
		<div class="breadCrumbContainer">
			<ul class="brdCrumb">
				<li><a href="advance.lp"><%=translate([==[Configure]==])%></a></li>
			</ul>
		</div>	



<div class='contentcontainer'>
<div class='contentitem'>
<table cellspacing="0" cellpadding="0" border="0"  class="table2 fontSize width750" style="padding-top:10px;margin-left:0px;">
    <tr > 
    <td class="tablecontaint2 padleft40 fontSize">
      <p><%=translate([==[The modem Telecom Italia offers more services]==])%>.</p><p>&nbsp;</p>
      <p><%=translate([==[Those services enable you to protect your network, to ease sharing of games and applications with other people on the Internet, or manage your local network.]==])%></p>
      <table border='0' cellspacing='0' cellpadding='0' class='marleft40'  width="600"><tr><td colspan='3'><img src='/images/spacer.gif' width='0' height='25' border='0' alt=''><br></td></tr><tr><td><img src='/images/spacer.gif' width='265' height='1' border='0' alt=''><br></td><td><img src='/images/spacer.gif' width='20' height='1' border='0' alt=''><br></td><td><img src='/images/spacer.gif' width='265' height='1' border='0' alt=''><br></td></tr>
    <%	
	--Fix for CPE_P0012287
	local telephonyFlag = "false"
	if getTIServiceType() == "SIP_GW" then
		if FXO_val == "true" then
			printLeftBlock("voipStato.lp", "tel___xl.png", translate([==[Telephony]==]))
			telephonyFlag = "true"
		end
	elseif getTIServiceType() == "Virtual_PBX" then
		printLeftBlock("telephonyNumberPBX.lp", "tel___xl.png", translate([==[Telephony]==]))
		telephonyFlag = "true"
	end
	
	if telephonyFlag == "true" then
		printRightBlock("usbStato.lp", "iusb__xl.png", translate([==[USB services]==]))
		printLeftBlock("mediaServer.lp", "csharing__xl.png", "Media Server")
		
		if ipv6lanOption == "biz-rt-napt-ipv6" or ipv6lanOption == "res-rt-napt-ipv6" then
			printRightBlock("ipv6_Conf.lp", "ieth__xl.png", "IPv6")
			
			if isRemoteAccess() then 
				printLeftBlock("dynDns.lp", "dns___xl.png", translate([==[Dynamic DNS]==]))
				printRightBlock("statoPortMapping.lp", "ptmp__xl.png", "Port Mapping")
			else
				if ipv6lanOption == "res-rt-napt" or ipv6lanOption == "biz-rt-napt-ena" or ipv6lanOption== "res-rt-napt-ipv6" or ipv6lanOption == "biz-rt-napt-ipv6" then
					printLeftBlock("dynDns.lp", "dns___xl.png", translate([==[Dynamic DNS]==]))
					printRightBlock("statoPortMapping.lp", "ptmp__xl.png", "Port Mapping")
					printLeftBlock("simpleFirewall.lp", "secu__xl.png", "Firewall")
					printRightBlock("urlFilter.lp", "webf__xl.png", "URL Filtering")
					--printLeftBlock("remoteAccess.lp", "reac__xl.png", translate([==[Remote Access]==]))
					printLeftBlock("wakeOnLan.lp", "wol___xl.png", translate([==[Wake on LAN]==]))
					printRightBlock("tool.lp", "tbox__xl.png", translate([==[Tools]==]))
					
				else
					printLeftBlock("simpleFirewall.lp", "secu__xl.png", "Firewall")
					--printRightBlock("remoteAccess.lp", "reac__xl.png", translate([==[Remote Access]==]))
					printRightBlock("wakeOnLan.lp", "wol___xl.png", translate([==[Wake on LAN]==]))
					printLeftBlock("tool.lp", "tbox__xl.png", translate([==[Tools]==]))
				end
			end
		
		else
			if isRemoteAccess() then
				printRightBlock("dynDns.lp", "dns___xl.png", translate([==[Dynamic DNS]==]))
				printLeftBlock("statoPortMapping.lp", "ptmp__xl.png", "Port Mapping")
			else
				if ipv6lanOption == "res-rt-napt" or ipv6lanOption == "biz-rt-napt-ena" or ipv6lanOption== "res-rt-napt-ipv6" or ipv6lanOption == "biz-rt-napt-ipv6"  then
					printRightBlock("dynDns.lp", "dns___xl.png", translate([==[Dynamic DNS]==]))
					printLeftBlock("statoPortMapping.lp", "ptmp__xl.png", "Port Mapping")
					printRightBlock("simpleFirewall.lp", "secu__xl.png", "Firewall")
					printLeftBlock("urlFilter.lp", "webf__xl.png", "URL Filtering")
					--printRightBlock("remoteAccess.lp", "reac__xl.png", translate([==[Remote Access]==]))
					printRightBlock("wakeOnLan.lp", "wol___xl.png", translate([==[Wake on LAN]==]))
					printLeftBlock("tool.lp", "tbox__xl.png", translate([==[Tools]==]))
					
				else
					printRightBlock("simpleFirewall.lp", "secu__xl.png", "Firewall")
					--printLeftBlock("remoteAccess.lp", "reac__xl.png", translate([==[Remote Access]==]))
					printLeftBlock("wakeOnLan.lp", "wol___xl.png", translate([==[Wake on LAN]==]))
					printRightBlock("tool.lp", "tbox__xl.png", translate([==[Tools]==]))
				end
			end
		end
	else
		printLeftBlock("usbStato.lp", "iusb__xl.png", translate([==[USB services]==]))
		printRightBlock("mediaServer.lp", "csharing__xl.png", "Media Server")
		
		if ipv6lanOption == "biz-rt-napt-ipv6" or ipv6lanOption == "res-rt-napt-ipv6" then
			printLeftBlock("ipv6_Conf.lp", "ieth__xl.png", "IPv6")
		
			if isRemoteAccess() then
				printRightBlock("dynDns.lp", "dns___xl.png", translate([==[Dynamic DNS]==]))
				printLeftBlock("statoPortMapping.lp", "ptmp__xl.png", "Port Mapping")
			else
				if ipv6lanOption == "res-rt-napt" or ipv6lanOption == "biz-rt-napt-ena" or ipv6lanOption== "res-rt-napt-ipv6" or ipv6lanOption == "biz-rt-napt-ipv6" then
					printRightBlock("dynDns.lp", "dns___xl.png", translate([==[Dynamic DNS]==]))
					printLeftBlock("statoPortMapping.lp", "ptmp__xl.png", "Port Mapping")
					printRightBlock("simpleFirewall.lp", "secu__xl.png", "Firewall")
					printLeftBlock("urlFilter.lp", "webf__xl.png", "URL Filtering")
					--printRightBlock("remoteAccess.lp", "reac__xl.png", translate([==[Remote Access]==]))
					printRightBlock("wakeOnLan.lp", "wol___xl.png", translate([==[Wake on LAN]==]))
					printLeftBlock("tool.lp", "tbox__xl.png", translate([==[Tools]==]))
					
				else
					printRightBlock("simpleFirewall.lp", "secu__xl.png", "Firewall")
					--printLeftBlock("remoteAccess.lp", "reac__xl.png", translate([==[Remote Access]==]))
					printLeftBlock("wakeOnLan.lp", "wol___xl.png", translate([==[Wake on LAN]==]))
					printRightBlock("tool.lp", "tbox__xl.png", translate([==[Tools]==]))
				end
			end
		else
			if isRemoteAccess() then
				printLeftBlock("dynDns.lp", "dns___xl.png", translate([==[Dynamic DNS]==]))
				printRightBlock("statoPortMapping.lp", "ptmp__xl.png", "Port Mapping")
			else
				if ipv6lanOption == "res-rt-napt" or ipv6lanOption == "biz-rt-napt-ena" or ipv6lanOption== "res-rt-napt-ipv6" or ipv6lanOption == "biz-rt-napt-ipv6"  then
					printLeftBlock("dynDns.lp", "dns___xl.png", translate([==[Dynamic DNS]==]))
					printRightBlock("statoPortMapping.lp", "ptmp__xl.png", "Port Mapping")
					printLeftBlock("simpleFirewall.lp", "secu__xl.png", "Firewall")
					printRightBlock("urlFilter.lp", "webf__xl.png", "URL Filtering")
					--printRightBlock("remoteAccess.lp", "reac__xl.png", translate([==[Remote Access]==]))
					printLeftBlock("wakeOnLan.lp", "wol___xl.png", translate([==[Wake on LAN]==]))
					printRightBlock("tool.lp", "tbox__xl.png", translate([==[Tools]==]))
					
				else
					printLeftBlock("simpleFirewall.lp", "secu__xl.png", "Firewall")
					--printLeftBlock("remoteAccess.lp", "reac__xl.png", translate([==[Remote Access]==]))
					printRightBlock("wakeOnLan.lp", "wol___xl.png", translate([==[Wake on LAN]==]))
					printLeftBlock("tool.lp", "tbox__xl.png", translate([==[Tools]==]))
				end
			end
		end
	end
      %>
</table></td></tr></table></td></tr></table>
</div>
</div>
 <script language="javascript" type="text/javascript">
  function detectBrowserDetails() 
{
	var nVer = navigator.appVersion;
	var nAgt = navigator.userAgent;
	var browserName  = navigator.appName;
	var fullVersion  = ''+parseFloat(navigator.appVersion); 
	var majorVersion = parseInt(navigator.appVersion,10);
	var nameOffset,verOffset,ix;

// In Opera, the true version is after "Opera" or after "Version"
if ((verOffset=nAgt.indexOf("Opera"))!=-1) {
	 browserName = "Opera";
	 fullVersion = nAgt.substring(verOffset+6);
	 if ((verOffset=nAgt.indexOf("Version"))!=-1) 
	   fullVersion = nAgt.substring(verOffset+8);
}
// In MSIE, the true version is after "MSIE" in userAgent
else if ((verOffset=nAgt.indexOf("MSIE"))!=-1) {
	 browserName = "Microsoft Internet Explorer";
	 fullVersion = nAgt.substring(verOffset+5);
}
// In Chrome, the true version is after "Chrome" 
else if ((verOffset=nAgt.indexOf("Chrome"))!=-1) {
	 browserName = "Chrome";
	 fullVersion = nAgt.substring(verOffset+7);
}
// In Safari, the true version is after "Safari" or after "Version" 
else if ((verOffset=nAgt.indexOf("Safari"))!=-1) {
	 browserName = "Safari";
	 fullVersion = nAgt.substring(verOffset+7);
	 if ((verOffset=nAgt.indexOf("Version"))!=-1) 
	   fullVersion = nAgt.substring(verOffset+8);
}
// In Firefox, the true version is after "Firefox" 
else if ((verOffset=nAgt.indexOf("Firefox"))!=-1) {
	 browserName = "Firefox";
	 fullVersion = nAgt.substring(verOffset+8);
}
// In most other browsers, "name/version" is at the end of userAgent 
else if ( (nameOffset=nAgt.lastIndexOf(' ')+1) < 
          (verOffset=nAgt.lastIndexOf('/')) ) 
{
	 browserName = nAgt.substring(nameOffset,verOffset);
	 fullVersion = nAgt.substring(verOffset+1);
	 if (browserName.toLowerCase()==browserName.toUpperCase()) {
	  browserName = navigator.appName;
 }
}
// trim the fullVersion string at semicolon/space if present
if ((ix=fullVersion.indexOf(";"))!=-1)
   fullVersion=fullVersion.substring(0,ix);
if ((ix=fullVersion.indexOf(" "))!=-1)
   fullVersion=fullVersion.substring(0,ix);

   majorVersion = parseInt(''+fullVersion,10);

	if (isNaN(majorVersion)) {
		fullVersion  = ''+parseFloat(navigator.appVersion); 
		majorVersion = parseInt(navigator.appVersion,10);
	}

if (browserName == "Microsoft Internet Explorer")
{
	
	if (majorVersion <= 7) 
	{
		
		if(document.getElementById("advanceTransform"))
		{
			document.getElementById("advanceTransform").className="contTabTxt transform";
		}
		
	}
	else
	{
		
		if(document.getElementById("advanceTransform"))
		{
			document.getElementById("advanceTransform").className="contTabTxt_ad transform";
		}
	}
}
else 
{
		
		if(document.getElementById("advanceTransform"))
		{
			document.getElementById("advanceTransform").className="contTabTxt_ad transform";
		}
}
}
	detectBrowserDetails(); 
  
  </script>
</body>
</html>
