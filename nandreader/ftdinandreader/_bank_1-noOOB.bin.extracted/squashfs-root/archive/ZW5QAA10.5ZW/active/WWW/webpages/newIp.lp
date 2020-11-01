<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
          "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head>

<title>Modem Telecom Italia</title>

<meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
<!-- <link rel="stylesheet" href="css/style.css" type="text/css"/> -->
<link rel="stylesheet" href="css/master.css" type="text/css" />
<script language="javascript" type="text/javascript" src="js/script.js"></script>

<% cgilua.lp.include("lp/language.lp") %>
<% cgilua.lp.include("lp/common.lp") %>
<% cgilua.lp.include("lp/mbus_util.lp") %>
<% cgilua.lp.include("lp/util.lp") %>
<% cgilua.lp.include("lp/form.lp") %>
<% cgilua.lp.include("lp/ppp.lp") %>
<% cgilua.lp.include("lp/device.lp") %>
<% cgilua.lp.include("lp/portmap.lp") %>
<% cgilua.lp.include("lp/style.lp") %>
<% cgilua.lp.include("lp/voip.lp") %>
<%
local tprint = require("tableprint")
local translate = translate
local POST=cgilua.POST

local isRemote = isRemoteAccess()
local telefonoId,telefonoName,register,username
local maxLimit=true
local telefonoPath = "Device.Services.VoiceService.3.VoiceProfile."
local telefonoInPath = "SIPServer.InternalUA."
local totalPros = getIpProfiles("Device.Services.VoiceService.3.VoiceProfile")
for i=2,totalPros do
	local replyType, error = mbus.getParameters{ path = telefonoPath..i..".Line.1", 		param="X_TELECOMITALIA_IT_PhyAssignment" , datamodel = "second" }
	local notAssign = replyType["Device.Services.VoiceService.3.VoiceProfile."..i..".Line.1"][1].param["X_TELECOMITALIA_IT_PhyAssignment"]
	if notAssign == "Not Assigned" then
		maxLimit = false
		telefonoId = i
		telefonoPath = telefonoPath..i	
		telefonoInPath = telefonoInPath..i	
		break
	end	
end
if maxLimit == false then
	if(telefonoId~=11)then
		telefonoName = "Telefono IP "..telefonoId 
	else
		telefonoName = "Telefono IP 1"
	end
	register = getRegister(telefonoPath..".SIP")
	username = getUsername(telefonoPath..".Line.1")
end
if cgilua.servervariable"REQUEST_METHOD" == "POST" then
	local modify ={}
	local modify1 ={}	
	
	table.insert(modify, {path = telefonoPath..".Line.1.SIP", param = {AuthUserName = username, AuthPassword = POST["password"]}, datamodel = "second"})

	--table.insert(modify, {path = telefonoPath..".Line.1", param = {X_TELECOMITALIA_IT_LineName = POST["telephonoIp"],X_TELECOMITALIA_IT_PhyAssignment="Assigned"}, datamodel = "second"})

	table.insert(modify1, {path = telefonoInPath, param = {Linename = POST["telephonoIp"],PhyAssignment="Assigned"}})	

	table.insert(modify, {path = telefonoPath, param = {Enable = "Enabled"}, datamodel = "second"})
	
	setMBUS_IGD(modify)
	setMBUS(modify1)	
        saveall(0, 1)
	cgilua.redirect("save_alert.lp", { u = "voipStato.lp" })	
	--cgilua.redirect("voipStato.lp")
end
%>

<script type="text/javascript">
//<![CDATA[

function isPwdCheck(str)
{
	var reg = /^[\da-zA-Z]{6,64}$/; 
	return reg.test(str);        
}

function isNameCheck(str)
{
	var reg = /^[\d a-zA-Z]{6,14}$/; 
	return reg.test(str);        
}

function isMaxCheck(str)
{	
	return <%=maxLimit%>;        
}

function submitIP()
{       
    var password = document.getElementById("password").value;	
    var ipName = document.getElementById("telephonoIp").value;
	
    if(isPwdCheck(password)==false || isNameCheck(ipName)==false ) {
	document.getElementById("newIpDiv").style.display = "none";
	document.getElementById("newPwd").style.display = "block";    	
    	document.getElementById("newMax").style.display="none";
	return false;
    } 
    if(isMaxCheck()) {
        document.getElementById("newIpDiv").style.display = "none";
	document.getElementById("newPwd").style.display = "none";    	
    	document.getElementById("newMax").style.display="block";
	return false;
    }	
    //Fix given for CPE_P00121391    
    document.getElementById("disableBtn").onclick = null;
    document.getElementById("disableBtn").className = "aClicked";
    document.getElementById("configIP").submit();
}

function closeConfirm()
{
    	document.getElementById("newIpDiv").style.display = "block";
	document.getElementById("newPwd").style.display = "none";    	
    	document.getElementById("newMax").style.display="none";
}

function invokeIpPage(pageName) {
	window.location.href=pageName;
}

//]]>
</script>
</head>
<body>

<div class="contentContainer">
		<div class="breadCrumbContainer">
			<ul class="brdCrumb">
				<li><a href="advance.lp"><%=translate([==[Advanced Settings]==])%></a></li><li>|</li> <li><a href="voipStato.lp"><%=translate([==[Telephony services]==])%></a></li> 
			</ul>
		</div>

<!-- <table cellspacing='0' cellpadding='0' width="100%" class="NavBar">
<tr><td align="left"><a href="advance.lp">Avanzate</a>&nbsp;&nbsp;>&nbsp;&nbsp;<a href="voipStato.lp"><%=translate([==[Telephony services]==])%></a></td> -->

<div class="contentTab" id="content">
			<ol id="tocTab">
				<li><a href="voipStato.lp" class="current">
		<div class="tab">
			<span class="tabIcon_sttel"></span>  
			<span class="contTabTxt"><%=translate([==[Telephony services]==])%></span>
		</div>
		<div class="clrBth"></div></a></li>
		<% if isRemote==false then%> 
			<li><a class="margin15" href="telephonyNumber.lp">
		
		<div class="tab">
			<span class="contTabTxt"><%=translate([==[Telephone numbers]==])%></span></div></a></li>
		<% end %> 
			</ol>
		</div>


<!-- <%if isRemote==false then%>
<td align="right"><a href="telephonyNumber.lp">Numeri telefonici</a></td>
<%end%>
</tr>
</table> -->

<div class='contentcontainer' id='configNum'>

<div class='contentitem'>


<div id="newIpDiv">
<form id="configIP" name="configIP" action="newIp.lp" method="post">
<table width='100%' cellspacing='0' cellpadding='0' class="PageMessage width750">

    	<tr>	
		<td>
			<span class='midarea2 tableTitle' style='font-weight:bold'><%=translate([==[New IP Phone]==])%></span><br>
		</td>
	</tr>
	<tr>
		<td width="250" align='left' class="wifiMidarea4-2 padleft40"><%=translate([==[Name]==])%></td>
		<td colspan="3" align='left'><input type="text" maxlength="14" id="telephonoIp" name="telephonoIp"  class="inputClass" value="<%=telefonoName%>"/></td>
	</tr>
</table>	
	<div class="marleft40 padtop5" style="font-weight:bold;font-size:11px;color: #5E5E5E;"><%=translate([==[Save the desired configuration and then configure the telephone Registrar, Username, Password, and Port specified.]==])%></div>
	</tr>
<table width='100%' cellspacing='0' cellpadding='0' class="PageMessage marleft40 width750">
	<tr>
		<td width="250" class="wifiMidarea4-2 padtop5" align='left' style='padding-left: 0px;'><%=translate([==[Registrar]==])%></td>
		<td colspan="3" class="padtop5" align='left'><%=register%></td>
	</tr>
	<tr>
		<td width="250" class="wifiMidarea4-2 padtop5" align='left' style='padding-left: 0px;'><%=translate([==[Username]==])%></td>
		<td colspan="3"  class="padtop5" align='left'><%=username%></td>
	</tr>
	<tr>
		<td width="250" class="wifiMidarea4-2 padtop5" align='left' style='padding-left: 0px;'><%=translate([==[Password]==])%></td>
		<td colspan="3" class="padtop5" align='left'><input type="password" id="password" name="password"  class="inputClass"  /></td>
	</tr>
	<tr>
		<td width="250" class="wifiMidarea4-2 padtop5" align='left' style='padding-left: 0px;'><%=translate([==[Port]==])%></td>
		<td colspan="3" class="padtop5" align='left'>5065</td>
	</tr>
<br/>
	 <table cellspacing='0' cellpadding='0' width='100%' style="text-align:center" class="marleft40 width750 padtop10">
	   <tr><td><img src='images/spacer.gif' border='0' width='1' height='10' alt=''><br></td></tr>	
            <tr>
		 <td class="verticalAlign fright" style="padding-left:25px;">
					<a  class="fright" style='color:black' onclick='submitIP()' id="disableBtn">
						<div class="midarea6-1 mainButton"><%=translate([==[Save]==])%></div>
					</a></td>
				<td  class="verticalAlign padleft50">				
					<a style='color:black' onclick='invokeIpPage("voipStato.lp")'>
						<div class="midarea6-1 secondaryButton"><%=translate([==[Back]==])%></div>
					</a>
				
				</td>
			</tr>
		</table>
</form>
</table>
</div>

<div id="newPwd" style="display:none">
<%cgilua.lp.include("webparts/newIpPwdCheck.lp")%>
</div>
<div id="newMax" style="display:none">
<%cgilua.lp.include("webparts/newIpMax.lp")%>
</div>

<script src="js/antiCSRF.js" type="text/javascript"></script>
<script type="text/javascript"> 
if(isMaxCheck()) {
        document.getElementById("newIpDiv").style.display = "none";
	document.getElementById("newPwd").style.display = "none";    	
    	document.getElementById("newMax").style.display="block";
 }
</script>
</div>
</div>
</div>

</body>
</html>

