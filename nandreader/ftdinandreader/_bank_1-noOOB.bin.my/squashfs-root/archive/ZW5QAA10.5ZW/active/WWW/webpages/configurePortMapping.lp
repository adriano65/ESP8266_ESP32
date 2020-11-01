<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
<title>Modem Telecom Italia</title>
<!-- <link rel="stylesheet" href="css/style.css" type="text/css" />
<link rel="stylesheet" href="css/menu.css" type="text/css" />
 -->
 <link rel="stylesheet" href="css/master.css" type="text/css" />
 <script language="javascript" type="text/javascript" src="js/script.js"></script>
<script language="javascript" type="text/javascript" src="js/portmap.js"></script>
<% 
cgilua.lp.include("lp/util.lp")
cgilua.lp.include("lp/mbus_util.lp")
cgilua.lp.include("lp/form.lp")
cgilua.lp.include("lp/portmap.lp")
cgilua.lp.include("lp/common.lp")
cgilua.lp.include("lp/style.lp")
local getIntSession = cgilua.get_session_var("Key1")
local getExtSession = cgilua.get_session_var("Key2")
local getProtocolSession = cgilua.get_session_var("KeyProtocol")
local tprint = require("tableprint")

local translate = translate
local POST=cgilua.POST

local ipInfo_T = getIPInfo()
local lanOption = getLANOption()
local TI_Device = getTIInfo_Device()

if TI_Device.lanOption ~= "res-rt-napt" and TI_Device.lanOption ~= "biz-rt-napt-ena" and TI_Device.lanOption ~= "res-rt-napt-ipv6"
and TI_Device.lanOption ~= "biz-rt-napt-ipv6" then
--  cgilua.redirect("index.lp")
--  return
end

-- get NAT status 
local NATStatus = ""
local NATStart = ""
local NATEnd = ""
local NATPath = "Device.NAT.InterfaceSetting.ppp_0"
local reply, error = mbus.getParameters{ path = NATPath,
                        param = {"Enable", "X_TELECOMITALIA_IT_NATStartIPAddress", "X_TELECOMITALIA_IT_NATEndIPAddress"},
                        flags = "KEYPATH", datamodel = "second" }

if error==nil then
  NATStatus = reply[NATPath][1].param["Enable"]
  NATStart  = reply[NATPath][1].param["X_TELECOMITALIA_IT_NATStartIPAddress"]
  NATEnd    = reply[NATPath][1].param["X_TELECOMITALIA_IT_NATEndIPAddress"]
end

--Fix CPE_P00103489.
local natPath = "Device.NAT.InterfaceSetting.2"
local replyNat, errorNat = mbus.getParameters{ path = natPath, param = "X_TELECOMITALIA_IT_NATExcludedInternalIPAddresses", datamodel = "second" }
local natIPAddr = replyNat[natPath][1].param["X_TELECOMITALIA_IT_NATExcludedInternalIPAddresses"]

if cgilua.servervariable"REQUEST_METHOD" == "POST" then

  if NATStatus=="" then
  -- the NAT status has problem, so do nothing, just go back.
    cgilua.redirect("statoPortMapping.lp")
    return
  end

  if POST["gameConfigFlag"] == "1" then
    local name = POST["gameName"]
    local ip = POST["hostIPAddress"]
    local protocol = POST["gameProtocol"]
    local internalPort = POST["internalRangePort"]
    local externalPort = POST["externalRangePort"]
    if tostring(ip)==tostring(natIPAddr) then
      cgilua.redirect("resultKO.lp")
      return
    end
    
    local status="true"
    -- only NAT enable and in NAT range, portmapping can enable
  --  if NATStatus=="true" and inRange(ip, NATStart, NATEnd)==true then 
    --  status="true"
   -- end
    local manualDisabled = "false"
    local intfDisabled = "true"
	cgilua.errorlog("NATStatus is " .. tostring(NATStatus))
    if NATStatus=="true" and inRange(ip, NATStart, NATEnd)==true then 
		intfDisabled="false"
    end
    cgilua.errorlog("intfDisabled is " .. tostring(intfDisabled))
    local result = virtualServerCreate_IGD(name, ip, protocol, internalPort, externalPort, status, manualDisabled, intfDisabled)
    if result==1	then
      cgilua.redirect("portmapping_conflictAlert.lp",{ flag="config", nameInfo=name, ipInfo=ip, protocolInfo=protocol, internalPortInfo=internalPort, externalPortInfo=externalPort })
      return
    end
  elseif POST["customFlag"] == "1" then
    local name = POST["customName"]
    local ip = POST["customAddress"]
    local protocol = POST["customProtocol"]
    local internalPort = POST["customInternalPort"]
    local externalPort = POST["customExternalPort"]
    if tostring(ip)==tostring(natIPAddr) then
      cgilua.redirect("resultKO.lp")
      return
    end
    
    local status="true"
    -- only NAT enable and in NAT range, portmapping can enable
 --   if NATStatus=="true" and inRange(ip, NATStart, NATEnd)==true then 
   --   status="true"
  --  end
    local manualDisabled = "false"
    local intfDisabled = "true"
    if NATStatus=="true" and inRange(ip, NATStart, NATEnd)==true then 
		intfDisabled="false"
    end
    
    local result = virtualServerCreate_IGD(name, ip, protocol, internalPort, externalPort, status, manualDisabled, intfDisabled)
    if result==1	then
      cgilua.redirect("portmapping_conflictAlert.lp",{ flag="config", nameInfo=name, ipInfo=ip, protocolInfo=protocol, internalPortInfo=internalPort, externalPortInfo=externalPort })
      return
    end
  end
  
  saveall(0, 1)
  cgilua.redirect("save_alert.lp", { u = "statoPortMapping.lp" })
  return
end

--Start to deal with port mapping
local portMappingPath = "Device.NAT.PortMapping"
local IGD_PortMapping_slen = string.len(portMappingPath) + 1
local portMappingList, error = getList_IGD(portMappingPath, nil, "Description", "InternalClient", "InternalPort", "ExternalPort", "Protocol", "Enable")

local APP_path  = "NATAppList.App"
local APP_slen = string.len(APP_path)+1
local appListAll, error = getList(APP_path, nil, "Name", "HostIPAddress", "Category")
local appList, appEditList, protocolList, protocolEditList, virtualList = getListForPortMapping(appListAll, APP_slen, portMappingList)

local deviceList = getHostIpList(NATStart, NATEnd)

local ipNaptedAddr=""
local ipIntf = getList("IP.Intf","(== Name Telecom_Italia)","Name")
if ipIntf[1]~=nil then
  local ipPath = ipIntf[1].path
  local natTemp = getList("NAT.Template","(== IPIntf " .. ipPath .. ")","InsideAddress")
  if natTemp[1]~=nil then
    ipNaptedAddr = natTemp[1]["InsideAddress"]
--	cgilua.errorlog("@@@ipNaptedAddr is " .. tostring(ipNaptedAddr))
  end
end

--flags to make a distinction whether other port mapping is existing
local portConflict = ""
%>

<script type="text/javascript">
//<![CDATA[

var natStatus = "<%=NATStatus%>";

function changeApp(val,name)
{
  if(document.getElementById("appName").value!=""){
    document.getElementById("gameName").value = name;
    var urlStr = "/application_ajax.lp";
    var params="pathId="+val+"&flag=game";
    ajax_get(urlStr, params, gamePort_cb)
  }
}

function changeDevice(val)
{
  if(document.getElementById("deviceIp").value!=""){
    var arrIp = val.split(".");
    document.getElementById("ipAddr1").value = arrIp[0];
    document.getElementById("ipAddr2").value = arrIp[1];
    document.getElementById("ipAddr3").value = arrIp[2];
    document.getElementById("ipAddr4").value = arrIp[3];
  }   
}

function gameConfigSubmit()
{
  document.getElementById("gameConfigFlag").value = "1";
  var ipAddr1 = document.getElementById("ipAddr1").value;
  var ipAddr2 = document.getElementById("ipAddr2").value;
  var ipAddr3 = document.getElementById("ipAddr3").value;
  var ipAddr4 = document.getElementById("ipAddr4").value;
  var ipAddr = ipAddr1 + "." + ipAddr2 + "." + ipAddr3 + "." + ipAddr4;
  document.getElementById("hostIPAddress").value = ipAddr;

  if(!(isValidIPAddress(ipAddr) && ipAddr != "<%=ipNaptedAddr%>"))
  {
    document.getElementById("PMWarningMsg").innerHTML = "<%=errMsgIP%>";
    document.getElementById("portMapping").style.display="none";
    document.getElementById("resultKoAll").style.display="block";
    return false;
  }

  //Fix for Tessa 273
  if((!inRange(ipAddr, "<%=NATStart%>","<%=NATEnd%>")) || (natStatus == "false"))
  {
    document.getElementById("PMWarningMsg").innerHTML = "<%=errMsgNAT%>";
    document.getElementById("portMapping").style.display="none";
    document.getElementById("resultKoAll").style.display="block";
    return false;
  }

  var appName = document.getElementById("appName").value;	
  if(appName == "")
  {
    document.getElementById("PMWarningMsg").innerHTML = "<%=errMsgNoApp%>";
    document.getElementById("portMapping").style.display="none";
    document.getElementById("resultKoAll").style.display="block";
    return false;	
  }

  var GameName = document.getElementById("gameName").value;
  <%for i,v in pairs(portMappingList) do%>
	if(GameName == "<%=tostring(v["Description"])%>")
        {
		document.getElementById("PMWarningMsg").innerHTML = "<%=errMsgName%>";
		document.getElementById("portMapping").style.display="none";
		document.getElementById("resultKoAll").style.display="block";
		return false;
        }
  <%end%>

  document.getElementById("portMapping").style.display="none";
  document.getElementById("confirmConfig").style.display="block";
}

function changeCustomDevice(val)
{
  if(document.getElementById("deviceCustom").value!=""){
    var arrIp = val.split(".");
    document.getElementById("customAddr1").value = arrIp[0];
    document.getElementById("customAddr2").value = arrIp[1];
    document.getElementById("customAddr3").value = arrIp[2];
    document.getElementById("customAddr4").value = arrIp[3];
  }
}

function customSubmit()
{
	document.getElementById("customFlag").value = "1";
	var customAddr1 = document.getElementById("customAddr1").value;
	var customAddr2 = document.getElementById("customAddr2").value;
	var customAddr3 = document.getElementById("customAddr3").value;
	var customAddr4 = document.getElementById("customAddr4").value;
	var customAddr = customAddr1 + "." + customAddr2 + "." + customAddr3 + "." + customAddr4;
	document.getElementById("customAddress").value = customAddr;

	if(!(isValidIPAddress(customAddr) && customAddr != "<%=ipNaptedAddr%>"))
	{		
		document.getElementById("PMWarningMsg").innerHTML = "<%=errMsgIP%>";
		document.getElementById("portMapping").style.display="none";
		document.getElementById("resultKoAll").style.display="block";
		return false;
	}

	// Fix for Tessa 273	
	if((!inRange(customAddr, "<%=NATStart%>","<%=NATEnd%>")) || (natStatus == "false"))
	{
		document.getElementById("PMWarningMsg").innerHTML = "<%=errMsgNAT%>";
		document.getElementById("portMapping").style.display="none";
		document.getElementById("resultKoAll").style.display="block";
		return false;
	}

	var customName = document.getElementById("customName").value;
	if(customName == "" || (customName.length > 25) || (customName.charAt(0) == ' ') || (customName.charAt(customName.length-1) == ' ') || !(/^[A-Za-z0-9 ]+$/.test(customName)))
	{
		document.getElementById("PMWarningMsg").innerHTML = "<%=errMsgName%>";
		document.getElementById("portMapping").style.display="none";
		document.getElementById("resultKoAll").style.display="block";
		return false;	
	}
	<%for i,v in pairs(virtualList) do%>
		if(customName == "<%=tostring(v["Description"])%>")
                {
			document.getElementById("PMWarningMsg").innerHTML = "<%=errMsgName%>";
			document.getElementById("portMapping").style.display="none";
			document.getElementById("resultKoAll").style.display="block";
			return false;
                }
	<%end%>
	<%for i,v in pairs(appListAll) do%>
		if(customName == "<%=tostring(v["Name"])%>")
		{
			document.getElementById("PMWarningMsg").innerHTML = "<%=errMsgName%>";
			document.getElementById("portMapping").style.display="none";
			document.getElementById("resultKoAll").style.display="block";
			return false;
		}
	<%end%>

	var customProtocol = document.getElementById("customProtocol").value;
	if(customProtocol == "")
	{
		document.getElementById("PMWarningMsg").innerHTML = "<%=errMsgNoApp%>";
		document.getElementById("portMapping").style.display="none";
		document.getElementById("resultKoAll").style.display="block";
		return false;	
	}

	var customInternalPort = document.getElementById("customInternalPort").value;
	var customExternalPort = document.getElementById("customExternalPort").value;
	var customProtocol = document.getElementById("customProtocol").value;
	var portConflictFlag = document.getElementById("portConflictFlag").value;
	//var customProtocol = document.getElementById("customProtocol").value;
	//if(
        //   (customInternalPort=="*" || customExternalPort=="*") && 
        //   (
        //    (portConflictFlag.indexOf("all")!= -1 && customProtocol=="ALL") || 
        //    (portConflictFlag.indexOf("tcp")!= -1 && customProtocol=="TCP") || 
        //   (portConflictFlag.indexOf("udp")!= -1 && customProtocol=="UDP") ))
	//{
	//	document.getElementById("portMapping").style.display="none";
	//	document.getElementById("portConflict").style.display="block";
	//}
	var portIntParam = "<%=getIntSession%>";	
	var portExtParam = "<%=getExtSession%>";
	portIntParam = portIntParam.split("^");
	portExtParam = portExtParam.split("%");
	var portProtocol = "<%=getProtocolSession%>";	
	portProtocol = portProtocol.split("@");
	
	for(i=1;i<portProtocol.length;i++)
	{
		var portSplitVal = portIntParam
		var portExtVal = portExtParam
		var custSplitVal = customInternalPort.split("-");
		var custExtVal = customExternalPort.split("-");
		
		//Internal Port and Protocol
		if(custSplitVal[1]!= null)
		{
		var portSplitValue = portSplitVal[i].split("-");
		portSplitValue[0] = Number(portSplitValue[0]);		
		 if(portSplitValue.length > 1)
		 {		
			portSplitValue[1] = Number(portSplitValue[1]);
			if((custSplitVal[0] >= portSplitValue[0] && custSplitVal[0] <= portSplitValue[1]) ||
         (custSplitVal[1] >= portSplitValue[0] && custSplitVal[1] <= portSplitValue[1]) ||
         (portSplitValue[0] >= custSplitVal[0] && portSplitValue[0] <= custSplitVal[1]) ||
         (portSplitValue[1] >= custSplitVal[0] && portSplitValue[1] <= custSplitVal[1]))
			{
			if((portProtocol[i] == customProtocol) || (portProtocol[i]=="ALL" && (customProtocol=="TCP" || customProtocol=="UDP")) || (customProtocol=="ALL" && (portProtocol[i]=="TCP" || portProtocol[i]=="UDP")))
				{
				document.getElementById("PMWarningMsg").innerHTML = "<%=errMsgRange%>";
				document.getElementById("portMapping").style.display="none";
				document.getElementById("confirmConfig").style.display="none";
				document.getElementById("resultKoAll").style.display="block";
				return false;
				}
			}
		 }
		 else
		 {
			if(((portSplitVal[i]==custSplitVal[0]) || (portSplitVal[i]==custSplitVal[1]) || ((Number(portSplitVal[i])<custSplitVal[1]) && (Number(portSplitVal[i])>custSplitVal[0])))&&((portProtocol[i] == customProtocol) || (portProtocol[i]=="ALL" && (customProtocol=="TCP" || customProtocol=="UDP")) || (customProtocol=="ALL" && (portProtocol[i]=="TCP" || portProtocol[i]=="UDP"))))
			{
			document.getElementById("PMWarningMsg").innerHTML = "<%=errMsgRange%>";
			document.getElementById("portMapping").style.display="none";
			document.getElementById("confirmConfig").style.display="none";
			document.getElementById("resultKoAll").style.display="block";
			return false;
			}
		 }
		}
		else
		{
		var portSplitValue = portSplitVal[i].split("-");
		
		portSplitValue[0] = Number(portSplitValue[0]);
		
		 if(portSplitValue.length > 1)
		 {
			portSplitValue[1] = Number(portSplitValue[1]);
			if(((customInternalPort >= portSplitValue[0])&&(customInternalPort <= portSplitValue[1]))&&((portProtocol[i] == customProtocol) || (portProtocol[i]=="ALL" && (customProtocol=="TCP" || customProtocol=="UDP")) || (customProtocol=="ALL" && (portProtocol[i]=="TCP" || portProtocol[i]=="UDP"))))
			{
			document.getElementById("PMWarningMsg").innerHTML = "<%=errMsgRange%>";
			document.getElementById("portMapping").style.display="none";
			document.getElementById("confirmConfig").style.display="none";
			document.getElementById("resultKoAll").style.display="block";
			return false;
			}
		 }
		}
		
		//External Port and Protocol
		if(custExtVal[1]!= null)
		{
		var portSplitValue = portExtVal[i].split("-");
		portSplitValue[0] = Number(portSplitValue[0]);
		
		 if(portSplitValue.length > 1)
		 {
			portSplitValue[1] = Number(portSplitValue[1]);
			if((custExtVal[0] >= portSplitValue[0] && custExtVal[0] <= portSplitValue[1]) ||
         (custExtVal[1] >= portSplitValue[0] && custExtVal[1] <= portSplitValue[1]) ||
         (portSplitValue[0] >= custExtVal[0] && portSplitValue[0] <= custExtVal[1]) ||
         (portSplitValue[1] >= custExtVal[0] && portSplitValue[1] <= custExtVal[1]))
			{
			if((portProtocol[i] == customProtocol) || (portProtocol[i]=="ALL" && (customProtocol=="TCP" || customProtocol=="UDP")) || (customProtocol=="ALL" && (portProtocol[i]=="TCP" || portProtocol[i]=="UDP")))
				{
				document.getElementById("PMWarningMsg").innerHTML = "<%=errMsgRange%>";
				document.getElementById("portMapping").style.display="none";
				document.getElementById("confirmConfig").style.display="none";
				document.getElementById("resultKoAll").style.display="block";
				return false;
				}
			}
		 }
		 else
		 {
			if(((portExtVal[i]==custExtVal[0]) || (portExtVal[i]==custExtVal[1]) || ((Number(portExtVal[i])<custExtVal[1]) && (Number(portExtVal[i])>custExtVal[0])))&&((portProtocol[i] == customProtocol) || (portProtocol[i]=="ALL" && (customProtocol=="TCP" || customProtocol=="UDP")) || (customProtocol=="ALL" && (portProtocol[i]=="TCP" || portProtocol[i]=="UDP"))))
			{
			document.getElementById("PMWarningMsg").innerHTML = "<%=errMsgRange%>";
			document.getElementById("portMapping").style.display="none";
			document.getElementById("confirmConfig").style.display="none";
			document.getElementById("resultKoAll").style.display="block";
			return false;
			}
		 }
		}
		else
		{
		var portSplitValue = portExtVal[i].split("-");
		portSplitValue[0] = Number(portSplitValue[0]);
		
		 if(portSplitValue.length > 1)
		 {
			portSplitValue[1] = Number(portSplitValue[1]);
			if(((customExternalPort >= portSplitValue[0])&&(customExternalPort <= portSplitValue[1]))&&((portProtocol[i] == customProtocol) || (portProtocol[i]=="ALL" && (customProtocol=="TCP" || customProtocol=="UDP")) || (customProtocol=="ALL" && (portProtocol[i]=="TCP" || portProtocol[i]=="UDP"))))
			{
			document.getElementById("PMWarningMsg").innerHTML = "<%=errMsgRange%>";
			document.getElementById("portMapping").style.display="none";
			document.getElementById("confirmConfig").style.display="none";
			document.getElementById("resultKoAll").style.display="block";
			return false;
			}
		 }
		 else
		 {
			if(((customExternalPort == portExtVal[i]))&&((portProtocol[i] == customProtocol) || (portProtocol[i]=="ALL" && (customProtocol=="TCP" || customProtocol=="UDP")) || (customProtocol=="ALL" && (portProtocol[i]=="TCP" || portProtocol[i]=="UDP"))))
			{
			document.getElementById("PMWarningMsg").innerHTML = "<%=errMsgRange%>";
			document.getElementById("portMapping").style.display="none";
			document.getElementById("confirmConfig").style.display="none";
			document.getElementById("resultKoAll").style.display="block";
			return false;
			}
		 }
		}
	}

	if(isValidFullPortRange(customInternalPort, customExternalPort) || (customInternalPort=="*" && customExternalPort=="*"))
	{
		document.getElementById("portMapping").style.display="none";
		document.getElementById("confirmConfig").style.display="block";
	}else{
		document.getElementById("PMWarningMsg").innerHTML = "<%=errMsgPort%>";
		document.getElementById("portMapping").style.display="none";
		document.getElementById("resultKoAll").style.display="block";
	}

    if(((customInternalPort.indexOf("TCP")>-1) && (customInternalPort.indexOf("UDP")>-1) && (customInternalPort.indexOf(";")>-1) && (customProtocol!="ALL")) || ((customExternalPort.indexOf("TCP")>-1) && (customExternalPort.indexOf("UDP")>-1) && (customExternalPort.indexOf(";")>-1) && (customProtocol!="ALL")))
    {
        document.getElementById("PMWarningMsg").innerHTML = "<%=errMsgPort%>";
        document.getElementById("confirmConfig").style.display="none";
        document.getElementById("portMapping").style.display="none";
        document.getElementById("resultKoAll").style.display="block";
    }

    if(((customInternalPort.indexOf("TCP")>-1) && (customProtocol=="UDP") || (customInternalPort.indexOf("UDP")>-1) && (customProtocol=="TCP")) || ((customExternalPort.indexOf("TCP")>-1) && (customProtocol=="UDP") || (customExternalPort.indexOf("UDP")>-1) && (customProtocol=="TCP")))
    {
        document.getElementById("PMWarningMsg").innerHTML = "<%=errMsgPort%>";
        document.getElementById("confirmConfig").style.display="none";
        document.getElementById("portMapping").style.display="none";
        document.getElementById("resultKoAll").style.display="block";
    }
}

function cancelConfirm()
{
  document.getElementById("portMapping").style.display="block";
  document.getElementById("confirmConfig").style.display="none";
  document.getElementById("resultKoIp").style.display="none";
  document.getElementById("resultKoAll").style.display="none";
  document.getElementById("resultKoNoName").style.display="none";
  document.getElementById("portConflict").style.display="none";
  
  document.getElementById("gameConfigFlag").value = "0";
  document.getElementById("customFlag").value = "0";
}

function submitConfirm()
{
  document.getElementById("wifi_submit").removeAttribute("href");
  document.getElementById("wifi_submit").onclick = null;
  document.getElementById("wifi_submit_con").className = "next_wifidisable";
  var gameConfigFlag = document.getElementById("gameConfigFlag").value;
  var customFlag = document.getElementById("customFlag").value;
  
  if(gameConfigFlag == "1")
  {
    document.gameConfig.submit();
  }
  else if(customFlag == "1")
  {
    document.customConfig.submit();
  }
}

function gamePort_cb(ajax_obj)
{
  var rsps = ajax_obj.responseText.replace(/\s/g,"");
  var arrAppName = rsps.split("##");		

 //in case external Port is too long to display in GUI urgly, add some whitespace
  temp0=arrAppName[0].replace(",", ", "); 
  temp0=temp0.replace(";", "; "); 
  temp1=arrAppName[1].replace(",", ", "); 
  temp1=temp0.replace(";", "; "); 

  document.getElementById("internalRange").innerHTML = temp0;
  document.getElementById("externalRange").innerHTML = temp1;
  document.getElementById("gameProto").innerHTML = arrAppName[2];
  document.getElementById("internalRangePort").value = arrAppName[0];
  document.getElementById("externalRangePort").value = arrAppName[1];
  document.getElementById("gameProtocol").value = arrAppName[2];
}
//]]>
</script>
</head>
<body>

<div class="contentContainer">
	 
		<div class="breadCrumbContainer">
			<ul class="brdCrumb">
				<li><a href="advance.lp"><%=translate([==[Advanced Settings]==])%></a></li><li>|</li> <li><a href="configurePortMapping.lp"><%=translate([==[Port Mapping]==])%></a></li> 
				</ul>
		</div>	

<div class="contentTab" id="content">
	<ol id="tocTab">
		<li><a id="mediaStatus" href="statoPortMapping.lp" >
			<div class="tab">
			<span class="tabIcon_stport"></span>  
			<span class="contTabTxt transform"><%=translate([==[Port Mapping]==])%></span>
		</div><div class="clrBth"></div></a></li>
		<li><a  id="mediaconfig" href="configurePortMapping.lp" class="margin15 current">
			<div class="tab">
				<span class="contTabTxt transform"><%=translate([==[Configure]==])%> Port Mapping</span></div></a></li>			
	</ol>
</div>


<!-- <table cellspacing='0' cellpadding='0' width="100%" class="NavBar">
<tr><td align="left"><a href="advance.lp">Avanzate</a>&nbsp;&nbsp;>&nbsp;&nbsp;<a href="configurePortMapping.lp">Port Mapping</a></td><td align="right"><a href="statoPortMapping.lp">Stato</a>&nbsp;&nbsp;|&nbsp;&nbsp;<em>Configura</em></td></tr>
</table> -->

<div class='contentcontainer'>
<div class='contentitem' id="portMapping">
<%
writePageRowHeader(translate([==[Configuration]==]).." Port Mapping")
%>
<!-- start to config port mapping info -->
<form id="gameConfig" name="gameConfig" action="" method="post">
<input type="hidden" id="gameConfigFlag" name="gameConfigFlag" value="0" />
<input type="hidden" id="hostIPAddress" name="hostIPAddress" value="" />

<%
writeTableRowTitle_port(translate([==[Manage Port Mapping]==]))
writeTableBlockRowHeader(4,translate([==[Application]==]),translate([==[Destination IP]==]),translate([==[Protocol]==]),translate([==[Configure]==]))

%>
			
<tr><td class='oddrow' colspan='4'><img src='images/spacer.gif' border='0' width='1' height='3' alt=''><br></td></tr>
<tr>
    <td class="oddrow midvertical">
<%
createSelect('<select id="appName" name="appName" class="inputClass" onchange="changeApp(this.value, this.options[this.selectedIndex].text)"><option value="">' .. translate([==[Select from the list]==]) .. ' </option>',nil,appList,"Name","path")
%><input type="hidden" id="gameName" name="gameName" value="" />
	</td>
	<td class="oddrow midvertical" style="white-space:nowrap;">
       <div><input type="text" id="ipAddr1" name="ipAddr1" size="3" maxlength="3" class="inputClass" /><b>.</b><input type="text" id="ipAddr2" name="ipAddr2" size="3" maxlength="3" class="inputClass" /><b>.</b><input type="text" id="ipAddr3" name="ipAddr3" size="3" maxlength="3" class="inputClass" /><b>.</b><input type="text" id="ipAddr4" name="ipAddr4" size="3" maxlength="3" class="inputClass" /></div>
        <div class="padtop5"><%
createSelect('<select name="deviceIp" id="deviceIp" class="inputClass" onchange="changeDevice(this.value);"><option value="">&lt; ' .. translate([==[IP Available]==]) .. ' &gt;</option>', nil,deviceList, "IPAddress", "IPAddress")
       %> </div>
    </td>
    <td class="oddrow midvertical">
       <div id="gameProto">&nbsp;</div><input type="hidden" id="gameProtocol" name="gameProtocol" value="" />
    </td>
	<td class="oddrow midvertical">
	<br />
	<a onclick='gameConfigSubmit()' href="#">
	<div class='midarea6-1 mainButton' name="thb14"  class="alignMid"><%=translate([==[Active]==])%></div></a>
       <!-- <input type="button" class="button" onclick='gameConfigSubmit()' value="<%=translate([==[Active]==])%>" name="thb14" /> -->
    </td>
</tr>
<tr><td class="oddrow" colspan='4'><img src='images/spacer.gif' border='0' width='1' height='3' alt=''><br></td></tr>


<tr><td class="evenrow" colspan='4'><img src='images/spacer.gif' border='0' width='1' height='3' alt=''><br></td></tr>
<tr>
	<td class="evenrow"><%=translate([==[Internal Port]==])%></td>
	<td class="evenrow" colspan="3"><div id="internalRange">&nbsp;</div><input type="hidden" id="internalRangePort" name="internalRangePort" value="" /></td>
</tr>
<tr><td class="evenrow" colspan='4'><img src='images/spacer.gif' border='0' width='1' height='3' alt=''><br></td></tr>

<tr><td class="oddrow" colspan='4'><img src='images/spacer.gif' border='0' width='1' height='3' alt=''><br></td></tr>
<tr>
	<td class="oddrow"><%=translate([==[External Port]==])%></td>
	<td class="oddrow" colspan="3"><div id="externalRange">&nbsp;</div><input type="hidden" id="externalRangePort" name="externalRangePort" value="" /></td>
</tr>
<tr><td class="oddrow" colspan='4'><img src='images/spacer.gif' border='0' width='1' height='3' alt=''><br></td></tr>

<%endBlock()%>
</form>

<!-- end of  port mapping info -->

	<tr>
		<td><hr style="color:#53669E" /></td>
</tr>
<tr><td class="padtop5">&nbsp;</td></tr>
<!-- start to config custom virtual info -->
<form id="customConfig" name="customConfig" action="" method="post">
<input type="hidden" id="customFlag" name="customFlag" value="0" />
<input type="hidden" id="customAddress" name="customAddress" value="" />
<%
writeTableRowTitle_port(translate([==[Create Virtual Server]==]))
writeTableBlockRowHeader(4,translate([==[Application]==]),translate([==[Destination IP]==]),translate([==[Protocol]==]),translate([==[Configure]==]))
%>
	

<tr><td class="oddrow" colspan='4'><img src='images/spacer.gif' border='0' width='1' height='3' alt=''><br></td></tr>

<tr>
	<td class="oddrow midvertical"><input type="text" name="customName" id="customName" size="24" class="inputClass" /></td>
	<td class="oddrow midvertical" style="white-space:nowrap;">
	     <div> <input type="text" id="customAddr1" name="customAddr1" size="3" maxlength="3"  class="inputClass" /><b>.</b><input type="text" id="customAddr2" name="customAddr2" size="3" maxlength="3"  class="inputClass" /><b>.</b><input type="text" id="customAddr3" name="customAddr3" size="3" maxlength="3"  class="inputClass" /><b>.</b>
		 <input type="text" id="customAddr4" name="customAddr4" size="3" maxlength="3" class="inputClass" /></div>
 <div class="padtop5">
<%
createSelect('<select name="deviceCustom" id="deviceCustom" class="inputClass" onchange="changeCustomDevice(this.value);"><option value="">&lt; ' .. translate([==[IP Available]==]) .. ' &gt;</option>', nil,deviceList, "IPAddress", "IPAddress")
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
		<!-- <input type="button" class="button" onclick='customSubmit()' value="<%=translate([==[Active]==])%>" name="thb14" />			 -->
	</td>
</tr>
<tr><td class="oddrow" colspan='4'><img src='images/spacer.gif' border='0' width='1' height='3' alt=''><br></td></tr>

			
<tr><td class="evenrow" colspan='4'><img src='images/spacer.gif' border='0' width='1' height='3' alt=''><br></td></tr>
<tr>
	<td class="evenrow"><%=translate([==[Internal Port]==])%> </td>
	<td class="evenrow" colspan="3">
		<input type="text" name="customInternalPort" id="customInternalPort" size="48" class="inputClass" onchange="portChange(this.value)" /></td>
</tr>
<tr><td class="evenrow" colspan='4'><img src='images/spacer.gif' border='0' width='1' height='3' alt=''><br></td></tr>

			
<tr><td class="oddrow" colspan='4'><img src='images/spacer.gif' border='0' width='1' height='3' alt=''><br></td></tr>
<tr>
	<td class="oddrow"><%=translate([==[External Port]==])%> </td>
	<td class="oddrow" colspan="3">
	    <input type="text" name="customExternalPort" id="customExternalPort" size="48"  class="inputClass" onchange="portChange(this.value)" />
    </td>
</tr>
<tr><td class="oddrow" colspan='4'><img src='images/spacer.gif' border='0' width='1' height='3' alt=''><br></td></tr>

<%endBlock()%>
</form>
<!-- end of config virtual info -->

<table cellspacing='0' cellpadding='0' width='100%' >
     <tr class='midarea6' align='center'>
		<td  class="midarea6-4" style="padding-left:300px">

		 <a href="statoPortMapping.lp">
		 <div class='midarea6-1 secondaryButton' name="thb12" style="vertical-align:middle"><%=translate([==[Back]==])%></div></a>
         <!-- <input type="button" class="button" onclick='javascript: document.location.href="statoPortMapping.lp";' value="<%=translate([==[Back <]==])%>" name="thb12" /> -->
         </td>
     </tr>
</table>

<%endPage()%>

<input type="hidden" id="portConflictFlag" name="portConflictFlag" value="<%=portConflict%>" />
<script src="js/antiCSRF.js" type="text/javascript"></script>
</div>
</div>
</div>
<div id="confirmConfig" style="display:none">
<%cgilua.lp.include("webparts/confirmBack.lp")%>
</div>
<div id="resultKoIp" style="display:none">
<%cgilua.lp.include("webparts/resultKO_IP.lp")%>
</div>
<div id="resultKoAll" style="display:none">
<%cgilua.lp.include("webparts/resultKO_noApp.lp")%>
</div>
<div id="resultKoNoName" style="display:none">
<%cgilua.lp.include("webparts/resultKO_noName.lp")%>
</div>
<div id="portConflict" style="display:none">
<%cgilua.lp.include("webparts/portmapping_conflictAlert.lp")%>
</div>
<script language="javascript" type="text/javascript">
var gameForm = document.getElementById("gameConfig");
var customForm = document.getElementById("customConfig");
</script>  
</body>
</html>
