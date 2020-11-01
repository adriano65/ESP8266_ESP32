<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
          "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<title>Modem Telecom Italia</title>
<!-- <link rel="stylesheet" href="css/style.css" type="text/css"/> -->
<link href="css/master.css" type="text/css" rel="stylesheet"/>
<script language="javascript" type="text/javascript" src="js/script.js"></script>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
<meta http-equiv="Content-Language" content="it"/>
</head>
<% cgilua.lp.include("lp/language.lp") %>
<% local translate = translate %>
<body>
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
                          <td class="errorMessage"><%=translate([==[Operation failure]==])%></td></tr>
            <tr><td class="errorDesc">
            <% if cgilua.QUERY["pageDisplay"] == "enough" then %>
                <p><%=translate([==[Can not add MAC Address. Maximum size of Authorized Devices is 50.]==])%></p>
            <% elseif cgilua.QUERY["pageDisplay"] == "exist" then %>
                <p><%=translate([==[Can not add MAC Address which already exists in Authorized Devices list.]==])%></p>
            <% else %>
                <p><%=translate([==[You can not perform the requested operation]==])%></p>
                <p><%=translate([==[Warning: The configuration change was not implemented due to activity]==])%><br/><%=translate([==[remote maintenance ongoing]==])%><br/><%=translate([==[Repeat a few minutes]==])%></p>
                <p class="paddtop10"><%=translate([==[Press "Continue" to return to previous page]==])%></p>
            <% end %>
            <br/>
        </td></tr></table>
        </td></tr>
		<tr><td>
         <table  cellspacing='0' cellpadding='0' class="fontSize padtop10 width790">
          <tr><td class="width340">&nbsp;</td>
            <td class="verticalAlign">
            <% if cgilua.servervariable"REQUEST_METHOD" == "GET" and cgilua.QUERY["page"] ~= nil then %>
				<a onclick="javascript:document.location.href='<%=cgilua.urlcode.escape(cgilua.QUERY["page"])%>'"><div class='midarea6-1 mainButton' name="thb11"><%=translate([==[Continue]==])%></div></a>
                <!-- <input type="button" onclick="javascript:document.location.href='<%=cgilua.QUERY["page"]%>'" value="<%=translate([==[Continue]==])%>" name="thb11"> -->
            <% else %>
			
				<a onclick='javascript:window.history.back();'><div class='midarea6-1 mainButton' name="thb11"><%=translate([==[Continue]==])%></div></a>
                <!-- <input type="button" onclick='javascript:window.history.back();' value="<%=translate([==[Continue]==])%>" name="thb11"> -->
            <% end %>
            </td></tr></table>
			</td></tr></table>
<script src="js/antiCSRF.js" type="text/javascript"></script>
</div>
</div>
</body>
</html>
