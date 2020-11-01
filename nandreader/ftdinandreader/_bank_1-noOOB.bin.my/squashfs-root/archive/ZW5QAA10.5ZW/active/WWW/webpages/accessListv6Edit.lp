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
<% cgilua.lp.include("lp/util.lp")%>
<% cgilua.lp.include("lp/mbus_util.lp")%>
<% cgilua.lp.include("lp/form.lp")%>
<% cgilua.lp.include("lp/device.lp")%>
<% cgilua.lp.include("lp/common.lp") %>
<% cgilua.lp.include("lp/style.lp") %>

<%
local translate = translate
local POST=cgilua.POST
local tprint = require("tableprint")


local flag = cgilua.QUERY["flag"]
local pathId = cgilua.QUERY["pathId"]
local pathDetail = pathId
local nameInfo, ipInfo, protocolInfo, internalRange, statusInfo
local APP_path = "NATAppList.App"
local APP_slen = string.len(APP_path)+1
local firewallPath = "Device.Firewall.X_TELECOMITALIA_IT_ACLv6"
local firewallPath_slen = string.len(firewallPath) + 1

local tcpRangeInfo , udpRangeInfo = "", ""

--Start to deal with port mapping
local portMappingList, error = getList_IGD(firewallPath, nil, "Description", "InternalClient", "InternalPort", "Protocol", "Enable")

local appListAll, error = getList(APP_path, nil, "Name", "HostIPAddress", "Category")
local appList, appEditList, protocolList, protocolEditList, virtualList = getListForPortMapping(appListAll, APP_slen, portMappingList)

if flag == "virtual" then
	nameInfo, ipInfo, protocolInfo, internalRange = getDetailInfoByPath(pathDetail, virtualList)
else	
	nameInfo, ipInfo, protocolInfo, internalRange = getDetailInfoByPath(pathDetail, protocolEditList)
end

local reply, error = mbus.getParameters{path = pathDetail, param = "Enable", datamodel = "second"}
statusInfo = reply[pathDetail][1].param["Enable"]

local deviceList={}
local deviceListValue = getHostIpv6List()
if deviceListValue~=nil and deviceListValue~="" then
  deviceList=deviceListValue
end

local errMsgApplication={
	invalidIp = translate([==[Warning: The IPv6 address is not entered or it is not in a valid formated]==]),

	invalidRange = translate([==[Warning: The IPv6 address is not included in the LAN Range]==]),
	
	invalidName = translate([==[Warning: Please enter a valid name for the rule that you want to create. Verify that you are not already in use or that does not contain any special characters or symbols]==]),
	
	invalidPortRange = translate([==[Warning: Check the value entered for the Port. Valid values are: 1-65535]==]),
	
	portRangeOverlap = translate([==[Warning: The port range overlaps an already defined within the same application]==]),
	
	existApplication = translate([==[Warning: The Rule is already in active. Check that the IPv6 address and the port configured have not been previous allocated to another rule]==])
}
-- POST start
if cgilua.servervariable "REQUEST_METHOD" == "POST" then

local modify = {}
	--Update the port mapping of protocol or virtual config parameters
		local changed = 0
		local accesslisterr = 0
		
	if POST["deletePath"] == "on" then
	
		local reply, error = mbus.modify(
		function()
			local reply1, error1 = mbus.deleteObjects{ path = pathId, datamodel="second"}
		end,
		{datamodel="second"})
		
		if error == nil then
			changed = 1
		end
		
	else
		local customPath = POST["customPathId"]
 		local name = POST["customName"]
		local ip = POST["hostIPAddress"]
		local protocol = POST["customProtocol"]
		local internalPort = POST["customInternalPort"]
		local status = POST["IPv6ListState"]
		
		if status == "1" then
			status = "true"
		else
			status = "false"
		end
		
		table.insert(modify, {path = customPath, param = {InternalClient = ip, Protocol = protocol, InternalPort = internalPort, Enable = status}})
		changed = 1
	end

	if changed == 1 then
		accesslisterr = setMBUS_IGD(modify)
	end
	
	saveall(0, 1)
	cgilua.redirect("save_alert.lp", { u = "accessListv6.lp"})
	return
	
end	-- POST end
%>

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
			<li><a id="ipv6Status" href="accessListv6.lp">
				<div class="tab">
				<span class="tabIcon_fire"></span>  
				<span class="contTabTxt transform"><%=translate([==[Firewall IPv6]==])%></span>
				</div><div class="clrBth"></div></a>
			</li>
			<li><a class="current margin15" href="accessListv6config.lp">
				<div class="tab">
				<span class="contTabTxt transform"><%=translate([==[Configure Firewall IPv6]==])%></span>
				</div></a>
			</li>
		</ol>
	</div>
	
	<div class='contentitem' id="acessListEdit">
	<%
	writePageRowHeader(translate([==[Configuration Access List IPv6]==]))
	%>
	<!-- start to config access list ipv6 info -->
	<form id="customConfig" name="customConfig" action="" method="post">
	<input type="hidden" id="hostIPAddress" name="hostIPAddress" value="" />
	<input type="hidden" id="customPathId" name="customPathId" value="<%=pathId%>" />
	<input type="hidden" id="deletePath" name="deletePath" value="off" />
	
	<%
	writeTableRowTitle_port(translate([==[Manage Access List]==]))
	writeTableBlockRowHeader(4,translate([==[Application]==]),translate([==[Destination IP]==]),translate([==[Protocol]==]),translate([==[Status]==]))
	%>		
						
	<tr><td class='oddrow' colspan='4'><img src='images/spacer.gif' border='0' width='1' height='3' alt=''><br></td></tr>
	<tr>
		<td class="oddrow midvertical">
	<%
	--createSelect('<select id="protocolName" name="protocolName" class="inputClass" onchange="changeProtocol(this.value, this.options[this.selectedIndex].text)"><option value="">&lt;' .. translate([==[Select from the list]==]) .. '&gt;</option>',nil,protocolList,"Name","path")
	%>
	
	<input class="inputClass" type="text" name="customName" id="customName" size="25" value="<%=nameInfo%>" /><input class="inputClass" type="hidden" name="oldCustomName" id="oldCustomName" size="17" value="<%=nameInfo%>" />
	
	<input type="hidden" id="protocolPathId" name="protocolPathId" value="" /><input type="hidden" id="protocolPathName" name="protocolPathName" value="" /><input type="hidden" id="protocolType" name="protocolType" value="" />
	
	<input type="hidden" id="gameName" name="gameName" value="" />
		</td>
		<td class="oddrow midvertical" style="white-space:nowrap;">
		   <input type="text" id="protocolAddr" name="protocolAddr" size="28" maxlength="26" class="inputClass" value="<%=ipInfo%>"/>
			<div class="padtop5">
			<%
			createSelect('<select name="deviceProtocol" id="deviceProtocol" class="inputClass" onchange="changeProtocolDevice(this.value, this.options[this.selectedIndex].text);"><option value="">&lt;' .. translate([==[IPv6 Available]==]) .. '&gt;</option>', nil,deviceList, "IPAddress", "IPAddress")
		   %> </div>
		</td>
		<td class="oddrow midvertical">
		   <div id="internalProtocolRange"></div>
			<select size="1" id="customProtocol" name="customProtocol" class="inputClass" style="width:60px">
			<option value="TCP">TCP</option>
			<option value="UDP">UDP</option>
			<option value="ALL">ALL</option>
			</select>
		</td>
		<td class="oddrow midvertical">
		 <input type="radio" value="1" id="enablelistStatus" name="IPv6ListState">&nbsp;<%=translate([==[Active]==])%>
		 <div class="padtop5">
		<input type="radio" value="0" id="disablelistStatus" name="IPv6ListState">&nbsp;<%=translate([==[Disable]==])%>
		</div>
		</td>
	</tr>
	
	<tr><td class="oddrow" colspan='4'><img src='images/spacer.gif' border='0' width='1' height='3' alt=''><br></td></tr>
			
	<tr><td class="evenrow" colspan='4'><img src='images/spacer.gif' border='0' width='1' height='3' alt=''><br></td></tr>
	<tr>
		<td class="evenrow"><%=translate([==[Port]==])%> </td>
		<td class="evenrow" colspan="3">
			
			<div id="singleport" name="singleport" class="align_topEle">
				<input type="text" id="customInternalPort" name="customInternalPort" class="inputClass" value="<%=internalRange%>"/>
			</div>
			<div id="fromtoport" name="fromtoport" style="display:none;">
				<div>
				<div style="float:left;"><%=translate([==[From]==])%></div>
				<div style="float:left;margin-left:1%"><input type="text" name="customInternalPortFrom" id="customInternalPortFrom" size="6" class="inputClass" /></div>
				</div>
				<div>
				<div style="float:left;margin-left:2%"><%=translate([==[To]==])%></div>
				<div style="margin-left:109px"><input type="text" name="customInternalPortTo" id="customInternalPortTo" size="6" class="inputClass" /></div>
				</div>
			</div>
			<div class="padtop5">
				<select name="CustomPort" id="CustomPort" class="inputClass" style="width:108px;" onchange="changePort(this.value);">
					<option value="singleport"><%=translate([==[Single Port]==])%></option>
					<option value="portrang"><%=translate([==[Port Range]==])%></option>
				</select>
			</div>
		</td>
	</tr>
	<tr><td class="evenrow" colspan='4'><img src='images/spacer.gif' border='0' width='1' height='3' alt=''><br></td></tr>

	<%endBlock()%>	
	<%endBlock()%>	
	<tr><td colspan='4'>
	<table cellspacing='0' cellpadding='0' width='100%' class="martop15 txtAlignCenter width750" >
    <tr><td>
		<div  class="width130 fleft padleft200">
<a onclick="submitVirtualApply()" href="#" class="fright">
		<div class='midarea6-1 mainButton' name="thb10"><%=translate([==[Save]==])%></div></a></div>
		<div class="width130 fleft" style="padding-left:25px;"><a onclick="deleteApplication()" href="#"><div class='midarea6-1 mainButton' name="thb10"><%=translate([==[Delete]==])%></div></a></div>
		<div class="width130 fleft"><a class="fleft" href="accessListv6.lp"><div class='midarea6-1 mainButton' name="thb12"><%=translate([==[Cancel]==])%></div></a></div>
	</td></tr>
	</table></td></tr>
	
	</form>	
</div>

<script language="javascript" type="text/javascript">

var customInternalPort = document.getElementById("customInternalPort").value;
document.getElementById("customInternalPort").value = customInternalPort;
var fromPort;
var toPort;
if(customInternalPort.indexOf("-") != -1)
{
	var n=customInternalPort.split("-");
	
	document.getElementById("CustomPort").value="portrang";
	document.getElementById("singleport").style.display ="none";
	document.getElementById("fromtoport").style.display ="block";
	fromPort=n[0];
	toPort=n[1];
	document.getElementById("customInternalPortFrom").value = n[0];
	document.getElementById("customInternalPortTo").value = n[1];
}
else
{
	document.getElementById("CustomPort").value="singleport";
	document.getElementById("fromtoport").style.display ="none";
	document.getElementById("singleport").style.display ="block";
}
	
<%if statusInfo == "true" then%>
	document.getElementById("enablelistStatus").checked = true;
<%else%>
	document.getElementById("disablelistStatus").checked = true;
<%end%>

var protocalType = "<%=protocolInfo%>";
if(protocalType!="TCP")
{
	if(protocalType!="UDP")
	{
		protocalType="ALL"
	}
}
document.getElementById("customProtocol").value = protocalType;	

function changeProtocolDevice(val,name)
{
	if(name=="<<%=translate([==[IPv6 Available]==])%>>")
	{ 
	  document.getElementById("protocolAddr").value = "";
	}
	if(document.getElementById("deviceProtocol").value!="")
	{
		  document.getElementById("protocolAddr").value = val;
	}   
}

function submitVirtualApply()
{
	var customName = document.getElementById("customName").value;
	var oldCustomName = document.getElementById("oldCustomName").value;

	if(customName != oldCustomName)
	{
		if((customName == "") || (customName.length > 25) || (customName.charAt(0) == ' ') || (customName.charAt(customName.length-1) == ' ') || !(/^[A-Za-z0-9 ]+$/.test(customName)))
		{
			document.getElementById("acessListEdit").style.display="none";
			document.getElementById("ACLWarningMsg").innerHTML = '<%=errMsgApplication["invalidName"]%>';
			document.getElementById("resultKoAll").style.display="block";
			return false;	
		}

		<%for i,v in pairs(virtualList) do%>
			if(customName == "<%=v["Description"]%>")
			{
				document.getElementById("acessListEdit").style.display="none";
				document.getElementById("ACLWarningMsg").innerHTML = '<%=errMsgApplication["invalidName"]%>';
				document.getElementById("resultKoAll").style.display="block";
				return false;
			}
		<%end%>

		<%for i,v in pairs(appListAll) do%>
			if(customName == "<%=v["Name"]%>")
			{
				document.getElementById("acessListEdit").style.display="none";
				document.getElementById("ACLWarningMsg").innerHTML = '<%=errMsgApplication["invalidName"]%>';
				document.getElementById("resultKoAll").style.display="block";
				return false;
			}
		<%end%>
	}

	//Ip address validation
	var ipv6Addr = document.getElementById("protocolAddr").value;
	document.getElementById("hostIPAddress").value = ipv6Addr;
	
	if(!(isValidIPv6Address(ipv6Addr))) {
		
		document.getElementById("acessListEdit").style.display="none";
		document.getElementById("ACLWarningMsg").innerHTML = '<%=errMsgApplication["invalidIp"]%>';
		document.getElementById("resultKoAll").style.display="block";
		return false;
	}
	
	var customProtocol = document.getElementById("customProtocol").value;
	var selectedPort = document.getElementById("CustomPort").value;
	var customInternalPort = document.getElementById("customInternalPort").value;
	fromPort = document.getElementById("customInternalPortFrom").value;
	toPort = document.getElementById("customInternalPortTo").value;
	fromPort = fromPort.replace(/\s+/g, '');
	toPort = toPort.replace(/\s+/g, '');

	if( (selectedPort == "singleport" && !customPortJudgement(customInternalPort)) || (selectedPort == "portrang" && (!customPortJudgement(fromPort) || !customPortJudgement(toPort) || parseInt(fromPort) >= parseInt(toPort))) )
	{
		document.getElementById("ACLWarningMsg").innerHTML = '<%=errMsgApplication["invalidPortRange"]%>';
		document.getElementById("acessListEdit").style.display="none";
		document.getElementById("resultKoAll").style.display="block";
		return false;
	}
	else
	{
		if(selectedPort == "portrang")
		{
			var from_to_Port = fromPort+"-"+toPort;
			document.getElementById("customInternalPort").value = from_to_Port;
		}
		<%
		local aclv6, error=mbus.getParameters{path=firewallPath, datamodel="second"}
		
		if (aclv6[firewallPath][1] ~= nil) and (aclv6[firewallPath][1].param ~= nil) then
		for i,v in pairs(aclv6[firewallPath]) do
		if v.path ~= pathId then %>

			var old_port = "<%=v.param.InternalPort%>";
			old_port =  old_port.replace(/\s+/g, '');
			var split_port  = old_port.split("-");
			
			if((selectedPort == "portrang" && ((isNaN(split_port[1]) && parseInt(fromPort) <= split_port[0] && parseInt(toPort) >= split_port[0] && (customProtocol == "<%=v.param.Protocol%>" || customProtocol == "ALL" || "<%=v.param.Protocol%>" == "ALL")) || (!isNaN(split_port[1]) && ( (parseInt(fromPort) <= split_port[0] && parseInt(toPort) >= split_port[0]) || (parseInt(fromPort) <= split_port[1] && parseInt(toPort) >= split_port[1]) ) && (customProtocol == "<%=v.param.Protocol%>" || customProtocol == "ALL" || "<%=v.param.Protocol%>" == "ALL") ))) || (selectedPort == "singleport" && ((isNaN(split_port[1]) && customInternalPort == split_port[0] && (customProtocol == "<%=v.param.Protocol%>" || customProtocol == "ALL" || "<%=v.param.Protocol%>" == "ALL") ) || (!isNaN(split_port[1]) && customInternalPort >= split_port[0] && customInternalPort <= split_port[1] && (customProtocol == "<%=v.param.Protocol%>" || customProtocol == "ALL" || "<%=v.param.Protocol%>" == "ALL") ))) )
			{
				
				var status_check = "false";
				if(document.getElementById('enablelistStatus').checked) {
				  status_check = "true";
				}

				if(ipv6Addr == "<%=v.param.InternalClient%>" && "<%=v.param.Enable%>" == "true" && status_check == "true")
				{
					document.getElementById("ACLWarningMsg").innerHTML = '<%=errMsgApplication["existApplication"]%>';
					document.getElementById("acessListEdit").style.display="none";
					document.getElementById("resultKO_IPv6Overlap").style.display="none";
					document.getElementById("resultKoAll").style.display="block";
					return false;
				}
				else if(status_check == "true" && ipv6Addr != "<%=v.param.InternalClient%>")
				{
					document.getElementById("ACLWarningMsg").innerHTML = '<%=errMsgApplication["portRangeOverlap"]%>';
					document.getElementById("acessListEdit").style.display="none";
					document.getElementById("resultKO_IPv6Overlap").style.display="none";
					document.getElementById("resultKoAll").style.display="block";
					return false;
				}
			}
			
		<%end end end%>
	}
	document.getElementById("acessListEdit").style.display="none";
	document.getElementById("resultKoAll").style.display="none";
	document.getElementById("resultKO_IPv6Overlap").style.display="none";
	document.getElementById("confirmConfig").style.display="block";
}

function deleteApplication() {

	document.getElementById("deletePath").value = "on";
	document.getElementById("acessListEdit").style.display="none";
	document.getElementById("confirmConfig").style.display="block";
}

function submitConfirm()
{
	var deletePath = document.getElementById("deletePath").value;
	document.customConfig.submit();
}

function cancelConfirm()
{
	window.location.href="accessListv6.lp";
	document.getElementById("acessListEdit").style.display="none";
	document.getElementById("deletePath").value = "off";
	document.getElementById("resultKoAll").style.display="none";
	document.getElementById("confirmConfig").style.display="block";
	document.getElementById("resultKO_IPv6Overlap").style.display="none";
}

function cancelConfig()
{
	document.getElementById("acessListEdit").style.display="block";
	document.getElementById("resultKoAll").style.display="none";
	document.getElementById("resultKO_IPv6Overlap").style.display="none";
}

function continueConfig()
{
	document.getElementById("acessListEdit").style.display="none";
	document.getElementById("resultKoAll").style.display="none";
	document.getElementById("resultKO_IPv6Overlap").style.display="none";
	document.getElementById("confirmConfig").style.display="block";
}

//validation the ipv6 address, in order to confirm the ip address is right.
function hascolon(s) 
{ 
    // Check for colon
    if(s.indexOf(':') >= 0) 
	{ 
		return true; 
    } 
    return false; 
}

function isValidIPv6Address(IPvalue)
{
    if(hascolon(IPvalue)==true)
	{
		return /^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$|^(([a-zA-Z]|[a-zA-Z][a-zA-Z0-9\-]*[a-zA-Z0-9])\.)*([A-Za-z]|[A-Za-z][A-Za-z0-9\-]*[A-Za-z0-9])$|^\s*((([0-9A-Fa-f]{1,4}:){7}([0-9A-Fa-f]{1,4}|:))|(([0-9A-Fa-f]{1,4}:){6}(:[0-9A-Fa-f]{1,4}|((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3})|:))|(([0-9A-Fa-f]{1,4}:){5}(((:[0-9A-Fa-f]{1,4}){1,2})|:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3})|:))|(([0-9A-Fa-f]{1,4}:){4}(((:[0-9A-Fa-f]{1,4}){1,3})|((:[0-9A-Fa-f]{1,4})?:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){3}(((:[0-9A-Fa-f]{1,4}){1,4})|((:[0-9A-Fa-f]{1,4}){0,2}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){2}(((:[0-9A-Fa-f]{1,4}){1,5})|((:[0-9A-Fa-f]{1,4}){0,3}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){1}(((:[0-9A-Fa-f]{1,4}){1,6})|((:[0-9A-Fa-f]{1,4}){0,4}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(:(((:[0-9A-Fa-f]{1,4}){1,7})|((:[0-9A-Fa-f]{1,4}){0,5}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:)))(%.+)?\s*$/.test(IPvalue);
	}else
	{
	 return false;
	}
}

function customPortJudgement(port)
{	
	if((port=="") || isNaN(port) || parseInt(port)==0 || parseInt(port)>65535 || port<0)
    {
        return false;
    }
    return true;
}

function isEncrWpaKey(str)
{
	var reg = str.match(/[a-zA-Z,!,@,#,$,%,^,&,(,),_,+,=,{,},\,,.,\/,<,>,?,`,~,\[,\],|,;,:,\\]/);
	if(reg)
	{
		return false;
	}
	else
	{
		return true;
	}
}
function changePort(port)
{
	if(port == "singleport") {
		document.getElementById("fromtoport").style.display ="none";
		document.getElementById("customInternalPort").value ="";
		document.getElementById("singleport").style.display ="block";
	}
	else {
		document.getElementById("fromtoport").style.display ="block";
		document.getElementById("customInternalPortFrom").value ="";
		document.getElementById("customInternalPortTo").value ="";
		document.getElementById("singleport").style.display ="none";
	}
}

</script>
<script src="js/antiCSRF.js" type="text/javascript"></script>

<div id="confirmConfig" style="display:none">
<%cgilua.lp.include("webparts/confirmBack.lp")%>
</div>
<div id="resultKoAll" style="display:none">
<%cgilua.lp.include("webparts/resultKO_IPv6.lp")%>
</div>
<div id="resultKO_IPv6Overlap" style="display:none">
<%cgilua.lp.include("webparts/resultKO_IPv6Overlap.lp")%>
</div>

</body>
</html>
