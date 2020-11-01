<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<title>Modem Telecom Italia</title>
<link rel="stylesheet" href="css/master.css" type="text/css"/>
<style>
.urlTop
{
	margin-top:125px;
}
.buttonTop
{
	margin-top:20px;
}
.imgleft
{
	padding-left:5px;
}
</style>
<script language="javascript" type="text/javascript" src="js/script.js"></script>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<meta http-equiv="Content-Language" content="it"/>
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
		window.parent.menu.document.getElementById("dns").className="";
	}
	if(window.parent.menu.document.getElementById("firewa")!=null && 
		window.parent.menu.document.getElementById("firewa") != "undefinded") {
		window.parent.menu.document.getElementById("firewa").className="";
	}
	if(window.parent.menu.document.getElementById("urlfi")!=null && 
		window.parent.menu.document.getElementById("urlfi") != "undefinded") {
		window.parent.menu.document.getElementById("urlfi").className="submenuselect1";
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
<% cgilua.lp.include("lp/common.lp") %>
<% cgilua.lp.include("lp/device.lp") %>
<% cgilua.lp.include("lp/ppp.lp") %>
<% cgilua.lp.include("lp/util.lp") %>
<% cgilua.lp.include("lp/mbus_util.lp") %>
<% cgilua.lp.include("lp/lan.lp") %>
<%
local translate = translate
local POST = cgilua.POST
local urlFilterPath = "Device.NAT.X_TELECOMITALIA_IT_URLFiltering.1" 
local TI_Device = getTIInfo_Device()
local ipInfo_T = getIPInfo()
local TI_info = getTIInfo()
if TI_Device.lanOption ~= "res-rt-napt" and TI_Device.lanOption ~= "biz-rt-napt-ena" and 
TI_Device.lanOption ~= "res-rt-napt-ipv6" and TI_Device.lanOption ~= "biz-rt-napt-ipv6" then
    cgilua.redirect("index.lp")
    return
end
if cgilua.servervariable"REQUEST_METHOD" == "POST" then
    local modify = {}
    -- only DSD enabled, url filter could effect, so when url filter eanble, DSD is eanbled;  when disabled, DSD is automatic
    local DSD, error = mbus.getParameters{ path = "DSD", param ={"Status"}}
    local DSDStatus = DSD["DSD"][1].param["Status"]
    if POST["enable"]=="1" and DSDStatus~="Enabled" then
        table.insert(modify, {path = "DSD", param={ Status = "Enabled"}})
        setMBUS(modify)
    elseif POST["enable"]=="0" and DSDStatus~="Automatic" then
        table.insert(modify, {path = "DSD", param={ Status = "Automatic"}})
        setMBUS(modify)
    end
    modify={}
    if POST["save"] == "1" then
        table.insert(modify, {path = urlFilterPath, param={ Enable = POST["enable"] }, datamodel="second"})
        table.insert(modify, {path = urlFilterPath, param={ FilteredURLsExclude = POST["exclude"] }, datamodel="second"})
        setMBUS_IGD(modify)
    end

    modify={}
    if POST["add"] == "1" and POST["addurl"] ~= "" then
        table.insert(modify, {path = urlFilterPath, param={ AddURL = POST["addurl"] }, datamodel="second"})

    elseif POST["remove"] == "1" and POST["removeurl"] ~= "" then
        table.insert(modify, {path = urlFilterPath, param={ RemoveURL = POST["removeurl"] }, datamodel="second"})

    elseif POST["clearurl"] == "1" then
        table.insert(modify, {path = urlFilterPath, param={ ClearURL = "1" }, datamodel="second"})
    end

    setMBUS_IGD(modify)
    saveall(0, 1)
    cgilua.redirect("save_alert.lp", { u="urlFilter.lp" })
    return
end

local active = 0
local exclude = 0
local set_url_disp = "none"
local url = ""
local url_list = {}

local reply, error = mbus.getParameters{ path = urlFilterPath, datamodel="second"}
local ret = reply[urlFilterPath][1]

if ret ~= nil and ret.param ~= nil and ret.param["Enable"] ~= nil then
  if ret.param["Enable"] == "true" then
    active = 1
    set_url_disp = "" 
  end

  if ret.param["FilteredURLsExclude"] == "true" then
    exclude = 1
    set_url_disp = ""
  end

  url = ret.param["FilteredURLs"]
  if url ~= "" then
    for s in string.gmatch(url, "([%w%.*]+)") do
      table.insert(url_list, s)
    end
  end
end

local function get_active_checked()
  local checkInfo=" "
  if active==1 then
    checkInfo = "checked='checked'"
  end
  return checkInfo
end

local function get_off_checked()
  local checkInfo=" "
  if active==0 then
    checkInfo = "checked='checked'"
  end
  return checkInfo
end

local function get_exclude_checked()
  local checkInfo=" "
  if exclude==1 then
    checkInfo = "checked='checked'"
  end
  return checkInfo
end

local function get_exclude_off_checked()
  local checkInfo=" "
  if exclude==0 then
    checkInfo = "checked='checked'"
  end
  return checkInfo
end

local pppStatuspath = "Device.PPP.Interface.ppp_0"
local pppStatusreply, error = mbus.getParameters{ path = pppStatuspath, param = {"Status"}, flags = "KEYPATH", datamodel = "second" }
local pppStatus = pppStatusreply[pppStatuspath][1].param["Status"]

local NATStatus = ""
local NATPath = "Device.NAT.InterfaceSetting.ppp_0"
local reply, error = mbus.getParameters{ path = NATPath, param = {"Enable"}, flags = "KEYPATH", datamodel = "second" }
if error==nil then
  NATStatus = reply[NATPath][1].param["Enable"]
end

local wrongUrl = translate([==[Warning: there are one or more URLs correct. Use only the allowed characters (az, AZ, 0-9, *)]==])
local listFull = translate([==[Warning: the list is full. Remove items before proceeding]==])
%>

<script language="javascript" type="text/javascript">
//<![CDATA[
function showErrorMsg(errorMsgStr)
{
    document.getElementById("set_url_table").style.display="none";
    document.getElementById("resultKO").style.display="block";
    document.getElementById("errorMsg").innerHTML=errorMsgStr;
}

function save_url()
{
    var excludeVal = document.getElementById('filterExclude').value;
    var oldFilterExclude = document.getElementById('R_active').checked;

    if(oldFilterExclude==true)
    {
        if (excludeVal=="1")
        {
            document.getElementById('save').value="1";
            document.getElementById("set_url_table").style.display="none";
            document.getElementById("excludeWarn").style.display = "none";
            document.getElementById("confirm").style.display = "block";
        }
        else
        {
            document.getElementById('save').value="1";
            document.getElementById("set_url_table").style.display="none";
            document.getElementById("excludeWarn").style.display = "block";
        }
    }
    else
    {
        document.getElementById('save').value="1";
        document.getElementById("set_url_table").style.display="none";
        document.getElementById("excludeWarn").style.display = "none";
        document.getElementById("confirm").style.display = "block";
    }
}

function submit_url()
{
    document.getElementById("excludeWarn").style.display = "none";
    document.getElementById("set_url_table").style.display="none";
    document.getElementById("confirm").style.display = "block";
}
function change_url()
{
<% if url == "" then %>
  if(document.getElementById('clearurl').value == "1")
  {
    document.getElementById('clearurl').value = "0";
    return false;
  }
<% end %>

  if(document.getElementById('remove').value == "1")
  {
    document.getElementById('remove').value = "0";
<% if url == "" then %>
    return false;
<% else %>
    var str = "";

    <% for n=1, #url_list do %>
      if((document.getElementById("url_check<%=n%>").checked))
      {
        str = str + (document.getElementById("url_check<%=n%>").value) + ",";
      }
    <%end%>
	
    if(str == "")
    {
      return false;
    }
    // remove the last redundant ','
    str = str.substring(0, str.length-1);
    document.getElementById('remove').value = "1";
    document.getElementById('removeurl').value = str;
<% end %>
  }
  else if(document.getElementById('add').value == "1")
  {
    document.getElementById('add').value = "0";
    var addurlstr = document.getElementById('addurl').value;
    if(addurlstr == "")
    {
      return false;
    }
      
    var urlstr = "<%=url%>";
    var urlarray = urlstr.split(",");
    var addurlarray = addurlstr.split(",");
	    
    if((addurlarray.length > 128) || ((urlarray.length + addurlarray.length) > 128))
    {
      showErrorMsg('<%=listFull%>');
      return false;
    }
  
    if((addurlstr.length > 1280) || ((urlstr.length + addurlstr.length) > 1280))
    {
      showErrorMsg('<%=listFull%>');
      return false;
    }
	
	for(var i=0;i<addurlarray.length;i++)
	{
		if (addurlarray[i].length > 81)
		{
			showErrorMsg('<%=listFull%>');
			return false;
		}
		for(var j=0;j<urlarray.length;j++)
		{
			if (addurlarray[i] == urlarray[j])
			{
			  showErrorMsg('<%=wrongUrl%>');
			  return false;
			}
		}
		for(var k=0;k<addurlarray.length;k++)
		{
			if ((addurlarray[k] == addurlarray[i]) && (i != k))
			{
			  showErrorMsg('<%=wrongUrl%>');
			  return false;
			}
		}
	}
	 if(!urlExam(addurlstr))
    {
      showErrorMsg('<%=wrongUrl%>');
      return false;
    }
	
    document.getElementById('add').value = "1";
  }
  
  document.getElementById("set_url_table").style.display = "none";
  document.getElementById("confirm").style.display = "block";
}

function submitConfirm()
{
  document.getElementById("wifi_submit").removeAttribute("href");
  document.getElementById("wifi_submit").onclick = null;
  document.getElementById("wifi_submit_con").className = "next_wifidisable";
  document.getElementById("change_url_form").submit();
}

function cancelConfirm()
{
  document.getElementById("set_url_table").style.display = "";
  document.getElementById("confirm").style.display = "none";
  document.getElementById("resultKO").style.display = "none";
  document.getElementById("add").value = "0";
  document.getElementById("remove").value = "0";
  document.getElementById("clearurl").value = "0";
  document.getElementById("removeurl").value = "";
}

function urlExam(str)
{
    var filter=/^\s*[.,A-Za-z0-9*]{0,10240}\s*$/;
    if ((str.indexOf(' ') != -1) || (!str.match(filter)))
    {
        return false;
    }
    return true;
}
	

//]]>
</script>

<body>
<div class="contentContainer">
	<div class="breadCrumbContainer">
			<ul class="brdCrumb">
				<li><a href="advance.lp"><%=translate([==[Advanced Settings]==])%></a></li><li>|</li>
				<li><a href="urlFilter.lp"><%=translate([==[URL Filtering]==])%></a></li> 
			</ul>
	</div>	
	<div class="contentTab" id="content">
			<ol id="tocTab">
				<li><a class="current" href="urlFilter.lp">
				<div class="tab">
				<span class="tabIcon_urlfil"></span>
				<span class="contTabTxt transform"><%=translate([==[URL Filtering]==])%></span>
				</div><div class="clrBth"></div></a>
				</li>
			</ol>
	
	</div>
<div>
<%if pppStatus ~= "Up" or NATStatus ~= "true" then%>
    <p class='midarea2 fontSize' style="width:795px;"><%=translate([==[Warning: the automatic connection modem is disconnected or the NAT is disabled. The barring service URL is not active]==])%></p>
</div>
<%else%>
<div class="contentcontainer" id="set_url_table">
<hr>
<form method="POST" id="change_url_form" action="">
<input type="hidden" name="save" id="save" value="0" />
<input type="hidden" name="add" id="add" value="0" />
<input type="hidden" name="remove" id="remove" value="0" />
<input type="hidden" name="clearurl" id="clearurl" value="0" />
<input type="hidden" name="removeurl" id="removeurl" value="" />
<input type="hidden" name="filterExclude" id="filterExclude" value="<%=active%>" />

<div class='contentitem' style="padding-top:30px">
 <table cellspacing='0' cellpadding='0' ><tr><td width="40">&nbsp;</td><td>
             <table class="fontSize width750" width='100%' cellspacing='0' cellpadding='0'>
				
				<tr>
					<td class="midarea4_newtelmain2" width="20%"><%=translate([==[Status]==])%>:</td>
					<td class="midarea4_newtelmain2" width="80%">
						<input type="radio" value="1" id="R_active" name="enable" <%=get_active_checked()%> >&nbsp;<%=translate([==[Enabled]==])%>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
						<input type="radio" value="0" id="R_off" name="enable" <%=get_off_checked()%> >&nbsp;<%=translate([==[Disabled]==])%>
					</td>
				</tr>
				<tr height="10">
					<td colspan="2"></td>
				</tr>
				<tr>
					<td class="midarea4_newtelmain2" width="20%"><%=translate([==[Reverse block]==])%>:</td>
					<td class="midarea4_newtelmain2" width="80%">
						<input type="radio" value="1" id="R_ExcludeActive" name="exclude" <%=get_exclude_checked()%> >&nbsp;<%=translate([==[Enable]==])%>&nbsp;&nbsp;&nbsp;&nbsp;<%=translate([==[Block all URLs except those specified in continuing]==])%>.
					</td>
				</tr>
				<tr>
					<td class="midarea4_newtelmain2" width="20%"></td>
					<td class="midarea4_newtelmain2" width="80%">
						<input type="radio" value="0" id="R_ExcludeOff" name="exclude" <%=get_exclude_off_checked()%> >&nbsp;<%=translate([==[Disable]==])%>&nbsp;&nbsp;&nbsp;&nbsp;<%=translate([==[Allow all URLs except those specified in continuing]==])%>.
					</td>
				</tr>
				<tr height="10">
					<td colspan="2"></td>
				</tr>
				<tr>
					<td colspan="2" style="padding-left:150px;">
					<div class="fleft">
						<a onclick='javascript: save_url();'>
							<div style="vertical-align:middle;color:black;" class='midarea6-1 mainButton'><%=translate([==[Save]==])%></div>
						</a>
					</div>
					<div class="fleft" style="padding-left:10px;">
						<a onclick='javascript: document.location.href="advance.lp";'>
							<div style="vertical-align:middle;color:black;" class='midarea6-1 mainButton '><%=translate([==[Cancel]==])%></div>
						</a>
					</div>
					</td>
				</tr>
            <tr height="10">
					<td colspan="2"></td>
				</tr>
				<tr>
					<td colspan="2">
						<div class="fleft">
					
						<div class="fleft midarea4_newtelmain2" ><%=translate([==[Blocked URL]==])%>:
						</div>
						
						
						<% if url ~= "" then %>
						<div class="blockUrl" style="margin-left:14%">
								
							<table class="edittable fontSize" cellspacing="0" cellpadding="0">
							<thead>
								<th class="tableHd" width="250"><%=translate([==[URL]==])%></th>
								<th class="tableHd" width="50"><%=translate([==[Remove]==])%></th>
							</thead>
							<%local rowStyle = "oddrow"
							for n=1, #url_list do 								
								if n%2 == 1 then
									rowStyle = "oddrow"
								else
									rowStyle = "evenrow"
								end%>
							<tr><td class='<%=rowStyle%>' colspan='2'></td></tr>
							<tr><td colspan='2'><img src='images/spacer.gif' border='0' width='1' height='3' alt=''></td></tr>
							<tr class="<%=rowStyle%>">
								<td name="url_list<%=n%>" id="url_list<%=n%>" class="inputClass"><%=url_list[n]%></td>
								<td class=""><input type="checkbox" size="8" value="<%=url_list[n]%>" name="url_check<%=n%>" id="url_check<%=n%>" style="margin-left:20%"/></td>
							</tr>
							<% end %>
							</table>

						</div><% end %>
					</div></td>
					</tr>
			</table></td></tr></table>
			
			<table cellspacing='0' cellpadding='0' id="urlButton" >
			<tr height="10">
					<td colspan="2"></td>
				</tr>
			<tr class="fontSize padleft40" >				
					<td style="padding-left:191px;">
						<a onclick="javascript: document.getElementById('remove').value='1'; change_url();">
							<div style="vertical-align:middle;color:black;width:152px" class='midarea6-1 mainButton'><%=translate([==[Remove Selected URL]==])%></div>
						</a>
					</td>
					
					<td style="padding-left:10px;">
						<a onclick="javascript: document.getElementById('clearurl').value='1'; change_url();">
							<div style="vertical-align:middle;color:black;width:110px;" class='midarea6-1 mainButton'><%=translate([==[Remove all]==])%></div>
						</a>
					</td>
				</tr></table>
            
				 <table cellspacing='0' cellpadding='0' ><tr><td width="40">&nbsp;</td><td>
			
    <table class="tableTitle" cellspacing='0' cellpadding='0' width='100%'>
			<tr>
            <td class="midarea2_telmain"><%=translate([==[Add URL]==])%></td>
			</tr>
	</table>
    <table class="fontSize width750" width='100%' cellspacing='0' cellpadding='0' style="line-height:150%;">
        <tr>
			<td width="540"><textarea cols="72" rows="4" class="content" id="addurl" name="addurl" value="" class="inputClass"></textarea></td>
		</tr>
        <tr>
			<td class="midarea4_newtelmain2" style="margin-bottom:15px"><%=translate([==[Enter the URL to add, separated by a comma. Use only alphanumeric characters (a-z, A-Z, 0-9) or character *]==])%></td>
		</tr>
        <tr>
            <td>
				<a onclick="javascript: document.getElementById('add').value='1'; change_url();">
					<div class='midarea6-1 mainButton'><%=translate([==[Add]==])%></div>
				</a>
			</td>
		</tr>
    </table>
            </td>
		</tr>
	</table>
  
</div>
</form>
</div>
<% if url ~= "" then %>
<script language="javascript" type="text/javascript">
//<![CDATA[
var objURLList = document.getElementById("url_list");
if(objURLList.size < 6)
{
  objURLList.size = "6";
  document.getElementById("url_list_div").style.overflowY = "hidden";
}
if(objURLList.offsetWidth < 450)
{
  objURLList.style.width = "450px";
  objURLList.size = "6";
  document.getElementById("url_list_div").style.overflow = "hidden";
}
//]]>
</script>
<% end %>

<script src="js/antiCSRF.js"></script>
<div id="confirm" style="display:none">
<%cgilua.lp.include("webparts/confirmBack.lp")%>
</div>
<div id="excludeWarn" style="display:none">
<%cgilua.lp.include("webparts/resultKO_urlExclude.lp")%>
</div>
<div id="resultKO" style="display:none">
<%cgilua.lp.include("webparts/resultKO_URL.lp")%>
</div>
<%end%>
</div>
</body>

</html>
