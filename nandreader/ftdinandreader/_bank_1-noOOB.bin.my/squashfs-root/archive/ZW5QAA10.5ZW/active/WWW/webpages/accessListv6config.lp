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

-- ACLv6 table values
local aclEnable = {}
local aclPort = {}
local aclProtocol = {}
local aclClient = {}
local aclDesc = {}
local aclCount = 0
local firewallPath = "Device.Firewall.X_TELECOMITALIA_IT_ACLv6"

local aclv6reply, error=mbus.getParameters{path=firewallPath, datamodel="second"}
if (aclv6reply[firewallPath][1] ~= nil) and (aclv6reply[firewallPath][1].param ~= nil) then
	for k,v in pairs(aclv6reply[firewallPath]) do
		aclEnable[k] = v.param.Enable
		aclPort[k] = v.param.InternalPort
		aclProtocol[k] = v.param.Protocol
		aclClient[k] = v.param.InternalClient
		aclDesc[k] = v.param.Description
		aclCount = k
	end
end

local firewallPath_slen = string.len(firewallPath) + 1

function getStatus(firewallPath)
        local reply, error=mbus.getParameters{path=firewallPath, param={"Enable"}, datamodel="second"}
        if error==nil then
           return reply[firewallPath][1].param["Enable"]
        else
           return "false"  -- default is false
        end
end  

if cgilua.servervariable"REQUEST_METHOD" == "POST" then
	
	local ipv6enablepath = "Device.Firewall"	
	local modify = {}
	local result = 0
	
	if POST["protocolFlag"] == "1" then 

		local name = POST["protocolPathName"]
		local ip = POST["protocolAddress"]
		local protocol = POST["protocolType"]
		local internalProtocol = POST["internalProtocolRangePort"]
		local internalPort = POST["internalPort"]
		local status="true"
		
		result = virtualServerCreate_firewall(name, ip, protocol, internalPort, status)

	elseif POST["customFlag"] == "1" then
	
		local name = POST["customName"]
		local ip = POST["customAddress"]
		local protocol = POST["customProtocol"]
		local internalPort = POST["customInternalPort"]
		local status = POST["appStatus"]
				
		result = virtualServerCreate_firewall(name, ip, protocol, internalPort, status)	
	end
	
	if result == 1 then
		saveall(0, 1)
		cgilua.redirect("save_alert.lp", { u = "accessListv6.lp"})
		return
	end
	
	cgilua.redirect("save_alert.lp", { u = "accessListv6.lp"})
	return
end

--Start to deal with port mapping
local NATStart = ""
local NATEnd = ""
local IGD_PortMapping_slen = string.len(firewallPath) + 1
local portMappingList, error = getList_IGD(firewallPath, nil, "Description", "InternalClient", "InternalPort", "Protocol", "Enable")
local appListAll, error = getList(APP_path, nil, "Name", "HostIPAddress", "Category")

local appList, appEditList, protocolList, protocolEditList, virtualList = getListForPortMapping(appListAll, APP_slen, portMappingList)

local deviceList={}
local deviceListValue = getHostIpv6List()
if deviceListValue~=nil and deviceListValue~="" then
  deviceList=deviceListValue
end


local ipNaptedAddr=""
local ipIntf = getList("IP.Intf","(== Name Telecom_Italia)","Name")
if ipIntf[1]~=nil then
	local ipPath = ipIntf[1].path
	local natTemp = getList("NAT.Template","(== IPIntf " .. ipPath .. ")","InsideAddress")
	if natTemp[1]~=nil then
		ipNaptedAddr = natTemp[1]["InsideAddress"]
	end
end

--flags to make a distinction whether other port mapping is existing
local portConflict = ""

for i,v in pairs(virtualList) do
	local pathId = string.sub(v.path, IGD_PortMapping_slen + 1)

	local customStatus = v["Enable"]
	local isActive = translate([==[Actived]==])
	local statusColor = "tdGreen"
	if customStatus=="false" then
		isActive = translate([==[Inactived]==])
		statusColor = "tdRed"
	end

	local internalPort = v["InternalPort"]
	
	if internalPort == "0" then 
		internalPort = "*"
	end

	local starExist = string.find(internalPort, "*")
	if starExist ~= nil and v["Protocol"]=="TCP" and string.match(portConflict,"tcp")==nil then
		portConflict = portConflict.."tcp"
	elseif starExist ~= nil and v["Protocol"]=="UDP" and string.match(portConflict,"udp")==nil then
		portConflict = portConflict.."udp"
	elseif starExist ~= nil and v["Protocol"]=="ALL" and string.match(portConflict,"all")==nil then
		portConflict = portConflict.."all"
	end
end

--The warning or error message for IPv6 Firewall Access List.
local errMsgApplication={
	existconfig = translate([==[Warning: Rule already configured on the same IPv6 address with an overlapping range of ports. The rule will be created in the state 'not active']==]),

	emptyProtocol = translate([==[Warning: Select an application or protocol from the default list for the IPv6 access list that you want to create]==]),

	invalidIp = translate([==[Warning: The IPv6 address is not entered or it is not in a valid formated]==]),

	invalidRange = translate([==[Warning: The IPv6 address is not included in the LAN Range"]==]),
	
	invalidName = translate([==[Warning: Please enter a valid name for the rule that you want to create. Verify that you are not already in use or that does not contain any special characters or symbols]==]),
	
	invalidPortRange = translate([==[Warning: Check the value entered for the Port. Valid values are: 1-65535]==]),
	
	portRangeOverlap = translate([==[Warning: The port range overlaps an already defined within the same application]==]),
	
	existApplication = translate([==[Warning: The Rule is already in active. Check that the IPv6 address and the port configured have not been previous allocated to another rule]==])
}
%>

<script language="javascript" type="text/javascript">

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
function changeProtocol(val, name)
{
	if(document.getElementById("protocolName").value!=""){
		document.getElementById("protocolPathName").value = name;
		document.getElementById("protocolPathId").value = val;
		var urlStr = "/application_ajax.lp";		
		var params="pathId="+val+"&flag=procotol";
		ajax_get(urlStr, params, protocolPort_cb);	
	}
	if(name=="<<%=translate([==[Select from the list]==])%>>")
	{ 
		document.getElementById("internalProtocolRange").innerHTML = "";
		document.getElementById("internalProtocolRangePort").value = "";
		document.getElementById("internalipv6Port").innerHTML = "";
		document.getElementById("internalPort").value = "";
	}
}

function protocolSubmit()
{
	document.getElementById("protocolFlag").value = "0";
	var protocolAddr = document.getElementById("protocolAddr").value;
	document.getElementById("protocolAddress").value = protocolAddr;
	var protocolName = document.getElementById("protocolName").value;
	
	if(protocolName == "")
	{
		document.getElementById("ACLWarningMsg").innerHTML = '<%=errMsgApplication["emptyProtocol"]%>';
		document.getElementById("ipv6accesslist").style.display="none";
		document.getElementById("resultKoAll").style.display="block";
		return false;
	}

	if(!isValidIPv6Address(protocolAddr))
	{
		document.getElementById("ACLWarningMsg").innerHTML = '<%=errMsgApplication["invalidIp"]%>';
		document.getElementById("ipv6accesslist").style.display="none";
		document.getElementById("resultKoAll").style.display="block";
		return false;
	}
	
	document.getElementById("protocolFlag").value = "1";
	document.getElementById("ipv6accesslist").style.display="none";
	document.getElementById("resultKoAll").style.display="none";
	document.getElementById("confirmConfig").style.display="block";
}

function customSubmit()
{
	document.getElementById("customFlag").value = "0";
	var customAddr = document.getElementById("customAddr").value;
	document.getElementById("customAddress").value = customAddr;
	var customName = document.getElementById("customName").value;		
	var customProtocol = document.getElementById("customProtocol").value;
	
	if((customName == "") || (customName.length > 25) || (customName.charAt(0) == ' ') || (customName.charAt(customName.length-1) == ' ') || !(/^[A-Za-z0-9 ]+$/.test(customName)))
	{
		document.getElementById("ACLWarningMsg").innerHTML = '<%=errMsgApplication["invalidName"]%>';
		document.getElementById("resultKO_IPv6Overlap").style.display="none";
		document.getElementById("ipv6accesslist").style.display="none";		
		document.getElementById("resultKoAll").style.display="block";
		return false;	
	}
	<%for i,v in pairs(virtualList) do%>
		if(customName == "<%=v["Description"]%>")
		{
			document.getElementById("ACLWarningMsg").innerHTML = '<%=errMsgApplication["invalidName"]%>';
			document.getElementById("ipv6accesslist").style.display="none";
			document.getElementById("resultKO_IPv6Overlap").style.display="none";
			document.getElementById("resultKoAll").style.display="block";
			return false;
		}
	<%end%>
	<%for i,v in pairs(appListAll) do%>
		if(customName == "<%=v["Name"]%>")
		{
			document.getElementById("ACLWarningMsg").innerHTML = '<%=errMsgApplication["invalidName"]%>';
			document.getElementById("ipv6accesslist").style.display="none";
			document.getElementById("resultKO_IPv6Overlap").style.display="none";
			document.getElementById("resultKoAll").style.display="block";
			return false;
		}
	<%end%>
	
	if(!(isValidIPv6Address(customAddr))) {
		document.getElementById("ACLWarningMsg").innerHTML = '<%=errMsgApplication["invalidIp"]%>';
		document.getElementById("ipv6accesslist").style.display="none";
		document.getElementById("resultKO_IPv6Overlap").style.display="none";
		document.getElementById("resultKoAll").style.display="block";
		return false;
	}
	
	if(customProtocol == "")
	{
		document.getElementById("ACLWarningMsg").innerHTML = '<%=errMsgApplication["emptyProtocol"]%>';
		document.getElementById("ipv6accesslist").style.display="none";
		document.getElementById("resultKO_IPv6Overlap").style.display="none";
		document.getElementById("resultKoAll").style.display="block";
		return false;
	}

	var selectedPort = document.getElementById("CustomPort").value;
	var customInternalPort = document.getElementById("customInternalPort").value;
	var fromPort = document.getElementById("customInternalPortFrom").value;
	var toPort = document.getElementById("customInternalPortTo").value;
	
	if( (selectedPort == "singleport" && !customPortJudgement(customInternalPort)) || (selectedPort == "portrang" && (!customPortJudgement(fromPort) || !customPortJudgement(toPort) || parseInt(fromPort) >= parseInt(toPort))) )
	{
		document.getElementById("ACLWarningMsg").innerHTML = '<%=errMsgApplication["invalidPortRange"]%>';
		document.getElementById("ipv6accesslist").style.display="none";
		document.getElementById("resultKoAll").style.display="block";
		return false;
	}
	else 
	{
		if(selectedPort == "portrang") {
			var from_to_Port = fromPort+"-"+toPort;
			document.getElementById("customInternalPort").value = from_to_Port;
		}
		
		<%local aclv6, error=mbus.getParameters{path=firewallPath, datamodel="second"}
		
		if (aclv6[firewallPath][1] ~= nil) and (aclv6[firewallPath][1].param ~= nil) then
		for i,v in pairs(aclv6[firewallPath]) do%>
			var old_port = "<%=v.param.InternalPort%>";
			old_port =  old_port.replace(/\s+/g, '');
			var split_port  = old_port.split("-");

			if((selectedPort == "portrang" && ((!split_port[1] && parseInt(fromPort) <= split_port[0] && parseInt(toPort) >= split_port[0] && (customProtocol == "<%=v.param.Protocol%>" || customProtocol == "ALL" || "<%=v.param.Protocol%>" == "ALL")) || (split_port[1] && ( (parseInt(fromPort) <= split_port[0] && parseInt(toPort) >= split_port[0]) || (parseInt(fromPort) <= split_port[1] && parseInt(toPort) >= split_port[1]) ) && (customProtocol == "<%=v.param.Protocol%>" || customProtocol == "ALL" || "<%=v.param.Protocol%>" == "ALL") ))) ||  ((!split_port[1] && customInternalPort == split_port[0] && (customProtocol == "<%=v.param.Protocol%>" || customProtocol == "ALL" || "<%=v.param.Protocol%>" == "ALL")) || (split_port[1] && customInternalPort >= split_port[0] && customInternalPort <= split_port[1] && (customProtocol == "<%=v.param.Protocol%>" || customProtocol == "ALL" || "<%=v.param.Protocol%>" == "ALL"))) )
			{
				if(customAddr == "<%=v.param.InternalClient%>")
				{
					document.getElementById("appStatus").value = "false";
					document.getElementById("ipv6accesslist").style.display="none";
					document.getElementById("resultKoAll").style.display="none";
					document.getElementById("resultKO_IPv6Overlap").style.display="block";
					return false;
				}
				else
				{				
					document.getElementById("ACLWarningMsg").innerHTML = '<%=errMsgApplication["portRangeOverlap"]%>';
					document.getElementById("ipv6accesslist").style.display="none";
					document.getElementById("resultKO_IPv6Overlap").style.display="none";
					document.getElementById("resultKoAll").style.display="block";
					return false;
				}
			}
			
		<%end end%>
	}
	document.getElementById("customFlag").value = "1";
	document.getElementById("ipv6accesslist").style.display="none";
	document.getElementById("resultKoAll").style.display="none";
	document.getElementById("resultKO_IPv6Overlap").style.display="none";
	document.getElementById("confirmConfig").style.display="block";
}

function cancelConfirm()
{	
	window.location.href="accessListv6config.lp";
	document.getElementById("protocolFlag").value = "0";
	document.getElementById("customFlag").value = "0";
	document.getElementById("appStatus").value = "true";
}

function submitConfirm()
{
	if(document.getElementById("protocolFlag"))
	var protocolFlag = document.getElementById("protocolFlag").value;
	if(document.getElementById("customFlag"))
	var customFlag = document.getElementById("customFlag").value;
	
	if(protocolFlag == "1")
		document.protocolConfig.submit();
		
	if(customFlag == "1")
		document.customConfig.submit();
}

function cancelConfig()
{
	document.getElementById("ipv6accesslist").style.display="block";
	document.getElementById("resultKoAll").style.display="none";
	document.getElementById("resultKO_IPv6Overlap").style.display="none";
}

function continueConfig()
{
	document.getElementById("customFlag").value = "1";
	document.getElementById("ipv6accesslist").style.display="none";
	document.getElementById("resultKoAll").style.display="none";
	document.getElementById("resultKO_IPv6Overlap").style.display="none";
	document.getElementById("confirmConfig").style.display="block";
}

function linkToEdit(flag, pathId)
{
	window.location.href="accessListv6Edit.lp?flag="+flag+"&pathId="+pathId;
}

function sajax_init_object() {
	var A;
	try {
		A=new ActiveXObject("Msxml2.XMLHTTP");
	} catch (e) {
			try {
				A=new ActiveXObject("Microsoft.XMLHTTP");
			} catch (oc) {
				A=null;
			}
	}
	if(!A && typeof XMLHttpRequest != "undefined")
			A = new XMLHttpRequest();
	return A;
}

function ajax_get(url, param, callback)
{	
	var x = sajax_init_object();
	if (param) {
		url = url + '?' + param;
	}
	x.open('GET', url, true);
	x.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
	x.setRequestHeader("Connection", "close");
	x.send("");
	x.onreadystatechange = function() {
		if (x.readyState == 4)
		callback(x);
	};
	delete x;
}

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

function changeCustomDevice(val,name)
{
	if(name=="<<%=translate([==[IPv6 Available]==])%>>")
	{ 
	  document.getElementById("customAddr").value = "";
	}
	if(document.getElementById("deviceCustom").value!="")
	{
		  document.getElementById("customAddr").value = val;		
	}   
}

function protocolPort_cb(ajax_obj)
{
	var rsps = ajax_obj.responseText.replace(/\s/g,"");
	
	var arrProtocolName = rsps.split("##");
	var arrPortValue = arrProtocolName[1].split(":");
	
	document.getElementById("internalProtocolRange").innerHTML = arrProtocolName[2];
	document.getElementById("internalProtocolRangePort").value = arrProtocolName[2];	
	document.getElementById("internalipv6Port").innerHTML = arrProtocolName[0];
	document.getElementById("internalPort").value = arrPortValue[1];
	
	document.getElementById("protocolType").value = arrProtocolName[2];
	
	if(arrProtocolName[0]=="UDP:*,7,9")
	{ 
	  document.getElementById("internalProtocolRange").innerHTML = "UDP:7-9";	 
	  document.getElementById("internalProtocolRangePort").value = "UDP:7-9";	 
	}
}

function portChange(port)
{
	if(port=="*")
	{
		document.getElementById("customInternalPort").value="*";
		
	}
}

function changePort(port)
{
	if(port == "singleport") {
		document.getElementById("fromtoport").style.display ="none";
		document.getElementById("singleport").style.display ="block";
	}
	else {
		document.getElementById("fromtoport").style.display ="block";
		document.getElementById("singleport").style.display ="none";
	}
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
			<li><a href="accessListv6.lp">
				<div class="tab">
					<span class="tabIcon_fire"></span>  
					<span class="contTabTxt transform"><%=translate([==[Firewall IPv6]==])%></span>
				</div><div class="clrBth"></div></a>
			</li>
			<li><a class="current margin15" href="accessListv6config.lp">
				<div class="tab">
				<span class="contTabTxt transform"><%=translate([==[Configure Firewall IPv6]==])%></span></div></a>
			</li>
		</ol>
	</div>
	
	<div class='contentitem' id="ipv6accesslist">
	<%
	writePageRowHeader(translate([==[Configuration Access List IPv6]==]))
	%>
	<!-- start to config access list ipv6 info -->
	<form id="protocolConfig" name="protocolConfig" action="" method="post">
	<input type="hidden" id="protocolFlag" name="protocolFlag" value="0"/>
	<input type="hidden" id="protocolAddress" name="protocolAddress" value=""/>

	<%
	writeTableRowTitle_port(translate([==[ ]==]))
	writeTableBlockRowHeader(4,translate([==[Application]==]),translate([==[Destination IP]==]),translate([==[Protocol]==]),translate([==[Configure]==]))
	%>		
						
	<tr><td class='oddrow' colspan='4'><img src='images/spacer.gif' border='0' width='1' height='3' alt=''><br></td></tr>
	<tr>
		<td class="oddrow midvertical">
	<%
	createSelect('<select id="protocolName" name="protocolName" class="inputClass" onchange="changeProtocol(this.value, this.options[this.selectedIndex].text)"><option value="">&lt;' .. translate([==[Select from the list]==]) .. '&gt;</option>',nil,protocolList,"Name","path")
	%>
	
	<input type="hidden" id="protocolPathId" name="protocolPathId" value="" /><input type="hidden" id="protocolPathName" name="protocolPathName" value="" /><input type="hidden" id="protocolType" name="protocolType" value="" />
	
	<input type="hidden" id="gameName" name="gameName" value="" />
		</td>
		<td class="oddrow midvertical" style="white-space:nowrap;">
		   <input type="text" id="protocolAddr" name="protocolAddr" size="26" maxlength="26" class="inputClass" value=""/>
			<div class="padtop5">
			<%
			createSelect('<select name="deviceProtocol" id="deviceProtocol" class="inputClass" onchange="changeProtocolDevice(this.value, this.options[this.selectedIndex].text);"><option value="">&lt;' .. translate([==[IPv6 Available]==]) .. '&gt;</option>', nil,deviceList, "IPAddress", "IPAddress")
		   %> </div>
		</td>
		<td class="oddrow midvertical">
		   <div id="internalProtocolRange" style="width:70px;"></div><input type="hidden" id="internalProtocolRangePort" name="internalProtocolRangePort" value="" />
		</td>
		<td class="oddrow midvertical">
		<br />
		<a onclick='protocolSubmit()' href="#">
		<div class='midarea6-1 mainButton' name="thb14"  class="alignMid"><%=translate([==[Active]==])%></div></a>
		</td>
	</tr>
	
	<tr><td class="oddrow" colspan='4'><img src='images/spacer.gif' border='0' width='1' height='3' alt=''><br></td></tr>
			
	<tr><td class="evenrow" colspan='4'><img src='images/spacer.gif' border='0' width='1' height='3' alt=''><br></td></tr>
	<tr>
		<td class="evenrow"><%=translate([==[Port]==])%> </td>
		<td class="evenrow" colspan="3">
			<div id="internalipv6Port">&nbsp;</div><input type="hidden" id="internalPort" name="internalPort" value="" />
		</td>
	</tr>
	<tr><td class="evenrow" colspan='4'><img src='images/spacer.gif' border='0' width='1' height='3' alt=''><br></td></tr>

	<%endBlock()%>
	</form>		

<!-- end of  access list info -->

	<tr><td class="padtop5">&nbsp;</td></tr>
	<!-- start to config custom virtual info -->
	<form id="customConfig" name="customConfig" action="" method="post">
	<input type="hidden" id="customFlag" name="customFlag" value="0" />
	<input type="hidden" id="customAddress" name="customAddress" value="" />
	<input type="hidden" id="appStatus" name="appStatus" value="true"/>
	<%
	writeTableRowTitle_port(translate([==[Custom Access List]==]))
	writeTableBlockRowHeader(4,translate([==[Name]==]),translate([==[Destination IP]==]),translate([==[Protocol]==]),translate([==[Configure]==]))
	%>
		

	<tr><td class="oddrow" colspan='4'><img src='images/spacer.gif' border='0' width='1' height='3' alt=''><br></td></tr>

	<tr>
		<td class="oddrow midvertical"><input type="text" name="customName" id="customName" size="24" class="inputClass" /></td>
		<td class="oddrow midvertical" style="white-space:nowrap;">
			 <input type="text" id="customAddr" name="customAddr" size="26" maxlength="26" class="inputClass" value=""/>
	 <div class="padtop5">
	<%
	createSelect('<select name="deviceCustom" id="deviceCustom" class="inputClass" onchange="changeCustomDevice(this.value, this.options[this.selectedIndex].text);"><option value="">&lt;' .. translate([==[IPv6 Available]==]) .. '&gt;</option>', nil,deviceList, "IPAddress", "IPAddress")
	%></div>

		</td>
		<td class="oddrow midvertical">
					<select size="1" id="customProtocol" name="customProtocol" class="inputClass">
					<option value=""><%=translate([==[Choose]==])%>...</option>
					<option value="TCP">TCP</option>
					<option value="UDP">UDP</option>
					<option value="ALL">ALL</option>
					</select>
		</td>

		<td class="oddrow midvertical">
			<br />
			<a onclick='customSubmit()' href="#">
			<div class='midarea6-1 mainButton' name="thb14" style="vertical-align:middle"><%=translate([==[Active]==])%></div></a>
		</td>
	</tr>
	<tr><td class="oddrow" colspan='4'><img src='images/spacer.gif' border='0' width='1' height='3' alt=''><br></td></tr>
	
	<tr><td class="evenrow" colspan='4'><img src='images/spacer.gif' border='0' width='1' height='3' alt=''><br></td></tr>
	<tr><td class="evenrow" colspan='4'><img src='images/spacer.gif' border='0' width='1' height='3' alt=''><br></td></tr>
	<tr>
		<td class="evenrow"><%=translate([==[Port]==])%></td>
		<td class="evenrow" colspan="3">
			<div id="singleport" name="singleport" class="align_topEle">
				<input type="text" name="customInternalPort" id="customInternalPort" size="26" class="inputClass" onchange="portChange(this.value)" />
			</div>
			<div id="fromtoport" name="fromtoport" style="display:none;">
				<div>
				<div style="float:left;"><%=translate([==[From]==])%></div>
				<div style="float:left;margin-left:1%"><input type="text" name="customInternalPortFrom" id="customInternalPortFrom" size="6" class="inputClass" /></div>
				</div>
				<div>
				<div style="float:left;margin-left:2%"><%=translate([==[To]==])%></div>
				<div style="margin-left:22%"><input type="text" name="customInternalPortTo" id="customInternalPortTo" size="6" class="inputClass" /></div>
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
	<%endBlock()%>
	</form>
	<input type="hidden" id="portConflictFlag" name="portConflictFlag" value="<%=portConflict%>" />
	<%endBlock()%>
</div>
<script src="js/antiCSRF.js" type="text/javascript"></script>

<div id="resultKoAll" style="display:none">
<%cgilua.lp.include("webparts/resultKO_IPv6.lp")%>
</div>
<div id="resultKO_IPv6Overlap" style="display:none">
<%cgilua.lp.include("webparts/resultKO_IPv6Overlap.lp")%>
</div>
<div id="confirmConfig" name="confirmConfig" style="display:none">
<%cgilua.lp.include("webparts/confirmBack.lp")%>
</div>

</body>
</html>
