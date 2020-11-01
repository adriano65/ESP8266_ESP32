<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
          "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head>

<title>Modem Telecom Italia</title>

<meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
<link rel="stylesheet" href="css/master.css" type="text/css" />
</head>

<% cgilua.lp.include("lp/language.lp") %>
<% cgilua.lp.include("lp/util.lp")%>
<% cgilua.lp.include("lp/device.lp")%>
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

local function get_domain_name_from_url(url)
  local first = ""
  local second = "" 

  for word in string.gmatch( url, "([a-z|A-Z|0-9|%-]-)%." ) do 
    first = word
    break
  end

  for word in string.gmatch( url, "%.([a-z|A-Z|0-9|%-]*)" ) do
    second = second .. "." .. word
  end

  second = first .. second
  return second
end

if TI_Device.lanOption ~= "res-rt-napt" and TI_Device.lanOption ~= "biz-rt-napt-ena" and TI_Device.lanOption ~= "res-rt-napt-ipv6"
and TI_Device.lanOption ~= "biz-rt-napt-ipv6" then
        cgilua.redirect("index.lp")
        return
end

local dsl = getDSLInfoHome()
local info = getPPP("PPP.Intf.2")
if cgilua.servervariable"REQUEST_METHOD" == "POST" then

function pcall_MainDNSMethod()
	if info~=nil then
		local domainName=get_domain_name_from_url(POST["domainName"])
		local username=POST["username"]
		local password=POST["password"]
		local servicePath="DynDNS.Service." .. POST["serviceProvide"]
		local interface=info.ipintf
		local dynDnsClientPath
	
		local reply, error = mbus.modify(
		function()
			local reply1, error1 = mbus.addObjects{ path = "DynDNS.Client", param = { UserName=username, Password = password, Service=servicePath, Interface=interface}}
			if error1 ~= nil then
				cgilua.redirect("resultKO.lp")
				return
			end

			dynDnsClientPath=reply1["DynDNS.Client"][1].path
			local reply2, error2 = mbus.addObjects{ path = dynDnsClientPath..".Host", param = { Name = domainName}}
			if error2 ~= nil then
				cgilua.redirect("resultKO.lp")
				return
			end	
		end)	
	
		if info.ppp_status ~= "Connected" then
			local modify = {}
			table.insert(modify, {path=info.ppp_path, param= {TI_Enable="true"}})
			setMBUS(modify)
		end

		if dynDnsClientPath ~= nil then
			modify = {}
            local isCheckedChked = "0"
            if POST["clientDisChked"]~=nil then
                isCheckedChked = "1"
            end
			table.insert(modify, {path=dynDnsClientPath, param= {Enable=isCheckedChked}})
			setMBUS(modify)
		end

	end
	saveall(0, 1)
	cgilua.redirect("save_alert.lp", { u = "dynDns.lp" })
	return
end
	if pcall(pcall_MainDNSMethod) then
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

local dynClientList = getList("DynDNS.Client",nil,"Name","UserName", "Password", "Service", "nbOfdyndns_hosts", "Enable")

%>
<body>
<script type="text/javascript">
//<![CDATA[
function submitAdd()
{
	setTimeout("alert('Please Wait!');", 1);
	var isActive = document.getElementById("clientDisChked").checked;
	var serviceProvide = document.getElementById("serviceProvide").value;
	var domainName = document.getElementById("domainName").value;
	var username = document.getElementById("username").value;	
	var domainNameConflict = false;	

	if(("<%=info.status%>"!="Connected" ) && isActive)
	{
		document.getElementById("DynDnsConfig").style.display="none";
                document.getElementById("resultKoConnected").style.display="block";
                return false;
	}
	
	if(serviceProvide=="")
	{
		document.getElementById("DynDnsConfig").style.display="none";
		document.getElementById("resultKoProvider").style.display="block";
		return false;
	}
	
<% for i,v in pairs(dynClientList) do
    if v["nbOfdyndns_hosts"]~="0" then
      local hostList = getList(v.path..".Host",nil,"Name","Status")
%>
        var domainNameInList = "<%=hostList[1]["Name"]%>";
        if(domainNameInList == domainName)
        {
            domainNameConflict = true;
        }
    <% end %>
<% end %>

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
			window.location = "dynDnsConf.lp";
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

	document.dysDnsConfig.submit();		
}

function cancelConfirm()
{
	document.getElementById("DynDnsConfig").style.display="block";
	document.getElementById("resultKoDomain").style.display="none";
	document.getElementById("resultConflictDomain").style.display="none";
	document.getElementById("resultKoProvider").style.display="none";
	document.getElementById("resultKoNoUsername").style.display="none";
	document.getElementById("resultKoConnected").style.display="none";
}
//]]>
</script>

<div class="contentContainer">
	<div class="breadCrumbContainer">
	<ul class="brdCrumb">
	<li><a href="advance.lp"><%=translate([==[Advanced Settings]==])%></a></li><li>|</li> <li><a href="dynDnsConf.lp"><%=translate([==[Dynamic DNS]==])%></a></li> 
				</ul>
		</div>	

<div class="contentTab" id="content">
	<ol id="tocTab">
		<li><a id="mediaStatus" href="dynDns.lp" >
			<div class="tab">
			<span class="tabIcon_stdns"></span>  
			<span class="contTabTxt transform"><%=translate([==[Dynamic DNS]==])%></span>
		</div><div class="clrBth"></div></a></li>
		<li><a id="mediaconfig" href="dynDnsConf.lp" class="current margin15">
			<div class="tab" style="padding:0 31px;">
				<span class="contTabTxt transform"><%=translate([==[Configure Dynamic DNS]==])%></span></div></a></li>			
	</ol>
</div>
<div class='contentcontainer'>
<hr>
<div class='contentitem'>
<table border="0" width="100%" id="DynDnsConfig">
<tr>
    <td style='vertical-align:top'>
        <table cellspacing='0' cellpadding='0' width="100%">
        <tr>
            <td class="midarea2 tableTitle"><%=translate([==[Configuring Dynamic DNS]==])%></td>
        </tr>
        <tr>
			<td>
            
            <form id="dysDnsConfig" name="dysDnsConfig" action="" method="post">
				<table cellspacing='0' cellpadding='0' width='100%'>
						<tr><td style='vertical-align:top'>
                <table width='100%' class='edittable fontSize marleft36 width750' cellspacing='0' cellpadding='0' border='0'>
					<tr>
						<td colspan='6'></td>
					</tr>
					<tr>
						<td colspan='6'></td>
					</tr>
					
					<tr><th class="tableHd"><%=translate([==[Active]==])%></th>
					<th class="tableHd"><%=translate([==[Service Provider]==])%></th>
					<th class="tableHd"><%=translate([==[Domain Names]==])%></th>
					<th class="tableHd"><%=translate([==[Username]==])%></th>
					<th class="tableHd"><%=translate([==[Password]==])%></th><th class="tableHd"><%=translate([==[Configure]==])%></th></tr>
  <tr><td colspan='6'>&nbsp;</td></tr>
                <%
                local rowStyle = "oddrow"
                local isChecked = 'checked="checked"'
                if isChecked =="true" then
                    isChecked = ""
                end
                %>
        
                <tr>
                <td class="<%=rowStyle%> padleft15"><input type="checkbox" <%=isChecked%> id="clientDisChked" name="clientDisChked" value="ON" /></td>
                <td class="<%=rowStyle%> alignMid padcell">
<%
createSelect('<select id="serviceProvide" style="text-align:left" name="serviceProvide" class="inputClass alignMid"><option value="">&lt;' .. translate([==[Choose]==]) .. ' ... &gt;</option>',nil,dynServiceList,"Server","path")
%>
                </td>
                <td  class="<%=rowStyle%> alignMid padcell"><input type="text" id="domainName" name="domainName" size="15" class="inputClass"/></td>
                <td  class="<%=rowStyle%> alignMid padcell"><input type="text" id="username" name="username" size="10"  class="inputClass"/></td>
                <td  class="<%=rowStyle%> alignMid padcell"><input id="password" type="password" name="password" size="10" class="inputClass" /></td>
                <td  class="<%=rowStyle%> alignMid padcell">
					<a onclick="submitAdd()" href="#">
						<div class="midarea6-1 mainButton" style="margin-bottom:0px;"   name="thb1"><%=translate([==[Add]==])%></div>
					</a>
				</td>
                </tr>
               
                <table cellspacing='0' cellpadding='0' width='100%' class="padtop10 fontSize txtAlignCenter">
					<tr>
						<td width='320'></td>
						<td class="verticalAlign" align="center">
							<a href ="dynDns.lp">
								<div class="midarea6-1 secondaryButton"> <%=translate([==[Back]==])%> </div>
							</a>
						</td>
					</tr>
				</table>
            </table>
			            </td>
        </tr>
        </table>
            </form>

    </td>
</tr>
</table>
    </td>
</tr>
</table>
</div>
</div>
</div>
<script src="js/antiCSRF.js" type="text/javascript"></script>

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

