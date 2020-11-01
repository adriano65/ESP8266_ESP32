<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
          "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head>

<title>Modem Telecom Italia</title>

<meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
<link rel="stylesheet" href="css/master.css" type="text/css"/>
<% cgilua.lp.include("lp/language.lp") %>
<%
local translate = translate
local POST = cgilua.POST

if cgilua.servervariable"REQUEST_METHOD" == "POST" then
	if POST["assoCheck"]=="1" then
		local path_id = POST["pathId"]
		local path_fxs1 = "Device.Services.VoiceService.1.PhyInterface.1"
		local path_fxs2 = "Device.Services.VoiceService.1.PhyInterface.2"
		local fxs1 = "0"
		local fxs2 = "0"
		local info1, error = mbus.getParameters{path = path_fxs1, param = {"X_TELECOMITALIA_IT_SwitchToPSTNIn", "X_TELECOMITALIA_IT_SwitchToPSTNOut"}, datamodel = "second"}
		if info1[path_fxs1][1].param["X_TELECOMITALIA_IT_SwitchToPSTNIn"] == "true" or 
			info1[path_fxs1][1].param["X_TELECOMITALIA_IT_SwitchToPSTNOut"] == "true" then
			fxs1 = "1"
		end
		local info2, error = mbus.getParameters{path = path_fxs2, param = {"X_TELECOMITALIA_IT_SwitchToPSTNIn", "X_TELECOMITALIA_IT_SwitchToPSTNOut"}, datamodel = "second"}
		if info2[path_fxs2][1].param["X_TELECOMITALIA_IT_SwitchToPSTNIn"] == "true" or 
			info2[path_fxs2][1].param["X_TELECOMITALIA_IT_SwitchToPSTNOut"] == "true" then
			fxs2 = "1"
		end
		if (fxs1 == "1" and path_id == "1") or (fxs2 == "1" and path_id == "2") then
			local to_page = "telephonyMeasurement.lp?asso_warn=1&path_id="..tostring(path_id)
			cgilua.redirect(to_page)
		else
			local to_page = "telephonyMeasurement.lp?asso_warn=0&path_id="..tostring(path_id)
			cgilua.redirect(to_page)
		end
	end
end
	
%>
</head>
<body>
<script type="text/javascript">
//<![CDATA[
function associated_check_submit(pathId)
{
	document.getElementById("assoCheck").value = "1";
	document.getElementById("pathId").value = pathId;
	document.assoCheckForm.submit();
}

function closeConfirm(){
	document.getElementById("TeleService").style.display="block";
	document.getElementById("voiceTest").style.display="none";
	document.getElementById("associatedCheck").style.display="none";	
	document.getElementById("pathId").value = "";
}

function submit_ok()
{
<% 

-- Fix for TI Security Issue mentioned in 20141205-report-agvtf-v2.pdf section C.1
-- Multiple cross-site scripting vulnerabilities 

local path_id = cgilua.QUERY["path_id"]
if path_id ~= nil then 
	path_id = cgilua.urlcode.escape(path_id)
%>
	var pathId = <%=path_id%>;
<%else%>
	var pathId = document.getElementById("pathId").value;
<%end%>
	window.location = "telephonyTest.lp?pathId=" + pathId;
}
//]]>
</script>
<div class="contentContainer">

		<div class="breadCrumbContainer">
			<ul class="brdCrumb">
				<li><a href="telephonyMeasurement.lp"><%=translate([==[Home]==])%></a></li><li>|</li><li><a href="telephonyMeasurement.lp"><%=translate([==[Telephony services]==])%></a></li>
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
<tr><td align="left"><a href="home.lp"><%=translate([==[Home]==])%></a>&nbsp;&nbsp;>&nbsp;&nbsp;<a href="telephonyMeasurement.lp"><%=translate([==[Telephony services]==])%></a></td></tr>
</table> -->

<% if cgilua.QUERY["asso_warn"] ~= nil then %>
<div id="TeleService" class='contentcontainer' style='display:none'>
<%else%>
<div id="TeleService" class='contentcontainer'>
<%end%>
<hr>

<div class='contentitem'>
<form method="POST" name="assoCheckForm" action="">
<input type="hidden" id="pathId" name="pathId" value="" />
<input type="hidden" id="assoCheck" name="assoCheck" value="0">
<table cellspacing='0' cellpadding='0' class="fontSize">
<tr>
<td>
<table  cellspacing='0' cellpadding='0' width='100%' >
    <tr>
	<td class="verticalAlign"> <table cellspacing='0' cellpadding='0' class="martop5">
	<tr>
	<td class="midarea2 tableTitle"><%=translate([==[Test of voice ports]==])%></td></tr></table></td>
				</tr>
            <tr><td>
			<table width='100%'  cellspacing='0' cellpadding='0' class='servizitable fontSize' style="line-height:150%;"> 
                 <tr><td style="vertical-align:top;padding-top:5px;width:150px;" class="sectionArea-1 padleft40 "><%=translate([==[Tests on FXS port]==])%>1:</td>
                    <td colspan='3' class="sectionArea-2 verticalAlign"><a onclick="associated_check_submit('1')">
						<div class="midarea6-1 mainButton" id="testFXS1" name="testFXS1"><%=translate([==[Lance]==])%></div>
						</a>
					</td>
				</tr>
                <tr><td style="vertical-align:top;padding-top:5px;width:150px" class="sectionArea-1 padleft40 "><%=translate([==[Tests on FXS port]==])%>2:</td>
                    <td colspan='3' class="sectionArea-2 verticalAlign">
						<a onclick="associated_check_submit('2')">
							<div class="midarea6-1 mainButton" id="testFXS2" name="testFXS2"><%=translate([==[Lance]==])%></div>
						</a>
					</td>
				</tr>
		<tr><td style="vertical-align:top;padding-top:5px;width:150px" class="sectionArea-1 padleft40 ">&nbsp;</td>
                                        <td colspan='3' class="sectionArea-2">&nbsp;
                                        </td>
                                </tr>
	

				<!-- For CPE_P00106866 -->
				<!--
				 <tr><td style="vertical-align:top;padding-top:5px;width:150px" class="sectionArea-1 padleft40 "><%=translate([==[Test su porta FXO]==])%>:</td>
                    			<td colspan='3' class="sectionArea-2">
						<a onclick="associated_check_submit('4')">
							<div class="midarea6-1 mainButton" id="testFXS2" name="testFXS2"><%=translate([==[Lance]==])%></div>
						</a>
					</td>
				</tr>
				-->	

            </table>
            </td></tr></table><!-- End of showing test FXS result-->
        </td></tr>
        </table>
  
</form>
</div>
</div>

<% if cgilua.QUERY["asso_warn"] ~= nil and cgilua.QUERY["asso_warn"] == "0" then %>
<div id="voiceTest" style="display:block">
<%else%>
<div id="voiceTest" style="display:none">
<%end%>
  <div class='contentcontainer'>
  <div class='contentitem'>
  <table cellspacing='0' cellpadding='0' width='100%' class="width790 marleft5 martop5">
                  <tr>
                    <td class="verticalAlign padleft35">
                      <div class="width50 fleft"><img src='images/warn__xl.png' alt='Technicolor Gateway'></div>
					  <div class="errInfo"><%=translate([==[Info]==])%></div>
                    </td>
                  </tr>
                  <tr>
                    <td class="verticalAlign">
                      <table width='100%' cellspacing='0' cellpadding='0' class="PageMessage" style="text-align:left">
                        <tr>
                          <td class="errorMessage"><%=translate([==[Warning]==])%>.</td></tr>
            <tr><td class="errorDesc">           
              <p><%=translate([==[Warning: the measurement procedure can result in the removal of telephone calls in progress]==])%></p>
                 <br/>
                 </td></tr></table>
                   </td></tr>
                   <tr><td>
                      <table  cellspacing='0' cellpadding='0' class="fontSize padtop10 width790">
                         <tr><td class="verticalAlign fright">
                            <a class="fright" onclick="submit_ok()">
						<div class="midarea6-1 mainButton" name="thb11"><%=translate([==[Next]==])%></div>
					</a>
				</td>
				<td class="verticalAlign" style="padding-left:15px;">
					<a onclick="closeConfirm()">
						<div class="midarea6-1 mainButton" name="thb12"><%=translate([==[Cancel]==])%></div>
					</a>
        </td></tr></table>
    </td></tr></table>
  </div>
  </div>
</div>


<% if cgilua.QUERY["asso_warn"] ~= nil and cgilua.QUERY["asso_warn"] == "1" then %>
<div id="associatedCheck" style="display:block">
<%else%>
<div id="associatedCheck" style="display:none">
<%end%>

  <div class='contentcontainer'>
  <div class='contentitem'>
  <table cellspacing='0' cellpadding='0' width='100%' class="width790 marleft5 martop5">
                  <tr>
                    <td class="verticalAlign padleft35">
                      <div class="width50 fleft"><img src='images/warn__xl.png' alt='Technicolor Gateway'></div>
					  <div class="errInfo"><%=translate([==[Info]==])%></div>
                    </td>
                  </tr>
                  <tr>
                    <td class="verticalAlign">
                      <table width='100%' cellspacing='0' cellpadding='0' class="PageMessage" style="text-align:left">
                        <tr>
                          <td class="errorMessage"><%=translate([==[Warning]==])%>.</td></tr>
            <tr><td class="errorDesc">          
              <p><%=translate([==[Warning: the measurement procedure can be performed only when the FXS port is not associated with fixed-line input and / or output]==])%></p>
               <br/>
        </td></tr></table>
        </td></tr>
		<tr><td>
         <table  cellspacing='0' cellpadding='0' class="fontSize padtop10 width790">
          <tr><td class="width340">&nbsp;</td>
            <td class="verticalAlign">
					<a onclick="closeConfirm()">
						<div class="midarea6-1 mainButton" name="thb12"><%=translate([==[Cancel]==])%></div>
					</a>
        </td></tr></table>
    </td></tr></table>
  </div>
  </div>
</div>

<script src="js/antiCSRF.js" type="text/javascript"></script>

</body>
</html>
