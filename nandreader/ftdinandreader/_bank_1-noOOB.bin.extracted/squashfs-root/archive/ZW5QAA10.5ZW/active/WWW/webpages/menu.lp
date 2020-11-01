<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml"> 
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
<title>Modem Telecom Italia</title>
<link href="css/master1.css" rel="stylesheet" type="text/css" />
<script language="javascript" type="text/javascript" src="js/main.js"></script>
<style type="text/css">
html,body{
margin:0px;
height:100%;
} 
</style>
</head>
<% cgilua.lp.include("lp/common.lp") %>
<% cgilua.lp.include("lp/device.lp") %>
<%
local FXO_val = getDeviceRoute()
local TI_info = getTIInfoHome()
local IPv6_info = get_IPv6Service()
local TI_Device = getTIInfo_Device()
local remoteStyle = ""
if isRemoteAccess() then
        remoteStyle = "display:none;"
end


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
<body leftmargin="0" topmargin="0" marginwidth="0" marginheight="0">

<table width="100%" height="100%" cellpadding="0" cellspacing="0" align="center">
<tr>
	<td style="background-color:#e9eef2">
	<div class="lftNavConainer"> 
        <div id="LeftIcons"> 
          <ul class="leftNav_lvl1 leftIconMnu">
            <li > 
			<div class="bdc"><a id="home" style="font-weight:bold;" onclick="showContent('home.lp');hideonly('d2');hideonly('d3'); LeftNav('home');changeImage('home');return false; " class='Icons' href="#"  >
              <img src="images/menu_ico_modem_on.png"  id="img_home"/><br/> HOME</a> </div>
     		</li>
            <li >
              <div class="bdc"><a style="font-weight:bold;" id="base" onclick="showContent('standard.lp');showSubMenu('d2'); hideonly('d3');LeftNav('base');hideWifiSub();showIcons(); changeImage('base');return false;" href="#" ><img src="images/menu_ico_impostazioni.png" id="img_base"/><br/><%=translate([==[PREFERENCES]==])%></a></div>
            </li>
			<div id="d2" style="display:none;"> 
			  <div class="left_menu_area1"> 
				<div class="topborder"></div>
							
				 <ul>
				<li><div class="bdc"><a id="stcon" onclick="showContent('wanStatus.lp');submenuclick(this);hideWifiSub();return false;" href="#" class=""><%=translate([==[Connection Status]==])%></a></div></li>
                		<li><div class="bdc"><a id="serte" onclick="showContent('statoServizi.lp');submenuclick(this);hideWifiSub();return false;" href="#" class="submenuselect1"><%=translate([==[Telecom Italia Services]==])%></a></div></li>
				<li><div class="bdc"><a id="lanst" onclick="showContent('lanStatus.lp');submenuclick(this);hideWifiSub();return false;" href="#" class="">LAN</a></div></li>
				<li><div class="bdc"><a id="wifist" onclick="showContent('wlanStatus.lp?wifiPage=wifi');linktoWifiSub();submenuclick(this);return false;" href="#" class="submenuselect1">Wi-Fi</a></div></li>
				<li id="wifi2li" style="display:none"><div class="bdc"><a id="wifi2" style='padding-left:20px;' onclick="showContent('wlanStatus.lp?wifiPage=wifi2');submenuclick(this);return false;" href="#" class="submenuselect1">Wi-Fi 2.4 GHz</a></div></li>
				<li id="wifi5li" style="display:none"><div class="bdc"><a id="wifi5" style='padding-left:20px;'  onclick="showContent('wlanStatus.lp?wifiPage=wifi5');submenuclick(this);return false;" href="#" class="submenuselect1">Wi-Fi 5 GHz</a></div></li>
				<li id="wifi_guestli" style="display:none"><div class="bdc"><a id="wifi_guest" style='padding-left:20px;'  onclick="showContent('wlanGuestStatus.lp');submenuclick(this);return false;" href="#" class="submenuselect1"><%=translate([==[Wi-Fi Guests]==])%></a></div></li>
				<li><div class="bdc"><a id="asst" onclick="showContent('helpAssistenza.lp');submenuclick(this);hideWifiSub();return false;" href="#" class="submenuselect1"><%=translate([==[Assistance]==])%></a></div></li>
				<li><div class="bdc"><a id="stat" onclick="showContent('statisticsAG.lp');submenuclick(this);hideWifiSub();return false;" href="#" class="submenuselect1"><%=translate([==[Statistics]==])%></a></div></li>
				<li style="<%=remoteStyle%>"><div class="bdc"><a id="loac" onclick="showContent('loginMgm.lp');submenuclick(this);hideWifiSub();return false;" href="#" class="submenuselect1"><%=translate([==[Local Access]==])%></a></div></li>
				</ul>
              
			  </div>
			 </div> 
            <li>
              <div class="bdc"><a  id="advance" style="font-weight:bold;" onclick="showContent('advance.lp');showSubMenu('d3'); hideonly('d2');LeftNav('advance');changeImage('advance');hideTeleSub();showIcons1(); return false;" href="#"><img src="images/menu_ico_imp_avan.png" id="img_advance"/><br/><%=translate([==[CONFIGURE]==])%></a></div>
            </li>
			
			<div id="d3"  style="display:none;"> 
               <div class="left_menu_area1"> 
			   <div class="topborder"></div>
			   <ul>
			    <%
				--Fix for CPE_P0012287
				if getTIServiceType() == "SIP_GW" then
					if FXO_val == "true" then
				%>
						<li><div class="bdc"><a id="tele" onclick="showContent('voipStato.lp');linktoTeleSub();submenuclick1(this);displayTelefoniaSubMenu();return false;" href="#" class="submenuselect1"><%=translate([==[Telephony]==])%></a></div></li>
					
					<li style="display:none" id="teleSubli">
					<div class="bdc"><a id="teleSub" style='padding-left:18px'  onclick="showContent('callLog.lp');submenuclick1(this);hideipv6Sub();return false;" href="#" class=""><%=translate([==[Call Statistics]==])%></a></div></li>
				<%
					end
				elseif getTIServiceType() == "Virtual_PBX" then
				%>
					<li><div class="bdc"><a id="tele" onclick="showContent('telephonyNumberPBX.lp');submenuclick1(this);hideipv6Sub();return false;" href="#" class=""><%=translate([==[Telephony]==])%></a></div></li>
				<%end%>				
				<li><div class="bdc"><a id="usbst" onclick="showContent('usbStato.lp');submenuclick1(this);hideTeleSub();hideipv6Sub();return false;" href="#" class=""><%=translate([==[USB services]==])%></a></div></li>
                <li><div class="bdc"><a id="media" onclick="showContent('mediaServer.lp');submenuclick1(this);hideTeleSub();hideipv6Sub();return false;" href="#" class="">Media Server</a></div></li>
				
			<%if IPv6_info == "biz-rt-napt-ipv6" or IPv6_info == "res-rt-napt-ipv6" then%>
				<li><div class="bdc"><a id="ipv6" onclick="showContent('ipv6_Conf.lp');linktoipv6Sub();submenuclick1(this);hideTeleSub();return false;" href="#" class="">IPv6</a></div></li>
				
				<li id="ipv6list" style="display:none"><div class="bdc"><a id="ipv6firewall" style='padding-left:20px;' onclick="showContent('accessListv6.lp');submenuclick1(this);hideTeleSub();return false;" href="#" class=""><%=translate([==[Firewall IPv6]==])%></a></div></li>
				
			<%end%>
				
	<%if TI_Device.lanOption == "res-rt-napt" or TI_Device.lanOption == "biz-rt-napt-ena" or TI_Device.lanOption == "res-rt-napt-ipv6" or TI_Device.lanOption == "biz-rt-napt-ipv6" then%>
				<li><div class="bdc"><a id="dns" onclick="showContent('dynDns.lp');submenuclick1(this);hideTeleSub();hideipv6Sub();return false;" href="#"><%=translate([==[Dynamic DNS]==])%></a></div></li>
				<li><div class="bdc"><a id="port" onclick="showContent('statoPortMapping.lp');submenuclick1(this);hideTeleSub();hideipv6Sub();return false;" href="#">Port Mapping</a></div></li>
	<%end%>			
				<li style="<%=remoteStyle%>"><div class="bdc"><a id="firewa" onclick="showContent('simpleFirewall.lp');submenuclick1(this);hideTeleSub();hideipv6Sub();return false;" href="#"><%=translate([==[Firewall]==])%></a></div></li>
	<%if TI_Device.lanOption == "res-rt-napt" or TI_Device.lanOption == "biz-rt-napt-ena" or TI_Device.lanOption == "res-rt-napt-ipv6" or TI_Device.lanOption == "biz-rt-napt-ipv6" then%>			
				<li style="<%=remoteStyle%>"><div class="bdc"><a id="urlfi" onclick="showContent('urlFilter.lp');submenuclick1(this);hideTeleSub();hideipv6Sub();return false;" href="#">URL filtering</a></div></li>
	<%end%>
				<!--<li style="<%=remoteStyle%>"><div class="bdc"><a id="reac" onclick="showContent('remoteAccess.lp');submenuclick1(this);hideTeleSub();hideipv6Sub();return false;" href="#" class=""><%=translate([==[Remote Access]==])%></a></div></li> -->
				<li style="<%=remoteStyle%>"><div class="bdc"><a id="waon" onclick="showContent('wakeOnLan.lp');submenuclick1(this);hideTeleSub();hideipv6Sub();return false;" href="#">Wake on LAN</a></div></li>
				<li style="<%=remoteStyle%>"><div class="bdc"><a id="stru" onclick="showContent('tool.lp');submenuclick1(this);hideTeleSub();hideipv6Sub();return false;" href="#"><%=translate([==[Tools]==])%></a></div></li>
				</ul>
              </div>
          </ul>
        </div>
      </div>

	</td>
</tr>


</table>


<script language="javascript">
	function showtag(b)
	{
		i=0;
		while(document.getElementById("tag"+i)){			
			if(i==b) {
				document.getElementById("tagItem"+i).className="Menu1ItemOver";
				document.getElementById("tag"+i).style.display="block";
				document.getElementById("tagtd"+i).height="100%";
			}
			else {
				document.getElementById("tagItem"+i).className="Menu1Item";
				if(i!=0){
					document.getElementById("tag"+i).style.display="none";
				}
				document.getElementById("tagtd"+i).height="";
			}
			i++;
		}
		var n=1;
		while(document.getElementById("menuItem"+n)){			
			document.getElementById("menuItem"+n).className="Menu2Item";
			n++;
		}
	}
	
	function showContent(menuName)
	{
		window.parent.body.location.href=menuName;
	}
	
	function displayTelefoniaSubMenu()
	{	
		window.parent.menu.document.getElementById("teleSubli").style.display="block";
		window.parent.menu.document.getElementById("teleSub").style.display="block";
	}
	function changeImage(menuName)
	{
		
		if(menuName=='base')
		{
			document.getElementById('img_home').src="images/menu_ico_modem.png";
			document.getElementById('img_base').src="images/menu_ico_impostazioni_on.png";
			document.getElementById('img_advance').src="images/menu_ico_imp_avan.png";
		}
		else if(menuName=='advance')
		{
			
			document.getElementById('img_home').src="images/menu_ico_modem.png";
			document.getElementById('img_base').src="images/menu_ico_impostazioni.png";
			document.getElementById('img_advance').src="images/menu_ico_imp_avan_on.png";
		}
		else if(menuName=='home')
		{
			document.getElementById('img_home').src="images/menu_ico_modem_on.png";
			document.getElementById('img_base').src="images/menu_ico_impostazioni.png";
			document.getElementById('img_advance').src="images/menu_ico_imp_avan.png";
		}
	}

</script>
</body>
</html>
