<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
          "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<title>Modem Telecom Italia</title>
<link rel="stylesheet" href="css/master.css" type="text/css"/>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
	 <script language="JavaScript" type="text/javascript">
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
		window.parent.menu.document.getElementById("wifi2li").style.display="none";
		window.parent.menu.document.getElementById("wifi2li").style.display="none";
		window.parent.menu.document.getElementById("wifi5li").style.display="none";
		window.parent.menu.document.getElementById("wifist").className="";
		window.parent.menu.document.getElementById("wifi2").className="";
		window.parent.menu.document.getElementById("wifi5").className="";
		window.parent.menu.document.getElementById("wifi_guest").className="";
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
	
  </script>
</head>
<% cgilua.lp.include("lp/language.lp") %>
<% cgilua.lp.include("lp/common.lp") %>
<% cgilua.lp.include("lp/device.lp") %>
<% cgilua.lp.include("lp/ppp.lp") %>
<% cgilua.lp.include("lp/util.lp") %>
<% cgilua.lp.include("lp/mbus_util.lp") %>
<% cgilua.lp.include("lp/lan.lp") %>
<%
local translate = translate
local ppp = getPPP("PPP.Intf.2")
local TI_Device = getTIInfo_Device()
local device_PPP = getDevice_PPP()
local TI_info = getTIInfo()
local info = getIPInfo()
local pubLan = getPubLAN() 
local natStatus = nil
if ppp~=nil then
  natStatus = get_deviceNatStatus()
end
local naptState = translate([==[Inactived]==])
if natStatus.enable == "true" then
	naptState = translate([==[Actived]==])
end
local dhcpState = translate([==[Inactived]==])
if info.enable=="true" then
	dhcpState = translate([==[Actived]==])	
end
local ethdevices, wlandevices, usbdevices = get_Devices()
local devices = reassignlist()
%>
<body>
	<div class="contentContainer">
		<div class="breadCrumbContainer">
			<ul class="brdCrumb">
				<li><a href="standard.lp"><%=translate([==[Basic Settings]==])%></a></li><li>|</li><li><a href="lanStatus.lp"><%=translate([==[LAN]==])%></a></li>
			</ul>
		</div>	
						<div class="contentTab" id="content">
							<ol id="tocTab">
								
								<li><a href="lanStatus.lp" class="current">
									<div class="tab">
										<span class="tabIcon_stlan"></span>  
										<span class="contTabTxt transform"><%=translate([==[LAN State]==])%></span>
									</div>
									<div class="clrBth">
									</div></a></li>
				<% if isRemoteAccess() == false then %>
								<li><a class="margin15" href="lanConfig.lp">
									<div class="tab">
									<span class="contTabTxt transform"><%=translate([==[LAN Configuration]==])%></span></div></a></li>
				<% end %>
							</ol>
						</div>
						
<div class="contentcontainer">
<hr>
<div class='contentitem'> 
<table cellspacing='0' cellpadding='0' width="100%" class="fontSize">
<tr>
	<!-- <td class='icon' style='vertical-align:top' width='100px'><img src='images/ieth__xl.gif' alt='Technicolor Gateway'></td>  -->
	<td>
		<!-- <table cellspacing='0' cellpadding='0' width="100%">
			<tr>
				<td align='left' class="midarea2" style="font-weight:bold"><span class='itemtitle'><%=translate([==[LAN State]==])%></span></td>
			</tr> --> 
			<tr>
				<td> 
			<!-- Begin of private LAN State-->
		<table cellspacing='0' cellpadding='0' width='100%' class='infotable datatable fontSize padtop10' >
			<tr>
				<!-- <td width='40' style='vertical-align:top'><img src='images/bull__md.gif' alt=''></td> -->
				<td class="midarea2 tableTitle"><%=translate([==[LAN State]==])%>
				</td></tr><tr><td>
		<table width='100%' class='datatable' cellspacing='0' cellpadding='0' style="line-height:150%;"> 
			<tr>
				<td width='300' class="padleft40"><%=translate([==[Modem IP Address]==])%>:</td>
				<td colspan='3'><%=info.ipaddress%></td>
			</tr> 
			<tr>
				<td width='300' class="padleft40"><%=translate([==[Subnet Mask]==])%>:</td>
				<td colspan='3'><%=info.ipmask%></td>
			</tr> 
		</table> 
				</td>
			</tr>
		</table> 
		
		<%if info.pubEnable ~= nil and info.pubEnable == "true" then%>
		<table cellspacing='0' cellpadding='0' width='100%' class='infotable datatable fontSize padtop10' >
			<tr>
				<td class="midarea2 tableTitle"><%=translate([==[public LAN State]==])%>
				</td></tr><tr><td>
		<table width='100%' class='datatable' cellspacing='0' cellpadding='0' style="line-height:150%;"> 
			<tr>
				<td width='300' class="padleft40"><%=translate([==[Modem IP Address]==])%>:</td>
				<td colspan='3'><%if info.pubIp ~= nil and info.pubIp ~= "" then %><%=info.pubIp%><% else%>&nbsp;<%end%></td>
			</tr> 
			<tr>
				<td width='300' class="padleft40"><%=translate([==[Subnet Mask]==])%>:</td>
				<td colspan='3'><%if info.pubSubmask ~= nil and info.pubSubmask ~= "" then %><%=info.pubSubmask%><% else%>&nbsp;<%end%></td>
			</tr> 
		</table> 
				</td>
			</tr>
		</table>
		<%end%>
		
		<table cellspacing='0' cellpadding='0' width='100%' class="fontSize padtop10">
			<tr>
				<!-- <td width='40' style='vertical-align:top'><img src='images/bull__md.gif' alt=''></td> -->
				<td class="midarea2 tableTitle"><%=translate([==[DHCP Service State]==])%></td>
				</tr>
			<tr><td>
		<table width='100%'  class='infotable datatable fontSize' cellspacing='0' cellpadding='0' style="line-height:150%;"> 

			<tr>
				<td width='300' class="padleft40"><%=translate([==[DHCP State]==])%>:</td>
				<td colspan='3'><%=dhcpState%></td>
			</tr> 
			<tr>
				<td width='300' class="padleft40"><%=translate([==[start IP]==])%> DHCP:</td>
				<td colspan='3'><%=info.beginip%></td>
			</tr> 
			<tr>
				<td width='300' class="padleft40"><%=translate([==[end IP]==])%> DHCP (<%=translate([==[Reserved for internal use]==])%>):</td>
				<td colspan='3'><%=info.endip%></td>
			</tr> 
		</table> 
				</td>
			</tr>
		</table>


		<% if(device_PPP.enable == "true") then %>
			
		<table cellspacing='0' cellpadding='0' width='100%' class="fontSize padtop10">
			<tr>
				<!-- <td width='40' style='vertical-align:top'><img src='images/bull__md.gif' alt=''></td> -->
				<td class="midarea2 tableTitle"><%=translate([==[NAT Service State]==])%></td>
				</tr>
				<tr><td>
		<table width='100%'  class='infotable datatable fontSize' cellspacing='0' cellpadding='0' style="line-height:150%;text-align:left;"> 
		<tr>
<td  width='300' class="padleft40"><%=translate([==[NAT State]==])%>:</td><td><%=naptState%></td>

</tr>
<% if natStatus.enable == "true" then %>
<tr>
				<td   width='300' class="padleft40"><%=translate([==[start IP]==])%> NAT:</td>
				<td ><%=ppp.natStartIPAddress%></td>
			</tr>
			<tr>
				<td  width='300' class="padleft40"><%=translate([==[end IP]==])%> NAT:</td>
				<td ><%=ppp.natEndIPAddress%></td>
			</tr>
<%end%>			
		</table> 
				</td>
			</tr>
		</table>	
<%end%>		<!-- End of private LAN State-->
			<!-- Begin of LAN Connections-->
			
		<table cellspacing='0' cellpadding='0' width='100%' class="fontSize width770 padtop10">
			<tr>
				<!-- <td width='40' style='vertical-align:top'><img src='images/bull__md.gif' alt=''></td> -->
				<td class="midarea2 tableTitle"><%=translate([==[LAN Connections]==])%></td>
				
				<tr><td>
		<table class='edittable fontSize valueSpace ipReserve width700' width='100%' cellspacing='0' cellpadding='0' border='0'> 
			<% local ipv6Enable = getIPv6("Device.IP")%>	 
			<tr>
				<td class="tableHd width175"  align='left'><%=translate([==[Interface]==])%></td>
				<td class="tableHd width175"  align='left'><%=translate([==[HOST Name]==])%></td>
				<td class="tableHd width175"  align='left'><%=translate([==[MAC Address]==])%></td>
				<td class="tableHd width175"  align='left'><%=translate([==[IP Address]==])%></td>
				<%if ipv6Enable == "true" then %><td class="tableHd width175"  align='left'><%=translate([==[IPv6 Address]==])%></td><%end%>
			</tr> 
			<tr>
				<td <%if ipv6Enable == "true" then %>colspan='5' <%else %>colspan='4' <%end%>><!-- <img src='images/spacer.gif' border='0' width='1' height='3' alt=''><br> --></td>
			</tr>
			<tr>
				<td <%if ipv6Enable == "true" then %>colspan='5' <%else %>colspan='4' <%end%>><img src='images/spacer.gif' border='0' width='1' height='3' alt=''><br></td>
			</tr> 	
				<% 
				local rowStyle = "oddrow"
				local rowNum = 0
				local cnt=0 for i,v in pairs(ethdevices) do cnt=cnt+1 end; if(cnt~=0) then for i,v in pairs(ethdevices) do 
					rowNum = rowNum + 1
					if rowNum%2==1 then
						rowStyle = "oddrow"
					else
						rowStyle = "evenrow"
					end
				%>
			<tr>
				<td   class='<%=rowStyle%>' <%if ipv6Enable == "true" then %>colspan='5' <%else %>colspan='4' <%end%>><!-- <img src='images/spacer.gif' border='0' width='1' height='3' alt=''><br> --></td>
			</tr>
			<tr>
				<td class="<%=rowStyle%> alignMid">Ethernet <%=v.ethIndex%></td>
				<td class="<%=rowStyle%> alignMid"><%=v.name%></td>
				<td class="<%=rowStyle%> alignMid"><%=v.mac%></td>
				<td class="<%=rowStyle%> alignMid"><%=v.ip%></td>
				<%if ipv6Enable == "true" then %><td class="<%=rowStyle%> alignMid"><%=v.ipv6%></td><%end%>
			</tr>
			<tr>
				<td class="<%=rowStyle%>" <%if ipv6Enable == "true" then %>colspan='5' <%else %>colspan='4' <%end%>><img src='images/spacer.gif' border='0' width='1' height='3' alt=''></td>
			</tr> 
				<% end end %>
				<% local cnt=0 for i,v in pairs(wlandevices) do cnt=cnt+1 end; if(cnt~=0) then for i,v in pairs(wlandevices) do  
					rowNum = rowNum + 1
					if rowNum%2==1 then
						rowStyle = "oddrow"
					else
						rowStyle = "evenrow"
					end
				%>
			<tr>
				<td class='<%=rowStyle%>' <%if ipv6Enable == "true" then %>colspan='5' <%else %>colspan='4' <%end%>><img src='images/spacer.gif' border='0' width='1' height='3' alt=''></td>
			</tr>
			<tr>
				<% 
					local band = ""
					if v.radioIndex=="1" then
					   band = "2.4GHz"
					elseif v.radioIndex=="2" then
					   band = "5GHz"
					else
						band = translate( [==[Guests]==])
					end
				%>
				<td class="<%=rowStyle%> alignMid">Wi-Fi <%=band%></td>
				<td class="<%=rowStyle%> alignMid"><%=v.name%></td>
				<td class="<%=rowStyle%> alignMid"><%=v.mac%></td>
				<td class="<%=rowStyle%> alignMid"><%=v.ip%></td>
				<%if ipv6Enable == "true" then %><td class="<%=rowStyle%> alignMid"><%=v.ipv6%></td><%end%>
			</tr>
			<tr>
				<td class="<%=rowStyle%>" <%if ipv6Enable == "true" then %>colspan='5' <%else %>colspan='4' <%end%>><img src='images/spacer.gif' border='0' width='1' height='3' alt=''><br></td>
			</tr>
				<% end end %>				
	</table>
				</td>
			</tr>
	</table> <!-- End of LAN Connections-->
			<!-- Begin of LAN Reservation-->
			
		<table cellspacing='0' cellpadding='0' width='100%' class="fontSize width770 padtop10">
			<tr>
				<!-- <td width='40' style='vertical-align:top'><img src='images/bull__md.gif' alt=''></td> -->
				<td class="midarea2 tableTitle"><%=translate([==[IP Reservation]==])%></td>
				<tr>
		<table class='edittable fontSize valueSpace ipReserve width700' width='100%' cellspacing='0' cellpadding='0' border='0'> 
			<tr>
				<td align='left' class="tableHd width175" ><%=translate([==[HOST Name]==])%></td>
				<td align='left' class="tableHd width175" ><%=translate([==[MAC Address]==])%></td>
				<td align='left' class="tableHd width175" ><%=translate([==[IP Address]==])%></td>
				<td align='left' class="tableHd width175" ><%=translate([==[Reservation Status]==])%></td>
			</tr> 
			<tr>
				<td colspan='4'><img src='images/spacer.gif' border='0' width='1' height='3' alt=''><br></td>
			</tr> 
			<tr>
				<td colspan='4' class='black'><img src='images/spacer.gif' border='0' width='1' height='1' alt=''><br></td>
			</tr> 	
				<% 
				local rowStyle = "oddrow"
				local rowNum = 0
				for i,v in pairs(devices) do 
					local ip_addr = v.ip
	              			local reservationStatus = translate([==[Unreserved]==])
              				if v.staticenable=="true" then                				
						ip_addr = v.newip
						reservationStatus = translate([==[Reserved]==])
					end

					rowNum = rowNum + 1
					if rowNum%2==1 then
						rowStyle = "oddrow"
					else
						rowStyle = "evenrow"
					end
				%>
			<tr>
				<td class='<%=rowStyle%>' colspan='4'><img src='images/spacer.gif' border='0' width='1' height='3' alt=''></td>
			</tr>
			<tr>				
				<td class="<%=rowStyle%> alignMid" ><%=v.name%></td>
				<td class="<%=rowStyle%> alignMid" ><%=v.mac%></td>
				<td class="<%=rowStyle%> alignMid" ><%=ip_addr%></td>
				<td class="<%=rowStyle%> alignMid" ><%=reservationStatus%></td>
			</tr>
			<tr>
				<td class="<%=rowStyle%>" colspan='4'><img src='images/spacer.gif' border='0' width='1' height='3' alt=''></td>
			</tr> 
				<% end %>							
	</table>
				</td>
			</tr>
	</table>
			<!-- End of LAN Reservation-->
				</td>
			</tr>
	</table>
				</td>
			</tr>
	</table>
</div> 
</div>		
</div>
</body>
</html>