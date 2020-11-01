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
		window.parent.menu.document.getElementById("ipv6").className="";
		if(window.parent.menu.document.getElementById("ipv6list")) {
			window.parent.menu.document.getElementById("ipv6firewall").className="submenuselect1";
			window.parent.menu.document.getElementById("ipv6list").style.display="block";
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
  
<% cgilua.lp.include("lp/language.lp") %>
<% cgilua.lp.include("lp/util.lp")%>
<% cgilua.lp.include("lp/mbus_util.lp")%>
<% cgilua.lp.include("lp/form.lp")%>
<% cgilua.lp.include("lp/device.lp")%>
<% cgilua.lp.include("lp/common.lp") %>
<% cgilua.lp.include("lp/style.lp") %>

<%
local translate = translate
local POST=cgilua.POST
local print = cgilua.print
local tprint = require("tableprint")
local spArray, splitvalue


--To Get isIPv6UserConfigurable Status
function getIPv6UserConfigurable(ipv6stausUserEnablepath)
	local IPv6Result, IPv6Error = mbus.getParameters{  { path=ipv6stausUserEnablepath, param={"X_TELECOMITALIA_IT_FW_ACLv6Enable"} }, datamodel = "second" }
	local IPv6Userstatus = IPv6Result[ipv6stausUserEnablepath][1].param["X_TELECOMITALIA_IT_FW_ACLv6Enable"]	
	return IPv6Userstatus
end

local isIPv6UserConfigurable=getIPv6UserConfigurable("Device.Firewall")
	
  
local APP_path  = "NATAppList.App"
local APP_slen = string.len(APP_path)+1
local firewallPath = "Device.Firewall.X_TELECOMITALIA_IT_ACLv6"
local firewallPath_slen = string.len(firewallPath) + 1

local IGD_PortMapping_slen = string.len(firewallPath) + 1
local portMappingList, error = getList_IGD(firewallPath, nil, "Description", "InternalClient", "InternalPort", "Protocol", "Enable")

local appListAll, error = getList(APP_path, nil, "Name", "HostIPAddress", "Category")
local appList, appEditList, protocolList, protocolEditList, virtualList = getListForPortMapping(appListAll, APP_slen, portMappingList)

-- ACLv6 table values
local aclEnable = {}
local aclPort = {}
local aclProtocol = {}
local aclClient = {}
local aclDesc = {}
local aclpath = {}
local aclCount = 0
local firewallPath = "Device.Firewall.X_TELECOMITALIA_IT_ACLv6"

local aclv6reply, error=mbus.getParameters{path=firewallPath, datamodel="second"}
if (aclv6reply[firewallPath][1] ~= nil) and (aclv6reply[firewallPath][1].param["Enable"] ~= nil) then
	for k,v in pairs(aclv6reply[firewallPath]) do
		aclpath[k] = v.path
		aclEnable[k] = v.param.Enable
		aclPort[k] = v.param.InternalPort
		aclProtocol[k] = v.param.Protocol
		aclClient[k] = v.param.InternalClient
		aclDesc[k] = v.param.Description
		aclCount = k
	end
end

local firewallPath_slen = string.len(firewallPath) + 1

-- POST start
if cgilua.servervariable "REQUEST_METHOD" == "POST" then

	local modify = {}
	
	if POST["ipv6statesave"] == "1" then
		local accesslistEnablepath = "Device.Firewall"
		local changed = 0
		local accesslisterr = 0

		if POST["IPv6Stateconfig"] ~= nil then
			if POST["IPv6Stateconfig"] == "1" and getIPv6UserConfigurable("Device.Firewall") == "false" then
				table.insert(modify, {path = accesslistEnablepath, param = {X_TELECOMITALIA_IT_FW_ACLv6Enable = "true"}})
				changed = 1
			end
			if POST["IPv6Stateconfig"] == "0" and getIPv6UserConfigurable("Device.Firewall") == "true" then
				table.insert(modify, {path = accesslistEnablepath, param = {X_TELECOMITALIA_IT_FW_ACLv6Enable = "false"}})	
				changed = 1
			end
			if changed == 1 then
				accesslisterr = setMBUS_IGD(modify)
			end
		end
	end
	
	if POST["accessliststatesave"] == "1" then
		local changed = 0
		local accesslisterr = 0

		for i=1, aclCount do

			if POST["IPv6ListState_"..i] == "1" then
				POST["IPv6ListState_"..i] = "true"
			else
				POST["IPv6ListState_"..i] = "false"
			end
			
			if aclEnable[i] ~= POST["IPv6ListState_"..i] then
				table.insert(modify, {path = aclpath[i], param = {Enable = POST["IPv6ListState_"..i]}})
				changed = 1
			end
		end
		if changed == 1 then
			accesslisterr = setMBUS_IGD(modify)
		end
	end
		saveall(0, 1)
		cgilua.redirect("save_alert.lp", { u = "accessListv6.lp"})
		return
	

end	-- POST end

local errMsgApplication={
	existApplication = translate([==[Warning: The Rule is already in active. Check that the IPv6 address and the port configured have not been previous allocated to another rule]==])
}
%>
<script language="javascript" type="text/javascript">

function cancelConfig()
{
	document.getElementById("accesslistform").style.display="block";
	document.getElementById("resultKoAll").style.display="none";
	document.getElementById("resultKO_IPv6Overlap").style.display="none";
}

function linkToEditipv6(flag, pathId)
{
	window.location.href="accessListv6Edit.lp?flag="+flag+"&pathId="+pathId;
}

function config_submit()
{
	document.getElementById("ipv6statesave").value = "1"
	document.accesslistform.submit();
}

function config_status()
{
	var row_count = "<%=aclCount%>";
	for(i=1;i<=parseInt(row_count-1);i++) {
		var split_port =  ((document.getElementById("InternalPort_"+i).innerHTML).replace(/\s+/g, '')).split("-");
		
		for(j=(i+1);j<=parseInt(row_count);j++) {
			if((document.getElementById("enablelistStatus_"+i).checked == true) && (document.getElementById("enablelistStatus_"+j).checked == true) && (document.getElementById("ip_"+i).innerHTML == document.getElementById("ip_"+j).innerHTML) && (document.getElementById("Protocol_"+i).innerHTML == document.getElementById("Protocol_"+j).innerHTML || document.getElementById("Protocol_"+i).innerHTML == "ALL" || document.getElementById("Protocol_"+j).innerHTML == "ALL"))
			{			
				var port_Check =  ((document.getElementById("InternalPort_"+j).innerHTML).replace(/\s+/g, '')).split("-");
				
				if((isNaN(split_port[1]) && isNaN(port_Check[1]) && parseInt(split_port[0]) == parseInt(port_Check[0])) || (isNaN(split_port[1]) && !isNaN(port_Check[1]) && parseInt(split_port[0]) >= parseInt(port_Check[0]) && parseInt(split_port[0]) <= parseInt(port_Check[1])) || (!isNaN(split_port[1]) && isNaN(port_Check[1]) && parseInt(split_port[0]) <= parseInt(port_Check[0]) && parseInt(split_port[1]) >= parseInt(port_Check[0])))
				{
					document.getElementById("ACLWarningMsg").innerHTML = '<%=errMsgApplication["existApplication"]%>';
					document.getElementById("accesslistform").style.display="none";
					document.getElementById("resultKoAll").style.display="block";
					return false;
				}
				
				if(!isNaN(split_port[1]) && !isNaN(port_Check[1])) {
					for(var p=parseInt(port_Check[0]);p<=parseInt(port_Check[1]);p++) {
						for(var q=parseInt(split_port[0]);q<=parseInt(split_port[1]);q++) {
							if(p==q) {
								document.getElementById("ACLWarningMsg").innerHTML = '<%=errMsgApplication["existApplication"]%>';
								document.getElementById("accesslistform").style.display="none";
								document.getElementById("resultKoAll").style.display="block";
								return false;
							}
						}
					}
				}
			}
		}
	}
	document.getElementById("accessliststatesave").value = "1";
	document.accessliststatus.submit();
}

</script>

</head>
<body>
<div class="contentContainer fontSize">
	<div class="breadCrumbContainer">
		<ul class="brdCrumb">
			<li><a href="advance.lp"><%=translate([==[Advanced Settings]==])%></a></li><li>|</li><li><a href="ipv6_Conf.lp">IPv6</a></li><li>|</li><li><a href="accessListv6.lp"><%=translate([==[Firewall IPv6]==])%></a></li>
		</ul>
	</div>	
	
	<div class="contentTab" id="content">
		<ol id="tocTab">				
			<li><a id="ipv6Status" href="accessListv6.lp" class="current">
				<div class="tab">
				<span class="tabIcon_fire"></span>  
				<span class="contTabTxt transform"><%=translate([==[Firewall IPv6]==])%></span>
				</div><div class="clrBth"></div></a>
			</li>
			<%if isIPv6UserConfigurable == "true" then%>
			<li><a class="margin15" href="accessListv6config.lp">
				<div class="tab">
				<span class="contTabTxt transform"><%=translate([==[Configure Firewall IPv6]==])%></span>
				</div></a>
			</li>
			<%end%>
		</ol>
	</div>

	<form method="POST" name="accesslistform" id="accesslistform" action="">	
		<div class='contentitem'>
			<input type="hidden" name="ipv6statesave" id="ipv6statesave" value="0">
			<%
			writePageHeader_new()
			writeBlockNoTitle()
			%>
			<tr><td width='300' class="tableTitle"><%=translate([==[Firewall and IPv6 Access List]==])%></td></tr>
			<tr height="20"><td></td></tr>
			<tr>
				<td style="padding-left:0px;">
				<%=translate([==[Enabling the feature is activated one Stateful Firewall for IPv6. A Stateful Firewall protects LAN IPv6 hosts in allowing incoming connections only on open ports or traded by those hosts. Additionally, IPv6 access lists allow you to configure additional rules to allow incoming traffic to the IPv6 host in LAN-based port / protocol.]==])%>
				</td>
			</tr> 
			<tr height="20"><td></td></tr>
			<tr class='midarea3' style="padding-left:0px;">

				<td width="300px"><%=translate([==[State Firewall and IPv6 Access List]==])%>:</td>
				<td width="430px"colspan='2'>			
			  
				<input type="radio" value="1" id="enableIPv6config" name="IPv6Stateconfig">&nbsp;<%=translate([==[Active]==])%>&nbsp;&nbsp;&nbsp;&nbsp;
				<input type="radio" value="0" id="disableIPv6config" name="IPv6Stateconfig">&nbsp;<%=translate([==[Not active]==])%>
			  </td>
			</tr>
			<% endBlock() %>
			
			<table><tr class='' style='padding-left:0px'>
				<td style='padding-left:250px'>
				<a style='color:black' onclick='config_submit()' href="#">
				<div class="midarea6-1 mainButton" name="thb6"><%=translate([==[Save]==])%></div></a></td>
				
				<td style='padding-left:50px'>
				<a style='color:black' href='ipv6_Conf.lp' onclick='cancelconf();'>
				<div class="midarea6-1 mainButton" name="thb7"><%=translate([==[Cancel]==])%></div></a></td>
				</tr>
			</table>
		</div>
	</form>
	<form method="POST" name="accessliststatus" id="accessliststatus" action="">	
		<div class='contentitem'>
			<input type="hidden" name="accessliststatesave" id="accessliststatesave" value="0">
			
			<%if isIPv6UserConfigurable == "true" then
			if virtualList[1] ~= nil or protocolEditList[1] ~= nil then	%>
			<table cellspacing='0' cellpadding='0' width='100%' class="fontSize width770 padtop10">
				<tr><td class="midarea2 tableTitle"><%=translate([==[State IPv6 Access List]==])%></td></tr>	
				<tr><td>				
					<table class='edittable fontSize valueSpace ipReserve width700' width='100%' cellspacing='0' cellpadding='0' border='0'> 
						<tr>
							<td class="tableHd width175"  align='left'><%=translate([==[Application]==])%></td>
							<td class="tableHd width175"  align='left'><%=translate([==[Status]==])%></td>
							<td class="tableHd width175"  align='left'><%=translate([==[Port]==])%></td>
							<td class="tableHd width175"  align='left'><%=translate([==[Protocol]==])%></td>
							<td class="tableHd width175"  align='left'><%=translate([==[IPv6 Destination]==])%></td>
							<td class="tableHd width175"  align='left'><%=translate([==[Modify]==])%></td>
						</tr> 
						<tr><td colspan='6'></td></tr>
						<tr><td colspan='6'><img src='images/spacer.gif' border='0' width='1' height='3' alt=''><br></td></tr>
						
						<%local rowStyle = "oddrow"
						local row_count = 0
						for i,v in pairs(protocolEditList) do
							row_count = i
							if i%2==1 then
								rowStyle = "oddrow"
							else
								rowStyle = "evenrow"
							end
							
						%>
						
						<tr><td class='<%=rowStyle%>' colspan='6'></td></tr>
						<tr>
							<td class="<%=rowStyle%> alignMid"><%=v["Description"]%></td>
							<td class="<%=rowStyle%> alignMid">
							<input type="radio" value="1" id="enablelistStatus_<%=i%>" name="IPv6ListState_<%=i%>">&nbsp;<%=translate([==[Active]==])%>
							<div class="padtop5">
							<input type="radio" value="0" id="disablelistStatus_<%=i%>" name="IPv6ListState_<%=i%>">&nbsp;<%=translate([==[Disable]==])%>
							</div>
							<script language="javascript" type="text/javascript">
							<%if v["Enable"] == "true" then %>
								document.getElementById("enablelistStatus_<%=i%>").checked = true;
							<% else %>
								document.getElementById("disablelistStatus_<%=i%>").checked = true;
							<% end%>
							</script></td>
							<td class="<%=rowStyle%> alignMid" id="InternalPort_<%=i%>" name="InternalPort_<%=i%>"><%=v["InternalPort"]%></td>
							<td class="<%=rowStyle%> alignMid" id="Protocol_<%=i%>" name="Protocol_<%=i%>"><%=v["Protocol"]%></td>
							<td class="<%=rowStyle%> alignMid" id="ip_<%=i%>" name="ip_<%=i%>"><%=v["InternalClient"]%></td>
							<td class="<%=rowStyle%> alignMid"><div class="midarea6-1 mainButton" style="width:85px;" name="thb6" onclick="linkToEditipv6('protocol', '<%=v.path%>')"><%=translate([==[Modify]==])%></div>
							</td>
						</tr>
						<%end%>	
						
						<%for i,v in pairs(virtualList) do
							if (row_count+i)%2 == 1 then
								rowStyle = "oddrow"
							else
								rowStyle = "evenrow"
							end
							
						%>
						
						<tr><td class='<%=rowStyle%>' colspan='6'></td></tr>
						<tr>
							<td class="<%=rowStyle%> alignMid"><%=v["Description"]%></td>
							<td class="<%=rowStyle%> alignMid">
							<input type="radio" value="1" id="enablelistStatus_<%=(row_count+i)%>" name="IPv6ListState_<%=(row_count+i)%>">&nbsp;<%=translate([==[Active]==])%>
							<div class="padtop5">
							<input type="radio" value="0" id="disablelistStatus_<%=(row_count+i)%>" name="IPv6ListState_<%=(row_count+i)%>">&nbsp;<%=translate([==[Disable]==])%>
							</div>
							<script language="javascript" type="text/javascript">
							<%if v["Enable"] == "true" then %>
								document.getElementById("enablelistStatus_<%=(row_count+i)%>").checked = true;
							<% else %>
								document.getElementById("disablelistStatus_<%=(row_count+i)%>").checked = true;
							<% end%>
							</script></td>
							<td class="<%=rowStyle%> alignMid" id="InternalPort_<%=(row_count+i)%>" name="InternalPort_<%=(row_count+i)%>"><%=v["InternalPort"]%></td>
							<td class="<%=rowStyle%> alignMid" id="Protocol_<%=(row_count+i)%>" name="Protocol_<%=(row_count+i)%>"><%=v["Protocol"]%></td>
							<td class="<%=rowStyle%> alignMid" id="ip_<%=(row_count+i)%>" name="ip_<%=(row_count+i)%>"><%=v["InternalClient"]%></td>
							<td class="<%=rowStyle%> alignMid"><div class="midarea6-1 mainButton" style="width:85px;" name="thb6" onclick="linkToEditipv6('virtual', '<%=v.path%>')"><%=translate([==[Modify]==])%></div>
							</td>
						</tr>
						<%end%>	
						
						</tr> 
											
					</table>
				</td></tr>
			</table>
			
			<% endPage() %>
			<table><tr class='' style='padding-left:0px'>
				<td style='padding-left:250px'>
				<a style='color:black' onclick='config_status()' href="#">
				<div class="midarea6-1 mainButton" name="thb6"><%=translate([==[Save]==])%></div></a></td>
				
				<td style='padding-left:50px'>
				<a style='color:black' href='ipv6_Conf.lp'>
				<div class="midarea6-1 mainButton" name="thb7" onclick='cancelconf();'><%=translate([==[Cancel]==])%></div></a></td>
				</tr>
			</table>
			<% end end%>
		</div>
		</form>

	
</div>
	
<div id="resultKoAll" style="display:none">
<%cgilua.lp.include("webparts/resultKO_IPv6.lp")%>
</div>

<script src="js/antiCSRF.js" type="text/javascript"></script>
<script language="javascript" type="text/javascript">
<%if isIPv6UserConfigurable == "true" then%>
	document.getElementById("enableIPv6config").checked = true;
<%else%>
	document.getElementById("disableIPv6config").checked = true;
<%end%>
</script>


</body>
</html>
