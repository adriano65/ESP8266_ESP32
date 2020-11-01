<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<title>Modem Telecom Italia</title>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>

<link rel="stylesheet" href="css/master.css" type="text/css" />

<style type="text/css">

.backBtnPadding {
   padding-left:68px;
}

.backBtnPadding-ie6nOpera {
   padding-left:75px;
}

.backBtnPadding-Chrome {
   padding-left:72px;
}
</style>

<% cgilua.lp.include("lp/language.lp") %>
<% cgilua.lp.include("lp/usb.lp") %>
<% cgilua.lp.include("lp/mbus_util.lp") %>
<% cgilua.lp.include("lp/device.lp") %>
<% cgilua.lp.include("lp/util.lp") %>
<% cgilua.lp.include("lp/style.lp") %>

<% local ipv6Enable = getIPv6("Device.IP")%>

<script language="javascript" type="text/javascript" src="js/script.js"></script>
    <script language="JavaScript" type="text/javascript">
	
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
		window.parent.menu.document.getElementById("usbst").className="";
	}

	if(window.parent.menu.document.getElementById("media")!=null && 
		window.parent.menu.document.getElementById("media") != "undefinded") {
		window.parent.menu.document.getElementById("media").className="";
	}
	
	if(window.parent.menu.document.getElementById("ipv6")!=null && 
		window.parent.menu.document.getElementById("ipv6") != "undefinded") {
		window.parent.menu.document.getElementById("ipv6").className="submenuselect1";
		
		if(window.parent.menu.document.getElementById("ipv6list")!=null && 
		window.parent.menu.document.getElementById("ipv6list") != "undefinded") {
			window.parent.menu.document.getElementById("ipv6firewall").className="";
			<%if ipv6Enable == "true" then %>
				window.parent.menu.document.getElementById("ipv6list").style.display="block";
			<%else%>
				window.parent.menu.document.getElementById("ipv6list").style.display="none";
			<%end%>
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

<%
local translate = translate
local POST = cgilua.POST

local tprint = require("tableprint")
local print = cgilua.print

local ipv6address = ""
local pppEnable = ""
local pppConnectionStatus = ""
local ipv6config = false
local lanipaddress = ""
local lanprefixpath = ""
local lanprefix = ""
local spArray, splitvalue
local usersessionpath=""
local username=""
local regmanstring=""

--ipv6address values 
local ipv6addresspath = "Device.IP.Interface.2.IPv6Address.2"
local replyipv6address, error = mbus.getParameters{path = ipv6addresspath, param = {"IPAddress"}, datamodel = "second"}
if (replyipv6address[ipv6addresspath][1] ~= nil) and (replyipv6address[ipv6addresspath][1].param ~= nil) then
  ipv6address = replyipv6address[ipv6addresspath][1].param["IPAddress"]
  if ipv6address == nil then
	ipv6address = ""
  end
end

--IPv6UserConfigurable value
local ipv6configpath = "Device.UserInterface.X_TELECOMITALIA_IT_WebPage"
local replyipv6config, error = mbus.getParameters{path = ipv6configpath, param = {"IPv6UserConfigurable"}, datamodel = "second"}
if (replyipv6config[ipv6configpath][1] ~= nil) and (replyipv6config[ipv6configpath][1].param ~= nil) then
  ipv6config=replyipv6config[ipv6configpath][1].param["IPv6UserConfigurable"]
end

--PPPEnable value
local PPPpath = "Device.PPP.Interface.2"
local replyppp, error = mbus.getParameters{path = PPPpath, datamodel = "second"}
if (replyppp[PPPpath][1] ~= nil) and (replyppp[PPPpath][1].param ~= nil) then
  pppEnable = replyppp[PPPpath][1].param["Enable"]
  pppConnectionStatus = replyppp[PPPpath][1].param["ConnectionStatus"]
end

--DNS ipv6 servers value
local dnsServer = {}
local dnscount = 0
local DNSpath = "Device.DNS.Client.Server"
local replydns, error = mbus.getParameters{path = DNSpath, param= {"DNSServer","Type"}, filter="(== Type DHCPv6)", datamodel = "second"}
if (replydns[DNSpath][1] ~= nil) and (replydns[DNSpath][1].param ~= nil) then
	for k,v in pairs(replydns[DNSpath]) do
		dnsServer[k] = v.param.DNSServer
		dnscount = k
	end
end

--LAN ipaddress
local lanaddresspath = "Device.IP.Interface.3.IPv6Address.2"
local lanipv6address, error = mbus.getParameters{path = lanaddresspath, param = {"IPAddress","Prefix"}, datamodel = "second"}
if (lanipv6address[lanaddresspath][1] ~= nil) and (lanipv6address[lanaddresspath][1].param ~= nil) then
  lanipaddress = lanipv6address[lanaddresspath][1].param["IPAddress"]
  lanprefixpath = lanipv6address[lanaddresspath][1].param["Prefix"]
  if lanipaddress == nil then
	lanipaddress = ""
  end
end

if lanprefixpath ~= nil then
	local lanipv6prefix, error = mbus.getParameters{path = lanprefixpath, param = {"Prefix"}, datamodel = "second"}
	if (lanipv6prefix[lanprefixpath][1] ~= nil) and (lanipv6prefix[lanprefixpath][1].param ~= nil) then
		lanprefix = lanipv6prefix[lanprefixpath][1].param["Prefix"]
	end
end

local bInfo = getDeviceBoardInfo()
local isipv6stausEnabled = getIPv6("Device.IP")

--split function
local replyusersession, error = mbus.getParameters{path = "Device.PPP.Interface", filter = "(== Name  User session)", datamodel = "second"}
if (replyusersession["Device.PPP.Interface"][1] ~= nil) then
   usersessionpath=replyusersession["Device.PPP.Interface"][1].path
end

local replyusername, error = mbus.getParameters{path = usersessionpath, param = {"Username"}, datamodel = "second"}
if (replyusername[usersessionpath][1] ~= nil) and (replyusername[usersessionpath][1].param ~= nil) then
  username = replyusername[usersessionpath][1].param["Username"]
end

if(username ~= nil) then
	spArray = split(username,"[@]")
	splitvalue = spArray[2]
end

-- POST start
if cgilua.servervariable "REQUEST_METHOD" == "POST" then
	local ipv6enablepath = "Device.IP"	
	local modify = {}
	local ipv6err = 0
	local changed = 0

	if splitvalue == "aliceres.v64routed" then
		regmanstring = bInfo.serialNumber.."-"..bInfo.ManufacturerOUI.."@".."aliceres.routed"
	elseif splitvalue == "aliceres.routed" then
		regmanstring = bInfo.serialNumber.."-"..bInfo.ManufacturerOUI.."@".."aliceres.v64routed"
	elseif splitvalue == "alicebiz.v64routed" then
		regmanstring = bInfo.serialNumber.."-"..bInfo.ManufacturerOUI.."@".."alicebiz.routed"
	elseif splitvalue == "alicebiz.routed" then
		regmanstring = bInfo.serialNumber.."-"..bInfo.ManufacturerOUI.."@".."alicebiz.v64routed"
	end
				tprint("regmanstring")
				tprint(regmanstring)
				
	if POST["IPv6State"] ~= nil then
		if POST["IPv6State"] == "1" and getIPv6("Device.IP") == "false" then
			table.insert(modify, {path = ipv6enablepath, param = {IPv6Enable = "true"}})	
			if ((splitvalue ~= "aliceres.v64routed") or (splitvalue ~= "alicebiz.v64routed")) and regmanstring ~= nil and regmanstring ~= "" then

				table.insert(modify,{path = usersessionpath,param = {Username = regmanstring}})
			end
			changed = 1
		end
		if POST["IPv6State"] == "0" and getIPv6("Device.IP") == "true" then
			table.insert(modify, {path = ipv6enablepath, param = {IPv6Enable = "false"}})	
			if ((splitvalue ~= "aliceres.routed") or (splitvalue ~= "alicebiz.routed")) and regmanstring ~= nil and regmanstring ~= "" then
				table.insert(modify,{path = usersessionpath,param = {Username = regmanstring}})
			end
			changed = 1
		end
		if changed == 1 then
		  ipv6err= setMBUS_IGD(modify)
		  -- Fix for Tessa 356 Increased the waiting time for ppp_0 to establish the connection
		  sleep(1)
		end	
		
		saveall(0, 1)
		cgilua.redirect("save_alert.lp", { u = "ipv6_Conf.lp"})
		return
	end
end	-- POST end
%>

</head>

<body>

<script language="javascript" type="text/javascript">
function confirmConfig()
{
	document.getElementById("ipv6form").style.display="none";
    document.getElementById("confirmIPv6Config").style.display="block";
}

function submit_ok()
{
  document.ipv6form.submit();
}

function closeConfirm()
{
  document.getElementById("ipv6form").style.display="block";
  document.getElementById("confirmIPv6Config").style.display="none";
}

</script>

<div class="contentContainer fontSize">
	<div class="breadCrumbContainer">
		<ul class="brdCrumb">
				<li><a href="advance.lp"><%=translate([==[Configure]==])%></a></li><li>|</li><li><a href="ipv6_Conf.lp">IPv6</a></li>
			</ul>
	</div>	
		
	<div class='contentcontainer' id="ipv6conf">
	<div id="ipv6tatus">
			
		<div class="contentTab" id="content">
			<ol id="tocTab">				
				<li><a id="ipv6Status" href="ipv6_Conf.lp" class="current">
					<div class="tab">
					<span class="tabIcon_stlan"></span>  
					<span class="contTabTxt transform"><%=translate([==[IPv6 Service]==])%></span>
					</div><div class="clrBth"></div></a>
				</li>
			</ol>
		</div>	
		
		<form method="POST" name="ipv6form" id="ipv6form" action="">	
			<div class='contentitem'>
			<%
			writePageHeader_new()
			writeBlockNoTitle()
			%>
			<tr class='midarea3' style="padding-left:0px;">
			  <td width="300px"><%=translate([==[State IPv6]==])%>:</td>
			  <td width="430px"colspan='2'>			
			  
				<input type="radio" value="1" id="enableIPv6" name="IPv6State">&nbsp;<%=translate([==[Active]==])%>&nbsp;&nbsp;&nbsp;&nbsp;
				<input type="radio" value="0" id="disableIPv6" name="IPv6State">&nbsp;<%=translate([==[Not active]==])%>
			  </td>
			</tr>
			<% endBlock() %>
			<% if ipv6config == "true" then%>
				<table><tr class='' style='padding-left:0px'>
					<td style='padding-left:250px'>
					<a style='color:black' onclick='confirmConfig()' href="#">
					<div class="midarea6-1 mainButton" name="thb6"><%=translate([==[Save]==])%></div></a></td>
					
					<td style='padding-left:50px'>
					<a style='color:black' href='advance.lp'>
					<div class="midarea6-1 mainButton" name="thb7"><%=translate([==[Cancel]==])%></div></a></td>
					</tr>
				</table>
				<% if ipv6Enable == "true" then%>
				<table cellspacing='0' cellpadding='0' width='100%'>
					<tr>
						<td class='midarea2 tableTitle'><%=translate([==[Internet Connection]==])%></td>
					</tr>
					<tr><td>
					<table width='100%' cellspacing='0' cellpadding='0' class="midarea4_telmain27 marleft40">
						<tr>
							<td width='300' style="padding:10px 0 0 0;"><%=translate([==[Public Address IPv6 connection from modem]==])%>:</td>
							<td><span><%if ipv6Enable == "true" and pppEnable == "true" and pppConnectionStatus ~= "Disconnected" then %><%=ipv6address%><%end%></span></td>
						</tr>
						<tr>
							<td width='300' style="padding:10px 0 0 0 ;"><%=translate([==[Primary DNS v6]==])%>:</td>
							<td><span><%if dnscount ~= 0 then %><%=dnsServer[1]%><%end%></span></td>
						</tr>						
						<tr>
							<td width='300' style="padding:10px 0 0 0 ;"><%=translate([==[Secondary DNS v6]==])%>:</td>
							<td><span><%if dnscount >= 2 then %><%=dnsServer[2]%><%end%></span></td>
						</tr>
						
						<tr>
							<td width='300' style="padding:10px 0 0 0 ;"><%=translate([==[Others DNS v6]==])%>:</td>							
							<td><%for i=3,dnscount do%><span><%=dnsServer[i]%></span><br><%end%></td>
							
						</tr>
					</table>
					</td></tr> 
				</table>
				<br>
				<table cellspacing='0' cellpadding='0' width='100%'>
					<tr>
						<td class='midarea2 tableTitle'><%=translate([==[State LAN IPv6]==])%></td>
					</tr>
					<tr><td>
					<table width='100%' cellspacing='0' cellpadding='0' class="midarea4_telmain27 marleft40">
						<tr>
							<td width='300' style="padding:10px 0 0 0;"><%=translate([==[Modem IPv6 Address]==])%>:</td>
							<td><span><%=lanipaddress%></span></td>
						</tr>
						<tr>
							<td width='300' style="padding:10px 0 0 0 ;"><%=translate([==[IPv6 prefix Modem]==])%>:</td>
							<td><span><%=lanprefix%></span></td>
						</tr>						
					</table>
					</td></tr> 
				</table>
				
				<tr>
					<td class="padleft230">
						<br><br>
						<a href="#" onclick='javascript: document.location.href="accessListv6.lp";'>
						<div class="midarea7-4 mainButton"><%=translate([==[Configure Firewall and IPv6 Access List]==])%></div></a>
					</td>
				</tr>
			<%end%>	
			<%end%>
			<% endPage() %>
			</div>
		</form>
	</div>
	</div>
	</div>
	

	
	<script src="js/antiCSRF.js" type="text/javascript"></script>
	<script language="javascript" type="text/javascript">
	<%if ipv6Enable == "true" then%>
		document.getElementById("enableIPv6").checked = true;
	<%else%>
		document.getElementById("disableIPv6").checked = true;
	<%end%>
	</script>

	<div id="confirmIPv6Config" name="confirmIPv6Config" style="display:none">
	<%cgilua.lp.include("webparts/confirmIPv6.lp")%>
	</div>
</body>
</html>
