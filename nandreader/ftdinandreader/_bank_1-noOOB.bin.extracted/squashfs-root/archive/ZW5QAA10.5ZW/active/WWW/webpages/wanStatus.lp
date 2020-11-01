<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
<html>
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
	<title>Modem Telecom Italia</title>
	<link rel="stylesheet" href="css/master.css" type="text/css" />
         <script language="JavaScript" type="text/javascript">
    if(window.parent.menu.document.getElementById("stcon")!=null && 
		window.parent.menu.document.getElementById("stcon") != "undefinded") {
		window.parent.menu.document.getElementById("stcon").className="submenuselect";
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
<% cgilua.lp.include("lp/connectionService.lp") %>
<%
local translate = translate

if cgilua.servervariable"REQUEST_METHOD" == "POST" then
	local info2 = getPPP("PPP.Intf.2")
	local PPP_Device = getDevice_PPP()
	if PPP_Device~=nil and info2~=nil then
		local modify ={}
		if PPP_Device.connectionStatus ~= "Connected" then

			setDataPPP(info2.ppp_path, "enabled", "true")
			sleep(5)
			saveall(15, 1)
			--If the ppp is still not active, it should be redirected to the helpLinkDown page.
			if isDataPPPNotConnected() then
				cgilua.print("<body><script language='JavaScript'>window.parent.location.href='noconnect.html';</script></body></html>")
				return
			end
		else

			setDataPPP(info2.ppp_path, "disabled", "false")
			sleep(2)
			saveall(15, 1)
		end
	end

end


function get_iptv_active()
 local result={}
 local active, error =  mbus.getParameters{path = "TI_STORE.TiUserIntf", param = "IPTV_Active"}
 return active["TI_STORE.TiUserIntf"][1].param["IPTV_Active"] 
end


-- get handler
local TI_info = getTIInfo()
local PPP_Device = getDevice_PPP()
local TI_Device = getTIInfo_Device()
local info2 = getPPP("PPP.Intf.2")
local dsl = getDSLInfo()
local iptv_active = get_iptv_active()
local board = getBoardInfo()
local wanEthIntf = getLanStat("ethif5")

--WAN ETH Connection 
local wanConnType, wanConnTitle = getWANConnectionType()	

--ADSL Status
local dslState, dslStateColor = translateDSLState(dsl.dsl_status)

--ADSL Mode
local dslModulationType = translateDSLMode(dsl.dsl_ModulationType)

--Management PPP of Telecom_Italia
local pppManagementState = getPPPManagementState()
local pppManagementStateColor = "tdRed"
if pppManagementState=="Connected" then
	pppManagementStateColor = "tdGreen"
	pppManagementState=translate([==[Connected]==])
elseif pppManagementState=="Connecting" then
	pppManagementStateColor = "tdOrange"
	pppManagementState=translate([==[Connecting]==])
else
	pppManagementState=translate([==[Disconnected]==])
end

--Data PPP of User session
local pppPPPStatus = translate([==[Not active]==])
local pppPPPStatusColor = "tdRed"
local connectType = "Automatica"
local connProtocol = "PPPoE"
if info2~=nil then
	pppPPPStatus, pppPPPStatusColor, connectType = translateDataPPPState(info2.ppp_status, info2.connectionTrigger, pppPPPStatus, pppPPPStatusColor, connectType)
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
				<li><a href="standard.lp">Impostazioni Base</a></li><li>|</li><li><a href="wanStatus.lp"><%=translate([==[Connection Status]==])%></a></li>
			</ul>
		</div>	

		<div class="contentTab" id="content">
			<ol id="tocTab">
				<li><a class="current">
		<div class="tab">
			<span class="tabIcon_stcon"></span>  
			<span class="contTabTxt transform"><%=translate([==[Connection Status]==])%></span>
		</div>
		<div class="clrBth"></div></a></li>
			</ol>
		</div>
		
<div class='contentcontainer'>	
<div class='contentitem'> 
<table cellspacing='0' cellpadding='0' class="fontSize">
<tr>
<td>
<table  cellspacing='0' cellpadding='0' width='100%' >
	 <%if isDefaultConf() then%> 
			<br><!-- Begin of warning events-->
			<table cellspacing='0' cellpadding='0' width='100%'>
			<tr><td width="40" valign="top">&nbsp;</td><td class='midareainfo'>Info</td></tr>
			<tr>
			<td width='40' class="verticalAlign"></td>
			<td class="verticalAlign"> 
			<table width='100%' class='midarea4' cellspacing='0' cellpadding='0' style="line-height:150%;padding-left:0px;"> 
			<tr><td><%=translate([==[Attention: Research and WAN interface configuration in progress]==])%>.</td></tr> 
			</table> 
			</td></tr></table>
			<!-- <tr><td class="midarea3" style="font-weight:bold"><%=translate([==[Attention: Research and WAN interface configuration in progress]==])%>.</td></tr> -->
			 <!-- End of warning events-->
<%else%> 
			<!-- Begin of DeviceInfo-->
	<tr>
	<td class="verticalAlign"> <table cellspacing='0' cellpadding='0' class="martop5">
	<tr>
	<td class="midarea2 tableTitle">
		        <%=translate([==[Identification data modem]==])%></td></tr></table></td>
				</tr>
<tr><td>
			<table width='100%'  cellspacing='0' cellpadding='0' class='servizitable fontSize' style="line-height:150%;"> 
			
			 <tr><td class="sectionArea-1 padleft40"><%=translate([==[Model]==])%>:</td><td colspan='3' class="sectionArea-2"><%=board.pname%></td></tr> 
			 <tr><td class="sectionArea-1 padleft40"><%=translate([==[Seriale Modem]==])%>:</td><td colspan='3' class="sectionArea-2"><%=board.sn%></td></tr>		
			 <tr><td class="sectionArea-1 padleft40"><%=translate([==[Hardware Version]==])%>:</td><td colspan='3' class="sectionArea-2"><%=board.bversion%></td></tr> 
			 <tr>
			 <td class="sectionArea-1 padleft40"><%=translate([==[Software Version]==])%>:</td><td colspan='3' class="sectionArea-2"><%=board.sversion%></td></tr> 
			</table> </td></tr>
			</table> <!-- End of DeviceInfo-->

		<!-- Begin of WAN Connection-->
		<table  cellspacing='0' cellpadding='0' width='100%' class="fontSize padtop10"><tr>
		<td class="verticalAlign"> 
			<table cellspacing='0' cellpadding='0'>
 <tr>
	<td class="midarea2 tableTitle"><%=wanConnTitle%></td></tr>
	</table>
			<table width='100%' cellspacing='0' class='servizitable fontSize' cellpadding='0' style="line-height:150%;"> 
					<%if wanConnType=="ETH" then%><!-- WAN Ethernet -->
			 <tr><td class="sectionArea-1 padleft40"><%=translate([==[Interface]==])%> WAN Ethernet:</td><td colspan='3' class="sectionArea-2">WAN Ethernet</td></tr>
			<tr ><td class="sectionArea-1 padleft40"><%=translate([==[Status]==])%>:</td><td colspan='3' class="<%=wanStatusColor%>"><%=translate(wanEthIntf.state)%></td></tr>	
		<%else%><!-- ADSL & VDSL -->
			<tr><td class="sectionArea-1 padleft40"><%=translate([==[DSL Driver Version]==])%>:</td>
			<td colspan='3'   class="sectionArea-2"><%=dsl.dsl_version%></td>
			</tr>
			<tr>
			<td class="sectionArea-1 padleft40"><%=translate([==[Status]==])%>:</td>
			<td colspan='3' class="<%=dslStateColor%>"><%=dslState%></td>
			</tr>
			<tr><td class="sectionArea-1 padleft40"><%=translate([==[Transmission system]==])%>:</td>
			<td colspan='3' class="sectionArea-2 verticalAlign" ><%=dslModulationType%></td>
			</tr>
			<tr><td class="sectionArea-1 padleft40"><%=translate([==[Mode of transmission]==])%>:</td>
			<td colspan='3'   class="sectionArea-2 verticalAlign"><%=dsl.latency_type%></td></tr>  
			<% if wanConnType=="VDSL" then%>
				<tr>
				<td class="sectionArea-1 padleft40"><%=translate([==[Profile]==])%>:</td><td colspan='3'  class="sectionArea-2"><%=dsl.dsl_profile%></td></tr>
			<%end%>

			<% if dsl.dsl_enable=="1" then%>
			<tr><td class="sectionArea-1 padleft40">Encapsulation Type:</td>
				<td colspan='3'  class="sectionArea-2"><% if wanConnType=="VDSL" then cgilua.print("PTM") else cgilua.print("ATM") end%></td></tr> 
			<%end%>
			<tr>
			<td class="sectionArea-1 padleft40">Impulse Noise Protection (INP):</td><td colspan='3'  class="sectionArea-2"><%=dsl.up_impulsemargin%></td></tr> 
			<tr>
			<td class="sectionArea-1 padleft40"><%=translate([==[Speed in transmission]==])%>(Kbps):</td>
			<td colspan='3'  class="sectionArea-2"><%=dsl.upstream%></td></tr> 
			<tr>
			<td class="sectionArea-1 padleft40"><%=translate([==[Receiving speeds]==])%>(Kbps):</td>
			<td colspan='3'  class="sectionArea-2"><%=dsl.downstream%></td></tr>
			<% if wanConnType~="VDSL" then%>
			<% if dsl.atmStatus=="Connected" then%>
			<tr ><td class="sectionArea-1 padleft40">VPI/VCI:</td><td colspan='3'  class="sectionArea-2"><%=dsl.pvc%></td></tr>
			<%end%>
			<% if dsl.atmStatus_1=="Connected" and iptv_active=="true" then %>
			<tr ><td class="sectionArea-1 padleft40">VPI/VCI:</td><td colspan='3' class="sectionArea-2"><%=dsl.pvc_1%></td></tr>
			<%end%>
			<%end%>
		<%end%>
			</table> 
			</td></tr></table> <!-- End of WAN Connection-->
			
			<!-- Begin of Internet connection-->
			<table  cellspacing='0' cellpadding='0' width='100%' class="fontSize padtop10"><tr>
			<td style='vertical-align:top'> 
			<table cellspacing='0' cellpadding='0'>
<tr>
	<td class="midarea2 tableTitle">
			<%=translate([==[Internet Link]==])%></td></tr></table> 
			<table width='100%' cellspacing='0' cellpadding='0' style="line-height:150%;" class='servizitable fontSize'> 
			
			<tr><td class="sectionArea-1 padleft40"><%=translate([==[rate profile]==])%>:</td><td colspan='3' class="sectionArea-2"><%=TI_info.profile%></td></tr>
			<tr><td class="sectionArea-1 padleft40"><%=translate([==[Mode]==])%>:</td><td colspan='3' class="sectionArea-2"><%=TI_info.connectMode%></td></tr> 		
			
<%
if info2~=nil then
if (TI_Device.lanOption == "res-rt-napt" or TI_Device.lanOption == "biz-rt-napt-ena" or TI_Device.lanOption == "res-rt-napt-ipv6" or TI_Device.lanOption == "biz-rt-napt-ipv6") and info2.name== "User session" then %>
			<tr><td class="sectionArea-1 padleft40"><%=translate([==[Connection protocol]==])%>:</td>
			<td colspan='3' class="sectionArea-2"><%=connProtocol%></td></tr>
			<tr><td class="sectionArea-1 padleft40"><%=translate([==[Connection Mode]==])%>:</td>
			<td colspan='3' class="sectionArea-2"><%=connectType%></td></tr>			
			<tr><td class="sectionArea-1 padleft40"><%=translate([==[Public IP address from your modem connection]==])%>:</td>
			<td colspan='3' class="sectionArea-2"><%=info2.ipaddr%></td></tr>
<%end
end
%>			
			</table> 
			</td></tr></table><!-- End of Internet connection-->
 			
			<!-- Begin of Management Connection-->
			<table cellspacing='0' cellpadding='0' width='100%' class="fontSize padtop10">
			<tr><td class="verticalAlign"> 
			<table cellspacing='0' cellpadding='0' >
<tr>
	<td class="midarea2 tableTitle">Telecom Italia</td></tr></table>
			<table width='100%' cellspacing='0' cellpadding='0' style="line-height:150%;"  class='servizitable fontSize'> 
						<tr><td class="sectionArea-1 padleft40"><%=translate([==[telemanagement]==])%>:</td>
						<td  class="<%=pppManagementStateColor%>" colspan='3' ><% =pppManagementState %></td></tr>
			</table> 
			</td></tr></table> <!-- End of Management Connection-->

			<!-- Begin of Connection Details-->
			<form method="POST" id="modemState" name="modemState" action="">
			<table  cellspacing='0' cellpadding='0' width='100%' class="fontSize padtop10">
			<tr>
			<td class="verticalAlign"> 
			<table cellspacing='0' cellpadding='0'>
<tr>
	<td class="midarea2 tableTitle"><%=translate([==[Connection Details]==])%></td></tr></table>
			<table width='100%' cellspacing='0' cellpadding='0' style="line-height:150%;" class='servizitable fontSize'> 
			
<%if PPP_Device~=nil then
	
	if (((TI_Device.lanOption == "res-rt-napt" or TI_Device.lanOption == "res-rt-napt-ipv6") and PPP_Device.connectionTrigger == "X_TELECOMITALIA_IT_Conditional") or (TI_Device.lanOption == "biz-rt-napt-ena" or TI_Device.lanOption == "biz-rt-napt-ipv6")and PPP_Device.connectionTrigger == "AlwaysOn") and PPP_Device.name == "User session" then
	
		-- if PPP_Device.enable == "true" then
		%>
		
			<tr><td class="sectionArea-1 padleft40 padtop5"><%=translate([==[Automatic connection by modem]==])%>:</td>
			
			<%if PPP_Device.connectionStatus == "Unconfigured" then%>
				<td colspan='2' class="tdRed padtop5"><%=translate([==[Unconfigured]==])%></td>
			<%elseif PPP_Device.connectionStatus == "Connecting" then%>
				<td colspan='2' class="tdOrange padtop5"><%=translate([==[Connecting]==])%></td>
			<%elseif PPP_Device.connectionStatus == "Authenticating" then%>
				<td colspan='2' class="tdRed padtop5"><%=translate([==[Authenticating]==])%></td>
			<%elseif PPP_Device.connectionStatus == "Connected" then%>
				<td colspan='2' class="tdGreen padtop5"><%=translate([==[Connected]==])%></td>
			<%elseif PPP_Device.connectionStatus == "PendingDisconnect" or PPP_Device.connectionStatus == "Disconnecting" then%>
				<td colspan='2' class="tdRed padtop5"><%=translate([==[Disconnecting]==])%></td>
			<%else%>
				<td colspan='2' class="tdRed padtop5"><%=translate([==[Disconnected]==])%></td>
			<%end%>
			<td class="verticalAlign">
			
			<%if (TI_Device.lanOption == "res-rt-napt" or TI_Device.lanOption == "res-rt-napt-ipv6") and PPP_Device.connectionTrigger == "X_TELECOMITALIA_IT_Conditional" then
				if isRemoteAccess()==false then
					if PPP_Device.connectionStatus == "Connected" then%>
						<a href ="javascript:submitStatus()"><div class="midarea6-1 mainButton" name="thbA4"><%=translate([==[Disable]==])%></div></a>
					<%else%>						
						<a href ="javascript:submitStatus()"><div class="midarea6-1 mainButton" name="thbA5"><%=translate([==[Active]==])%></div></a>
					<%end
				end
			end%>
		</tr>
		<%--end 
	end
end
			
local numberOfEntries = getAllDNSCount()%>

		<tr><td  class="sectionArea-1 padleft40"><%=translate([==[Primary DNS default]==])%>:</td>
		<td colspan='3' class="sectionArea-2"><%=getAllDNS(1)%></td></tr> 
		<tr><td  class="sectionArea-1 padleft40"><%=translate([==[Secondary DNS default]==])%>:</td>
		<td colspan='3' class="sectionArea-2"><%=getAllDNS(2)%></td></tr>
		
		<tr><td  class="sectionArea-1 padleft40"><%=translate([==[Others DNS]==])%>:</td>
		<td colspan='3' class="sectionArea-2"><table>
	<%if tonumber(numberOfEntries) >= 2 then
		local otherDNS_value = ""%>
		<%for i=3, tonumber(numberOfEntries) do
			otherDNS_value = getAllDNS(i)
			if otherDNS_value ~= nil and otherDNS_value ~= "" then%>			
				<tr><td><%=otherDNS_value%></td></tr>
			<%end
		end%>
	<%end%>
	<%if tonumber(numberOfEntries) == 0 then%>
			<%otherDNS_value = getAllDNS(98)
			if otherDNS_value ~= nil and otherDNS_value ~= "" then%>
				<tr><td><%=otherDNS_value%></td></tr>
			<%end%>
			<%otherDNS_value = getAllDNS(99)
			if otherDNS_value ~= nil and otherDNS_value ~= "" then%>
				<tr><td><%=otherDNS_value%></td></tr>
			<%end%>
		</td></tr></table>
	<%end%>
		
		</table> 
		</td></tr></table></form> <!-- End of Connection Details-->

<%end%>
		</td>
</tr>
</table>
</div> 
</div>	
</div>		
<script language="javascript">
function submitStatus() {
	document.modemState.submit();
}
</script>		

<script src="js/antiCSRF.js"></script>
</body>
</html>
