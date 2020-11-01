<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
          "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head>

<title>Modem Telecom Italia</title>

<meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
<!-- <link rel="stylesheet" href="css/style.css" type="text/css"/> -->
<link rel="stylesheet" href="css/master.css" type="text/css" />
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
		window.parent.menu.document.getElementById("port").className="";
	}

	if(window.parent.menu.document.getElementById("dns")!=null && 
		window.parent.menu.document.getElementById("dns") != "undefinded") {
		window.parent.menu.document.getElementById("dns").className="submenuselect1";
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

<% cgilua.lp.include("lp/language.lp") %>
<% cgilua.lp.include("lp/util.lp")%>
<% cgilua.lp.include("lp/device.lp") %>
<% cgilua.lp.include("lp/mbus_util.lp")%>
<% cgilua.lp.include("lp/form.lp")%>
<% cgilua.lp.include("lp/ppp.lp") %>
<% cgilua.lp.include("lp/dsl.lp") %>
<% cgilua.lp.include("lp/common.lp") %>
<%
local translate = translate
local POST=cgilua.POST
local TI_Device = getTIInfo_Device()

local TI_info = getTIInfo()
if TI_Device.lanOption ~= "res-rt-napt" and TI_Device.lanOption ~= "biz-rt-napt-ena" and TI_Device.lanOption ~= "res-rt-napt-ipv6"
and TI_Device.lanOption ~= "biz-rt-napt-ipv6" then
        cgilua.redirect("index.lp")
        return
end

local dsl = getDSLInfoHome()
local datappp = getPPP("PPP.Intf.2")
local pppstatus = datappp.status

local dynDnsPath = "DynDNS.Client"
local dynDns_slen = string.len(dynDnsPath) + 1
if cgilua.servervariable"REQUEST_METHOD" == "POST" then
function pcall_MainDNSStatusMethod()	
	for i=1, tonumber(POST["rowNum"]) do
		local modify = {}
		local status = "false"
		if POST["dnsChk"..tostring(i)] ~= nil then
			status = "true"
		end
		
		table.insert(modify, { path = dynDnsPath.."."..POST["pathId"..tostring(i)], param = {Enable = status} })		
		setMBUS(modify)
	end

	saveall(0, 1)
	cgilua.redirect("save_alert.lp", { u = "dynDns.lp" })
	return
end
	if pcall(pcall_MainDNSStatusMethod) then
		saveall(0, 1)
		cgilua.redirect("save_alert.lp", { u = "dynDns.lp" })
		return
	else
		cgilua.redirect("save_alert.lp", { u = "dynDns.lp" })
		return
	end	
end

local dynServiceList = getList("DynDNS.Service","(!= Server '')","Server")
for i,v in pairs(dynServiceList) do	
	v.path = string.sub(v.path, 16)
	local server = v["Server"]
	local pointFirst = string.find(server, "%.")
	local pointSecond = string.find(server, "%.", pointFirst+1)
	if pointSecond ~= nil then
		v["Server"] = string.sub(server, pointFirst+1)
	end
end

local dynClientList = getList("DynDNS.Client",nil,"Name","UserName", "Password", "Service", "nbOfdyndns_hosts", "Enable")

local isRemote = isRemoteAccess()

%>
<body>
<script type="text/javascript">
//<![CDATA[
function cancelConfirm()
{
	document.getElementById("DynDnsConfig").style.display="block";
	document.getElementById("confirmConfig").style.display = "none";
	document.getElementById("resultKoConnected").style.display = "none";
}

function submitConfirm()
{
  setTimeout("alert('Please Wait!');", 1);
  document.getElementById("change_status_form").submit();
}

function change_status()
{	
	var isActive = false;
	var num = document.getElementById("rowNum").value;
	for(var i=1; i<=num; i++)
	{
		var isChecked = document.getElementById("dnsChk"+i).checked;
		var oldState = document.getElementById("clientStatus"+i).value;
		if(isChecked && oldState!="true")
		{
			isActive = true;
			break;
		}
	}
	if(("<%=pppstatus%>"!="Connected" ) && isActive)
	{
		document.getElementById("DynDnsConfig").style.display="none";
		document.getElementById("resultKoConnected").style.display="block";
		return false;
	}

	document.getElementById("DynDnsConfig").style.display = "none";
	document.getElementById("confirmConfig").style.display = "block";
}

//]]>
</script>

<div class="contentContainer">
	 
		<div class="breadCrumbContainer">
			<ul class="brdCrumb">
				<li><a href="advance.lp"><%=translate([==[Advanced Settings]==])%></a></li><li>|</li><li><a href="dynDns.lp"><%=translate([==[Dynamic DNS]==])%></a></li>
			</ul>
		</div>	
			
		<div class="contentTab" id="content">
			<ol id="tocTab">
				<li><a class="current"><div class="tab"><span class="tabIcon_stdns"></span><span class="contTabTxt transform"><%=translate([==[Dynamic DNS]==])%></span></div><div class="clrBth"></div></a></li>
				<% if isRemoteAccess() == false then %>
				<li><a class="margin15" href="dynDnsConf.lp"><div class="tab" style="padding:0 31px;"><span class="contTabTxt transform"><%=translate([==[Configure Dynamic DNS]==])%></span></div></a></li>
				<%end%>
			</ol>
		</div>

<!-- <table cellspacing='0' cellpadding='0' width="100%" class="NavBar">
<tr><td align="left"><a href="advance.lp">Avanzate</a>&nbsp;&nbsp;>&nbsp;&nbsp;<a href="dynDns.lp"><%=translate([==[Dynamic DNS]==])%></a></td><td align="right"><%=showConfigMenu("dynDnsConf.lp")%></td></tr> 
</table>  -->

<div id="DynDnsConfig">
<div class='contentcontainer'>
<hr>
<div class='contentitem'>

<form method="POST" id="change_status_form" action="">
<table border="0" width="100%">
<tr>
    
    <td>
        <table cellspacing='0' cellpadding='0' width="100%" class="fontSize">
        <tr>
            <td class="midarea2" style='font-weight:bold;vertical-align:left'><%=translate([==[Configure Dynamic DNS]==])%></td>
        </tr>
<%if pppstatus~="Connected" then%>
        <tr><td class="midarea2"><p><%=translate([==[Warning: the automatic connection modem is disconnected. The Dynamic DNS service is not active]==])%>.</p></td></tr>
<%else%>
<%
    local rowNum = 0
    if dynClientList[1] == nil then
%>
        <tr><td class="midarea2"> <p><%=translate([==[No Dynamic DNS server configured.]==])%></p></td></tr>
<% 
    else
%>
        <tr><td>
             <table cellspacing='0' cellpadding='0' width='100%'><tr><td width='40' style='vertical-align:top'></td><td style='vertical-align:top'>
                <table class="edittable" width='100%' cellspacing='0' cellpadding='0' border='0'>
                <tr><td colspan='6' ></td></tr>
            
                <tr>
				<th class="tableHd"><%=translate([==[Active]==])%></th>
				<th class="tableHd"><%=translate([==[Service Provider]==])%></th>
				<th class="tableHd"><%=translate([==[Domain Names]==])%></th>
				<th class="tableHd"><%=translate([==[Username]==])%></th>
				<th class="tableHd"><%=translate([==[Status]==])%></th>
				<th class="tableHd"><%=translate([==[Edit]==])%></th></tr>
                <tr><td colspan='6'>&nbsp;</td></tr>
               <%
                local rowStyle = "oddrow"
                local rowNum = 0
                for i,v in pairs(dynClientList) do
                    local path_id = string.sub(v.path, dynDns_slen + 1)
                    rowNum = rowNum + 1
                    if rowNum%2==1 then
                        rowStyle = "oddrow"
                    else
                        rowStyle = "evenrow"
                    end
                	
                	local serviceName=""                	
                    for j,w in pairs(dynServiceList) do
                        if v["Service"] == "DynDNS.Service."..w.path then
                            serviceName=w["Server"]
                        end
                    end
                	local domainName=""
                	local isActive = translate([==[Inactived]==])
                	local statusColor = "tdRed"
                	if v["nbOfdyndns_hosts"]~="0" then
                   		local hostList = getList(v.path..".Host",nil,"Name","Status")
                    	domainName = hostList[1]["Name"]
                        if pppstatus =="Connected" and  hostList[1]["Status"]=="Success" and v["Enable"]~="false"  then
                            isActive = translate([==[Actived]==])
                            statusColor = "tdGreen"
                        end
                    end
                    local isChecked = 'checked="checked"'
                    if v["Enable"]~="true" then
                        isChecked = ""
                    end
                %>
                               <tr>
                <td style='vertical-align:middle' class="<%=rowStyle%> padleft15"><input type="checkbox" <%=isChecked%> id="dnsChk<%=rowNum%>" name="dnsChk<%=rowNum%>" value="ON" /><input type="hidden" id="clientStatus<%=rowNum%>" name="clientStatus<%=rowNum%>" value="<%=v["Enable"]%>"/><input type="hidden" id="pathId<%=rowNum%>" name="pathId<%=rowNum%>" value="<%=path_id%>"/></td>
                <td class="<%=rowStyle%> padcell alignMid"><%=serviceName%></td>
                <td class="<%=rowStyle%> padcell alignMid"><%=domainName%><input type="hidden" id="domainName<%=rowNum%>" name="domainName<%=rowNum%>" value="<%=domainName%>" /></td>
                <td  class="<%=rowStyle%> padcell alignMid"><%=v["UserName"]%></td>
                <td style='font-size:11px;' class="<%=statusColor%> <%=rowStyle%> alignMid"><%=isActive%></td>
                <td class="<%=rowStyle%> padcell alignMid">
<%if isRemote==false then%>
				<a onclick='javascript: document.location.href="editDynDns.lp?pathId=<%=string.sub(v.path, 15)%>";'><div class='midarea6-1 mainButton' style="margin-bottom:0px;" name="thb2"><%=translate([==[Edit]==])%></div></a>
		        <!-- <input type="button" class="midarea6-3" onclick='javascript: document.location.href="editDynDns.lp?pathId=<%=string.sub(v.path, 15)%>";' value="<%=translate([==[Edit]==])%>" name="thb2" /> -->
<%end%>
        		</td></tr>
                <% end %>
				
					<table cellspacing='0' cellpadding='0' width='100%' class="paddtop10 txtAlignCenter">
				<tr><td style="text-align:left;">
				<table cellspacing='0' cellpadding='0'><tr>
				<td style='padding-left:250px'>
				<% if isRemote==false then%>
												<a onclick="change_status()" href="#">
												<div class="midarea6-1 mainButton" name="thb10"><%=translate([==[Save]==])%></div></a>
												<%end%>
					</td>
<td>
												<input type="hidden" id="rowNum" name="rowNum" value="<%=rowNum%>" /></td>
					<td style='padding-left:50px'>
										
												<a href ="advance.lp">
												<div class="midarea6-1 secondaryButton" name="thb7"> <%=translate([==[Back]==])%> </div > </a>
					</td>
				</tr>	
	</table>
	</td></tr></table>
				

            </table>    
		</td>		
        </tr>
    <%end%>
<%end%>
        </table>
    </td>
</tr>
</table>
</form>
</div>
</div>
</div>
</div>
<script src="js/antiCSRF.js" type="text/javascript"></script>

<div id="confirmConfig" style="display:none">
<%cgilua.lp.include("webparts/confirmBack.lp")%>
</div>
<div id="resultKoConnected" style="display:none">
<%cgilua.lp.include("webparts/resultKO_connected.lp")%>
</div>
</html>
