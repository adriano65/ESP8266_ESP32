<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
	<title>Modem Telecom Italia</title>
	<link rel="stylesheet" href="css/master.css" type="text/css" />
	         <script language="JavaScript" type="text/javascript">
    if(window.parent.menu.document.getElementById("stcon")!=null && 
		window.parent.menu.document.getElementById("stcon") != "undefinded") {
		window.parent.menu.document.getElementById("stcon").className="";
	}
	
	if(window.parent.menu.document.getElementById("serte")!=null && 
		window.parent.menu.document.getElementById("serte") != "undefinded") {
		window.parent.menu.document.getElementById("serte").className="submenuselect";
	}

	if(window.parent.menu.document.getElementById("lanst")!=null && 
		window.parent.menu.document.getElementById("lanst") != "undefinded") {
		window.parent.menu.document.getElementById("lanst").className="";
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
<% cgilua.lp.include("lp/dsl.lp") %>
<% cgilua.lp.include("lp/mbus_util.lp") %>
<% cgilua.lp.include("lp/connectionService.lp") %>
<% cgilua.lp.include("lp/style.lp") %>
<%
local translate = translate
local POST=cgilua.POST

if cgilua.servervariable"REQUEST_METHOD" == "POST" then	
	local info2 = getPPP("PPP.Intf.2")
	local PPP_Device = getDevice_PPP()
	if PPP_Device~=nil and info2~=nil then
		if PPP_Device.connectionStatus ~= "Connected" then
	   		setDataPPP(info2.ppp_path, "enabled", "true")
			sleep(4)
		else
	   		setDataPPP(info2.ppp_path, "disabled", "false")
			sleep(2)
		end
	end
	saveall(15, 1)
end

-- get handler
local PPP_Device = getDevice_PPP()
local TI_Device = getTIInfo_Device()
local TI_info = getTIInfo()
local info1 = getPPP("PPP.Intf.1")
local info2 = getPPP("PPP.Intf.2")
local dsl = getDSLInfo()
local pubLan = getPubLAN()
local wanEthIntf = getLanStat("ethif5")

--WAN ETH Connection 
local wanConnType, wanConnTitle = getWANConnectionType()

--ADSL Status
local dslState, dslStateColor = translateDSLState_Servizi(dsl.dsl_status)	

--Management PPP of Telecom_Italia
local pppStatus, pppStatusColor = translateManagementPPPState(info1.ppp_status, info1.ipaddr, info1.connectionTrigger, dsl.dsl_status)

--Data PPP of User session
local pppPPPStatus = translate([==[Not active]==])
local pppPPPStatusColor = "tdRed"
local connectType = "Automatica"
local connProtocol = "PPPoE"
if info2~=nil then
	pppPPPStatus, pppPPPStatusColor, connectType = translateDataPPPState(info2.ppp_status, info2.connectionTrigger, pppPPPStatus, pppPPPStatusColor, connectType)
end

--STB status
local iptv_tatus = translate([==[Not present]==])
local IPTV_Ser = get_IPTVService()
if IPTV_Ser ~= "OFF" and IPTV_Ser ~= "Off" then
	local intf = string.sub(tostring(IPTV_Ser), -1)
	iptv_tatus = translate([==[Active on Ethernet port ]==]) .. intf
  	if IPTV_Ser == "Dyn_Portmapping" then
			iptv_tatus = translate([==[Actived]==])
		end
end

--Get the wanEtherIntf state color
local wanStatusColor = "tdRed"
if wanEthIntf.state=="Active" then
    wanStatusColor = "tdGreen"
end
%>

<body>
<div class="contentContainer">
	 
		<div class="breadCrumbContainer">
			<ul class="brdCrumb">
				<li><a href="standard.lp"><%=translate([==[Basic Settings]==])%></a></li><li>|</li><li><a href="statoServizi.lp"><%=translate([==[Telecom Italia Services]==])%></a></li>
			</ul>
		</div>	

		
		<div class="contentTab" id="content">
			<ol id="tocTab_tiServices"  style="list-style-type: none;">
				<li><a class="current">
		<div class="tab">
			<span class="tabIcon_conn"></span>  
			<span class="contTabTxt transform"><%=translate([==[Telecom Italia Services]==])%></span>
		</div>
		<div class="clrBth"></div></a></li>
			</ol>
		</div>
		
	<div class="contentcontainer">
	<div class='contentitem'> 
	<form method="POST" id="modemState" name="modemState" action="">
	<table cellspacing='0' cellpadding='0' border="0" >
	<tr>
	<td>
	<table cellspacing='0' cellpadding='0' border="0" class="fontSize">
	<tr>
	<td>

	<table cellspacing='0' cellpadding='0' border="0">
		<tr>
		<td class="midarea2 tableTitle"><%=translate([==[Connectivity]==])%></td>
		</tr></table> 

		
			<table cellspacing='0' cellpadding='0' border="0">
			 
			<tr><td> 

	<%if isDefaultConf() then%> 
				<!-- Begin of warning events-->
				<table cellspacing='0' cellpadding='0' width='100%'>
				<tr><td width='40' class="verticalAlign"></td><td class=" verticalAlign midareainfo">Info</td></tr>
				<tr><td width='40' class="verticalAlign"></td>
				<td class="verticalAlign"> 
				<table  class='midarea4' width='100%' cellspacing='0' cellpadding='0' style="line-height:150%;padding-left:0px"> 
				<tr>
					<td><%=translate([==[Your modem is not yet configured services for Telecom Italy]==])%>.</td>
				</tr> 
				</table> 
				</td></tr></table> <!-- End of warning events-->
	<%else%>
				<!-- Begin of Internet Connection-->
				<!--<table cellspacing='0' cellpadding='0' width='100%'><tr> <td width='40' style='vertical-align:top'>&nbsp;</td> <td style='vertical-align:top'> -->
				<table cellspacing='0' cellpadding='0' class="martop5">
				<tr>
				<td class="midarea2 tableTitle"><%=translate([==[Internet Link]==])%></td></tr><tr><td>
				<table width='100%' cellspacing='0' cellpadding='0' class='servizitable fontSize' style="line-height:150%;"> 
							<tr>
							<td width='300' class="sectionArea-1 padleft40" ><%=translate([==[rate profile]==])%>:</td>
							<td colspan='3' class="sectionArea-2"><%=TI_info.profile%></td></tr>  			
							<tr>
							<td width='300' class="sectionArea-1 padleft40"><%=translate([==[Mode]==])%>:</td>
							<td colspan='3' class="sectionArea-2"><%=TI_info.connectMode%>	</td></tr> 

	<%
	if info2~=nil then
	if (((TI_Device.lanOption == "res-rt-napt" or TI_Device.lanOption == "res-rt-napt-ipv6") and PPP_Device.connectionTrigger == "X_TELECOMITALIA_IT_Conditional")   
		   or ((TI_Device.lanOption == "biz-rt-napt-ena" or TI_Device.lanOption == "biz-rt-napt-ipv6")and PPP_Device.connectionTrigger == "AlwaysOn"))
		   and PPP_Device.name == "User session" then%>
				<tr ><td width='300' class="sectionArea-1 padleft40 verticalAlign padtop5"><%=translate([==[Automatic connection by modem]==])%>:</td>
				<%if PPP_Device.connectionStatus == "Unconfigured" then%>
					<td width='150' class="tdRed verticalAlign padtop5"><%=translate([==[Unconfigured]==])%></td>
				<%elseif PPP_Device.connectionStatus == "Connecting" then%>
					<td width='150' class="tdOrange verticalAlign padtop5"><%=translate([==[Connecting]==])%></td>
				<%elseif PPP_Device.connectionStatus == "Authenticating" then%>
					<td width='150' class="tdRed verticalAlign padtop5"><%=translate([==[Authenticating]==])%></td>
				<%elseif PPP_Device.connectionStatus == "Connected" then%>
					<td width='150' class="tdGreen verticalAlign padtop5"><%=translate([==[Active]==])%></td>
				<%elseif PPP_Device.connectionStatus == "PendingDisconnect" or PPP_Device.connectionStatus == "Disconnecting" then%>
					<td width='150' class="tdRed verticalAlign padtop5"><%=translate([==[Disconnecting]==])%></td>
				<%else%>
					<td width='150' class="tdRed verticalAlign padtop5"><%=translate([==[Not active]==])%></td>
				<%end%>
				<td class="fleft verticalAlign">
		<% if (TI_Device.lanOption == "res-rt-napt" or TI_Device.lanOption == "res-rt-napt-ipv6")and PPP_Device.connectionTrigger == "X_TELECOMITALIA_IT_Conditional" then %>
				
			<% if isRemoteAccess()==false then%>
			<%if PPP_Device.connectionStatus ~= "Connected" then%>
				<a href ="javascript:submitServizi()"><div class="midarea6-1 mainButton" name="thbA5"><%=translate([==[Active]==])%></div></a>
			<%else%>
				<a href ="javascript:submitServizi()"><div class="midarea6-1 mainButton" name="thbA4"><%=translate([==[Disable]==])%></div></a>
			<%end%>
			<%end%>
			
			<%end%>
				</td></tr>
	<%if (TI_Device.lanOption == "res-rt-napt" or TI_Device.lanOption == "biz-rt-napt-ena") and PPP_Device.name== "User session" then%>
				<tr><td width='300' class="sectionArea-1 padleft40 padtop5"><%=translate([==[Public IP address from your modem connection]==])%>:</td><td colspan='3' class="sectionArea-2 padtop5"><%=info2.ipaddr%></td></tr>
	<%end%>
	<%end end%>
				</table> 
				<!--</td></tr></table>-->
				<!-- End of Internet Connection-->
			
				<!-- Begin of WAN Connection-->
				<table cellspacing='0' cellpadding='0' width='100%' border="0" class="padtop10">
				<tr>
				<td class="verticalAlign"> 
				<table cellspacing='0' cellpadding='0' border="0" >
				<tr>
				<td class="midarea2 tableTitle"><%=wanConnTitle%>
				</td>
				</tr><tr><td>
				<table width='100%' cellspacing='0' cellpadding='0' class='servizitable fontSize' style="line-height:150%;"> 
						<%if wanConnType=="ETH" then%><!-- WAN Ethernet -->
				<%if wanEthIntf.state=="Active" then%>
					<tr><td  class="sectionArea-1 padleft40" ><%=translate([==[FIBER Ethernet service]==])%>:</td><td colspan='3' class="<%=wanStatusColor%>"><%=translate([==[Actived]==])%></td></tr>
				<%elseif wanEthIntf.state=="Inactive" then%>	
					<tr ><td  class="sectionArea-1 padleft40"><%=translate([==[FIBER Ethernet service]==])%>:</td><td colspan='3' class="<%=wanStatusColor%>"><%=translate([==[Inactived]==])%></td></tr>
				<% end%>
			<%elseif wanConnType=="VDSL" then%>
				<tr ><td  class="sectionArea-1 padleft40"><%=translate([==[VDSL service]==])%>:</td><td colspan='3' class="<%=dslStateColor%>"><%=dslState%></td></tr>
				<tr ><td  class="sectionArea-1 padleft40"><%=translate([==[Speed in transmission]==])%>(Kbps):</td><td colspan='3' class="sectionArea-2"><%=dsl.upstream%></td></tr> 
				<tr ><td  class="sectionArea-1 padleft40"><%=translate([==[Receiving speeds]==])%>(Kbps):</td><td colspan='3' class="sectionArea-2"><%=dsl.downstream%></td></tr>
			<%else%>
				<tr><td  class="sectionArea-1 padleft40"><%=translate([==[ADSL Service]==])%>:</td><td colspan='3' class="<%=dslStateColor%>"><%=dslState%></td></tr>
				<tr ><td  class="sectionArea-1 padleft40"><%=translate([==[Speed in transmission]==])%>(Kbps):</td><td colspan='3'
				class="sectionArea-2"><%=dsl.upstream%></td></tr> 
				<tr><td  class="sectionArea-1 padleft40" ><%=translate([==[Receiving speeds]==])%>(Kbps):</td><td colspan='3' style="color:#5e5e5e;width:330px;"
				class="sectionArea-2"><%=dsl.downstream%></td></tr>
			<% end%>
				
					
				</table> 
				</td></tr></table><!-- End of WAN Connection-->
	</table>			
	<tr>
	<%
	if TI_Device.lanOption ~= "biz-br" and TI_Device.lanOption ~= "biz-rt-napt-ena" and TI_info.lanOption ~= "biz-rt-napt-ipv6" then
	-- Begin of IPTV
	%>
	<td align='left'><table cellspacing='0' cellpadding='0' class="padtop10">
		  <tr>
				<td class="midarea2 tableTitle"><%=translate([==[IPTV]==])%>
		</td></tr></table></td>
	<tr><td>
	<table cellspacing='0' cellpadding='0' class='servizitable fontSize'>
	  <%
	  writeSectionRow(translate([==[IPTV service]==]), iptv_tatus)
	  if TI_info.stbConnected == "false" then
		writeSectionRow(translate([==[Decoder Telecom Italia]==]), translate([==[Unconfigured]==]))
	  else
		for i=1, TI_info.stbConnected_num do
		  writeSectionRow(translate([==[Decoder Telecom Italia]==]), translate([==[Connected to Ethernet port ]==]) .. TI_info.stbIntf[i])
		end
	  end
	  %>
     </table></td></tr>
	  <%
	  endBlock()
	-- End of IPTV
	
	-- Begin of Managed TV
	local managedTV_Path = "Device.DHCPv4.Client.1"
	local reply, error = mbus.getParameters{path = managedTV_Path, datamodel = "second"}
	local m_Enable = reply[managedTV_Path][1].param["Enable"]
	local m_Status = reply[managedTV_Path][1].param["Status"]
	local m_dhcpStatus = reply[managedTV_Path][1].param["DHCPStatus"]
	%>

	<table cellspacing='0' cellpadding='0' class="fontSize padtop10"><tr><td class="midarea2 tableTitle"><%=translate([==[MANAGED TV]==])%></td></tr></table>
	<table width='100%' cellspacing='0' cellpadding='0' style="line-height:150%;width:640px" class="servizitable width750"> 
		<tr>
		<td class="sectionArea-1 padleft40"><%=translate([==[Managed TV Service]==])%>:</td><td class="sectionArea-1"><%if m_Enable == "true" then%><%=translate([==[Actived]==])%><%else %><%=translate([==[Not present]==])%><% end%></td></tr>
		<tr>
		<%if m_Status ~= "Disabled" then%>
		<%if m_Status == "Error_Misconfigured" or m_Status == "Error" then%>
		<td class="sectionArea-1 padleft40"><%=translate([==[Addressing State]==])%>:</td>
		<td class="sectionArea-1"><%=translate([==[Anomaly]==])%></td>
		<%else if m_Status == "Enabled" then%>
		<td class="sectionArea-1 padleft40"><%=translate([==[Addressing State]==])%>:</td>
		<td class="sectionArea-1"><%if m_dhcpStatus == "INIT" then%><%=translate([==[Initialization]==])%><%elseif m_dhcpStatus == "SELECTING" then%><%=translate([==[Selection in progress]==])%><%elseif m_dhcpStatus == "REQUESTING" then%><%=translate([==[Request in progress]==])%><%elseif m_dhcpStatus == "REBINDING" then%><%=translate([==[Reassigning in progress]==])%><%elseif m_dhcpStatus == "BOUND" then%><%=translate([==[Assigned]==])%><%elseif m_dhcpStatus == "RENEWING" then%><%=translate([==[Renewal in progress]==])%><%else%><%=m_dhcpStatus%><%end%></td></tr>
		
		<%local managedTV_IP_Path = "Device.IP.Interface.4.IPv4Address.1"
		local reply, error = mbus.getParameters{path = managedTV_IP_Path, datamodel = "second"}
		local m_IP = reply[managedTV_IP_Path][1].param["IPAddress"]%>
		
		<tr><td class="sectionArea-1 padleft40"><%=translate([==[IP Address]==])%>:</td><td class="sectionArea-1"><%=m_IP%>&nbsp;</td></tr>  
		<%end end end%>
	</table>
	<!-- End of Managed TV -->
	<%end%>
	
	<%if true then
		if pubLan.isPubLan then
			pubLanStatus = translate([==[not Active]==])
			pubLanStatusColor = "tdRed"
			if pubLan.pubLanEnable then
				pubLanStatus = translate([==[Active]==])
				pubLanStatusColor = "tdGreen"
			end
	%>
<!-- Begin of LAN public-->
				<table cellspacing='0' cellpadding='0' class="fontSize padtop10"><tr><td class="midarea2 tableTitle"><%=translate([==[LAN Public]==])%></td></tr></table>
				<table width='100%' cellspacing='0' cellpadding='0' style="line-height:150%;width:640px" class="servizitable width750"> 
				<tr>
				<td class="sectionArea-1 padleft40"><%=translate([==[Public LAN Service]==])%>:</td><td class="<%=pubLanStatusColor%>"><%=pubLanStatus%></td></tr>
				<tr>
				<td class="sectionArea-1 padleft40"><%=translate([==[default Gateway]==])%>:</td><td class="sectionArea-1"><%=pubLan.pubIpDef%></td></tr>
				<tr>
				<td class="sectionArea-1 padleft40"><%=translate([==[Subnet Mask]==])%>:</td><td class="sectionArea-1"><%=pubLan.pubIpMask%></td></tr>  
				<tr>
				<td class="sectionArea-1 padleft40"><%=translate([==[start IP]==])%>:</td><td class="sectionArea-1"><%=pubLan.beginip%></td></tr> 	
				<tr>
				<td class="sectionArea-1 padleft40"><%=translate([==[end IP]==])%>:</td><td class="sectionArea-1"><%=pubLan.endip%></td></tr> 
				<tr>
				<td class="sectionArea-1 padleft40"><%=translate([==[Primary DNS]==])%>:</td><td class="sectionArea-1"><%=getDefaultDNS("1")%></td></tr> 
				<tr>
				<td class="sectionArea-1 padleft40"><%=translate([==[Secondary DNS]==])%>:</td><td class="sectionArea-1"><%=getDefaultDNS("2")%></td></tr> 
				</table> </td></tr>
				</td></tr></table><!-- End of LAN public-->
	<%
		end 
	end
	%>
	<%end%>
			</td></tr>
	</table>
	</td></tr></table>
	</form>
	</div> 
	</div>
	</div>
	<script language="javascript">
	function submitServizi() {
		document.modemState.submit();
	}
	</script>
	<script src="js/antiCSRF.js"></script>

	</body>
	</html>

