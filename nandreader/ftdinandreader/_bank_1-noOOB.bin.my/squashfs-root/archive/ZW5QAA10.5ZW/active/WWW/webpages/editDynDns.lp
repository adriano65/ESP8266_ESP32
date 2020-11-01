<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
          "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head>

<meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>

<title>Modem Telecom Italia</title>
<link rel="stylesheet" href="css/master.css" type="text/css"/>
<!-- <link rel="stylesheet" href="css/style.css" type="text/css"/>
<link rel="stylesheet" href="css/menu.css" type="text/css" /> -->
</head>
<% cgilua.lp.include("lp/language.lp") %>
<% cgilua.lp.include("lp/util.lp")%>
<% cgilua.lp.include("lp/device.lp") %>
<% cgilua.lp.include("lp/mbus_util.lp")%>
<% cgilua.lp.include("lp/form.lp")%>
<% cgilua.lp.include("lp/dsl.lp")%>
<% cgilua.lp.include("lp/ppp.lp") %>
<%
local translate = translate
local POST=cgilua.POST

local pathId = cgilua.QUERY["pathId"]
local pathDetail = "DynDNS.Client." .. pathId 

local dynDnsClientInfo = getList(pathDetail,nil,"UserName", "Password", "Service", "Enable")
local dynDnsClientHostInfo = getList(pathDetail..".Host",nil,"Name")

local serviceProvide=string.sub(dynDnsClientInfo[1]["Service"], 16)
local username = dynDnsClientInfo[1]["UserName"]
local password = dynDnsClientInfo[1]["Password"]
local enable = dynDnsClientInfo[1]["Enable"]

local domainName = ""
if dynDnsClientHostInfo[1]~=nil then
	domainName = dynDnsClientHostInfo[1]["Name"]
end

if cgilua.servervariable"REQUEST_METHOD" == "POST" then
	local modify = {}	
function pcall_MainEditDNSMethod()	
	if POST["modConfigFlag"] == "1" then
		local pathId = POST["pathId"]
		local dynDnsClientPath = "DynDNS.Client." .. pathId	

		-- it can be changed only when client is disabled
		if enable == "true" then
			modify = {}
			table.insert(modify, {path=dynDnsClientPath, param= {Enable = "false"}})
			setMBUS(modify)
		end
		
		modify = {}
		if domainName~=POST["domainName"] then
			local dynDnsClientHostPath = dynDnsClientPath..".Host"

			local reply, error = mbus.modify(
			function()				
				local reply1, error1 = mbus.deleteObjects{ path = dynDnsClientHostPath }		

				local reply2, error2 = mbus.addObjects{ path = dynDnsClientHostPath, param = { Name = POST["domainName"]}}
				if error1~=nil or error2 ~= nil then
					cgilua.redirect("resultKO.lp")
					return
				end
			end)
		end

		if username~=POST["username"] then
			table.insert(modify, {path=dynDnsClientPath, param= {UserName=POST["username"]}})
		end
		if password~=POST["password"] then
			table.insert(modify, {path=dynDnsClientPath, param= {Password=POST["password"]}})
		end
		if serviceProvide~=POST["serviceProvide"] then
			table.insert(modify, {path=dynDnsClientPath, param= {Service="DynDNS.Service."..POST["serviceProvide"]}})
		end		

		local result = setMBUS(modify)

		-- Enabled again since it is disabled to allow modification
		if enable == "true" then
			modify = {}
			table.insert(modify, {path=dynDnsClientPath, param= {Enable = "true"}})
			setMBUS(modify)
			sleep(1)
		end
		
		if result==1	then
			cgilua.redirect("resultKO.lp")
			return
		end
	end
	if POST["listEditFlag"] == "1" then
		for i=1,tonumber(POST["rowNum"]) do
			local clientPath = "DynDNS.Client."..POST["clientPathId"..i]
			if (POST["clientDisChk"..i]=="ON" and POST["clientStatus"..i]=="false") or (POST["clientDisChk"..i]==nil and POST["clientStatus"..i]=="true") then
				local status
				if POST["clientDisChk"..i]=="ON" and POST["clientStatus"..i]=="false" then
					status = "true"
				else
					status = "false"
				end
				modify = {}
				table.insert(modify, {path=clientPath, param= {Enable=status}})
				local result = setMBUS(modify)

				if result==1	then
					cgilua.redirect("resultKO.lp")
					return
				end
			end
 
			if POST["clientDelChk"..i]=="ON" then
				local reply, error = mbus.modify(
				function()
					local reply1, error1 = mbus.deleteObjects{ path = clientPath }	
					if error1~=nil then
						cgilua.redirect("resultKO.lp")
						return
					end
				end)
			end
		end		
	end
	
	saveall(0, 1)	
	cgilua.redirect("save_alert.lp", { u="dynDns.lp" })
	return
end
	if pcall(pcall_MainEditDNSMethod) then
		saveall(0, 1)
		cgilua.redirect("save_alert.lp", { u = "dynDns.lp" })
		return
	else
		cgilua.redirect("save_alert.lp", { u = "dynDnsConf.lp" })
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

local dynClientList = getList("DynDNS.Client",nil,"Name","UserName", "Password", "Service", "Enable")

local dsl = getDSLInfoHome()
local datappp = getPPP("PPP.Intf.2")
local pppstatus = datappp.status
%>

<body>
<script type="text/javascript">
//<![CDATA[
function submitApply()
{
	var serviceProvide = document.getElementById("serviceProvide").value;
	var domainName = document.getElementById("domainName").value;
	var oldDomainName = document.getElementById("oldDomainName").value;
	var username = document.getElementById("username").value;	
	var rowNum = document.getElementById("rowNum").value;
	var domainNameConflict = false;	

	if(serviceProvide=="")
	{
		document.getElementById("DynDnsConfig").style.display="none";
		document.getElementById("resultKoProvider").style.display="block";
		return false;
	}

	for(var i=1;i<=parseInt(rowNum);i++)
	{
		var domainNameInList = document.getElementById("domainName"+i.toString()).value;		
		if(oldDomainName != domainName && domainNameInList == domainName)
		{
			domainNameConflict = true;	
		}
	}		
	if(domainName=="")
	{
		document.getElementById("DynDnsConfig").style.display="none";
		document.getElementById("resultKoDomain").style.display="block";
		return false;
	}
	else
	{
		var domainNameSplit = domainName.split(".");
		if( (domainNameSplit[0] == null) || (domainNameSplit[1] == null)||  (domainNameSplit[0] == "") || (domainNameSplit[1] == "") || (domainNameSplit == ",") )
		{
			 window.location = "dynDns.lp";
			return false;
		}
	}

    if(domainNameConflict)
	{
		document.getElementById("DynDnsConfig").style.display="none";
		document.getElementById("resultConflictDomain").style.display="block";
		return false;
	}

	if(username=="")
	{
		document.getElementById("DynDnsConfig").style.display="none";
		document.getElementById("resultKoNoUsername").style.display="block";
		return false;
	}
	document.getElementById("DynDnsConfig").style.display="none";
	document.getElementById("confirmConfig").style.display="block";	
}

function cancelConfirm()
{
	document.getElementById("DynDnsConfig").style.display="block";
	document.getElementById("confirmConfig").style.display="none";
	document.getElementById("resultKoDomain").style.display="none";
	document.getElementById("resultConflictDomain").style.display="none";
	document.getElementById("resultKoProvider").style.display="none";
	document.getElementById("resultKoNoUsername").style.display="none";
	document.getElementById("resultKoConnected").style.display="none";
}

function submitConfirm()
{
	setTimeout("alert('Please Wait!');", 1);
	document.getElementById("modConfigFlag").value="1";	
	document.dysDnsConfig.submit();	
}

function submitSave()
{
	setTimeout("alert('Please Wait!');", 1);
	var isActive = false;
	var num = document.getElementById("rowNum").value;
	for(var i=1; i<=num; i++)
	{
		var isChecked = document.getElementById("clientDisChk"+i).checked;
		var oldState = document.getElementById("clientStatus"+i).value;
		if(isChecked && oldState!="true")
		{
			isActive = true;
			break;
		}
	}
	if(("<%=pppstatus%>"!="Connected") && isActive)
	{
		document.getElementById("DynDnsConfig").style.display="none";
		document.getElementById("resultKoConnected").style.display="block";
		return false;
	}
	document.getElementById("listEditFlag").value="1";
	document.dynDnsListEdit.submit();
}

//]]>
</script>

<div class="contentContainer">
			<div class="breadCrumbContainer">
			<ul class="brdCrumb">
				<li><a href="advance.lp"><%=translate([==[Advanced Settings]==])%></a></li><li>|</li> <li><a href="editDynDns.lp?pathId=<%=pathId%>"><%=translate([==[Edit Dynamic DNS]==])%></a></li> 
				</ul>
		</div>	

<!-- <table cellspacing='0' cellpadding='0' width="100%" class="NavBar">
<tr><td align="left"><a href="advance.lp">Avanzate</a>&nbsp;&nbsp;>&nbsp;&nbsp;<a href="editDynDns.lp?pathId=<%=pathId%>"><%=translate([==[Edit Dynamic DNS]==])%></a></td><td align="right"><a href="dynDns.lp">Stato</a>&nbsp;&nbsp;|&nbsp;&nbsp;<em>Configura</em></td></tr>
</table> -->

<div class="contentTab" id="content">
	<ol id="tocTab" style="width:780px">
		<li><a href="dynDns.lp" >
			<div class="tab">
			<span class="tabIcon_stdns"></span>  
			<span class="contTabTxt transform"><%=translate([==[Dynamic DNS]==])%></span>
		</div><div class="clrBth"></div></a></li>
		<li><a href="dynDnsConf.lp" class="current margin15">
			<div class="tab" style="padding:0 31px;">
				<span class="contTabTxt transform"><%=translate([==[Configure Dynamic DNS]==])%></span></div></a></li>			
	</ol>
</div>
<div id="DynDnsConfig">
<div class='contentcontainer'>
<hr>
<div class='contentitem'>
<table border="0" width="100%">
<tr>
   <!--  <td class='icon' style='vertical-align:top' width='100px'><img src='images/dns___xl.gif' alt='Technicolor Gateway'></td> -->
    <td class='data' style='vertical-align:top'>
        <table cellspacing='0' cellpadding='0' width="100%">
        <tr>
            <td align='left' class='midarea2 tableTitle'><%=translate([==[Edit Dynamic DNS]==])%></td>
        </tr>
        <tr><td>
            <!-- Begin of Configuring Dynamic DNS-->
            <form id="dysDnsConfig" name="dysDnsConfig" action="" method="post">
            <input type="hidden" id="modConfigFlag" name="modConfigFlag" value="0"/>
            <input type="hidden" id="pathId" name="pathId" value="<%=pathId%>"/>
            <table cellspacing='0' cellpadding='0' width='100%' class="fontSize"><tr>
			<td class='midarea2 tableTitle'><%=translate([==[Configuring Dynamic DNS]==])%></td><tr><td>
			<table class='edittable width750 paddtop10 marleft40' width='100%' cellspacing='0' cellpadding='0' border='0'>
                <tr><td colspan='5'><img src='images/spacer.gif' border='0' width='1' height='1' alt=''><br></td></tr>
                <tr>
				<th class="tableHd"><%=translate([==[Service Provider]==])%></th>
				<th class="tableHd"><%=translate([==[Domain Names]==])%></th>
				<th class="tableHd"><%=translate([==[Username]==])%></th>
				<th class="tableHd"><%=translate([==[Password]==])%></th>
				<th class="tableHd"><%=translate([==[Configure]==])%></th>
				</tr>
                <%
                local rowStyle = "oddrow"
                %>
                                <tr>
                <td class="<%=rowStyle%> alignMid padcell">
<%
createSelect('<select  id="serviceProvide" name="serviceProvide" class="inputClass"><option value="">&lt;' .. translate([==[Choose]==]) .. ' ... &gt;</option>',nil,dynServiceList,"Server","path")
%>
                </td>
                <td  class="<%=rowStyle%> alignMid padcell"><input type="text" id="domainName" name="domainName" size="20" class="inputClass" value="<%=domainName%>" /><input type="hidden" id="oldDomainName" name="oldDomainName" size="20" class="inputClass" value="<%=domainName%>" /></td>
                <td class="<%=rowStyle%> alignMid padcell"><input type="text" id="username" name="username" size="15" class="inputClass" value="<%=username%>" /></td>
                <td class="<%=rowStyle%> alignMid padcell"><input id="password" type="password" name="password" size="8" class="inputClass" value="<%=password%>" /></td>
                <td class="<%=rowStyle%> alignMid padcell">
				<a onclick='submitApply()' href="#"><div class='midarea6-1 mainButton' style="margin-bottom:0px;"  name="thb8"><%=translate([==[Apply]==])%></div></a></td>
				<!-- <input type="button" class="button" onclick='submitApply()' value="<%=translate([==[Apply]==])%>" name="thb8" /></td> -->
                </tr></table>
            </td></tr></table> 
            </form> <!-- End of Configuring Dynamic DNS-->

            <!-- Begin of Accounts Dynamic DNS-->
            <form name="dynDnsListEdit" action="" method="post">
            <input type="hidden" id="listEditFlag" name="listEditFlag" value="0"/>

            <table cellspacing='0' cellpadding='0' width='100%' class="fontSize padtop10">
			<tr><td class='midarea2 tableTitle'><%=translate([==[Accounts Dynamic DNS]==])%></td><tr><td>
                <table class='edittable width750 marleft40 fontSize' width='100%' cellspacing='0' cellpadding='0' border='0'>
                   <tr>
				<th class="tableHd"><%=translate([==[Service Provider]==])%></th>
				<th class="tableHd"><%=translate([==[Domain Names]==])%></th>
				<th class="tableHd"><%=translate([==[Username]==])%></th>
				<th class="tableHd"><%=translate([==[Active]==])%></th>
				<th class="tableHd"><%=translate([==[Delete]==])%></th>
				</tr>
                
                <tr><td colspan='5' class='black'><img src='images/spacer.gif' border='0' width='1' height='1' alt=''><br></td></tr>
                <%
                local rowStyle = "oddrow"
                local rowNum = 0
                for i,v in pairs(dynClientList) do
                    rowNum = rowNum + 1
                    if rowNum%2==1 then
                        rowStyle = "oddrow"
                    else
                        rowStyle = "evenrow"
                    end
                    local clientPathId=string.sub(v.path, 15)
                    local serviceName=""
                    for j,w in pairs(dynServiceList) do
                        if v["Service"] == "DynDNS.Service."..w.path then
                            serviceName=w["Server"]
                        end
                    end

			local domainName=""
			if v["nbOfdyndns_hosts"]~="0" then
				local hostList = getList(v.path..".Host",nil,"Name","Status")
				if hostList[1]~=nil then
					domainName = hostList[1]["Name"]
				end
			end

			local isChecked = 'checked="checked"'
			if v["Enable"]~="true" then
				isChecked = ""
			end
                %>
                <tr><td width='33%' class='<%=rowStyle%>' colspan='5'><img src='images/spacer.gif' border='0' width='1' height='3' alt=''><br></td></tr>
                <tr>
                <td class="<%=rowStyle%>"><%=serviceName%><input type="hidden" name="clientPathId<%=rowNum%>" value="<%=clientPathId%>"/><input type="hidden" id="clientStatus<%=rowNum%>" name="clientStatus<%=rowNum%>" value="<%=v["Enable"]%>"/></td>
                <td class="<%=rowStyle%>"><%=domainName%><input type="hidden" id="domainName<%=rowNum%>" name="domainName<%=rowNum%>" value="<%=domainName%>" /></td>
                <td class="<%=rowStyle%>"><%=v["UserName"]%></td>
                <td class="<%=rowStyle%>"><input type="checkbox" <%=isChecked%> id="clientDisChk<%=rowNum%>" name="clientDisChk<%=rowNum%>" value="ON" /></td>
                <td class="<%=rowStyle%>"><input type="checkbox" name="clientDelChk<%=rowNum%>" value="ON"/></td>
                </tr>
                <tr><td class="<%=rowStyle%>" colspan='5'><img src='images/spacer.gif' border='0' width='1' height='3' alt=''><br></td></tr>
                <% end %>
     <tr><td colspan='5'>
	 					<table cellspacing='0' cellpadding='0' width='100%' class="padtop10 txtAlignCenter">
				<tr><td style="text-align:left;">
				<table cellspacing='0' cellpadding='0'><tr>
				<td style='padding-left:250px'>
			<a onclick='javascript: submitSave();' href="#"><div class='midarea6-1 mainButton' name="thb10"><%=translate([==[Save]==])%></div></a>
					</td>
<td>
												<input type="hidden" id="rowNum" name="rowNum" value="<%=rowNum%>" /></td>
					<td style='padding-left:50px'>
										
											<a onclick='javascript:document.location.href="dynDns.lp";' style="color:black;"><div class='midarea6-1 mainButton' name="thb7"><%=translate([==[Cancel]==])%></div></a>
					</td>
				</tr>	
	</table>
	</td></tr></table>
</td></tr>
</td></tr>
                </table>
            </td></tr></table>
            </form>
            <!-- End of Accounts Dynamic DNS-->
        </td></tr></table>
    </td>
</tr>
</table>
</div>
</div>
</div>
</div>
<script src="js/antiCSRF.js" type="text/javascript"></script>

<script type="text/javascript">
	document.getElementById("serviceProvide").value = "<%=serviceProvide%>";
</script>
<div id="confirmConfig" style="display:none">
<%cgilua.lp.include("webparts/confirmBack.lp")%>
</div>
<div id="resultKoDomain" style="display:none">
<%cgilua.lp.include("webparts/resultKO_nodominio.lp")%>
</div>
<div id="resultConflictDomain" style="display:none">
<%cgilua.lp.include("webparts/resultKO_Conflictdominio.lp")%>
</div>
<div id="resultKoProvider" style="display:none">
<%cgilua.lp.include("webparts/resultKO_noprovider.lp")%>
</div>
<div id="resultKoNoUsername" style="display:none">
<%cgilua.lp.include("webparts/resultKO_nousername.lp")%>
</div>
<div id="resultKoConnected" style="display:none">
<%cgilua.lp.include("webparts/resultKO_connected.lp")%>
</div>
</body>
</html>
