<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
<title>Modem Telecom Italia</title>
<!-- <link rel="stylesheet" href="css/style.css" type="text/css" /> -->
<link rel="stylesheet" href="css/master.css" type="text/css" />

<script language="javascript" type="text/javascript" src="js/portmap.js"></script>
<%
cgilua.lp.include("lp/mbus_util.lp")
cgilua.lp.include("lp/common.lp")
cgilua.lp.include("lp/portmap.lp")
cgilua.lp.include("lp/style.lp")
cgilua.lp.include("lp/util.lp")
cgilua.lp.include("lp/device.lp")
local tprint = require("tableprint")
local translate = translate
local POST = cgilua.POST
local portMappingPath = "Device.NAT.PortMapping"
local IGD_PortMapping_slen = string.len(portMappingPath) + 1
--flags to make a distinction whether other port mapping is existing
local portConflict = ""

local lanOption = getLANOption()
local TI_Device = getTIInfo_Device()
if TI_Device.lanOption ~= "res-rt-napt" and TI_Device.lanOption ~= "biz-rt-napt-ena" and 
TI_Device.lanOption ~= "res-rt-napt-ipv6" and TI_Device.lanOption ~= "biz-rt-napt-ipv6" then
  cgilua.redirect("index.lp")
  return
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

if cgilua.servervariable"REQUEST_METHOD" == "POST" then

  if NATStatus=="" then
    -- the NAT status has problem, so do nothing, just go back.
    cgilua.redirect("statoPortMapping.lp")
    return
  end

  local modify = {}
  local reply, error = mbus.getParameters{ path = portMappingPath, param = {"Enable", "InternalClient", "X_000E50_GUIDisabled", "X_000E50_InterfaceDisabled"}, datamodel = "second" }
  
  local manualDisabled = {}
  --Fistly deal with the rules to be set disabled by GUI
  for i, v in pairs(reply[portMappingPath]) do
    local path_id = string.sub(v.path, IGD_PortMapping_slen + 1)

    if (POST[path_id] == nil) then
	  
	  if (v["param"]["Enable"] == "false" and v["param"]["X_000E50_GUIDisabled"] == "false" and v["param"]["X_000E50_InterfaceDisabled"] == "false") then
		
	  elseif  (v["param"]["Enable"] == "false" and v["param"]["X_000E50_GUIDisabled"] == "false" and v["param"]["X_000E50_InterfaceDisabled"] == "true") then
		
      else
	    manualDisabled = "false" 
        
        table.insert(modify, { path = v.path, param = { Enable = manualDisabled}, datamodel = "second" })
	  end
    end
  end 
  setMBUS_IGD(modify)
  --Secondly deal with the rules to be set enabled by GUI one by one
  for i, v in pairs(reply[portMappingPath]) do
    modify = {}
    local path_id = string.sub(v.path, IGD_PortMapping_slen + 1)
    if (POST[path_id] ~= nil) then
      manualDisabled = "true"
  
      table.insert(modify, { path = v.path, param = { Enable = manualDisabled}, datamodel = "second" })
	
	  local result = setMBUS_IGD(modify)
  
	  if result == 1 then
	    saveall(0, 1)
	
	    cgilua.redirect("portmapping_conflictAlert.lp",{ flag="stateEnable"})
		local modify2 = {}
		table.insert(modify2, { path = v.path, param = {Enable="false"}, datamodel = "second" })
		
		result2 = setMBUS_IGD(modify2)
    
	    return
	  end 
    end
  end
 -- if #modify>0 then
--	local result = setMBUS_IGD(modify)
--	if result==1 then
--		saveall(0, 1)
--		cgilua.redirect("portmapping_conflictAlert.lp",{ flag="stateEnable"})
--		return
--	end
--  end

  saveall(0, 1)
  cgilua.redirect("save_alert.lp", { u="statoPortMapping.lp" })
  return
end

local portMappingList, error = getList_IGD(portMappingPath, nil, "Description", "InternalClient", "InternalPort", "ExternalPort", "Protocol", "Enable", "X_000E50_GUIDisabled", "X_000E50_InterfaceDisabled")
local isRemote = isRemoteAccess()
%>

<script type="text/javascript">
//<![CDATA[
function cancelConfirm()
{
  document.getElementById("statoPortMappingTable").style.display = "block";
  document.getElementById("confirmConfig").style.display = "none";
  document.getElementById("resultKoAll").style.display = "none";
}

function submitConfirm()
{
	document.getElementById("wifi_submit").removeAttribute("href");
    document.getElementById("wifi_submit").onclick = null;
    document.getElementById("wifi_submit_con").className = "next_wifidisable";
    document.getElementById("change_status_form").submit();
}

function linkToEdit(pathId)
{
  window.location.href="editPortMapping.lp?pathId="+pathId;
}

function change_status()
{
<%
  for i,v in pairs(portMappingList) do
    if NATStatus=="false" or (v["InternalClient"]~="" and inRange(tostring(v["InternalClient"]), NATStart, NATEnd)==false) then
      local pathId = string.sub(v.path, IGD_PortMapping_slen + 1)
%>
      if (document.getElementById("<%=pathId%>").checked == true) {
        document.getElementById("PMWarningMsg").innerHTML = "<%=errMsgNAT%>";
        document.getElementById("statoPortMappingTable").style.display = "none";
        document.getElementById("resultKoAll").style.display = "block";
        return false;
      }
<%
    end
	local enable = v["Enable"]
	local pathId = string.sub(v.path, IGD_PortMapping_slen + 1)
%>
	var path_checked = "false";
	if(document.getElementById("<%=pathId%>").checked == true){
		path_checked = "true";
	}
	var get_Path_checked = "<%=enable%>";
	if(path_checked != get_Path_checked){
		document.getElementById("statoPortMappingTable").style.display = "none";
		document.getElementById("confirmConfig").style.display = "block";
	}
<%
  end
%>
}

function changeCheck(n)
{
  if(document.getElementById(n).checked == true)
    document.getElementById("span"+n).innerHTML = "<%=translate([==[Active]==])%>";
  else
    document.getElementById("span"+n).innerHTML = "<%=translate([==[Disable]==])%>";
}
//]]>
</script>
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
			window.parent.menu.document.getElementById("ipv6firewall").className="";
			window.parent.menu.document.getElementById("ipv6list").style.display="none";
		}
	}

	if(window.parent.menu.document.getElementById("port")!=null && 
		window.parent.menu.document.getElementById("port") != "undefinded") {
		window.parent.menu.document.getElementById("port").className="submenuselect1";
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

<div class="contentContainer">
	 
		<div class="breadCrumbContainer">
			<ul class="brdCrumb">
				<li><a href="advance.lp"><%=translate([==[Advanced Settings]==])%></a></li><li>|</li><li><a href="statoPortMapping.lp"><%=translate([==[Port Mapping]==])%></a></li>
			</ul>
		</div>	
			
		<div class="contentTab" id="content">
			<ol id="tocTab">
				<li><a class="current"><div class="tab"><span class="tabIcon_stport"></span>
				<span class="contTabTxt transform"><%=translate([==[Port Mapping]==])%></span>
				</div>
				<div class="clrBth"></div></a></li>
				<% if isRemoteAccess() == false then %>
				<li><a class="margin15" href="configurePortMapping.lp"><div class="tab">
				<span class="contTabTxt transform"><%=translate([==[Configure]==])%> Port Mapping</span></div></a>
				</li>
				<% end %>
			</ol>
		</div>

<!-- <table cellspacing='0' cellpadding='0' width="100%" class="NavBar">
<tr><td align="left"><a href="advance.lp">Avanzate</a>&nbsp;&nbsp;>&nbsp;&nbsp;<a href="statoPortMapping.lp">Port Mapping</a></td><td align="right"><%=showConfigMenu("configurePortMapping.lp")%></td></tr>
</table> -->

<div class='contentcontainer'>
<div class='contentitem' id="statoPortMappingTable">
<form method="POST" id="change_status_form" action="">
<%
writeBlockPageHeader(translate([==[Port Mapping Status]==]))
-- start to list virtual info
if portMappingList[1] == nil then	
%>
  <tr>
    <td class="midarea4">
      <p><%=translate([==[No rule of port configured mapping]==])%>.</p>
    </td>
  </tr>

<% else 
%>

  <table cellspacing='0' cellpadding='0' width='100%'><tr><td width='40' valign='top'></td><td valign='top'>
  <br>
  <table class='edittable_port valuespace' width='100%' cellspacing='0' cellpadding='0' border='0'>
  <tr><td colspan='8'><img src='images/spacer.gif' border='0' width='1' height='1' alt=''><br></td></tr> 
  <tr>
  <th class="tableHd"><%=translate([==[Active]==])%></th>
  <th class="tableHd"><%=translate([==[Application]==])%></th>
  <th class="tableHd" style="white-space: nowrap;"><%=translate([==[Destination IP]==])%></th>
  <th class="tableHd"><%=translate([==[Protocol]==])%></th>
  <th class="tableHd"><%=translate([==[Internal Port]==])%></th>
  <th class="tableHd"><%=translate([==[External Port]==])%></th>
  <th class="tableHd"><%=translate([==[Status]==])%></th>
  <th class="tableHd"><%=translate([==[Edit]==])%></th>
   </tr> 
   <tr><td colspan="8">&nbsp;</td></tr>
<%
--writeTableBlockHeader(8,translate([==[Active]==]),translate([==[Application]==]),translate([==[Destination IP]==]),translate([==[Protocol]==]),translate([==[Internal Port]==]),translate([==[External Port]==]),translate([==[Status]==]),translate([==[Edit]==]))

local rowStyle="oddrow_firewall"

local conIntPort = ""
local conExtPort = ""
local conProtocol = ""
for i,v in pairs(portMappingList) do
  local pathId = string.sub(v.path, IGD_PortMapping_slen + 1)
  local customStatus = "false"
  --if v["Enable"] == "true" and v["X_000E50_GUIDisabled"] == "false" and v["X_000E50_InterfaceDisabled"] == "false" then
	--customStatus = "true"
  --end 
  customStatus = v["Enable"]
  
  local isActive = "checked='checked'"
  local statusShow = translate([==[Active]==])
  if customStatus=="false" then
    isActive = ""
    statusShow = translate([==[Disable]==])
  end

  if i%2==1 then
      rowStyle = "oddrow_firewall"
    else
      rowStyle = "evenrow_firewall"
    end

  local internalPort = v["InternalPort"]
  local externalPort = v["ExternalPort"]
  if internalPort == "0" then 
    internalPort = "*"
  end

  if externalPort == "0" then 
    externalPort = "*"
  end
	
  local starExist = string.find(internalPort, "*")
  if starExist ~= nil and v["Protocol"]=="TCP" and string.match(portConflict,"tcp")==nil then
    portConflict = portConflict.."tcp"
  elseif starExist ~= nil and v["Protocol"]=="UDP" and string.match(portConflict,"udp")==nil then
    portConflict = portConflict.."udp"
  elseif starExist ~= nil and v["Protocol"]=="ALL" and string.match(portConflict,"all")==nil then
    portConflict = portConflict.."all"
  end

-- in case external Port is too long to display in GUI urgly, add some whitespace
externalPort=string.gsub(externalPort,",",", ")
externalPort=string.gsub(externalPort,";","; ")
internalPort=string.gsub(internalPort,",",", ")
internalPort=string.gsub(internalPort,";","; ")

if isRemote then
	writePortTableRow(8,rowStyle,[[<input type="checkbox" value="true" id="]]..pathId..[[" name="]]..pathId..[[" ]]..isActive..[[/>]],v["Description"],v["InternalClient"],v["Protocol"],internalPort,externalPort,statusShow,[[&nbsp;]])
else
	writePortTableRow(8,rowStyle,[[<input type="checkbox" value="true" id="]]..pathId..[[" name="]]..pathId..[[" ]]..isActive..[[/>]],v["Description"],v["InternalClient"],v["Protocol"],internalPort,externalPort,[[<div id="span]]..pathId..[[">]]..statusShow..[[</div>]],[[ <a style="color:black" onclick="linkToEdit(']]..pathId..[[')"><div class="midarea6-1 mainButton" style="margin-bottom:0px;" name="thb37">]]..translate([==[Edit]==])..[[</div></a>]])
end
local getProtocol = v["Protocol"]
conIntPort = conIntPort.."^"..internalPort	
conExtPort = conExtPort.."%"..externalPort
conProtocol = conProtocol.."@"..getProtocol
end

cgilua.set_session_var("Key1",conIntPort)
cgilua.set_session_var("Key2",conExtPort)
cgilua.set_session_var("KeyProtocol",conProtocol)
endBlock()
%>


	<table cellspacing='0' cellpadding='0' width='100%' class="paddtop10 txtAlignCenter">
				<tr><td style="text-align:left;">
				<table cellspacing='0' cellpadding='0'><tr>
				<td style='padding-left:250px'>
			<% if isRemote==false then%>
			<a onclick="change_status()" href="#">
			<div class="midarea6-1 mainButton" name="thb10" style="vertical-align:middle"><%=translate([==[Save]==])%></div></a>
			<%end%>
				</td>
			
					<td style='padding-left:50px'>
				<a href ="advance.lp">
		<div class="midarea6-1 mainButton" name="thb12" style="vertical-align:middle"><%=translate([==[Cancel]==])%></div> </a>
					</td>
				</tr>	
	</table>
	</td></tr></table>



<%
end
endPage()
%>

<input type="hidden" id="portConflictFlag" name="portConflictFlag" value="<%=portConflict%>" />
</form>
</div>
</div>
<script src="js/antiCSRF.js" type="text/javascript"></script>

<div id="confirmConfig" style="display:none">
<%cgilua.lp.include("webparts/confirmBack.lp")%>
</div>
<div id="portConflict" style="display:none">
<%cgilua.lp.include("webparts/portmapping_conflictAlert.lp")%>
</div> 
<div id="resultKoAll" style="display:none">
<%cgilua.lp.include("webparts/resultKO_noApp_reload.lp")%>
</div>
</body>
</html>
