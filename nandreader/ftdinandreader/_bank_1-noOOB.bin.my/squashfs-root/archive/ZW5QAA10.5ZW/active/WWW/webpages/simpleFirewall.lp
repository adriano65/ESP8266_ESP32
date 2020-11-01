<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
<head>
<title>Modem Telecom Italia</title>
<link rel="stylesheet" href="css/master.css" type="text/css"/>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
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
		window.parent.menu.document.getElementById("firewa").className="submenuselect1";
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
<% cgilua.lp.include("lp/mbus_util.lp") %>
<% cgilua.lp.include("lp/style.lp") %>
<%
local translate = translate
local POST = cgilua.POST

function get_fw_state()
	local fw_data, error = mbus.getParameters{path = "Device.Firewall", param = "Config", datamodel = "second"}
	local fw_state = fw_data["Device.Firewall"][1].param["Config"]
	return fw_state
end

local fw_active = get_fw_state()
if cgilua.servervariable"REQUEST_METHOD" == "POST" then
	local modify={}
	local ret

	if POST["gui_fwstate"] == "1" and fw_active ~= "Low" then
		table.insert(modify, {path="Device.Firewall", param = {Config="Low"}, datamodel = "second"})
		ret = setMBUS_IGD(modify)
		if ret then
			fw_active = "Low"		
			saveall(15, 1)
		end

	elseif POST["gui_fwstate"] == "0" and fw_active ~= "Off" then
		table.insert(modify, {path="Device.Firewall", param = {Config="Off"}, datamodel = "second"})
		ret = setMBUS_IGD(modify)
		if ret then
			fw_active = "Off"		
			saveall(15, 1)
		end
	end
end

%>
	<body>
		<div class="contentContainer">
	 
		<div class="breadCrumbContainer">
			<ul class="brdCrumb">
				<li><a href="advance.lp"><%=translate([==[Advanced Settings]==])%></a></li><li>|</li><li><a href="simpleFirewall.lp"><%=translate([==[Firewall]==])%></a></li>
			</ul>
		</div>	
		
		
		
		<div class="contentTab" id="content">
			<ol id="tocTab">
				<li><a class="current">
		<div class="tab">
			<span class="tabIcon_fire"></span>  
			<span class="contTabTxt transform"><%=translate([==[Configure firewall]==])%></span>
		</div>
		<div class="clrBth"></div></a></li>
			</ol>
		</div>
		
<div class="contentcontainer"> 

<form id="firewall" name="firewall" method="post" action="">
<div class='contentitem' class="fontSize">
<%
   writePageHeader_new()
   writeTableRowNoTitle()
 
%>
	<tr>
	<td  class=" fontSize tableTitle paddtop10"  style="width:300px;"><%=translate([==[firewall status]==])%></td>
	<td class=" fontSize tableTitle paddtop10"><%=translate([==[description]==])%></td >
	</tr>
<tr> <td align='center' colspan="2">&nbsp;</td></tr>
   <tr >
        <td  class=" oddrow_firewall firewallRow fontSize" >
       <input type="radio" value="0" id="fw_not_active" name="gui_fwstate">&nbsp;<%=translate([==[Inactived]==])%></td>
        <td class="oddrow_firewall firewallRow fontSize">
        <%=translate([==[Firewall off: disables controls on TCP/UDP maintaining the configuration of the virtual server, DMZ and Port Mapping]==])%>.
		</td>
    </tr>
	
	<tr>
        <td class=" evenrow_firewall firewallRow fontSize" >
		<input type="radio" value="1" id="fw_active" name="gui_fwstate" >&nbsp;<%=translate([==[Actived]==])%>&nbsp;<%=translate([==[(Basic protection)]==])%></td>
        <td class=" evenrow_firewall firewallRow fontSize" >
        <%=translate([==[Firewall active: blocks incoming connections without affecting the configuration of the DMZ, Virtual Server and Port Mapping]==])%>.</td>
    </tr>
	
	<!-- <tr><td></br></td></tr> -->
	<tr>
                   <td align='center' colspan="2">
			  <table border='0' cellspacing='0' cellpadding='0' width='100%' class="fontSize padtop10 txtAlignCenter">
	<tr>
					<td style="float:right;text-align:left">
				<a href ="javascript:submitFire()" style="float:right;text-align:left">
				<div name="thb8" class="midarea6-1 mainButton"><%=translate([==[Save]==])%></div></a>
				</td>
				<td style="padding-left:50px">
				<a href ="advance.lp">
				<div name="thb10" class="midarea6-1 secondaryButton"><%=translate([==[Back]==])%></div></a>
				</td>
				</tr>
				</table>
				</td></tr>
    <!-- <tr><td align='center'>
        <br/>
        <input type="submit" value="<%=translate([==[Save]==])%>" name="thb8"/>&nbsp;&nbsp;&nbsp;&nbsp;
        <input type="button" onclick='javascript: document.location.href="advance.lp";' value="<%=translate([==[Back <]==])%>" name="thb10"/>
    </td></tr> -->
<%
   endBlock()
   endPage()
%>
</div>
</form>
</div>
</div>
<script src="js/antiCSRF.js" type="text/javascript"></script>
</body>
</html>

<script language="javascript">
var active = "<%=fw_active%>";
//alert(active)
function submitFire() {
	document.firewall.submit();
}
if(active == "Low"){
        document.getElementById("fw_active").checked = true;
}else{
        document.getElementById("fw_not_active").checked = true;
}
</script>
