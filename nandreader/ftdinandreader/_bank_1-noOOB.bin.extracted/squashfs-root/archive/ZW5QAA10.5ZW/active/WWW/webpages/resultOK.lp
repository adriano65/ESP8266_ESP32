<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Frameset//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-frameset.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
<title>Modem Telecom Italia</title>
<link rel="stylesheet" href="css/style.css" type="text/css" />
<link href="css/menu.css" type="text/css" rel="stylesheet"/>
<% cgilua.lp.include("lp/language.lp") %>
<% cgilua.lp.include("lp/mbus_util.lp")%>
<%
	local POST=cgilua.POST

	if cgilua.servervariable"REQUEST_METHOD" == "POST" then
		local page = "/"
		local round = "2"
		if POST["page"]~=nil and POST["page"]~="" then
			page = tostring(POST["page"])
		end
		
		if page=="statoPortMapping.lp" then
			round = "3"
		end
		
		saveall(0, 1)
		cgilua.redirect("save_alert.lp", { u = page, r = round })
		return	
	end
%>
</head>
<body>
<div class='contentcontainer'>
<div class='contentitem'>
<form name="saveResult" method="post" action="">
<input type="hidden" id="page" name="page" value="<%=cgilua.QUERY["page"]%>" />
<table cellspacing='0' cellpadding='0' width="100%">
<tr>
    <td class='icon' style='vertical-align:top' width='100px'><img src='images/warn__xl.gif' alt='Technicolor Gateway'></td>
    <td class='data' style='vertical-align:top'>
        <table cellspacing='0' cellpadding='0' width="100%">
        <tr><td>
            <table cellspacing='0' cellpadding='0' width='100%'><tr><td style='vertical-align:top'>
            <span class='itemtitle'>Info</span><br/><br/>
            <table width='100%' cellspacing='0' cellpadding='0' class="PageMessage">
            <tr><td class="trScura"><%=translate([==[Operation performed]==])%></td></tr>
            <tr><td class="tdBiancaC">
                <p>&nbsp;<%=translate([==[Successfully finished]==])%></p>
                <p><%=translate([==[To make permanent configuration changes, press the "Continue"]==])%>
                <%=translate([==[Failure to save leads to zero change settings after shutdown or restart your modem]==])%></p>
                <p><%=translate([==[Press "Continue" to save the configuration or]==])%>
                <%=translate([==[press "Cancel" and manually turn off the modem to undo the changes made]==])%></p>
            </td></tr></table>
            </td></tr>
            <tr><td align='center'>
                <input type="submit" value="<%=translate([==[Continue]==])%>" name="thb11" />&nbsp;&nbsp;&nbsp;&nbsp;
                <input type="button" onclick="javascript:document.location.href='<%=cgilua.QUERY["page"]%>'"  value="<%=translate([==[Cancel]==])%>" name="thb12" />
            </td></tr></table>
        </td></tr></table>
    </td></tr></table>
</form>
<script src="js/antiCSRF.js" type="text/javascript"></script>
</div>
</div>
</body>
</html>
