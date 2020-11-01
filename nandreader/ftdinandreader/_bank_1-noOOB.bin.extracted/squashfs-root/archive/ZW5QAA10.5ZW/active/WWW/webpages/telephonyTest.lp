<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
          "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<title>Modem Telecom Italia</title>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
<link rel="stylesheet" href="css/master.css" type="text/css" />	
<script language="javascript" type="text/javascript" src="js/portmap.js"></script>
<% cgilua.lp.include("lp/language.lp") %>
<%
local translate = translate
local QUERY = cgilua.QUERY
local pathId = cgilua.QUERY["pathId"]
local pathDetail = "Device.Services.VoiceService.1.PhyInterface." .. tostring(pathId) .. ".Tests"
local testSelectorStr = "Requested"
if pathId=="4" then
	testSelectorStr = "PhoneConnectivityTest"
end
local reply, error = mbus.modify(
        function()           
                local reply1, error1 = mbus.setParameters{path = pathDetail, param = {TestSelector=testSelectorStr}, datamodel = "second"}            
        end, {datamodel="second"})
%>
</head>
<body>
<script type="text/javascript">
//<![CDATA[
function changeTeleTest()
{
	var pathId = document.getElementById("pathId").value;
	var urlStr = "/teleTest_ajax.lp";
	var params="pathId="+pathId;
	ajax_get(urlStr, params, testUpdate_cb);
}

//Callback handle to test update:array_T{0=TestState, 1=connection, 2=volDC, 3=volAC, 4=insulationResistance,5=phoneRelease, 6=impedance, 7=dial}
function testUpdate_cb(ajax_obj)
{
	var pathId = document.getElementById("pathId").value;
	var rsps = ajax_obj.responseText.replace(/\s/g,"");
//alert(rsps);
	var array_T = rsps.split("##");
	if(array_T[0] == "Complete")
	{
		var connection = array_T[1];		
		var volDC = array_T[2];
		var volAC = array_T[3];
		var insulationResistance = array_T[4];
		var phoneRelease = array_T[5];
		var impedance = array_T[6];
		var dial = array_T[7];

		if(connection == "true")
		{
			connection = "<%=translate([==[Phone Connected]==])%>";
		}else{
			connection = "<%=translate([==[Phone not connected]==])%>";
		}
		document.getElementById("connection").innerHTML = connection;

		if(phoneRelease == "true")
		{
			phoneRelease = "<%=translate([==[Telephone hook]==])%>";
		}else{
			phoneRelease = "<%=translate([==[Phone locked]==])%>";
		}

		if(dial == "true")
		{
			dial = "<%=translate([==[This fixed line]==])%>";
		}else{
			dial = "<%=translate([==[No landline]==])%>";
		}
		
		document.getElementById("phoneRelease").innerHTML = phoneRelease;
		document.getElementById("dial").innerHTML = dial;

		document.getElementById("volDC").innerHTML = volDC;
		document.getElementById("volAC").innerHTML = volAC;
		document.getElementById("insulationResistance").innerHTML = insulationResistance;
		document.getElementById("impedance").innerHTML = impedance;
		
	}
}

function changeTeleTest4() {
	<%		
	local pathDetail = "Device.Services.VoiceService.1.PhyInterface.4.Tests"
	local con = "Phone not connected"
	local reply, error = mbus.getParameters{ path = pathDetail, param = {"PhoneConnectivity"}, datamodel = "second" }
	if reply[pathDetail]~=nil and reply[pathDetail][1]~=nil then
		con = reply[pathDetail][1].param["PhoneConnectivity"]
	end	
	%>
	var connection = "<%=con%>"
	if(connection == "true") {
		document.getElementById("connState").innerHTML = "<%=translate([==[Phone Connected]==])%>";
	} else {
		document.getElementById("connState").innerHTML = "<%=translate([==[Phone not connected]==])%>";
	}
}
<%if pathId ~= "4" then%>
	window.setInterval("changeTeleTest()", 2000);

<% else%>
	window.setInterval("changeTeleTest4()", 2000);
<%end%>

//]]>
</script>
<div class="contentContainer">
<div class="breadCrumbContainer">
			<ul class="brdCrumb">
				<li><a href="telephonyTest.lp?pathId=<%=pathId%>"><%=translate([==[Telephony test result]==])%></a></li>
			</ul>
		</div>	

		<div class="contentTab" id="content">
			<ol id="tocTab">
				<li><a class="current">
		<div class="tab">
			<span class="tabIcon_voip"></span>
			<span class="contTabTxt"><%=translate([==[Telephony services]==])%></span>
		</div>
		<div class="clrBth"></div></a></li>
			</ol>
		</div>
<!-- <table cellspacing='0' cellpadding='0' width="100%" class="NavBar">
<tr><td align="left"><a href="advance.lp">Avanzate</a>&nbsp;&nbsp;>&nbsp;&nbsp;<a href="telephonyTest.lp?pathId=<%=pathId%>"><%=translate([==[Telephony test result]==])%></a></td></tr>
</table> -->

<div class='contentcontainer'>	
<div class='contentitem'> 
<table cellspacing='0' cellpadding='0' class="fontSize">
<tr>
<td>
        <table  cellspacing='0' cellpadding='0' width='100%' >
		<tr>
		<td class="verticalAlign"> <table cellspacing='0' cellpadding='0' class="martop5">
		<tr>
		<td class="midarea2 tableTitle">
			<input type="hidden" id="pathId" name="pathId" value="<%=pathId%>"/>
			<%=translate([==[Test of voice ports]==])%></td></tr></table></td>
		</tr>
        <tr><td>		
        <table width='100%' class='datatable marleft40' cellspacing='0' cellpadding='0' style="line-height:150%;">
            <tr>
				<td colspan='2' class='black'><img src='images/spacer.gif' border='0' width='1' height='1' alt=''><br></td>
			</tr>
            <tr>
				<td colspan='2'><img src='images/spacer.gif' border='0' width='1' height='3' alt=''><br></td>
			</tr>
            <tr>
				<th  class="sectionArea-1 " align='left' width="400" class="padleft40"><%=translate([==[Label]==])%></th>
				<th class="sectionArea-1 " align='left'><%=translate([==[Shown Value]==])%></th>
			</tr>
            
                <%
		if tonumber(pathId)==1 or tonumber(pathId)==2 then
                %>
            <tr>
				<td  class="sectionArea-1 paddtop10" width='400' class="padleft40"><%=translate([==[Telephone connection]==])%>:</td>
				<td class="sectionArea-1 paddtop10">
					<div id="connection"><img src="images/wait.gif" width="15px" height="15px" /></div>
				</td>
			</tr>
            <tr>
				<td  class="sectionArea-1 padtop5" width='400' class="padleft40"><%=translate([==[DC voltage between a and b]==])%>:</td>
				<td class="sectionArea-1 padtop5">
					<div id="volDC"><img src="images/wait.gif" width="15px" height="15px" /></div>
				</td>
			</tr>
            <tr>
				<td  class="sectionArea-1 padtop5" width='400' class="padleft40"><%=translate([==[AC voltage between a and b]==])%>:</td>
				<td class="sectionArea-1 padtop5">
					<div id="volAC"><img src="images/wait.gif" width="15px" height="15px" /></div>
				</td>
			</tr>
            <tr>
				<td  class="sectionArea-1 padtop5" width='400' class="padleft40"><%=translate([==[Insulation resistance between a and b]==])%>:</td>
				<td class="sectionArea-1 padtop5">
					<div id="insulationResistance"><img src="images/wait.gif" width="15px" height="15px" /></div>
				</td>
			</tr>
            <tr>
				<td  class="sectionArea-1 padtop5" width='400' class="padleft40"><%=translate([==[Release of the phone]==])%>:</td>
				<td class="sectionArea-1 padtop5">
					<div id="phoneRelease"><img src="images/wait.gif" width="15px" height="15px" /></div>
				</td>
			</tr>
            <tr>
				<td  class="sectionArea-1 padtop5" width='400' class="padleft40"><%=translate([==[Impedance]==])%>:</td>
				<td class="sectionArea-1 padtop5">
					<div id="impedance"><img src="images/wait.gif" width="15px" height="15px" /></div>
				</td>
			</tr>
            <tr>
				<td  class="sectionArea-1 padtop5" width='400' class="padleft40"><%=translate([==[Presence dial]==])%>:</td>
				<td class="sectionArea-1 padtop5">
					<div id="dial"><img src="images/wait.gif" width="15px" height="15px" /></div>
				</td>
			</tr>
                <%  
		elseif tonumber(pathId)==4 then
                %>
            <tr>
				<td  class="sectionArea-1 padtop5" width='400' class="padleft40"><%=translate([==[Telephone connection]==])%>:</td>
				<td class="sectionArea-1 padtop5">
					<div id="connState"><img src="images/wait.gif" width="15px" height="15px" /></div>
				</td>
			</tr>
		<%end%>
                <br>
                <table class='padtop10' cellspacing='0' cellpadding='0' width='100%' style="text-align:center">
                <tr>
					<td style="padding-left:200px" class="paddtop10">	
						<a onclick='javascript:document.location.href="telephonyMeasurement.lp";'>
							<div name="thb7" class="midarea6-1 mainButton"><%=translate([==[Cancel]==])%></div>
						</a>
					</td>
                </tr>
			</table> 
            </table>
            </td></tr></table>
        </td></tr>
        </table>
   
</div>
</div>
</body>
</html>
