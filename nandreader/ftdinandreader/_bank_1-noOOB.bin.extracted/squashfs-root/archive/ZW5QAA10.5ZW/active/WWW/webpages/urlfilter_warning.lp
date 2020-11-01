<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
<html>
<head>
<% cgilua.lp.include("lp/device.lp") %>
<base target="mainFrame">
<title>Modem Telecom Italia</title>

<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<meta http-equiv="Content-Language" content="it">
<link href="css/master.css" rel="stylesheet" type="text/css" />


</head>
<script language="javascript" type="text/javascript">
	parent.document.getElementById("releasemodem").innerHTML = "Release Modem: <%=getVersion()%>";
</script>
<%
local translate = translate

local msg=translate([==[Warning: the requested URL is blocked. To access, change the configuration of the barring service URLs. Press the "Next" button to access the Management of modems.]==])

%>
<body>

<div class='contentcontainer'>

<div class='contentitem'>
<table cellspacing='0' cellpadding='0' width="100%" class="width750 martop5">
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
                          <td class="errorMessage"><%=translate([==[Operation failed]==])%>.</td></tr>
                             <tr><td class="errorDesc"><p><%=msg%></p><br/>
							</td></tr></table>
							</td></tr>
							<tr><td>
							<table  cellspacing='0' cellpadding='0' class="fontSize padtop10 width790">
							<tr><td class="width340">&nbsp;</td>
							<td class="verticalAlign">
							<a onclick='javascript:top.location.href="/";'>
							<div class="midarea6-1 mainButton" name="thb11"><%=translate([==[Next]==])%></div>
							</a>
						

            </td></tr>
        </table>
    </td>
</tr>
</table>
</div>
</div>
</body>
</html>
